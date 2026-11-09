local pl = game.Players.LocalPlayer

local stats = pl:WaitForChild("Stats")
local Emotes = pl:WaitForChild("Emotes")

local kills = stats:WaitForChild("Kills")
local reward = Emotes:WaitForChild("KillReward")
local pendingClaims = Emotes:WaitForChild("PendingClaims")

local function update()
	local owned = 0
	local total = 0

	for _, v in ipairs(Emotes:GetChildren()) do
		if v:IsA("NumberValue") and v.Name ~= "KillReward" and v.Name ~= "PendingClaims" then
			total += 1
			if v.Value > 0 then
				owned += 1
			end
		end
	end

	if owned == total then
		script.Parent.Text = "YOU OWN ALL EMOTES"
	elseif pendingClaims.Value > 0 then
		script.Parent.Text = string.format("CLAIM EMOTE (%d)", pendingClaims.Value)
	else
		local killsLeft = math.max(0, 20 - (kills.Value - reward.Value))
		script.Parent.Text = string.format("%d KILLS UNTIL EMOTE", killsLeft)
	end
end

kills.Changed:Connect(update)
reward.Changed:Connect(update)
pendingClaims.Changed:Connect(update)

for _, v in ipairs(Emotes:GetChildren()) do
	if v:IsA("NumberValue") then
		v.Changed:Connect(update)
	end
end

update()

local RandomGen = Random.new()

script.Parent.MouseButton1Click:Connect(function()
	if pendingClaims.Value > 0 then
		local unowned = {}

		for _, v in ipairs(Emotes:GetChildren()) do
			if v:IsA("NumberValue")
				and v.Name ~= "KillReward"
				and v.Name ~= "PendingClaims"
				and v.Value == 0
				and game.ReplicatedStorage.Functions.GetEmote:InvokeServer("CheckGivingValidity", v.Name) then

				table.insert(unowned, v)
			end
		end

		if #unowned > 0 then
			local chosen = unowned[RandomGen:NextInteger(1, #unowned)]

			game.ReplicatedStorage.Functions.ChangeStat:FireServer(Emotes, chosen.Name, 1)
		end
	end
end)