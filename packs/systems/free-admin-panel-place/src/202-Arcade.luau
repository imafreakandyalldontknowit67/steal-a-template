--[=[
	@class ArcadeTheme

	Bright retro-arcade variant. Uses the shared _base skeleton; differentiation
	comes from the Arcade theme config (chunky 12px corners, 4px strokes,
	LuckiestGuy/FredokaOne fonts, saturated blue/yellow palette on dark base).
]=]

return function(deps)
	local base = require(script.Parent:FindFirstChild("_base"))
	return base(deps)
end
