local gui=script.Parent
local Theme=require(gui:WaitForChild('Theme'))
local UIS=game:GetService('UserInputService')
local TS=game:GetService('TweenService')
local panels=gui.Panels
local nav=gui.HUD.TopRight
local active
local blur=gui.PanelBlur:Clone();blur.Name='CommandHQGlassBlur';blur.Parent=workspace.CurrentCamera
gui.Destroying:Connect(function() blur:Destroy() end)
workspace:GetPropertyChangedSignal('CurrentCamera'):Connect(function() blur.Parent=workspace.CurrentCamera end)
local function layout()
 local size=gui.AbsoluteSize
 local compact=UIS.TouchEnabled or size.X<700
 nav.Size=UDim2.fromOffset(compact and 164 or 310,48)
 for i,n in {'Updates','Codes','Settings'} do
  local b=nav[n];b.Size=UDim2.fromOffset(compact and 48 or ({128,112,46})[i],46)
  b.Position=UDim2.fromOffset(compact and (i-1)*58 or ({0,138,260})[i],0)
  if n~='Settings' then b.Text=compact and '' or n end
 end
 nav.Updates.Unread.Position=UDim2.new(1,-8,0,-3)
 for _,p in panels:GetChildren() do
  local w,h=p:GetAttribute('DesignWidth'),p:GetAttribute('DesignHeight')
  p.ResponsiveScale.Scale=math.min(1,(size.X-32)/w,(size.Y-96)/h)
 end
 -- Settings reflows instead of shrinking text on phones and short landscapes.
 local p=panels.Settings
 local short=size.Y<500
 local w,h=math.min(780,size.X-32),math.min(570,size.Y-(short and 24 or 96))
 p.Size=UDim2.fromOffset(w,h);p.ResponsiveScale.Scale=1
 p.Header.Size=UDim2.fromOffset(w,short and 48 or 64);p.Header.Close.Position=UDim2.fromOffset(w-56,short and 2 or 10);p.Divider.Size=UDim2.fromOffset(w,1);p.Divider.Position=UDim2.fromOffset(0,short and 48 or 63)
 local narrow=w<620
 for i,n in {'Game','Audio','Graphics','Controls'} do
  local b=p[n];local bw=(w-52-24)/4;b.Position=UDim2.fromOffset(26+(i-1)*(bw+8),short and 56 or 83);b.Size=UDim2.fromOffset(bw,short and 38 or 46);b.TextSize=narrow and 14 or 21
  b.TextXAlignment=narrow and Enum.TextXAlignment.Center or Enum.TextXAlignment.Right
  b.Caption.Position=UDim2.fromOffset(narrow and 0 or 44,0);b.Caption.Size=UDim2.new(1,narrow and 0 or -52,1,0);b.Caption.TextSize=narrow and 14 or 21
  for _,v in b:GetChildren() do if v:GetAttribute('IsIcon') then v.Visible=not narrow end end
 end
 local pw=w-52;local py=short and 106 or 152;p.Pages.Position=UDim2.fromOffset(26,py);p.Pages.Size=UDim2.fromOffset(pw,math.max(60,h-py-18));p.Pages.CanvasSize=UDim2.fromOffset(0,narrow and 450 or 390)
 for _,page in p.Pages:GetChildren() do if page:IsA('Frame') then
  page.Size=UDim2.fromOffset(pw,narrow and 450 or 390);page.Heading.Size=UDim2.fromOffset(pw-48,46);page.Rule.Size=UDim2.fromOffset(pw,1)
  for _,v in page:GetChildren() do if v:IsA('TextLabel') and v.Name~='Heading' then v.Size=UDim2.fromOffset(pw-52,v.Size.Y.Offset) end end
  for _,v in page:GetDescendants() do if v:IsA('TextLabel') and v.Name=='Label' then v.TextSize=narrow and 17 or 21 elseif v:IsA('TextLabel') and v.Name=='Description' then v.TextSize=narrow and 12 or 14 end end
 end end
 local a=p.Pages.Audio
 for i=1,3 do
  local y=65+(i-1)*(narrow and 78 or 64)
  a['Label'..i].Position=UDim2.fromOffset(26,y);a['Label'..i].Size=UDim2.fromOffset(narrow and pw-85 or 270,narrow and 28 or 50);a['Label'..i].TextSize=narrow and 18 or 23
  local b=a['Slider'..i];b.Position=UDim2.fromOffset(narrow and 26 or 310,y+(narrow and 44 or 20));b.Size=UDim2.fromOffset(narrow and pw-52 or pw-406,10)
  b.Fill.Size=UDim2.new(b:GetAttribute('Value')/100,0,1,0);b.Thumb.Position=UDim2.new(b:GetAttribute('Value')/100,-9,0,-6)
  a['Value'..i].Position=UDim2.fromOffset(pw-70,y);a['Value'..i].Size=UDim2.fromOffset(60,narrow and 28 or 50);a['Value'..i].TextSize=narrow and 18 or 22
  a['Separator'..i].Position=UDim2.fromOffset(16,y+(narrow and 69 or 59));a['Separator'..i].Size=UDim2.fromOffset(pw-32,1)
 end
 for i=1,2 do local y=(narrow and 305 or 259)+(i-1)*65
  a['ToggleTitle'..i].Position=UDim2.fromOffset(26,y);a['ToggleTitle'..i].Size=UDim2.fromOffset(pw-106,30);a['ToggleTitle'..i].TextSize=narrow and 18 or 23
  a['ToggleDetail'..i].Position=UDim2.fromOffset(26,y+27);a['ToggleDetail'..i].Size=UDim2.fromOffset(pw-106,34);a['ToggleDetail'..i].TextSize=narrow and 12 or 17
  a['Toggle'..i].Position=UDim2.fromOffset(pw-84,y+14)
 end
 for _,name in {'UpdateLog','RedeemCode','Missions'} do
  local q=panels[name];local dw=q:GetAttribute('DesignWidth');local qw=math.min(dw,size.X-32)
  local qh=math.min(q:GetAttribute('DesignHeight'),size.Y-32)
  if name=='RedeemCode' and qw<450 then qh=math.min(290,size.Y-32) end
  q.Size=UDim2.fromOffset(qw,qh);q.ResponsiveScale.Scale=1;q.Position=UDim2.fromScale(.5,.5)
  q.Header.Size=UDim2.fromOffset(qw,64);q.Header.Close.Position=UDim2.fromOffset(qw-52,10);q.Header.Title.Size=UDim2.fromOffset(qw-128,44);q.Header.Title.TextSize=qw<400 and 22 or 28;q.Divider.Size=UDim2.fromOffset(qw,1)
  if name=='UpdateLog' then
   q.Version.Size=UDim2.fromOffset(qw-52,50);q.Version.Version.Size=UDim2.fromOffset(qw-185,50);q.Version.Version.TextSize=qw<400 and 20 or 25
   q.Version.Date.Position=UDim2.fromOffset(qw-178,0);q.Version.Date.Size=UDim2.fromOffset(117,50);q.Version.Date.TextSize=qw<400 and 12 or 16
   q.Entries.Size=UDim2.fromOffset(qw-56,math.max(50,qh-172));q.Entries.CanvasSize=UDim2.fromOffset(0,280)
   for i=1,3 do q.Entries['Heading'..i].Size=UDim2.fromOffset(qw-110,30);q.Entries['Body'..i].Size=UDim2.fromOffset(qw-110,55);q.Entries['Body'..i].TextSize=qw<400 and 16 or 19 end
  elseif name=='RedeemCode' then
   q.Prompt.Size=UDim2.fromOffset(qw-56,32);q.Prompt.TextSize=qw<450 and 18 or 22
   q.CodeInput.Size=UDim2.fromOffset(qw<450 and qw-56 or qw-230,52)
   q.Redeem.Position=UDim2.fromOffset(qw<450 and 28 or qw-186,qw<450 and 190 or 126);q.Redeem.Size=UDim2.fromOffset(qw<450 and qw-56 or 158,44)
   q.Feedback.Position=UDim2.fromOffset(28,qw<450 and 242 or 182);q.Feedback.Size=UDim2.fromOffset(qw-56,26)
  else
   q.Cards.Size=UDim2.fromOffset(qw,math.max(60,qh-88))
   for _,card in q.Cards:GetChildren() do if card:IsA('Frame') then card.Size=UDim2.fromOffset(qw-40,90);card.Title.Size=UDim2.fromOffset(qw-120,27);card.Title.TextSize=qw<380 and 18 or 20;card.Description.Size=UDim2.fromOffset(qw-166,35);card.Description.TextSize=qw<380 and 11 or 13;card.Count.Position=UDim2.fromOffset(qw-94,35);card.Progress.Size=UDim2.fromOffset(qw-130,6);card.Progress.Fill.Size=UDim2.new(card.Name=='Mission2' and 1/3 or 0,0,1,0) end end
  end
 end
 local nw=math.min(340,size.X-48);gui.HUD.Notifications.Size=UDim2.fromOffset(nw,202)
 for _,notice in gui.HUD.Notifications:GetChildren() do if notice:IsA('Frame') then notice.Size=UDim2.fromOffset(nw,58);notice.Dismiss.Position=UDim2.fromOffset(nw-35,4);notice.Title.Size=UDim2.fromOffset(nw-95,23);notice.Detail.Size=UDim2.fromOffset(nw-75,21) end end
 gui:SetAttribute('Compact',compact)
end
local function open(name)
 for _,p in panels:GetChildren() do p.Visible=p.Name==name end
 active=name
 blur.Enabled=name~=nil
 gui:SetAttribute('ActivePanel',name or '')
 if name=='UpdateLog' then nav.Updates.Unread.Visible=false end
end
local function toggle(name) if active==name then open(nil) else open(name) end end
nav.Updates.Activated:Connect(function() toggle('UpdateLog') end)
nav.Codes.Activated:Connect(function() toggle('RedeemCode') end)
nav.Settings.Activated:Connect(function() toggle('Settings') end)
for _,p in panels:GetChildren() do p.Header.Close.Activated:Connect(function() open(nil) end) end
for _,n in {'LeaveQueue','PurchaseUnit'} do
 local p=panels[n];p.Cancel.Activated:Connect(function() open(nil) end)
 p.Confirm.Activated:Connect(function() open(nil);gui.HUD.Notifications.Visible=true end)
end
local settings=panels.Settings
for _,b in settings:GetChildren() do
 if b:IsA('TextButton') and b:GetAttribute('Tab') then
  b.Activated:Connect(function()
   for _,p in settings.Pages:GetChildren() do if p:IsA('Frame') then p.Visible=p.Name==b.Name end end
   for _,other in settings:GetChildren() do if other:IsA('TextButton') and other:GetAttribute('Tab') then
    local on=other==b;Theme.button(other,on,false)
   end end
  end)
 end
end
local audio=settings.Pages.Audio
for i=1,3 do
 local b=audio['Slider'..i]
 local function update(x)
  local v=math.clamp(math.floor((x-b.AbsolutePosition.X)/b.AbsoluteSize.X*100+.5),0,100)
  b:SetAttribute('Value',v);b.Fill.Size=UDim2.new(v/100,0,1,0);b.Thumb.Position=UDim2.new(v/100,-9,0,-6);audio['Value'..i].Text=v..'%'
 end
 local dragging=false
 b.InputBegan:Connect(function(input) if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then dragging=true;update(input.Position.X) end end)
 UIS.InputChanged:Connect(function(input) if dragging and (input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch) then update(input.Position.X) end end)
 UIS.InputEnded:Connect(function(input) if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then dragging=false end end)
end
for i=1,2 do
 local b=audio['Toggle'..i]
 b.Activated:Connect(function()
  local on=not b:GetAttribute('On');b:SetAttribute('On',on);b.Knob.Position=UDim2.fromOffset(on and 35 or 3,3)
  Theme.button(b,on,false)
 end)
end
local used=false
panels.RedeemCode.Redeem.Activated:Connect(function()
 local v=panels.RedeemCode.CodeInput.Text:upper():gsub('%s','')
 panels.RedeemCode.Feedback.Text=v=='HQ140' and (used and 'Code already redeemed in this session.' or 'Demo reward redeemed!') or 'Invalid code. Try HQ140.'
 if v=='HQ140' and not used then used=true;gui.HUD.Notifications.Visible=true end
end)
for _,p in gui.HUD.Notifications:GetChildren() do if p:IsA('Frame') then p.Dismiss.Activated:Connect(function() p.Visible=false end) end end
for _,b in settings.Pages:GetDescendants() do
 if b:IsA('TextButton') and b:GetAttribute('DemoOn')~=nil then
  b.Activated:Connect(function() local on=not b:GetAttribute('DemoOn');b:SetAttribute('DemoOn',on);Theme.button(b,on,false);b.Knob.Position=UDim2.fromOffset(on and 35 or 3,3) end)
 elseif b:IsA('TextButton') and b:GetAttribute('QualityChoice') then
  b.Activated:Connect(function() for _,other in b.Parent:GetChildren() do if other:IsA('TextButton') then Theme.button(other,other==b,false) end end end)
 end
end
-- Integration hook for panels without reference-established launchers.
local request=Instance.new('BindableEvent');request.Name='OpenPanel';request.Parent=gui
request.Event:Connect(open)
for _,b in gui:GetDescendants() do if b:IsA('TextButton') and b:FindFirstChild('Caption') then
 b:GetPropertyChangedSignal('Text'):Connect(function() b.Caption.Text=b.Text end)
 b:GetPropertyChangedSignal('TextColor3'):Connect(function() b.Caption.TextColor3=b.TextColor3 end)
end end
gui:GetPropertyChangedSignal('AbsoluteSize'):Connect(layout)
UIS.InputBegan:Connect(function(input,processed) if not processed and input.KeyCode==Enum.KeyCode.Escape then open(nil) end end)
layout()
