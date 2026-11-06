-- Camera-relative SurfaceGui. All visible UI is authored in the model, not built here.
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local HttpService = game:GetService("HttpService")
-- A separate copy of this included controller survives UI destruction long enough
-- to clean detached SurfaceGui/Part resources under deferred engine signals.
local reference = script:FindFirstChild("UIRoot")
if not reference then
 local ui = script.Parent
 local driver = script:Clone()
 driver.Name = "SurfaceInventoryDriver_" .. HttpService:GenerateGUID(false)
 local link = Instance.new("ObjectValue")
 link.Name = "UIRoot"; link.Value = ui; link.Parent = driver
 driver.Parent = Players.LocalPlayer:WaitForChild("PlayerScripts")
 return
end
local root = reference.Value
if not root then script:Destroy(); return end
local config = require(root.Config)
local surface = root.InventorySurface
local canvas = surface.Canvas
local panel = canvas.Panel
local slots = panel.Slots
local launcher = root.Launcher
local player = Players.LocalPlayer
local connections = {}
local alive = true
local open = config.StartOpen
local phase = open and 1 or 0
local velocity = 0
local tilt = Vector2.zero
local tiltVelocity = Vector2.zero
local pointer = Vector2.zero
local activeTouch = nil
local animationTime = open and 10 or 0
local revealEpoch = os.clock() - animationTime
local transitionEpoch = os.clock()
local freshTransition = false
local selected = 0
local hoverStates = {}
local loadedAt = os.clock()
local part = Instance.new("Part")
part.Name = "SurfaceInventoryCameraPlane"
part.Anchored = true
part.CanCollide = false
part.CanTouch = false
part.CanQuery = true -- SurfaceGui buttons require a queryable adornee.
part.CastShadow = false
part.Transparency = 1
part.Size = Vector3.new(10, 7.2, 0.01)
part.Parent = workspace
surface.Adornee = part
surface.ResetOnSpawn = false
-- LayerCollector must be directly under PlayerGui for reliable surface input.
surface.Parent = player:WaitForChild("PlayerGui")
surface.Enabled = open
root.Money.Visible = config.ShowDemoMoney
root.Money.Text = "MONEY:0"
local originalPositions = {}
local slotCount = 0
for _, slot in ipairs(slots:GetChildren()) do
 if slot:IsA("GuiButton") then originalPositions[slot] = slot.Position;slotCount+=1 end
end
local function connect(signal, fn)
 local c = signal:Connect(fn)
 table.insert(connections,c)
 return c
end
local function setOpen(value)
 if value == open then return end
 open = value
 for button,state in pairs(hoverStates) do
  if button ~= launcher then state.over=false;state.down=false end
 end
 transitionEpoch = os.clock()
 freshTransition = true
 if open then
  surface.Enabled = true
  animationTime = 0
  revealEpoch = os.clock()
  if UserInputService:GetLastInputType().Name:find("Gamepad") then GuiService.SelectedObject = panel.Close end
 else
  GuiService.SelectedObject = nil
 end
 root:SetAttribute("InventoryOpen", open)
end
connect(launcher.Activated, function() setOpen(not open) end)
connect(panel.Close.Activated, function() setOpen(false) end)
connect(UserInputService.InputBegan, function(input, processed)
 if input.UserInputType == Enum.UserInputType.Touch then activeTouch=input end
 if processed or UserInputService:GetFocusedTextBox() then return end
 if input.KeyCode == config.ToggleKey or input.KeyCode == Enum.KeyCode.ButtonY then setOpen(not open)
 elseif open and (input.KeyCode == Enum.KeyCode.Escape or input.KeyCode == Enum.KeyCode.ButtonB) then setOpen(false) end
end)
connect(UserInputService.InputChanged, function(input)
 if input.UserInputType == Enum.UserInputType.Touch and input==activeTouch and open then
  local camera = workspace.CurrentCamera
  if camera then
   local size = camera.ViewportSize
   pointer = Vector2.new(input.Position.X / math.max(size.X,1) * 2 - 1,input.Position.Y / math.max(size.Y,1) * 2 - 1)
  end
 end
end)
connect(UserInputService.InputEnded,function(input)
 if input.UserInputType == Enum.UserInputType.Touch then pointer = Vector2.zero;activeTouch=nil end
end)
local function hover(button,kind)
 hoverStates[button]={over=false,down=false,value=0,press=0,kind=kind,base=button.BackgroundColor3}
 local state=hoverStates[button]
 connect(button.MouseEnter,function() state.over=true end)
 connect(button.MouseLeave,function() state.over=false;state.down=false end)
 connect(button.SelectionGained,function() state.over=true end)
 connect(button.SelectionLost,function() state.over=false;state.down=false end)
 connect(button.MouseButton1Down,function() state.down=true end)
 connect(button.MouseButton1Up,function() state.down=false end)
end
hover(launcher,"launcher")
hover(panel.Close,"close")
hover(panel.ActionPrimary,"action")
hover(panel.ActionSecondary,"action")
connect(UserInputService.InputEnded,function(input)
 if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
  for _,state in pairs(hoverStates) do state.down=false end
 end
end)
connect(root:GetPropertyChangedSignal("Enabled"),function()
 if not root.Enabled then for _,state in pairs(hoverStates)do state.over=false;state.down=false end end
end)
for _, slot in ipairs(slots:GetChildren()) do
 if slot:IsA("GuiButton") then
  hover(slot,"slot")
  connect(slot.Activated,function()
   selected = tonumber(slot.Name:match("%d+")) or 0
   for _, sibling in ipairs(slots:GetChildren()) do
    if sibling:IsA("GuiButton") then sibling.Selection.Visible = sibling == slot end
   end
   -- Reference slots/actions are blank: retain blank text and emit local integration event.
   root.ItemSelected:Fire(selected)
  end)
 end
end
connect(panel.ActionPrimary.Activated,function() root.ActionRequested:Fire("primary",selected) end)
connect(panel.ActionSecondary.Activated,function() root.ActionRequested:Fire("secondary",selected) end)
connect(root.OpenRequested.Event,function(value) setOpen(value ~= false) end)
-- Optional generated artwork: leave native editable fallback until a real uploaded ID is configured.
if config.BackpackImage ~= "" then
 for _, obj in ipairs(root:GetDescendants()) do
  if obj:IsA("ImageLabel") and obj.Name == "UploadedBackpack" then
   obj.Image = config.BackpackImage
   obj.Visible = true
   obj.Parent.NativeBackpack.Visible = false
  end
 end
end
-- Stable substepped damped springs, including reversal/resize during a transition.
local function stepScalar(x,v,target,frequency,damping,dt)
 local steps = math.max(1,math.ceil(dt / (1/120)))
 local h = dt / steps
 for _ = 1,steps do
  v += ((target-x)*frequency*frequency - 2*damping*frequency*v)*h
  x += v*h
 end
 return x,v
end
-- Same authored instances, deliberate compact reflow instead of unreadably tiny slots.
local layoutMode = ""
local function applyResponsive(viewport)
 local mode = (viewport.X < 900 or viewport.Y < 700) and (viewport.X < viewport.Y and "portrait" or "compact-landscape") or "desktop"
 if mode == layoutMode then return mode end
 layoutMode = mode
 pointer=Vector2.zero;activeTouch=nil
 local cols,cell,pitchX,pitchY = 5,78,90,88
 if mode == "portrait" then
  surface.CanvasSize = Vector2.new(500,740)
  panel.Position=UDim2.fromOffset(30,100);panel.Size=UDim2.fromOffset(440,580)
  slots.Position=UDim2.fromOffset(4,4);slots.Size=UDim2.fromOffset(415,316)
  panel.Detail.Position=UDim2.fromOffset(20,338);panel.Detail.Size=UDim2.fromOffset(190,212)
  panel.ActionPrimary.Position=UDim2.fromOffset(230,338);panel.ActionPrimary.Size=UDim2.fromOffset(190,96)
  panel.ActionSecondary.Position=UDim2.fromOffset(239,454);panel.ActionSecondary.Size=UDim2.fromOffset(172,76)
  panel.Title.Position=UDim2.fromOffset(-10,-90);panel.Title.Size=UDim2.fromOffset(330,85)
  panel.Title.Label.Position=UDim2.fromOffset(76,9);panel.Title.Label.Size=UDim2.fromOffset(248,65);panel.Title.Label.TextSize=42
  panel.Title.Backpack.Position=UDim2.fromOffset(8,5);panel.Title.Backpack.Size=UDim2.fromOffset(65,72)
  panel.Close.Position=UDim2.fromOffset(381,-30)
  cols,cell,pitchX,pitchY = 4,84,96,96
 elseif mode == "compact-landscape" then
  surface.CanvasSize=Vector2.new(900,360)
  panel.Position=UDim2.fromOffset(40,74);panel.Size=UDim2.fromOffset(820,286)
  slots.Position=UDim2.fromOffset(4,4);slots.Size=UDim2.fromOffset(507,256)
  panel.Detail.Position=UDim2.fromOffset(520,12);panel.Detail.Size=UDim2.fromOffset(280,64)
  panel.ActionPrimary.Position=UDim2.fromOffset(520,88);panel.ActionPrimary.Size=UDim2.fromOffset(280,104)
  panel.ActionSecondary.Position=UDim2.fromOffset(533,198);panel.ActionSecondary.Size=UDim2.fromOffset(254,88)
  panel.Title.Position=UDim2.fromOffset(-14,-74);panel.Title.Size=UDim2.fromOffset(370,70)
  panel.Title.Label.Position=UDim2.fromOffset(80,8);panel.Title.Label.Size=UDim2.fromOffset(280,66);panel.Title.Label.TextSize=45
  panel.Title.Backpack.Position=UDim2.fromOffset(8,4);panel.Title.Backpack.Size=UDim2.fromOffset(65,72)
  panel.Close.Position=UDim2.fromOffset(746,-30)
  cols,cell,pitchX,pitchY = 5,88,94,96
 else
  surface.CanvasSize=Vector2.new(1000,720)
  panel.Position=UDim2.fromOffset(70,130);panel.Size=UDim2.fromOffset(860,560)
  slots.Position=UDim2.fromOffset(6,4);slots.Size=UDim2.fromOffset(497,550)
  panel.Detail.Position=UDim2.fromOffset(540,25);panel.Detail.Size=UDim2.fromOffset(292,310)
  panel.ActionPrimary.Position=UDim2.fromOffset(535,365);panel.ActionPrimary.Size=UDim2.fromOffset(297,82)
  panel.ActionSecondary.Position=UDim2.fromOffset(549,457);panel.ActionSecondary.Size=UDim2.fromOffset(269,65)
  panel.Title.Position=UDim2.fromOffset(-38,-108);panel.Title.Size=UDim2.fromOffset(435,108)
  panel.Title.Label.Position=UDim2.fromOffset(97,15);panel.Title.Label.Size=UDim2.fromOffset(325,78);panel.Title.Label.TextSize=51
  panel.Title.Backpack.Position=UDim2.fromOffset(12,10);panel.Title.Backpack.Size=UDim2.fromOffset(78,84)
  panel.Close.Position=UDim2.fromOffset(819,-32)
 end
 local closeSize=mode=="compact-landscape" and 88 or 74
 panel.Close.Size=UDim2.fromOffset(closeSize,closeSize)
  panel.Close.AnchorPoint=Vector2.new(.5,.5)
  panel.Close.Position+=UDim2.fromOffset(closeSize/2,closeSize/2)
 for _,cross in ipairs(panel.Close:GetChildren())do if cross:IsA("Frame")then cross.Position=UDim2.fromOffset((closeSize-13)/2,(closeSize-52)/2)end end
 canvas.Size=UDim2.fromOffset(surface.CanvasSize.X,surface.CanvasSize.Y)
 slots.ScrollingEnabled=true;slots.ScrollBarThickness=4
 slots.ScrollBarImageColor3=Color3.new(1,1,1);slots.ScrollBarImageTransparency=0
 slots.CanvasSize=UDim2.fromOffset(0,32+(math.ceil(slotCount/cols)-1)*pitchY+cell)
 slots.CanvasPosition=Vector2.zero
 for slot in pairs(originalPositions) do
  local n=(tonumber(slot.Name:match("%d+")) or 1)-1
  originalPositions[slot]=UDim2.fromOffset(16+cell/2+n%cols*pitchX,16+cell/2+math.floor(n/cols)*pitchY)
  slot.Size=UDim2.fromOffset(cell,cell)
  slot.InnerRim.Size=UDim2.fromOffset(cell-6,cell-6);slot.Selection.Size=UDim2.fromOffset(cell+4,cell+4)
 end
 for _,button in ipairs({panel.ActionPrimary,panel.ActionSecondary}) do
  -- Layout authors top-lefts; convert once to center anchors for hover scaling.
  button.Position += UDim2.fromOffset(button.Size.X.Offset/2,button.Size.Y.Offset/2)
  button.Highlight.Size=UDim2.new(1,-4,0,2);button.Highlight.Position=UDim2.new(0,2,1,-3)
 end
 root:SetAttribute("LayoutMode",mode)
 return mode
end
local bindName = "SurfaceInventory_" .. HttpService:GenerateGUID(false)
RunService:BindToRenderStep(bindName,Enum.RenderPriority.Camera.Value+1,function(dt)
 if not alive then return end
 local camera = workspace.CurrentCamera
 if not camera then surface.Enabled = false return end
 dt = math.min(dt,0.1)
 local now = os.clock()
 local springDt = freshTransition and math.min(dt,now-transitionEpoch) or dt
 freshTransition = false
 -- Keep the plane in Workspace: replacing CurrentCamera can destroy the old Camera.
 local viewport = camera.ViewportSize
 if viewport.X <= 0 or viewport.Y <= 0 then return end
 local mode=applyResponsive(viewport)
 local response=1-math.exp(-config.HoverResponse*dt)
 for button,state in pairs(hoverStates)do
  local active=root.Enabled and (button==launcher or surface.Enabled)
  state.value += ((active and state.over and 1 or 0)-state.value)*response
  state.press += ((active and state.down and 1 or 0)-state.press)*response
  local h=state.value
  if state.kind=="launcher" then
   button.HoverScale.Scale=1+.12*h-.05*state.press
   -- Slow arrival turn is reconstructed; the clip starts with cursor already here.
   button.Rotation=8*h-8*math.exp(-(now-loadedAt)/config.BackpackArrivalSeconds)
  elseif state.kind=="action" then
   button.HoverScale.Scale=1+.09*h-.04*state.press
   button.ZIndex=h>.01 and 12 or 5
  elseif state.kind=="slot" then
   button.Rotation=8*h
   button.ZIndex=h>.01 and 12 or 5
  elseif state.kind=="close" then
    -- Demo 14.7–15.1s: centered hover enlargement, click compression.
    -- Keep the authored 15-degree resting tilt; panel perspective is separate.
    button.HoverScale.Scale=1+.12*h-.20*state.press
   end
 end
 -- Real elapsed time, not capped physics dt. Fractional scale translation
 -- avoids the old integer-offset stepping at a barely visible 7px/sec.
 local drift=((now-loadedAt)*config.StudSpeed)%44
 for _,holder in ipairs({panel.Studs,panel.Detail.Studs,panel.Title.Studs})do
  for _,layer in ipairs(holder:GetChildren())do
   if layer:IsA("Frame")then
    layer.Position=UDim2.new(-drift/math.max(holder.AbsoluteSize.X,1),-44,drift/math.max(holder.AbsoluteSize.Y,1),-44)
   end
  end
 end
 launcher.Visible = mode == "desktop" or not open
 root.Money.Visible = config.ShowDemoMoney and (mode=="desktop" or not open)
 if UserInputService.MouseEnabled and not UserInputService.TouchEnabled then
  local mouse = UserInputService:GetMouseLocation()
  pointer = Vector2.new(mouse.X/viewport.X*2-1,mouse.Y/viewport.Y*2-1)
 elseif UserInputService.TouchEnabled and UserInputService:GetLastInputType() ~= Enum.UserInputType.Touch then pointer = Vector2.zero
 elseif UserInputService.GamepadEnabled and not UserInputService.TouchEnabled then pointer = Vector2.zero end
 pointer = Vector2.new(math.clamp(pointer.X,-1,1),math.clamp(pointer.Y,-1,1))
 local oldX,oldY = tilt.X,tilt.Y
 local vx,vy = tiltVelocity.X,tiltVelocity.Y
 local tiltLimit=math.rad(config.MaxTiltDegrees)*(mode=="desktop" and 1 or .5)
 local tx = -pointer.Y*tiltLimit
 local ty = pointer.X*tiltLimit
 oldX,vx = stepScalar(oldX,vx,tx,config.TiltFrequency,1,dt)
 oldY,vy = stepScalar(oldY,vy,ty,config.TiltFrequency,1,dt)
 tilt = Vector2.new(oldX,oldY)
 tiltVelocity = Vector2.new(vx,vy)
 phase,velocity = stepScalar(phase,velocity,open and 1 or 0,config.OpenFrequency,open and config.OpenDamping or 0.88,springDt)
 animationTime = open and (now-revealEpoch) or (animationTime+dt)
 local p = math.clamp(phase,0,1.5)
 local safeTop,safeBottom = GuiService:GetGuiInset()
 local tenFoot=GuiService:IsTenFootInterface()
 local hudX=tenFoot and (viewport.X*.05+12) or 12
 launcher.AnchorPoint=Vector2.new(.5,.5)
 launcher.Position=UDim2.new(0,hudX+28,.5,0)
 root.Money.Position=UDim2.new(.5,-120,0,tenFoot and math.max(12,viewport.Y*.05-safeTop.Y+12) or 12)
 if UserInputService.TouchEnabled and mode=="compact-landscape" then safeTop=Vector2.new(safeTop.X,safeTop.Y+16) end
 local touchReserve = UserInputService.TouchEnabled and mode~="desktop" and 80 or 0
 local usableHeight = math.max(1,viewport.Y-safeTop.Y-safeBottom.Y-touchReserve)
 local aspect = viewport.X/viewport.Y
 local distance = config.Distance
 -- Fit BOTH axes. Entire 1000x720 canvas includes title/close overflow.
 local viewHeight = 2*distance*math.tan(math.rad(camera.FieldOfView)*0.5)
 local canvasAspect=surface.CanvasSize.X/surface.CanvasSize.Y
 local margin=mode=="desktop" and 0.82 or (mode=="portrait" and .92 or .96)
 local width = math.min(viewHeight*aspect*(mode=="desktop" and .84 or (mode=="portrait" and .90 or .94)),viewHeight*(usableHeight/viewport.Y)*margin*canvasAspect)
 local factor = math.max(0.025,math.min(p,1.36))
 part.Size = Vector3.new(width*factor,width/canvasAspect*factor,0.01)
 local insetY = (safeTop.Y-safeBottom.Y-touchReserve)/viewport.Y*viewHeight*-0.5
 part.CFrame = camera.CFrame * CFrame.new(0,insetY-(1-p)*viewHeight*0.09-math.max(p-1,0)*viewHeight*.065,-distance-(1-p)*config.Distance*0.08)
  * CFrame.Angles(tilt.X+(1-p)*math.rad(-12),math.pi+tilt.Y,tilt.Y*-0.16)
 surface.Enabled = root.Enabled and (open or phase>0.015)
 part.CanQuery = surface.Enabled
 for slot,original in pairs(originalPositions) do
  local index = tonumber(slot.Name:match("%d+")) or 1
  local delay = config.SlotDelay + (index-1)*config.SlotStagger
  local t = math.clamp((animationTime-delay)/config.SlotDuration,0,1)
  local eased = 1-(1-t)^3
  slot.Visible = not open or t>0
  local state=hoverStates[slot]
  slot.RevealScale.Scale = math.max(0.01,eased*(1+.08*state.value-.04*state.press))
  slot.Position = original + UDim2.fromOffset(0,(1-eased)*12)
 end
end)
local function cleanup()
 if not alive then return end
 alive=false
 RunService:UnbindFromRenderStep(bindName)
 for _,connection in ipairs(connections) do connection:Disconnect() end
 surface.Adornee = nil
 surface:Destroy()
 part:Destroy()
 script:Destroy()
end
connect(root.Destroying,cleanup)
connect(script.Destroying,cleanup)
root:SetAttribute("InventoryOpen",open)
