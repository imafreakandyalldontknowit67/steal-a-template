--[[
	HeldEggClient

	Every player's equipped egg is carried in front of them with both arms (yours and
	everyone else's). The server only says WHICH egg (Player attribute "HeldEgg", set by
	PlayerData); each client poses the arms and draws the egg locally, so it follows the
	character smoothly with no network cost and looks the same for everybody.

	  - Arms: the shoulder (and elbow) joints are turned into a carrying pose right after the
	    normal animations each frame, blended in/out so it never snaps. Works on R15 and R6.
	  - Egg: sits between the hands; animated eggs (Animation = "Angel" in Config.Eggs) keep
	    their animation.
	Settings: Config.Held.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Shared = ReplicatedStorage:WaitForChild("EggRandomizer")
local Config = require(Shared:WaitForChild("Config"))
local EggAnimations = require(Shared:WaitForChild("EggAnimations"))
local DisplayTemplates = Shared:WaitForChild("DisplayTemplates")

local HELD = Config.Held or {}
local EGG_HEIGHT = HELD.EggHeight or 1.7
local ARM_RAISE = math.rad(HELD.ArmRaise or 50)
local ELBOW_BEND = math.rad(HELD.ElbowBend or 40)
local ARM_INWARD = math.rad(HELD.ArmInward or 12)
local HOLD_LIFT = HELD.HoldLift or 0.5
local HOLD_FORWARD = HELD.HoldForward or 0.1
local BLEND_SPEED = 1 / math.max(HELD.BlendTime or 0.2, 0.01)
local VIEW_DISTANCE = HELD.ViewDistance or 250
local FACING = math.rad((Config.Display and Config.Display.FacingYaw) or 0)

local EGG_INFO = {}
for _, entry in Config.Eggs do
	EGG_INFO[entry.TemplateName] = entry
end

local folder = Instance.new("Folder")
folder.Name = "HeldEggs_Local"
folder.Parent = workspace

-- Carrying pose, written in the torso's own space (x = right, y = up, -z = forward).
-- How far the arms angle inward is tuned live per player, so the hands meet the egg's sides
-- on any avatar (wide, skinny, scaled, R6 or R15).
local ELBOW = CFrame.Angles(ELBOW_BEND, 0, 0)
local GRIP_GAIN = 0.08 -- how quickly the arms settle onto the egg

type Body = {
	character: Model,
	torso: BasePart,
	root: BasePart,
	rightHand: BasePart,
	leftHand: BasePart,
	handDrop: number, -- R6 arms have no hand part: use the bottom of the arm
	raise: number,
	rightShoulder: Motor6D,
	leftShoulder: Motor6D,
	rightElbow: Motor6D?,
	leftElbow: Motor6D?,
}

type Held = {
	player: Player,
	eggId: string?,
	model: Model?,
	parts: { BasePart },
	offsets: { CFrame }, -- each part relative to the egg's pivot
	world: { CFrame },
	rig: any?, -- egg animation (EggAnimations)
	pivotRotation: CFrame,
	centerOffset: Vector3, -- egg centre, in pivot space
	halfHeight: number,
	body: Body?,
	blend: number, -- 0 = normal arms, 1 = carrying pose
	inward: number, -- current inward angle of the arms (adapts to the avatar)
	gripWidth: number, -- distance between the hands that touches this egg's sides
	connections: { RBXScriptConnection },
}

local entries: { [Player]: Held } = {}

---------------------------------------------------------------------------
-- The character's arms
---------------------------------------------------------------------------

-- turn a rotation about the joint (in its parent part's space) into that joint's Transform
local function jointPose(motor: Motor6D, rotation: CFrame): CFrame
	local r0 = motor.C0.Rotation
	return r0:Inverse() * rotation * r0
end

local function findBody(character: Model?): Body?
	if not character then
		return nil
	end
	local root = character:FindFirstChild("HumanoidRootPart")
	local upperTorso = character:FindFirstChild("UpperTorso")
	if root and upperTorso then -- R15
		local rightShoulder = character:FindFirstChild("RightUpperArm") and character.RightUpperArm:FindFirstChild("RightShoulder")
		local leftShoulder = character:FindFirstChild("LeftUpperArm") and character.LeftUpperArm:FindFirstChild("LeftShoulder")
		local rightElbow = character:FindFirstChild("RightLowerArm") and character.RightLowerArm:FindFirstChild("RightElbow")
		local leftElbow = character:FindFirstChild("LeftLowerArm") and character.LeftLowerArm:FindFirstChild("LeftElbow")
		local rightHand = character:FindFirstChild("RightHand")
		local leftHand = character:FindFirstChild("LeftHand")
		if not (rightShoulder and leftShoulder and rightHand and leftHand) then
			return nil
		end
		return {
			character = character,
			torso = upperTorso,
			root = root,
			rightHand = rightHand,
			leftHand = leftHand,
			handDrop = 0,
			raise = ARM_RAISE,
			rightShoulder = rightShoulder,
			leftShoulder = leftShoulder,
			rightElbow = rightElbow,
			leftElbow = leftElbow,
		}
	end
	local torso = character:FindFirstChild("Torso")
	if root and torso then -- R6
		local rightShoulder = torso:FindFirstChild("Right Shoulder")
		local leftShoulder = torso:FindFirstChild("Left Shoulder")
		local rightArm = character:FindFirstChild("Right Arm")
		local leftArm = character:FindFirstChild("Left Arm")
		if not (rightShoulder and leftShoulder and rightArm and leftArm) then
			return nil
		end
		return {
			character = character,
			torso = torso,
			root = root,
			rightHand = rightArm,
			leftHand = leftArm,
			handDrop = rightArm.Size.Y / 2,
			raise = ARM_RAISE + ELBOW_BEND * 0.5, -- R6 arms are straight: lift them a bit more
			rightShoulder = rightShoulder,
			leftShoulder = leftShoulder,
		}
	end
	return nil
end

local function currentBody(entry: Held): Body?
	local character = entry.player.Character
	local body = entry.body
	if body and body.character == character and body.torso.Parent and body.rightHand.Parent and body.leftHand.Parent then
		return body
	end
	entry.body = findBody(character)
	return entry.body
end

---------------------------------------------------------------------------
-- Building the egg
---------------------------------------------------------------------------
local function clearEgg(entry: Held)
	if entry.model then
		entry.model:Destroy()
	end
	entry.model = nil
	entry.rig = nil
	entry.parts = {}
	entry.offsets = {}
	entry.world = {}
end

local function buildEgg(entry: Held, eggId: string)
	local template = DisplayTemplates:FindFirstChild(eggId)
	if not (template and template:IsA("Model")) then
		return
	end
	local model = template:Clone()
	model.Name = entry.player.Name .. "_HeldEgg"
	for _, descendant in model:GetDescendants() do
		if descendant:IsA("BasePart") then
			descendant.Anchored = true
			descendant.CanCollide = false
			descendant.CanTouch = false
			descendant.CanQuery = false -- never blocks the camera, clicks or raycasts
			descendant.Massless = true
		elseif descendant:IsA("BaseScript") then
			descendant:Destroy()
		end
	end

	-- same height for every egg, keeping proportions
	local _, rawSize = model:GetBoundingBox()
	model:ScaleTo(model:GetScale() * (EGG_HEIGHT / math.max(rawSize.Y, 0.01)))
	local pivot = model:GetPivot()
	local box, size = model:GetBoundingBox()
	entry.pivotRotation = pivot.Rotation
	entry.centerOffset = pivot:PointToObjectSpace(box.Position)
	entry.halfHeight = size.Y / 2
	-- hands hold the egg's sides (wings and rings don't count: cap at the egg's height)
	entry.gripWidth = math.clamp(math.min(size.X, size.Z), EGG_HEIGHT * 0.5, EGG_HEIGHT) + 0.25

	local info = EGG_INFO[eggId]
	if info and info.Animation then
		entry.rig = EggAnimations.create(info.Animation, model, pivot)
		if entry.rig then
			EggAnimations.revealLook(entry.rig) -- e.g. the Angel Egg's glowing halo
		end
	end
	if entry.rig then
		entry.parts = entry.rig.parts
		entry.world = entry.rig.worldCFrames
	else
		for _, descendant in model:GetDescendants() do
			if descendant:IsA("BasePart") then
				table.insert(entry.parts, descendant)
				table.insert(entry.offsets, pivot:ToObjectSpace(descendant.CFrame))
			end
		end
		entry.world = table.clone(entry.offsets)
	end
	entry.model = model
end

local function setEgg(entry: Held, eggId: string?)
	if entry.eggId == eggId and (eggId == nil or entry.model) then
		return
	end
	clearEgg(entry)
	entry.eggId = eggId
	if eggId then
		buildEgg(entry, eggId)
	end
end

---------------------------------------------------------------------------
-- Players
---------------------------------------------------------------------------
local function refresh(entry: Held)
	local eggId = entry.player:GetAttribute("HeldEgg")
	setEgg(entry, type(eggId) == "string" and eggId ~= "" and eggId or nil)
end

local function addPlayer(player: Player)
	if entries[player] then
		return
	end
	local entry: Held = {
		player = player,
		parts = {},
		offsets = {},
		world = {},
		pivotRotation = CFrame.identity,
		centerOffset = Vector3.zero,
		halfHeight = EGG_HEIGHT / 2,
		blend = 0,
		inward = ARM_INWARD,
		gripWidth = EGG_HEIGHT,
		connections = {},
	}
	entries[player] = entry
	table.insert(entry.connections, player:GetAttributeChangedSignal("HeldEgg"):Connect(function()
		refresh(entry)
	end))
	table.insert(entry.connections, player.CharacterAdded:Connect(function()
		entry.body = nil
		entry.blend = 0
		entry.inward = ARM_INWARD
	end))
	refresh(entry)
end

local function removePlayer(player: Player)
	local entry = entries[player]
	if not entry then
		return
	end
	entries[player] = nil
	for _, connection in entry.connections do
		connection:Disconnect()
	end
	clearEgg(entry)
end

for _, player in Players:GetPlayers() do
	task.spawn(addPlayer, player)
end
Players.PlayerAdded:Connect(addPlayer)
Players.PlayerRemoving:Connect(removePlayer)

---------------------------------------------------------------------------
-- Arms: right after the normal animations each frame, blend toward the carrying pose
---------------------------------------------------------------------------
local function handPoint(hand: BasePart, drop: number): Vector3
	return if drop > 0 then hand.CFrame * Vector3.new(0, -drop, 0) else hand.Position
end

RunService.PreSimulation:Connect(function(dt)
	for _, entry in entries do
		local target = entry.model and 1 or 0
		if entry.blend == 0 and target == 0 then
			continue
		end
		local body = currentBody(entry)
		if not body then
			entry.blend = 0
			continue
		end
		if target > entry.blend then
			entry.blend = math.min(target, entry.blend + dt * BLEND_SPEED)
		else
			entry.blend = math.max(target, entry.blend - dt * BLEND_SPEED)
		end
		-- settle the hands onto the egg's sides: compare where they are with where they should be
		if entry.model and entry.blend >= 1 then
			local torsoCFrame = body.torso.CFrame
			local right = torsoCFrame:PointToObjectSpace(handPoint(body.rightHand, body.handDrop))
			local left = torsoCFrame:PointToObjectSpace(handPoint(body.leftHand, body.handDrop))
			local error = (right.X - left.X) - entry.gripWidth
			entry.inward = math.clamp(entry.inward + error * GRIP_GAIN, -0.3, 1.1)
		end

		local alpha = entry.blend * entry.blend * (3 - 2 * entry.blend) -- smoothstep
		local raise = CFrame.Angles(body.raise, 0, 0)
		local function apply(motor: Motor6D?, rotation: CFrame)
			if motor then
				motor.Transform = motor.Transform:Lerp(jointPose(motor, rotation), alpha)
			end
		end
		apply(body.rightShoulder, CFrame.Angles(0, entry.inward, 0) * raise)
		apply(body.leftShoulder, CFrame.Angles(0, -entry.inward, 0) * raise)
		apply(body.rightElbow, ELBOW)
		apply(body.leftElbow, ELBOW)
	end
end)

---------------------------------------------------------------------------
-- Egg: every frame, put it between its owner's hands
---------------------------------------------------------------------------
RunService.RenderStepped:Connect(function()
	local now = os.clock()
	local camera = workspace.CurrentCamera
	local cameraPosition = camera and camera.CFrame.Position or Vector3.zero
	for _, entry in entries do
		local model = entry.model
		if not model then
			continue
		end
		local body = entry.body
		if not body or entry.blend < 0.6 or not body.root.Parent
			or (body.root.Position - cameraPosition).Magnitude > VIEW_DISTANCE
		then
			model.Parent = nil -- appears once the arms are up
			continue
		end

		local torsoCFrame = body.torso.CFrame
		local hands = (handPoint(body.rightHand, body.handDrop) + handPoint(body.leftHand, body.handDrop)) / 2
		local center = hands
			+ torsoCFrame.UpVector * (entry.halfHeight * HOLD_LIFT)
			+ torsoCFrame.LookVector * HOLD_FORWARD
		local look = body.root.CFrame.LookVector
		local yaw = math.atan2(-look.X, -look.Z) + FACING
		local pivotTarget = CFrame.new(center) * CFrame.Angles(0, yaw, 0) * entry.pivotRotation * CFrame.new(-entry.centerOffset)

		local world = entry.world
		local rig = entry.rig
		if rig then
			EggAnimations.pose(rig, now, true)
			local localCFrames = rig.localCFrames
			for i = 1, #localCFrames do
				world[i] = pivotTarget * localCFrames[i]
			end
		else
			local offsets = entry.offsets
			for i = 1, #offsets do
				world[i] = pivotTarget * offsets[i]
			end
		end
		if model.Parent ~= folder then
			model.Parent = folder -- same frame as the move below, so it never flashes in the wrong place
		end
		workspace:BulkMoveTo(entry.parts, world, Enum.BulkMoveMode.FireCFrameChanged)
	end
end)
