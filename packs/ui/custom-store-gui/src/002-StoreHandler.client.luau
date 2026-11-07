local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local EpicPromptSound = ReplicatedStorage:WaitForChild("Sounds"):WaitForChild("EpicPromptSound")

local BrainrotsModule = require(ReplicatedStorage:WaitForChild("BrainrotsModule"))
local RaritiesModule = require(ReplicatedStorage:WaitForChild("RaritiesModule"))

local Store = script.Parent
local ScrollingFrame = Store:WaitForChild("ScrollingFrame")

-- Automatic price fetching helper
local function SetButtonPrice(button, id, isGamepass)
	task.spawn(function()
		local success, info = pcall(function()
			if isGamepass then
				return MarketplaceService:GetProductInfo(id, Enum.InfoType.GamePass)
			else
				return MarketplaceService:GetProductInfo(id, Enum.InfoType.Product)
			end
		end)
		if success and info and info.PriceInRobux then
			-- Most buttons have a text label or use the button text itself
			if button:IsA("TextButton") then
				button.Text = tostring(info.PriceInRobux) .. " R$"
			else
				local title = button:FindFirstChild("Title") or button:FindFirstChildWhichIsA("TextLabel")
				if title then
					title.Text = tostring(info.PriceInRobux) .. " R$"
				end
			end
		end
	end)
end

-------------------------------
-- Replace Lucky Block rewards in packs with brainrots
-------------------------------
local StarterPackReward = ScrollingFrame:WaitForChild("StarterPack"):WaitForChild("Main"):WaitForChild("Items"):WaitForChild("Reward")
local ProPackReward = ScrollingFrame:WaitForChild("ProPack"):WaitForChild("Main"):WaitForChild("Items"):WaitForChild("Reward")

local starterPackFrame = ScrollingFrame:WaitForChild("StarterPack")
local proPackFrame = ScrollingFrame:WaitForChild("ProPack")
local luckyBlockFrame = ScrollingFrame:WaitForChild("LuckyBlock")
local starterPackMain = starterPackFrame:WaitForChild("Main")
local proPackMain = proPackFrame:WaitForChild("Main")
local luckyBlockMain = luckyBlockFrame:WaitForChild("Main")

-- Helper: apply an animated gradient to a rarity Amount label
local animatedGradients = {}

local function ApplyRarityGradient(label, rarityType)
	-- Remove any existing UIGradient
	local existing = label:FindFirstChildWhichIsA("UIGradient")
	if existing then existing:Destroy() end

	local gradient = Instance.new("UIGradient")
	if rarityType == "Epic" then
		label.TextColor3 = Color3.new(1, 1, 1)
		gradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(129, 79, 255)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(70, 30, 160)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(129, 79, 255)),
		})
	elseif rarityType == "Legendary" then
		label.TextColor3 = Color3.new(1, 1, 1)
		gradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 50, 50)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(140, 15, 15)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 50, 50)),
		})
	elseif rarityType == "Mythic" then
		label.TextColor3 = Color3.new(1, 1, 1)
		gradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(180, 180, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255)),
		})
	elseif rarityType == "Secret" then
		label.TextColor3 = Color3.new(1, 1, 1)
		gradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(30, 30, 30)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255)),
		})
	elseif rarityType == "God" then
		label.TextColor3 = Color3.new(1, 1, 1)
		gradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 215, 0)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 215, 0)),
		})
	end
	gradient.Parent = label
	table.insert(animatedGradients, gradient)
end

-- Animate all rarity gradients with a smooth offset shift
task.spawn(function()
	while true do
		local t = tick() * 0.4 -- speed of the animation
		local offset = (math.sin(t) + 1) / 2 -- oscillates 0 to 1
		for _, grad in ipairs(animatedGradients) do
			if grad and grad.Parent then
				grad.Offset = Vector2.new(offset - 0.5, 0)
			end
		end
		task.wait()
	end
end)

-- StarterPack reward: Legendary brainrot (Six Seven)
local legendaryData = BrainrotsModule["Six Seven"]
if legendaryData then
	local starterIcon = StarterPackReward:FindFirstChild("Icon")
	local starterTitle = StarterPackReward:FindFirstChild("Title")
	if starterIcon then
		starterIcon.Image = legendaryData.Image
	end
	if starterTitle then
		starterTitle.Text = "Six Seven"
	end
	local starterAmount = StarterPackReward:FindFirstChild("Amount")
	if starterAmount then
		starterAmount.Text = "Legendary"
		starterAmount.Position = UDim2.new(0.5, 0, 0.807, 0)
		ApplyRarityGradient(starterAmount, "Legendary")
	end

end

-- StarterPack: Replace "67 Brainrot" reward with Chef Crabracadabra (2D image, same style as Six Seven)
local starterItems = starterPackMain:WaitForChild("Items")
local chefData = BrainrotsModule["Chef Crabracadabra"]
task.spawn(function()
	-- Wait for the extra reward frames to be populated at runtime
	local brainrot67Reward = nil
	for _ = 1, 50 do
		for _, child in ipairs(starterItems:GetChildren()) do
			if child:IsA("Frame") and child.Name == "Reward" then
				local title = child:FindFirstChild("Title")
				if title and title:IsA("TextLabel") and title.Text == "67 Brainrot" then
					brainrot67Reward = child
					break
				end
			end
		end
		if brainrot67Reward then break end
		task.wait(0.1)
	end

	if brainrot67Reward and chefData then
		local icon = brainrot67Reward:FindFirstChild("Icon")
		if icon then
			icon.Image = chefData.Image
		end
		local titleLabel = brainrot67Reward:FindFirstChild("Title")
		if titleLabel then
			titleLabel.Text = "Chef Crabracadabra"
		end
		local amountLabel = brainrot67Reward:FindFirstChild("Amount")
		if amountLabel then
			amountLabel.Text = "Legendary"
			amountLabel.Position = UDim2.new(0.5, 0, 0.807, 0)
			ApplyRarityGradient(amountLabel, "Legendary")
		end

	end
end)

-- ProPack: Secret brainrot (La Vacca Saturno Saturnita)
local secretData = BrainrotsModule["La Vacca Saturno Saturnita"]
if secretData then
	local proIcon = ProPackReward:FindFirstChild("Icon")
	local proTitle = ProPackReward:FindFirstChild("Title")
	if proIcon then
		proIcon.Image = secretData.Image
	end
	if proTitle then
		proTitle.Text = "La Vacca Saturno Saturnita"
	end
	local proAmount = ProPackReward:FindFirstChild("Amount")
	if proAmount then
		proAmount.Text = "Secret"
		proAmount.Position = UDim2.new(0.5, 0, 0.807, 0)
		ApplyRarityGradient(proAmount, "Secret")
	end

end

-- ProPack: Replace "Secret BrainRot" reward with Dragon Cannelloni (2D image, same style)
local proItems = proPackMain:WaitForChild("Items")
local dragonData = BrainrotsModule["Dragon Cannelloni"]
task.spawn(function()
	local secretBrainRotReward = nil
	for _ = 1, 50 do
		for _, child in ipairs(proItems:GetChildren()) do
			if child:IsA("Frame") and child.Name == "Reward" then
				local title = child:FindFirstChild("Title")
				if title and title:IsA("TextLabel") and title.Text == "Secret BrainRot" then
					secretBrainRotReward = child
					break
				end
			end
		end
		if secretBrainRotReward then break end
		task.wait(0.1)
	end

	if secretBrainRotReward and dragonData then
		local icon = secretBrainRotReward:FindFirstChild("Icon")
		if icon then
			icon.Image = dragonData.Image
		end
		local titleLabel = secretBrainRotReward:FindFirstChild("Title")
		if titleLabel then
			titleLabel.Text = "Dragon Cannelloni"
		end
		local amountLabel = secretBrainRotReward:FindFirstChild("Amount")
		if amountLabel then
			amountLabel.Text = "Secret"
			amountLabel.Position = UDim2.new(0.5, 0, 0.807, 0)
			ApplyRarityGradient(amountLabel, "Secret")
		end

	end
end)

-------------------------------
-- OP Lucky Block: Replace ALL rewards with brainrots
-- 2 random Epic, 1 Legendary, 1 Mythic, 1 Secret, 1 God
-------------------------------
local opLuckyItems = luckyBlockMain:WaitForChild("Items")

-- Collect brainrots by rarity from the module
local brainrotsByRarity = {}
for name, data in pairs(BrainrotsModule) do
	-- Only use base brainrots (no variant prefixes)
	if not name:match("^Gold ") and not name:match("^Diamond ") and not name:match("^Lava ") and not name:match("^Legendary ") and not name:match("^Lucky ") and not name:match("^Galaxy ") and not name:match("^Mythic ") and not name:match("^Midnight ") and not name:match("^Rainbow ") then
		local rType = data.RarityType
		if not brainrotsByRarity[rType] then
			brainrotsByRarity[rType] = {}
		end
		table.insert(brainrotsByRarity[rType], { name = name, data = data })
	end
end

-- Pick random brainrots for each rarity
local function pickRandom(rarityType, count)
	local pool = brainrotsByRarity[rarityType]
	if not pool or #pool == 0 then return {} end
	local picked = {}
	local used = {}
	for _ = 1, count do
		local attempts = 0
		repeat
			local idx = math.random(1, #pool)
			if not used[idx] then
				used[idx] = true
				table.insert(picked, pool[idx])
				break
			end
			attempts += 1
		until attempts > 50
	end
	return picked
end

local opRewards = {}
for _, v in ipairs(pickRandom("Epic", 2)) do table.insert(opRewards, { info = v, rarity = "Epic" }) end
for _, v in ipairs(pickRandom("Legendary", 1)) do table.insert(opRewards, { info = v, rarity = "Legendary" }) end
for _, v in ipairs(pickRandom("Mythic", 1)) do table.insert(opRewards, { info = v, rarity = "Mythic" }) end
for _, v in ipairs(pickRandom("Secret", 1)) do table.insert(opRewards, { info = v, rarity = "Secret" }) end
for _, v in ipairs(pickRandom("God", 1)) do table.insert(opRewards, { info = v, rarity = "God" }) end

task.spawn(function()
	local replacementIndex = 0

	for _ = 1, 60 do
		for _, child in ipairs(opLuckyItems:GetChildren()) do
			if child:IsA("Frame") and child.Name == "Reward" and not child:GetAttribute("OPReplaced") then
				replacementIndex += 1
				local rewardData = opRewards[replacementIndex]
				if rewardData and rewardData.info and rewardData.info.data then
					child:SetAttribute("OPReplaced", true)

					local icon = child:FindFirstChild("Icon")
					if icon then
						icon.Image = rewardData.info.data.Image
					end

					local titleLabel = child:FindFirstChild("Title")
					if titleLabel then
						titleLabel.Text = rewardData.info.name
					end

					local percentLabel = child:FindFirstChild("Percentage")
					if percentLabel then
						percentLabel.Text = rewardData.rarity
						percentLabel.Position = UDim2.new(0.5, 0, 0.875, 0)
						ApplyRarityGradient(percentLabel, rewardData.rarity)
					end
				end

				if replacementIndex >= #opRewards then break end
			end
		end

		if replacementIndex >= #opRewards then break end
		task.wait(0.1)
	end
end)

-- Debounce for purchase buttons
local CanActivate = {}

local function PromptPurchase(button, productId)
	if CanActivate[button] then return end
	CanActivate[button] = true
	EpicPromptSound:Play()
	MarketplaceService:PromptProductPurchase(LocalPlayer, productId)
	task.delay(1, function()
		CanActivate[button] = nil
	end)
end

-- Hover tween for buttons
local HoverTweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local function SetupHover(button)
	local OriginalSize = button.Size
	local HoverSize = OriginalSize + UDim2.new(-0.05, 0, -0.05, 0)
	local ClickSize = OriginalSize + UDim2.new(-0.15, 0, -0.15, 0)
	local IsHovered = false

	button.MouseEnter:Connect(function()
		IsHovered = true
		TweenService:Create(button, HoverTweenInfo, { Size = HoverSize }):Play()
	end)

	button.MouseLeave:Connect(function()
		IsHovered = false
		TweenService:Create(button, HoverTweenInfo, { Size = OriginalSize }):Play()
	end)

	button.MouseButton1Click:Connect(function()
		local ClickTween = TweenService:Create(button, HoverTweenInfo, { Size = ClickSize })
		ClickTween:Play()
		ClickTween.Completed:Connect(function()
			if IsHovered then
				TweenService:Create(button, HoverTweenInfo, { Size = HoverSize }):Play()
			else
				TweenService:Create(button, HoverTweenInfo, { Size = OriginalSize }):Play()
			end
		end)
	end)
end

-------------------------------
-- Cash Packs (Developer Products)
-------------------------------
local CashSection = ScrollingFrame:WaitForChild("Cash")
local CashPack1Buy = CashSection:WaitForChild("CashPack1"):WaitForChild("Main"):WaitForChild("Buy")
local CashPack2Buy = CashSection:WaitForChild("CashPack2"):WaitForChild("Main"):WaitForChild("Buy")
local CashPack3Buy = CashSection:WaitForChild("CashPack3"):WaitForChild("Main"):WaitForChild("Buy")

-- New IDs from user
local CASH_PACK_1_ID = 3575637363
local CASH_PACK_2_ID = 3575637446
local CASH_PACK_3_ID = 3575637532

-- Override cash pack display amounts
local CashPack1Amount = CashSection:WaitForChild("CashPack1"):WaitForChild("Main"):WaitForChild("Amount")
local CashPack2Amount = CashSection:WaitForChild("CashPack2"):WaitForChild("Main"):WaitForChild("Amount")
local CashPack3Amount = CashSection:WaitForChild("CashPack3"):WaitForChild("Main"):WaitForChild("Amount")
CashPack1Amount.Text = "+250K"
CashPack2Amount.Text = "+750K"
CashPack3Amount.Text = "+3.0M"

CashPack1Buy.Activated:Connect(function()
	PromptPurchase(CashPack1Buy, CASH_PACK_1_ID)
end)

CashPack2Buy.Activated:Connect(function()
	PromptPurchase(CashPack2Buy, CASH_PACK_2_ID)
end)

CashPack3Buy.Activated:Connect(function()
	PromptPurchase(CashPack3Buy, CASH_PACK_3_ID)
end)

SetButtonPrice(CashPack1Buy, CASH_PACK_1_ID)
SetButtonPrice(CashPack2Buy, CASH_PACK_2_ID)
SetButtonPrice(CashPack3Buy, CASH_PACK_3_ID)

SetupHover(CashPack1Buy)
SetupHover(CashPack2Buy)
SetupHover(CashPack3Buy)

-------------------------------
-- Server Luck
-------------------------------
local ServerLuckFrame = ScrollingFrame:WaitForChild("ServerLuck")
local ServerLuckMain = ServerLuckFrame:WaitForChild("Main")
local ServerLuckBuy = ServerLuckMain:WaitForChild("Buy")

local LuckData = {
	{ level = 1, nextLevel = 2, price = 64, productId = 3575648788 },
	{ level = 2, nextLevel = 4, price = 256, productId = 3575635769 },
	{ level = 4, nextLevel = 6, price = 1024, productId = 3575649004 },
	{ level = 6, nextLevel = 12, price = 2048, productId = 3575649620 },
	{ level = 12 }
}

local function GetLuckData(level)
	for _, Data in ipairs(LuckData) do
		if Data.level == level then
			return Data
		end
	end
	return LuckData[1]
end

local function UpdateServerLuckDisplay()
	local currentLuck = workspace:GetAttribute("ServerLuck") or 1
	local data = GetLuckData(currentLuck)
	local isMax = currentLuck == 12

	-- Title update logic removed from here to keep UI titles static

	if isMax then
		ServerLuckBuy.Text = "Maxed"
	else
		-- Update price dynamically
		SetButtonPrice(ServerLuckBuy, data.productId)
	end
end

UpdateServerLuckDisplay()
workspace:GetAttributeChangedSignal("ServerLuck"):Connect(UpdateServerLuckDisplay)

ServerLuckBuy.Activated:Connect(function()
	local currentLuck = workspace:GetAttribute("ServerLuck") or 1
	local data = GetLuckData(currentLuck)
	if not data.productId then return end
	PromptPurchase(ServerLuckBuy, data.productId)
end)

SetupHover(ServerLuckBuy)

-------------------------------
-- VIP (Gamepass)
-------------------------------
local VIPFrame = ScrollingFrame:WaitForChild("VIP")
local VIPMain = VIPFrame:WaitForChild("Main")
local VIPBuy = VIPMain:WaitForChild("Buy")
local VIP_GAMEPASS_ID = 1793949172

VIPBuy.Activated:Connect(function()
	if LocalPlayer:GetAttribute("VIP") then return end
	if CanActivate[VIPBuy] then return end
	CanActivate[VIPBuy] = true
	EpicPromptSound:Play()
	MarketplaceService:PromptGamePassPurchase(LocalPlayer, VIP_GAMEPASS_ID)
	task.delay(1, function()
		CanActivate[VIPBuy] = nil
	end)
end)

SetButtonPrice(VIPBuy, VIP_GAMEPASS_ID, true)
SetupHover(VIPBuy)

-------------------------------
-- Starter Pack (one-time purchase)
-------------------------------
local STARTER_PACK_PRODUCT_ID = 3575647982
local StarterPackBuy = starterPackMain:WaitForChild("Buy")
local StarterPackBuyTitle = StarterPackBuy:FindFirstChild("Title")

local function UpdateStarterPackDisplay()
	if LocalPlayer:GetAttribute("StarterPack") then
		if StarterPackBuyTitle then
			StarterPackBuyTitle.Text = "Owned"
		end
	else
		SetButtonPrice(StarterPackBuy, STARTER_PACK_PRODUCT_ID)
	end
end

UpdateStarterPackDisplay()
LocalPlayer:GetAttributeChangedSignal("StarterPack"):Connect(UpdateStarterPackDisplay)

StarterPackBuy.Activated:Connect(function()
	if LocalPlayer:GetAttribute("StarterPack") then return end
	PromptPurchase(StarterPackBuy, STARTER_PACK_PRODUCT_ID)
end)

SetupHover(StarterPackBuy)

-------------------------------
-- Pro Pack (one-time purchase)
-------------------------------
local PRO_PACK_PRODUCT_ID = 3575648136
local ProPackBuy = proPackMain:WaitForChild("Buy")
local ProPackBuyTitle = ProPackBuy:FindFirstChild("Title")

local function UpdateProPackDisplay()
	if LocalPlayer:GetAttribute("ProPack") then
		if ProPackBuyTitle then
			ProPackBuyTitle.Text = "Owned"
		end
	else
		SetButtonPrice(ProPackBuy, PRO_PACK_PRODUCT_ID)
	end
end

UpdateProPackDisplay()
LocalPlayer:GetAttributeChangedSignal("ProPack"):Connect(UpdateProPackDisplay)

ProPackBuy.Activated:Connect(function()
	if LocalPlayer:GetAttribute("ProPack") then return end
	PromptPurchase(ProPackBuy, PRO_PACK_PRODUCT_ID)
end)

SetupHover(ProPackBuy)

-------------------------------
-- 2x Cash Boost (15 min, rebuyable & stackable)
-------------------------------
local X2CASH_PRODUCT_ID = 3575648344
local PassesSection = ScrollingFrame:WaitForChild("Passes")
local X2CashFrame = PassesSection:WaitForChild("x2Cash")
local X2CashMain = X2CashFrame:WaitForChild("Main")
local X2CashBuy = X2CashMain:WaitForChild("Buy")
local X2CashDesc = X2CashMain:WaitForChild("Desc")
local NotifsEvent = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("NotifsEvent")

local DefaultDesc = "Gain twice money from brainrots for 15 minutes!"

X2CashBuy.Activated:Connect(function()
	PromptPurchase(X2CashBuy, X2CASH_PRODUCT_ID)
end)

SetButtonPrice(X2CashBuy, X2CASH_PRODUCT_ID)
SetupHover(X2CashBuy)

-- Timer display: show countdown when boost is active (don't touch Buy button text)
local function FormatBoostTime(seconds)
	local mins = math.floor(seconds / 60)
	local secs = math.floor(seconds % 60)
	return string.format("%02d:%02d", mins, secs)
end

local function UpdateX2CashDisplay()
	local expiry = LocalPlayer:GetAttribute("CashBoostExpiry") or 0
	local now = os.time()
	local remaining = expiry - now

	if remaining > 0 then
		X2CashDesc.Text = "Active! " .. FormatBoostTime(remaining) .. " remaining"
	else
		X2CashDesc.Text = DefaultDesc
	end
end

UpdateX2CashDisplay()

-- Show notification when boost is activated/extended
LocalPlayer:GetAttributeChangedSignal("CashBoostExpiry"):Connect(function()
	local expiry = LocalPlayer:GetAttribute("CashBoostExpiry") or 0
	local now = os.time()
	local remaining = expiry - now
	if remaining > 0 then
		local mins = math.ceil(remaining / 60)
		NotifsEvent:Fire("2x Cash active! " .. mins .. " min remaining", true)
	end
	UpdateX2CashDisplay()
end)

-- Live countdown timer
task.spawn(function()
	while true do
		local expiry = LocalPlayer:GetAttribute("CashBoostExpiry") or 0
		if expiry > os.time() then
			UpdateX2CashDisplay()
		end
		task.wait(1)
	end
end)

-------------------------------
-- Super Luck (150% better rarity, 15 min, rebuyable & stackable)
-------------------------------
local SUPER_LUCK_PRODUCT_ID = 3575648479
local SuperLuckFrame = PassesSection:WaitForChild("SuperLuck")
local SuperLuckMain = SuperLuckFrame:WaitForChild("Main")
local SuperLuckBuy = SuperLuckMain:WaitForChild("Buy")
local SuperLuckDesc = SuperLuckMain:WaitForChild("Desc")
local DefaultSuperLuckDesc = "150% better chance for rare brainrots for 15 min!"

SuperLuckBuy.Activated:Connect(function()
	PromptPurchase(SuperLuckBuy, SUPER_LUCK_PRODUCT_ID)
end)

SetButtonPrice(SuperLuckBuy, SUPER_LUCK_PRODUCT_ID)
SetupHover(SuperLuckBuy)

local function UpdateSuperLuckDisplay()
	local expiry = LocalPlayer:GetAttribute("SuperLuckExpiry") or 0
	local now = os.time()
	local remaining = expiry - now
	if remaining > 0 then
		SuperLuckDesc.Text = "Active! " .. FormatBoostTime(remaining) .. " remaining"
	else
		SuperLuckDesc.Text = DefaultSuperLuckDesc
	end
end

UpdateSuperLuckDisplay()

LocalPlayer:GetAttributeChangedSignal("SuperLuckExpiry"):Connect(function()
	local expiry = LocalPlayer:GetAttribute("SuperLuckExpiry") or 0
	local now = os.time()
	local remaining = expiry - now
	if remaining > 0 then
		local mins = math.ceil(remaining / 60)
		NotifsEvent:Fire("Super Luck active! " .. mins .. " min remaining", true)
	end
	UpdateSuperLuckDisplay()
end)

task.spawn(function()
	while true do
		local expiry = LocalPlayer:GetAttribute("SuperLuckExpiry") or 0
		if expiry > os.time() then
			UpdateSuperLuckDisplay()
		end
		task.wait(1)
	end
end)

-------------------------------
-- Mega Luck (300% better rarity, 15 min, rebuyable & stackable)
-------------------------------
local MEGA_LUCK_PRODUCT_ID = 3575648591
local MegaLuckFrame = PassesSection:WaitForChild("MegaLuck")
local MegaLuckMain = MegaLuckFrame:WaitForChild("Main")
local MegaLuckBuy = MegaLuckMain:WaitForChild("Buy")
local MegaLuckDesc = MegaLuckMain:WaitForChild("Desc")
local DefaultMegaLuckDesc = "300% better chance for rare brainrots for 15 min!"

MegaLuckBuy.Activated:Connect(function()
	PromptPurchase(MegaLuckBuy, MEGA_LUCK_PRODUCT_ID)
end)

SetButtonPrice(MegaLuckBuy, MEGA_LUCK_PRODUCT_ID)
SetupHover(MegaLuckBuy)

local function UpdateMegaLuckDisplay()
	local expiry = LocalPlayer:GetAttribute("MegaLuckExpiry") or 0
	local now = os.time()
	local remaining = expiry - now
	if remaining > 0 then
		MegaLuckDesc.Text = "Active! " .. FormatBoostTime(remaining) .. " remaining"
	else
		MegaLuckDesc.Text = DefaultMegaLuckDesc
	end
end

UpdateMegaLuckDisplay()

LocalPlayer:GetAttributeChangedSignal("MegaLuckExpiry"):Connect(function()
	local expiry = LocalPlayer:GetAttribute("MegaLuckExpiry") or 0
	local now = os.time()
	local remaining = expiry - now
	if remaining > 0 then
		local mins = math.ceil(remaining / 60)
		NotifsEvent:Fire("Mega Luck active! " .. mins .. " min remaining", true)
	end
	UpdateMegaLuckDisplay()
end)

task.spawn(function()
	while true do
		local expiry = LocalPlayer:GetAttribute("MegaLuckExpiry") or 0
		if expiry > os.time() then
			UpdateMegaLuckDisplay()
		end
		task.wait(1)
	end
end)

-------------------------------
-- OP Lucky Block (1x / 3x / 8x)
-------------------------------
local LuckyBlockButtons = luckyBlockMain:WaitForChild("Buttons")
local LBBuy1 = LuckyBlockButtons:WaitForChild("Buy1")
local LBBuy3 = LuckyBlockButtons:WaitForChild("Buy3")
local LBBuy8 = LuckyBlockButtons:WaitForChild("Buy8")

local LB_1_ID = 3575649831
local LB_3_ID = 3575650433
local LB_8_ID = 3575650670

LBBuy1.Activated:Connect(function()
	PromptPurchase(LBBuy1, LB_1_ID)
end)

LBBuy3.Activated:Connect(function()
	PromptPurchase(LBBuy3, LB_3_ID)
end)

LBBuy8.Activated:Connect(function()
	PromptPurchase(LBBuy8, LB_8_ID)
end)

SetButtonPrice(LBBuy1, LB_1_ID)
SetButtonPrice(LBBuy3, LB_3_ID)
SetButtonPrice(LBBuy8, LB_8_ID)

SetupHover(LBBuy1)
SetupHover(LBBuy3)
SetupHover(LBBuy8)
