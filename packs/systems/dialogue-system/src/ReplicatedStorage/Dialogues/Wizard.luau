local ReplicatedStorage = game:GetService("ReplicatedStorage")
local QuestConfig = require(ReplicatedStorage:WaitForChild("QuestConfig"))
local QuestAction = ReplicatedStorage:WaitForChild("QuestRemotes"):WaitForChild("QuestAction")

local function plural(word, n)
	if n == 1 then
		return word
	end
	if word:sub(-1):lower() == "s" then
		return word
	end
	return word .. "s"
end

local function offerText(q)
	local obj = q.Objective or {}
	local req = obj.Required or 1
	local target = obj.Item or obj.Target or "Thing"
	local rewardCoins = (q.Reward and q.Reward.Coins) or 0
	local rewardExp = (q.Reward and q.Reward.EXP) or 0
	local action = "Collect"
	if obj.Type == "Kill" then
		action = "Defeat"
	end
	return string.format("%s %d %s.\nReward: %d Coins, %d EXP.", action, req, plural(target, req), rewardCoins, rewardExp)
end

local function missingTextFor(q, questId)
	return function()
		local success, snapshot = pcall(function()
			return QuestAction:InvokeServer("Get")
		end)

		local current = 0
		if success and snapshot and snapshot.Quests and snapshot.Quests[questId] then
			current = snapshot.Quests[questId].Progress or 0
		end

		local obj = q.Objective or {}
		local req = obj.Required or 1
		local missing = math.max(0, req - current)

		local target = obj.Item or obj.Target or "items"
		local targetName = plural(target, missing):lower()

		return string.format("You’re still missing %d %s. I need them all.", missing, targetName)
	end
end

local function successTextFor(q, questId)
	if questId == "Wizard_Fragments" then
		return "Ah, these fragments vibrate with energy. Excellent work."
	end
	if questId == "Wizard_Crystals" then
		return "Crystals. They sing when I hold them. Well done."
	end
	return "Good. That will do."
end

local Settings = {
	TypeSpeed = 0.025,
	LetterboxSize = 0.12,
	BlurSize = 10,
	FadeTime = 0.2,
	DefaultFOV = 45,
	CameraTween = {
		Time = 0.85,
	},
	Breathing = {
		Speed = 0.9,
		PosAmp = Vector3.new(0.03, 0.06, 0.03),
		RotAmp = Vector3.new(0.25, 0.35, 0.12),
	},
	SpeakerStyles = {
		["*"] = {
			NameColor = Color3.fromRGB(255, 255, 255),
			TextColor = Color3.fromRGB(235, 235, 235),
		},
		You = {
			NameColor = Color3.fromRGB(120, 200, 255),
			TextColor = Color3.fromRGB(220, 245, 255),
		},
	},
	TypeSFX = {
		SoundId = "rbxassetid://615716445",
		Volume = 0.35,
		PitchMin = 0.95,
		PitchMax = 1.05,
		Every = 2,
		MinInterval = 0.02,
	},
	ChoiceSlide = {
		OffsetX = 90,
		Stagger = 0.06,
		Time = 0.18,
	},
	ChoiceHover = {
		StrokeColor = Color3.fromRGB(255, 255, 255),
		StrokeTransparency = 0.25,
		StrokeThickness = 2,
		HoverBgTransparency = 0.12,
		HoverXOffset = -8,
		HoverTime = 0.10,
	},
}

local Lines = {
	{
		Speaker = "Wizard",
		Text = "Ah… a traveler. The air around you is loud.",
	},
	{
		Speaker = "Wizard",
		Text = "Will you listen, or will you waste my time?",
		Choices = {
			{
				Text = "Listen",
				Next = "menu",
			},
			{
				Text = "Waste time",
				Next = "waste",
			},
		},
	},
}

local chain = QuestConfig.QuestChains.Wizard or {}
local menuChoices = {}

for _, questId in ipairs(chain) do
	local q = QuestConfig.Quests[questId]
	if q then
		local obj = q.Objective or {}
		local label = obj.Item or obj.Target or questId
		table.insert(menuChoices, {
			Text = label,
			Next = "q_" .. questId,
		})
	end
end

table.insert(menuChoices, {
	Text = "Leave",
	End = true,
})

table.insert(Lines, {
	Label = "menu",
	Speaker = "Wizard",
	Text = "Speak.",
	Choices = menuChoices,
})

for _, questId in ipairs(chain) do
	local q = QuestConfig.Quests[questId]
	if q then
		table.insert(Lines, {
			Label = "q_" .. questId,
			Speaker = "Wizard",
			Text = offerText(q),
			Choices = {
				{
					Text = "Accept",
					StartQuest = questId,
					End = true,
				},
				{
					Text = "Turn in",
					TurnInQuest = questId,
					SuccessNext = "ok_" .. questId,
					FailNext = "fail_" .. questId,
				},
				{
					Text = "Back",
					Next = "menu",
				},
			},
		})

		table.insert(Lines, {
			Label = "fail_" .. questId,
			Speaker = "Wizard",
			Text = missingTextFor(q, questId),
			End = true,
		})

		table.insert(Lines, {
			Label = "ok_" .. questId,
			Speaker = "Wizard",
			Text = successTextFor(q, questId),
			End = true,
		})
	end
end

table.insert(Lines, {
	Label = "done",
	Speaker = "Wizard",
	Text = "You’ve done enough. Begone.",
	End = true,
})

table.insert(Lines, {
	Label = "waste",
	Speaker = "Wizard",
	Text = "Then I will waste yours right back. Begone.",
	End = true,
})

return {
	Settings = Settings,
	Lines = Lines,
}
