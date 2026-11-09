--[[
	UIFx (client)

	Shared menu sounds and animations so every button and window feels the same.

	  UIFx.play(name)                       -- "Click", "Hover", "Open", "Close", "Purchase", "Error", "Equip"
	  UIFx.bindButton(button, options)      -- hover grow + icon tilt, press squash, bouncy release, click sound
	  UIFx.pop(uiScale, from, delay)        -- springy pop from `from` to 1
	  UIFx.popAll(uiScales, stagger)        -- the same, one after another
	  UIFx.slideIn(guiObject, offset, delay)
	  UIFx.tween(instance, tweenInfo, props)

	Sound IDs and volumes live in Config.UISounds.
]]

local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local ContentProvider = game:GetService("ContentProvider")

local Config = require(script.Parent:WaitForChild("Config"))

local UIFx = {}

UIFx.Info = {
	Hover = TweenInfo.new(0.16, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
	Unhover = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
	Press = TweenInfo.new(0.06, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
	Release = TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
	Pop = TweenInfo.new(0.34, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
	Slide = TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
}

function UIFx.tween(instance: Instance, info: TweenInfo, props: { [string]: any }): Tween
	local tween = TweenService:Create(instance, info, props)
	tween:Play()
	return tween
end

---------------------------------------------------------------------------
-- Sounds
---------------------------------------------------------------------------
local soundFolder = Instance.new("Folder")
soundFolder.Name = "UISounds"
soundFolder.Parent = SoundService

local sounds: { [string]: Sound } = {}
local basePitch: { [string]: number } = {}
for name, def in Config.UISounds or {} do
	if type(def) == "table" and def.Id and (def.Volume or 0) > 0 then
		local sound = Instance.new("Sound")
		sound.Name = name
		sound.SoundId = def.Id
		sound.Volume = def.Volume
		sound.PlaybackSpeed = def.Pitch or 1
		sound.Parent = soundFolder
		sounds[name] = sound
		basePitch[name] = def.Pitch or 1
	end
end
task.spawn(function()
	local list = {}
	for _, sound in sounds do
		table.insert(list, sound)
	end
	pcall(function()
		ContentProvider:PreloadAsync(list) -- so the first click isn't silent
	end)
end)

local random = Random.new()
local lastPlayed: { [string]: number } = {}

-- Plays a menu sound. A tiny random pitch change keeps repeated clicks from sounding robotic.
function UIFx.play(name: string)
	local sound = sounds[name]
	if not sound then
		return
	end
	local now = os.clock()
	if lastPlayed[name] and now - lastPlayed[name] < 0.03 then
		return -- the same sound twice in one frame just gets louder
	end
	lastPlayed[name] = now
	sound.PlaybackSpeed = basePitch[name] * (1 + random:NextNumber(-0.04, 0.04))
	SoundService:PlayLocalSound(sound)
end

---------------------------------------------------------------------------
-- Animations
---------------------------------------------------------------------------
function UIFx.pop(scale: UIScale, from: number?, delay: number?)
	scale.Scale = from or 0.6
	if delay and delay > 0 then
		task.delay(delay, function()
			UIFx.tween(scale, UIFx.Info.Pop, { Scale = 1 })
		end)
	else
		UIFx.tween(scale, UIFx.Info.Pop, { Scale = 1 })
	end
end

function UIFx.popAll(scales: { UIScale }, stagger: number?, from: number?)
	for index, scale in scales do
		UIFx.pop(scale, from, (index - 1) * (stagger or 0.035))
	end
end

-- Slides an object in from `offset` pixels away to where it is now.
function UIFx.slideIn(object: GuiObject, offset: UDim2, delay: number?)
	local home = object:GetAttribute("HomePosition") or object.Position
	object:SetAttribute("HomePosition", home)
	object.Position = home + offset
	task.delay(delay or 0, function()
		UIFx.tween(object, UIFx.Info.Slide, { Position = home })
	end)
end

--[[
	bindButton(button, options)
	  options.scale  UIScale to animate (default: the button's "ButtonScale")
	  options.icon   image/label to tilt on hover (default: the button's "Icon")
	  options.spin   object that does a quarter turn on hover (used by the [X] buttons)
	  options.hover / options.press   scales (default 1.07 / 0.9)
	  options.sound  sound on press (default "Click"; false = none)
]]
function UIFx.bindButton(button: GuiButton, options: { [string]: any }?)
	local opts = options or {}
	local scale = opts.scale or button:FindFirstChild("ButtonScale")
	if not scale then
		scale = Instance.new("UIScale")
		scale.Name = "ButtonScale"
		scale.Parent = button
	end
	local icon = if opts.icon ~= nil then opts.icon else button:FindFirstChild("Icon")
	local spin = opts.spin
	local hoverScale = opts.hover or 1.07
	local pressScale = opts.press or 0.9
	local clickSound = if opts.sound == nil then "Click" else opts.sound
	local hovering, pressing = false, false

	local function setHover(on: boolean)
		if icon and icon:IsA("GuiObject") then
			UIFx.tween(icon, on and UIFx.Info.Hover or UIFx.Info.Unhover, { Rotation = on and -8 or 0 })
		end
		if spin then
			UIFx.tween(spin, on and UIFx.Info.Hover or UIFx.Info.Unhover, { Rotation = on and 90 or 0 })
		end
	end

	button.InputBegan:Connect(function(input)
		local kind = input.UserInputType
		if kind == Enum.UserInputType.MouseMovement then
			if not hovering then
				hovering = true
				UIFx.play("Hover")
				setHover(true)
			end
			if not pressing then
				UIFx.tween(scale, UIFx.Info.Hover, { Scale = hoverScale })
			end
		elseif kind == Enum.UserInputType.MouseButton1 or kind == Enum.UserInputType.Touch then
			pressing = true
			if clickSound then
				UIFx.play(clickSound)
			end
			UIFx.tween(scale, UIFx.Info.Press, { Scale = pressScale })
		end
	end)
	button.InputEnded:Connect(function(input)
		local kind = input.UserInputType
		if kind == Enum.UserInputType.MouseMovement then
			hovering = false
			setHover(false)
			if not pressing then
				UIFx.tween(scale, UIFx.Info.Unhover, { Scale = 1 })
			end
		elseif kind == Enum.UserInputType.MouseButton1 or kind == Enum.UserInputType.Touch then
			pressing = false
			-- Back easing overshoots a little: a springy bounce on release
			UIFx.tween(scale, UIFx.Info.Release, { Scale = hovering and hoverScale or 1 })
		end
	end)
	button.MouseLeave:Connect(function()
		if hovering or pressing then
			hovering, pressing = false, false
			setHover(false)
			UIFx.tween(scale, UIFx.Info.Unhover, { Scale = 1 })
		end
	end)
end

return UIFx
