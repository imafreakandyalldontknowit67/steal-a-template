--[[
	CashShopServer

	Pays out Robux cash packs (Config.CashShop). Roblox calls ProcessReceipt for every
	Developer Product purchase; we add the cash, remember the receipt so it can never pay
	twice, save, and only then tell Roblox the purchase is done.

	Linking: a pack uses its ProductId from Config if set, otherwise the Developer Product
	with the same name ("Pocket Change", "Cash Stack", ...). Checked again every minute, so
	products made while the game is running start working on their own.

	NOTE: a game can only have ONE ProcessReceipt. If you add other Developer Products later,
	add them here instead of writing a second ProcessReceipt somewhere else.
]]

local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("EggRandomizer")
local Config = require(Shared:WaitForChild("Config"))
local Remotes = Shared:WaitForChild("Remotes")
local PlayerData = require(script.Parent:WaitForChild("PlayerData"))

local LOG = "[CashShop]"

local packs = (Config.CashShop and Config.CashShop.Packs) or {}
local PACKS = {} -- [productId] = pack

local function simplify(name: any): string
	return string.lower((tostring(name):gsub("[%s%p]", "")))
end

-- Works out each pack's product ID and shares them with clients ("id1,id2,..." on Shared).
local function link()
	local ids = {}
	for index, pack in packs do
		ids[index] = math.max(0, math.floor(tonumber(pack.ProductId) or 0))
	end
	local ok, err = pcall(function()
		local pages = MarketplaceService:GetDeveloperProductsAsync()
		while true do
			for _, product in pages:GetCurrentPage() do
				local productId = tonumber(product.ProductId) or tonumber(product.DeveloperProductId)
				if productId then
					for index, pack in packs do
						if ids[index] == 0 and simplify(product.Name) == simplify(pack.Name) then
							ids[index] = productId
						end
					end
				end
			end
			if pages.IsFinished then
				break
			end
			pages:AdvanceToNextPageAsync()
		end
	end)
	if not ok then
		warn(LOG, "Couldn't read this game's Developer Products:", err)
	end
	table.clear(PACKS)
	local shared = table.create(#packs)
	for index = 1, #packs do
		local id = ids[index] or 0
		shared[index] = tostring(id)
		if id > 0 then
			PACKS[id] = packs[index]
		end
	end
	Shared:SetAttribute("CashPackProductIds", table.concat(shared, ","))
end

link()
task.spawn(function()
	while true do
		task.wait(60)
		link()
	end
end)

local function formatMoney(amount: number): string
	local text = tostring(math.floor(math.abs(amount)))
	return Config.Economy.CurrencySymbol .. (text:reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", ""))
end

MarketplaceService.ProcessReceipt = function(receipt)
	local pack = PACKS[receipt.ProductId]
	if not pack then
		link() -- a product made after the server started
		pack = PACKS[receipt.ProductId]
	end
	if not pack then
		warn(LOG, "Unknown Developer Product", receipt.ProductId, "- add it to Config.CashShop.Packs.")
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
	local player = Players:GetPlayerByUserId(receipt.PlayerId)
	if not player or not PlayerData.isLoaded(player) then
		return Enum.ProductPurchaseDecision.NotProcessedYet -- Roblox retries next time they join
	end
	local purchaseId = tostring(receipt.PurchaseId)
	if PlayerData.hasReceipt(player, purchaseId) then
		return Enum.ProductPurchaseDecision.PurchaseGranted -- already paid out
	end

	local cash = math.max(0, math.floor(tonumber(pack.Cash) or 0))
	PlayerData.addMoney(player, cash)
	PlayerData.addReceipt(player, purchaseId)
	if PlayerData.isSaving(player) and not PlayerData.saveNow(player) then
		-- the cash is in their session already; the receipt makes the retry a no-op
		warn(LOG, "Couldn't save after a purchase for", player.Name, "- Roblox will retry.")
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	print(LOG, player.Name, "bought", pack.Name, "for", receipt.CurrencySpent, "Robux:", formatMoney(cash))
	Remotes.Notify:FireClient(player, "+" .. formatMoney(cash) .. " Cash!", "cash")
	return Enum.ProductPurchaseDecision.PurchaseGranted
end
