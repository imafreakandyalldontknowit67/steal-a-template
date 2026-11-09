local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContentProvider = game:GetService("ContentProvider")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local getEmote = ReplicatedStorage.Functions.GetEmote

local State = require(ReplicatedStorage.Shared.EmoteState)

local function stopEmote(track)
	getEmote:InvokeServer("Stop", player.Emotes[script.Parent.Name].Value)

	if track and track.IsPlaying then
		track:Stop(0.15)
	end

	if State.CurrentTrack == track then
		State.CurrentTrack = nil
	end

	State.DisconnectAll()
end

script.Parent.MouseButton1Click:Connect(function()

	-- Stop whatever emote is currently active
	stopEmote(State.CurrentTrack)

	if player.Emotes[script.Parent.Name].Value == "None" then
		return
	end

	script.Parent.Parent.Visible = false

	local character = player.Character
	if not character then
		return
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
	local root = character:FindFirstChild("HumanoidRootPart")

	if not (humanoid and animator and root) then
		return
	end

	local data = getEmote:InvokeServer("Get", player.Emotes[script.Parent.Name].Value)
	if not data then
		return
	end

	for _, playingTrack in ipairs(animator:GetPlayingAnimationTracks()) do
		if playingTrack.Priority == Enum.AnimationPriority.Action2 then
			playingTrack:Stop()
		end
	end

	local animation = Instance.new("Animation")
	animation.AnimationId = data.AnimationId

	ContentProvider:PreloadAsync({animation})

	local track = animator:LoadAnimation(animation)
	track.Priority = Enum.AnimationPriority.Action2
	track.Looped = data.Looped ~= false
	track:Play()

	State.CurrentTrack = track

	table.insert(State.Connections, animator.AnimationPlayed:Connect(function(newTrack)
		if newTrack == State.CurrentTrack then
			return
		end

		local priority = newTrack.Priority

		if priority == Enum.AnimationPriority.Action
			or priority == Enum.AnimationPriority.Action3
			or priority == Enum.AnimationPriority.Action4 then

			if State.CurrentTrack == track then
				stopEmote(track)
			end
		end
	end))

	table.insert(State.Connections, humanoid.StateChanged:Connect(function(_, newState)
		if newState == Enum.HumanoidStateType.Jumping then
			if State.CurrentTrack == track then
				stopEmote(track)
			end
		end
	end))

	table.insert(State.Connections, character.ChildAdded:Connect(function(child)
		if child:IsA("Tool") then
			if State.CurrentTrack == track then
				stopEmote(track)
			end
		end
	end))

	table.insert(State.Connections, track.Stopped:Connect(function()
		if State.CurrentTrack == track then
			stopEmote(track)
		end
	end))

	table.insert(State.Connections, UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then
			return
		end

		if input.KeyCode == Enum.KeyCode.F then
			if State.CurrentTrack == track then
				stopEmote(track)
			end
		end
	end))
end)