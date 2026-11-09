local RunService = game:GetService("RunService")
local root = script.Parent
local background = root:WaitForChild("ButtonBackground")
local icon = root:WaitForChild("IndexIcon")
local random = Random.new()
local layer = Instance.new("Frame")
layer.Name = "FallingIndexLayer"
layer.BackgroundTransparency = 1
layer.BorderSizePixel = 0
layer.Position = UDim2.fromOffset(4, 4)
layer.Size = UDim2.new(1, -8, 1, -8)
layer.ClipsDescendants = true
layer.Active = false
layer.ZIndex = 2
layer.Parent = background
local copies = {}
local function setting(name, fallback)
 local value = script:GetAttribute(name)
 return if value == nil then fallback else value
end
local function rebuild()
 for _, copy in copies do copy.image:Destroy() end
 table.clear(copies)
 local minimum = math.clamp(setting("MinSize", 10), 2, 128)
 local maximum = math.clamp(setting("MaxSize", 20), minimum, 128)
 for i = 1, math.clamp(math.floor(setting("Count", 8)), 0, 60) do
  local size = random:NextNumber(minimum, maximum)
  local image = Instance.new("ImageLabel")
  image.Name = string.format("FallingIndex%02d", i)
  image.BackgroundTransparency = 1
  image.BorderSizePixel = 0
  image.AnchorPoint = Vector2.new(0.5, 0.5)
  image.Size = UDim2.fromOffset(size, size)
  image.Image = setting("Image", icon.Image)
  image.ScaleType = Enum.ScaleType.Fit
  image.ImageTransparency = math.clamp(setting("Transparency", 0.65), 0, 1)
  image.Active = false
  image.ZIndex = layer.ZIndex
  local x = random:NextNumber()
  local phase = random:NextNumber()
  image.Position = UDim2.new(x, 0, phase, 0)
  image.Parent = layer
  table.insert(copies, {image=image, x=x, phase=phase, size=size, speed=random:NextNumber(0.8, 1.2)})
 end
end
rebuild()
local attributeConnection = script.AttributeChanged:Connect(rebuild)
local connection
local function cleanup()
 if connection then connection:Disconnect() end
 attributeConnection:Disconnect()
 layer:Destroy()
end
connection = RunService.RenderStepped:Connect(function(dt)
 if not root:IsDescendantOf(game) then cleanup(); return end
 if not root.Visible then return end
 local height = layer.AbsoluteSize.Y
 if height <= 0 then return end
 for _, copy in copies do
  local travel = height + copy.size
  copy.phase = (copy.phase + dt * math.max(0, setting("Speed", 24)) * copy.speed / travel) % 1
  copy.image.Position = UDim2.new(copy.x, 0, 0, copy.phase * travel - copy.size / 2)
 end
end)
script.Destroying:Connect(cleanup)
