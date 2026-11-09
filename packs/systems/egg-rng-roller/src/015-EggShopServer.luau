--[[
	EggShopServer

	Money, buying rolled eggs, passive income and the admin panel — all decided here on
	the server. Clients only ASK (through ReplicatedStorage.EggRandomizer.Remotes) and every
	request is checked before anything changes.

	  BuyEgg (RemoteFunction)      client -> server: (machine, slotIndex) -> (ok, message)
	  EquipEgg (RemoteFunction)    client -> server: (eggItemId or nil)   -> (ok, message)
	  SellEggs (RemoteFunction)    client -> server: ({Ids} or {All=true}) -> (ok, message, cash)
	  AdminAction (RemoteFunction) client -> server: (action, data)        -> (ok, message)
	  Notify (RemoteEvent)         server -> client: (message, kind)       toast messages

	Buying rules: only the player who pulled the lever, only after the roll has finished,
	only once per pedestal, only when standing near it, and only with enough money.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")

local Shared = ReplicatedStorage:WaitForChild("EggRandomizer")
local Config = require(Shared:WaitForChild("Config"))
local Remotes = Shared:WaitForChild("Remotes")
local PlayerData = require(script.Parent:WaitForChild("PlayerData"))

-- (older places don't have these remotes yet)
local function remoteFunction(name: string): RemoteFunction
	local remote = Remotes:FindFirstChild(name)
	if not remote then
		remote = Instance.new("RemoteFunction")
		remote.Name = name
		remote.Parent = Remotes
	end
	return remote :: RemoteFunction
end
local EquipEggRemote = remoteFunction("EquipEgg")
local SellEggsRemote = remoteFunction("SellEggs")

local LOG = "[EggShop]"
local ECONOMY = Config.Economy
local MAX_ADMIN_AMOUNT = 1e12

local EGG_INFO = {}
for _, entry in Config.Eggs do
	EGG_INFO[entry.TemplateName] = entry
end

local function formatMoney(amount: number): string
	local text = tostring(math.floor(math.abs(amount)))
	local withCommas = text:reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
	return (amount < 0 and "-" or "") .. ECONOMY.CurrencySymbol .. withCommas
end

-- "a Basic Egg" / "an Angel Egg"
local function withArticle(name: string): string
	return (name:match("^[AEIOUaeiou]") and "an " or "a ") .. name
end

local function notify(player: Player, message: string, kind: string?)
	Remotes.Notify:FireClient(player, message, kind or "info")
end

-- Simple per-player spam guard for remotes.
local lastRequest: { [Player]: { [string]: number } } = {}
local function tooFast(player: Player, action: string, gap: number): boolean
	local times = lastRequest[player]
	if not times then
		times = {}
		lastRequest[player] = times
	end
	local now = os.clock()
	if times[action] and now - times[action] < gap then
		return true
	end
	times[action] = now
	return false
end

---------------------------------------------------------------------------
-- Player data + admin flag
---------------------------------------------------------------------------
local adminIds = {}
for _, userId in Config.Admin.UserIds do
	adminIds[userId] = true
end

local function isAdmin(player: Player): boolean
	if adminIds[player.UserId] then
		return true
	end
	if game.CreatorType == Enum.CreatorType.User and player.UserId == game.CreatorId then
		return true
	end
	if game.CreatorType == Enum.CreatorType.Group then
		local ok, rank = pcall(function()
			return player:GetRankInGroup(game.CreatorId)
		end)
		if ok and rank >= (Config.Admin.GroupMinRank or 255) then
			return true
		end
	end
	return false
end

PlayerData.PlayerLoaded:Connect(function(player: Player, isSaving: boolean)
	if not isSaving then
		notify(player, "Saving is off right now - your progress won't be kept after you leave.", "warn")
	end
end)
PlayerData.start()

local function onPlayerAdded(player: Player)
	-- only used to show/hide the admin button; every admin request is re-checked below
	player:SetAttribute("EggAdmin", isAdmin(player))
end
Players.PlayerAdded:Connect(onPlayerAdded)
for _, player in Players:GetPlayers() do
	task.spawn(onPlayerAdded, player)
end
Players.PlayerRemoving:Connect(function(player)
	lastRequest[player] = nil
end)

---------------------------------------------------------------------------
-- Passive income
---------------------------------------------------------------------------
task.spawn(function()
	local interval = tonumber(ECONOMY.IncomeInterval) or 0
	local amount = tonumber(ECONOMY.IncomeAmount) or 0
	if interval <= 0 or amount <= 0 then
		return
	end
	while true do
		task.wait(interval)
		for _, player in Players:GetPlayers() do
			if PlayerData.isLoaded(player) then
				PlayerData.addMoney(player, amount)
			end
		end
	end
end)

---------------------------------------------------------------------------
-- Buying a rolled egg
---------------------------------------------------------------------------
local function findSlotAnchor(machine: Instance, slotIndex: number): BasePart?
	local slots = machine:FindFirstChild("Slots")
	if not slots then
		return nil
	end
	for _, slot in slots:GetChildren() do
		if slot:GetAttribute("SlotIndex") == slotIndex then
			local anchor = slot:FindFirstChild("EggAnchor")
			return anchor and anchor:IsA("BasePart") and anchor or nil
		end
	end
	return nil
end

-- Returns (ok, message). No cooldown: players can buy several eggs as fast as they like
-- (each pedestal can only be bought once per roll, so there's nothing to spam).
Remotes.BuyEgg.OnServerInvoke = function(player: Player, machine: any, slotIndex: any)
	if typeof(machine) ~= "Instance" or not CollectionService:HasTag(machine, Config.MachineTag) then
		return false, "That machine doesn't exist."
	end
	local slotCount = machine:GetAttribute("SlotCount") or 0
	if type(slotIndex) ~= "number" or slotIndex ~= math.floor(slotIndex) or slotIndex < 1 or slotIndex > slotCount then
		return false, "Nothing to buy there."
	end
	if not PlayerData.isLoaded(player) then
		return false, "Your data is still loading - try again in a second."
	end
	if machine:GetAttribute("RolledByUserId") ~= player.UserId then
		return false, "Only the player who rolled can buy these eggs."
	end
	if machine:GetAttribute("State") == "Rolling" then
		return false, "Wait for the roll to finish."
	end

	local results = string.split(machine:GetAttribute("Results") or "", ",")
	local eggId = results[slotIndex]
	local info = eggId and EGG_INFO[eggId]
	if not info then
		return false, "Nothing to buy there."
	end
	local bought = machine:GetAttribute("Bought") or ""
	if bought:sub(slotIndex, slotIndex) == "1" then
		return false, "You already bought that egg."
	end

	local anchor = findSlotAnchor(machine, slotIndex)
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not (anchor and root) or (root.Position - anchor.Position).Magnitude > (ECONOMY.BuyDistance or 16) then
		return false, "Get closer to the egg."
	end

	if not PlayerData.hasRoom(player) then
		return false, "Your inventory is full (" .. PlayerData.getMaxEggs() .. " eggs)."
	end

	local price = math.max(0, math.floor(tonumber(info.Price) or 0))
	if not PlayerData.trySpend(player, price) then
		return false, "Not enough money! You need " .. formatMoney(price - PlayerData.getMoney(player)) .. " more."
	end

	-- mark this pedestal as bought (no yields since the checks above, so no double-buys)
	local flags = {}
	for i = 1, slotCount do
		flags[i] = bought:sub(i, i) == "1" and "1" or "0"
	end
	flags[slotIndex] = "1"
	machine:SetAttribute("Bought", table.concat(flags))
	PlayerData.addEgg(player, eggId) -- room was checked above (no yields in between)

	print(LOG, player.Name, "bought", eggId, "for", formatMoney(price))
	return true, "You bought " .. withArticle(info.DisplayName or eggId) .. "!"
end

---------------------------------------------------------------------------
-- Holding an egg above your head (equip / unequip from the inventory)
---------------------------------------------------------------------------
EquipEggRemote.OnServerInvoke = function(player: Player, id: any)
	if tooFast(player, "equip", 0.2) then
		return false, "Slow down!"
	end
	if id ~= nil and (type(id) ~= "number" or id ~= math.floor(id) or id < 1) then
		return false, "That egg doesn't exist."
	end
	return PlayerData.equipEgg(player, id)
end

---------------------------------------------------------------------------
-- Selling eggs (one egg, or "Sell All" which keeps the equipped egg)
---------------------------------------------------------------------------
local function sellPrice(eggId: string): number
	local info = EGG_INFO[eggId]
	if not info then
		return 0
	end
	if tonumber(info.SellPrice) then
		return math.max(0, math.floor(info.SellPrice))
	end
	return math.max(0, math.floor((tonumber(info.Price) or 0) * (tonumber(ECONOMY.SellRate) or 0.5)))
end

SellEggsRemote.OnServerInvoke = function(player: Player, request: any)
	if tooFast(player, "sell", 0.15) then
		return false, "Slow down!"
	end
	if not PlayerData.isLoaded(player) then
		return false, "Your data is still loading - try again in a second."
	end
	if type(request) ~= "table" then
		return false, "Nothing to sell."
	end

	local ids = {}
	if request.All == true then
		local equipped = player:GetAttribute("EquippedEggId")
		for _, item in PlayerData.getEggs(player) do
			if item.id ~= equipped then
				table.insert(ids, item.id)
			end
		end
		if #ids == 0 then
			return false, "Nothing to sell - your equipped egg is kept."
		end
	elseif type(request.Ids) == "table" then
		for index, id in request.Ids do
			if index > 1000 then
				break
			end
			if type(id) == "number" and id == math.floor(id) then
				table.insert(ids, id)
			end
		end
	end

	-- only eggs the player really owns are removed (and paid for)
	local removed = PlayerData.removeEggs(player, ids)
	if #removed == 0 then
		return false, "You don't own that egg."
	end
	local total = 0
	for _, item in removed do
		total += sellPrice(item.egg)
	end
	PlayerData.addMoney(player, total)
	print(LOG, player.Name, "sold", #removed, "egg(s) for", formatMoney(total))
	if #removed == 1 then
		return true, "Sold for " .. formatMoney(total) .. "!", total
	end
	return true, "Sold " .. #removed .. " eggs for " .. formatMoney(total) .. "!", total
end

---------------------------------------------------------------------------
-- Admin panel
---------------------------------------------------------------------------
local function parseAmount(value: any, allowZero: boolean): number?
	local amount = tonumber(value)
	if not amount or amount ~= amount or amount == math.huge or amount == -math.huge then
		return nil
	end
	amount = math.floor(amount)
	if amount < 0 or (amount == 0 and not allowZero) or amount > MAX_ADMIN_AMOUNT then
		return nil
	end
	return amount
end

Remotes.AdminAction.OnServerInvoke = function(player: Player, action: any, data: any)
	if not isAdmin(player) then
		warn(LOG, player.Name, "tried to use the admin panel without permission.")
		return false, "You are not an admin."
	end
	if tooFast(player, "admin", 0.15) then
		return false, "Slow down!"
	end
	if type(data) ~= "table" then
		data = {}
	end

	local target = player
	if data.TargetUserId ~= nil then
		target = Players:GetPlayerByUserId(tonumber(data.TargetUserId) or 0)
		if not target then
			return false, "That player isn't in the server."
		end
	end
	if not PlayerData.isLoaded(target) then
		return false, target.Name .. "'s data is still loading."
	end

	if action == "GiveMoney" then
		local amount = parseAmount(data.Amount, false)
		if not amount then
			return false, "Type an amount above 0."
		end
		PlayerData.addMoney(target, amount)
		if target ~= player then
			notify(target, "An admin gave you " .. formatMoney(amount) .. "!", "success")
		end
		print(LOG, player.Name, "gave", formatMoney(amount), "to", target.Name)
		return true, "Gave " .. formatMoney(amount) .. " to " .. target.Name .. "."
	elseif action == "SetMoney" then
		local amount = parseAmount(data.Amount, true)
		if not amount then
			return false, "Type an amount of 0 or more."
		end
		PlayerData.setMoney(target, amount)
		print(LOG, player.Name, "set", target.Name, "money to", formatMoney(amount))
		return true, target.Name .. " now has " .. formatMoney(amount) .. "."
	elseif action == "GiveEgg" then
		local info = type(data.EggId) == "string" and EGG_INFO[data.EggId]
		if not info then
			return false, "Pick an egg first."
		end
		local added = PlayerData.addEgg(target, data.EggId)
		if not added then
			return false, target.Name .. "'s inventory is full (" .. PlayerData.getMaxEggs() .. " eggs)."
		end
		if target ~= player then
			notify(target, "An admin gave you " .. withArticle(info.DisplayName) .. "!", "success")
		end
		return true, "Gave " .. withArticle(info.DisplayName) .. " to " .. target.Name .. "."
	elseif action == "ClearEggs" then
		PlayerData.clearEggs(target)
		print(LOG, player.Name, "cleared", target.Name .. "'s inventory")
		return true, "Cleared " .. target.Name .. "'s inventory."
	end
	return false, "Unknown action."
end
