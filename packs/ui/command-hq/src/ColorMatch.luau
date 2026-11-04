-- Run after Polish. Paints the existing native controls with component-specific sampled colors.
local g=game.StarterGui:FindFirstChild('CommandHQ_ToneRevision') or game.StarterGui:FindFirstChild('CommandHQ_Revision') or game.StarterGui.CommandHQ
local P=require(g.Palette)
local function finish(f,a,b)
 f.BackgroundColor3=Color3.new(1,1,1);f.BackgroundTransparency=0
 local gradient=f:FindFirstChild('Finish')
 if not gradient then gradient=Instance.new('UIGradient');gradient.Name='Finish';gradient.Rotation=90;gradient.Parent=f end
 gradient.Color=ColorSequence.new(a,b or a);gradient.Transparency=NumberSequence.new(0);gradient.Enabled=true
end
local function paintSurface(p,content)
 local skin=p:FindFirstChild('GlassSurface');if not skin then return end
 finish(skin.Body,content and P.Content or P.Panel,content and P.ContentBottom or P.PanelBottom)
 skin.AngledReflection.BackgroundTransparency=1
 for _,f in skin:GetChildren() do
  if f.Name:match('TopCut') then f.BackgroundColor3=P.HeaderTop;f.BackgroundTransparency=0
  elseif f.Name:match('BottomCut') then f.BackgroundColor3=P.PanelBottom;f.BackgroundTransparency=0
  elseif f.Name=='TopRim' then f.BackgroundColor3=P.RimTop;f.BackgroundTransparency=0
  elseif f.Name=='BottomRim' then f.BackgroundColor3=P.RimBottom;f.BackgroundTransparency=0
  elseif f.Name=='LeftRim' or f.Name=='RightRim' or f.Name=='CornerBevel' then f.BackgroundColor3=P.Rim;f.BackgroundTransparency=0
  elseif f.Name=='InsetUpperHighlight' then f.BackgroundColor3=P.HeaderDivider;f.BackgroundTransparency=.6
  elseif f.Name=='InsetLowerShade' then f.BackgroundTransparency=.9
  end
 end
 if skin.Body:FindFirstChild('Rim') then skin.Body.Rim.Color=P.InnerRim;skin.Body.Rim.Transparency=0 end
 local h=p:FindFirstChild('SoftShadow')
 if h then
  h:ClearAllChildren()
  local im=Instance.new('ImageLabel');im.Name='GaussianFalloff';im.BackgroundTransparency=1;im.Image=P.Shadow;im.ImageColor3=Color3.new(0,0,0);im.ImageTransparency=content and .7 or .35;im.ScaleType=Enum.ScaleType.Slice;im.SliceCenter=Rect.new(48,48,208,208);im.Position=UDim2.fromOffset(-18,-12);im.Size=UDim2.new(1,36,1,42);im.ZIndex=-2;im.Parent=h
 end
end
for _,p in g.Panels:GetChildren() do
 paintSurface(p,false)
 p.Header.HeaderGlass.Visible=false
 local paint=Instance.new('ImageLabel');paint.Name='HeaderPaint';paint.BackgroundTransparency=1;paint.Image='';paint.Size=UDim2.fromScale(1,1);paint.ZIndex=0;paint.Parent=p.Header
 local body=Instance.new('Frame');body.Name='Body';body.Position=UDim2.fromOffset(1,14);body.Size=UDim2.new(1,-2,1,-14);body.BorderSizePixel=0;body.ZIndex=0;body.Parent=paint;finish(body,P.Header,P.HeaderBottom)
 body.Finish.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(22,47,64)),ColorSequenceKeypoint.new(.7,P.Header),ColorSequenceKeypoint.new(1,P.HeaderBottom)})
 for y=0,13 do local row=Instance.new('Frame');row.Name='CornerCut'..y;row.Position=UDim2.fromOffset(15-y,y+1);row.Size=UDim2.new(1,-2*(15-y),0,1);row.BackgroundColor3=P.HeaderTop;row.BorderSizePixel=0;row.ZIndex=0;row.Parent=paint end
 p.Divider.BackgroundColor3=P.HeaderDivider;p.Divider.BackgroundTransparency=0
 p.Header.HeaderUnderCut.BackgroundTransparency=.8
 for _,row in p.Header.GoldAccent:GetChildren() do if row:IsA('Frame') then finish(row,P.Ribbon,P.Ribbon) end end
end
paintSurface(g.Panels.Settings.Pages,true)
for _,pg in g.Panels.Settings.Pages:GetChildren() do if pg:IsA('Frame') then
 finish(pg.SectionFinish.HeaderSheen,P.Section,P.Header)
 pg.Rule.BackgroundColor3=P.HeaderDivider;pg.Rule.BackgroundTransparency=0
 pg.Accent.BackgroundColor3=P.Ribbon
end end
for _,o in g:GetDescendants() do
 if o:IsA('TextLabel') then
  if o.TextColor3.R>.65 and o.TextColor3.G>.35 and o.TextColor3.B<.45 then o.TextColor3=P.GoldText
  elseif o.FontFace.Weight==Enum.FontWeight.Bold then o.TextColor3=P.Primary else o.TextColor3=P.Secondary end
  o.TextStrokeTransparency=.9
 elseif o:IsA('TextButton') and o:FindFirstChild('ButtonSurface') then
  local role=(o:GetAttribute('Tab') or o:GetAttribute('QualityChoice')) and 'Tab' or (o.Name=='Toggle1' or o.Name=='Toggle2' or o:GetAttribute('DemoOn')~=nil) and 'Toggle' or (o.Name=='Redeem' or o.Name=='Confirm') and 'Action' or 'Neutral'
  o:SetAttribute('ToneRole',role)
  local on=o:GetAttribute('Tab')=='Audio' or o.Name=='HIGH' or role=='Action' or o.Name=='Toggle1' or o:GetAttribute('DemoOn')==true
  require(g.Theme).button(o,on,role=='Action')
  o.Caption.TextColor3=o.TextColor3
 end
end
local a=g.Panels.Settings.Pages.Audio
for i=1,3 do
 local s=a['Slider'..i];finish(s,P.TrackTop,P.TrackBottom);finish(s.Fill,P.FillTop,P.FillBottom);finish(s.Thumb,P.ThumbTop,P.ThumbBottom)
 s.Thumb.Outline.Color=P.Primary;s.Thumb.Outline.Transparency=0
 local divider=a['Separator'..i];divider.BackgroundColor3=P.Divider;divider.BackgroundTransparency=0;divider.DarkEdge.BackgroundColor3=P.DividerShade;divider.DarkEdge.BackgroundTransparency=0
end
for _,o in g:GetDescendants() do
 if o.Name=='Knob' and o:IsA('Frame') then finish(o,P.KnobTop,P.KnobBottom)
 elseif o.Name=='Separator' and o:IsA('Frame') then o.BackgroundColor3=P.Divider;o.BackgroundTransparency=0 end
end
local banner=g.Panels.UpdateLog.Version;finish(banner,P.BannerTop,P.BannerBottom);banner.Outline.Color=P.BannerRim;banner.Outline.Transparency=0
local input=g.Panels.RedeemCode.CodeInput;input.BackgroundColor3=P.InputTop;input.BackgroundTransparency=0;input.TextColor3=P.Primary;input.PlaceholderColor3=Color3.fromRGB(139,159,175);input.Outline.Color=P.InputRim;input.Outline.Transparency=0
g.HUD.TopRight.Updates.Unread.BackgroundColor3=P.Ribbon
for i=1,3 do g.Panels.UpdateLog.Entries['Body'..i].TextColor3=P.Primary end
for _,card in g.Panels.Missions.Cards:GetChildren() do if card:IsA('Frame') then paintSurface(card,true);finish(card.Progress,P.TrackTop,P.TrackBottom);finish(card.Progress.Fill,P.FillTop,P.FillBottom) end end
for _,notice in g.HUD.Notifications:GetChildren() do if notice:IsA('Frame') then paintSurface(notice,true) end end
g:SetAttribute('Version','0.3.0')
return 'Reference-picked component palette applied.'
