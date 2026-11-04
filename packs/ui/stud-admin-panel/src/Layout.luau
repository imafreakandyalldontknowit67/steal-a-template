-- Preserve the authored composition; scale all artwork, strokes and controls together.
local Layout = {}
function Layout.apply(gui)
 local size=gui.AbsoluteSize
 local scale=math.max(.1,math.min(1,(size.X-24)/780,(size.Y-24)/540))
 local canvas=gui.Canvas
 canvas.AnchorPoint=Vector2.new(.5,.5)
 canvas.Position=UDim2.fromScale(.5,.5)
 canvas.FitScale.Scale=scale
 return scale
end
return Layout
