local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local emoteValues = player:WaitForChild("Emotes")

local viewport = script.Parent:WaitForChild("EmoteViewPort")
local worldModel = viewport:WaitForChild("WorldModel")
local humanoid = worldModel.Anim:WaitForChild("Humanoid")
local animator = humanoid:WaitForChild("Animator")

local emoteValue = emoteValues:WaitForChild(script.Parent.Name)

local currentTrack
local currentAnimation

local function stopCurrentAnimation()
	if currentTrack then
		currentTrack:Stop(0)
		currentTrack = nil
	end

	currentAnimation = nil
end

local function updateAnimation()

	local emoteName = emoteValue.Value

	print("Updating to:", emoteName)

	stopCurrentAnimation()

	script.Parent.EmoteName.Text = emoteName

	if emoteName == "" or emoteName == "None" then
		return
	end

	local animationId = ReplicatedStorage.Functions.GetEmote:InvokeServer("DummyGet", emoteName)

	print("Animation ID:", animationId)

	if not animationId or animationId == "" then
		return
	end

	currentAnimation = Instance.new("Animation")
	currentAnimation.AnimationId = animationId

	currentTrack = animator:LoadAnimation(currentAnimation)
	currentTrack.Priority = Enum.AnimationPriority.Action
	currentTrack.Looped = true
	currentTrack:Play(0)
end

updateAnimation()

emoteValue:GetPropertyChangedSignal("Value"):Connect(function()
	task.wait()
	updateAnimation()
end)