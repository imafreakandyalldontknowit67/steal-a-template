--[=[
	@class MidnightTheme

	Deep-blue refined variant. Uses the shared _base skeleton; differentiation
	comes from the Midnight theme config (indigo palette, 8px corners, 3px
	strokes, Montserrat body/heading, bold text weights).
]=]

return function(deps)
	local base = require(script.Parent:FindFirstChild("_base"))
	return base(deps)
end
