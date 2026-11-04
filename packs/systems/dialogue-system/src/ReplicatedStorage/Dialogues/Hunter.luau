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
	local target = obj.Target or "beast"
	local rewardCoins = (q.Reward and q.Reward.Coins) or 0
	local rewardExp = (q.Reward and q.Reward.EXP) or 0
	local action = "Hunt"
	return string.format("%s %d %s.\nReward: %d Coins, %d EXP, a sword.", action, req, plural(target, req), rewardCoins, rewardExp)
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

		local target = obj.Target or "monsters"
		local targetName = plural(target, missing):lower()

		return string.format("You still owe me %d %s. The hunt is not over.", missing, targetName)
	end
end

local function successTextFor()
	return "Good work. The sword is yours. Use it well."
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
		Speaker = "Hunter",
		Text = "You look like you can swing a blade.",
	},
	{
		Speaker = "Hunter",
		Text = "Care to thin out the monsters for me?",
		Choices = {
			{
				Text = "What do you need?",
				Next = "menu",
			},
			{
				Text = "Not interested",
				Next = "leave",
			},
		},
	},
}

local chain = QuestConfig.QuestChains.Hunter or {}
local menuChoices = {}

for _, questId in ipairs(chain) do
	local q = QuestConfig.Quests[questId]
	if q then
		table.insert(menuChoices, {
			Text = "Monster Hunt",
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
	Speaker = "Hunter",
	Text = "Speak.",
	Choices = menuChoices,
})

for _, questId in ipairs(chain) do
	local q = QuestConfig.Quests[questId]
	if q then
		table.insert(Lines, {
			Label = "q_" .. questId,
			Speaker = "Hunter",
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
			Speaker = "Hunter",
			Text = missingTextFor(q, questId),
			End = true,
		})

		table.insert(Lines, {
			Label = "ok_" .. questId,
			Speaker = "Hunter",
			Text = successTextFor(q, questId),
			End = true,
		})
	end
end

table.insert(Lines, {
	Label = "leave",
	Speaker = "Hunter",
	Text = "Then stay out of the way.",
	End = true,
})

return {
	Settings = Settings,
	Lines = Lines,
}
