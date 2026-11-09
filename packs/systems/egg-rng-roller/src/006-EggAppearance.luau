--[[
	EggAppearance

	Turns a DISPLAY CLONE of an egg completely black while it shuffles, then restores its
	exact original look when it is revealed. It is only ever used on clones — never on
	the original templates in ServerStorage.

	Usage:
		local snapshot = EggAppearance.capture(clone)   -- record the original look (once, on a fresh clone)
		EggAppearance.applyBlack(snapshot)              -- solid black, same 3D shape
		EggAppearance.restore(snapshot)                 -- exact original properties back

	What the blackout touches (all descendants, including nested models):
		BasePart / MeshPart / Union : Color, Material, MaterialVariant, Reflectance, TextureID, UsePartColor
		Decal / Texture             : hidden (Transparency = 1)
		SpecialMesh / FileMesh      : TextureId removed, VertexColor black
		SurfaceAppearance           : temporarily unparented (its properties can't be edited at runtime)
		Particles, beams, trails, lights, highlights, fire/smoke/sparkles, surface/billboard GUIs : disabled
	Part Transparency is recorded and restored but not changed, so the silhouette stays identical.
]]

local EggAppearance = {}

export type Snapshot = {
	entries: { [Instance]: { [string]: any } },
	isBlack: boolean,
}

-- Classes whose visual effect is switched off with .Enabled while black.
local TOGGLE_CLASSES = {
	"ParticleEmitter",
	"Trail",
	"Beam",
	"Fire",
	"Smoke",
	"Sparkles",
	"Light",
	"Highlight",
	"SurfaceGui",
	"BillboardGui",
}

local function isToggleClass(inst: Instance): boolean
	for _, className in TOGGLE_CLASSES do
		if inst:IsA(className) then
			return true
		end
	end
	return false
end

-- Record every property the blackout will change on one instance.
local function record(inst: Instance): { [string]: any }?
	if inst:IsA("BasePart") then
		local props: { [string]: any } = {
			Color = inst.Color,
			Material = inst.Material,
			MaterialVariant = inst.MaterialVariant,
			Reflectance = inst.Reflectance,
			Transparency = inst.Transparency,
		}
		if inst:IsA("MeshPart") then
			props.TextureID = inst.TextureID
		end
		if inst:IsA("PartOperation") then
			props.UsePartColor = inst.UsePartColor
		end
		return props
	elseif inst:IsA("Decal") then -- also covers Texture
		return { Transparency = inst.Transparency }
	elseif inst:IsA("SpecialMesh") or inst:IsA("FileMesh") then
		return { TextureId = (inst :: any).TextureId, VertexColor = (inst :: any).VertexColor }
	elseif inst:IsA("SurfaceAppearance") then
		return { Parent = inst.Parent }
	elseif isToggleClass(inst) then
		return { Enabled = (inst :: any).Enabled }
	end
	return nil
end

local function trySet(inst: Instance, property: string, value: any)
	-- pcall so one locked/unsupported property can never break the whole effect
	pcall(function()
		(inst :: any)[property] = value
	end)
end

-- Capture the original look of a fresh clone. Call BEFORE any other visual change.
function EggAppearance.capture(model: Instance): Snapshot
	local entries = {}
	local function visit(inst: Instance)
		local props = record(inst)
		if props then
			entries[inst] = props
		end
	end
	visit(model)
	for _, descendant in model:GetDescendants() do
		visit(descendant)
	end
	return { entries = entries, isBlack = false }
end

-- Make every visible surface solid black while keeping the real 3D geometry.
function EggAppearance.applyBlack(snapshot: Snapshot, color: Color3?, material: Enum.Material?)
	local black = color or Color3.new(0, 0, 0)
	local blackMaterial = material or Enum.Material.SmoothPlastic
	for inst, _ in snapshot.entries do
		if inst:IsA("BasePart") then
			inst.Color = black
			inst.Material = blackMaterial
			trySet(inst, "MaterialVariant", "")
			inst.Reflectance = 0
			if inst:IsA("MeshPart") then
				trySet(inst, "TextureID", "")
			end
			if inst:IsA("PartOperation") then
				inst.UsePartColor = true
			end
		elseif inst:IsA("Decal") then
			inst.Transparency = 1
		elseif inst:IsA("SpecialMesh") or inst:IsA("FileMesh") then
			trySet(inst, "TextureId", "")
			trySet(inst, "VertexColor", Vector3.zero)
		elseif inst:IsA("SurfaceAppearance") then
			inst.Parent = nil
		else
			trySet(inst, "Enabled", false)
		end
	end
	snapshot.isBlack = true
end

-- Put back the exact original values recorded by capture().
function EggAppearance.restore(snapshot: Snapshot)
	for inst, props in snapshot.entries do
		for property, value in props do
			trySet(inst, property, value)
		end
	end
	snapshot.isBlack = false
end

return EggAppearance
