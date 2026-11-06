-- Read-only runtime geometry probe; run through Studio MCP Client context.
local pg=game.Players.LocalPlayer.PlayerGui
local root=pg:FindFirstChild('SurfaceInventory')
local surface=pg:FindFirstChild('InventorySurface') or (root and root:FindFirstChild('InventorySurface'))
assert(root and surface,'Expected installed SurfaceInventory')
local camera=workspace.CurrentCamera
local plane=surface.Adornee
local function project(x,y)
 local sz=plane.Size
 local world=plane.CFrame:PointToWorldSpace(Vector3.new((.5-x/surface.CanvasSize.X)*sz.X,(.5-y/surface.CanvasSize.Y)*sz.Y,-sz.Z*.5))
 local p=camera:WorldToViewportPoint(world)
 return Vector2.new(p.X,p.Y)
end
local function rect(obj)
 local p,s=obj.AbsolutePosition,obj.AbsoluteSize
 local center=p+s*.5
 local corners={}
 for _,v in ipairs({Vector2.new(-.5,-.5),Vector2.new(.5,-.5),Vector2.new(.5,.5),Vector2.new(-.5,.5)})do
  local dx,dy=v.X*s.X,v.Y*s.Y
  local a=math.rad(obj.Rotation)
  local q=project(center.X+dx*math.cos(a)-dy*math.sin(a),center.Y+dx*math.sin(a)+dy*math.cos(a))
  table.insert(corners,q)
 end
 local minX,minY,maxX,maxY=math.huge,math.huge,-math.huge,-math.huge
 for _,q in ipairs(corners)do minX=math.min(minX,q.X);minY=math.min(minY,q.Y);maxX=math.max(maxX,q.X);maxY=math.max(maxY,q.Y)end
 return {x=minX,y=minY,right=maxX,bottom=maxY,width=(corners[2]-corners[1]).Magnitude,height=(corners[4]-corners[1]).Magnitude,center={project(center.X,center.Y).X,project(center.X,center.Y).Y}}
end
local p=surface.Canvas.Panel
local insetA,insetB=game.GuiService:GetGuiInset()
local controls={close=rect(p.Close),primary=rect(p.ActionPrimary),secondary=rect(p.ActionSecondary),firstSlot=rect(p.Slots.Slot01),scroll=rect(p.Slots),title=rect(p.Title)}
local outside={}
for name,r in pairs(controls)do
 if name~='firstSlot' and name~='scroll' and (r.x<0 or r.y<insetA.Y or r.right>camera.ViewportSize.X or r.bottom>camera.ViewportSize.Y-insetB.Y)then table.insert(outside,name)end
end
return {viewport={camera.ViewportSize.X,camera.ViewportSize.Y},inset={insetA.X,insetA.Y,insetB.X,insetB.Y},layout=root:GetAttribute('LayoutMode'),open=root:GetAttribute('InventoryOpen'),enabled=surface.Enabled,canvas={surface.CanvasSize.X,surface.CanvasSize.Y},controls=controls,outside=outside,titleFits=p.Title.Label.TextFits,artLoaded={root.Launcher.Backpack.UploadedBackpack.IsLoaded,p.Title.Backpack.UploadedBackpack.IsLoaded},scrollPosition={p.Slots.CanvasPosition.X,p.Slots.CanvasPosition.Y},scrollCanvas={p.Slots.AbsoluteCanvasSize.X,p.Slots.AbsoluteCanvasSize.Y},scrollEnabled=p.Slots.ScrollingEnabled,launcherVisible=root.Launcher.Visible,touchEnabled=game.UserInputService.TouchEnabled,gamepadEnabled=game.UserInputService.GamepadEnabled}
