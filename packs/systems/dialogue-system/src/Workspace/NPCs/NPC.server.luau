local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local npc = script.Parent
local humanoid = npc:WaitForChild("Humanoid")

local prompt = npc:FindFirstChild("TalkPrompt", true)
if not prompt or not prompt:IsA("ProximityPrompt") then
	error("TalkPrompt not found in NPC")
end

local remotes = ReplicatedStorage:WaitForChild("DialogueRemotes")
local endDialogue = remotes:WaitForChild("EndDialogue")

local idleAnim = script:WaitForChild("Idle")
local talkAnim = script:WaitForChild("Talk")

local animator = humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator")
animator.Parent = humanoid

local idleTrack = animator:LoadAnimation(idleAnim)
idleTrack.Priority = Enum.AnimationPriority.Idle
idleTrack.Looped = true

local talkTrack = animator:LoadAnimation(talkAnim)
talkTrack.Priority = Enum.AnimationPriority.Action
talkTrack.Looped = true

local activePlayers = {}

local function anyActive()
	return next(activePlayers) ~= nil
end

local function playIdle()
	if talkTrack.IsPlaying then talkTrack:Stop(0.15) end
	if not idleTrack.IsPlaying then idleTrack:Play(0.15) end
end

local function playTalk()
	if idleTrack.IsPlaying then idleTrack:Stop(0.15) end
	if not talkTrack.IsPlaying then talkTrack:Play(0.15) end
end

idleTrack:Play(0.15)

prompt.Triggered:Connect(function(player)
	activePlayers[player] = true
	playTalk()
end)

endDialogue.OnServerEvent:Connect(function(player)
	if not activePlayers[player] then return end
	activePlayers[player] = nil
	if not anyActive() then
		playIdle()
	end
end)

Players.PlayerRemoving:Connect(function(player)
	if activePlayers[player] then
		activePlayers[player] = nil
		if not anyActive() then
			playIdle()
		end
	end
end)
