local button = script.Parent

local hoverSound = button:WaitForChild("Hover")
local selectSound = button:WaitForChild("Select")

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

local uiScale = button:FindFirstChildOfClass("UIScale")
if not uiScale then
	uiScale = Instance.new("UIScale")
	uiScale.Scale = 1
	uiScale.Parent = button
end

local tweenInfo = TweenInfo.new(
	0.15,
	Enum.EasingStyle.Quad,
	Enum.EasingDirection.Out
)

button.MouseEnter:Connect(function()
	hoverSound:Play()

	TweenService:Create(uiScale, tweenInfo, {
		Scale = 1.05
	}):Play()
end)

button.MouseLeave:Connect(function()
	TweenService:Create(uiScale, tweenInfo, {
		Scale = 1
	}):Play()
end)

button.MouseButton1Click:Connect(function()
	selectSound:Play()
end)