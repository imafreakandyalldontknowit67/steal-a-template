local Theme={}
local P=require(script.Parent.Palette)
function Theme.button(b,on,darkText)
 local surface=b:FindFirstChild('ButtonSurface')
 if not surface then return end
 b.BackgroundTransparency=1
 local role=b:GetAttribute('ToneRole') or 'Neutral'
 local top,bottom,rim=P.NeutralTop,P.NeutralBottom,P.NeutralRim
 if role=='Toggle' then top=on and P.ToggleTop or P.OffTop;bottom=on and P.ToggleBottom or P.OffBottom;rim=on and P.ToggleRim or P.OffRim
 elseif on then top=role=='Action' and P.ActionTop or P.TabTop;bottom=role=='Action' and P.ActionBottom or P.TabBottom;rim=role=='Action' and P.ActionRim or P.TabRim end
 surface.Body.BackgroundTransparency=0;surface.Body.Finish.Color=ColorSequence.new(top,bottom)
 surface.Specular.Visible=false
 surface.TopLight.BackgroundColor3=rim;surface.TopLight.BackgroundTransparency=0
 surface.BottomShadow.BackgroundTransparency=.8
 if b:FindFirstChild('Outline') then b.Outline.Color=rim;b.Outline.Transparency=0 end
 b.TextColor3=(darkText or role=='Action') and P.ActionText or P.Primary
end
return Theme
