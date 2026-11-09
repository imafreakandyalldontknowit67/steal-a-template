local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local shine = script.Parent
local container = shine.Parent
local function setting(name, fallback)
 local value = script:GetAttribute(name)
 return if value == nil then fallback else value
end
-- Find the button's full-size hit target by walking up from the shine layer.
local button
local node = container
while node and not button do
 for _, child in node:GetChildren() do
  if child:IsA("GuiButton") and child.Name:match("HitTarget$") then button = child; break end
 end
 node = node.Parent
end
if not button then return end
local baseY = shine.Position.Y
local pad = shine.Size.Y.Offset * 0.5
local startPosition = UDim2.new(0, -shine.Size.X.Offset - pad, baseY.Scale, baseY.Offset)
local endPosition = UDim2.new(1, pad, baseY.Scale, baseY.Offset)
local playing = false
shine.Visible = false
shine.Position = startPosition
local function pass()
 if playing then return end
 playing = true
 shine.Position = startPosition
 shine.Visible = true
 local tween = TweenService:Create(shine, TweenInfo.new(math.max(0.05, setting("Duration", 0.45)), Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Position = endPosition})
 tween:Play()
 tween.Completed:Wait()
 shine.Visible = false
 shine.Position = startPosition
 playing = false
end
button.MouseEnter:Connect(function()
 if UserInputService.TouchEnabled and not UserInputService.MouseEnabled then return end
 task.spawn(pass)
end)
button.SelectionGained:Connect(function() task.spawn(pass) end)
button.InputBegan:Connect(function(input)
 if input.UserInputType == Enum.UserInputType.Touch then task.spawn(pass) end
end)
