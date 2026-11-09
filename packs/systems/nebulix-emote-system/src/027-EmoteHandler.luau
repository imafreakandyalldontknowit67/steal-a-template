local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local emotes = ServerStorage:WaitForChild("Emotes")
local anims = emotes:WaitForChild("Anims")
local sounds = emotes:WaitForChild("Sounds")

local ContentProvider = game:GetService("ContentProvider")

local getEmote = ReplicatedStorage.Functions:WaitForChild("GetEmote")

local activeSounds = {}
local walkSpeedData = {}

local function destroySound(player)
	print("destroySound")
	local sound = activeSounds[player]
	if not sound then
		return
	end

	activeSounds[player] = nil

	if sound.Parent then
		sound:Stop()
		sound:Destroy()
	end
end

local function fadeOutSound(player)
	print("fadeOutSound")
	local sound = activeSounds[player]
	if not sound then
		return
	end

	activeSounds[player] = nil

	if not sound.Parent then
		return
	end

	local tween = TweenService:Create(
		sound,
		TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{
			Volume = 0
		}
	)

	tween:Play()

	tween.Completed:Once(function()
		if sound.Parent then
			sound:Stop()
			sound:Destroy()
		end
	end)
end

local function characterHasRayValue(character)
	for _, obj in ipairs(character:GetChildren()) do
		if obj:IsA("RayValue") then
			return true
		end
	end
	return false
end

local function characterHasTool(character)
	for _, obj in ipairs(character:GetChildren()) do
		if obj:IsA("Tool") then
			return true
		end
	end
	return false
end

getEmote.OnServerInvoke = function(player, action, emoteName)
	print(action, emoteName)
	
	if action == "DummyGet" then
		if emoteName == "None" then
			return nil
		else
			return anims:FindFirstChild(emoteName).AnimationId
		end
		
	elseif action == "CheckGivingValidity" then
		if anims[emoteName]:GetAttribute("Admin") or anims[emoteName]:GetAttribute("Limited") then
			return false
		else
			return true
		end
	elseif action == "Get" then
		if typeof(emoteName) ~= "string" then
			return nil
		end

		local animation = anims:FindFirstChild(emoteName)
		if not animation or not animation:IsA("Animation") then
			return nil
		end

		destroySound(player)

		local character = player.Character
		if character then
			local humanoid = character:FindFirstChildOfClass("Humanoid")
			local root = character:FindFirstChild("HumanoidRootPart")

			if humanoid then
				walkSpeedData[player] = {
					OldSpeed = humanoid.WalkSpeed,
					HadRayValue = characterHasRayValue(character),
					HadTool = characterHasTool(character)
				}

				humanoid.WalkSpeed = 2

			end

			if root then
				local soundTemplate = sounds:FindFirstChild(emoteName)

				if soundTemplate and soundTemplate:IsA("Sound") then
					local sound = soundTemplate:Clone()
					sound.Name = "EmoteSound"
					sound.Volume = soundTemplate.Volume
					sound.Parent = root
					pcall(function()
						ContentProvider:PreloadAsync({sound})
					end)

					sound:Play()
					print("Playing", emoteName, sound.IsPlaying, sound.TimeLength)
					activeSounds[player] = sound
				end
			end
		end
		
		if emotes.Modules:FindFirstChild(tostring(emoteName)) then
			require(emotes.Modules:FindFirstChild(tostring(emoteName))).Start(player)
		end
		
		return {
			AnimationId = animation.AnimationId,
			Looped = not animation:GetAttribute("NotLoop")
		}

	elseif action == "Stop" then
		fadeOutSound(player)
		
		if emotes.Modules:FindFirstChild(emoteName) then
			require(emotes.Modules:FindFirstChild(emoteName)).End(player)
		end
		
		local character = player.Character
		local data = walkSpeedData[player]

		if character and data then
			local humanoid = character:FindFirstChildOfClass("Humanoid")

			if humanoid then
				local hasToolNow = characterHasTool(character)

				if data.HadRayValue or (data.HadTool and not hasToolNow) then
					humanoid.WalkSpeed = 16
				else
					humanoid.WalkSpeed = data.OldSpeed
				end
			end
		end

		walkSpeedData[player] = nil

		return true
	end

	return nil
end

game.Players.PlayerRemoving:Connect(function(player)
	destroySound(player)
	walkSpeedData[player] = nil
end)