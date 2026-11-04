-- Command HQ: editable authoring source. Controller source is embedded by the build runner.
local C={bg=Color3.fromRGB(13,30,41),top=Color3.fromRGB(29,51,65),line=Color3.fromRGB(90,133,156),white=Color3.fromRGB(239,244,248),muted=Color3.fromRGB(175,195,208),gold=Color3.fromRGB(255,181,54)}
local function make(class,name,parent,props)
 local o=Instance.new(class); o.Name=name
 for k,v in props or {} do o[k]=v end
 if o:IsA('TextLabel') or o:IsA('TextButton') then o.FontFace=Font.new('rbxasset://fonts/families/RobotoCondensed.json',Enum.FontWeight.Bold) end
 o.Parent=parent; return o
end
local function frame(name,p,x,y,w,h,color)
 return make('Frame',name,p,{Position=UDim2.fromOffset(x,y),Size=UDim2.fromOffset(w,h),BackgroundColor3=color or C.top,BorderSizePixel=0})
end
local function round(p,r) make('UICorner','Corners',p,{CornerRadius=UDim.new(0,r or 8)}) end
local function stroke(p,col,a) make('UIStroke','Outline',p,{Color=col or C.line,Thickness=1,Transparency=a or .35,ApplyStrokeMode=Enum.ApplyStrokeMode.Border}) end
local function grad(p,a,b) p.BackgroundColor3=Color3.new(1,1,1);make('UIGradient','Shading',p,{Color=ColorSequence.new(a or C.top,b or C.bg),Rotation=90}) end
local function text(name,p,s,x,y,w,h,size,bold,col)
 local label=make('TextLabel',name,p,{Text=s,Position=UDim2.fromOffset(x,y),Size=UDim2.fromOffset(w,h),BackgroundTransparency=1,Font=bold and Enum.Font.RobotoCondensed or Enum.Font.Roboto,TextSize=size or 18,TextColor3=col or C.white,TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true})
 label.FontFace=Font.new('rbxasset://fonts/families/RobotoCondensed.json',bold and Enum.FontWeight.Bold or Enum.FontWeight.Regular);return label
end
local function button(name,p,s,x,y,w,h,gold)
 local b=make('TextButton',name,p,{Text=s,Position=UDim2.fromOffset(x,y),Size=UDim2.fromOffset(w,h),BackgroundColor3=gold and C.gold or C.top,BorderSizePixel=0,Font=Enum.Font.RobotoCondensed,TextSize=20,TextColor3=gold and C.bg or C.white,AutoButtonColor=false})
 round(b,7);stroke(b,gold and C.gold or C.line);make('UIGradient','Shading',b,{Enabled=false});return b
end
local function line(p,x,y,w,h,rot,col)
 local f=frame('IconStroke',p,x,y,w,h,col or C.white);f.Rotation=rot or 0;round(f,1);return f
end
local function icon(kind,p,x,y,size,col)
 local f=frame(kind..'Icon',p,x,y,28,28);f.BackgroundTransparency=1
 make('UIScale','IconScale',f,{Scale=(size or 28)/28});col=col or C.white
 if kind=='gear' then
  for i=0,7 do local a=math.rad(i*45);line(f,12+10*math.cos(a),12+10*math.sin(a),5,5,i*45,col) end
  local r=frame('Ring',f,5,5,18,18,col);round(r,18);local q=frame('Hole',r,5,5,8,8,C.top);round(q,8)
 elseif kind=='ticket' then
  local q=frame('Ticket',f,3,7,23,14,col);q.Rotation=-27;round(q,3)
  local inner=frame('Inset',q,2,2,19,10,C.top);round(inner,2);line(q,11,3,2,8,0,col)
 elseif kind=='document' or kind=='tasks' then
  local q=frame('Paper',f,5,2,18,24,col);round(q,2);frame('Inset',q,2,2,14,20,C.top)
  for i=0,2 do line(q,5,7+i*5,8,2,0,col) end
  if kind=='tasks' then frame('Clip',q,5,-1,8,4,col) end
 elseif kind=='close' then line(f,2,13,25,2,45,col);line(f,2,13,25,2,-45,col)
 elseif kind=='plus' then line(f,3,12,22,4,0,col);line(f,12,3,4,22,0,col)
 elseif kind=='check' then line(f,3,15,10,3,45,col);line(f,9,12,18,3,-45,col)
 elseif kind=='flag' then line(f,6,2,3,25,0,col);frame('Flag',f,9,4,16,11,col)
 elseif kind=='crate' then local q=frame('Crate',f,3,7,22,18,col);line(q,10,1,2,16,0,C.bg);line(f,3,5,23,2,0,col)
 elseif kind=='speaker' then frame('Speaker',f,3,10,7,10,col);local q=frame('Cone',f,9,7,8,16,col);line(f,21,6,2,17,0,col)
 elseif kind=='monitor' then local q=frame('Screen',f,2,3,24,17,col);round(q,2);frame('Glass',q,2,2,20,13,C.top);line(f,13,20,2,5,0,col);line(f,7,25,14,2,0,col)
 elseif kind=='alert' then local q=frame('Circle',f,2,2,24,24,col);round(q,24);text('Exclamation',q,'!',8,-1,10,24,21,true,C.bg)
 elseif kind=='party' then for i=0,2 do local q=frame('Head',f,3+i*8,3+(i%2)*3,7,7,col);round(q,7);local z=frame('Body',f,1+i*8,12+(i%2)*3,11,11,col);round(z,5) end
 else line(f,4,20,21,4,-45,col);local q=frame('Head',f,16,1,10,10,col);round(q,10) end
 return f
end
local root=make('ScreenGui','CommandHQ',nil,{ResetOnSpawn=false,IgnoreGuiInset=false,DisplayOrder=20,ZIndexBehavior=Enum.ZIndexBehavior.Sibling,ScreenInsets=Enum.ScreenInsets.CoreUISafeInsets})
root:SetAttribute('Version','0.1.0');root:SetAttribute('Demo',true)
local hud=make('Frame','HUD',root,{Size=UDim2.fromScale(1,1),BackgroundTransparency=1})
local nav=frame('TopRight',hud,0,18,310,48);nav.AnchorPoint=Vector2.new(1,0);nav.Position=UDim2.new(1,-24,0,18);nav.BackgroundTransparency=1
local updates=button('Updates',nav,'Updates',0,0,128,46);text('Padding',updates,'',0,0,1,1);icon('document',updates,12,11,24);updates.TextXAlignment=Enum.TextXAlignment.Right;make('UIPadding','TextPadding',updates,{PaddingRight=UDim.new(0,12)})
local codes=button('Codes',nav,'Codes',138,0,112,46);icon('ticket',codes,12,11,24);codes.TextXAlignment=Enum.TextXAlignment.Right;make('UIPadding','TextPadding',codes,{PaddingRight=UDim.new(0,12)})
local settings=button('Settings',nav,'',260,0,46,46);icon('gear',settings,9,9,28)
local badge=frame('Unread',updates,115,-3,11,11,C.gold);round(badge,11)
local panels=make('Frame','Panels',root,{Size=UDim2.fromScale(1,1),BackgroundTransparency=1})
local function panel(name,title,kind,w,h)
 local p=frame(name,panels,0,0,w,h,C.bg);p.AnchorPoint=Vector2.new(.5,.5);p.Position=UDim2.fromScale(.5,.52);p.Visible=false;round(p,10);stroke(p,C.line,0);grad(p)
 make('UIScale','ResponsiveScale',p,{Scale=1});p:SetAttribute('DesignWidth',w);p:SetAttribute('DesignHeight',h)
 local head=frame('Header',p,0,0,w,64);head.BackgroundTransparency=.45;round(head,10)
 frame('Divider',p,0,63,w,1,C.line).BackgroundTransparency=.5
 local slash=frame('GoldAccent',p,8,4,5,52,C.gold);slash.Rotation=23
 icon(kind,head,28,18,28);text('Title',head,title,72,10,w-132,44,28,true)
 local close=button('Close',head,'',w-56,10,44,44);close.BackgroundTransparency=1;close.Outline.Enabled=false;close.Shading.Enabled=false;icon('close',close,9,9,26)
 return p
end
local up=panel('UpdateLog','UPDATE LOG','document',560,460)
local banner=frame('Version',up,26,82,508,50,C.top);round(banner,7);stroke(banner,C.gold,.1);text('Version',banner,'Update 1.4.0',18,0,300,50,25,true,C.gold);text('Date',banner,'MAR 8, 2025',356,0,140,50,16,true)
local scroll=make('ScrollingFrame','Entries',up,{Position=UDim2.fromOffset(28,148),Size=UDim2.fromOffset(508,284),CanvasSize=UDim2.fromOffset(0,360),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=7,ScrollBarImageColor3=C.muted})
for i,data in {{'ADDITIONS','plus','Added new Supply Drop system.\nAdded 2 new map variations.'},{'CHANGES','gear','Improved overall performance.\nAdjusted deployment lobby flow.'},{'FIXES','wrench','Fixed various UI issues.\nResolved bugs with party invites.'}} do
 local y=(i-1)*90;icon(data[2],scroll,5,y+2,23,i<3 and C.gold or C.white);text('Heading'..i,scroll,data[1],42,y,410,30,23,true,i<3 and C.gold or C.white);text('Body'..i,scroll,'•  '..data[3]:gsub('\n','\n•  '),42,y+29,443,52,19,false,C.muted)
end
local redeem=panel('RedeemCode','REDEEM CODE','ticket',560,220)
text('Prompt',redeem,'Enter a code to redeem a reward!',28,78,500,32,22,true)
local input=make('TextBox','CodeInput',redeem,{Position=UDim2.fromOffset(28,126),Size=UDim2.fromOffset(330,52),BackgroundColor3=C.bg,BorderSizePixel=0,Text='',PlaceholderText='Enter code...',PlaceholderColor3=C.muted,TextColor3=C.white,TextSize=20,Font=Enum.Font.Roboto,ClearTextOnFocus=false,TextXAlignment=Enum.TextXAlignment.Left});round(input,7);stroke(input);make('UIPadding','Inset',input,{PaddingLeft=UDim.new(0,16)})
button('Redeem',redeem,'REDEEM',374,126,158,52,true)
text('Feedback',redeem,'',28,182,500,26,15,false,C.gold)
local set=panel('Settings','SETTINGS','gear',780,570)
for i,d in {{'Game','GAME','flag'},{'Audio','AUDIO','speaker'},{'Graphics','GRAPHICS','monitor'},{'Controls','CONTROLS','tasks'}} do local b=button(d[1],set,d[2],26+(i-1)*184,83,174,50,i==2);b:SetAttribute('Tab',d[1]);icon(d[3],b,10,13,24);b.TextSize=21;b.TextXAlignment=Enum.TextXAlignment.Right;make('UIPadding','Right',b,{PaddingRight=UDim.new(0,13)}) end
local pages=make('ScrollingFrame','Pages',set,{Position=UDim2.fromOffset(26,152),Size=UDim2.fromOffset(728,390),CanvasSize=UDim2.fromOffset(0,390),BackgroundColor3=C.top,BorderSizePixel=0,ScrollBarThickness=5,ScrollBarImageColor3=C.muted});round(pages,8);stroke(pages);grad(pages)
for _,n in {'Audio','Game','Graphics','Controls'} do local pg=frame(n,pages,0,0,728,390);pg.BackgroundTransparency=1;pg.Visible=n=='Audio';text('Heading',pg,string.upper(n),24,8,600,46,25,true);frame('Accent',pg,0,12,7,30,C.gold);frame('Rule',pg,0,54,728,1,C.line).BackgroundTransparency=.5 end
local audio=pages.Audio
for i,d in {{'Master Volume',75},{'Music Volume',50},{'Sound Effects Volume',80}} do
 local y=65+(i-1)*64;text('Label'..i,audio,d[1],26,y,270,50,23,true)
 local s=button('Slider'..i,audio,'',310,y+20,322,10);s:SetAttribute('Value',d[2]);s.BackgroundColor3=C.line;s.Shading.Enabled=false;s.Outline.Enabled=false
 local fill=frame('Fill',s,0,0,322*d[2]/100,10,C.gold);round(fill,5)
 local thumb=frame('Thumb',s,322*d[2]/100-9,-6,18,23,C.gold);round(thumb,3);stroke(thumb,C.white,0)
 text('Value'..i,audio,d[2]..'%',650,y,60,50,22,true);frame('Separator'..i,audio,16,y+59,696,1,C.line).BackgroundTransparency=.5
end
for i,d in {{'Interface Sounds','Play sounds for menu interactions.',true},{'Mute When Unfocused','Automatically mute audio when the game is not in focus.',false}} do
 local y=259+(i-1)*65;text('ToggleTitle'..i,audio,d[1],26,y,570,30,23,true);text('ToggleDetail'..i,audio,d[2],26,y+27,580,28,17,false,C.muted)
 local b=button('Toggle'..i,audio,'',640,y+14,64,32,d[3]);round(b,20);b:SetAttribute('On',d[3]);local k=frame('Knob',b,d[3] and 35 or 3,3,26,26,C.white);round(k,26)
end
text('GameInfo',pages.Game,'Deployment preferences',26,75,650,35,22,true);text('GameDetail',pages.Game,'Prepare your squad. Review your loadout before deploying.',26,118,650,50,19,false,C.muted)
text('GraphicsInfo',pages.Graphics,'Display quality',26,75,650,35,22,true);text('GraphicsDetail',pages.Graphics,'Use the Roblox menu to adjust rendering quality.',26,118,650,60,19,false,C.muted)
text('ControlsInfo',pages.Controls,'CONTROLS',26,75,650,35,22,true);text('ControlsDetail',pages.Controls,'W A S D   Move\nSpace   Jump\nEsc   Roblox menu\nTouch   Use on-screen controls',26,118,650,180,21,false,C.muted)
local tasks=panel('Missions','TASKS & MISSIONS','tasks',420,412)
local missionCards=make('ScrollingFrame','Cards',tasks,{Position=UDim2.fromOffset(0,72),Size=UDim2.fromOffset(420,324),CanvasSize=UDim2.fromOffset(0,316),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=5,ScrollBarImageColor3=C.muted})
for i,d in {{'Secure the Outpost','Complete 1 deployment on Outpost.','0/1',0,'wrench'},{'Unit Training','Win 3 deployments.','1/3',1/3,'flag'},{'Supply Operation','Purchase 1 item from the Supply Drop.','0/1',0,'crate'}} do
 local y=10+(i-1)*102;local card=frame('Mission'..i,missionCards,20,y,380,90);round(card,8);grad(card);icon(d[5],card,16,24,30,C.gold);text('Title',card,d[1],68,9,285,27,20,true);text('Description',card,d[2],68,36,244,26,13,false,C.muted);text('Count',card,d[3],326,35,44,25,16,true)
 local track=frame('Progress',card,68,70,290,6,C.top);round(track,6);local f=frame('Fill',track,0,0,290*d[4],6,C.gold);round(f,6)
end
for _,d in {{'LeaveQueue','Leave Queue?','You will be removed from the\ndeployment queue.','Leave','flag'},{'PurchaseUnit','Purchase Unit?','Buy the Humvee from the\nSupply Drop?','Confirm','crate'}} do
 local p=panel(d[1],d[2],d[5],360,240);p.Header.Title.TextSize=23;text('Message',p,d[3],28,81,304,65,19,false,C.muted).TextXAlignment=Enum.TextXAlignment.Center;button('Cancel',p,'Cancel',24,172,148,44);button('Confirm',p,d[4],188,172,148,44,true)
end
local notices=frame('Notifications',hud,0,85,340,202);notices.AnchorPoint=Vector2.new(1,0);notices.Position=UDim2.new(1,-24,0,85);notices.BackgroundTransparency=1;notices.Visible=false
for i,d in {{'Code Redeemed!','You claimed a reward.','check',Color3.fromRGB(76,196,92)},{'Party Invite','Aero has invited you to their party.','party',C.gold},{'Queue Failed','Unable to join the deployment.','alert',Color3.fromRGB(238,80,73)}} do
 local p=frame('Notice'..i,notices,0,(i-1)*66,340,58);round(p,8);stroke(p,C.line,.6);grad(p);local bar=frame('Status',p,0,0,5,58,d[4]);round(bar,5);icon(d[3],p,17,17,26,d[4]);text('Title',p,d[1],60,7,245,23,17,true);text('Detail',p,d[2],60,30,250,21,13,false,C.muted);local b=button('Dismiss',p,'',305,4,30,30);b.BackgroundTransparency=1;b.Outline.Enabled=false;b.Shading.Enabled=false;icon('close',b,6,6,18)
end
root.Parent=game.StarterGui
return 'CommandHQ authored: '..#root:GetDescendants()..' descendants'
