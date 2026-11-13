--[=[
	@class PastelTheme

	Soft pink/mint variant. Uses the shared _base skeleton; differentiation
	comes from the Pastel theme config (rounded 16px corners, 2px thin strokes,
	cream base, Nunito/FredokaOne fonts, soft pastel palette).
]=]

return function(deps)
	local base = require(script.Parent:FindFirstChild("_base"))
	return base(deps)
end
