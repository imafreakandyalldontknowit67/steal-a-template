local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Get the announcement RemoteEvent
local AdminPanelRemote = ReplicatedStorage:WaitForChild("AdminPanelRemote")
local GlobalAnnounceEvent = AdminPanelRemote:WaitForChild("GlobalAnnounce")

-- Create announcement UI
local announcementScreen = Instance.new("ScreenGui")
announcementScreen.Name = "GlobalAnnouncement"
announcementScreen.ResetOnSpawn = false
announcementScreen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
announcementScreen.Parent = playerGui

local announcementFrame = Instance.new("Frame")
announcementFrame.Name = "AnnouncementFrame"
announcementFrame.Size = UDim2.new(0.9, 0, 0, 60)
announcementFrame.Position = UDim2.new(0.5, 0, -0.1, 0) -- Start off screen
announcementFrame.AnchorPoint = Vector2.new(0.5, 0)
announcementFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
announcementFrame.BackgroundTransparency = 0.3
announcementFrame.BorderSizePixel = 0
announcementFrame.Parent = announcementScreen

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = announcementFrame

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(100, 100, 255)
stroke.Thickness = 2
stroke.Parent = announcementFrame

local padding = Instance.new("UIPadding")
padding.PaddingLeft = UDim.new(0, 20)
padding.PaddingRight = UDim.new(0, 20)
padding.Parent = announcementFrame

local textLabel = Instance.new("TextLabel")
textLabel.Name = "Message"
textLabel.Size = UDim2.new(1, 0, 1, 0)
textLabel.BackgroundTransparency = 1
textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
textLabel.Font = Enum.Font.GothamBold
textLabel.TextSize = 20
textLabel.TextWrapped = true
textLabel.Parent = announcementFrame

-- Animation functions
local function showAnnouncement(message)
	textLabel.Text = message
	
	-- Animate in from top
	local tweenIn = TweenService:Create(announcementFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Position = UDim2.new(0.5, 0, 0.05, 0)
	})
	tweenIn:Play()
	
	-- Auto-hide after 5 seconds
	task.wait(5)
	
	local tweenOut = TweenService:Create(announcementFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
		Position = UDim2.new(0.5, 0, -0.1, 0)
	})
	tweenOut:Play()
end

-- Listen for global announcements
GlobalAnnounceEvent.OnClientEvent:Connect(function(message)
	print("[AnnouncementClient] Received announcement:", message)
	showAnnouncement(message)
end)

print("[AnnouncementClient] Loaded successfully")
