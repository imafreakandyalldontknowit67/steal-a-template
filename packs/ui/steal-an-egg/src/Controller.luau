local gui=script.Parent
local Tween=game:GetService("TweenService")
local Input=game:GetService("UserInputService")
local Run=game:GetService("RunService")
local canvas=gui:WaitForChild("DesignCanvas")
local panels=canvas:WaitForChild("Panels")
local hud=canvas:WaitForChild("HUD")
local active, tweens, generation={}, {}, {}
local homes={}
local fuseSlots={false,false,false}
local function animate(o,seconds,props)
 if tweens[o] then tweens[o]:Cancel() end
 local t=Tween:Create(o,TweenInfo.new(seconds,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),props)
 tweens[o]=t;t:Play();return t
end
local function close(p)
 generation[p]=(generation[p] or 0)+1;local token=generation[p]
 active[p]=nil
 local h=homes[p] or p.Position
 local t=animate(p,.18,{Position=UDim2.new(h.X.Scale,h.X.Offset,h.Y.Scale,h.Y.Offset+canvas.AbsoluteSize.Y/canvas.ResponsiveScale.Scale+70)})
 t.Completed:Once(function() if generation[p]==token then p.Visible=false;p.Position=h end end)
 if p.Name=="FuseMachine" then p.Confirmation.Visible=false;p.Result.Visible=false end
end
local function open(name)
 local p=panels:FindFirstChild(name);if not p then return end
 if active[p] then close(p);return end
 for other in pairs(active) do close(other) end
 generation[p]=(generation[p] or 0)+1
 local h=homes[p] or p.Position
 if not p.Visible then p.Position=UDim2.new(h.X.Scale,h.X.Offset,h.Y.Scale,h.Y.Offset+canvas.AbsoluteSize.Y/canvas.ResponsiveScale.Scale+70) end
 p.Visible=true;active[p]=true
 animate(p,.28,{Position=h})
 gui:SetAttribute("ActivePanel",name)
end
local function fit()
 local cam=workspace.CurrentCamera;if not cam then return end
 local v=cam.ViewportSize;local s=math.min(v.X/1333,v.Y/682)
 canvas.ResponsiveScale.Scale=s
 local left=(1333-v.X/s)/2;local top=(682-v.Y/s)/2
 hud.Shop.Position=UDim2.fromOffset(left+12,272)
 hud.FuseLauncher.Position=UDim2.fromOffset(left+12,430);hud.TrailLauncher.Position=UDim2.fromOffset(left+12,473)
 hud.Index.Position=UDim2.fromOffset(left+12,327)
 hud.SlowMode.Position=UDim2.fromOffset(left+12,384);hud.SlowModeLabel.Position=UDim2.fromOffset(left+93,384)
 hud.Eggs.Position=UDim2.fromOffset(1333-left-61,272);hud.Pets.Position=UDim2.fromOffset(1333-left-61,343)
 hud.Timer.Position=UDim2.fromOffset(1333-left-160,682-top-50)
 hud.Hourglass.Position=UDim2.fromOffset(1333-left-198,682-top-50)
 hud.SpeedIcon.Position=UDim2.fromOffset(left+7,682-top-95)
 hud.SpeedValue.Position=UDim2.fromOffset(left+63,682-top-97)
 hud.SpeedPlus.Position=UDim2.fromOffset(left+36,682-top-74)
 hud.CashArt.Position=UDim2.fromOffset(left+6,682-top-44)
 hud.CashValue.Position=UDim2.fromOffset(left+63,682-top-46)
 for _,p in panels:GetChildren() do
 local ps=p:FindFirstChild("PanelScale") or Instance.new("UIScale");ps.Name="PanelScale";ps.Parent=p
 local w,h=p:GetAttribute("PanelWidth"),p:GetAttribute("PanelHeight")
 local ratio=1
 if v.X<650 then ratio=math.min((v.X-24)/w,(v.Y-145)/h)/s end
 ps.Scale=ratio
 local x,y=p:GetAttribute("HomeX"),p:GetAttribute("HomeY")
 if v.X<650 then x=(1333-w*ratio)/2;y=(682-h*ratio)/2
 elseif p:GetAttribute("Drawer") then x=1333-left-w-13 end
 if p.Name=="FuseMachine" then p.Result.Position=v.X<650 and UDim2.fromOffset(10,130) or UDim2.fromOffset(-256,120) end
 local home=UDim2.fromOffset(x,y);homes[p]=home
 if tweens[p] then tweens[p]:Cancel() end
 p.Position=home
 end
 gui:SetAttribute("ViewportWidth",v.X);gui:SetAttribute("ViewportHeight",v.Y)
 gui:SetAttribute("LayoutMode",v.X<650 and "Compact" or "Reference")
end
local cameraConnection
local function cameraChanged()
 if cameraConnection then cameraConnection:Disconnect() end
 if workspace.CurrentCamera then cameraConnection=workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(fit) end
 fit()
end
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(cameraChanged);cameraChanged()
local function updateFuse()
 local p=panels.FuseMachine;local count=0
 for i,on in ipairs(fuseSlots) do
 local slot=p["Slot"..i];slot.Caption.Text=on and "Name\nRarity" or "Empty";slot.Caption.TextSize=on and 16 or 23
 slot.Egg.Visible=on;slot.Add.Label.Text=on and "Return" or "+";slot.Add.Label.TextSize=on and 19 or 27
 slot.Add.Size=UDim2.fromOffset(on and 68 or 105,29)
 slot.Add.Label.Position=UDim2.fromOffset(0,0);slot.Add.Label.Size=UDim2.fromScale(1,1)
 slot.Add.Label.TextSize=on and 16 or 27
 if on then count+=1 end
 end
 p.Fuse.Label.Text=count==3 and "Fuse!" or tostring(3-count).." Pets Left"
end
local function toggle(b)
 local on=not b:GetAttribute("On");b:SetAttribute("On",on)
 local thumb=b:FindFirstChild("Thumb")
 if thumb then
 local g=thumb:FindFirstChildOfClass("UIGradient");if g then g.Enabled=false end
 animate(thumb,.12,{Position=UDim2.fromOffset(on and b.Size.X.Offset-thumb.Size.X.Offset-5 or 5,thumb.Position.Y.Offset),BackgroundColor3=on and Color3.fromRGB(94,255,0) or Color3.fromRGB(255,20,30)})
 end
 local state=b.Parent:FindFirstChild("State");if state then state.Text=on and "ON" or "OFF" end
end
local dragging
local function setSlider(b,x)
 local value=math.clamp((x-b.AbsolutePosition.X)/b.AbsoluteSize.X,0,1)
 b:SetAttribute("Value",value);b.Fill.Size=UDim2.new(value,-3,0,17)
 b.Knob.Position=UDim2.new(value,-12,0,-3)
end
Input.InputChanged:Connect(function(i)
 if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then setSlider(dragging,i.Position.X) end
end)
Input.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=nil end end)
for _,b in gui:GetDescendants() do if b:IsA("GuiButton") then
 local iscale=b:FindFirstChild("InteractionScale")
 b.MouseEnter:Connect(function() if iscale then animate(iscale,.1,{Scale=1.035}) end end)
 b.MouseLeave:Connect(function() if iscale then animate(iscale,.1,{Scale=1}) end end)
 b.MouseButton1Down:Connect(function() if iscale then animate(iscale,.07,{Scale=.97}) end end)
 b.MouseButton1Up:Connect(function() if iscale then animate(iscale,.08,{Scale=1}) end end)
 if b:GetAttribute("Action")=="Slider" then b.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=b;setSlider(b,i.Position.X) end end) end
 b.Activated:Connect(function()
 local route=b:GetAttribute("Route");if route then open(route);return end
 local a=b:GetAttribute("Action")
 if a=="Close" then local p=b;while p and p.Parent~=panels do p=p.Parent end;if p then close(p) end
 elseif a=="Toggle" then toggle(b)
 elseif a=="SelectPet" then local p=panels.PetIndex;p.Detail.Rarity.Text=b:GetAttribute("Rarity");p.Detail.Pet.Image=b.PetArt.Image
 elseif a=="Claim" then b.Label.Text="CLAIMED";gui:SetAttribute("DemoClaimed",true)
 elseif a=="Equip" then b.Label.Text=b.Label.Text=="Equip" and "Unequip" or "Equip"
 elseif a=="EquipBest" then for _,r in panels.ActivePets.Content:GetChildren() do if r:FindFirstChild("Equip") then r.Equip.Label.Text="Unequip" end end
 elseif a=="FuseSlot" then local i=b:GetAttribute("Slot");fuseSlots[i]=not fuseSlots[i];updateFuse()
 elseif a=="Fuse" then if fuseSlots[1] and fuseSlots[2] and fuseSlots[3] then panels.FuseMachine.Confirmation.Visible=true end
 elseif a=="CancelFuse" then panels.FuseMachine.Confirmation.Visible=false
 elseif a=="ConfirmFuse" then panels.FuseMachine.Confirmation.Visible=false;panels.FuseMachine.Result.Visible=true;fuseSlots={false,false,false};updateFuse()
 elseif a=="DismissResult" then panels.FuseMachine.Result.Visible=false
 elseif a=="Grow" then b.Parent.Progress.Time.Text="Ready!"
 elseif a=="GrowAll" then for _,r in panels.GrowingEggs.Content:GetChildren() do if r:FindFirstChild("Progress") then r.Progress.Time.Text="Ready!" end end
 elseif a=="DemoPurchase" then gui:SetAttribute("LastDemoAction",b:GetFullName());gui:SetAttribute("DemoActionCount",(gui:GetAttribute("DemoActionCount") or 0)+1)
 end
 if a=="Equip" or a=="EquipBest" then local n=0;for _,r in panels.ActivePets.Content:GetChildren() do if r:FindFirstChild("Equip") and r.Equip.Label.Text=="Unequip" then n+=1 end end;panels.ActivePets.Header.Title.Text=n.."/7 Active" end
 end)
end end
-- Integration hook for world triggers. No extra launcher added to the reference HUD.
local openEvent=Instance.new("BindableEvent");openEvent.Name="OpenPanel";openEvent.Parent=gui;openEvent.Event:Connect(open)
gui:GetAttributeChangedSignal("PreviewPanel"):Connect(function() local n=gui:GetAttribute("PreviewPanel");if n and n~="" then open(n) end end)
Input.InputBegan:Connect(function(i,processed)
 if not processed and i.KeyCode==Enum.KeyCode.Escape then for p in pairs(active) do close(p) end end
end)
task.spawn(function() local assets={} for _,o in gui:GetDescendants() do if o:IsA("ImageLabel") then table.insert(assets,o) end end pcall(function() game:GetService("ContentProvider"):PreloadAsync(assets) end) end)

-- Keep the custom backpack/settings beside actual Roblox controls, outside canvas scaling.
local GuiService=game:GetService("GuiService")
local function fitTopbar()
 local inset=GuiService.TopbarInset
 local x=math.max(172,inset.Min.X+8)
 local y=inset.Height>0 and inset.Min.Y+math.max(0,(inset.Height-36)/2) or 8
 gui.Topbar.Position=UDim2.fromOffset(x,y)
end
GuiService:GetPropertyChangedSignal("TopbarInset"):Connect(fitTopbar);fitTopbar()
-- This inventory displays real local Tools; it does not fabricate owned items.
pcall(function() game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.Backpack,false) end)
local player=game.Players.LocalPlayer
local backpack=player:WaitForChild("Backpack")
local function inventory()
 local container=panels.AllItems.Items
 for _,o in container:GetChildren() do if o:IsA("GuiButton") then o:Destroy() end end
 local all={}
 for _,parent in {backpack,player.Character} do
  if parent then for _,o in parent:GetChildren() do if o:IsA("Tool") then table.insert(all,o) end end end
 end
 local query=panels.AllItems.Search.Text:lower();local shown=0
 for _,tool in all do if query=="" or tool.Name:lower():find(query,1,true) then
  local i=shown;shown+=1
  local b=Instance.new("TextButton");b.Name="ToolItem";b.Size=UDim2.fromOffset(96,96);b.Position=UDim2.fromOffset((i%10)*106,math.floor(i/10)*106)
  b.Text=tool.Name;b.TextWrapped=true;b.TextSize=17;b.Font=Enum.Font.Gotham;b.TextColor3=Color3.new(1,1,1);b.BackgroundColor3=Color3.fromRGB(65,68,72);b.BackgroundTransparency=.25;b.ZIndex=24;b.Parent=container
  local c=Instance.new("UICorner");c.CornerRadius=UDim.new(0,6);c.Parent=b
  b.Activated:Connect(function() local h=player.Character and player.Character:FindFirstChildOfClass("Humanoid");if h then if tool.Parent==backpack then h:EquipTool(tool) else h:UnequipTools() end end end)
 end end
 container.CanvasSize=UDim2.fromOffset(0,math.max(335,math.ceil(shown/10)*106))
end
backpack.ChildAdded:Connect(inventory);backpack.ChildRemoved:Connect(inventory)
local function watchCharacter(c) c.ChildAdded:Connect(inventory);c.ChildRemoved:Connect(inventory);inventory() end
if player.Character then watchCharacter(player.Character) end
player.CharacterAdded:Connect(watchCharacter)
panels.AllItems.Search:GetPropertyChangedSignal("Text"):Connect(inventory);inventory()
Input.InputBegan:Connect(function(i,processed) if not processed and i.KeyCode==Enum.KeyCode.Backquote then open("AllItems") end end)

local function showLaunchers() local visible=gui:GetAttribute("ShowDemoLaunchers")~=false;hud.FuseLauncher.Visible=visible;hud.TrailLauncher.Visible=visible end
gui:GetAttributeChangedSignal("ShowDemoLaunchers"):Connect(showLaunchers);showLaunchers()
gui:SetAttribute("ControllerReady",true)
