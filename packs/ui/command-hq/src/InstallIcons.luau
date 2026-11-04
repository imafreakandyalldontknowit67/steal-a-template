-- Run after ColorMatch. Replace all shared symbol uses with the same uploaded artwork.
local g=game.StarterGui:FindFirstChild('CommandHQ_Revision') or game.StarterGui.CommandHQ
local assets=require(g.SharedIcons)
local palette=require(g.Palette)
local targets={}
for _,o in g:GetDescendants() do
 if o:IsA('GuiObject') then
  local kind=o.Name:match('^(%a+)Icon$')
  if kind and assets[kind] then table.insert(targets,{object=o,kind=kind}) end
 end
end
local changed={}
for _,target in targets do
 local old,kind=target.object,target.kind
 local im=Instance.new('ImageLabel');im.Name=old.Name;im.BackgroundTransparency=1;im.BorderSizePixel=0
 im.Image=assets[kind].Id;im.ScaleType=Enum.ScaleType.Fit;im.ResampleMode=Enum.ResamplerMode.Default
 im.Position=old.Position;im.Size=old.Size;im.AnchorPoint=old.AnchorPoint;im.Rotation=old.Rotation
 im.Visible=old.Visible;im.ZIndex=math.max(3,old.ZIndex)
 im.ImageColor3=(kind=='plus' or old:IsDescendantOf(g.Panels.Missions)) and palette.GoldText or palette.Primary
 im:SetAttribute('SharedIcon',kind)
 local scale=old:FindFirstChild('IconScale');if scale then scale:Clone().Parent=im end
 im.Parent=old.Parent;table.insert(changed,im:GetFullName());old:Destroy()
end
g:SetAttribute('Version','0.3.1')
return changed
