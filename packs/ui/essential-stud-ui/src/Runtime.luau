-- Runtime for EssentialStudUI. UI instances are authored in StarterGui, not reconstructed here.
return function(root)
 local Players=game:GetService('Players');local TS=game:GetService('TweenService');local UIS=game:GetService('UserInputService');local RS=game:GetService('RunService')
 local canvas=root.Canvas;local hud=canvas.HUD;local panels=canvas.Panels;local feedback=canvas.Feedback
 local config=require(root.Configuration)
 local purchaseBusy=false;local alive=true;local current=nil;local transition=0;local cash=config.InitialCash;local shownCash=cash;local cashVersion=0;local spins=config.InitialSpins;local busy=false;local gifted='VIP';local recipient='';local redeemed={};local claims={};local offerIndex=1;local elapsed=0;local connections={};local panelTweens={};local toastList={}
 local blur=Instance.new('BlurEffect');blur.Name='EssentialStudUI_Blur';blur.Size=0;blur.Parent=workspace.CurrentCamera
 local function connect(event,fn) local c=event:Connect(fn);table.insert(connections,c);return c end
 local function tween(o,t,props,style,dir) local a=TS:Create(o,TweenInfo.new(t,style or Enum.EasingStyle.Quad,dir or Enum.EasingDirection.Out),props);a:Play();return a end
 local function fmt(n) local a=math.abs(n);if a>=1e6 then return string.format('%.2fM',n/1e6) elseif a>=1e3 then return string.format('%.2fK',n/1e3) end return tostring(math.floor(n+.5)) end
 local function text(p,txt,size,color) local o=Instance.new('TextLabel');o.BackgroundTransparency=1;o.Size=UDim2.fromScale(1,1);o.Font=Enum.Font.FredokaOne;o.TextSize=size or 28;o.TextColor3=color or Color3.new(1,1,1);o.TextStrokeTransparency=0;o.TextStrokeColor3=Color3.fromRGB(12,16,20);o.Text=txt;o.ZIndex=50;o.Parent=p;return o end
 local function cashAdd(amount)
  cash+=amount;cashVersion+=1;local v=cashVersion;local from=shownCash;local start=os.clock()
  task.spawn(function() while alive and v==cashVersion do local t=math.min((os.clock()-start)/.48,1);shownCash=from+(cash-from)*(1-(1-t)^3);hud.Cash.Total.Text=fmt(shownCash);if t==1 then break end;RS.RenderStepped:Wait() end end)
  local f=Instance.new('Frame');f.Name='CashDelta';f.BackgroundTransparency=1;f.Position=UDim2.new(0,70,1,-125);f.Size=UDim2.fromOffset(320,50);f.Parent=feedback
  local t=text(f,(amount>=0 and '+' or '')..fmt(amount),31,amount>=0 and Color3.fromRGB(141,255,46) or Color3.fromRGB(255,39,61));t.TextXAlignment=Enum.TextXAlignment.Left
  tween(f,1.6,{Position=UDim2.new(0,70,1,-185)});task.delay(1,function() if f.Parent then tween(t,.6,{TextTransparency=1,TextStrokeTransparency=1}) end end);task.delay(1.65,function()f:Destroy()end)
 end
 hud.Cash.Total.Text=fmt(cash)
 local function toast(message,success)
  local f=Instance.new('Frame');f.Name='Toast';f.AnchorPoint=Vector2.new(.5,0);f.Position=UDim2.new(.5,0,0,-60);f.Size=UDim2.fromOffset(850,44);f.BorderSizePixel=0;f.BackgroundColor3=success and Color3.fromRGB(73,219,29) or Color3.fromRGB(221,24,53);f.BackgroundTransparency=.15;f.Parent=feedback
  local g=Instance.new('UIGradient');g.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(.22,.15),NumberSequenceKeypoint.new(.78,.15),NumberSequenceKeypoint.new(1,1)});g.Parent=f
  local txt=text(f,message,30);table.insert(toastList,1,f)
  for i,item in ipairs(toastList) do tween(item,.18,{Position=UDim2.new(.5,0,0,8+(i-1)*49)}) end
  task.delay(3.3,function() if not f.Parent then return end;tween(txt,.25,{TextTransparency=1,TextStrokeTransparency=1});tween(f,.25,{BackgroundTransparency=1});task.wait(.26);local idx=table.find(toastList,f);if idx then table.remove(toastList,idx)end;f:Destroy();for i,item in ipairs(toastList) do tween(item,.18,{Position=UDim2.new(.5,0,0,8+(i-1)*49)})end end)
 end
 local rng=Random.new(3184)
 local function confetti()
  for i=1,100 do
   local f=Instance.new('Frame');f.Name='Confetti';f.BorderSizePixel=0;f.BackgroundColor3=Color3.fromHSV(rng:NextNumber(),1,1);f.Size=UDim2.fromOffset(rng:NextInteger(8,20),rng:NextInteger(9,20));f.Position=UDim2.new(.5,rng:NextNumber(-110,110),0,-40);f.Rotation=rng:NextInteger(0,360);f.Parent=feedback
   local dx=rng:NextNumber(-800,800);tween(f,.36,{Position=UDim2.new(.5,dx,0,rng:NextNumber(60,240)),Rotation=f.Rotation+180},Enum.EasingStyle.Quad)
   task.delay(.35,function()if f.Parent then tween(f,1.05,{Position=UDim2.new(.5,dx*1.3,0,rng:NextNumber(850,1250)),Rotation=f.Rotation+rng:NextNumber(-500,500),BackgroundTransparency=1},Enum.EasingStyle.Quad,Enum.EasingDirection.In)end end);task.delay(1.5,function()f:Destroy()end)
  end
 end
 local function cancelPanel(p) if panelTweens[p] then panelTweens[p]:Cancel();panelTweens[p]=nil end end
 local function resetHover()for _,o in ipairs(root:GetDescendants())do if o:IsA('UIScale') and o.Name=='HoverScale'then o.Scale=1 end end end
 local function open(name)
  local target=panels:FindFirstChild(name);if not target then return false end
  transition+=1;resetHover()
  for _,p in ipairs(panels:GetChildren()) do if p:IsA('GuiObject') then cancelPanel(p);p.Visible=false;p.Position=UDim2.fromScale(.5,.5)end end
  current=name;target.Visible=true;target.Position=UDim2.new(.5,0,.5,100);panelTweens[target]=tween(target,.22,{Position=UDim2.fromScale(.5,.5)},Enum.EasingStyle.Quart)
  tween(blur,.22,{Size=18});return true
 end
 local function close()
  transition+=1;resetHover();local v=transition;local name=current;current=nil;tween(blur,.18,{Size=0})
  if name then local p=panels[name];cancelPanel(p);panelTweens[p]=tween(p,.14,{Position=UDim2.new(.5,0,.5,180)},Enum.EasingStyle.Quad,Enum.EasingDirection.In)
   task.delay(.15,function()if transition==v then p.Visible=false;p.Position=UDim2.fromScale(.5,.5)end end)
  end
 end
 local function purchase(name,amount)
  -- DEMO ONLY: no Robux spent, no live entitlement/receipt claims.
  toast('DEMO: '..name..' — no Robux charged',true);confetti()
  if amount then cashAdd(amount)end
  if name=='VIP' or name=='Teleporter' or name=='x2 Speed' then local c=panels.Shop.Content:FindFirstChild(name);if c then c.Buy.Amount.Visible=false;c.Buy.Robux.Visible=false;c.Buy.Caption.Text='OWNED' end end
 end
 local function refreshSpin() panels.Wheel.Spin.Caption.Text='SPIN (x'..spins..')' end;refreshSpin()
 local function spin()
  if busy then return false,'busy' end;if spins<1 then toast('No spins remaining',false);return false,'empty' end
  spins-=1;busy=true;refreshSpin();local rotor=panels.Wheel.WheelArt.Rotor;local index=rng:NextInteger(0,4);local target=(360-(index*72+36))%360
  local base=rotor.Rotation;local final=base+(360-base%360)+360*4+target
  local tw=tween(rotor,2.35,{Rotation=final},Enum.EasingStyle.Quint)
  tw.Completed:Once(function(state) if not alive or state~=Enum.PlaybackState.Completed then busy=false;return end;busy=false;local amount=({100,1000,10000,100000,150000})[index+1];cashAdd(amount);toast('You won '..fmt(amount)..' Cash',true)end)
  return true
 end
 local function skip()
  local l=canvas.Loading;if not l.Visible then return true end;tween(l,.35,{GroupTransparency=1});task.delay(.36,function()if l.Parent then l.Visible=false;l.GroupTransparency=0 end end);return true
 end
 local function action(a)
  local verb,arg=a:match('^([^:]+):?(.*)$')
  if verb=='Open' then return open(arg)
  elseif verb=='Close' then close()
  elseif verb=='Gift' then gifted=arg;panels.Gift.Subtitle.Text='- Gift "'..arg..'" To -';open('Gift')
  elseif verb=='Recipient' or verb=='RecipientInput' then recipient=verb=='Recipient' and arg or panels.Gift.UsernameInput.Text;recipient=recipient:match('^%s*(.-)%s*$');if recipient=='' then toast('Enter a username',false);return end;panels.Confirm.Question.Text='Are you sure you\nwant to gift "'..gifted..'"\nto '..recipient..'?';open('Confirm')
  elseif verb=='ConfirmGift' then close();toast('DEMO: Gift preview for '..recipient,true);confetti()
  elseif verb=='Buy' then purchase(arg,({['1K Cash']=1000,['100K Cash']=100000,['1M Cash']=1000000,['10M Cash']=10000000})[arg])
  elseif verb=='GroupClaim' then if claims.group then toast('Already Claimed',false)else claims.group=true;panels.Rewards.Join.Caption.Text='Already Claimed';toast('Demo reward claimed',true) end
  elseif verb=='Daily' or verb=='Time' then local n=tonumber(arg);local key=verb..arg;local allowed=(verb=='Daily' and n==1) or (verb=='Time' and elapsed>=config.TimeRewards[n]);if not allowed then toast('Reward is locked',false) elseif claims[key] then toast('Already Claimed',false)else claims[key]=true;panels[verb]['Card'..n].Claim.Caption.Text='CLAIMED';toast('Successfully claimed — demo',true);cashAdd(100)end
  elseif verb=='Redeem' then local code=panels.Codes.CodeInput.Text:match('^%s*(.-)%s*$'):lower();if config.Codes[code] and not redeemed[code] then redeemed[code]=true;cashAdd(config.Codes[code]);toast('Code Redeemed Successfully',true)else toast(redeemed[code] and 'Code already redeemed' or 'Invalid Code',false)end
  elseif verb=='Spin' then return spin()
  elseif verb=='Spins' then local n=tonumber(arg);spins+=n;refreshSpin();purchase('x'..n..' Spins')
  elseif verb=='Skip' then return skip()
  end
 end
 for _,o in ipairs(root:GetDescendants()) do if o:IsA('GuiButton') then
  local a=o:GetAttribute('Action');if a then connect(o.Activated,function()if a=='Offer' then purchase(o:GetAttribute('Product'));else action(a)end end)end
  local scale=o:FindFirstChild('HoverScale');if scale then connect(o.MouseEnter,function()tween(scale,.1,{Scale=1.035})end);connect(o.MouseLeave,function()tween(scale,.1,{Scale=1})end);connect(o.MouseButton1Down,function()tween(scale,.06,{Scale=.96})end);connect(o.MouseButton1Up,function()tween(scale,.1,{Scale=1})end);connect(o:GetPropertyChangedSignal('Visible'),function()scale.Scale=1 end)end
 end end
 local drag=nil
 for _,name in ipairs({'Music','SFX'})do
  local track=panels.Settings[name].Track;track.Active=true
  local function set(x) local v=math.clamp((x-track.AbsolutePosition.X)/track.AbsoluteSize.X,0,1);track:SetAttribute('Value',v);track.Thumb.Position=UDim2.fromScale(v,.5);root:SetAttribute(name..'Volume',v)
   local group=game:GetService('SoundService'):FindFirstChild('Essential'..name);if group and group:IsA('SoundGroup')then group.Volume=v end
  end
  connect(track.InputBegan,function(i)if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drag={set=set,input=i};set(i.Position.X)end end)
  connect(track.Thumb.InputBegan,function(i)if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drag={set=set,input=i};set(i.Position.X)end end)
 end
 connect(UIS.InputChanged,function(i)if drag and (i.UserInputType==Enum.UserInputType.MouseMovement or i==drag.input)then drag.set(i.Position.X)end end)
 connect(UIS.InputEnded,function(i)if drag and (i.UserInputType==Enum.UserInputType.MouseButton1 or i==drag.input)then drag=nil end end)
 local function resize()
  local v=workspace.CurrentCamera.ViewportSize;local scale=math.min(v.X/1920,v.Y/1080);canvas.ViewportScale.Scale=scale;canvas.Size=UDim2.fromOffset(v.X/scale,v.Y/scale)
 end
 connect(workspace.CurrentCamera:GetPropertyChangedSignal('ViewportSize'),resize);resize()
 local icons={crown=0,teleporter=1,shoe=2,gift=3,cash=4,key=5,potion=6,chest=7,basket=8,calendar=9,check=10,gear=11,cat=12,coin=13,flame=14,shield=15}
 local wheelTemplate=hud.Offers.Offer3.Art.WheelIcon:Clone();wheelTemplate.Parent=nil
 local groups={{{'Secret Pack','potion'},{'Teleporter','teleporter'},{'x5 Spins','wheel'}},{{'x2 Speed','shoe'},{'Secret Pack','potion'},{'100K Cash','cash'}},{{'Teleporter','teleporter'},{'x5 Spins','wheel'},{'Starter Pack','flame'}}}
 task.spawn(function()
  while alive do task.wait(config.OfferInterval);if not alive then break end;offerIndex=offerIndex%#groups+1
   for i=1,3 do task.delay((i-1)*.12,function()
    if not alive then return end;local b=hud.Offers['Offer'..i];local y=(i-1)*220;tween(b,.18,{Position=UDim2.fromOffset(300,y)},Enum.EasingStyle.Quad,Enum.EasingDirection.In);task.wait(.19);if not alive then return end
    local dat=groups[offerIndex][i];b.Title.Text=dat[1];b:SetAttribute('Product',dat[1]);b.Art:ClearAllChildren()
    if dat[2]=='wheel' then local o=wheelTemplate:Clone();o.Parent=b.Art else local idx=icons[dat[2]];local o=Instance.new('ImageLabel');o.Name='Icon_'..dat[2];o.BackgroundTransparency=1;o.Size=UDim2.fromScale(1,1);o.Image=config.Atlas;o.ImageRectOffset=Vector2.new(idx%4*256,math.floor(idx/4)*256);o.ImageRectSize=Vector2.new(256,256);o.ZIndex=4;o.Parent=b.Art end
    tween(b,.25,{Position=UDim2.fromOffset(0,y)},Enum.EasingStyle.Quart)
   end)end
  end
 end)
 local start=os.clock();local nextFree=config.FreeSpinSeconds;local last=-1
 connect(RS.RenderStepped,function()
  elapsed=os.clock()-start;local sec=math.floor(elapsed);if sec==last then return end;last=sec
  local remain=math.max(0,nextFree-sec);panels.Wheel.Countdown.Text=string.format('Next FREE spin in %02d:%02d',math.floor(remain/60),remain%60)
  if remain==0 then spins+=1;refreshSpin();nextFree=sec+config.FreeSpinSeconds;toast('Free spin ready!',true)end
  for i=1,7 do local remain=math.max(0,config.TimeRewards[i]-sec);local card=panels.Time['Card'..i];card.Heading.Text=remain==0 and 'READY' or string.format('%02d:%02d:%02d',math.floor(remain/3600),math.floor(remain/60)%60,remain%60);if remain==0 and not claims['Time'..i]then card.Claim.Caption.Text='CLAIM'end end
 end)
 for _,p in ipairs(panels:GetChildren())do if p:IsA('GuiObject')then p.Visible=false end end
 root.DemoAPI.OnInvoke=function(cmd,value)
  if cmd=='Action'then return action(value)elseif cmd=='Cash'then cashAdd(value)elseif cmd=='Toast'then toast(value,true)elseif cmd=='Confetti'then confetti()elseif cmd=='State'then return {panel=current,cash=cash,shownCash=shownCash,spins=spins,spinning=busy,blur=blur.Size,claims=claims,music=panels.Settings.Music.Track:GetAttribute('Value'),sfx=panels.Settings.SFX.Track:GetAttribute('Value')}end
 end
 if config.ShowLoading then canvas.Loading.Visible=true;local l=canvas.Loading;l.GroupTransparency=0;local img=l.Icon_gift;tween(img,.45,{Rotation=10},Enum.EasingStyle.Sine);task.delay(.45,function()if img.Parent then tween(img,.5,{Rotation=-8},Enum.EasingStyle.Sine)end end);tween(l.Progress.Fill,1.3,{Size=UDim2.new(1,0,1,0)});task.delay(1.4,skip)end
 connect(root.Destroying,function()alive=false;for _,c in ipairs(connections)do c:Disconnect()end;blur:Destroy();wheelTemplate:Destroy()end)
 return {Action=action,State=function()return root.DemoAPI:Invoke('State')end}
end
