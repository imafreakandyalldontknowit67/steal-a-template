local ReplicatedStorage = game:GetService("ReplicatedStorage")

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
		Label = "intro",
		Speaker = "Guide",
		Text = "This is the Temp dialogue. It is used to test the dialogue and quest system.",
		Next = "menu",
	},

	{
		Label = "menu",
		Speaker = "Guide",
		Text = "What do you want to know about?",
		Choices = {
			{
				Text = "Dialogue system",
				Next = "dialogue_info",
			},
			{
				Text = "Quest system",
				Next = "quest_info",
			},
			{
				Text = "NPC types",
				Next = "npc_info",
			},
			{
				Text = "HUD and progress",
				Next = "hud_info",
			},
			{
				Text = "Nothing. Close this.",
				End = true,
			},
		},
	},

	{
		Label = "dialogue_info",
		Speaker = "Guide",
		Text = "The dialogue system can show text with a typewriter effect, play sounds, and present choices. Each choice can move to another line, start or turn in a quest, or end the dialogue.",
		Next = "dialogue_more",
	},

	{
		Label = "dialogue_more",
		Speaker = "Guide",
		Text = "While dialogue is active, the camera is controlled, the screen is letterboxed, blur is applied, and player movement and other UI are disabled so the focus stays on the conversation.",
		Choices = {
			{
				Text = "Back to menu",
				Next = "menu",
			},
			{
				Text = "Close",
				End = true,
			},
		},
	},

	{
		Label = "quest_info",
		Speaker = "Guide",
		Text = "The quest system tracks different objectives. Right now it supports collecting items and defeating targets. Quests can give coins, experience, and items such as weapons.",
		Next = "quest_more",
	},

	{
		Label = "quest_more",
		Speaker = "Guide",
		Text = "When you accept a quest from an NPC, it is stored for your player. Progress is updated automatically when you collect things or defeat the correct targets.",
		Choices = {
			{
				Text = "Back to menu",
				Next = "menu",
			},
			{
				Text = "Close",
				End = true,
			},
		},
	},

	{
		Label = "npc_info",
		Speaker = "Guide",
		Text = "Different NPCs give different kinds of quests. The Wizard gives collection quests like Fragments and Crystals. The Hunter gives monster kill quests that can reward weapons. The Duelist gives player-versus-player kill quests.",
		Next = "npc_more",
	},

	{
		Label = "npc_more",
		Speaker = "Guide",
		Text = "Each NPC is linked to a Dialogue module by a DialogueId, and linked to quests by a QuestGiver name. This lets one dialogue file define the menu and options for that NPC.",
		Choices = {
			{
				Text = "Back to menu",
				Next = "menu",
			},
			{
				Text = "Close",
				End = true,
			},
		},
	},

	{
		Label = "hud_info",
		Speaker = "Guide",
		Text = "The quest HUD on the left shows all active quests. Each quest line shows the target and your progress, like: Fragments 2/5 or Slime 3/5.",
		Next = "hud_more",
	},

	{
		Label = "hud_more",
		Speaker = "Guide",
		Text = "When a quest is completed, its text is crossed out with a line that grows from left to right. New quests slide in, and finished quests slide out when you turn them in.",
		Choices = {
			{
				Text = "Back to menu",
				Next = "menu",
			},
			{
				Text = "Close",
				End = true,
			},
		},
	},
}

return {
	Settings = Settings,
	Lines = Lines,
}
