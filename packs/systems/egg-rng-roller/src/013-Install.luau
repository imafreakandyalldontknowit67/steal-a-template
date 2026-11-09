--[[
	Egg Randomizer Kit - installer

	Run this once from the Command Bar (View > Command Bar) and press Enter:

		require(workspace.EggRandomizerKit.Install)()

	It moves every part of the system to the right place in your game, turns the server
	scripts on and removes the kit folder. Ctrl+Z undoes it.
	If you skip this step, the AutoInstall script does the same thing each time the game starts.
]]

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local LOG = "[EggRandomizerKit]"

-- kit folder -> where its contents go, in install order (server scripts last)
local TARGETS = {
	{ "ReplicatedStorage", function() return game:GetService("ReplicatedStorage") end },
	{ "ServerStorage", function() return game:GetService("ServerStorage") end },
	{ "Workspace", function() return workspace end },
	{ "StarterGui", function() return game:GetService("StarterGui") end },
	{ "StarterPlayerScripts", function() return game:GetService("StarterPlayer"):WaitForChild("StarterPlayerScripts") end },
	{ "ServerScriptService", function() return game:GetService("ServerScriptService") end },
}

local function turnOnScripts(root: Instance)
	local list = root:GetDescendants()
	table.insert(list, root)
	for _, item in list do
		if item:IsA("BaseScript") and item:GetAttribute("KitEnabled") then
			item:SetAttribute("KitEnabled", nil)
			item.Enabled = true
		end
	end
end

-- Anyone who joined before the kit installed still needs the menus and client scripts.
local function giveToPlayersInGame(guis: { Instance }, playerScripts: { Instance })
	for _, player in Players:GetPlayers() do
		local playerGui = player:FindFirstChildOfClass("PlayerGui")
		if playerGui then
			for _, gui in guis do
				if not playerGui:FindFirstChild(gui.Name) then
					gui:Clone().Parent = playerGui
				end
			end
			if #playerScripts > 0 and not playerGui:FindFirstChild("EggRandomizerClientScripts") then
				-- kept in a ScreenGui that never resets, so they keep running after a respawn
				local holder = Instance.new("ScreenGui")
				holder.Name = "EggRandomizerClientScripts"
				holder.ResetOnSpawn = false
				for _, localScript in playerScripts do
					localScript:Clone().Parent = holder
				end
				holder.Parent = playerGui
			end
		end
	end
end

return function()
	local kit = script.Parent
	local running = RunService:IsRunning()

	local ChangeHistoryService = game:GetService("ChangeHistoryService")
	local recording
	if not running then
		local ok, id = pcall(function()
			return ChangeHistoryService:TryBeginRecording("Install Egg Randomizer Kit")
		end)
		if ok then
			recording = id
		end
	end

	local installed, guis, playerScripts = {}, {}, {}
	local oldCopies
	for _, entry in TARGETS do
		local source = kit:FindFirstChild(entry[1])
		if source then
			local target = entry[2]()
			for _, item in source:GetChildren() do
				local existing = target:FindFirstChild(item.Name)
				if existing then
					-- never delete someone's old copy: park it in ServerStorage, where nothing runs
					if not oldCopies then
						oldCopies = Instance.new("Folder")
						oldCopies.Name = "EggRandomizerKit_OldVersion"
						oldCopies.Parent = game:GetService("ServerStorage")
					end
					existing.Parent = oldCopies
				end
				item.Parent = target
				table.insert(installed, item)
				if entry[1] == "StarterGui" then
					table.insert(guis, item)
				elseif entry[1] == "StarterPlayerScripts" then
					table.insert(playerScripts, item)
				end
			end
		end
	end

	for _, item in installed do
		turnOnScripts(item)
	end

	if running then
		giveToPlayersInGame(guis, playerScripts)
	else
		local readme = kit:FindFirstChild("README")
		local shared = game:GetService("ReplicatedStorage"):FindFirstChild("EggRandomizer")
		if readme and shared then
			readme.Parent = shared
		end
		kit.Parent = nil -- Ctrl+Z brings it back
		if recording then
			ChangeHistoryService:FinishRecording(recording, Enum.FinishRecordingOperation.Commit)
		end
		local machine = workspace:FindFirstChild("EggRandomizerMachine")
		if machine then
			pcall(function()
				game:GetService("Selection"):Set({ machine })
			end)
		end
		print(LOG, "Installed! Press Play to try it. Settings: ReplicatedStorage > EggRandomizer > Config")
	end

	if oldCopies then
		warn(LOG, "Your previous version was moved to ServerStorage > EggRandomizerKit_OldVersion. Delete it once you've copied over any changes.")
	end
end
