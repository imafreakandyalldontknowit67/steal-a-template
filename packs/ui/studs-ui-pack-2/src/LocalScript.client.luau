--// Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")
local TweenService = game:GetService("TweenService")

--// Modules
local ClientSoundsManager = require(script.ClientSoundsManager)
local OpenManager = require(script.OpenManager)

--// Reference
local LocalPlayer = Players.LocalPlayer
local playerGui = LocalPlayer:WaitForChild("PlayerGui")
local gameUI = playerGui:WaitForChild("GameUI")
local hudFrame = gameUI:WaitForChild("HUD")
local mainUI = gameUI:WaitForChild("Main")

--// Constants
local HOVER_SCALE = 1.05
local CLICK_SCALE = 0.95

local HOVER_TI = TweenInfo.new(0.125, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local CLICK_TI = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local LEAVE_TI = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local ROTATE_TI = TweenInfo.new(3, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1)

--// Functions
local function newUI(uiInstance: Instance)
	-- Button animation + logic
	if uiInstance:IsA("TextButton") or uiInstance:IsA("ImageButton") then
		-- Logic
		if uiInstance.Name == "Close" then
			uiInstance.MouseButton1Click:Connect(function()
				OpenManager.Close()
			end)
		end

		-- Animation
		local uiScale = uiInstance:FindFirstChildOfClass("UIScale")

		if uiScale then
			uiScale = uiScale
		else
			uiScale = Instance.new("UIScale", uiInstance)
		end

		local enterTween = TweenService:Create(uiScale, HOVER_TI, {Scale = HOVER_SCALE})
		local clickTween = TweenService:Create(uiScale, CLICK_TI, {Scale = CLICK_SCALE})
		local leaveTween = TweenService:Create(uiScale, LEAVE_TI, {Scale = 1})

		uiInstance.MouseEnter:Connect(function()
			ClientSoundsManager.PlaySFX("Hover")
			enterTween:Play()
		end)

		uiInstance.MouseLeave:Connect(function()
			leaveTween:Play()
		end)

		uiInstance.MouseButton1Down:Connect(function()
			ClientSoundsManager.PlaySFX("Click")
			clickTween:Play()
		end)

		uiInstance.MouseButton1Up:Connect(function()
			enterTween:Play()
		end)
	end

	-- Sunburst rotate
	if uiInstance:HasTag("SunRotate") and uiInstance:IsA("GuiObject") then
		uiInstance.Rotation = 180
		TweenService:Create(uiInstance, ROTATE_TI, {Rotation = -180}):Play()
	end
end

local function newHUD(uiInstance: Instance)
	if uiInstance:IsA("TextButton") or uiInstance:IsA("ImageButton") then
		-- Open button!
		local frame = mainUI and mainUI:FindFirstChild(uiInstance.Name)

		if frame ~= nil then
			uiInstance.MouseButton1Click:Connect(function()
				OpenManager.Open(frame)
			end)
		end
	end
end

gameUI.DescendantAdded:Connect(newUI)
hudFrame.DescendantAdded:Connect(newHUD)

for _, uiInstance in gameUI:GetDescendants() do
	newUI(uiInstance)
end

for _, uiInstance in hudFrame:GetDescendants() do
	newHUD(uiInstance)
end

-- Register the initially visible offer so its Close button works immediately.
local initialOffer = mainUI:FindFirstChild("StarterPack")
if initialOffer and initialOffer.Visible then
    OpenManager.Open(initialOffer)
end
