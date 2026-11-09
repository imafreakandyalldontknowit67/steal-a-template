-- Ai slop btw cba to learn topbar :sob:

local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")

local container = game.ReplicatedStorage:WaitForChild("Shared")
local Icon = require(container.Icon)

local settingsFrame = playerGui:WaitForChild("MainGUI"):WaitForChild("SettingsFrame")
local settingsClose = settingsFrame:WaitForChild("Close").Close

local slot1 = playerGui:WaitForChild("MainGUI"):WaitForChild("EmoteWheel"):WaitForChild("Slot1")
local slot2 = playerGui:WaitForChild("MainGUI"):WaitForChild("EmoteWheel"):WaitForChild("Slot2")
local slot3 = playerGui:WaitForChild("MainGUI"):WaitForChild("EmoteWheel"):WaitForChild("Slot3")
local slot4 = playerGui:WaitForChild("MainGUI"):WaitForChild("EmoteWheel"):WaitForChild("Slot4")

local settingsIcon
local emotesIcon

local function createIcons()
	if settingsIcon then
		settingsIcon:destroy()
	end

	if emotesIcon then
		emotesIcon:destroy()
	end

	local mainGui = playerGui:WaitForChild("MainGUI")

	local settingsFrame = mainGui.SettingsFrame
	local emoteWheel = mainGui.EmoteWheel

	emotesIcon = Icon.new()
		:setName("Emotes")
		:setLabel("Emotes")
		:setImage(90682070728446)
		:bindToggleItem(emoteWheel)
		:bindToggleKey(Enum.KeyCode.B)
end

createIcons()

localPlayer.CharacterAdded:Connect(function()
	task.wait(0.5)
	createIcons()
end)

settingsIcon:bindEvent("toggled", function(icon, isSelected)
	if not isSelected then
		settingsFrame.Visible = false
	end
end)

settingsClose.MouseButton1Click:Connect(function()
	settingsIcon:deselect()
end)

slot1.MouseButton1Click:Connect(function()
	emotesIcon:deselect()
end)

slot2.MouseButton1Click:Connect(function()
	emotesIcon:deselect()
end)

slot3.MouseButton1Click:Connect(function()
	emotesIcon:deselect()
end)

slot4.MouseButton1Click:Connect(function()
	emotesIcon:deselect()
end)