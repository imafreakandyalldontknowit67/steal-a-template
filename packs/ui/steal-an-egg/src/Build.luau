-- Steal an Egg UI: editable authoring source. Run in Studio Edit mode.
local SG=game:GetService("StarterGui")
local C=Color3.fromRGB
local A={stud="rbxassetid://106133458591909",shoe="rbxassetid://109120946940407",egg="rbxassetid://98549728933454",pig="rbxassetid://130944111992488",trail="rbxassetid://107760372489487",runner="rbxassetid://121734402541861"}
local function new(c,n,p,props)
 local o=Instance.new(c); o.Name=n
 for k,v in pairs(props or {}) do o[k]=v end
 o.Parent=p;return o
end
local function stroke(o,col,w) return new("UIStroke","Outline",o,{Color=col or C(12,12,17),Thickness=w or 3,ApplyStrokeMode=Enum.ApplyStrokeMode.Border}) end
local function frame(p,n,x,y,w,h,col,z)
 return new("Frame",n,p,{Position=UDim2.fromOffset(x,y),Size=UDim2.fromOffset(w,h),BackgroundColor3=col or C(40,40,53),BorderSizePixel=0,ZIndex=z or 1})
end
local function corner(o,r) new("UICorner","Corners",o,{CornerRadius=UDim.new(0,r or 3)}) end
local function grad(o,a,b,rot) new("UIGradient","Gradient",o,{Color=ColorSequence.new(a,b),Rotation=rot or 90}) end
local function text(p,n,s,x,y,w,h,size,col,z)
 local t=new("TextLabel",n,p,{BackgroundTransparency=1,Position=UDim2.fromOffset(x,y),Size=UDim2.fromOffset(w,h),Text=s,TextColor3=col or C(255,255,255),TextSize=size or 24,Font=Enum.Font.GothamBlack,TextStrokeTransparency=1,RichText=true,ZIndex=z or 5})
 new("UIStroke","TextOutline",t,{Color=C(0,0,0),Thickness=3,LineJoinMode=Enum.LineJoinMode.Round})
 return t
end
local function image(p,n,id,x,y,w,h,z)
 return new("ImageLabel",n,p,{BackgroundTransparency=1,Position=UDim2.fromOffset(x,y),Size=UDim2.fromOffset(w,h),Image=id,ScaleType=Enum.ScaleType.Fit,ZIndex=z or 4})
end
local function studs(p,alpha)
 local t=image(p,"StudPattern",A.stud,0,0,0,0,p.ZIndex+1);t.Size=UDim2.fromScale(1,1);t.ScaleType=Enum.ScaleType.Tile;t.TileSize=UDim2.fromOffset(18,18);t.ImageTransparency=math.max(alpha or .4,.64)
end
local function button(p,n,s,x,y,w,h,col,route)
 local b=new("TextButton",n,p,{Position=UDim2.fromOffset(x,y),Size=UDim2.fromOffset(w,h),Text="",AutoButtonColor=false,BackgroundColor3=col or C(104,255,0),BorderSizePixel=0,ZIndex=35})
 stroke(b,C(15,15,18),3);corner(b,2)
 grad(b,C(255,255,255),C(180,220,170));studs(b,.65)
 local inner=frame(b,"Inset",3,3,w-6,h-6,C(255,255,255),8);inner.BackgroundTransparency=1;stroke(inner,C(220,255,180),1)
 local label=text(b,"Label",s,0,0,w,h,math.min(28,h*.68),nil,10)
 if route then b:SetAttribute("Route",route) end
 new("UIScale","InteractionScale",b,{Scale=1})
 return b
end
local function moneyIcon(p,x,y,w)
 local body=frame(p,"Cash",x,y,w,w*.58,C(19,180,30),5);stroke(body,C(9,69,8),2);body.Rotation=-16
 local side=frame(body,"Side",0,w*.42,w,w*.16,C(11,100,22),5)
 local band=frame(body,"Band",w*.42,0,w*.23,w*.58,C(255,207,36),6)
 text(body,"Dollar","$",0,0,w*.43,w*.5,w*.43,C(110,230,36),7)
end
local function robux(p,x,y,s)
 local holder=frame(p,"Robux",x,y,s,s,C(255,255,255),11);holder.BackgroundTransparency=1
 for i=0,7 do
 local a=math.rad(i*45)
 local q=frame(holder,"Edge"..i,s/2+math.cos(a)*s*.36,s/2+math.sin(a)*s*.36,s*.30,s*.12,C(255,255,255),12)
 q.AnchorPoint=Vector2.new(.5,.5);q.Rotation=i*45+90;stroke(q,C(15,15,15),1)
 end
 local center=frame(holder,"Square",s*.36,s*.36,s*.28,s*.28,C(255,255,255),13);stroke(center,C(20,20,20),1)
end
local function price(p,n,s,x,y,w,h,col)
 local b=button(p,n,s,x,y,w,h,col);b:SetAttribute("Action","DemoPurchase")
 robux(b,7,(h-22)/2,22);b.Label.Position=UDim2.fromOffset(25,0);b.Label.Size=UDim2.fromOffset(w-25,h)
 return b
end
local root=new("ScreenGui","StealAnEggUI",nil,{ResetOnSpawn=false,IgnoreGuiInset=true,ZIndexBehavior=Enum.ZIndexBehavior.Sibling,Enabled=false})
root:SetAttribute("Version","0.1.0");root:SetAttribute("DemoOnly",true)
local canvas=frame(root,"DesignCanvas",0,0,1333,682);canvas.BackgroundTransparency=1
canvas.AnchorPoint=Vector2.new(.5,.5);canvas.Position=UDim2.fromScale(.5,.5)
local scale=new("UIScale","ResponsiveScale",canvas,{Scale=1})
local hud=frame(canvas,"HUD",0,0,1333,682);hud.BackgroundTransparency=1
text(hud,"Offline","You earn <font color='#9499a3'>$%s</font>/Day offline! 😈",340,3,650,52,38)
local area=frame(hud,"Area",350,110,633,48,C(42,60,80),1);area.BackgroundTransparency=.83
text(area,"Label","Common Area 🙂",0,0,633,48,38)
button(hud,"Shop","🛒 Shop",12,272,120,45,C(100,255,0),"Shop")
button(hud,"Index","▤ Index",12,327,120,45,C(0,226,255),"PetIndex")
local slow=button(hud,"SlowMode","",12,384,74,27,C(66,91,110));slow:SetAttribute("Action","Toggle")
local thumb=frame(slow,"Thumb",5,4,24,19,C(255,20,30),11);stroke(thumb,C(15,15,18),2);corner(thumb,3)
text(hud,"SlowModeLabel","Slow Mode",93,384,95,27,17)
button(hud,"Eggs","",1272,272,50,52,C(255,40,40),"GrowingEggs")
local egg=frame(hud.Eggs,"Egg",12,9,28,36,C(255,216,125),11);corner(egg,30);stroke(egg,C(20,20,20),3);grad(egg,C(255,244,182),C(255,194,77))
button(hud,"Pets","🐾",1272,343,50,52,C(255,148,34),"ActivePets")
image(hud,"SpeedIcon",A.shoe,7,587,47,46)
text(hud,"SpeedValue","0",64,584,70,48,38)
local plus=button(hud,"SpeedPlus","+",36,608,25,25,C(255,209,0),"SpeedShop")
moneyIcon(hud,11,645,43);text(hud,"CashValue","$0",63,636,100,44,38,C(0,255,0))
text(hud,"Timer","⌛  In 2m 32s",1136,632,190,45,28)
local settings=button(hud,"Settings","⚙",215,8,34,34,C(36,41,47),"Settings");corner(settings,30);settings.Inset:Destroy();settings.StudPattern:Destroy();settings.Size=UDim2.fromOffset(34,34)
local panels=frame(canvas,"Panels",0,0,1333,682);panels.BackgroundTransparency=1;panels.ZIndex=20
local function panel(n,title,x,y,w,h,a,b)
 local p=frame(panels,n,x,y,w,h,C(43,43,57),20);stroke(p,C(17,17,20),5);corner(p,5);studs(p,.55)
 p.Visible=false;p:SetAttribute("HomeX",x);p:SetAttribute("HomeY",y);p:SetAttribute("PanelWidth",w);p:SetAttribute("PanelHeight",h)
 local header=frame(p,"Header",4,4,w-8,64,C(255,255,255),22);stroke(header,C(12,12,17),3);grad(header,a,b,0);studs(header,.55);header.ClipsDescendants=true
 for i=1,3 do local gloss=frame(header,"Gloss"..i,w*.38+i*75,-45,i==1 and 80 or 18,150,C(255,255,255),24);gloss.Rotation=45;gloss.BackgroundTransparency=.72 end
 local titleLabel=text(header,"Title",title,14,0,w-90,64,40,nil,25);titleLabel.TextXAlignment=Enum.TextXAlignment.Left
 local close=button(header,"Close","X",w-65,8,53,52,C(235,0,0));close:SetAttribute("Action","Close")
 return p
end
local function scroll(p,n,x,y,w,h,canvasH,horizontal)
 local s=new("ScrollingFrame",n,p,{Position=UDim2.fromOffset(x,y),Size=UDim2.fromOffset(w,h),BackgroundTransparency=1,BorderSizePixel=0,CanvasSize=horizontal and UDim2.fromOffset(canvasH,0) or UDim2.fromOffset(0,canvasH),ScrollBarThickness=7,ScrollBarImageColor3=C(155,155,155),ScrollingDirection=horizontal and Enum.ScrollingDirection.X or Enum.ScrollingDirection.Y,ZIndex=23,ClipsDescendants=true})
 return s
end
-- Settings
local p=panel("Settings","Settings",367,74,577,541,C(245,249,255),C(113,143,175))
local s=scroll(p,"Content",16,85,548,440,440)
for i,name in ipairs({"Music","SFX","View Other's Pets","View Your Pets","Treadmill Videos"}) do
 local row=frame(s,"Row"..i,2,(i-1)*86,536,76,C(56,72,93),24);stroke(row,C(18,20,26),4);studs(row,.5)
 local label=text(row,"Title",name,10,0,350,76,i<3 and 34 or 32,nil,28);label.TextXAlignment=Enum.TextXAlignment.Left
 if i<3 then
 label.Size=UDim2.fromOffset(230,47)
 local sub=text(row,"Subtitle",i==1 and "Background Music!" or "Sound Effects!",10,39,240,26,21,nil,28);sub.TextXAlignment=Enum.TextXAlignment.Left
 local track=button(row,"Slider","",256,29,264,23,C(27,41,56));track:SetAttribute("Action","Slider");track:SetAttribute("Value",.5)
 track.Inset:Destroy();track.StudPattern:Destroy()
 local fill=frame(track,"Fill",3,3,130,17,C(255,237,121),11)
 local knob=frame(track,"Knob",119,-3,23,29,C(255,230,23),12);stroke(knob,C(15,15,15),3);corner(knob,4)
 else
 local toggle=button(row,"Toggle","",426,23,94,36,C(26,40,55));toggle:SetAttribute("Action","Toggle");toggle:SetAttribute("On",i~=5)
 toggle.Inset:Destroy();toggle.StudPattern:Destroy()
 text(row,"State",i==5 and "OFF" or "ON",356,21,63,39,29,nil,29)
 local t=frame(toggle,"Thumb",i==5 and 5 or 48,5,40,26,i==5 and C(255,0,0) or C(91,255,0),12);corner(t,4);stroke(t,C(10,15,20),2);if i~=5 then grad(t,C(224,255,0),C(0,255,0)) end
 end
end
task.wait()
-- Premium Shop
p=panel("Shop","Shop",265,112,802,432,C(169,255,104),C(17,230,0))
s=scroll(p,"Content",18,78,770,342,1510)
local offer=frame(s,"LimitedOffer",0,0,762,278,C(255,227,18),24);stroke(offer,C(10,10,10),3);grad(offer,C(255,228,20),C(255,249,101))
-- Native sunburst rays behind egg cards.
local sun=frame(offer,"Rays",0,0,762,278,C(255,255,255),25);sun.BackgroundTransparency=1;sun.ClipsDescendants=true
for i=1,18 do local ray=frame(sun,"Ray"..i,170,180,9,550,C(255,255,255),25);ray.AnchorPoint=Vector2.new(.5,.5);ray.Rotation=i*20;ray.BackgroundTransparency=.63 end
text(offer,"New","New!",12,9,110,36,30,nil,27).BackgroundColor3=C(255,0,0);offer.New.BackgroundTransparency=0;stroke(offer.New)
text(offer,"Name","Name",143,4,180,43,40,C(255,211,0),28)
text(offer,"Limited","Limited Time!",143,43,185,28,23,nil,28)
text(offer,"Countdown","00:00:00",542,4,180,40,32,C(255,0,0),28)
image(offer,"FeaturedEgg",A.egg,20,67,210,203,26)
for i=1,7 do
 local x=({16,85,170,271,369,483,605})[i];local h=({70,70,73,84,98,108,147})[i];local cw=({65,80,85,85,98,107,144})[i];local card=frame(offer,"Chance"..i,x,201-h,cw,h,C(91,87,49),27);card.BackgroundTransparency=.28;stroke(card,C(0,0,0),2)
 image(card,"Egg",A.egg,8,4,cw-16,h-25,28);text(card,"Name","Name",0,h-29,cw,18,17,nil,29)
 text(card,"Odds",({"37%","37%","5%","12%","5%","1%","0.005%"})[i],0,h-14,cw,16,14,i==7 and C(255,230,0) or nil,29)
 if i==7 then grad(card,C(255,0,255),C(0,255,255),45);text(card,"Mecha","MECHA",0,-20,cw,22,20,nil,30) end
end
for i,v in ipairs({"1,279","879","179","19"}) do local b=price(offer,"Buy"..i,v,({227,377,507,637})[i],220,({141,121,121,112})[i],43,i==1 and C(255,0,116) or C(99,255,0));text(offer,"Quantity"..i,({"50 Eggs","10 Eggs","3 Eggs","1 Egg"})[i],({227,377,507,637})[i],258,({141,121,121,112})[i],19,18,nil,29) end
text(s,"PassesTitle","PASSES",0,289,762,48,36,C(255,226,0),26)
for i,v in ipairs({"VIP","Double Cash","Lucky","Super Lucky"}) do local card=frame(s,"Pass"..i,((i-1)%2)*384,350+math.floor((i-1)/2)*170,374,160,C(235,218,28),24);stroke(card);grad(card,C(255,205,0),C(255,76,235),0);text(card,"Title",v,5,7,364,40,32,nil,28);image(card,"Icon",A.egg,15,45,100,100,27);price(card,"Buy","199",137,105,220,43) end
local function speedCards(parent,y)
 for i,v in ipairs({"+50M","+150M","+300M","+700M","+1.5B","+3B"}) do
 local card=frame(parent,"Speed"..i,((i-1)%3)*231,y+math.floor((i-1)/3)*185,220,174,C(0,206,255),24);stroke(card);grad(card,C(0,180,255),C(133,255,255));studs(card,.55)
 for j=1,math.min(i,4) do image(card,"Shoe"..j,A.shoe,38+(j-1)*15,14-(j-1)*2,125,105,25+j) end
 text(card,"Amount","<font color='"..(i<4 and "#00ff00" or "#ffd000").."'>"..v.."</font> SPEED",0,108,220,26,25,nil,31)
 price(card,"Buy",i==1 and "9" or i==2 and "99" or "199",23,137,174,31)
 end
end
text(s,"SpeedTitle","SPEED",0,695,762,40,30,C(0,255,255),26);speedCards(s,744)
text(s,"CashTitle","CASH",0,1122,762,40,30,C(0,255,0),26)
for i,v in ipairs({"$24,000","$200,000","$800,000","$4,000,000","$8,000,000"}) do local card=frame(s,"Cash"..i,((i-1)%3)*250,1170+math.floor((i-1)/3)*166,240,156,C(73,255,0),24);grad(card,C(9,196,0),C(175,255,100));studs(card);moneyIcon(card,80,20,73);text(card,"Amount",v,0,83,240,30,25,nil,28);price(card,"Buy",({"9","99","199","799","2,999"})[i],20,117,200,31) end
task.wait()
-- Speed shop, including lower carousel state.
p=panel("SpeedShop","Speed Shop",298,106,738,445,C(72,231,255),C(31,127,209))
s=scroll(p,"Content",21,77,700,357,850);speedCards(s,0)
local mult=frame(s,"Multiplier",0,385,688,100,C(0,213,255),24);grad(mult,C(44,201,255),C(255,239,0),0);image(mult,"Shoes",A.shoe,12,1,120,98,27);text(mult,"Levels","4X ▸ <font color='#ffd400'>8X</font>",135,0,380,95,70,nil,28);price(mult,"Buy","179",535,26,140,51)
local up=frame(s,"Treadmill",0,501,688,265,C(32,235,239),24);stroke(up);grad(up,C(23,246,226),C(154,235,255),0);studs(up,.75)
text(up,"Title","<font color='#ff00d9'>UPGRADE</font> TREADMILL!",0,10,688,50,40,nil,29)
image(up,"Before",A.runner,30,61,210,164,26);image(up,"After",A.runner,420,42,243,214,26);text(up,"Arrow","➜",244,82,110,83,80,C(255,0,0),29)
price(up,"Buy","1,879",205,198,150,54);local cash=button(up,"CashBuy","$10.5M",376,198,111,54,C(215,0,255));cash:SetAttribute("Action","DemoPurchase")
-- Pet Index
p=panel("PetIndex","Pet Index",262,79,809,467,C(115,247,255),C(0,195,239))
local list=scroll(p,"Collection",17,82,552,305,835);list.BackgroundTransparency=0;list.BackgroundColor3=C(37,37,49);stroke(list,C(0,0,0),4)
for r,rarity in ipairs({"Basic","Rare","Legendary"}) do
 local row=frame(list,rarity,0,(r-1)*275,540,270,C(37,37,49),24)
 text(row,"Rarity",rarity,10,10,119,40,r==3 and 22 or 36,nil,29)
 for i=1,8 do
 local card=button(row,"Pet"..i,"Name",130+((i-1)%4)*102,12+math.floor((i-1)/4)*96,94,84,C(87,87,87));card:SetAttribute("Action","SelectPet");card:SetAttribute("Rarity",rarity)
 card.Label.Position=UDim2.fromOffset(0,60);card.Label.Size=UDim2.fromOffset(94,24);card.Label.TextSize=22
 image(card,"PetArt",r==1 and A.pig or A.egg,17,3,60,60,9)
 end
 local progress=frame(row,"Progress",130,214,372,31,C(42,239,0),25);stroke(progress);studs(progress);text(progress,"Count","8/8",0,0,372,31,30,nil,28)
end
local detail=frame(p,"Detail",580,83,218,216,C(255,255,255),24);stroke(detail,C(173,173,173),3);grad(detail,C(238,238,238),C(63,63,63));image(detail,"Pet",A.pig,42,12,132,126,27);text(detail,"Name","Name",0,126,218,33,29,nil,28);text(detail,"Rarity","Basic",0,158,218,34,29,nil,28)
local rew=frame(p,"Rewards",580,310,218,139,C(13,49,28),24);stroke(rew,C(0,150,20),3);text(rew,"Title","Rewards:",5,0,110,26,19,nil,29);moneyIcon(rew,50,28,45);image(rew,"Shoe",A.shoe,112,24,50,50,27);text(rew,"CashBoost","+5%",46,54,55,23,18,nil,29);text(rew,"SpeedBoost","+0.05",108,54,65,23,18,nil,29)
local claim=button(rew,"Claim","CLAIM!",33,85,152,43,C(204,204,204));claim:SetAttribute("Action","Claim")
local unlocked=frame(p,"Unlocked",24,407,541,43,C(0,190,255),24);stroke(unlocked);grad(unlocked,C(165,240,255),C(0,152,255),0);studs(unlocked);text(unlocked,"Label","▣  Unlocked: 24/24",0,0,541,43,35,nil,28)
task.wait()
-- Fuse machine and child confirmation/result.
p=panel("FuseMachine","Fuse Machine",416,123,503,418,C(208,0,255),C(190,0,253))
text(p,"Instruction","Bring <font color='#ff2525'>3</font> same Pets to Fuse",0,70,503,32,28,nil,25)
text(p,"Luck","<i><font color='#00ff00'>Better pets</font> give more <font color='#00ff00'>Luck 🍀</font>!</i>",0,101,503,26,25,nil,25)
for i=1,3 do
 local slot=frame(p,"Slot"..i,18+(i-1)*159,134,145,82,C(30,30,46),25);stroke(slot,C(19,19,28),3)
 text(slot,"Caption","Empty",0,2,145,24,23,nil,27);image(slot,"Egg",A.egg,86,22,49,49,27).Visible=false
 local add=button(slot,"Add","+",18,46,105,29,C(93,255,0));add:SetAttribute("Action","FuseSlot");add:SetAttribute("Slot",i)
 local pipe=frame(p,"Pipe"..i,88+(i-1)*159,223,16,65,i==3 and C(22,24,25) or C(216,255,169),24);stroke(pipe,C(20,20,20),2)
 if i~=2 then local diagonal=frame(p,"Branch"..i,88+(i-1)*159,281,i==1 and 110 or 120,18,i==3 and C(22,24,25) or C(216,255,169),24);diagonal.Rotation=i==1 and 18 or -18;diagonal.AnchorPoint=Vector2.new(i==1 and 0 or 1,.5);stroke(diagonal,C(20,20,20),2) end
 local port=frame(p,"Port"..i,70+(i-1)*159,220,43,7,C(112,255,0),26);corner(port,3);stroke(port,C(16,26,10),2)
end
local output=frame(p,"Output",178,248,144,106,C(30,30,46),26);stroke(output);image(output,"Egg",A.egg,20,-4,104,112,28)
local under=frame(output,"Glow",0,80,144,26,C(219,255,172),27)
local fuse=button(p,"Fuse","3 Pets Left",157,367,190,43,C(106,255,0));fuse:SetAttribute("Action","Fuse")
local confirm=frame(p,"Confirmation",0,26,503,365,C(0,0,0),40);confirm.BackgroundTransparency=.08;corner(confirm,6);stroke(confirm,C(10,10,10),4);confirm.Visible=false
text(confirm,"Prompt","Fuse the\nselected pets?",25,72,453,145,49,nil,42)
local yes=button(confirm,"Yes","Yes!",25,275,200,64,C(48,255,0));yes:SetAttribute("Action","ConfirmFuse")
local no=button(confirm,"No","No",275,275,200,64,C(255,0,0));no:SetAttribute("Action","CancelFuse")
local dismiss=button(confirm,"Close","X",468,-10,41,42,C(255,0,0));dismiss:SetAttribute("Action","CancelFuse")
local result=frame(p,"Result",-256,120,240,159,C(49,48,76),30);stroke(result,C(19,19,26),5);corner(result,5);studs(result);result.Visible=false
image(result,"Before",A.pig,8,32,75,68,31);text(result,"Arrow","≈",89,42,39,42,35,nil,33);image(result,"After",A.pig,132,12,93,102,31)
local ok=button(result,"OK","OK!",69,114,105,33,C(111,255,0));ok:SetAttribute("Action","DismissResult")
-- Trail shop
p=panel("TrailShop","Trail Shop",298,106,738,445,C(215,0,255),C(194,0,250))
s=scroll(p,"Content",9,81,720,355,2420,true)
for i,v in ipairs({"Grey Trail","Green Trail","Blue Trail","Purple Trail","Golden Trail","Red Trail","Galaxy Trail","Secret Trail","Eternal Trail","Divine Trail"}) do
 local colors={C(205,205,205),C(56,255,28),C(0,185,255),C(173,0,255),C(255,225,0),C(255,0,10),C(90,0,170),C(245,245,255),C(0,225,229),C(255,220,0)}
 local card=frame(s,"Trail"..i,(i-1)*240,0,230,343,colors[i],24);stroke(card,C(16,16,20),4);studs(card,.45);grad(card,colors[i],i==9 and C(225,14,255) or C(255,255,190))
 text(card,"Title",v,0,8,230,35,28,nil,29);text(card,"Rarity","Common",0,37,230,26,23,nil,29)
 local art=image(card,"Art",A.trail,-14,59,258,236,27);art.ImageColor3=i<=6 and colors[i] or C(255,255,255)
 if i==7 or i==10 then new("UIGradient","ArtGradient",art,{Color=ColorSequence.new({ColorSequenceKeypoint.new(0,C(255,255,0)),ColorSequenceKeypoint.new(.33,C(0,255,0)),ColorSequenceKeypoint.new(.66,C(0,100,255)),ColorSequenceKeypoint.new(1,C(213,0,255))}),Rotation=50}) end
 local speed=frame(card,"Speed",13,254,204,37,C(0,0,0),29);speed.BackgroundTransparency=.6;stroke(speed,C(20,20,20),2);text(speed,"Label","<font color='#00ff00'>x5</font> Speed",0,0,204,37,30,nil,30)
 local cash=button(card,"Cash","$1.5M",12,300,114,38,C(91,255,0));cash:SetAttribute("Action","DemoPurchase");price(card,"Robux","99",135,300,83,38,C(210,0,255))
end
task.wait()
-- Compact anchored side drawers, observed in video.
local function drawer(n,title,y,h)
 local p=frame(panels,n,1091,y,229,h,C(42,42,50),20);stroke(p);p.Visible=false;p:SetAttribute("HomeX",1091);p:SetAttribute("HomeY",y);p:SetAttribute("PanelWidth",229);p:SetAttribute("PanelHeight",h);p:SetAttribute("Drawer",true)
 local hd=frame(p,"Header",0,0,229,36,C(225,188,130),22);stroke(hd);text(hd,"Title",title,4,0,116,36,21,nil,26)
 local close=button(p,"Close",">",-38,82,30,32,C(255,0,0));close:SetAttribute("Action","Close")
 return p
end
p=drawer("ActivePets","4/7 Active",235,192)
local equipMore=button(p.Header,"More","+1 EQUIP [$1M]",113,5,111,25,C(90,255,0));equipMore:SetAttribute("Action","DemoPurchase")
s=scroll(p,"Content",8,41,214,149,205)
for i=1,5 do local r=frame(s,"Pet"..i,0,(i-1)*39,205,35,C(50,50,52),24);stroke(r,C(90,90,90),1);image(r,"Icon",A.egg,2,3,26,28,26);text(r,"Name","Name",31,1,76,33,22,i==5 and C(0,61,255) or C(233,0,255),26);local b=button(r,"Equip","Unequip",126,5,73,25,C(255,0,0));b.Label.TextSize=16;b:SetAttribute("Action","Equip") end
local best=button(p,"EquipBest","Equip Best",112,202,117,29,C(86,255,0));best:SetAttribute("Action","EquipBest")
p=drawer("GrowingEggs","Growing Eggs",408,190)
local grow=button(p.Header,"GrowAll","Grow All",155,7,69,23,C(255,209,0));grow:SetAttribute("Action","GrowAll")
s=scroll(p,"Content",8,42,214,143,200)
for i=1,4 do local row=frame(s,"Egg"..i,0,(i-1)*44,205,39,C(52,52,60),24);stroke(row,C(90,90,90),1);image(row,"Egg",A.egg,3,3,32,32,26);local bar=frame(row,"Progress",43,11,126,18,C(75,255,0),26);stroke(bar,C(15,15,15),2);text(bar,"Time","1m 25s",0,0,126,18,15,nil,28);local b=button(row,"Grow","▶",177,9,22,23,C(90,255,0));b:SetAttribute("Action","Grow") end

-- Pass 2 reference-driven corrections and art replacements.
local extra={bag="rbxassetid://134042140594042",chest="rbxassetid://89898500704739",cash="rbxassetid://88028506818720",secret="rbxassetid://76903995370413",galaxy="rbxassetid://92272137769691",divine="rbxassetid://115244586813100",dragon="rbxassetid://103095946503773",fox="rbxassetid://128141537451099",robux="rbxassetid://72708008341091",cart="rbxassetid://100946914804238",book="rbxassetid://83927911612192",index="rbxassetid://105488919038467",paw="rbxassetid://140626442103803",hourglass="rbxassetid://105955960720079",rays="rbxassetid://110785315534497"}
for _,o in root:GetDescendants() do
 if o.Name=="Robux" and o:IsA("Frame") then
  local im=image(o.Parent,"Currency",extra.robux,o.Position.X.Offset,o.Position.Y.Offset,o.Size.X.Offset,o.Size.Y.Offset,o.ZIndex)
  o:Destroy()
 elseif o.Name=="Cash" and o:IsA("Frame") then
  local im=image(o.Parent,"CashArt",extra.cash,o.Position.X.Offset-5,o.Position.Y.Offset-7,o.Size.X.Offset+10,o.Size.X.Offset*.75,o.ZIndex)
  o:Destroy()
 end
end
for _,spec in ipairs({{hud.Shop,"Shop",extra.cart},{hud.Index,"Index",extra.index}}) do
 local b=spec[1];b.Label.Text=spec[2];b.Label.Position=UDim2.fromOffset(36,0);b.Label.Size=UDim2.fromOffset(80,45);b.Label.TextSize=27
 image(b,"Icon",spec[3],7,8,29,29,12)
end
hud.Pets.Label.Text="";image(hud.Pets,"PawIcon",extra.paw,8,7,34,38,12)
hud.Timer.Text="In 2m 32s";hud.Timer.Position=UDim2.fromOffset(1173,632);hud.Timer.Size=UDim2.fromOffset(155,45);hud.Timer.Font=Enum.Font.GothamBold
image(hud,"Hourglass",extra.hourglass,1138,632,37,45,8)
hud.Eggs.StudPattern.ImageTransparency=1;hud.Eggs.Inset:Destroy();hud.Pets.Inset:Destroy()
hud.SlowMode.Inset:Destroy();hud.SlowMode.StudPattern.ImageTransparency=1
hud.Settings.Gradient:Destroy();hud.Settings.BackgroundColor3=C(35,40,47);hud.Settings.Size=UDim2.fromOffset(34,34)
hud.Settings.Corners.CornerRadius=UDim.new(1,0)
local off=hud.Offline;off.TextSize=37
local shop=panels.Shop.Content
shop.LimitedOffer.Rays:Destroy()
local rays=image(shop.LimitedOffer,"Sunburst",extra.rays,-50,-65,460,460,25);rays.ImageTransparency=.1
shop.LimitedOffer.ClipsDescendants=true
for i=1,7 do local card=shop.LimitedOffer["Chance"..i];local r=image(card,"Sunburst",extra.rays,0,0,0,0,27);r.Size=UDim2.fromScale(1,1);r.ScaleType=Enum.ScaleType.Stretch;r.ImageTransparency=.2 end
local mecha=shop.LimitedOffer.Chance7
mecha.BackgroundColor3=C(255,255,255);mecha.Gradient.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,C(255,230,0)),ColorSequenceKeypoint.new(.25,C(0,255,255)),ColorSequenceKeypoint.new(.5,C(90,40,255)),ColorSequenceKeypoint.new(.75,C(255,20,255)),ColorSequenceKeypoint.new(1,C(255,240,0))})
mecha.Outline.Color=C(0,255,255);mecha.Outline.Thickness=3
for i=1,9 do local line=frame(mecha,"Lightning"..i,(i*17)%120,(i*29)%135,42,3,Color3.fromHSV(i/9,1,1),27);line.Rotation=(i%2==0 and 25 or -20) end
text(shop.LimitedOffer,"OldPrice","5,959",230,201,130,24,20,C(255,0,0),37);local strike=frame(shop.LimitedOffer,"Strike",244,211,93,2,C(255,10,10),38)
shop.LimitedOffer.Quantity1.ZIndex=36;shop.LimitedOffer.Quantity2.ZIndex=36;shop.LimitedOffer.Quantity3.ZIndex=36;shop.LimitedOffer.Quantity4.ZIndex=36
-- Actual two passes observed at video 10.3 seconds.
for i=1,4 do shop["Pass"..i]:Destroy() end
for i,v in ipairs({"x2 Growth","x2 Money"}) do
 local c=frame(shop,"Pass"..i,(i-1)*389,350,374,177,C(255,236,85),24);stroke(c,C(20,20,20),3);studs(c,.68)
 if i==1 then new("UIGradient","Rainbow",c,{Color=ColorSequence.new({ColorSequenceKeypoint.new(0,C(255,191,119)),ColorSequenceKeypoint.new(.25,C(91,255,242)),ColorSequenceKeypoint.new(.5,C(161,140,255)),ColorSequenceKeypoint.new(.75,C(255,131,209)),ColorSequenceKeypoint.new(1,C(255,178,92))}),Rotation=25}) end
 text(c,"Title",v,0,8,374,37,29,nil,28)
 if i==1 then
 local clock=frame(c,"Stopwatch",34,62,74,74,C(255,255,255),27);corner(clock,50);stroke(clock,C(17,17,17),5)
 local ring=stroke(clock,C(0,230,180),3)
 frame(clock,"Hand1",35,15,5,26,C(20,20,20),29);frame(clock,"Hand2",35,37,24,5,C(20,20,20),29)
 text(c,"Fast","▶▶",40,119,72,31,24,nil,30)
 text(c,"Description","Eggs Grow <font color='#00ff00'>x2</font>\nfaster!",115,62,246,71,29,nil,28)
 else image(c,"Money",extra.cash,21,54,109,100,27);text(c,"Description","Get 2x Money",132,72,234,54,28,nil,28) end
 local buy=price(c,"Buy",i==1 and "1,949" or "3,999",127,135,207,35,C(117,255,0));buy.BackgroundTransparency=1;buy.StudPattern.ImageTransparency=1;buy.Inset:Destroy();buy.Outline.Enabled=false
 local cu=buy:FindFirstChild("Robux");if cu then cu:Destroy() end;image(buy,"Currency",extra.robux,6,4,25,25,12)
end
shop.SpeedTitle.Position=UDim2.fromOffset(0,550)
for i=1,6 do shop["Speed"..i].Position-=UDim2.fromOffset(0,154) end
shop.CashTitle.Position-=UDim2.fromOffset(0,154)
for i=1,5 do shop["Cash"..i].Position-=UDim2.fromOffset(0,154) end
shop.CanvasSize=UDim2.fromOffset(0,1356)
for _,parent in ipairs({shop,panels.SpeedShop.Content}) do
 for i=1,6 do local c=parent["Speed"..i]
 local rays=image(c,"Sunburst",extra.rays,0,0,220,174,25);rays.ImageTransparency=.2
 if i>=5 then for _,v in c:GetChildren() do if v.Name:match("^Shoe") then v:Destroy() end end;image(c,"Bundle",i==5 and extra.bag or extra.chest,34,-8,154,138,29) end
 end
end
panels.SpeedShop.Content.Multiplier.Shoes.Image=extra.bag
local index=panels.PetIndex
index.Unlocked.Label.Text="Unlocked: 24/24";image(index.Unlocked,"Book",extra.book,-5,-11,60,62,30)
index.Unlocked.Label.Position=UDim2.fromOffset(55,0);index.Unlocked.Label.Size=UDim2.fromOffset(480,43)
for _,r in index.Collection:GetChildren() do if r:IsA("Frame") then
 for _,c in r:GetChildren() do if c:IsA("TextButton") then
 c.Inset:Destroy();c.Gradient.Color=ColorSequence.new(C(255,255,255),C(150,150,150));c.StudPattern.ImageTransparency=.75
 if r.Name=="Legendary" then c.PetArt.Image=extra.dragon end
 end end
 local bat=frame(r.Progress,"Bat",340,-8,8,54,C(224,161,93),30);bat.Rotation=40;corner(bat,4);stroke(bat,C(77,44,18),2)
end end
index.Rewards.Claim.Inset:Destroy();index.Rewards.Claim.Gradient.Color=ColorSequence.new(C(255,255,255),C(107,107,107))
index.Rewards.Claim.StudPattern.ImageTransparency=1
local trails=panels.TrailShop.Content
for i,id in pairs({[7]=extra.galaxy,[8]=extra.secret,[10]=extra.divine}) do
 local a=trails["Trail"..i].Art;a.Image=id;a.ImageColor3=C(255,255,255);local g=a:FindFirstChildOfClass("UIGradient");if g then g:Destroy() end
end
trails.Trail9.Art.ImageColor3=C(255,0,255)
trails.Trail1.Title.Text="Grey Trail";trails.Trail2.Title.Text="Grey Trail" -- label is observed green art / Grey Trail in video.
panels.FuseMachine.Result.Before.Image=extra.fox;panels.FuseMachine.Result.After.Image=extra.fox
for i=1,2 do image(panels.FuseMachine.Result,"SmallFox"..i,extra.fox,5+i*28,45+i*10,45,50,32) end
-- Drawer proportions from settled video frames 26 and 29.
for _,n in ipairs({"GrowingEggs","ActivePets"}) do
 local d=panels[n];d.Size=UDim2.fromOffset(298,252);d.Position=UDim2.fromOffset(1022,266)
 d:SetAttribute("HomeX",1022);d:SetAttribute("HomeY",266);d:SetAttribute("PanelWidth",298);d:SetAttribute("PanelHeight",252)
 d.Header.Size=UDim2.fromOffset(298,46);d.Header.Title.Size=UDim2.fromOffset(n=="GrowingEggs" and 200 or 136,46);d.Header.Title.TextSize=23
 d.Content.Position=UDim2.fromOffset(9,54);d.Content.Size=UDim2.fromOffset(280,194)
 d.Close.Position=UDim2.fromOffset(-49,104);d.Close.Size=UDim2.fromOffset(38,40)
 studs(d,.66)
end
local g=panels.GrowingEggs
g.Header.GrowAll.Position=UDim2.fromOffset(204,8);g.Header.GrowAll.Size=UDim2.fromOffset(86,30);g.Header.GrowAll.Label.Size=UDim2.fromScale(1,1)
for i=2,4 do g.Content["Egg"..i]:Destroy() end
g.Content.CanvasSize=UDim2.fromOffset(0,190);g.Content.Egg1.Size=UDim2.fromOffset(267,49)
g.Content.Egg1.Progress.Position=UDim2.fromOffset(60,14);g.Content.Egg1.Progress.Size=UDim2.fromOffset(150,23)
g.Content.Egg1.Grow.Position=UDim2.fromOffset(226,11)
local d=panels.ActivePets
d.Header.More.Position=UDim2.fromOffset(140,8);d.Header.More.Size=UDim2.fromOffset(150,30);d.Header.More.Label.Size=UDim2.fromScale(1,1)
d.Content.CanvasSize=UDim2.fromOffset(0,260)
for i=1,5 do local r=d.Content["Pet"..i];r.Position=UDim2.fromOffset(0,(i-1)*51);r.Size=UDim2.fromOffset(267,46);r:FindFirstChild("Name").TextSize=23;r.Equip.Position=UDim2.fromOffset(174,7);r.Equip.Size=UDim2.fromOffset(87,31);r.Equip.Label.Size=UDim2.fromScale(1,1) end
d.EquipBest.Position=UDim2.fromOffset(151,262);d.EquipBest.Size=UDim2.fromOffset(147,34);d.EquipBest.Label.Size=UDim2.fromScale(1,1)


-- Pass 3 consistency: centered currency groups and cropped trail artwork.
for _,o in root:GetDescendants() do
 if o:IsA("TextButton") and o:FindFirstChild("Currency") and o:FindFirstChild("Label") then
 local lab=o.Label;local width=o.Size.X.Offset;local group=24+#lab.Text*lab.TextSize*.62
 o.Currency.Position=UDim2.fromOffset(math.max(3,(width-group)/2),(o.Size.Y.Offset-24)/2)
 o.Currency.Size=UDim2.fromOffset(24,24)
 lab.Position=UDim2.fromOffset(o.Currency.Position.X.Offset+27,0)
 lab.Size=UDim2.fromOffset(group-24,o.Size.Y.Offset);lab.TextXAlignment=Enum.TextXAlignment.Left
 end
 if o.Name=="Sunburst" and o.Parent.Name:match("^Speed") then o.ImageTransparency=.52 end
end
for i=1,10 do local c=panels.TrailShop.Content["Trail"..i];c.ClipsDescendants=true;c.Art.Position=UDim2.fromOffset(-74,49);c.Art.Size=UDim2.fromOffset(340,260) end
for i=1,3 do panels.FuseMachine["Slot"..i].Add.Label.TextSize=27 end


-- Pass 4: match the briefly visible pass badges and full-width cash rows.
local sc=panels.Shop.Content
sc.LimitedOffer:FindFirstChild("Name").TextXAlignment=Enum.TextXAlignment.Left
sc.LimitedOffer.Limited.TextXAlignment=Enum.TextXAlignment.Left
sc.Pass1.BackgroundColor3=C(255,255,255)
local coin=frame(sc.Pass2,"Coin",23,55,102,102,C(255,192,0),26);corner(coin,60);stroke(coin,C(149,86,0),5);grad(coin,C(255,250,100),C(235,145,0))
local inner=frame(coin,"Inner",8,8,86,86,C(255,208,31),27);corner(inner,50);stroke(inner,C(255,246,136),3)
sc.Pass2.Money.ZIndex=28;sc.Pass2.Money.Size=UDim2.fromOffset(82,75);sc.Pass2.Money.Position=UDim2.fromOffset(31,64)
text(sc.Pass2,"Double","x2",66,112,62,38,34,C(255,207,0),29)
for i=1,6 do
 local c=sc["Speed"..i];c.Size=UDim2.fromOffset(246,174);c.Position=UDim2.fromOffset(((i-1)%3)*256,c.Position.Y.Offset)
 c.Amount.Size=UDim2.fromOffset(246,26);c.Buy.Position=UDim2.fromOffset(23,137);c.Buy.Size=UDim2.fromOffset(200,31)
 for _,o in c:GetChildren() do if o:IsA("ImageLabel") and o.Name~="StudPattern" and o.Name~="Sunburst" then o.Position+=UDim2.fromOffset(13,0) end end
 c.Sunburst.Size=UDim2.fromOffset(246,174)
end
for i=4,5 do
 local c=sc["Cash"..i];c.Size=UDim2.fromOffset(374,156);c.Position=UDim2.fromOffset((i-4)*384,c.Position.Y.Offset)
 c.CashArt.Position=UDim2.fromOffset(142,13);c.Amount.Size=UDim2.fromOffset(374,30);c.Buy.Size=UDim2.fromOffset(334,31)
 local lab=c.Buy.Label;local group=24+#lab.Text*lab.TextSize*.62;c.Buy.Currency.Position=UDim2.fromOffset((334-group)/2,4);lab.Position=UDim2.fromOffset((334-group)/2+27,0)
 c.Buy.Inset.Size=UDim2.fromOffset(328,25)
end

panels.TrailShop.Content.Trail9.BackgroundColor3=C(255,255,255)
sc.Cash4.CashArt.Image="rbxassetid://111094681099104";sc.Cash5.CashArt.Image="rbxassetid://107198124960588"
for i=4,5 do sc["Cash"..i].CashArt.Size=UDim2.fromOffset(110,100);sc["Cash"..i].CashArt.Position=UDim2.fromOffset(132,0) end
local rows={} for _,r in panels.ActivePets.Content:GetChildren() do if r:FindFirstChild("Equip") then table.insert(rows,r) end end
table.sort(rows,function(a,b) return a.Position.Y.Offset<b.Position.Y.Offset end)
if rows[5] then rows[5].Equip.Label.Text="Equip" end
for _,o in root:GetDescendants() do if o.Name=="Inset" and o.Parent:IsA("GuiButton") then o.Size=UDim2.new(1,-6,1,-6) end end


-- Pass 5: explicit treadmill arrow; white grip on the reference Index baton.
local tread=panels.SpeedShop.Content.Treadmill
tread.Arrow:Destroy()
image(tread,"Arrow","rbxassetid://77256673181681",244,82,110,83,29)
for _,r in panels.PetIndex.Collection:GetChildren() do
 if r:FindFirstChild("Progress") then local grip=frame(r.Progress.Bat,"Grip",0,39,8,15,C(245,245,245),31);corner(grip,2) end
end


-- Review 6: real top-bar anchoring, inventory, HUD silhouettes and counter alignment.
hud.Settings:Destroy()
local topbar=frame(root,"Topbar",172,8,80,36,C(0,0,0),100);topbar.BackgroundTransparency=1
for i,spec in ipairs({{"Backpack","AllItems","rbxassetid://88620256860888"},{"Settings","Settings","rbxassetid://73125667882146"}}) do
 local b=new("TextButton",spec[1],topbar,{Position=UDim2.fromOffset((i-1)*42,0),Size=UDim2.fromOffset(36,36),Text="",AutoButtonColor=false,BackgroundColor3=C(34,37,43),BorderSizePixel=0,ZIndex=101})
 corner(b,40);b:SetAttribute("Route",spec[2]);new("UIScale","InteractionScale",b,{Scale=1})
 image(b,"Icon",spec[3],7,7,22,22,102)
end
local inv=frame(panels,"AllItems",111,137,1110,408,C(38,40,43),20);inv.BackgroundTransparency=.40;corner(inv,10);inv.Visible=false
inv:SetAttribute("HomeX",111);inv:SetAttribute("HomeY",137);inv:SetAttribute("PanelWidth",1110);inv:SetAttribute("PanelHeight",408)
local title=text(inv,"Title","All Items",18,8,250,35,29,C(220,223,226),22);title.TextXAlignment=Enum.TextXAlignment.Left;title.Font=Enum.Font.GothamBold;title.TextOutline:Destroy()
local search=new("TextBox","Search",inv,{Position=UDim2.new(1,-232,0,12),Size=UDim2.fromOffset(210,32),BackgroundColor3=C(60,63,67),BackgroundTransparency=.35,Text="",PlaceholderText="search",TextColor3=C(240,240,240),PlaceholderColor3=C(190,193,196),TextSize=25,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Left,ClearTextOnFocus=false,BorderSizePixel=0,ZIndex=23});corner(search,5)
scroll(inv,"Items",18,55,1074,335,335)
hud.Eggs.Egg:Destroy();image(hud.Eggs,"EggIcon","rbxassetid://88384104679142",7,5,36,42,12)
hud.Pets.PawIcon.Image="rbxassetid://71114644338982";hud.Pets.PawIcon.Size=UDim2.fromOffset(41,43);hud.Pets.PawIcon.Position=UDim2.fromOffset(4,4)
hud.Index.Icon.Image="rbxassetid://138628566988484";hud.Index.Icon.Size=UDim2.fromOffset(30,30);hud.Index.Icon.Position=UDim2.fromOffset(5,7)
for _,n in {"SpeedValue","CashValue"} do
 local t=hud[n];t.TextXAlignment=Enum.TextXAlignment.Left;t.TextSize=34
 t.FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json",Enum.FontWeight.Bold,Enum.FontStyle.Italic)
 t.Size=UDim2.fromOffset(200,44)
end
for _,n in {"ActivePets","GrowingEggs"} do
 local b=panels[n].Close;b.Label.Position=UDim2.fromScale(0,0);b.Label.Size=UDim2.fromScale(1,1);b.Label.TextSize=30
 b.Position=UDim2.new(0,-49,.5,-20)
end
root:SetAttribute("Version","0.1.1")


-- Explicit demo access; hide these two additions when wiring world triggers.
root:SetAttribute("ShowDemoLaunchers",true)
button(hud,"FuseLauncher","Fuse",12,430,120,36,C(204,0,255),"FuseMachine")
button(hud,"TrailLauncher","Trails",12,473,120,36,C(140,0,255),"TrailShop")
hud.Eggs.EggIcon.Size=UDim2.fromOffset(42,46);hud.Eggs.EggIcon.Position=UDim2.fromOffset(4,3)

-- Controller is embedded at authoring/export, not a runtime UI builder.
new("LocalScript","Controller",root,{Source=[====[local gui=script.Parent
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
]====]})
local old=SG:FindFirstChild("StealAnEggUI")
root.Parent=SG;root.Enabled=true;if old then old:Destroy() end
return {name=root.Name,descendants=#root:GetDescendants(),panels=#panels:GetChildren()}
