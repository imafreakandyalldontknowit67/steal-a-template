local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")

local EmotesStore = DataStoreService:GetDataStore("PlayerEmotes")

local function SavePlayer(player)
	local Emotes = player:FindFirstChild("Emotes")
	if not Emotes then
		warn("No Emotes folder for " .. player.Name)
		return
	end

	local dataToSave = {}

	for _, value in ipairs(Emotes:GetChildren()) do
		if value:IsA("IntValue") or value:IsA("NumberValue") or value:IsA("StringValue") then
			dataToSave[value.Name] = value.Value
			print("Saving:", value.Name, value.Value)
		end
	end

	local success, err = pcall(function()
		EmotesStore:SetAsync(player.UserId, dataToSave)
	end)

	if success then
		print("Saved emotes for", player.Name)
	else
		warn("Failed to save " .. player.Name .. ": " .. err)
	end
end

Players.PlayerAdded:Connect(function(player)
	local Emotes = player:WaitForChild("Emotes")

	local success, data = pcall(function()
		return EmotesStore:GetAsync(player.UserId)
	end)

	if not success then
		warn("Failed to load " .. player.Name)
		return
	end

	if type(data) ~= "table" then
		print("No save data for", player.Name)
		return
	end

	-- Optional migration from old "None" value
	if data.None ~= nil and data.KillReward == nil then
		data.KillReward = data.None
		data.None = nil
	end

	for name, value in pairs(data) do
		local stat = Emotes:FindFirstChild(name)

		if stat and (stat:IsA("IntValue") or stat:IsA("NumberValue") or stat:IsA("StringValue")) then
			stat.Value = value
			print("Loaded:", name, value)
		else
			warn("Saved value '" .. name .. "' no longer exists.")
		end
	end
end)

Players.PlayerRemoving:Connect(SavePlayer)

game:BindToClose(function()
	for _, player in ipairs(Players:GetPlayers()) do
		SavePlayer(player)
	end
end)