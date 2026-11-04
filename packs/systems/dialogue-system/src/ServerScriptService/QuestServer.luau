local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local CollectionService = game:GetService("CollectionService")

local Remotes = ReplicatedStorage:FindFirstChild("DialogueRemotes")
if not Remotes then
	Remotes = Instance.new("Folder")
	Remotes.Name = "DialogueRemotes"
	Remotes.Parent = ReplicatedStorage
end

local StartDialogue = Remotes:FindFirstChild("StartDialogue") or Instance.new("RemoteEvent")
StartDialogue.Name = "StartDialogue"
StartDialogue.Parent = Remotes

local EndDialogue = Remotes:FindFirstChild("EndDialogue") or Instance.new("RemoteEvent")
EndDialogue.Name = "EndDialogue"
EndDialogue.Parent = Remotes

local QuestRemotes = ReplicatedStorage:FindFirstChild("QuestRemotes")
if not QuestRemotes then
	QuestRemotes = Instance.new("Folder")
	QuestRemotes.Name = "QuestRemotes"
	QuestRemotes.Parent = ReplicatedStorage
end

local QuestAction = QuestRemotes:FindFirstChild("QuestAction") or Instance.new("RemoteFunction")
QuestAction.Name = "QuestAction"
QuestAction.Parent = QuestRemotes

local QuestUpdate = QuestRemotes:FindFirstChild("QuestUpdate") or Instance.new("RemoteEvent")
QuestUpdate.Name = "QuestUpdate"
QuestUpdate.Parent = QuestRemotes

local QuestService = require(ServerScriptService:WaitForChild("QuestService"))
local QuestConfig = require(ReplicatedStorage:WaitForChild("QuestConfig"))

local activeByPlayer = {}
local activeCountByPrompt = {}

Players.PlayerAdded:Connect(function(player)
	QuestService:InitPlayer(player)
end)

for _, player in ipairs(Players:GetPlayers()) do
	QuestService:InitPlayer(player)
end

QuestAction.OnServerInvoke = function(player, action, questId)
	if action == "Get" then
		return QuestService:GetSnapshot(player)
	end

	if action == "Start" then
		return QuestService:StartQuest(player, questId)
	end

	if action == "TurnIn" then
		return QuestService:TurnInQuest(player, questId)
	end

	return false, "Unknown action."
end

local function findInNpc(npcModel, name)
	if not npcModel then
		return nil
	end
	local inst = npcModel:FindFirstChild(name, true)
	if inst and inst:IsA("BasePart") then
		return inst
	end
	return nil
end

local function getDialogueId(prompt, npcModel)
	if prompt then
		local a = prompt:GetAttribute("DialogueId")
		if typeof(a) == "string" and a ~= "" then
			return a
		end
		local sv = prompt:FindFirstChild("DialogueId")
		if sv and sv:IsA("StringValue") and sv.Value ~= "" then
			return sv.Value
		end
	end
	if npcModel then
		local a = npcModel:GetAttribute("DialogueId")
		if typeof(a) == "string" and a ~= "" then
			return a
		end
		local sv = npcModel:FindFirstChild("DialogueId")
		if sv and sv:IsA("StringValue") and sv.Value ~= "" then
			return sv.Value
		end
	end
	return "Intro"
end

local function pivotCharacterTo(player, cf)
	local char = player.Character
	if not char then
		return
	end
	pcall(function()
		char:PivotTo(cf)
	end)
end

local function setPromptBusy(prompt, busy)
	if not prompt then
		return
	end
	local n = activeCountByPrompt[prompt] or 0
	if busy then
		n += 1
	else
		n = math.max(0, n - 1)
	end
	activeCountByPrompt[prompt] = n
	prompt.Enabled = (n == 0)
end

local function computeStartLabel(player, npcModel)
	if not (QuestService and QuestConfig and npcModel) then
		return nil
	end

	local giverKey = npcModel:GetAttribute("QuestGiver") or npcModel.Name
	local chain = QuestConfig.QuestChains[giverKey]
	if not chain or #chain == 0 then
		return nil
	end

	local pdata = QuestService:GetPlayerData(player)

	local hasActive = false
	local allTurnedIn = true

	for _, qid in ipairs(chain) do
		local st = pdata.Quests[qid]
		if st and not st.TurnedIn then
			hasActive = true
			allTurnedIn = false
			break
		end
		if not (st and st.TurnedIn) then
			allTurnedIn = false
		end
	end

	if hasActive then
		return npcModel:GetAttribute("QuestMenuLabel") or "menu"
	end

	if allTurnedIn then
		return npcModel:GetAttribute("QuestDoneLabel") or "done"
	end

	return nil
end

local function beginConversation(player, prompt)
	if activeByPlayer[player] then
		return
	end
	if not prompt.Enabled then
		return
	end

	local npcModel = prompt:FindFirstAncestorOfClass("Model")
	local dialogueId = getDialogueId(prompt, npcModel)

	local char = player.Character or player.CharacterAdded:Wait()
	local origPivot = char:GetPivot()

	setPromptBusy(prompt, true)

	local talkPoint = findInNpc(npcModel, "TalkPoint")
	if talkPoint then
		pivotCharacterTo(player, talkPoint.CFrame)
	end

	local camPart = findInNpc(npcModel, "DialogueCamera")
	local startLabel = computeStartLabel(player, npcModel)

	activeByPlayer[player] = {
		origPivot = origPivot,
		prompt = prompt,
	}

	StartDialogue:FireClient(player, dialogueId, {
		NPC = npcModel,
		Camera = camPart,
		StartLabel = startLabel,
	})

	task.spawn(function()
		task.wait(90)
		if activeByPlayer[player] then
			local state = activeByPlayer[player]
			activeByPlayer[player] = nil
			setPromptBusy(state.prompt, false)
			pivotCharacterTo(player, state.origPivot)
		end
	end)
end

EndDialogue.OnServerEvent:Connect(function(player)
	local state = activeByPlayer[player]
	if not state then
		return
	end
	activeByPlayer[player] = nil
	setPromptBusy(state.prompt, false)
	pivotCharacterTo(player, state.origPivot)
end)

Players.PlayerRemoving:Connect(function(player)
	local state = activeByPlayer[player]
	if state then
		activeByPlayer[player] = nil
		setPromptBusy(state.prompt, false)
	end
end)

local function hookPrompt(prompt)
	if prompt:GetAttribute("DialogueHooked") then
		return
	end
	prompt:SetAttribute("DialogueHooked", true)
	prompt.Triggered:Connect(function(player)
		beginConversation(player, prompt)
	end)
end

for _, d in ipairs(workspace:GetDescendants()) do
	if d:IsA("ProximityPrompt") and d.Name == "TalkPrompt" then
		hookPrompt(d)
	end
end

workspace.DescendantAdded:Connect(function(d)
	if d:IsA("ProximityPrompt") and d.Name == "TalkPrompt" then
		hookPrompt(d)
	end
end)

local function hookCollectible(part, itemName)
	if not part:IsA("BasePart") then
		return
	end

	local prompt = part:FindFirstChildOfClass("ProximityPrompt")
	if not prompt then
		prompt = Instance.new("ProximityPrompt")
		prompt.ActionText = "Collect"
		prompt.ObjectText = itemName
		prompt.HoldDuration = 0
		prompt.RequiresLineOfSight = false
		prompt.MaxActivationDistance = 12
		prompt.Parent = part
	end

	local respawnTime = part:GetAttribute("RespawnTime") or 20

	prompt.Triggered:Connect(function(player)
		if not prompt.Enabled then
			return
		end
		prompt.Enabled = false

		QuestService:AddItem(player, itemName, 1)

		part.Transparency = 1
		part.CanCollide = false

		task.delay(respawnTime, function()
			if part and part.Parent then
				part.Transparency = 0
				part.CanCollide = true
				prompt.Enabled = true
			end
		end)
	end)
end

local function hookAllTagged(itemName)
	for _, inst in ipairs(CollectionService:GetTagged(itemName)) do
		hookCollectible(inst, itemName)
	end
	CollectionService:GetInstanceAddedSignal(itemName):Connect(function(inst)
		hookCollectible(inst, itemName)
	end)
end

hookAllTagged("Fragment")
hookAllTagged("Crystal")

local function onCharacterAdded(char)
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not hum then
		return
	end

	hum.Died:Connect(function()
		local tag = hum:FindFirstChild("creator")
		if tag and tag.Value then
			local killer = tag.Value
			local victimPlayer = Players:GetPlayerFromCharacter(char)

			if victimPlayer then
				QuestService:OnKill(killer, "Player")
			else
				QuestService:OnKill(killer, char.Name)
			end
		end
	end)
end

workspace.DescendantAdded:Connect(function(desc)
	if desc:IsA("Model") and desc:FindFirstChildOfClass("Humanoid") then
		onCharacterAdded(desc)
	end
end)

for _, desc in ipairs(workspace:GetDescendants()) do
	if desc:IsA("Model") and desc:FindFirstChildOfClass("Humanoid") then
		onCharacterAdded(desc)
	end
end
