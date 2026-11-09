local RunService = game:GetService("RunService")
local stroke = script.Parent
local gradient = stroke:FindFirstChildOfClass("UIGradient")
if not gradient then return end
local originalOffset = gradient.Offset
local phase = 0
local function setting(name, fallback)
 local value = script:GetAttribute(name)
 return if value == nil then fallback else value
end
script.AttributeChanged:Connect(function() phase = 0 end)
local connection
connection = RunService.RenderStepped:Connect(function(dt)
 if not script:IsDescendantOf(game) then connection:Disconnect(); return end
 local direction = if setting("Direction", 1) < 0 then -1 else 1
 local angle = setting("Angle", -90)
 if setting("Mode", "Rotate") == "Move" then
  phase = (phase + dt * math.max(0, setting("MoveSpeed", 0.5)) * direction) % 2
  local radians = math.rad(angle)
  gradient.Rotation = angle
  gradient.Offset = originalOffset + Vector2.new(math.cos(radians), math.sin(radians)) * (phase - 1)
 else
  phase = (phase + dt * setting("Speed", 60) * direction) % 360
  gradient.Rotation = angle + phase
  gradient.Offset = originalOffset
 end
end)
