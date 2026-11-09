function onPlayerEntered(newPlayer)
	local stats = Instance.new("Folder")
	stats.Name = "Emotes"

	local emotes = {
		"PendingClaims","Yuji Jump"
	}

	local Slots = {
		"Slot1", "Slot2", "Slot3", "Slot4"
	}

	for _, name in ipairs(emotes) do
		local value = Instance.new("NumberValue")
		value.Name = name
		value.Value = 0
		value.Parent = stats
	end

	--[[ Kill reward system uncomment if you want it
	local rewardKills = Instance.new("IntValue")
	rewardKills.Name = "KillReward"
	rewardKills.Value = 0
	rewardKills.Parent = stats
	]]
	for _, name in ipairs(Slots) do
		local value = Instance.new("StringValue")
		value.Name = name
		value.Value = "None"
		value.Parent = stats
	end

	stats.Parent = newPlayer

	local kills = newPlayer:WaitForChild("Stats"):WaitForChild("Kills")
	local pendingClaims = stats:WaitForChild("PendingClaims")
--[[ Kill reward system uncomment if you want it
	kills.Changed:Connect(function()
		while kills.Value >= rewardKills.Value + 20 do
			rewardKills.Value += 20
			pendingClaims.Value += 1
		end
	end)
	]]
end

game.Players.PlayerAdded:Connect(onPlayerEntered)