--[[
	EGG RANDOMIZER KIT
	Made by MarvinSmlchannel. Free to use in your own games.

	A lever machine that shuffles eggs and reveals them, with buying, an inventory, holding
	eggs, selling, money that saves, an admin panel and a Robux cash shop.


	INSTALL (pick one)

	  A) Quickest: leave this EggRandomizerKit folder in Workspace and press Play.
	     It sets itself up every time the game starts.

	  B) Permanent (recommended): open View > Command Bar, paste this line and press Enter:

	        require(workspace.EggRandomizerKit.Install)()

	     Everything moves to the right place and this folder disappears. Ctrl+Z undoes it.
	     (If you put the folder somewhere other than Workspace, change "workspace" to that place.)


	WHERE EVERYTHING ENDS UP

	  ReplicatedStorage > EggRandomizer           Config (all settings), shared modules, remotes
	  ServerScriptService > EggRandomizer         server scripts, saving, shop, cash shop
	  ServerStorage > EggModels                   the egg models the machine rolls
	  StarterGui > EggShopGui                     money, inventory, admin panel, cash shop
	  StarterPlayer > StarterPlayerScripts        EggRandomizerClient, CheckUIPrompts, HeldEggClient
	  Workspace > EggRandomizerMachine            move it anywhere; copy it for more machines


	GAME SETTINGS (Home > Game Settings > Security; publish the game first)

	  - Enable Studio Access to API Services   lets money and eggs save while testing in Studio
	  - Allow Mesh / Image APIs                the faint stud pattern on the menus (optional)


	ADMIN PANEL

	  The game's owner gets it automatically (group games: rank 255 and up).
	  To add more people, put their user IDs in Config > Admin > UserIds.


	ROBUX CASH PACKS (the green + next to the money)

	  Creator Hub > your game > Monetization > Developer Products, and create 4 products
	  named exactly:  Pocket Change,  Cash Stack,  Gold Pile,  Mega Vault
	  Pick any Robux prices. The game finds them by name on its own (or paste their IDs
	  into Config > CashShop). Until then the packs say they aren't for sale yet.


	ADDING EGGS

	  1. Put the egg model in ServerStorage > EggModels.
	  2. Add a line for it in Config > Eggs. TemplateName must match the model's name exactly,
	     and every line needs a comma at the end.
	  Weight = how common it is (bigger = more common). Price = cost to buy it.


	UI style based on Check-UI by TemporaryLooker22 (MIT License).
]]
