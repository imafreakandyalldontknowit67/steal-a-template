local roblox = require('@lune/roblox')
local fs = require('@lune/fs')
local process = require('@lune/process')
local serde = require('@lune/serde')
local roots = roblox.deserializeModel(fs.readFile(process.args[1]))
local root = roots[1]
local scripts,images,classes = {},{},{}
local descendants = root:GetDescendants()
local bevelFaces=0
local slots=0
for _,v in ipairs(descendants) do
 if v:IsA("TextButton")and v.Name:match("^Slot%d+$")then slots+=1 end
 if v.Name=="FlatFace" and v:IsA("Frame")then bevelFaces+=1 end
 classes[v.ClassName]=(classes[v.ClassName] or 0)+1
 if v:IsA('LuaSourceContainer') then scripts[v.Name]=v.Source end
 if v:IsA('ImageLabel') then local ok,img=pcall(function()return v.Image end);if not ok then local _,content=pcall(function()return v.ImageContent end);img=tostring(content)end;table.insert(images,{name=v:GetFullName(),image=tostring(img),visible=v.Visible})end
end
fs.writeFile(process.args[2],serde.encode('json',{roots=#roots,name=root.Name,class=root.ClassName,count=#descendants+1,bevelFaces=bevelFaces,slots=slots,scrollEnabled=root.InventorySurface.Canvas.Panel.Slots.ScrollingEnabled,scrollThickness=root.InventorySurface.Canvas.Panel.Slots.ScrollBarThickness,scrollWidth=root.InventorySurface.Canvas.Panel.Slots.Size.X.Offset,scrollCanvasY=root.InventorySurface.Canvas.Panel.Slots.CanvasSize.Y.Offset,scripts=scripts,images=images,classes=classes,surfaceResetOnSpawn=root.InventorySurface.ResetOnSpawn,sourceVersion=root:GetAttribute('SourceVersion')}))
print('Native binary inspection saved')
