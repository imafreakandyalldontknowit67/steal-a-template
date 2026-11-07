local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local EpicPromptSound = ReplicatedStorage:WaitForChild("Sounds"):WaitForChild("EpicPromptSound")

local Store = script.Parent
local ScrollingFrame = Store:WaitForChild("ScrollingFrame")

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

CashPack1Buy.Activated:Connect(function()
	PromptPurchase(CashPack1Buy, 3537947235)
end)

CashPack2Buy.Activated:Connect(function()
	PromptPurchase(CashPack2Buy, 3537947783)
end)

CashPack3Buy.Activated:Connect(function()
	PromptPurchase(CashPack3Buy, 3537947997)
end)

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
	{ level = 1, nextLevel = 2, price = 64, productId = 3478038081 },
	{ level = 2, nextLevel = 4, price = 256, productId = 3478038426 },
	{ level = 4, nextLevel = 6, price = 1024, productId = 3478038848 },
	{ level = 6, nextLevel = 12, price = 2048, productId = 3478038582 },
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

	local titleUp = ServerLuckMain:FindFirstChild("TitleUp")
	local titleDown = ServerLuckMain:FindFirstChild("TitleDown")

	if titleUp then
		titleUp.Text = "x" .. tostring(currentLuck) .. " Luck"
	end
	if titleDown then
		if isMax then
			titleDown.Text = "MAXED"
		else
			titleDown.Text = "-> x" .. tostring(data.nextLevel or 12)
		end
	end

	if isMax then
		ServerLuckBuy.Text = "Maxed"
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

SetupHover(VIPBuy)
