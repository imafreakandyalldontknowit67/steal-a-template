-- Second visual revision. Run after Build and before exporting; consumes real uploaded icon IDs.
local root=game.StarterGui:FindFirstChild('CommandHQ_Revision') or game.StarterGui.CommandHQ
local function new(class,name,p,props)
 local o=Instance.new(class);o.Name=name;for k,v in props or {} do o[k]=v end;o.Parent=p;return o
end
local function box(name,p,pos,size,color,alpha,z)
 return new('Frame',name,p,{Position=pos,Size=size,BackgroundColor3=color,BackgroundTransparency=alpha or 0,BorderSizePixel=0,ZIndex=z or 0})
end
local function corner(p,r) new('UICorner','Radius',p,{CornerRadius=UDim.new(0,r)}) end
local function gradient(p,colors,alpha,angle)
 return new('UIGradient','Finish',p,{Color=colors,Transparency=alpha or NumberSequence.new(0),Rotation=angle or 90})
end
local function holder(name,p,z)
 return new('ImageLabel',name,p,{BackgroundTransparency=1,Image='',Size=UDim2.fromScale(1,1),ZIndex=z or 0})
end
local function edge(name,p,pos,size,col,alpha,angle)
 local o=box(name,p,pos,size,col,alpha,2);o.Rotation=angle or 0;return o
end
local navy=Color3.fromRGB(8,24,36)
local ice=Color3.fromRGB(146,202,234)
local colors=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(35,65,83)),ColorSequenceKeypoint.new(.32,Color3.fromRGB(12,35,51)),ColorSequenceKeypoint.new(.74,Color3.fromRGB(7,24,37)),ColorSequenceKeypoint.new(1,Color3.fromRGB(17,40,55))})
local function shadow(p,r)
 local h=holder('SoftShadow',p,-2)
 for i=1,5 do
  local spread=i*2
  local s=box('Falloff'..i,h,UDim2.fromOffset(-spread,5-spread),UDim2.new(1,spread*2,1,spread*2),Color3.new(0,0,0),.95,-2);corner(s,r+spread)
 end
end
local function glass(p,chamfer)
 p.BackgroundTransparency=1
 if p:FindFirstChild('Shading') then p.Shading.Enabled=false end
 if p:FindFirstChild('Outline') then p.Outline.Enabled=false end
 local skin=holder('GlassSurface',p,0)
 local cut=chamfer and 14 or 0
 if cut>0 then
  local body=box('Body',skin,UDim2.fromOffset(0,cut),UDim2.new(1,0,1,-cut*2),Color3.new(1,1,1),.13);gradient(body,colors)
  for i=0,cut-1 do
   local top=box('TopCut'..i,skin,UDim2.fromOffset(cut-i,i),UDim2.new(1,-2*(cut-i),0,1),Color3.fromRGB(35,65,83),.13)
   box('BottomCut'..i,skin,UDim2.new(0,cut-i,1,-i-1),UDim2.new(1,-2*(cut-i),0,1),Color3.fromRGB(17,40,55),.13)
  end
  edge('TopRim',skin,UDim2.fromOffset(cut,0),UDim2.new(1,-cut*2,0,1),ice,.04)
  edge('BottomRim',skin,UDim2.new(0,cut,1,-1),UDim2.new(1,-cut*2,0,1),ice,.18)
  for _,right in {false,true} do
   edge(right and 'RightRim' or 'LeftRim',skin,UDim2.new(right and 1 or 0,right and -1 or 0,0,cut),UDim2.new(0,1,1,-cut*2),ice,.13)
   for _,bottom in {false,true} do
    local f=edge('CornerBevel',skin,UDim2.new(right and 1 or 0,right and -7 or 7,bottom and 1 or 0,bottom and -7 or 7),UDim2.fromOffset(19.8,1),ice,.08,(right==bottom) and -45 or 45);f.AnchorPoint=Vector2.new(.5,.5)
   end
  end
 else
  local body=box('Body',skin,UDim2.fromOffset(0,0),UDim2.fromScale(1,1),Color3.new(1,1,1),.2);corner(body,8);gradient(body,colors)
  new('UIStroke','Rim',body,{Color=ice,Thickness=1,Transparency=.48})
 end
 local reflection=box('AngledReflection',skin,UDim2.fromOffset(cut+1,1),UDim2.new(1,-cut*2-2,.42,0),Color3.fromRGB(141,191,217),0)
 gradient(reflection,ColorSequence.new(Color3.new(1,1,1)),NumberSequence.new({NumberSequenceKeypoint.new(0,.92),NumberSequenceKeypoint.new(.35,.98),NumberSequenceKeypoint.new(1,1)}),90)
 edge('InsetUpperHighlight',skin,UDim2.fromOffset(cut+2,2),UDim2.new(1,-cut*2-4,0,1),Color3.fromRGB(209,235,249),.82)
 edge('InsetLowerShade',skin,UDim2.new(0,cut+2,1,-3),UDim2.new(1,-cut*2-4,0,1),Color3.new(0,0,0),.4)
 shadow(p,cut>0 and 12 or 8)
end
local goldA=Color3.fromRGB(255,188,66)
local goldB=Color3.fromRGB(193,113,18)
local function button(p,on)
 if not p:FindFirstChildWhichIsA('UICorner') then corner(p,7) end
 for _,c in p:GetChildren() do if c:IsA('UIPadding') then c:Destroy() end end
 p.BackgroundTransparency=1
 if p:FindFirstChild('Shading') then p.Shading.Enabled=false end
 local old=p:FindFirstChild('ButtonSurface');if old then old:Destroy() end
 local surface=holder('ButtonSurface',p,0)
 local body=box('Body',surface,UDim2.fromOffset(0,0),UDim2.fromScale(1,1),Color3.new(1,1,1),on and .02 or .18);corner(body,7)
 gradient(body,ColorSequence.new(on and goldA or Color3.fromRGB(34,61,78),on and goldB or Color3.fromRGB(11,30,44)))
 local gloss=box('Specular',surface,UDim2.fromOffset(2,2),UDim2.new(1,-4,.48,0),Color3.new(1,1,1),0);corner(gloss,6)
 gradient(gloss,ColorSequence.new(Color3.new(1,1,1)),NumberSequence.new({NumberSequenceKeypoint.new(0,on and .72 or .88),NumberSequenceKeypoint.new(1,1)}))
 edge('TopLight',surface,UDim2.fromOffset(6,1),UDim2.new(1,-12,0,1),on and Color3.fromRGB(255,230,167) or ice,on and .15 or .47)
 edge('BottomShadow',surface,UDim2.new(0,6,1,-2),UDim2.new(1,-12,0,1),Color3.new(0,0,0),.4)
 if p:FindFirstChild('Outline') then p.Outline.Enabled=true;p.Outline.Color=on and Color3.fromRGB(255,202,110) or Color3.fromRGB(112,158,185);p.Outline.Transparency=on and .04 or .15 end
 p.TextColor3=Color3.fromRGB(245,248,250)
 p.TextStrokeColor3=Color3.fromRGB(2,10,17);p.TextStrokeTransparency=.7
 local caption=new('TextLabel','Caption',p,{Text=p.Text,FontFace=p.FontFace,TextSize=p.TextSize,TextColor3=p.TextColor3,TextStrokeColor3=Color3.fromRGB(2,10,17),TextStrokeTransparency=.7,BackgroundTransparency=1,Size=UDim2.fromScale(1,1),ZIndex=4})
 p.TextTransparency=1
 if p:GetAttribute('Tab') or p.Name=='Updates' or p.Name=='Codes' then caption.Position=UDim2.fromOffset(44,0);caption.Size=UDim2.new(1,-52,1,0) end
end
for _,p in root.Panels:GetChildren() do
 glass(p,true)
 p.Header.BackgroundTransparency=1
 if p.Header:FindFirstChild('Corners') then p.Header.Corners:Destroy() end
 local hg=holder('HeaderGlass',p.Header,0)
 local f=box('HeaderReflection',hg,UDim2.fromOffset(15,1),UDim2.new(1,-30,1,-1),Color3.new(1,1,1),0)
 gradient(f,ColorSequence.new(Color3.fromRGB(80,117,139),Color3.fromRGB(19,44,60)),NumberSequence.new({NumberSequenceKeypoint.new(0,.86),NumberSequenceKeypoint.new(1,.99)}),90)
 p.Divider.BackgroundColor3=ice;p.Divider.BackgroundTransparency=.57
 local dark=box('HeaderUnderCut',p.Header,UDim2.new(0,1,1,1),UDim2.new(1,-2,0,1),Color3.new(0,0,0),.45,0)
 if p:FindFirstChild('GoldAccent') then p.GoldAccent:Destroy() end
 local accent=holder('GoldAccent',p.Header,2);accent.Size=UDim2.new(0,36,1,0)
 -- A clipped ribbon, from the top edge to the left edge: no rotated bar overhang.
 for y=0,63 do
  local x=25-y*25/63;local width=math.min(9,36-x)
  local row=box('Ribbon'..y,accent,UDim2.new(0,math.max(0,x),y/64,0),UDim2.new(0,width,1/64,.25),Color3.fromRGB(255,179,43),0,2)
  gradient(row,ColorSequence.new(Color3.fromRGB(255,215,127),Color3.fromRGB(241,151,25)),nil,0)
 end
 for _,t in p:GetDescendants() do
  if t:IsA('TextLabel') then t.TextStrokeColor3=Color3.fromRGB(1,10,17);t.TextStrokeTransparency=t.FontFace.Weight==Enum.FontWeight.Bold and .65 or .86 end
 end
end
for _,b in root:GetDescendants() do
 if b:IsA('TextButton') and b.Name~='Close' and b.Name~='Dismiss' and not b.Name:match('Slider') then button(b,b.Name=='Audio' or b.Name=='Redeem' or b.Name=='Confirm' or b.Name=='Toggle1') end
end
local settings=root.Panels.Settings
glass(settings.Pages,false)
-- Decorations live in ImageLabel containers so responsive page discovery ignores them.
for _,pg in settings.Pages:GetChildren() do if pg:IsA('Frame') then
 pg.Rule.BackgroundColor3=ice;pg.Rule.BackgroundTransparency=.55
 local cap=holder('SectionFinish',pg,0);cap.Size=UDim2.new(1,0,0,54)
 local f=box('HeaderSheen',cap,UDim2.fromOffset(1,1),UDim2.new(1,-2,1,-1),Color3.new(1,1,1),0)
 gradient(f,ColorSequence.new(Color3.fromRGB(63,100,123),Color3.fromRGB(18,44,60)),NumberSequence.new(.82,.98))
end end
for i=1,3 do
 local a=settings.Pages.Audio
 local s=a['Slider'..i];s.BackgroundColor3=Color3.fromRGB(72,109,135);s.BackgroundTransparency=.05
 gradient(s,ColorSequence.new(Color3.fromRGB(79,117,142),Color3.fromRGB(46,76,98)))
 s.Fill.BackgroundColor3=Color3.new(1,1,1);gradient(s.Fill,ColorSequence.new(Color3.fromRGB(255,193,76),Color3.fromRGB(241,149,27)))
 s.Thumb.BackgroundColor3=Color3.new(1,1,1);gradient(s.Thumb,ColorSequence.new(Color3.fromRGB(255,207,114),Color3.fromRGB(229,137,20)))
 new('UIStroke','InsetShadow',s,{Color=Color3.fromRGB(1,12,22),Thickness=1,Transparency=.5})
 a['Separator'..i].BackgroundColor3=ice;a['Separator'..i].BackgroundTransparency=.5
 local sep=a['Separator'..i];local hair=box('DarkEdge',sep,UDim2.fromOffset(0,1),UDim2.fromScale(1,1),Color3.new(0,0,0),.55)
end
for i=1,2 do
 local b=settings.Pages.Audio['Toggle'..i];b.ButtonSurface.Body.Radius.CornerRadius=UDim.new(1,0);b.ButtonSurface.Specular.Radius.CornerRadius=UDim.new(1,0)
 local first=true;for _,c in b:GetChildren() do if c:IsA('UICorner') then if first then c.CornerRadius=UDim.new(1,0);first=false else c:Destroy() end end end
 local k=b.Knob;k.BackgroundColor3=Color3.new(1,1,1);gradient(k,ColorSequence.new(Color3.fromRGB(255,255,255),Color3.fromRGB(194,209,219)))
 new('UIStroke','KnobEdge',k,{Color=Color3.fromRGB(10,27,39),Thickness=1,Transparency=.12})
end
local v=root.Panels.UpdateLog.Version;v.BackgroundColor3=Color3.new(1,1,1);gradient(v,ColorSequence.new(Color3.fromRGB(78,73,56),Color3.fromRGB(42,46,45)),NumberSequence.new(.25,.3))
local input=root.Panels.RedeemCode.CodeInput;input.BackgroundColor3=Color3.fromRGB(3,18,30);input.BackgroundTransparency=.24
input.Outline.Color=ice;input.Outline.Transparency=.22
for _,card in root.Panels.Missions.Cards:GetChildren() do if card:IsA('Frame') then glass(card,false) end end
for _,notice in root.HUD.Notifications:GetChildren() do if notice:IsA('Frame') then glass(notice,false) end end
local function label(p,name,value,pos,size,fontSize,bold)
 local t=new('TextLabel',name,p,{Text=value,Position=pos,Size=size,BackgroundTransparency=1,TextColor3=bold and Color3.fromRGB(239,245,249) or Color3.fromRGB(173,196,211),TextSize=fontSize,TextWrapped=true,TextXAlignment=Enum.TextXAlignment.Left,FontFace=Font.new('rbxasset://fonts/families/RobotoCondensed.json',bold and Enum.FontWeight.Bold or Enum.FontWeight.Regular),ZIndex=2})
 t.TextStrokeColor3=Color3.fromRGB(1,10,17);t.TextStrokeTransparency=.8;return t
end
local function fakeToggle(pg,i,title,detail,on)
 local y=64+(i-1)*72
 local row=holder('Preference'..i,pg,1);row.Position=UDim2.fromOffset(20,y);row.Size=UDim2.new(1,-40,0,70)
 label(row,'Label',title,UDim2.fromOffset(6,1),UDim2.new(1,-100,0,30),21,true)
 label(row,'Description',detail,UDim2.fromOffset(6,30),UDim2.new(1,-100,0,30),14,false)
 local b=new('TextButton','DemoToggle',row,{Text='',Position=UDim2.new(1,-70,0,18),Size=UDim2.fromOffset(64,32),BackgroundTransparency=1,AutoButtonColor=false});b:SetAttribute('DemoOn',on)
 corner(b,20)
 new('UIStroke','Outline',b,{ApplyStrokeMode=Enum.ApplyStrokeMode.Border,Color=ice,Thickness=1});button(b,on);b.ButtonSurface.Body.Radius.CornerRadius=UDim.new(1,0);b.ButtonSurface.Specular.Radius.CornerRadius=UDim.new(1,0)
 local k=box('Knob',b,UDim2.fromOffset(on and 35 or 3,3),UDim2.fromOffset(26,26),Color3.new(1,1,1),0,2);corner(k,20);gradient(k,ColorSequence.new(Color3.fromRGB(255,255,255),Color3.fromRGB(196,214,224)))
 edge('Separator',row,UDim2.new(0,0,1,-1),UDim2.new(1,0,0,1),ice,.72)
end
for _,name in {'Game','Graphics','Controls'} do
 local pg=settings.Pages[name]
 for _,c in pg:GetChildren() do if c:IsA('TextLabel') and c.Name~='Heading' then c:Destroy() end end
end
for i,d in {{'Auto Deploy','Join the next deployment automatically.',false},{'Teammate Names','Show names above friendly units.',true},{'Camera Shake','Enable shake from nearby explosions.',true},{'Damage Numbers','Show damage dealt to enemy units.',true}} do fakeToggle(settings.Pages.Game,i,d[1],d[2],d[3]) end
local graphics=settings.Pages.Graphics
local quality=holder('QualitySettings',graphics,1);quality.Position=UDim2.fromOffset(26,65);quality.Size=UDim2.new(1,-52,0,70)
label(quality,'Label','Render Quality',UDim2.fromOffset(0,0),UDim2.new(.5,0,0,30),21,true)
local options=holder('Choices',quality,1);options.Position=UDim2.new(.48,0,0,2);options.Size=UDim2.new(.52,0,0,40)
for i,name in {'LOW','MED','HIGH'} do
 local b=new('TextButton',name,options,{Text=name,Position=UDim2.new((i-1)/3,3,0,0),Size=UDim2.new(1/3,-6,1,0),TextSize=16,FontFace=Font.new('rbxasset://fonts/families/RobotoCondensed.json',Enum.FontWeight.Bold),AutoButtonColor=false});new('UIStroke','Outline',b,{ApplyStrokeMode=Enum.ApplyStrokeMode.Border,Color=ice,Thickness=1});button(b,i==3);b:SetAttribute('QualityChoice',true)
end
for i,d in {{'Bloom','Enable glow from bright light sources.',true},{'Dynamic Shadows','Render shadows cast by units and props.',true},{'Particle Effects','Show smoke, sparks and debris.',true}} do fakeToggle(graphics,i+1,d[1],d[2],d[3]) end
for i,d in {{'Move','W  A  S  D'},{'Sprint','LEFT SHIFT'},{'Jump','SPACE'},{'Reload','R'},{'Interact','E'}} do
 local pg=settings.Pages.Controls;local row=holder('Binding'..i,pg,1);row.Position=UDim2.fromOffset(26,70+(i-1)*58);row.Size=UDim2.new(1,-52,0,52)
 label(row,'Action',d[1],UDim2.fromOffset(0,0),UDim2.new(.45,0,1,0),21,true)
 local key=new('TextButton','BindingKey',row,{Text=d[2],Position=UDim2.new(.5,0,0,5),Size=UDim2.new(.5,0,0,40),TextSize=16,FontFace=Font.new('rbxasset://fonts/families/RobotoCondensed.json',Enum.FontWeight.Bold),AutoButtonColor=false});new('UIStroke','Outline',key,{ApplyStrokeMode=Enum.ApplyStrokeMode.Border,Color=ice,Thickness=1});button(key,false)
 edge('Separator',row,UDim2.new(0,0,1,0),UDim2.new(1,0,0,1),ice,.75)
end
root:SetAttribute('Version','0.2.0')
-- Generated gear attempts introduced alpha noise; preserve a crisp hollow silhouette natively.
for _,old in root:GetDescendants() do if old:IsA('Frame') and old.Name=='gearIcon' then
 local p=old.Parent;local pos=old.Position;local scale=old.IconScale.Scale;old:Destroy()
 local cog=holder('gearIcon',p,3);cog.Position=pos;cog.Size=UDim2.fromOffset(28,28);new('UIScale','IconScale',cog,{Scale=scale})
 local points={}
 for i=0,7 do for _,v in {{-22.5,10.5},{-10,10.5},{-10,13.5},{10,13.5},{10,10.5},{22.5,10.5}} do local a=math.rad(i*45+v[1]);table.insert(points,Vector2.new(14+math.cos(a)*v[2],14+math.sin(a)*v[2])) end end
 for i,a in points do local b=points[i%#points+1];local delta=b-a;local midpoint=(a+b)/2;local seg=edge('CogContour',cog,UDim2.fromOffset(midpoint.X,midpoint.Y),UDim2.fromOffset(delta.Magnitude+.25,1.5),Color3.fromRGB(245,249,252),0,math.deg(math.atan2(delta.Y,delta.X)));seg.AnchorPoint=Vector2.new(.5,.5) end
 local ring=new('Frame','CenterRing',cog,{Position=UDim2.fromOffset(9,9),Size=UDim2.fromOffset(10,10),BackgroundTransparency=1,ZIndex=3});corner(ring,10);new('UIStroke','RingLine',ring,{Color=Color3.fromRGB(245,249,252),Thickness=1.5})
end end
local assets=require(root.Assets)
for name,asset in assets do
 local b=settings[name]
 for _,c in b:GetChildren() do if c:IsA('Frame') and c.Name:match('Icon$') then c:Destroy() end end
 local im=new('ImageLabel','GeneratedIcon',b,{BackgroundTransparency=1,Image=asset.Id,ImageRectOffset=asset.Offset,ImageRectSize=asset.Size,Position=UDim2.fromOffset(16,10),Size=UDim2.fromOffset(30,28),ScaleType=Enum.ScaleType.Fit,ZIndex=3})
 im:SetAttribute('IsIcon',true)
 for _,x in {-.3,.3} do local ink=new('ImageLabel','StrokeReinforcement',im,{BackgroundTransparency=1,Image=asset.Id,Position=UDim2.fromOffset(x,0),Size=UDim2.fromScale(1,1),ScaleType=Enum.ScaleType.Fit,ZIndex=3}) end
end
new('BlurEffect','PanelBlur',root,{Size=12,Enabled=false})
return 'Glass finish and generated icon assets applied.'
