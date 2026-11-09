--[[
	EggSelector (server only)

	Weighted random choice of an egg. Kept separate from all visuals: it only returns
	the TemplateName of the egg that was rolled. Weights come from Config.Eggs, so to
	add rarity later just change the Weight values there.
]]

local EggSelector = {}
EggSelector.__index = EggSelector

export type EggEntry = { TemplateName: string, Weight: number? }

function EggSelector.new(eggEntries: { EggEntry })
	local self = setmetatable({}, EggSelector)
	self.entries = {}
	self.totalWeight = 0
	for _, entry in eggEntries do
		local weight = tonumber(entry.Weight) or 1
		if weight > 0 then
			table.insert(self.entries, { id = entry.TemplateName, weight = weight })
			self.totalWeight += weight
		end
	end
	assert(self.totalWeight > 0, "[EggRandomizer] EggSelector needs at least one egg with Weight > 0")
	self.rng = Random.new()
	return self
end

-- Returns the TemplateName of a randomly chosen egg, respecting the weights.
function EggSelector:pick(): string
	local roll = self.rng:NextNumber() * self.totalWeight
	for _, entry in self.entries do
		roll -= entry.weight
		if roll < 0 then
			return entry.id
		end
	end
	return self.entries[#self.entries].id -- floating-point safety net
end

-- Chance (0..1) of a given egg, useful for debugging or UI.
function EggSelector:chanceOf(templateName: string): number
	for _, entry in self.entries do
		if entry.id == templateName then
			return entry.weight / self.totalWeight
		end
	end
	return 0
end

return EggSelector
