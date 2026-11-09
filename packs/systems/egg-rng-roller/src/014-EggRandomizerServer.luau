--[[
	EggRandomizerServer

	Server authority for every Egg Randomizer machine (models tagged "EggRandomizerMachine").
	  - Validates lever use (ProximityPrompt), blocks re-use while busy, runs the cooldown.
	  - Picks each slot's egg with EggSelector (the client never chooses anything).
	  - Publishes the roll to every client through attributes on the machine model:
	        Results       "SpaceEgg,BasicEgg"   final egg per slot, in SlotIndex order
	        RollId        increments on every pull (clients start the animation on change)
	        RollSeed      seed for the cosmetic swap order, so all players see the same shuffle
	        RollStartTime server time of the pull (late joiners sync to it)
	        State         "Ready" | "Rolling" | "Cooldown"
	    No RemoteEvents are needed.
	  - Copies the egg models into ReplicatedStorage so clients can render display clones.
	    The originals in ServerStorage > EggModels are only ever cloned, never modified.
]]

local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")

local Shared = ReplicatedStorage:WaitForChild("EggRandomizer")
local Config = require(Shared:WaitForChild("Config"))
local ShuffleTimeline = require(Shared:WaitForChild("ShuffleTimeline"))
local EggSelector = require(script.Parent:WaitForChild("EggSelector"))

local LOG_PREFIX = "[EggRandomizer]"

---------------------------------------------------------------------------
-- 1. Publish display copies of the egg templates for clients
---------------------------------------------------------------------------
local templateFolder = ServerStorage:WaitForChild(Config.TemplateFolderName, 10)
if not templateFolder then
	warn(LOG_PREFIX, "ServerStorage." .. Config.TemplateFolderName .. " is missing - the machine is disabled.")
	return
end

local displayTemplates = Instance.new("Folder")
displayTemplates.Name = "DisplayTemplates"

local usableEggs = {}
for _, entry in Config.Eggs do
	local template = templateFolder:FindFirstChild(entry.TemplateName)
	local copy = template and template:IsA("Model") and template:Clone()
	if copy then
		-- display copies never need code
		for _, descendant in copy:GetDescendants() do
			if descendant:IsA("BaseScript") then
				descendant:Destroy()
			end
		end
		copy.Parent = displayTemplates
		table.insert(usableEggs, entry)
	else
		warn(LOG_PREFIX, string.format("Egg model '%s' not found in ServerStorage.%s - skipped.", entry.TemplateName, Config.TemplateFolderName))
	end
end

local previous = Shared:FindFirstChild("DisplayTemplates")
if previous then
	previous:Destroy()
end
displayTemplates.Parent = Shared -- parented once, after it is filled, so clients receive it complete

if #usableEggs == 0 then
	warn(LOG_PREFIX, "No usable egg models - the machine is disabled.")
	return
end

local selector = EggSelector.new(usableEggs)
local seedRng = Random.new()

---------------------------------------------------------------------------
-- 2. Machine controller
---------------------------------------------------------------------------
local activeMachines: { [Instance]: boolean } = setmetatable({}, { __mode = "k" }) :: any

local function countSlots(machine: Instance): number
	local slots = machine:FindFirstChild("Slots")
	local count = 0
	if slots then
		for _, slot in slots:GetChildren() do
			if slot:FindFirstChild("EggAnchor") then
				count += 1
			end
		end
	end
	return count
end

local function promptPosition(prompt: ProximityPrompt): Vector3?
	local parent = prompt.Parent
	if parent and parent:IsA("Attachment") then
		return parent.WorldPosition
	elseif parent and parent:IsA("BasePart") then
		return parent.Position
	end
	return nil
end

local function canUse(player: Player, prompt: ProximityPrompt): boolean
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local root = character and character:FindFirstChild("HumanoidRootPart")
	local leverPosition = promptPosition(prompt)
	if not (humanoid and root and leverPosition) or humanoid.Health <= 0 then
		return false
	end
	return ((root :: BasePart).Position - leverPosition).Magnitude <= Config.MaxUseDistance
end

local function setupMachine(machine: Instance)
	if activeMachines[machine] or not machine:IsA("Model") then
		return
	end

	local prompt = machine:FindFirstChild("RollPrompt", true)
	if not (prompt and prompt:IsA("ProximityPrompt")) then
		warn(LOG_PREFIX, machine:GetFullName(), "has no ProximityPrompt named RollPrompt - skipped.")
		return
	end
	local slotCount = countSlots(machine)
	if slotCount == 0 then
		warn(LOG_PREFIX, machine:GetFullName(), "has no slots with an EggAnchor - skipped.")
		return
	end

	-- Each slot needs its own SlotIndex (1, 2, 3...) so results land on the right pedestal for everyone.
	local seenIndex = {}
	for _, slot in machine.Slots:GetChildren() do
		if slot:FindFirstChild("EggAnchor") then
			local index = slot:GetAttribute("SlotIndex")
			if index == nil then
				warn(LOG_PREFIX, slot:GetFullName(), "has no SlotIndex attribute - give it a unique number (1, 2, ...).")
			elseif seenIndex[index] then
				warn(LOG_PREFIX, string.format("%s and %s both have SlotIndex %s - give each slot a unique number.", seenIndex[index]:GetFullName(), slot:GetFullName(), tostring(index)))
			else
				seenIndex[index] = slot
			end
		end
	end
	activeMachines[machine] = true

	prompt.ActionText = Config.Prompt.ActionText
	prompt.ObjectText = Config.Prompt.ObjectText
	prompt.HoldDuration = Config.Prompt.HoldDuration
	prompt.MaxActivationDistance = Config.Prompt.MaxActivationDistance
	prompt.Enabled = true

	machine:SetAttribute("SlotCount", slotCount)
	machine:SetAttribute("State", "Ready")
	machine:SetAttribute("RollId", 0)

	-- How long the machine stays busy for one pull (lever + shuffle + reveal + settle).
	local busyTime = ShuffleTimeline.totalDuration(Config, slotCount) + Config.Reveal.SettleTime
	local busy = false

	local function runRoll(player: Player)
		local results = table.create(slotCount)
		for slotIndex = 1, slotCount do
			results[slotIndex] = selector:pick()
		end

		-- Order matters: RollId goes last because clients start the animation when it changes.
		machine:SetAttribute("Results", table.concat(results, ","))
		machine:SetAttribute("RollSeed", seedRng:NextInteger(1, 1000000000))
		machine:SetAttribute("RollStartTime", workspace:GetServerTimeNow())
		machine:SetAttribute("RolledBy", player.Name)
		machine:SetAttribute("RolledByUserId", player.UserId) -- only this player may buy the result (EggShopServer)
		machine:SetAttribute("Bought", string.rep("0", slotCount)) -- "1" per slot once bought
		machine:SetAttribute("State", "Rolling")
		machine:SetAttribute("RollId", (machine:GetAttribute("RollId") or 0) + 1)
		print(LOG_PREFIX, player.Name, "rolled:", table.concat(results, ", "))

		task.wait(busyTime)
	end

	prompt.Triggered:Connect(function(player: Player)
		if busy or machine.Parent == nil or not canUse(player, prompt) then
			return
		end
		busy = true -- set before any yield, so simultaneous triggers from other players are rejected
		prompt.Enabled = false

		task.spawn(function()
			local ok, err = pcall(runRoll, player)
			if not ok then
				warn(LOG_PREFIX, "Roll failed:", err)
			end
			if machine.Parent == nil then
				return
			end

			machine:SetAttribute("State", "Cooldown")
			machine:SetAttribute("CooldownEndsAt", workspace:GetServerTimeNow() + Config.CooldownTime)
			task.wait(Config.CooldownTime)
			if machine.Parent == nil then
				return
			end

			machine:SetAttribute("State", "Ready")
			prompt.Enabled = true
			busy = false
		end)
	end)
end

for _, machine in CollectionService:GetTagged(Config.MachineTag) do
	setupMachine(machine)
end
CollectionService:GetInstanceAddedSignal(Config.MachineTag):Connect(setupMachine)
