--[[
	Egg Randomizer — central configuration.

	Every tunable value for the machine lives here. Both the server (selection, timing,
	cooldown) and the clients (animation, effects) read this module, so a change here
	applies everywhere.

	ADDING A NEW EGG LATER
	  1. Put the egg Model inside ServerStorage > EggModels.
	  2. Add a line to Config.Eggs below with the model's exact name as TemplateName.
	The original models in ServerStorage are never modified; the machine only uses clones.
]]

local Config = {}

-- Eggs the machine can roll.
--   TemplateName : exact name of the Model in ServerStorage > EggModels
--   DisplayName  : text shown above the egg when it is revealed
--   Weight       : relative chance. All 1 = equal chance. (e.g. Weight 3 is 3x as likely as Weight 1)
--   AccentColor  : colour used for the reveal ring, light and label
--   Rarity       : optional label under the name (e.g. "Rare"). If omitted, the egg's % chance is shown.
--   Animation    : optional built-in animation while the egg is on display (see EggAnimations).
--   Price        : how much money it costs to buy this egg after it's rolled
--                  "Angel" = flapping wings, bobbing halo, spinning rune rings, circling orbs + golden glow.
Config.Eggs = {
	{ TemplateName = "BasicEgg", DisplayName = "Basic Egg", Weight = 10, Rarity = "Common", Price = 50, AccentColor = Color3.fromRGB(255, 236, 190) },
	{ TemplateName = "SpaceEgg", DisplayName = "Space Egg", Weight = 4, Rarity = "Epic", Price = 600, AccentColor = Color3.fromRGB(214, 100, 255) },
	{ TemplateName = "OceanEgg", DisplayName = "Ocean Egg", Weight = 6, Rarity = "Rare", Price = 250, AccentColor = Color3.fromRGB(40, 176, 255) },
	{ TemplateName = "SpikyEgg", DisplayName = "Spiky Egg", Weight = 8, Rarity = "Uncommon", Price = 120, AccentColor = Color3.fromRGB(110, 225, 90) },
	{ TemplateName = "AngelEgg", DisplayName = "Angel Egg", Weight = 2, Rarity = "Legendary", Price = 2000, AccentColor = Color3.fromRGB(255, 225, 140), Animation = "Angel" },
	{ TemplateName = "BeeEgg", DisplayName = "Bee Egg", Weight = 6, Rarity = "Rare", Price = 250, AccentColor = Color3.fromRGB(255, 205, 40) },
	{ TemplateName = "CandyEgg", DisplayName = "Candy Egg", Weight = 4, Rarity = "Epic", Price = 600, AccentColor = Color3.fromRGB(255, 130, 200) },
	{ TemplateName = "DevilEgg", DisplayName = "Devil Egg", Weight = 6, Rarity = "Rare", Price = 250, AccentColor = Color3.fromRGB(255, 60, 60) },
	{ TemplateName = "IceEgg", DisplayName = "Ice Egg", Weight = 6, Rarity = "Rare", Price = 250, AccentColor = Color3.fromRGB(150, 220, 255) },
	{ TemplateName = "CrystalEgg", DisplayName = "Crystal Egg", Weight = 4, Rarity = "Epic", Price = 600, AccentColor = Color3.fromRGB(190, 140, 255) },
	{ TemplateName = "NatureEgg", DisplayName = "Nature Egg", Weight = 6, Rarity = "Rare", Price = 250, AccentColor = Color3.fromRGB(120, 220, 90) },
	{ TemplateName = "SamuraiEgg", DisplayName = "Samurai Egg", Weight = 2, Rarity = "Legendary", Price = 2000, AccentColor = Color3.fromRGB(255, 80, 70) },
	{ TemplateName = "ToxicEgg", DisplayName = "Toxic Egg", Weight = 0.5, Rarity = "Secret", Price = 10000, AccentColor = Color3.fromRGB(150, 255, 40) },
	{ TemplateName = "FireEgg", DisplayName = "Fire Egg", Weight = 8, Rarity = "Uncommon", Price = 120, AccentColor = Color3.fromRGB(255, 140, 30) },
}

-- Where the original egg models live (inside ServerStorage).
Config.TemplateFolderName = "EggModels"

-- CollectionService tag on the machine model. Every tagged machine works on its own,
-- so you can copy the machine and place several in the world.
Config.MachineTag = "EggRandomizerMachine"

-- Lever animation
Config.Lever = {
	PullAngle = 70, -- degrees the arm swings down/forward from its rest pose
	PullTime = 0.18, -- seconds to swing down
	HoldTime = 0.06, -- seconds it stays at the bottom
	ReturnTime = 0.55, -- seconds to spring back up
}

-- Shuffle animation
Config.Shuffle = {
	StartDelay = 0.18, -- seconds after the pull before the eggs start cycling (lever hits bottom)
	Duration = 3.0, -- seconds the FIRST slot shuffles before it stops
	SlotStopStagger = 0.5, -- each further slot stops this many seconds after the previous one
	FastestSwapInterval = 0.06, -- seconds between egg swaps at full speed
	SlowestSwapInterval = 0.42, -- seconds between swaps right before the stop
	SlowdownCurve = 2.4, -- higher = stays fast longer, then brakes harder at the end
	RotationSpeed = 900, -- starting spin speed in degrees/second (eases smoothly to 0 at the stop)
	BobHeight = 0.18, -- studs the egg floats up and down while shuffling
	SwapPopScale = 0.82, -- each new egg pops in from this size (1 = no pop)
	SwapPopTime = 0.08, -- seconds for that pop
}

-- Reveal (end of the shuffle)
Config.Reveal = {
	PopScale = 1.3, -- egg grows to this size and settles back to 1 when revealed
	PopTime = 0.45,
	HopHeight = 0.6, -- studs the egg hops up during the pop
	EffectsTime = 0.9, -- length of the light beam / shock ring / flash
	SettleTime = 0.6, -- seconds after the last reveal before the cooldown begins
	ShowNameLabel = true,
}

-- Seconds after the animation finishes before the lever can be pulled again.
Config.CooldownTime = 3

-- Display positions
Config.Display = {
	EggHeight = 3.0, -- every egg is scaled (on the clone only) to be this many studs tall
	Offset = Vector3.new(0, 0.35, 0), -- egg bottom position relative to each slot's EggAnchor
	SlotOffsets = {
		-- Optional extra offset per slot, e.g. [2] = Vector3.new(0, 0.2, 0),
	},
	FacingYaw = 180, -- degrees; turns every displayed egg so its front faces the player
	LabelHeight = 1.4, -- studs between the top of the egg and its name label

	-- After the reveal, eggs keep turning on their pedestal until the next roll.
	IdleSpinSpeed = 60, -- degrees per second (0 = stay still)
	IdleRampTime = 0.8, -- seconds to ease up to that speed after the reveal pop
	IdleBobHeight = 0.15, -- studs the egg gently floats up and down while idling (0 = off)
	IdleBobSpeed = 0.5, -- floats per second
	AnimateDistance = 150, -- idle spin + egg animations pause when your camera is farther than this (performance)
}

-- ProximityPrompt on the lever
Config.Prompt = {
	ActionText = "Roll Eggs",
	ObjectText = "Egg Roller",
	HoldDuration = 0,
	MaxActivationDistance = 10,
}

-- Server-side check: the player must be at least this close to the lever.
Config.MaxUseDistance = 16

-- Sounds (Id = "" turns a sound off). Volume 0..1. All sounds play from the machine in 3D.
Config.Sounds = {
	-- lever being pulled
	Lever = { Id = "rbxassetid://9116260154", Volume = 0.5 },

	-- SPINNING SOUND (option 1, default): the MM2 role-choosing "ding", played every time the
	-- egg swaps to the next one — fast at the start, slowing ding... by... ding until the egg lands,
	-- exactly like MM2's role picker.
	--   Pitch          : base pitch (1 = normal, higher = sharper)
	--   PitchVariation : small random pitch change per ding (0 = off)
	--   MinGap         : shortest time between two dings for the whole machine (stops it turning into a buzz)
	Tick = { Id = "rbxassetid://89539292769549", Volume = 0.6, Pitch = 1, PitchVariation = 0, MinGap = 0.11 },

	-- SPINNING SOUND (option 2): one recording played once when the shuffle starts, and faded
	-- out when the last egg lands. To use the full 2.2-second MM2 "choosing roles" recording instead
	-- of the per-swap ding, set this Id to "rbxassetid://140041378781574" and set Tick.Id to "".
	-- Tip: that recording is 2.2 s long, so also set Config.Shuffle.Duration to about 2.2 so it
	-- finishes right as the eggs land.
	SpinClip = { Id = "", Volume = 0.7 },

	-- played together the moment the egg appears in colour
	RevealPop = { Id = "rbxassetid://106984966606682", Volume = 1 },
	Reveal = { Id = "rbxassetid://4612374393", Volume = 0.8 },
}

-- Money
Config.Economy = {
	CurrencyName = "Money", -- name shown on the player list
	CurrencySymbol = "$",
	StartingMoney = 250, -- money a brand-new player starts with
	IncomeAmount = 25, -- every player earns this much every IncomeInterval seconds (0 = off)
	IncomeInterval = 60,
	BuyDistance = 16, -- how close you must be to a pedestal to buy its egg
	SellRate = 0.3, -- selling an egg pays this much of its Price (0.3 = 30%, always less than you paid). An egg can also have its own SellPrice.
}

-- Saving (DataStores). To test saving in Studio turn on:
-- Game Settings > Security > Enable Studio Access to API Services
Config.Data = {
	StoreName = "EggRandomizerPlayerData_v1", -- change this name to wipe everyone's saves
	AutosaveInterval = 120, -- seconds between automatic saves (also saves when a player leaves)
}

-- Admin panel access. The game's owner is always an admin.
Config.Admin = {
	UserIds = {}, -- add Roblox user IDs here to give other people the admin panel, e.g. { 12345678, 87654321 }
	GroupMinRank = 255, -- only if the game is owned by a group: this rank and above are admins
}

-- Robux cash packs (the green + next to the money opens this shop).
-- 1) Create a Developer Product for each pack: Creator Hub > your game > Monetization >
--    Developer Products. The Robux price you set there is what the shop shows.
-- 2) Put its ID in ProductId below - or leave 0 and name the product exactly like the pack
--    (the game links them by name). Packs with no product show "Soon".
Config.CashShop = {
	Packs = {
		{ Name = "Pocket Change", Cash = 1000, ProductId = 0, Icon = "rbxassetid://88694661500877" }, -- 25 Robux
		{ Name = "Cash Stack", Cash = 5000, ProductId = 0, Icon = "rbxassetid://98216083115274" }, -- 99 Robux
		{ Name = "Gold Pile", Cash = 15000, ProductId = 0, Icon = "rbxassetid://81781760189273" }, -- 249 Robux
		{ Name = "Mega Vault", Cash = 50000, ProductId = 0, Icon = "rbxassetid://89267825858001", Tag = "BEST VALUE" }, -- 699 Robux
	},
}

-- Menu sounds (swap any ID for one you like; Volume 0 turns a sound off).
-- Kept to two on purpose: a soft click on buttons and a cash sound when you buy something.
Config.UISounds = {
	Click = { Id = "rbxassetid://126965103485114", Volume = 0.25 },
	Purchase = { Id = "rbxassetid://1319346243", Volume = 0.3 },
	Hover = { Id = "rbxassetid://88442833509532", Volume = 0 },
	Open = { Id = "rbxassetid://137273815815490", Volume = 0 },
	Close = { Id = "rbxassetid://137273815815490", Volume = 0 },
	Error = { Id = "rbxassetid://16903690359", Volume = 0 },
	Equip = { Id = "rbxassetid://9119717523", Volume = 0 },
}

-- Inventory: every egg a player owns is its own item (no stacking).
Config.Inventory = {
	MaxEggs = 200, -- buying (and admin giving) stops at this many eggs; keeps saves and the inventory fast
}

-- The equipped egg is carried in front of the player with both arms (everyone can see it).
-- Equip / unequip by clicking an egg in the inventory.
Config.Held = {
	EggHeight = 1.7, -- studs tall
	ArmRaise = 50, -- degrees the upper arms swing forward
	ElbowBend = 38, -- degrees the forearms bend up (R15 avatars)
	ArmInward = 15, -- starting inward angle; it then adjusts so the hands touch the egg on any avatar
	HoldLift = 0.15, -- how far above the hands the egg's centre sits (1 = half the egg's height)
	HoldForward = 0.25, -- studs in front of the hands
	BlendTime = 0.2, -- seconds to move the arms into / out of the holding pose
	ViewDistance = 250, -- other players' eggs farther away than this are not drawn
}

-- Blackout look while shuffling
Config.Blackout = {
	Color = Color3.new(0, 0, 0),
	Material = Enum.Material.SmoothPlastic,
}

return Config
