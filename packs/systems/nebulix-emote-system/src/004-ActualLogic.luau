local MarketplaceService = game:GetService("MarketplaceService")

local paidRandomItemsRestricted = false

local success, policy = pcall(function()
	return MarketplaceService:GetPolicyInfoForPlayerAsync(game.Players.LocalPlayer)
end)

if success and policy then
	paidRandomItemsRestricted = policy.ArePaidRandomItemsRestricted == true
end

local DEV_PRODUCT_ID = 3608623691

local pl = game.Players.LocalPlayer

local stats = pl:WaitForChild("Stats")
local Emotes = pl:WaitForChild("Emotes")

local kills = stats:WaitForChild("Kills")
local reward = Emotes:WaitForChild("KillReward")
local pendingClaims = Emotes:WaitForChild("PendingClaims")

local RandomGen = Random.new()

local pendingEmote

if paidRandomItemsRestricted then
	script.Parent.Text = "NOT AVAILABLE IN YOUR REGION."
end

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

script.Parent.MouseButton1Click:Connect(function()

	if paidRandomItemsRestricted then
		script.Parent.Text = "NOT AVAILABLE IN YOUR REGION."
		return
	end

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


	if #unowned == 0 then
		return
	end

	pendingEmote = unowned[RandomGen:NextInteger(1, #unowned)]

	MarketplaceService:PromptProductPurchase(pl, DEV_PRODUCT_ID)
end)

MarketplaceService.PromptProductPurchaseFinished:Connect(function(userId, productId, purchased)
	print("Finished", userId, productId, purchased)

	if purchased and pendingEmote then
		print("Giving", pendingEmote.Name)

		game.ReplicatedStorage.Functions.ChangeStat:FireServer(
			Emotes, pendingEmote.Name,
			1
		)
	end
end)