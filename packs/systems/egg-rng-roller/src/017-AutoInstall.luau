--[[
	Sets up the Egg Randomizer when the game starts, so the kit works as soon as you press Play.
	To install it for good instead (cleaner), see the README script in this folder.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local kit = script.Parent

if ReplicatedStorage:FindFirstChild("EggRandomizer") then
	warn("[EggRandomizerKit] Already installed, so this kit copy was skipped. You can delete " .. kit:GetFullName() .. ".")
	kit:Destroy() -- only for this play session, so you don't get a second machine
	return
end

require(kit:WaitForChild("Install"))()
