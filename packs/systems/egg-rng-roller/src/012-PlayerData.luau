--[[
	PlayerData (server only)

	Every player's money, eggs and equipped egg, saved with DataStores.

	  - Loads when a player joins (3 tries). A brand-new player gets Config.Economy.StartingMoney.
	  - Saves when they leave, every Config.Data.AutosaveInterval seconds, and when the server shuts down.
	  - If their save could not be LOADED, nothing is saved for that session, so a hiccup can
	    never overwrite real progress with an empty save.
	  - If DataStores are unavailable (e.g. Studio without "Enable Studio Access to API Services")
	    the game still works, but progress is only kept until the player leaves.

	Every egg is its own item with a unique number (no stacking). Old saves that stored counts
	("3 Basic Eggs") are turned into separate eggs automatically the first time they load.

	What clients can see (read-only, created and updated by the server):
	  Player.leaderstats.Money             (IntValue)    -> also shows on the player list
	  Player.EggInventory.<id>             (StringValue) -> one per egg; Value = the egg's TemplateName
	  Player attribute "EquippedEggId"     (number)      -> the id of the egg being held (nil = none)
	  Player attribute "HeldEgg"           (string)      -> that egg's TemplateName, carried in front of them

	Only the server changes data, through the functions below.
]]

local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("EggRandomizer"):WaitForChild("Config"))

local PlayerData = {}

local LOG = "[EggData]"
local ECONOMY = Config.Economy
local DATA = Config.Data
local MAX_MONEY = 1e15
local HARD_EGG_LIMIT = 1000 -- safety cap when loading old/corrupted saves
local SAVE_VERSION = 2

local function maxEggs(): number
	local configured = Config.Inventory and tonumber(Config.Inventory.MaxEggs)
	return math.clamp(math.floor(configured or 200), 1, HARD_EGG_LIMIT)
end

local store: DataStore? = nil
local storeDisabledReason: string? = nil
do
	local ok, result = pcall(function()
		return DataStoreService:GetDataStore(DATA.StoreName)
	end)
	if ok then
		store = result
	else
		storeDisabledReason = tostring(result)
	end
end

type EggItem = { id: number, egg: string }

type Session = {
	money: number,
	eggs: { EggItem }, -- in the order they were collected
	nextId: number,
	equipped: number?,
	receipts: { string }, -- recent Robux purchase IDs already paid out (never pay twice)
	loaded: boolean,
	canSave: boolean,
	dirty: boolean,
	moneyValue: IntValue?,
	inventory: Folder?,
}

local sessions: { [Player]: Session } = {}
local loadedEvent = Instance.new("BindableEvent")

-- Fires (player, isSaving) once a player's data is ready.
PlayerData.PlayerLoaded = loadedEvent.Event

local function dataKey(player: Player): string
	return "Player_" .. player.UserId
end

local function disableStore(reason: string)
	if store then
		store = nil
		storeDisabledReason = reason
		warn(LOG, "DataStores are unavailable, so progress will NOT save this session:", reason)
		warn(LOG, "To test saving in Studio: Game Settings > Security > Enable Studio Access to API Services.")
	end
end

-- Turn whatever was saved into clean data (protects against corrupted or old saves).
local function sanitize(raw: any)
	local data = { Money = ECONOMY.StartingMoney, Eggs = {} :: { EggItem }, NextId = 1, Equipped = nil :: number?, Receipts = {} :: { string } }
	if type(raw) ~= "table" then
		return data
	end
	if type(raw.Money) == "number" and raw.Money == raw.Money then
		data.Money = math.clamp(math.floor(raw.Money), 0, MAX_MONEY)
	end

	local nextId = 1
	if type(raw.NextEggId) == "number" and raw.NextEggId == raw.NextEggId then
		nextId = math.max(1, math.floor(raw.NextEggId))
	end
	local seen = {}
	if type(raw.Eggs) == "table" then
		if raw.Version == SAVE_VERSION then
			-- current format: a list of { Id = number, Egg = string }
			for _, entry in ipairs(raw.Eggs) do
				if #data.Eggs >= HARD_EGG_LIMIT then
					break
				end
				if type(entry) == "table" and type(entry.Egg) == "string" and type(entry.Id) == "number" then
					local id = math.floor(entry.Id)
					if id >= 1 and not seen[id] then
						seen[id] = true
						table.insert(data.Eggs, { id = id, egg = entry.Egg })
						nextId = math.max(nextId, id + 1)
					end
				end
			end
		else
			-- old format { [eggName] = count }: give every counted egg its own id
			local names = {}
			for eggId, count in raw.Eggs do
				if type(eggId) == "string" and type(count) == "number" and count >= 1 then
					table.insert(names, eggId)
				end
			end
			table.sort(names)
			for _, eggId in names do
				for _ = 1, math.floor(raw.Eggs[eggId]) do
					if #data.Eggs >= HARD_EGG_LIMIT then
						break
					end
					table.insert(data.Eggs, { id = nextId, egg = eggId })
					seen[nextId] = true
					nextId += 1
				end
			end
		end
	end
	data.NextId = nextId
	if type(raw.Equipped) == "number" and seen[raw.Equipped] then
		data.Equipped = raw.Equipped
	end
	if type(raw.Receipts) == "table" then
		for _, receipt in ipairs(raw.Receipts) do
			if type(receipt) == "string" then
				table.insert(data.Receipts, receipt)
			end
		end
	end
	return data
end

-- Returns (savedData or nil, canSave)
local function loadData(player: Player): (any, boolean)
	if not store then
		return nil, false
	end
	for attempt = 1, 3 do
		local currentStore = store
		if not currentStore then
			return nil, false
		end
		local ok, result = pcall(function()
			return currentStore:GetAsync(dataKey(player))
		end)
		if ok then
			return result, true
		end
		local message = tostring(result)
		local lower = message:lower()
		if lower:find("studio access to apis", 1, true)
			or lower:find("studioaccesstoapisnotallowed", 1, true)
			or lower:find("publish", 1, true)
			or lower:find("403", 1, true)
		then
			disableStore(message) -- not a hiccup: retrying won't help
			return nil, false
		end
		warn(LOG, "Load failed for", player.Name, "(try " .. attempt .. "):", message)
		task.wait(attempt)
	end
	return nil, false -- could not load: play on, but never overwrite their real save
end

local function saveSession(player: Player, session: Session): boolean
	if not (store and session.loaded and session.canSave) then
		return false
	end
	local eggs = table.create(#session.eggs)
	for i, item in session.eggs do
		eggs[i] = { Id = item.id, Egg = item.egg }
	end
	local payload = {
		Version = SAVE_VERSION,
		Money = session.money,
		Eggs = eggs,
		NextEggId = session.nextId,
		Equipped = session.equipped,
		Receipts = table.clone(session.receipts),
	}
	for attempt = 1, 3 do
		local currentStore = store
		if not currentStore then
			return false
		end
		local ok, err = pcall(function()
			currentStore:UpdateAsync(dataKey(player), function()
				return payload
			end)
		end)
		if ok then
			session.dirty = false
			return true
		end
		warn(LOG, "Save failed for", player.Name, "(try " .. attempt .. "):", err)
		task.wait(attempt)
	end
	return false
end

local function findItem(session: Session, id: number): (EggItem?, number?)
	for index, item in session.eggs do
		if item.id == id then
			return item, index
		end
	end
	return nil, nil
end

-- Mirror the equipped egg onto the player so every client can draw it above their head.
local function publishEquipped(player: Player, session: Session)
	local item = session.equipped and findItem(session, session.equipped)
	if not item then
		session.equipped = nil
	end
	player:SetAttribute("EquippedEggId", item and item.id or nil)
	player:SetAttribute("HeldEgg", item and item.egg or nil)
end

local function addEggValue(session: Session, item: EggItem)
	local inventory = session.inventory
	if inventory then
		local value = Instance.new("StringValue")
		value.Name = tostring(item.id)
		value.Value = item.egg
		value.Parent = inventory
	end
end

-- Create the values clients read (money on the player list + inventory folder).
local function buildValues(player: Player, session: Session)
	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then
		leaderstats = Instance.new("Folder")
		leaderstats.Name = "leaderstats"
	end
	local money = Instance.new("IntValue")
	money.Name = ECONOMY.CurrencyName
	money.Value = session.money
	money.Parent = leaderstats
	leaderstats.Parent = player

	local inventory = Instance.new("Folder")
	inventory.Name = "EggInventory"
	session.inventory = inventory
	for _, item in session.eggs do
		addEggValue(session, item)
	end
	inventory.Parent = player

	session.moneyValue = money
end

local function onPlayerAdded(player: Player)
	if sessions[player] then
		return
	end
	local session: Session = { money = 0, eggs = {}, nextId = 1, receipts = {}, loaded = false, canSave = false, dirty = false }
	sessions[player] = session

	local raw, canSave = loadData(player)
	if player.Parent == nil or sessions[player] ~= session then
		return -- left while loading
	end
	local data = sanitize(raw)
	session.money = data.Money
	session.eggs = data.Eggs
	session.nextId = data.NextId
	session.equipped = data.Equipped
	session.receipts = data.Receipts
	session.canSave = canSave
	session.loaded = true
	-- an old count-based save was just converted: write the new format on the next save
	if type(raw) == "table" and raw.Version ~= SAVE_VERSION and #data.Eggs > 0 then
		session.dirty = true
	end
	buildValues(player, session)
	publishEquipped(player, session)
	player:SetAttribute("EggDataSaving", canSave)
	loadedEvent:Fire(player, canSave)
end

local function onPlayerRemoving(player: Player)
	local session = sessions[player]
	if session then
		saveSession(player, session)
		sessions[player] = nil
	end
end

---------------------------------------------------------------------------
-- Public API
---------------------------------------------------------------------------
local started = false
function PlayerData.start()
	if started then
		return
	end
	started = true
	if storeDisabledReason then
		warn(LOG, "DataStores are unavailable, so progress will NOT save:", storeDisabledReason)
	end

	Players.PlayerAdded:Connect(onPlayerAdded)
	Players.PlayerRemoving:Connect(onPlayerRemoving)
	for _, player in Players:GetPlayers() do
		task.spawn(onPlayerAdded, player)
	end

	game:BindToClose(function()
		local pending = 0
		for player, session in sessions do
			pending += 1
			task.spawn(function()
				saveSession(player, session)
				pending -= 1
			end)
		end
		local startTime = os.clock()
		while pending > 0 and os.clock() - startTime < 25 do
			task.wait(0.1)
		end
	end)

	task.spawn(function()
		while true do
			task.wait(math.max(DATA.AutosaveInterval or 120, 30))
			for player, session in sessions do
				if session.dirty then
					task.spawn(saveSession, player, session)
				end
			end
		end
	end)
end

function PlayerData.isLoaded(player: Player): boolean
	local session = sessions[player]
	return session ~= nil and session.loaded
end

function PlayerData.isSaving(player: Player): boolean
	local session = sessions[player]
	return session ~= nil and session.canSave and store ~= nil
end

function PlayerData.getMoney(player: Player): number
	local session = sessions[player]
	return session and session.money or 0
end

function PlayerData.setMoney(player: Player, amount: number): boolean
	local session = sessions[player]
	if not (session and session.loaded) then
		return false
	end
	session.money = math.clamp(math.floor(amount), 0, MAX_MONEY)
	session.dirty = true
	if session.moneyValue then
		session.moneyValue.Value = session.money
	end
	return true
end

function PlayerData.addMoney(player: Player, amount: number): boolean
	return PlayerData.setMoney(player, PlayerData.getMoney(player) + amount)
end

-- Takes the money only if the player has enough. Returns true if it was taken.
function PlayerData.trySpend(player: Player, amount: number): boolean
	local session = sessions[player]
	if not (session and session.loaded) or amount < 0 or session.money < amount then
		return false
	end
	return PlayerData.setMoney(player, session.money - amount)
end

function PlayerData.getMaxEggs(): number
	return maxEggs()
end

-- How many eggs the player owns in total.
function PlayerData.getEggTotal(player: Player): number
	local session = sessions[player]
	return session and #session.eggs or 0
end

function PlayerData.hasRoom(player: Player): boolean
	return PlayerData.getEggTotal(player) < maxEggs()
end

-- How many of one egg type the player owns.
function PlayerData.getEggCount(player: Player, eggId: string): number
	local session = sessions[player]
	local count = 0
	if session then
		for _, item in session.eggs do
			if item.egg == eggId then
				count += 1
			end
		end
	end
	return count
end

-- Adds ONE egg as its own item. Returns (true, newId) or (false, reason) where reason is
-- "loading" or "full".
function PlayerData.addEgg(player: Player, eggId: string): (boolean, any)
	local session = sessions[player]
	if not (session and session.loaded) then
		return false, "loading"
	end
	if #session.eggs >= maxEggs() then
		return false, "full"
	end
	local item = { id = session.nextId, egg = eggId }
	session.nextId += 1
	table.insert(session.eggs, item)
	session.dirty = true
	addEggValue(session, item)
	return true, item.id
end

-- A copy of the player's eggs ({ id, egg } items).
function PlayerData.getEggs(player: Player): { EggItem }
	local session = sessions[player]
	return session and table.clone(session.eggs) or {}
end

-- Removes the given egg ids (only ones the player owns). Returns the removed items.
function PlayerData.removeEggs(player: Player, ids: { number }): { EggItem }
	local session = sessions[player]
	if not (session and session.loaded) then
		return {}
	end
	local wanted = {}
	for _, id in ids do
		wanted[id] = true
	end
	local removed, kept = {}, {}
	for _, item in session.eggs do
		table.insert(if wanted[item.id] then removed else kept, item)
	end
	if #removed == 0 then
		return removed
	end
	session.eggs = kept
	session.dirty = true
	if session.inventory then
		for _, item in removed do
			local value = session.inventory:FindFirstChild(tostring(item.id))
			if value then
				value:Destroy()
			end
		end
	end
	if session.equipped and wanted[session.equipped] then
		session.equipped = nil
	end
	publishEquipped(player, session)
	return removed
end

function PlayerData.clearEggs(player: Player): boolean
	local session = sessions[player]
	if not (session and session.loaded) then
		return false
	end
	table.clear(session.eggs)
	session.equipped = nil
	session.dirty = true
	if session.inventory then
		session.inventory:ClearAllChildren()
	end
	publishEquipped(player, session)
	return true
end

-- Hold one of the player's eggs above their head (id = nil puts it away).
-- Returns (ok, message).
function PlayerData.equipEgg(player: Player, id: number?): (boolean, string?)
	local session = sessions[player]
	if not (session and session.loaded) then
		return false, "Your data is still loading - try again in a second."
	end
	if id ~= nil and not findItem(session, id) then
		return false, "You don't own that egg."
	end
	if session.equipped ~= id then
		session.equipped = id
		session.dirty = true
	end
	publishEquipped(player, session)
	return true, nil
end

-- Robux purchases: remember which receipts were already paid out (keeps the last 100).
function PlayerData.hasReceipt(player: Player, purchaseId: string): boolean
	local session = sessions[player]
	return session ~= nil and table.find(session.receipts, purchaseId) ~= nil
end

function PlayerData.addReceipt(player: Player, purchaseId: string)
	local session = sessions[player]
	if not session then
		return
	end
	table.insert(session.receipts, purchaseId)
	while #session.receipts > 100 do
		table.remove(session.receipts, 1)
	end
	session.dirty = true
end

-- Save one player right now (returns true if it saved).
function PlayerData.saveNow(player: Player): boolean
	local session = sessions[player]
	return session ~= nil and saveSession(player, session)
end

return PlayerData
