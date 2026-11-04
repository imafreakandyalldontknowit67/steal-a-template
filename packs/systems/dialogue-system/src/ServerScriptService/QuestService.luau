local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local QuestConfig = require(ReplicatedStorage:WaitForChild("QuestConfig"))
local QuestUpdate = ReplicatedStorage:WaitForChild("QuestRemotes"):WaitForChild("QuestUpdate")

local QuestItemsFolder = ServerStorage:FindFirstChild("QuestItems")

local QuestService = {}
QuestService._data = {}

local function ensureLeaderstats(player)
	local ls = player:FindFirstChild("leaderstats")
	if not ls then
		ls = Instance.new("Folder")
		ls.Name = "leaderstats"
		ls.Parent = player
	end

	local coins = ls:FindFirstChild("Coins")
	if not coins then
		coins = Instance.new("IntValue")
		coins.Name = "Coins"
		coins.Value = 0
		coins.Parent = ls
	end

	local exp = ls:FindFirstChild("EXP")
	if not exp then
		exp = Instance.new("IntValue")
		exp.Name = "EXP"
		exp.Value = 0
		exp.Parent = ls
	end

	return coins, exp
end

function QuestService:GetPlayerData(player)
	self._data[player] = self._data[player] or {
		Quests = {},
		Items = {},
		Kills = {},
	}
	return self._data[player]
end

function QuestService:GetSnapshot(player)
	local pdata = self:GetPlayerData(player)
	local coins, exp = ensureLeaderstats(player)
	return {
		Coins = coins.Value,
		EXP = exp.Value,
		Quests = pdata.Quests,
		Items = pdata.Items,
		Kills = pdata.Kills,
	}
end

function QuestService:PushUpdate(player)
	QuestUpdate:FireClient(player, self:GetSnapshot(player))
end

local function syncQuestProgress(pdata, questId)
	local q = QuestConfig.Quests[questId]
	local st = pdata.Quests[questId]
	if not q or not st or st.TurnedIn then
		return
	end

	local obj = q.Objective
	if not obj then
		return
	end

	local have = 0
	if obj.Type == "Collect" then
		have = pdata.Items[obj.Item] or 0
	elseif obj.Type == "Kill" then
		have = pdata.Kills[obj.Target] or 0
	end

	local req = obj.Required or 1
	st.Progress = math.clamp(have, 0, req)
	st.Completed = (have >= req)
end

function QuestService:InitPlayer(player)
	self:GetPlayerData(player)
	ensureLeaderstats(player)
	self:PushUpdate(player)
end

function QuestService:StartQuest(player, questId)
	local pdata = self:GetPlayerData(player)
	local q = QuestConfig.Quests[questId]
	if not q then
		self:PushUpdate(player)
		return false, "Invalid quest."
	end

	local existing = pdata.Quests[questId]
	if existing and not existing.TurnedIn then
		self:PushUpdate(player)
		return false, "Quest already started."
	end

	pdata.Quests[questId] = {
		Progress = 0,
		Completed = false,
		TurnedIn = false,
	}

	syncQuestProgress(pdata, questId)
	self:PushUpdate(player)
	return true, "Quest started."
end

function QuestService:AddItem(player, itemName, amount)
	amount = amount or 1
	local pdata = self:GetPlayerData(player)
	pdata.Items[itemName] = (pdata.Items[itemName] or 0) + amount

	for questId, st in pairs(pdata.Quests) do
		local q = QuestConfig.Quests[questId]
		if q and not st.TurnedIn and q.Objective.Type == "Collect" and q.Objective.Item == itemName then
			syncQuestProgress(pdata, questId)
		end
	end

	self:PushUpdate(player)
end

function QuestService:OnKill(player, targetName)
	local pdata = self:GetPlayerData(player)
	pdata.Kills[targetName] = (pdata.Kills[targetName] or 0) + 1

	for questId, st in pairs(pdata.Quests) do
		local q = QuestConfig.Quests[questId]
		if q and not st.TurnedIn and q.Objective.Type == "Kill" and q.Objective.Target == targetName then
			syncQuestProgress(pdata, questId)
		end
	end

	self:PushUpdate(player)
end

function QuestService:TurnInQuest(player, questId)
	local pdata = self:GetPlayerData(player)
	local q = QuestConfig.Quests[questId]
	if not q then
		self:PushUpdate(player)
		return false, "Invalid quest."
	end

	local st = pdata.Quests[questId]
	if not st or st.TurnedIn then
		self:PushUpdate(player)
		return false, "Cannot turn in."
	end

	syncQuestProgress(pdata, questId)
	if not st.Completed then
		self:PushUpdate(player)
		return false, "Not completed yet."
	end

	local obj = q.Objective
	if obj.Type == "Collect" then
		pdata.Items[obj.Item] = math.max(0, (pdata.Items[obj.Item] or 0) - obj.Required)
	end

	local coins, exp = ensureLeaderstats(player)
	coins.Value += (q.Reward and q.Reward.Coins) or 0
	exp.Value += (q.Reward and q.Reward.EXP) or 0

	if q.Reward and q.Reward.Items then
		for itemName, amt in pairs(q.Reward.Items) do
			if QuestItemsFolder then
				local toolTemplate = QuestItemsFolder:FindFirstChild(itemName)
				if toolTemplate then
					for i = 1, amt do
						local clone = toolTemplate:Clone()
						clone.Parent = player.Backpack
						local gearClone = toolTemplate:Clone()
						gearClone.Parent = player.StarterGear
					end
				else
					pdata.Items[itemName] = (pdata.Items[itemName] or 0) + amt
				end
			else
				pdata.Items[itemName] = (pdata.Items[itemName] or 0) + amt
			end
		end
	end

	st.TurnedIn = true
	self:PushUpdate(player)
	return true, "Quest Complete!"
end

Players.PlayerRemoving:Connect(function(player)
	QuestService._data[player] = nil
end)

return QuestService
