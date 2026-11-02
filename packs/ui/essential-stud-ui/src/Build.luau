-- Essential STUD UI: edit-time native authoring. Fresh kit; no previous pack artwork.
local S=game:GetService('StarterGui')
assert(not S:FindFirstChild('EssentialStudUI_Building'),'A pending build exists; inspect it first')
local function make(class,p,t) local o=Instance.new(class); for k,v in pairs(t or {}) do o[k]=v end; o.Parent=p; return o end
local rgb=Color3.fromRGB
local white=rgb(255,255,255); local black=rgb(10,14,20)
local palettes={gold={rgb(255,246,0),rgb(255,146,0)},green={rgb(157,255,22),rgb(56,211,0)},pink={rgb(255,28,111),rgb(239,0,53)},blue={rgb(0,202,255),rgb(24,94,240)},purple={rgb(245,85,255),rgb(133,26,222)},orange={rgb(255,179,30),rgb(255,92,5)},gray={rgb(177,190,194),rgb(78,84,88)},cyan={rgb(0,249,247),rgb(0,153,235)}}
local atlas='rbxassetid://93221120087757'
local icons={crown=0,teleporter=1,shoe=2,gift=3,cash=4,key=5,potion=6,chest=7,basket=8,calendar=9,check=10,gear=11,cat=12,coin=13,flame=14,shield=15}
local function frame(p,n,x,y,w,h,c) return make('Frame',p,{Name=n,Position=UDim2.fromOffset(x,y),Size=UDim2.fromOffset(w,h),BackgroundColor3=c or white,BorderSizePixel=0}) end
local function clear(p,n,x,y,w,h) local o=frame(p,n,x,y,w,h);o.BackgroundTransparency=1;return o end
local function stroke(p,c,t) return make('UIStroke',p,{Color=c or black,Thickness=t or 3,ApplyStrokeMode=Enum.ApplyStrokeMode.Border,LineJoinMode=Enum.LineJoinMode.Round}) end
local function label(p,n,txt,x,y,w,h,size,color) return make('TextLabel',p,{Name=n,Text=txt,Position=UDim2.fromOffset(x,y),Size=UDim2.fromOffset(w,h),BackgroundTransparency=1,Font=Enum.Font.FredokaOne,TextSize=size or 28,TextColor3=color or white,TextStrokeColor3=black,TextStrokeTransparency=0,TextWrapped=true,BorderSizePixel=0,ZIndex=6}) end
local function icon(p,n,x,y,w,h)
 local details={cube=0,orb=1,flatcash=2,clock=3};local detail=details[n];local id=icons[n];local o=make('ImageLabel',p,{Name='Icon_'..n,Position=UDim2.fromOffset(x,y),Size=UDim2.fromOffset(w,h or w),BackgroundTransparency=1,Image=atlas,ScaleType=Enum.ScaleType.Fit,ZIndex=4})
 if id then local col=id%4;local row=math.floor(id/4);o.ImageRectOffset=Vector2.new(math.floor(col*256),math.floor(row*256));o.ImageRectSize=Vector2.new(256,256) end
 if detail then o.Image='rbxassetid://122440188309227';o.ImageRectOffset=Vector2.new(detail%2*512,math.floor(detail/2)*512);o.ImageRectSize=Vector2.new(512,512) end
 return o
end
local rainbow=ColorSequence.new({ColorSequenceKeypoint.new(0,rgb(255,25,0)),ColorSequenceKeypoint.new(.18,rgb(255,220,0)),ColorSequenceKeypoint.new(.38,rgb(101,255,0)),ColorSequenceKeypoint.new(.58,rgb(0,215,255)),ColorSequenceKeypoint.new(.78,rgb(100,70,255)),ColorSequenceKeypoint.new(1,rgb(215,0,255))})
local function surface(p,theme,studSize)
 local pair=palettes[theme] or palettes.gold;p.BackgroundColor3=white
 make('UIGradient',p,{Color=theme=='rainbow' and rainbow or ColorSequence.new(pair[1],pair[2]),Rotation=theme=='rainbow' and 0 or 90})
 local w,h=p.Size.X.Offset,p.Size.Y.Offset;local s=studSize or 32
 local tex=clear(p,'Studs',0,0,w,h);tex.ClipsDescendants=true;tex.ZIndex=2
 for y=7,h,s do for x=7,w,s do
  local a=frame(tex,'Stud',x,y,s*.43,s*.43,black);a.BackgroundTransparency=.92;a.ZIndex=2
  local b=frame(a,'Highlight',1,1,s*.43-3,s*.43-3,white);b.BackgroundTransparency=.94;b.ZIndex=2
 end end
 local rim=clear(p,'InnerRim',4,4,w-8,h-8);rim.ZIndex=3;stroke(rim,white,2).Transparency=.35
 stroke(p,black,4)
 return p
end
local function rays(p,x,y,w,h)
 local r=clear(p,'Rays',x,y,w,h);r.ClipsDescendants=true;r.ZIndex=3
 for i=0,11 do local pivot=clear(r,'RayPivot',0,0,w,h);pivot.Rotation=i*30;local a=frame(pivot,'Ray',w/2,h/2,w*.46,math.max(5,h*.055),white);a.AnchorPoint=Vector2.new(0,.5);a.BackgroundTransparency=.87;a.ZIndex=3 end
 return r
end
local function button(p,n,txt,x,y,w,h,theme,action)
 local o=make('TextButton',p,{Name=n,Position=UDim2.fromOffset(x,y),Size=UDim2.fromOffset(w,h),Text='',AutoButtonColor=false,BorderSizePixel=0,ZIndex=5});surface(o,theme or 'green',24)
 local t=label(o,'Caption',txt,4,1,w-8,h-2,math.min(42,h*.66));if action then o:SetAttribute('Action',action) end
 make('UIScale',o,{Name='HoverScale'});return o
end
local function robux(p,x,y,size)
 local c=clear(p,'Robux',x,y,size,size);c.ZIndex=8
 for i=0,7 do local angle=math.rad(i*45);local e=frame(c,'Edge',size*.5+math.cos(angle)*size*.37,size*.5+math.sin(angle)*size*.37,size*.33,size*.13,white);e.AnchorPoint=Vector2.new(.5,.5);e.Rotation=i*45+90;e.ZIndex=8 end
 local hole=frame(c,'Center',size*.36,size*.36,size*.28,size*.28,white);hole.ZIndex=9;stroke(hole,rgb(55,122,22),size*.06);return c
end
local function clockArt(p,x,y,size)
 local c=frame(p,'ClockArt',x,y,size,size,rgb(239,16,89));make('UICorner',c,{CornerRadius=UDim.new(1,0)});stroke(c,black,5)
 local disk=frame(c,'Dial',size*.15,size*.15,size*.7,size*.7,white);make('UICorner',disk,{CornerRadius=UDim.new(1,0)})
 for i=0,3 do local a=math.rad(i*90);local tick=frame(disk,'Tick',size*.35+math.cos(a)*size*.24,size*.35+math.sin(a)*size*.24,size*.12,size*.07,rgb(239,16,89));tick.AnchorPoint=Vector2.new(.5,.5);tick.Rotation=i*90 end
 local h=frame(disk,'Hand',size*.31,size*.15,size*.08,size*.25,rgb(239,16,89));local h2=frame(disk,'Hand2',size*.31,size*.32,size*.23,size*.08,rgb(239,16,89));return c
end
local function price(p,n,x,y,w,h,action,value)
 local b=button(p,n,'',x,y,w,h,'green',action);robux(b,w*.24,7,h-14);label(b,'Amount',tostring(value or 1),w*.48,1,w*.35,h-2,h*.7);return b
end
local function wheelArt(p,n,x,y,d,labels)
 local o=clear(p,n,x,y,d,d);local colors={rgb(255,33,46),rgb(255,237,0),rgb(92,255,14),rgb(26,216,230),rgb(178,29,254)}
 local disk=frame(o,'Rim',0,0,d,d,white);make('UICorner',disk,{CornerRadius=UDim.new(1,0)});stroke(disk,black,4)
 local rot=clear(o,'Rotor',5,5,d-10,d-10);local dd=d-10
 -- Native radial strips approximate five continuous wedges; all labels and icons rotate with rotor.
 for i=0,179 do local deg=i*2;local pivot=clear(rot,'Segment',0,0,dd,dd);pivot.Rotation=deg-90;local f=frame(pivot,'Wedge',dd/2,dd/2,dd*.495,dd*.018,colors[math.floor(deg/72)+1]);f.AnchorPoint=Vector2.new(0,.5);f.ZIndex=3 end
 for j=0,4 do
  local rad=math.rad(j*72-90);local pivot=clear(rot,'LinePivot',0,0,dd,dd);pivot.Rotation=j*72-90;local line=frame(pivot,'Divider',dd/2,dd/2,dd/2,3,black);line.AnchorPoint=Vector2.new(0,.5);line.ZIndex=4
  local a=math.rad(j*72+36-90); local sz=dd*.29;local cx=dd/2+math.cos(a)*dd*.31;local cy=dd/2+math.sin(a)*dd*.31
  if labels then local ic=icon(rot,'cash',cx-sz/2,cy-sz*.62,sz,sz);ic.Rotation=j*72+36
   local t=label(rot,'Prize'..j,({'100 Cash','1K Cash','10K Cash','100K Cash','150K Cash'})[j+1],cx-sz*.65,cy+sz*.25,sz*1.3,sz*.3,dd*.034);t.Rotation=j*72+36
  end
 end
 if labels then
  local tex=clear(rot,'WheelStuds',0,0,dd,dd);tex.ZIndex=3
  for y=20,dd-20,28 do for x=20,dd-20,28 do if (x+5-dd/2)^2+(y+5-dd/2)^2<(dd/2-16)^2 then
   local a=frame(tex,'Stud',x,y,10,10,black);a.BackgroundTransparency=.91;a.ZIndex=3
   local b=frame(a,'Light',1,1,7,7,white);b.BackgroundTransparency=.94;b.ZIndex=3
  end end end
 end
 local hub=frame(rot,'Hub',dd*.445,dd*.445,dd*.11,dd*.11,black);hub.ZIndex=7;make('UICorner',hub,{CornerRadius=UDim.new(1,0)})
 return o
end
local root=make('ScreenGui',nil,{Name='EssentialStudUI_Building',Enabled=false,IgnoreGuiInset=true,ResetOnSpawn=false,ZIndexBehavior=Enum.ZIndexBehavior.Sibling,DisplayOrder=10})
root:SetAttribute('Kit','Essential STUD UI');root:SetAttribute('Version','1.0.0');root:SetAttribute('DemoOnly',true)
root.Parent=S
local viewport=workspace.CurrentCamera.ViewportSize
local canvas=clear(root,'Canvas',0,0,1920,1080);canvas.AnchorPoint=Vector2.new(.5,.5);canvas.Position=UDim2.fromScale(.5,.5)
make('UIScale',canvas,{Name='ViewportScale',Scale=math.min(viewport.X/1920,viewport.Y/1080)})
local hud=clear(canvas,'HUD',0,0,1920,1080)
local nav=clear(hud,'Navigation',20,310,280,510)
local navs={{'Shop','basket','gold',0,0,130,130},{'Rewards','gift','green',150,0,130,130},{'Daily','calendar','pink',0,150,130,130},{'Codes','check','blue',150,150,130,130},{'Wheel','wheel','rainbow',0,300,280,100},{'Time','clock','pink',90,420,100,100}}
for _,v in ipairs(navs) do
 local b=button(nav,v[1],'',v[4],v[5],v[6],v[7],v[3],'Open:'..v[1]);
 if v[2]=='wheel' then wheelArt(b,'WheelIcon',90,-2,100,false) elseif v[2]=='clock' then
  icon(b,'clock',16,5,68,68)
 else icon(b,v[2],18,5,94,94) end
 label(b,'Title',v[1]=='Wheel' and 'Lucky Wheel' or v[1],2,v[7]-43,v[6]-4,40,v[1]=='Wheel' and 32 or 29)
end
task.wait()
local settings=make('ImageButton',hud,{Name='SettingsButton',Position=UDim2.fromOffset(1850,16),Size=UDim2.fromOffset(50,50),BackgroundColor3=rgb(24,42,48),Image='',AutoButtonColor=false});make('UICorner',settings,{CornerRadius=UDim.new(1,0)});icon(settings,'gear',5,5,40,40);settings:SetAttribute('Action','Open:Settings')
local cash=clear(hud,'Cash',22,982,420,80);icon(cash,'flatcash',0,-9,100,100);label(cash,'Total','0',100,0,300,80,56,rgb(132,255,31)).TextXAlignment=Enum.TextXAlignment.Left
local offers=clear(hud,'Offers',1690,210,220,650)
for i,dat in ipairs({{'Secret Pack','potion'},{'Teleporter','teleporter'},{'x5 Spins','wheel'}}) do
 local b=make('TextButton',offers,{Name='Offer'..i,Position=UDim2.fromOffset(0,(i-1)*220),Size=UDim2.fromOffset(220,205),Text='',BackgroundTransparency=1,AutoButtonColor=false});b:SetAttribute('Action','Offer');b:SetAttribute('Product',dat[1]);rays(b,8,0,200,180)
 local slot=clear(b,'Art',45,0,140,140);if dat[2]=='wheel' then wheelArt(slot,'WheelIcon',0,0,140,false) else icon(slot,dat[2],0,0,140,140) end
 label(b,'Title',dat[1],0,135,220,65,37);robux(b,140,0,35);label(b,'Price','1',177,-3,35,40,34,rgb(145,255,75))
end
local panels=clear(canvas,'Panels',0,0,1920,1080);panels.ZIndex=10
local function panel(n,title,ic,w,h,theme)
 local p=frame(panels,n,0,0,w,h,rgb(63,81,105));p.AnchorPoint=Vector2.new(.5,.5);p.Position=UDim2.fromScale(.5,.5);p.BackgroundTransparency=.14;p.Visible=false;p.ZIndex=10;stroke(p,black,4)
 p:SetAttribute('HomeY',.5)
 local head=frame(p,'Header',0,0,w,90);surface(head,theme,36);icon(head,ic,12,7,74,74);label(head,'Title',title,95,5,w-190,77,48).TextXAlignment=Enum.TextXAlignment.Left
 button(head,'Close','X',w-79,12,64,64,'pink','Close');return p
end
local shop=panel('Shop','Shop','cube',960,720,'gold')
local scroll=make('ScrollingFrame',shop,{Name='Content',Position=UDim2.fromOffset(16,105),Size=UDim2.fromOffset(928,598),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=6,ScrollBarImageColor3=rgb(163,181,197),CanvasSize=UDim2.fromOffset(0,1618),ScrollingDirection=Enum.ScrollingDirection.Y,ClipsDescendants=true})
label(scroll,'Limited','- LIMITED TIME -',0,0,920,44,30)
for i,dat in ipairs({{'STARTER PACK','pink','flame','shield'},{'SECRET PACK','gray','key','potion'}}) do
 local f=frame(scroll,'Pack'..i,14,52+(i-1)*240,888,220);surface(f,dat[2],34);rays(f,70,7,220,210);rays(f,450,7,220,210);label(f,'Title',dat[1],14,8,440,40,32).TextXAlignment=Enum.TextXAlignment.Left
 icon(f,dat[3],110,42,140,140);icon(f,dat[4],490,42,140,140);label(f,'Item1','Title',95,166,170,44,32);label(f,'Item2','Title',475,166,170,44,32)
 price(f,'Purchase',700,150,164,56,'Buy:'..(i==1 and 'Starter Pack' or 'Secret Pack'));if i==2 then label(f,'Stock','Limited Stock',610,8,265,38,28,rgb(255,55,55)) end
end
label(scroll,'Passes','- Gamepasses -',0,535,920,48,36)
for i,dat in ipairs({{'VIP','crown','gold'},{'Teleporter','teleporter','purple'},{'x2 Speed','shoe','cyan'}}) do
 local c=frame(scroll,dat[1],14+(i-1)*300,590,282,350);surface(c,dat[3],34);rays(c,0,55,282,240);label(c,'Title',dat[1],5,8,272,50,39);icon(c,dat[2],42,70,200,200)
 price(c,'Buy',12,278,194,58,'Buy:'..dat[1]);local g=button(c,'Gift','',219,278,51,58,'gold','Gift:'..dat[1]);icon(g,'gift',3,4,45,48)
end
task.wait()
label(scroll,'Products','- Products -',0,960,920,48,36)
for i,name in ipairs({'1K Cash','100K Cash','1M Cash','10M Cash'}) do
 local c=frame(scroll,'Product'..i,14+((i-1)%2)*450,1020+math.floor((i-1)/2)*266,438,250);surface(c,'green',32);rays(c,0,0,190,240);icon(c,'cash',18,70,160,155);label(c,'Title',name,155,8,270,44,38)
 price(c,'Buy',193,177,220,54,'Buy:'..name);local g=button(c,'Gift','',368,70,45,42,'gold','Gift:'..name);icon(g,'gift',0,0,44,42)
end
local gift=panel('Gift','Gift','gift',620,730,'purple');label(gift,'Subtitle','- Gift "VIP" To -',0,95,620,45,30)
local people=make('ScrollingFrame',gift,{Name='People',Position=UDim2.fromOffset(24,148),Size=UDim2.fromOffset(572,450),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=5,CanvasSize=UDim2.fromOffset(0,450)})
for i,dat in ipairs({{'Dallas700','Pistol_Pete26'},{'Max','M_Gameing4pro'},{'Sayzz','Sayzz'}}) do
 local row=frame(people,'Player'..i,3,(i-1)*150,560,140);surface(row,'blue',28)
 local avatar=frame(row,'Avatar',8,10,112,118,rgb(57,91,128));avatar.ZIndex=4;local portrait=make('ImageLabel',avatar,{Name='Portrait',BackgroundTransparency=1,Size=UDim2.fromScale(1,1),Image='rbxthumb://type=AvatarHeadShot&id='..({1868543425,2706565897,120902307})[i]..'&w=150&h=150',ZIndex=4})
 label(row,'Display',dat[1],134,12,335,66,44).TextXAlignment=Enum.TextXAlignment.Left;label(row,'Username',dat[2],138,76,330,35,24).TextXAlignment=Enum.TextXAlignment.Left
 local g=button(row,'Send','',474,37,70,70,'gold','Recipient:'..dat[2]);icon(g,'gift',5,5,60,60)
end
local function textbox(p,n,placeholder,x,y,w,h)
 local t=make('TextBox',p,{Name=n,Position=UDim2.fromOffset(x,y),Size=UDim2.fromOffset(w,h),BackgroundColor3=rgb(21,35,47),BackgroundTransparency=.25,Text='',PlaceholderText=placeholder,PlaceholderColor3=white,TextColor3=white,TextStrokeTransparency=0,TextStrokeColor3=black,Font=Enum.Font.FredokaOne,TextSize=42,TextXAlignment=Enum.TextXAlignment.Left,ClearTextOnFocus=false,BorderSizePixel=0});stroke(t,black,3);make('UIPadding',t,{PaddingLeft=UDim.new(0,15)});return t
end
textbox(gift,'UsernameInput','Username Here',24,620,465,80);local send=button(gift,'Submit','',510,620,85,80,'green','RecipientInput');icon(send,'check',9,8,64,64)
local confirm=frame(panels,'Confirm',0,0,620,390,rgb(62,79,104));confirm.AnchorPoint=Vector2.new(.5,.5);confirm.Position=UDim2.fromScale(.5,.5);confirm.Visible=false;confirm.ZIndex=10;stroke(confirm,black,4)
label(confirm,'Question','Are you sure you\nwant to gift "VIP"\nto M_Gameing4pro?',25,30,570,230,45);button(confirm,'No','NO',40,285,250,75,'pink','Open:Gift');button(confirm,'Yes','YES',330,285,250,75,'green','ConfirmGift')
local rewards=panel('Rewards','Rewards','chest',820,510,'orange');local art=frame(rewards,'RewardArt',25,120,375,355,rgb(31,53,64));art.BackgroundTransparency=.4;rays(art,0,0,375,355);icon(art,'coin',18,30,220,235);icon(art,'cat',155,100,210,240);label(art,'Cash','+10,000',14,250,205,60,40).Rotation=12;label(art,'Pet','+1 Cat',185,291,175,55,40).Rotation=-12
local copy=label(rewards,'Copy','Join our\n<font color="#ff2222">ROBLOX</font> Group\nfor <font color="#145aff">exclusive</font>\nrewards!',425,125,370,230,40);copy.RichText=true
button(rewards,'Join','JOIN GROUP',425,385,370,85,'green','GroupClaim')
local daily=panel('Daily','Daily Rewards','calendar',890,600,'pink')
local time=panel('Time','Time Rewards','clock',890,600,'green')
for _,p in ipairs({daily,time}) do
 local isDaily=p==daily
 for i=1,7 do
  local big=i==7;local x=big and 666 or 20+((i-1)%3)*214;local y=big and 115 or 115+math.floor((i-1)/3)*234;local w=big and 200 or 200;local h=big and 463 or 220
  local c=frame(p,'Card'..i,x,y,w,h);surface(c,big and 'rainbow' or (isDaily and 'blue' or 'orange'),28);if big then c.UIGradient.Rotation=-45 end;rays(c,0,30,w,h-60)
  local titles=isDaily and {'Day 1','23:59:22','Day 3','Day 4','Day 5','Day 6','Day 7'} or {'03:00','13:00','28:00','58:00','01:28:00','01:58:00','02:58:00'}
  label(c,'Heading',titles[i],3,6,w-6,big and 60 or 37,big and 38 or 28)
  local ic=isDaily and ({'gift','potion','chest','flame','cash','orb','key'})[i] or 'gift';icon(c,ic,big and 15 or 48,big and 120 or 45,big and 170 or 105,big and 190 or 105)
  if isDaily then label(c,'Reward',({'One','Two','Three','Four','Five','Six','Seven'})[i],5,big and 300 or 138,w-10,big and 80 or 35,big and 47 or 28) end
  button(c,'Claim',(isDaily and i==1) and 'CLAIM' or 'LOCKED!',10,h-56,w-20,44,(isDaily and i==1) and 'green' or 'gray',(isDaily and 'Daily:' or 'Time:')..i)
 end
 task.wait()
end
local codes=panel('Codes','Codes','check',820,510,'blue');local c=label(codes,'Copy','Follow <font color="#1855ff">Viral Templates</font>\non <font color="#ff2424">X</font> for exclusive codes!',20,135,780,170,43);c.RichText=true
textbox(codes,'CodeInput','Code Here',28,350,480,95);button(codes,'Redeem','Redeem',530,350,260,95,'green','Redeem')
local settingsPanel=panel('Settings','Settings','gear',620,740,'cyan');label(settingsPanel,'Subtitle','- Game Settings -',0,98,620,60,36)
for i,dat in ipairs({{'Music','pink',.5},{'SFX','gold',1}}) do
 local row=frame(settingsPanel,dat[1],26,175+(i-1)*110,568,92);surface(row,dat[2],30);label(row,'Title',dat[1],14,10,190,70,44).TextXAlignment=Enum.TextXAlignment.Left
 local track=frame(row,'Track',230,29,300,34,rgb(74,49,36));track.BackgroundTransparency=.45;stroke(track,black,3);make('UICorner',track,{CornerRadius=UDim.new(1,0)})
 local thumb=make('TextButton',track,{Name='Thumb',Text='',Size=UDim2.fromOffset(46,46),AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(dat[3],.5),BackgroundColor3=rgb(0,225,255),BorderSizePixel=0,ZIndex=8,AutoButtonColor=false});make('UICorner',thumb,{CornerRadius=UDim.new(1,0)});stroke(thumb,black,3);track:SetAttribute('Value',dat[3])
end
local wheel=clear(panels,'Wheel',0,0,760,850);wheel.AnchorPoint=Vector2.new(.5,.5);wheel.Position=UDim2.fromScale(.5,.5);wheel.Visible=false;wheel.ZIndex=10
label(wheel,'Countdown','Next FREE spin in 03:20',0,0,760,65,36)
wheelArt(wheel,'WheelArt',95,90,570,true);label(wheel,'Pointer','⬇',327,40,100,95,88)
button(wheel,'Spin','SPIN (x1)',250,693,230,70,'green','Spin');button(wheel,'Close','X',510,693,65,70,'pink','Close')
for i,txt in ipairs({'(2x) 29 R$','(5x) 59 R$','(10x) 99 R$'}) do button(wheel,'Buy'..i,txt,36+(i-1)*237,790,220,60,'gold','Spins:'..({2,5,10})[i]) end
local loading=make('CanvasGroup',canvas,{Name='Loading',Size=UDim2.fromOffset(1920,1080),BackgroundColor3=rgb(67,126,208),BorderSizePixel=0});loading.Visible=false;loading.ZIndex=30;local backdrop=frame(loading,'Backdrop',0,0,1920,1080,white);backdrop.Size=UDim2.fromScale(1,1);backdrop.ZIndex=1;make('UIGradient',backdrop,{Color=ColorSequence.new(rgb(106,172,241),rgb(38,86,155)),Rotation=90});icon(loading,'gift',780,300,360,360);label(loading,'Text','Game Loading..',560,690,800,70,42,rgb(255,199,0));button(loading,'Skip','SKIP',830,940,260,70,'green','Skip');local progress=frame(loading,'Progress',0,1060,1920,20,rgb(29,48,75));frame(progress,'Fill',0,0,700,20,rgb(66,130,255))
local feedback=clear(canvas,'Feedback',0,0,1920,1080);feedback.ZIndex=40
local demo=label(canvas,'DemoNotice','',520,1010,880,45,22);demo.Visible=false
local sc=canvas.ViewportScale.Scale
canvas.Size=UDim2.fromOffset(viewport.X/sc,viewport.Y/sc)
hud.Size=UDim2.fromScale(1,1);panels.Size=UDim2.fromScale(1,1);feedback.Size=UDim2.fromScale(1,1)
nav.AnchorPoint=Vector2.new(0,.5);nav.Position=UDim2.new(0,20,.5,0)
cash.AnchorPoint=Vector2.new(0,1);cash.Position=UDim2.new(0,22,1,-22)
offers.AnchorPoint=Vector2.new(1,.5);offers.Position=UDim2.new(1,-10,.5,0)
settings.AnchorPoint=Vector2.new(1,0);settings.Position=UDim2.new(1,-16,0,16)
loading.Size=UDim2.fromScale(1,1)
loading.Icon_gift.AnchorPoint=Vector2.new(.5,.5);loading.Icon_gift.Position=UDim2.new(.5,0,.5,-100)
loading.Text.AnchorPoint=Vector2.new(.5,0);loading.Text.Position=UDim2.new(.5,0,.5,120)
loading.Skip.AnchorPoint=Vector2.new(.5,1);loading.Skip.Position=UDim2.new(.5,0,1,-60)
loading.Progress.AnchorPoint=Vector2.new(0,1);loading.Progress.Position=UDim2.fromScale(0,1);loading.Progress.Size=UDim2.new(1,0,0,20)
local api=make('BindableFunction',root,{Name='DemoAPI'})
root.Name='EssentialStudUI_Building'
return {root=root:GetFullName(),descendants=#root:GetDescendants(),viewport=tostring(viewport)}
