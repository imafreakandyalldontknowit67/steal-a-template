local QuestConfig = {
	Quests = {
		Fragments = {
			Giver = "Wizard",
			Objective = {
				Type = "Collect",
				Item = "Fragment",
				Required = 5,
			},
			Reward = {
				Coins = 10,
				EXP = 50,
			},
			Dialogues = {
				Offer = "FragmentsOffer",
				InProgress = "FragmentsInProgress",
				TurnIn = "FragmentsTurnIn",
				Done = "NoMoreQuests",
			},
			Repeatable = false,
		},

		Crystals = {
			Giver = "Wizard",
			Objective = {
				Type = "Collect",
				Item = "Crystal",
				Required = 3,
			},
			Reward = {
				Coins = 20,
				EXP = 80,
			},
			Dialogues = {
				Offer = "CrystalsOffer",
				InProgress = "CrystalsInProgress",
				TurnIn = "CrystalsTurnIn",
				Done = "NoMoreQuests",
			},
			Repeatable = false,
		},

		Monsters = {
			Giver = "Hunter",
			Objective = {
				Type = "Kill",
				Target = "Slime",
				Required = 5,
			},
			Reward = {
				Coins = 50,
				EXP = 200,
				Items = { Sword = 1 },
			},
			Dialogues = {
				Offer = "MonstersOffer",
				InProgress = "MonstersInProgress",
				TurnIn = "MonstersTurnIn",
				Done = "NoMoreQuests",
			},
			Repeatable = true,
		},

		Players = {
			Giver = "Duelist",
			Objective = {
				Type = "Kill",
				Target = "Player",
				Required = 3,
			},
			Reward = {
				Coins = 100,
				EXP = 300,
			},
			Dialogues = {
				Offer = "PlayersOffer",
				InProgress = "PlayersInProgress",
				TurnIn = "PlayersTurnIn",
				Done = "NoMoreQuests",
			},
			Repeatable = true,
		},
	},

	QuestChains = {
		Wizard = {
			"Fragments",
			"Crystals",
		},
		Hunter = {
			"Monsters",
		},
		Duelist = {
			"Players",
		},
	},
}

return QuestConfig
