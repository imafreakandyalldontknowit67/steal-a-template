-- SCRIPT MADE BY: DEVJM (sorryladiesihave)
local RunService = game:GetService("RunService")
local player = game.Players.LocalPlayer
local camera = workspace.CurrentCamera

-- Settings
local OFFSET = Vector3.new(18, 12, 18) -- U can change here.
local TARGET_FOV = 50 -- Dungeon Camera FOV 
local SMOOTHNESS = 0.15 -- Smoothness

camera.CameraType = Enum.CameraType.Scriptable
camera.FieldOfView = TARGET_FOV

local function updateCamera()
	local character = player.Character
	if character and character:FindFirstChild("HumanoidRootPart") then
		local rootPart = character.HumanoidRootPart

		local targetCameraPos = rootPart.Position + OFFSET

		local newCFrame = CFrame.lookAt(targetCameraPos, rootPart.Position)

		camera.CFrame = camera.CFrame:Lerp(newCFrame, SMOOTHNESS)
	end
end

RunService.RenderStepped:Connect(updateCamera)