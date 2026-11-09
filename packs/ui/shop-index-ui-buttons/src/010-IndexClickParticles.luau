local RunService = game:GetService("RunService")
local root = script.Parent
local button = root:WaitForChild("IndexHitTarget")
local icon = root:WaitForChild("IndexIcon")
local random = Random.new()
local layer = Instance.new("Frame")
layer.Name = "IndexParticleLayer"
layer.BackgroundTransparency = 1
layer.Size = UDim2.fromScale(1, 1)
layer.ZIndex = root.ZIndex - 1
layer.Active = false
layer.ClipsDescendants = false
layer.Parent = root.Parent
local particles = {}
local function setting(name, fallback)
 local value = script:GetAttribute(name)
 return if value == nil then fallback else value
end
local function clear()
 for _, p in particles do p.image:Destroy() end
 table.clear(particles)
end
local clickConnection = button.Activated:Connect(function()
 local count = math.clamp(math.floor(setting("Count", 12)), 1, 60)
 local spread = math.clamp(setting("Spread", 360), 0, 360)
 local lifetime = math.clamp(setting("Lifetime", 0.7), 0.1, 5)
 local size = math.clamp(setting("Size", 24), 4, 128)
 local distance = math.clamp(setting("Distance", 115), 10, 600)
 local center = root.AbsolutePosition + root.AbsoluteSize / 2 - layer.AbsolutePosition
 local halfSize = root.AbsoluteSize / 2
 for i = 1, count do
  if #particles >= 180 then
   particles[1].image:Destroy()
   table.remove(particles, 1)
  end
  local angle = math.rad(setting("Direction", -90) + ((i - 0.5 + random:NextNumber(-0.4, 0.4)) / count - 0.5) * spread)
  local direction = Vector2.new(math.cos(angle), math.sin(angle))
  local edge = math.min(halfSize.X / math.max(math.abs(direction.X), 0.001), halfSize.Y / math.max(math.abs(direction.Y), 0.001))
  local image = Instance.new("ImageLabel")
  image.Name = "IndexParticle"
  image.BackgroundTransparency = 1
  image.AnchorPoint = Vector2.new(0.5, 0.5)
  image.Image = setting("Image", icon.Image)
  image.ImageColor3 = setting("Colour", Color3.new(1, 1, 1))
  image.ScaleType = Enum.ScaleType.Fit
  image.Size = UDim2.fromOffset(size, size)
  image.ZIndex = layer.ZIndex
  image.Active = false
  local start = center + direction * math.max(0, edge - size * 0.65)
  image.Position = UDim2.fromOffset(start.X, start.Y)
  image.Parent = layer
  table.insert(particles, {
   image = image, start = start, direction = direction,
   distance = distance * random:NextNumber(0.75, 1.2),
   age = 0, life = lifetime * random:NextNumber(0.85, 1.15),
   size = size * random:NextNumber(0.8, 1.15),
   spin = setting("Spin", 180) * random:NextNumber(-1, 1),
  })
 end
end)
local connection
connection = RunService.RenderStepped:Connect(function(dt)
 if not root:IsDescendantOf(game) then
  connection:Disconnect()
  clickConnection:Disconnect()
  clear()
  layer:Destroy()
  return
 end
 if not root.Visible then clear(); return end
 for i = #particles, 1, -1 do
  local p = particles[i]
  p.age += dt
  local t = math.min(p.age / p.life, 1)
  if t >= 1 then
   p.image:Destroy()
   table.remove(particles, i)
  else
   local travel = 1 - (1 - t) ^ 2
   local position = p.start + p.direction * p.distance * travel
   p.image.Position = UDim2.fromOffset(position.X, position.Y)
   p.image.Rotation = p.spin * p.age
   local size = p.size * (1 - 0.55 * t)
   p.image.Size = UDim2.fromOffset(size, size)
   p.image.ImageTransparency = math.clamp((t - 0.25) / 0.75, 0, 1)
  end
 end
end)
script.Destroying:Connect(function()
 connection:Disconnect()
 clickConnection:Disconnect()
 clear()
 layer:Destroy()
end)
