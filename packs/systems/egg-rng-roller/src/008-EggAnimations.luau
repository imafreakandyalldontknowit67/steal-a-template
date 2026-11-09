--[[
	EggAnimations

	Optional built-in animations for the machine's display eggs, e.g. the Angel Egg's
	flapping wings. Turn one on by adding  Animation = "Angel"  to that egg's line in
	Config.Eggs.

	How it works: create() records every part's offset from the egg's pivot ONCE (on the
	machine's display copy — never the original model). Every frame pose() returns where each
	part should be relative to the egg, and the machine places them around wherever the egg
	currently is (spinning, bobbing, popping). So the egg's own animation and the machine's
	motion add together instead of fighting each other.

	To add another style later, add a new entry to Styles with build / pose / revealLook.
]]

local EggAnimations = {}
local Styles = {}

local SPARKLE_TEXTURE = "rbxasset://textures/particles/sparkles_main.dds"

local function newEffectPart(name: string, parent: Instance): Part
	local part = Instance.new("Part")
	part.Name = name
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.CastShadow = false
	part.Transparency = 1
	part.Size = Vector3.new(0.2, 0.2, 0.2)
	part.Parent = parent
	return part
end

-- Bounding box (in the egg's local space) of a list of rig entries.
local function bounds(entries)
	local low = Vector3.new(math.huge, math.huge, math.huge)
	local high = -low
	for _, entry in entries do
		local center, half = entry.cf0.Position, entry.size0 / 2
		low = low:Min(center - half)
		high = high:Max(center + half)
	end
	return low, high
end

---------------------------------------------------------------------------
-- Angel: wings flap from the shoulders, the halo bobs and turns, the two rune rings
-- rotate in opposite directions and the orbs circle the egg. While the egg is revealed
-- (never while it is black) the halo and rune rings glow, the gold trim shines, and a
-- soft golden light pulses with sparkles drifting up.
---------------------------------------------------------------------------
local GOLD = Color3.fromRGB(255, 214, 110)
local LIGHT = Color3.fromRGB(255, 238, 170)
local FLASH_EVERY = 3 -- seconds between little light bursts

Styles.Angel = {}

function Styles.Angel.build(rig)
	local function group(tag: string)
		local found = {}
		for _, entry in rig.entries do
			if entry.name:find(tag, 1, true) then
				table.insert(found, entry)
			end
		end
		return found
	end

	local eggParts = group("egg_")
	if #eggParts == 0 then
		eggParts = rig.entries
	end
	local low, high = bounds(eggParts)
	local eggCenter = (low + high) / 2
	local eggHeight = high.Y - low.Y
	local unit = eggHeight / 18
	rig.eggCenter = eggCenter
	rig.unit = unit

	-- every entry gets a "mover" function id; anything not listed below stays still
	for _, entry in rig.entries do
		entry.kind = "static"
	end

	-- wings: each wing tier/side flaps around its shoulder (inner edge)
	rig.wings = {}
	local wingDepth, wingCount = 0, 0
	for _, tier in { "main", "upper", "lower" } do
		for _, side in { "right", "left" } do
			local members = group("wing_" .. tier .. "_" .. side)
			if #members > 0 then
				local a, b = bounds(members)
				local mid = (a + b) / 2
				local sideSign = mid.X > eggCenter.X and 1 or -1
				local wing = {
					pivot = Vector3.new(sideSign > 0 and a.X or b.X, a.Y + (b.Y - a.Y) * 0.4, mid.Z),
					side = sideSign,
					phase = (tier == "main" and 0) or (tier == "upper" and 0.9) or 1.8,
					transform = CFrame.identity,
				}
				table.insert(rig.wings, wing)
				for _, entry in members do
					entry.kind = "group"
					entry.group = wing
				end
				wingDepth += mid.Z - eggCenter.Z
				wingCount += 1
			end
		end
	end
	rig.back = (wingCount > 0 and wingDepth < 0) and -1 or 1

	-- halo
	local halo = group("halo")
	rig.halo = { transform = CFrame.identity, center = eggCenter }
	if #halo > 0 then
		local a, b = bounds(halo)
		rig.halo.center = (a + b) / 2
	end
	for _, entry in halo do
		entry.kind = "group"
		entry.group = rig.halo
	end

	-- rune rings spin around the egg in opposite directions
	rig.rings = {}
	for _, ring in { { tag = "rune_ring_1", speed = 0.7 }, { tag = "rune_ring_2", speed = -0.5 } } do
		local ringGroup = { speed = ring.speed, transform = CFrame.identity }
		table.insert(rig.rings, ringGroup)
		for _, entry in group(ring.tag) do
			entry.kind = "group"
			entry.group = ringGroup
		end
	end

	-- orbs circle the egg
	for _, entry in group("orb_") do
		local offset = entry.cf0.Position - eggCenter
		entry.kind = "orb"
		entry.angle0 = math.atan2(offset.Z, offset.X)
		entry.radius = Vector3.new(offset.X, 0, offset.Z).Magnitude
	end

	-- parts that glow / shine while revealed
	rig.glowParts = {}
	rig.foilParts = {}
	for _, entry in rig.entries do
		if entry.name:find("inner_light", 1, true) or entry.name:find("halo", 1, true) or entry.name:find("rune", 1, true) then
			table.insert(rig.glowParts, entry)
		elseif entry.name:find("feather_tip", 1, true) or entry.name:find("gold", 1, true) or entry.name:find("orb", 1, true) then
			table.insert(rig.foilParts, entry)
		end
	end

	-- soft golden light + drifting sparkles (inside the egg model, so they hide with it)
	local core = newEffectPart("AngelGlow", rig.model)
	core.Size = Vector3.new(eggHeight * 1.3, eggHeight * 1.1, eggHeight * 1.3)
	local light = Instance.new("PointLight")
	light.Color = GOLD
	light.Range = eggHeight * 4
	light.Brightness = 0
	light.Shadows = false
	light.Parent = core
	local sparkles = Instance.new("ParticleEmitter")
	sparkles.Texture = SPARKLE_TEXTURE
	sparkles.Color = ColorSequence.new(LIGHT, GOLD)
	sparkles.LightEmission = 1
	sparkles.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(0.3, eggHeight * 0.13),
		NumberSequenceKeypoint.new(1, 0),
	})
	sparkles.Transparency = NumberSequence.new(0.1, 1)
	sparkles.Lifetime = NumberRange.new(1.2, 2.4)
	sparkles.Speed = NumberRange.new(eggHeight * 0.3, eggHeight * 0.8)
	sparkles.SpreadAngle = Vector2.new(25, 25)
	sparkles.EmissionDirection = Enum.NormalId.Top
	sparkles.Shape = Enum.ParticleEmitterShape.Box
	sparkles.ShapeStyle = Enum.ParticleEmitterShapeStyle.Volume
	sparkles.Rotation = NumberRange.new(0, 360)
	sparkles.RotSpeed = NumberRange.new(-90, 90)
	sparkles.Rate = 18
	sparkles.Enabled = false
	sparkles.Parent = core
	rig.light = light
	rig.sparkles = sparkles
	table.insert(rig.entries, { part = core, cf0 = CFrame.new(eggCenter), size0 = core.Size, name = "angelglow", kind = "static" })
end

function Styles.Angel.pose(rig, t: number, revealed: boolean)
	local unit = rig.unit
	local eggCenter = rig.eggCenter

	for _, wing in rig.wings do
		local beat = math.sin(t * 2.2 - wing.phase)
		wing.transform = CFrame.new(wing.pivot)
			* CFrame.Angles(0, wing.side * 0.3 * beat * rig.back, wing.side * 0.08 * beat)
			* CFrame.new(-wing.pivot)
	end
	local haloCenter = rig.halo.center
	rig.halo.transform = CFrame.new(haloCenter)
		* CFrame.new(0, math.sin(t * 1.6) * unit * 0.35, 0)
		* CFrame.Angles(0, t * 0.5, 0)
		* CFrame.new(-haloCenter)
	for _, ring in rig.rings do
		ring.transform = CFrame.new(eggCenter) * CFrame.Angles(0, t * ring.speed, 0) * CFrame.new(-eggCenter)
	end

	local out = rig.localCFrames
	for i, entry in rig.entries do
		if entry.kind == "group" then
			out[i] = entry.group.transform * entry.cf0
		elseif entry.kind == "orb" then
			local angle = entry.angle0 + t * 0.8
			local position = eggCenter
				+ Vector3.new(math.cos(angle) * entry.radius, 3 * unit * math.sin(angle * 2), math.sin(angle) * entry.radius)
			out[i] = CFrame.new(position) * CFrame.Angles(t, t * 1.3, 0)
		else
			out[i] = entry.cf0
		end
	end

	-- glow only while the real colours are showing (never during the black shuffle)
	if revealed then
		local pulse = 0.5 + 0.5 * math.sin(t * 2.4)
		local flash = math.max(0, 1 - ((t / FLASH_EVERY) % 1) * 5)
		rig.light.Brightness = 1 + pulse + flash * 3
		rig.sparkles.Rate = 18 + flash * 60
		rig.sparkles.Enabled = true
	else
		rig.light.Brightness = 0
		rig.sparkles.Enabled = false
	end
end

-- Extra look applied on top of the restored colours when the egg is revealed.
function Styles.Angel.revealLook(rig)
	for _, entry in rig.glowParts do
		entry.part.Material = Enum.Material.Neon
		entry.part.Color = entry.name:find("inner_light", 1, true) and LIGHT or GOLD
	end
	for _, entry in rig.foilParts do
		entry.part.Material = Enum.Material.Foil
	end
end

---------------------------------------------------------------------------
-- Public API (used by EggRandomizerClient)
---------------------------------------------------------------------------

-- Build a rig for a display clone. `pivot` is the clone's pivot at its display size.
-- Returns nil if the style name is unknown.
function EggAnimations.create(styleName: string, model: Model, pivot: CFrame)
	local style = Styles[styleName]
	if not style then
		warn("[EggRandomizer] Unknown egg Animation '" .. tostring(styleName) .. "' - available: Angel")
		return nil
	end
	local rig = { style = style, model = model, entries = {} }
	for _, descendant in model:GetDescendants() do
		if descendant:IsA("BasePart") then
			table.insert(rig.entries, {
				part = descendant,
				cf0 = pivot:ToObjectSpace(descendant.CFrame),
				size0 = descendant.Size,
				name = descendant.Name:lower(),
			})
		end
	end
	style.build(rig)

	-- fixed arrays reused every frame (no garbage)
	rig.parts = table.create(#rig.entries)
	rig.localCFrames = table.create(#rig.entries)
	rig.worldCFrames = table.create(#rig.entries)
	for i, entry in rig.entries do
		rig.parts[i] = entry.part
		rig.localCFrames[i] = entry.cf0
		rig.worldCFrames[i] = entry.cf0
	end
	return rig
end

-- Fill rig.localCFrames for time t. `revealed` = the egg is showing its real colours.
function EggAnimations.pose(rig, t: number, revealed: boolean)
	rig.style.pose(rig, t, revealed)
end

function EggAnimations.revealLook(rig)
	if rig.style.revealLook then
		rig.style.revealLook(rig)
	end
end

return EggAnimations
