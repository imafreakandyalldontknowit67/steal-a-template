--[[
	EggRandomizerClient

	Draws every Egg Randomizer machine for this player: the lever pull, the black egg
	shuffle, the slow-down and the reveal. It runs on each client so the spin is smooth at
	the player's frame rate. It never decides anything: the eggs it lands on are the
	server's results, read from the machine's attributes (see EggRandomizerServer).

	Display eggs are clones of ReplicatedStorage.EggRandomizer.DisplayTemplates (copies of
	ServerStorage.EggModels). Each slot keeps ONE pooled clone per egg type and reuses it,
	so nothing is created during a shuffle.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Shared = ReplicatedStorage:WaitForChild("EggRandomizer")
local Config = require(Shared:WaitForChild("Config"))
local EggAppearance = require(Shared:WaitForChild("EggAppearance"))
local ShuffleTimeline = require(Shared:WaitForChild("ShuffleTimeline"))
local EggAnimations = require(Shared:WaitForChild("EggAnimations"))
local DisplayTemplates = Shared:WaitForChild("DisplayTemplates")

local LOG_PREFIX = "[EggRandomizer]"
local SPARKLE_TEXTURE = "rbxasset://textures/particles/sparkles_main.dds"

---------------------------------------------------------------------------
-- Egg info (only eggs whose model actually exists take part in the shuffle)
---------------------------------------------------------------------------
local EGG_INFO = {} -- [TemplateName] = Config.Eggs entry
local EGG_IDS = {} -- shuffle pool, in Config order
local totalWeight = 0
for _, entry in Config.Eggs do
	if DisplayTemplates:FindFirstChild(entry.TemplateName) then
		EGG_INFO[entry.TemplateName] = entry
		table.insert(EGG_IDS, entry.TemplateName)
		totalWeight += math.max(tonumber(entry.Weight) or 1, 0)
	end
end
if #EGG_IDS == 0 then
	warn(LOG_PREFIX, "No egg display templates found - nothing to draw.")
	return
end

local function subtitleFor(eggId: string): string
	local info = EGG_INFO[eggId]
	if info and info.Rarity then
		return info.Rarity
	end
	local percent = totalWeight > 0 and (math.max(tonumber(info and info.Weight) or 1, 0) / totalWeight * 100) or 0
	if math.abs(percent - math.round(percent)) < 0.05 then
		return string.format("%d%% chance", math.round(percent))
	end
	return string.format("%.1f%% chance", percent)
end

local function accentFor(eggId: string): Color3
	local info = EGG_INFO[eggId]
	return (info and info.AccentColor) or Color3.new(1, 1, 1)
end

---------------------------------------------------------------------------
-- Small helpers
---------------------------------------------------------------------------
local function lerp(a: number, b: number, t: number): number
	return a + (b - a) * t
end

local function easeOutQuad(t: number): number
	return 1 - (1 - t) * (1 - t)
end

local function newLocalPart(name: string, parent: Instance): Part
	local part = Instance.new("Part")
	part.Name = name
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.CastShadow = false
	part.Transparency = 1
	part.Size = Vector3.new(1, 1, 1)
	part.Parent = parent
	return part
end

local function newCircleGui(part: BasePart, name: string): (Frame, UIStroke)
	local gui = Instance.new("SurfaceGui")
	gui.Name = name
	gui.Face = Enum.NormalId.Top
	gui.SizingMode = Enum.SurfaceGuiSizingMode.FixedSize
	gui.CanvasSize = Vector2.new(256, 256)
	gui.LightInfluence = 0
	gui.Parent = part

	local circle = Instance.new("Frame")
	circle.AnchorPoint = Vector2.new(0.5, 0.5)
	circle.Position = UDim2.fromScale(0.5, 0.5)
	circle.Size = UDim2.fromScale(0.9, 0.9)
	circle.BackgroundTransparency = 1
	circle.Parent = gui
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0.5, 0)
	corner.Parent = circle
	local stroke = Instance.new("UIStroke")
	stroke.Thickness = 10
	stroke.Transparency = 1
	stroke.Parent = circle
	return circle, stroke
end

local function makeSound(soundConfig, parent: Instance): Sound?
	if not soundConfig or not soundConfig.Id or soundConfig.Id == "" then
		return nil
	end
	local sound = Instance.new("Sound")
	sound.SoundId = soundConfig.Id
	sound.Volume = soundConfig.Volume or 0.5
	sound.RollOffMaxDistance = 80
	sound.Parent = parent
	return sound
end

local function playSound(sound: Sound?, pitch: number?)
	if sound then
		sound.PlaybackSpeed = pitch or 1
		sound.TimePosition = 0
		sound:Play()
	end
end

local function parseResults(value: any): { string }?
	if type(value) ~= "string" or value == "" then
		return nil
	end
	return string.split(value, ",")
end

---------------------------------------------------------------------------
-- Display eggs (pooled clones)
---------------------------------------------------------------------------
type EggEntry = {
	id: string,
	model: Model,
	snapshot: EggAppearance.Snapshot,
	baseScale: number,
	scaleFactor: number,
	pivotHeight: number,
	pivotRotation: CFrame,
	rig: any?, -- optional built-in animation (see EggAnimations)
}

-- Get (or create once) this slot's clone of an egg. New clones are made black BEFORE
-- they are ever parented, so their real colours can never flash on screen.
local function getEgg(slot, eggId: string): EggEntry?
	local existing = slot.pool[eggId]
	if existing then
		return existing
	end
	local template = DisplayTemplates:FindFirstChild(eggId)
	if not (template and template:IsA("Model")) then
		return nil
	end

	local model = template:Clone()
	model.Name = eggId .. "_Display"
	for _, descendant in model:GetDescendants() do
		if descendant:IsA("BasePart") then
			-- protect the display egg from physics, falling and collisions
			descendant.Anchored = true
			descendant.CanCollide = false
			descendant.CanTouch = false
			descendant.CanQuery = false
			descendant.Massless = true
		elseif descendant:IsA("BaseScript") then
			descendant:Destroy()
		end
	end

	-- Fit every egg to the same height (clone only), keeping its proportions.
	local _, rawSize = model:GetBoundingBox()
	local baseScale = model:GetScale() * (Config.Display.EggHeight / math.max(rawSize.Y, 0.01))
	model:ScaleTo(baseScale)

	local pivot = model:GetPivot()
	local boxCFrame, boxSize = model:GetBoundingBox()
	local bottomY = boxCFrame.Position.Y - boxSize.Y / 2

	local entry: EggEntry = {
		id = eggId,
		model = model,
		snapshot = EggAppearance.capture(model), -- original look, recorded from the fresh clone
		baseScale = baseScale,
		scaleFactor = 1,
		pivotHeight = pivot.Position.Y - bottomY,
		pivotRotation = pivot.Rotation,
	}
	EggAppearance.applyBlack(entry.snapshot, Config.Blackout.Color, Config.Blackout.Material)
	-- Optional built-in animation (e.g. Animation = "Angel" in Config.Eggs). Built after the
	-- snapshot so its glow/sparkle helpers are switched by the animation, not the blackout.
	local info = EGG_INFO[eggId]
	if info and info.Animation then
		entry.rig = EggAnimations.create(info.Animation, model, pivot)
	end
	slot.pool[eggId] = entry
	return entry
end

-- Position (and optionally pop-scale) an egg; parents it into the world if needed.
-- Animated eggs (entry.rig) get every part placed around the egg's current pivot, so their
-- own animation (wings etc.) rides along with the spin, bob and pop.
local function placeEgg(slot, entry: EggEntry?, angle: number, scaleFactor: number, lift: number)
	if not entry then
		return
	end
	if math.abs(entry.scaleFactor - scaleFactor) > 1e-4 then
		entry.model:ScaleTo(entry.baseScale * scaleFactor)
		entry.scaleFactor = scaleFactor
	end
	if entry.model.Parent ~= slot.eggFolder then
		entry.model.Parent = slot.eggFolder -- same frame as the move below, so nothing renders in between
	end
	local target = slot.baseCFrame
		* CFrame.Angles(0, angle, 0)
		* CFrame.new(0, entry.pivotHeight * scaleFactor + lift, 0)
		* entry.pivotRotation
	local rig = entry.rig
	if rig then
		EggAnimations.pose(rig, os.clock(), not entry.snapshot.isBlack)
		local localCFrames, worldCFrames = rig.localCFrames, rig.worldCFrames
		for i = 1, #localCFrames do
			local localCFrame = localCFrames[i]
			worldCFrames[i] = target * (CFrame.new(localCFrame.Position * scaleFactor) * localCFrame.Rotation)
		end
		workspace:BulkMoveTo(rig.parts, worldCFrames, Enum.BulkMoveMode.FireCFrameChanged)
		if not entry.model.PrimaryPart then
			entry.model.WorldPivot = target
		end
	else
		entry.model:PivotTo(target)
	end
end

-- Make `eggId` the slot's visible egg. black = true while shuffling, false when revealed.
-- The appearance is set BEFORE the egg is placed in the world.
local function setShownEgg(slot, eggId: string, black: boolean): EggEntry?
	local entry = getEgg(slot, eggId)
	if not entry then
		return nil
	end
	if slot.shown and slot.shown ~= entry then
		slot.shown.model.Parent = nil -- hide the previous egg (kept in the pool for reuse)
	end
	if black and not entry.snapshot.isBlack then
		EggAppearance.applyBlack(entry.snapshot, Config.Blackout.Color, Config.Blackout.Material)
	elseif not black and entry.snapshot.isBlack then
		EggAppearance.restore(entry.snapshot)
		if entry.rig then
			EggAnimations.revealLook(entry.rig) -- e.g. the Angel Egg's glowing halo
		end
	end
	slot.shown = entry
	return entry
end

local function hideShownEgg(slot)
	if slot.shown then
		slot.shown.model.Parent = nil
		slot.shown = nil
	end
end

---------------------------------------------------------------------------
-- Per-slot effects (created once per slot, reused for every roll)
---------------------------------------------------------------------------
local function createSlotEffects(slot, folder: Folder)
	local anchor: BasePart = slot.anchor
	local glowTop = slot.model:FindFirstChild("GlowTop")
	local surfaceY = glowTop and (glowTop.Position.Y + glowTop.Size.Y / 2) or (anchor.Position.Y - anchor.Size.Y / 2)
	local surfaceCFrame = anchor.CFrame.Rotation + Vector3.new(anchor.Position.X, surfaceY, anchor.Position.Z)
	slot.glowTop = glowTop
	slot.glowColor = glowTop and glowTop.Color

	-- Ring on the pedestal: dark disc while shuffling, coloured ring once revealed.
	local ringPart = newLocalPart("SlotRing", folder)
	ringPart.Size = Vector3.new(3.1, 0.02, 3.1)
	ringPart.CFrame = surfaceCFrame * CFrame.new(0, 0.02, 0)
	local ringCircle, ringStroke = newCircleGui(ringPart, "Ring")
	slot.ringCircle = ringCircle
	slot.ringStroke = ringStroke

	-- Shock-wave ring that expands outward on reveal.
	local wavePart = newLocalPart("RevealWave", folder)
	wavePart.Size = Vector3.new(2.5, 0.02, 2.5)
	wavePart.CFrame = surfaceCFrame * CFrame.new(0, 0.05, 0)
	local _, waveStroke = newCircleGui(wavePart, "Wave")
	waveStroke.Thickness = 8
	slot.wavePart = wavePart
	slot.waveStroke = waveStroke

	-- Light beam shooting up from the pedestal on reveal.
	local beam = newLocalPart("RevealBeam", folder)
	beam.Shape = Enum.PartType.Cylinder
	beam.Material = Enum.Material.Neon
	beam.Size = Vector3.new(14, 0.8, 0.8)
	beam.CFrame = surfaceCFrame * CFrame.new(0, 7, 0) * CFrame.Angles(0, 0, math.rad(90))
	slot.beam = beam

	-- Flash light + sparkle burst at the egg's centre.
	local center = newLocalPart("RevealCenter", folder)
	center.Size = Vector3.new(0.2, 0.2, 0.2)
	center.CFrame = slot.baseCFrame * CFrame.new(0, Config.Display.EggHeight / 2, 0)
	local light = Instance.new("PointLight")
	light.Brightness = 0
	light.Range = 14
	light.Parent = center
	slot.light = light
	local sparkles = Instance.new("ParticleEmitter")
	sparkles.Texture = SPARKLE_TEXTURE
	sparkles.Enabled = false
	sparkles.LightEmission = 1
	sparkles.Lifetime = NumberRange.new(0.5, 0.9)
	sparkles.Speed = NumberRange.new(7, 12)
	sparkles.SpreadAngle = Vector2.new(180, 180)
	sparkles.Acceleration = Vector3.new(0, -10, 0)
	sparkles.Drag = 2
	sparkles.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.6),
		NumberSequenceKeypoint.new(1, 0),
	})
	sparkles.Rotation = NumberRange.new(0, 360)
	sparkles.RotSpeed = NumberRange.new(-180, 180)
	sparkles.Parent = center
	slot.sparkles = sparkles
	slot.revealSound = makeSound(Config.Sounds.Reveal, center)
	slot.popSound = makeSound(Config.Sounds.RevealPop, center)
	-- a few copies of the tick so rapid ticks overlap instead of cutting each other off
	slot.tickSounds = {}
	slot.nextTick = 1
	for _ = 1, 5 do
		local tickSound = makeSound(Config.Sounds.Tick, center)
		if tickSound then
			table.insert(slot.tickSounds, tickSound)
		end
	end

	-- Name label above the egg.
	local labelPart = newLocalPart("LabelAnchor", folder)
	labelPart.Size = Vector3.new(0.2, 0.2, 0.2)
	labelPart.CFrame = slot.baseCFrame * CFrame.new(0, Config.Display.EggHeight + Config.Display.LabelHeight, 0)
	local billboard = Instance.new("BillboardGui")
	billboard.Name = "EggLabel"
	billboard.Size = UDim2.fromScale(7, 2.2) -- studs
	billboard.LightInfluence = 0
	billboard.MaxDistance = 90
	billboard.Enabled = false
	billboard.Parent = labelPart
	local holder = Instance.new("Frame")
	holder.BackgroundTransparency = 1
	holder.Size = UDim2.fromScale(1, 1)
	holder.Parent = billboard
	local scale = Instance.new("UIScale")
	scale.Parent = holder
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Name = "EggName"
	nameLabel.BackgroundTransparency = 1
	nameLabel.Size = UDim2.fromScale(1, 0.58)
	nameLabel.Font = Enum.Font.GothamBlack -- Check-UI: GothamBlack + black outline
	nameLabel.TextScaled = true
	nameLabel.TextColor3 = Color3.new(1, 1, 1)
	nameLabel.Parent = holder
	local nameStroke = Instance.new("UIStroke")
	nameStroke.Thickness = 3
	nameStroke.Color = Color3.new(0, 0, 0)
	nameStroke.LineJoinMode = Enum.LineJoinMode.Round
	nameStroke.Parent = nameLabel
	local subLabel = Instance.new("TextLabel")
	subLabel.Name = "Subtitle"
	subLabel.BackgroundTransparency = 1
	subLabel.Position = UDim2.fromScale(0, 0.58)
	subLabel.Size = UDim2.fromScale(1, 0.42)
	subLabel.Font = Enum.Font.GothamBlack
	subLabel.TextScaled = true
	subLabel.Parent = holder
	local subStroke = Instance.new("UIStroke")
	subStroke.Thickness = 2.5
	subStroke.Color = Color3.new(0, 0, 0)
	subStroke.LineJoinMode = Enum.LineJoinMode.Round
	subStroke.Parent = subLabel
	slot.label = billboard
	slot.labelScale = scale
	slot.nameLabel = nameLabel
	slot.subLabel = subLabel
end

local function setRingMode(slot, mode: string, color: Color3?)
	if mode == "shuffle" then
		slot.ringCircle.BackgroundColor3 = Color3.new(0, 0, 0)
		slot.ringCircle.BackgroundTransparency = 0.45
		slot.ringStroke.Transparency = 1
	elseif mode == "reveal" then
		slot.ringCircle.BackgroundColor3 = color or Color3.new(1, 1, 1)
		slot.ringCircle.BackgroundTransparency = 0.75
		slot.ringStroke.Color = color or Color3.new(1, 1, 1)
		slot.ringStroke.Transparency = 0
	else
		slot.ringCircle.BackgroundTransparency = 1
		slot.ringStroke.Transparency = 1
	end
end

local function setLabel(slot, eggId: string?, animate: boolean)
	if not (Config.Reveal.ShowNameLabel and eggId) then
		slot.label.Enabled = false
		return
	end
	local info = EGG_INFO[eggId]
	slot.nameLabel.Text = (info and info.DisplayName) or eggId
	slot.subLabel.Text = subtitleFor(eggId)
	slot.subLabel.TextColor3 = accentFor(eggId)
	slot.label.Enabled = true
	if animate then
		slot.labelScale.Scale = 0
		TweenService:Create(slot.labelScale, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 }):Play()
	else
		slot.labelScale.Scale = 1
	end
end

---------------------------------------------------------------------------
-- MM2-style tick: one tick per egg swap, from that slot's pedestal
---------------------------------------------------------------------------
local function playTick(view, slot)
	local sounds = slot.tickSounds
	if not sounds or #sounds == 0 then
		return
	end
	local tickConfig = Config.Sounds.Tick
	local now = os.clock()
	if now - view.lastTick < (tickConfig.MinGap or 0.04) then
		return -- both slots ticking at the same instant: keep it one crisp tick
	end
	view.lastTick = now
	local sound = sounds[slot.nextTick]
	slot.nextTick = slot.nextTick % #sounds + 1
	local variation = tickConfig.PitchVariation or 0
	playSound(sound, (tickConfig.Pitch or 1) + (math.random() * 2 - 1) * variation)
end

-- Optional one-shot spinning recording (Config.Sounds.SpinClip): plays once per roll.
local function startSpinClip(view)
	if view.clipStarted or not view.spinClip then
		return
	end
	view.clipStarted = true
	if view.clipFade then
		view.clipFade:Cancel()
		view.clipFade = nil
	end
	view.spinClip.Volume = Config.Sounds.SpinClip.Volume or 0.7
	view.spinClip.TimePosition = 0
	view.spinClip:Play()
end

local function stopSpinClip(view)
	local clip = view.spinClip
	if not (clip and clip.IsPlaying) then
		return
	end
	local fade = TweenService:Create(clip, TweenInfo.new(0.15), { Volume = 0 })
	view.clipFade = fade
	fade.Completed:Connect(function(state)
		if state == Enum.PlaybackState.Completed then
			clip:Stop()
		end
	end)
	fade:Play()
end

local function playRevealEffects(slot, eggId: string)
	local accent = accentFor(eggId)
	local duration = Config.Reveal.EffectsTime
	playSound(slot.popSound, 1 + (slot.index - 1) * 0.08)
	setRingMode(slot, "reveal", accent)

	slot.wavePart.Size = Vector3.new(2.5, 0.02, 2.5)
	slot.waveStroke.Color = accent
	slot.waveStroke.Transparency = 0
	TweenService:Create(slot.wavePart, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = Vector3.new(11, 0.02, 11) }):Play()
	TweenService:Create(slot.waveStroke, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Transparency = 1 }):Play()

	slot.beam.Color = accent:Lerp(Color3.new(1, 1, 1), 0.55)
	slot.beam.Size = Vector3.new(14, 0.9, 0.9)
	slot.beam.Transparency = 0.15
	TweenService:Create(slot.beam, TweenInfo.new(duration * 0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
		Transparency = 1,
		Size = Vector3.new(14, 0.1, 0.1),
	}):Play()

	slot.light.Color = accent
	slot.light.Brightness = 8
	TweenService:Create(slot.light, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Brightness = 0 }):Play()

	if slot.glowTop then
		slot.glowTop.Color = Color3.new(1, 1, 1)
		TweenService:Create(slot.glowTop, TweenInfo.new(duration * 0.6), { Color = slot.glowColor }):Play()
	end

	slot.sparkles.Color = ColorSequence.new(accent:Lerp(Color3.new(1, 1, 1), 0.4), accent)
	slot.sparkles:Emit(26)
	playSound(slot.revealSound, 0.95 + slot.index * 0.05)
	setLabel(slot, eggId, true)
end

---------------------------------------------------------------------------
-- Machine views
---------------------------------------------------------------------------
local localRoot = Instance.new("Folder")
localRoot.Name = "EggRandomizer_LocalDisplay"
localRoot.Parent = workspace

local views = {} -- [machine Model] = view

local function stopRender(view)
	if view.renderConnection then
		view.renderConnection:Disconnect()
		view.renderConnection = nil
	end
end

---------------------------------------------------------------------------
-- Idle: after the reveal, the egg keeps turning slowly on its pedestal
---------------------------------------------------------------------------
local function startIdle(slot, instant: boolean?)
	slot.idle = true
	slot.angle = 0
	-- instant = already at full speed (late joiners); otherwise ease in from a standstill
	slot.idleStart = os.clock() - (instant and (Config.Display.IdleRampTime or 0) or 0)
end

local function idleStep(slot, now: number, dt: number)
	local display = Config.Display
	local alive = now - slot.idleStart
	local ramp = math.clamp(alive / math.max(display.IdleRampTime or 0, 1e-3), 0, 1)
	ramp = ramp * ramp * (3 - 2 * ramp) -- smoothstep: no sudden start
	slot.angle = (slot.angle + math.rad(display.IdleSpinSpeed or 0) * ramp * dt) % (2 * math.pi)
	local bob = (display.IdleBobHeight or 0) * math.sin(alive * (display.IdleBobSpeed or 0) * 2 * math.pi) * ramp
	placeEgg(slot, slot.shown, slot.angle, 1, bob)
end

-- Bought eggs spin up, shrink and pop off the pedestal (they went to the buyer's inventory).
local COLLECT_TIME = 0.45
local function collectStep(slot, now: number)
	local progress = (now - slot.collectStart) / COLLECT_TIME
	if progress >= 1 or not slot.shown then
		slot.collectStart = nil
		hideShownEgg(slot)
		return
	end
	local shrink = math.max(1 - progress * progress, 0.02)
	placeEgg(slot, slot.shown, (slot.angle or 0) + progress * math.pi * 3, shrink, progress * 2.2)
end

local function onBoughtChanged(view)
	local bought = view.machine:GetAttribute("Bought") or ""
	local previous = view.lastBought or ""
	view.lastBought = bought
	if view.roll then
		return -- a roll is playing; it replaces the eggs anyway
	end
	for index, slot in view.slots do
		if bought:sub(index, index) == "1" and previous:sub(index, index) ~= "1" and slot.shown then
			slot.idle = false
			slot.collectStart = os.clock()
			setLabel(slot, nil, false)
			setRingMode(slot, "off")
			slot.sparkles.Color = ColorSequence.new(accentFor(slot.shown.id))
			slot.sparkles:Emit(20)
			playSound(slot.popSound, 1.35)
		end
	end
end

-- Snap every slot straight to its revealed egg (late join, after errors, or no roll in progress).
local function showFinal(view, results: { string })
	view.roll = nil
	stopSpinClip(view)
	local bought = view.machine:GetAttribute("Bought") or ""
	for index, slot in view.slots do
		local eggId = results[index]
		slot.collectStart = nil
		if eggId and EGG_INFO[eggId] and bought:sub(index, index) ~= "1" then
			placeEgg(slot, setShownEgg(slot, eggId, false), 0, 1, 0)
			setRingMode(slot, "reveal", accentFor(eggId))
			setLabel(slot, eggId, false)
			startIdle(slot, true)
		else
			hideShownEgg(slot)
			slot.idle = false
			setRingMode(slot, "off")
			setLabel(slot, nil, false)
		end
	end
end

local function playLever(view)
	if not view.arm then
		return
	end
	view.leverToken += 1
	local token = view.leverToken
	if view.leverTween then
		view.leverTween:Cancel()
	end
	local lever = Config.Lever
	local down = TweenService:Create(view.leverAngle, TweenInfo.new(lever.PullTime, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Value = lever.PullAngle })
	view.leverTween = down
	down.Completed:Connect(function(state)
		if state ~= Enum.PlaybackState.Completed then
			return
		end
		task.delay(lever.HoldTime, function()
			if view.leverToken ~= token or view.destroyed then
				return
			end
			local up = TweenService:Create(view.leverAngle, TweenInfo.new(lever.ReturnTime, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Value = 0 })
			view.leverTween = up
			up:Play()
		end)
	end)
	down:Play()
	playSound(view.leverSound)
end

-- One frame of a roll. `t` = seconds since the shuffle started.
local function stepRoll(view, timelines, t: number)
	local shuffle = Config.Shuffle
	local reveal = Config.Reveal
	local allDone = true

	for index, slot in view.slots do
		local timeline = timelines[index]
		if t < 0 then
			allDone = false -- lever still going down; previous result stays on show
		elseif t < timeline.stopTime then
			allDone = false
			startSpinClip(view) -- no-op unless Config.Sounds.SpinClip is set
			if not slot.shuffling then
				-- this slot starts shuffling now: carry on from the angle it was idling at
				slot.shuffling = true
				slot.idle = false
				slot.spinFrom = slot.angle or 0
			end
			-- advance to the egg that should be showing now
			local swapIndex = slot.swapIndex or 0
			local newIndex = math.max(swapIndex, 1)
			while newIndex < #timeline.swapTimes and t >= timeline.swapTimes[newIndex + 1] do
				newIndex += 1
			end
			if newIndex ~= swapIndex then
				slot.swapIndex = newIndex
				slot.swapStart = timeline.swapTimes[newIndex]
				setShownEgg(slot, timeline.sequence[newIndex], true) -- always black while shuffling
				playTick(view, slot) -- MM2-style tick on every swap
			end
			-- smooth spin + bob, and a quick pop when a new egg appears
			local sinceSwap = t - slot.swapStart
			local pop = 1
			if sinceSwap < shuffle.SwapPopTime then
				pop = lerp(shuffle.SwapPopScale, 1, easeOutQuad(sinceSwap / shuffle.SwapPopTime))
			end
			local fade = 1 - t / timeline.stopTime
			local bob = shuffle.BobHeight * math.sin(t * math.pi * 2.8) * fade
			-- spin eases out so it lands exactly facing the front, starting from the idle angle
			local fullTurns = timeline.totalTurns * 2 * math.pi
			local eased = ShuffleTimeline.spinAngle(timeline, t) / fullTurns
			slot.angle = slot.spinFrom + (fullTurns - slot.spinFrom % (2 * math.pi)) * eased
			placeEgg(slot, slot.shown, slot.angle, pop, bob)
		else
			if not slot.revealStarted then
				slot.revealStarted = true
				slot.shuffling = false
				slot.angle = 0
				local finalEgg = timeline.sequence[#timeline.sequence]
				local entry = setShownEgg(slot, finalEgg, false) -- restore the real colours
				placeEgg(slot, entry, 0, 1, 0)
				playRevealEffects(slot, finalEgg)
				if index == #view.slots then
					stopSpinClip(view) -- last egg landed: end the spinning recording
				end
			end
			local sinceStop = t - timeline.stopTime
			if sinceStop < reveal.PopTime then
				allDone = false
				local bump = math.sin(math.pi * sinceStop / reveal.PopTime)
				placeEgg(slot, slot.shown, 0, 1 + (reveal.PopScale - 1) * bump, reveal.HopHeight * bump)
			elseif not slot.settled then
				slot.settled = true
				startIdle(slot) -- keeps turning slowly from here (Config.Display.IdleSpinSpeed)
			end
		end
	end

	if allDone then
		view.roll = nil
	end
end

local function playRoll(view, results: { string }, seed: number, startServerTime: number)
	view.clipStarted = false

	local elapsed = workspace:GetServerTimeNow() - startServerTime
	if elapsed < 0.35 then
		playLever(view)
	end

	local timelines = {}
	for index, slot in view.slots do
		local finalEgg = results[index]
		if not (finalEgg and EGG_INFO[finalEgg]) then
			warn(LOG_PREFIX, "Unknown result for slot", index, finalEgg)
			finalEgg = EGG_IDS[1]
		end
		timelines[index] = ShuffleTimeline.build(Config, EGG_IDS, finalEgg, index, seed)
		slot.swapIndex = nil
		slot.swapStart = 0
		slot.revealStarted = false
		slot.settled = false
		slot.shuffling = false
		slot.collectStart = nil
		setLabel(slot, nil, false)
		setRingMode(slot, "shuffle")
	end

	-- Picked up by updateView every frame. Uses a local monotonic clock aligned to the
	-- server's start time (smooth, no network jitter).
	view.roll = { timelines = timelines, results = results, clockStart = os.clock() - elapsed }
end

local function isNearCamera(view): boolean
	local camera = workspace.CurrentCamera
	if not camera then
		return true
	end
	return (camera.CFrame.Position - view.center).Magnitude <= (Config.Display.AnimateDistance or 150)
end

-- Runs every frame for each machine: the roll (if one is playing) and the idle spin.
local function updateView(view)
	local now = os.clock()
	local dt = math.min(now - (view.lastFrame or now), 0.1)
	view.lastFrame = now

	local roll = view.roll
	if roll then
		stepRoll(view, roll.timelines, now - roll.clockStart - Config.Shuffle.StartDelay)
	end
	-- revealed eggs keep turning (paused while your camera is far away, to save performance)
	local near = isNearCamera(view)
	for _, slot in view.slots do
		if slot.collectStart then
			collectStep(slot, now)
		elseif near and slot.idle and slot.shown then
			idleStep(slot, now, dt)
		end
	end
end

-- Read the machine's attributes and show the right thing.
local function syncToServer(view)
	local machine = view.machine
	local results = parseResults(machine:GetAttribute("Results"))
	local rollId = machine:GetAttribute("RollId")
	if not results or rollId == nil or rollId == view.playedRollId then
		return
	end
	view.playedRollId = rollId

	local startTime = machine:GetAttribute("RollStartTime") or 0
	local elapsed = workspace:GetServerTimeNow() - startTime
	if elapsed < ShuffleTimeline.totalDuration(Config, #view.slots) then
		playRoll(view, results, machine:GetAttribute("RollSeed") or 0, startTime)
	else
		showFinal(view, results)
	end
end

-- Free everything a view created (safe to call more than once).
local function cleanupView(view)
	if view.cleaned then
		return
	end
	view.cleaned = true
	view.destroyed = true
	stopRender(view)
	if view.leverTween then
		view.leverTween:Cancel()
	end
	for _, connection in view.connections do
		connection:Disconnect()
	end
	for _, slot in view.slots do
		for _, entry in slot.pool do
			entry.model:Destroy() -- pooled clones that are not parented too
		end
		table.clear(slot.pool)
	end
	if view.folder then
		view.folder:Destroy()
	end
end

local function destroyView(machine)
	local view = views[machine]
	if not view then
		return
	end
	views[machine] = nil
	view.destroyed = true
	cleanupView(view)
end

local function buildView(view)
	local machine = view.machine
	local slotsFolder = machine:WaitForChild("Slots", 10)
	assert(slotsFolder, "machine has no Slots folder")

	view.folder = Instance.new("Folder")
	view.folder.Name = machine.Name
	view.folder.Parent = localRoot

	-- slots in SlotIndex order (matches the server's Results order)
	local slotModels = {}
	for _, child in slotsFolder:GetChildren() do
		if child:FindFirstChild("EggAnchor") then
			table.insert(slotModels, child)
		end
	end
	table.sort(slotModels, function(a, b)
		local indexA, indexB = a:GetAttribute("SlotIndex") or 0, b:GetAttribute("SlotIndex") or 0
		if indexA ~= indexB then
			return indexA < indexB
		end
		return a.Name < b.Name -- tie-break so every player gets the same slot order
	end)

	for index, slotModel in slotModels do
		local anchor = slotModel:FindFirstChild("EggAnchor") :: BasePart
		local offset = Config.Display.Offset + (Config.Display.SlotOffsets[index] or Vector3.zero)
		local slotFolder = Instance.new("Folder")
		slotFolder.Name = "Slot" .. index
		slotFolder.Parent = view.folder
		local eggFolder = Instance.new("Folder")
		eggFolder.Name = "Eggs"
		eggFolder.Parent = slotFolder

		local slot = {
			index = index,
			model = slotModel,
			anchor = anchor,
			pool = {},
			shown = nil,
			eggFolder = eggFolder,
			-- bottom-centre of the displayed egg, facing the player
			baseCFrame = anchor.CFrame
				* CFrame.new(0, -anchor.Size.Y / 2, 0)
				* CFrame.new(offset)
				* CFrame.Angles(0, math.rad(Config.Display.FacingYaw), 0),
		}
		createSlotEffects(slot, slotFolder)
		setRingMode(slot, "off")
		view.slots[index] = slot
	end

	-- lever arm (optional: the machine still works without it)
	local lever = machine:FindFirstChild("Lever")
	local arm = lever and lever:FindFirstChild("Arm")
	if arm and arm:IsA("Model") then
		view.arm = arm
		view.armRest = arm:GetPivot()
		view.leverAngle = Instance.new("NumberValue")
		table.insert(view.connections, view.leverAngle.Changed:Connect(function(degrees)
			arm:PivotTo(view.armRest * CFrame.Angles(math.rad(degrees), 0, 0))
		end))
	end

	view.center = machine:GetPivot().Position
	local soundEmitter = newLocalPart("SoundEmitter", view.folder)
	soundEmitter.CFrame = machine:GetPivot()
	view.leverSound = makeSound(Config.Sounds.Lever, soundEmitter)
	view.spinClip = makeSound(Config.Sounds.SpinClip, soundEmitter)
end

local function createView(machine: Instance)
	if views[machine] or not machine:IsA("Model") then
		return
	end
	local view = {
		machine = machine,
		slots = {},
		connections = {},
		leverToken = 0,
		lastTick = 0,
		errors = 0,
		destroyed = false,
	}
	views[machine] = view

	local ok, err = pcall(buildView, view)
	if not ok or view.destroyed then
		if not ok then
			warn(LOG_PREFIX, "Could not set up", machine:GetFullName(), err)
		end
		if views[machine] == view then
			views[machine] = nil
		end
		cleanupView(view)
		return
	end

	-- one render loop per machine for its whole life: plays rolls and the idle spin
	view.renderConnection = RunService.RenderStepped:Connect(function()
		local ok, err = pcall(updateView, view)
		if not ok then
			view.errors += 1
			if view.errors <= 3 then
				warn(LOG_PREFIX, "Animation error, showing the result directly:", err)
			end
			local roll = view.roll
			if roll then
				view.roll = nil
				pcall(showFinal, view, roll.results)
			end
			if view.errors > 3 then
				for _, slot in view.slots do
					slot.idle = false -- keeps failing: freeze the eggs instead of erroring every frame
				end
			end
		end
	end)

	table.insert(view.connections, machine:GetAttributeChangedSignal("RollId"):Connect(function()
		syncToServer(view)
	end))
	view.lastBought = machine:GetAttribute("Bought") or ""
	table.insert(view.connections, machine:GetAttributeChangedSignal("Bought"):Connect(function()
		onBoughtChanged(view)
	end))
	syncToServer(view) -- show the current result if the machine was used before we arrived
end

for _, machine in CollectionService:GetTagged(Config.MachineTag) do
	task.spawn(createView, machine)
end
CollectionService:GetInstanceAddedSignal(Config.MachineTag):Connect(createView)
CollectionService:GetInstanceRemovedSignal(Config.MachineTag):Connect(destroyView)
