--[=[
	@class IndustrialTheme

	Steel/amber factory variant. Uses the shared _base skeleton; differentiation
	comes from the Industrial theme config (near-square 2px corners, 5px strokes,
	RobotoCondensed heading, amber/gray palette).
]=]

return function(deps)
	local base = require(script.Parent:FindFirstChild("_base"))
	return base(deps)
end
