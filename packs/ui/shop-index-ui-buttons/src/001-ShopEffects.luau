local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local root = script.Parent
local button = root:WaitForChild("ShopHitTarget")
local icon = root:WaitForChild("CartIcon")
local label = root:WaitForChild("ShopText")
local scale = root:WaitForChild("ShopScale")
local function setting(name, fallback)
 local value = script:GetAttribute(name)
 return if value == nil then fallback else value
end
local baseScale, baseRotation = scale.Scale, icon.Rotation
local hovered, focused, pressed = false, false, false
local activeInput
local scaleTween, leanTween
local hoverSound = Instance.new("Sound")
hoverSound.Name = "ShopHoverSound"
hoverSound.Parent = button
local pressSound = Instance.new("Sound")
pressSound.Name = "ShopPressSound"
pressSound.Parent = button
local function sound(instance, attribute, pitch)
 if not setting("SoundsEnabled", true) then return end
 local id = setting(attribute, "rbxasset://sounds/electronicpingshort.wav")
 if id == "" then return end
 instance.SoundId = id
 instance.Volume = setting("SoundVolume", 0.16)
 instance.PlaybackSpeed = pitch
 instance:Play()
end
local function refresh()
 local engaged = hovered or focused or pressed
 local target = if pressed then setting("PressScale", 0.94) elseif engaged then setting("HoverScale", 1.06) else 1
 if scaleTween then scaleTween:Cancel() end
 if leanTween then leanTween:Cancel() end
 local duration = if pressed then 0.10 else setting("TransitionDuration", 0.18)
 scaleTween = TweenService:Create(scale, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Scale = baseScale * target})
 leanTween = TweenService:Create(icon, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Rotation = baseRotation + (if engaged then setting("CartLeanDegrees", -10) else 0)})
 scaleTween:Play()
 leanTween:Play()
end
button.MouseEnter:Connect(function()
 hovered = true
 sound(hoverSound, "HoverSoundId", 1.5)
 refresh()
end)
button.MouseLeave:Connect(function() hovered = false; refresh() end)
button.SelectionGained:Connect(function() focused = true; refresh() end)
button.SelectionLost:Connect(function() focused = false; pressed = false; refresh() end)
button.InputBegan:Connect(function(input)
 if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch or input.KeyCode == Enum.KeyCode.ButtonA then
  activeInput = input
  pressed = true
  sound(pressSound, "PressSoundId", 1.05)
  refresh()
 end
end)
UserInputService.InputEnded:Connect(function(input)
 if input == activeInput or (pressed and input.UserInputType == Enum.UserInputType.MouseButton1) then
  activeInput = nil
  pressed = false
  refresh()
 end
end)
UserInputService.WindowFocusReleased:Connect(function()
 hovered = false; focused = false; pressed = false; activeInput = nil; refresh()
end)
-- The overlay is still live text. Its narrow white band lights both glyphs and outline.
local shine = label:Clone()
shine.Name = "ShopTextShine"
for _, child in shine:GetChildren() do child:Destroy() end
shine.BackgroundTransparency = 1
shine.TextColor3 = Color3.new(1, 1, 1)
shine.TextStrokeTransparency = 1
shine.ZIndex = label.ZIndex + 1
shine.Active = false
local outline = label:FindFirstChildOfClass("UIStroke")
local glow
if outline then
 glow = outline:Clone()
 for _, child in glow:GetChildren() do child:Destroy() end
 glow.Color = Color3.new(1, 1, 1)
 glow.Parent = shine
end
local band = Instance.new("UIGradient")
band.Name = "SweepBand"
band.Rotation = 12
band.Parent = shine
local outlineBand = band:Clone()
if glow then outlineBand.Parent = glow else outlineBand:Destroy(); outlineBand = nil end
shine.Parent = root
local properties = {"Text", "FontFace", "TextSize", "TextScaled", "TextWrapped", "RichText", "TextXAlignment", "TextYAlignment", "Size", "Position", "AnchorPoint", "Rotation", "Visible", "TextTransparency"}
for _, property in properties do
 label:GetPropertyChangedSignal(property):Connect(function() shine[property] = label[property] end)
end
task.spawn(function()
 while script.Parent and root.Parent do
  local width = math.clamp(setting("SweepWidth", 0.28), 0.02, 0.95)
  local mask = NumberSequence.new({
   NumberSequenceKeypoint.new(0, 1),
   NumberSequenceKeypoint.new(0.5 - width / 2, 1),
   NumberSequenceKeypoint.new(0.5, 0),
   NumberSequenceKeypoint.new(0.5 + width / 2, 1),
   NumberSequenceKeypoint.new(1, 1)
  })
  band.Transparency = mask
  band.Offset = Vector2.new(-1, 0)
  if outlineBand then outlineBand.Transparency = mask; outlineBand.Offset = band.Offset end
  local info = TweenInfo.new(math.max(0.1, setting("SweepDuration", 1.1)), Enum.EasingStyle.Linear)
  local pass = TweenService:Create(band, info, {Offset = Vector2.new(1, 0)})
  if outlineBand then TweenService:Create(outlineBand, info, {Offset = Vector2.new(1, 0)}):Play() end
  pass:Play()
  pass.Completed:Wait()
  task.wait(math.max(0.05, setting("SweepPause", 2.2)))
 end
end)
