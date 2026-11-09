local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local GuiService = game:GetService("GuiService")
local UserInputService = game:GetService("UserInputService")
local SoundService = game:GetService("SoundService")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local camera = workspace.CurrentCamera

local gui = script.Parent
gui.Enabled = true
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false

--========================================================
-- CONFIG
--========================================================
local OPEN_BUTTON_NAME = "SettingsButton"
local CLOSE_WITH_ESC = true

local BASE_PANEL_SIZE = Vector2.new(1280, 760)
local MOBILE_SCALE_PADDING = 0.96
local MIN_SCALE = 0.56
local MAX_SCALE = 1.00

local CLICK_SOUND_ID = "rbxassetid://139403951941162"
local CLICK_VOLUME = 0.75

local DEFAULTS = {
	Theme = "Cyan",
	Font = "Gotham",
	Sound = 0.65,
	Music = 0.55,
	Ambience = 0.60,
	Brightness = 0.20,
	FOV = 70,
	GlobalShadows = true,
	Bloom = true,
	ColorFX = true,
	CompactMode = false,
	ShowNotifications = true,
	DamageNumbers = true,
	ReduceMotion = false,
	HighContrast = false,
	LivePreview = true,
}

local THEME_COLORS = {
	Cyan   = {Accent = Color3.fromRGB(84, 215, 255), Soft = Color3.fromRGB(27, 61, 98), Glow = Color3.fromRGB(39, 125, 186)},
	Purple = {Accent = Color3.fromRGB(178, 133, 255), Soft = Color3.fromRGB(56, 39, 99), Glow = Color3.fromRGB(96, 70, 170)},
	Green  = {Accent = Color3.fromRGB(103, 244, 169), Soft = Color3.fromRGB(29, 88, 61), Glow = Color3.fromRGB(49, 150, 105)},
	Orange = {Accent = Color3.fromRGB(255, 177, 90), Soft = Color3.fromRGB(100, 57, 22), Glow = Color3.fromRGB(163, 94, 34)},
	Red    = {Accent = Color3.fromRGB(255, 107, 130), Soft = Color3.fromRGB(97, 33, 51), Glow = Color3.fromRGB(160, 62, 88)},
}

local FONT_MAP = {
	Gotham = Enum.Font.Gotham,
	Arcade = Enum.Font.Arcade,
	Fredoka = Enum.Font.FredokaOne,
	SciFi = Enum.Font.SciFi,
}

local AUDIO_TARGETS = {
	{ key = "Music", label = "Mute Music", group = "Music" },
	{ key = "SFX", label = "Mute SFX", group = "SFX" },
	{ key = "Ambience", label = "Mute Ambience", group = "Ambience" },
}

--========================================================
-- STATE
--========================================================
local State = {
	Theme = DEFAULTS.Theme,
	Font = DEFAULTS.Font,
	Sound = DEFAULTS.Sound,
	Music = DEFAULTS.Music,
	Ambience = DEFAULTS.Ambience,
	Brightness = DEFAULTS.Brightness,
	FOV = DEFAULTS.FOV,
	GlobalShadows = DEFAULTS.GlobalShadows,
	Bloom = DEFAULTS.Bloom,
	ColorFX = DEFAULTS.ColorFX,
	CompactMode = DEFAULTS.CompactMode,
	ShowNotifications = DEFAULTS.ShowNotifications,
	DamageNumbers = DEFAULTS.DamageNumbers,
	ReduceMotion = DEFAULTS.ReduceMotion,
	HighContrast = DEFAULTS.HighContrast,
	LivePreview = DEFAULTS.LivePreview,
	MuteMusic = false,
	MuteSFX = false,
	MuteAmbience = false,
	Tab = "Overview",
	IsOpen = false,
	Busy = false,
}

local TEXT_OBJECTS = {}
local ACCENT_FRAMES = {}
local ACCENT_STROKES = {}
local ACCENT_TEXTS = {}
local SOFT_FRAMES = {}
local CARD_FRAMES = {}
local TOGGLE_DOTS = {}
local PREVIEW_LABELS = {}
local TAB_BUTTONS = {}
local PAGES = {}

local createdConnections = {}
local currentScale = 1

--========================================================
-- HELPERS
--========================================================
local function connect(sig, fn)
	local c = sig:Connect(fn)
	table.insert(createdConnections, c)
	return c
end

local function playTween(obj, info, props)
	local t = TweenService:Create(obj, info, props)
	t:Play()
	return t
end

local function registerText(obj)
	table.insert(TEXT_OBJECTS, obj)
	return obj
end

local function registerAccentFrame(obj)
	table.insert(ACCENT_FRAMES, obj)
	return obj
end

local function registerAccentStroke(obj)
	table.insert(ACCENT_STROKES, obj)
	return obj
end

local function registerAccentText(obj)
	table.insert(ACCENT_TEXTS, obj)
	return obj
end

local function registerSoftFrame(obj)
	table.insert(SOFT_FRAMES, obj)
	return obj
end

local function registerCard(obj)
	table.insert(CARD_FRAMES, obj)
	return obj
end

local function corner(parent, px)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, px)
	c.Parent = parent
	return c
end

local function stroke(parent, thickness, color, transparency)
	local s = Instance.new("UIStroke")
	s.Thickness = thickness
	s.Color = color or Color3.fromRGB(20, 28, 46)
	s.Transparency = transparency or 0
	s.LineJoinMode = Enum.LineJoinMode.Round
	s.Parent = parent
	return s
end

local function padding(parent, l, r, t, b)
	local p = Instance.new("UIPadding")
	p.PaddingLeft = UDim.new(0, l or 0)
	p.PaddingRight = UDim.new(0, r or 0)
	p.PaddingTop = UDim.new(0, t or 0)
	p.PaddingBottom = UDim.new(0, b or 0)
	p.Parent = parent
	return p
end

local function list(parent, fillDirection, paddingPx)
	local l = Instance.new("UIListLayout")
	l.FillDirection = fillDirection or Enum.FillDirection.Vertical
	l.Padding = UDim.new(0, paddingPx or 0)
	l.SortOrder = Enum.SortOrder.LayoutOrder
	l.Parent = parent
	return l
end

local function outlineText(obj)
	obj.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	obj.TextStrokeTransparency = 0.65
	return obj
end

local function makeText(parent, text, font, size, color, alignX, alignY)
	local lbl = Instance.new("TextLabel")
	lbl.BackgroundTransparency = 1
	lbl.Text = text or ""
	lbl.Font = font or Enum.Font.Gotham
	lbl.TextSize = size or 16
	lbl.TextColor3 = color or Color3.fromRGB(240, 244, 255)
	lbl.TextXAlignment = alignX or Enum.TextXAlignment.Left
	lbl.TextYAlignment = alignY or Enum.TextYAlignment.Center
	lbl.TextWrapped = false
	lbl.TextTruncate = Enum.TextTruncate.AtEnd
	lbl.Parent = parent
	outlineText(lbl)
	registerText(lbl)
	return lbl
end

local function makeButton(parent, text)
	local btn = Instance.new("TextButton")
	btn.AutoButtonColor = false
	btn.BackgroundColor3 = Color3.fromRGB(22, 30, 54)
	btn.Text = text or ""
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 16
	btn.TextColor3 = Color3.fromRGB(240, 244, 255)
	btn.Parent = parent
	corner(btn, 14)
	stroke(btn, 1.5, Color3.fromRGB(37, 52, 84), 0)
	outlineText(btn)
	registerText(btn)
	registerSoftFrame(btn)
	return btn
end

local function makeIconButton(parent, glyph)
	local btn = makeButton(parent, glyph or "✕")
	btn.Font = Enum.Font.GothamBlack
	btn.TextSize = 22
	return btn
end

local function applyButtonFX(btn)
	local originalColor = btn.BackgroundColor3
	local originalStroke = btn:FindFirstChildOfClass("UIStroke")
	local down = false

	local function tweenVisuals(hovered, pressed)
		local targetColor = originalColor
		local targetPos = btn.Position
		if hovered then
			targetColor = originalColor:Lerp(Color3.fromRGB(255, 255, 255), 0.06)
		end
		if pressed then
			targetColor = originalColor:Lerp(Color3.fromRGB(0, 0, 0), 0.12)
			targetPos = UDim2.new(btn.Position.X.Scale, btn.Position.X.Offset, btn.Position.Y.Scale, btn.Position.Y.Offset + 1)
		end
		playTween(btn, TweenInfo.new(State.ReduceMotion and 0.06 or 0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			BackgroundColor3 = targetColor,
			Position = targetPos,
		})
		if originalStroke then
			playTween(originalStroke, TweenInfo.new(State.ReduceMotion and 0.06 or 0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Transparency = pressed and 0.05 or (hovered and 0.0 or 0.12)
			})
		end
	end

	connect(btn.MouseEnter, function()
		if not down then
			tweenVisuals(true, false)
		end
	end)
	connect(btn.MouseLeave, function()
		if not down then
			tweenVisuals(false, false)
		end
	end)
	connect(btn.InputBegan, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			down = true
			tweenVisuals(true, true)
		end
	end)
	connect(btn.InputEnded, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			down = false
			tweenVisuals(false, false)
		end
	end)
	connect(btn.MouseButton1Click, function()
		playClickSound()
	end)
end

local function ensureSoundGroup(name)
	local sg = SoundService:FindFirstChild(name)
	if sg and sg:IsA("SoundGroup") then
		return sg
	end
	return nil
end

local clickSound = Instance.new("Sound")
clickSound.Name = "Settings_Click"
clickSound.SoundId = CLICK_SOUND_ID
clickSound.Volume = CLICK_VOLUME
clickSound.Parent = gui

local function playClickSound()
	if clickSound then
		clickSound.TimePosition = 0
		clickSound:Play()
	end
end

local function ensureEffect(className, effectName)
	local effect = Lighting:FindFirstChild(effectName)
	if effect and effect.ClassName == className then
		return effect
	end
	if effect and effect.ClassName ~= className then
		effect:Destroy()
	end
	local newEffect = Instance.new(className)
	newEffect.Name = effectName
	newEffect.Parent = Lighting
	return newEffect
end

local bloom = ensureEffect("BloomEffect", "SettingsLocalBloom")
bloom.Enabled = true
bloom.Intensity = 0.45
bloom.Size = 18
bloom.Threshold = 1.4

local colorCorrection = ensureEffect("ColorCorrectionEffect", "SettingsLocalColor")
colorCorrection.Enabled = true
colorCorrection.Brightness = 0.02
colorCorrection.Contrast = 0.04
colorCorrection.Saturation = 0.02
colorCorrection.TintColor = Color3.fromRGB(240, 248, 255)

local blur = ensureEffect("BlurEffect", "SettingsPanelBlur")
blur.Enabled = false
blur.Size = 0

--========================================================
-- ROOT
--========================================================
local dim = Instance.new("Frame")
dim.Name = "Dim"
dim.Size = UDim2.fromScale(1, 1)
dim.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
dim.BackgroundTransparency = 1
dim.Visible = false
dim.ZIndex = 1
dim.Active = true
dim.Parent = gui

local panel = Instance.new("Frame")
panel.Name = "SettingsPanel"
panel.AnchorPoint = Vector2.new(0.5, 0.5)
panel.Position = UDim2.fromScale(0.5, 0.5)
panel.Size = UDim2.new(0, BASE_PANEL_SIZE.X, 0, BASE_PANEL_SIZE.Y)
panel.BackgroundColor3 = Color3.fromRGB(5, 9, 18)
panel.BackgroundTransparency = 1
panel.Visible = false
panel.ZIndex = 2
panel.Parent = gui
corner(panel, 28)
stroke(panel, 2, Color3.fromRGB(38, 58, 95), 0)

local panelGradient = Instance.new("UIGradient")
panelGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(4, 10, 22)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(3, 7, 16)),
})
panelGradient.Rotation = 90
panelGradient.Parent = panel

local uiScale = Instance.new("UIScale")
uiScale.Scale = 1
uiScale.Parent = panel

local rootPad = padding(panel, 18, 18, 18, 18)
local rootLayout = list(panel, Enum.FillDirection.Vertical, 14)

--========================================================
-- HEADER
--========================================================
local header = Instance.new("Frame")
header.Name = "Header"
header.Size = UDim2.new(1, 0, 0, 96)
header.BackgroundColor3 = Color3.fromRGB(2, 6, 14)
header.Parent = panel
corner(header, 24)
stroke(header, 2, Color3.fromRGB(35, 58, 97), 0)
registerCard(header)

local headerAccent = Instance.new("Frame")
headerAccent.Size = UDim2.new(0, 8, 0, 64)
headerAccent.Position = UDim2.new(0, 16, 0.5, -32)
headerAccent.BackgroundColor3 = THEME_COLORS[State.Theme].Accent
headerAccent.Parent = header
corner(headerAccent, 999)
registerAccentFrame(headerAccent)

local titleWrap = Instance.new("Frame")
titleWrap.BackgroundTransparency = 1
titleWrap.Position = UDim2.new(0, 34, 0, 14)
titleWrap.Size = UDim2.new(1, -360, 1, -28)
titleWrap.Parent = header

local titleText = makeText(titleWrap, "SETTINGS PRO X", Enum.Font.GothamBlack, 34, Color3.fromRGB(244, 248, 255))
titleText.Size = UDim2.new(1, 0, 0, 38)

local subText = makeText(titleWrap, "High-end control center • visible live functions • scalable layout", Enum.Font.GothamBold, 16, Color3.fromRGB(147, 164, 198))
subText.Position = UDim2.new(0, 0, 0, 42)
subText.Size = UDim2.new(1, 0, 0, 24)

local headerRight = Instance.new("Frame")
headerRight.BackgroundTransparency = 1
headerRight.AnchorPoint = Vector2.new(1, 0.5)
headerRight.Position = UDim2.new(1, -18, 0.5, 0)
headerRight.Size = UDim2.new(0, 310, 0, 56)
headerRight.Parent = header

local rightLayout = list(headerRight, Enum.FillDirection.Horizontal, 12)

local livePill = Instance.new("Frame")
livePill.Size = UDim2.new(0, 180, 1, 0)
livePill.BackgroundColor3 = Color3.fromRGB(16, 28, 55)
livePill.LayoutOrder = 1
livePill.Parent = headerRight
corner(livePill, 999)
stroke(livePill, 1.5, Color3.fromRGB(42, 67, 110), 0)
registerSoftFrame(livePill)

local liveDot = Instance.new("Frame")
liveDot.Size = UDim2.new(0, 12, 0, 12)
liveDot.Position = UDim2.new(0, 16, 0.5, -6)
liveDot.BackgroundColor3 = Color3.fromRGB(115, 248, 167)
liveDot.Parent = livePill
corner(liveDot, 999)

local liveLabel = makeText(livePill, "LIVE PREVIEW ON", Enum.Font.GothamBold, 16, Color3.fromRGB(115, 248, 167))
liveLabel.Position = UDim2.new(0, 36, 0, 0)
liveLabel.Size = UDim2.new(1, -42, 1, 0)

local exitBtn = makeIconButton(headerRight, "✕")
exitBtn.LayoutOrder = 2
exitBtn.Size = UDim2.new(0, 118, 1, 0)
exitBtn.Text = "EXIT"
exitBtn.TextSize = 20
exitBtn.Font = Enum.Font.GothamBlack
applyButtonFX(exitBtn)
print("Created by David")

--========================================================
-- MAIN AREA
--========================================================
local main = Instance.new("Frame")
main.Name = "Main"
main.ClipsDescendants = true
main.Size = UDim2.new(1, 0, 1, -224)
main.BackgroundTransparency = 1
main.Parent = panel

local mainLayout = list(main, Enum.FillDirection.Horizontal, 14)

--========================================================
-- SIDEBAR
--========================================================
local sidebar = Instance.new("Frame")
sidebar.Name = "Sidebar"
sidebar.ClipsDescendants = true
sidebar.Size = UDim2.new(0, 252, 1, 0)
sidebar.BackgroundColor3 = Color3.fromRGB(7, 13, 27)
sidebar.LayoutOrder = 1
sidebar.Parent = main
corner(sidebar, 24)
stroke(sidebar, 2, Color3.fromRGB(35, 58, 95), 0)
registerCard(sidebar)
padding(sidebar, 12, 12, 12, 12)

local sidebarList = list(sidebar, Enum.FillDirection.Vertical, 12)

local profileCard = Instance.new("Frame")
profileCard.Size = UDim2.new(1, 0, 0, 208)
profileCard.BackgroundColor3 = Color3.fromRGB(10, 20, 44)
profileCard.Parent = sidebar
corner(profileCard, 22)
stroke(profileCard, 2, Color3.fromRGB(35, 58, 95), 0)
registerCard(profileCard)
padding(profileCard, 14, 14, 14, 14)

local avatarRing = Instance.new("Frame")
avatarRing.Size = UDim2.new(0, 92, 0, 92)
avatarRing.Position = UDim2.new(0, 0, 0, 0)
avatarRing.BackgroundColor3 = Color3.fromRGB(13, 32, 55)
avatarRing.Parent = profileCard
corner(avatarRing, 999)
local avatarRingStroke = stroke(avatarRing, 2.5, THEME_COLORS[State.Theme].Accent, 0)
registerAccentStroke(avatarRingStroke)

local avatarImage = Instance.new("ImageLabel")
avatarImage.Size = UDim2.new(1, -12, 1, -12)
avatarImage.Position = UDim2.new(0, 6, 0, 6)
avatarImage.BackgroundColor3 = Color3.fromRGB(4, 8, 16)
avatarImage.ScaleType = Enum.ScaleType.Crop
avatarImage.Parent = avatarRing
corner(avatarImage, 999)

task.spawn(function()
	local ok, content = pcall(function()
		return Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
	end)
	if ok then
		avatarImage.Image = content
	end
end)

local profileName = makeText(profileCard, player.DisplayName or player.Name, Enum.Font.GothamBlack, 22, Color3.fromRGB(245, 248, 255))
profileName.Position = UDim2.new(0, 110, 0, 8)
profileName.Size = UDim2.new(1, -112, 0, 30)

local profileUser = makeText(profileCard, "@" .. player.Name, Enum.Font.GothamBold, 15, Color3.fromRGB(149, 166, 199))
profileUser.Position = UDim2.new(0, 110, 0, 40)
profileUser.Size = UDim2.new(1, -112, 0, 22)

local proChip = Instance.new("Frame")
proChip.Size = UDim2.new(0, 84, 0, 34)
proChip.Position = UDim2.new(0, 110, 0, 76)
proChip.BackgroundColor3 = Color3.fromRGB(17, 45, 78)
proChip.Parent = profileCard
corner(proChip, 999)
stroke(proChip, 1.5, Color3.fromRGB(41, 72, 116), 0)
registerSoftFrame(proChip)

local proChipText = makeText(proChip, "PRO", Enum.Font.GothamBlack, 16, Color3.fromRGB(242, 246, 255), Enum.TextXAlignment.Center)
proChipText.Size = UDim2.fromScale(1, 1)

local idPill = Instance.new("Frame")
idPill.Size = UDim2.new(1, 0, 0, 34)
idPill.Position = UDim2.new(0, 0, 0, 116)
idPill.BackgroundColor3 = Color3.fromRGB(13, 24, 46)
idPill.Parent = profileCard
corner(idPill, 999)
stroke(idPill, 1.5, Color3.fromRGB(36, 54, 89), 0)
registerSoftFrame(idPill)

local idLabel = makeText(idPill, "ID • " .. tostring(player.UserId), Enum.Font.GothamBold, 14, Color3.fromRGB(170, 184, 208))
idLabel.Position = UDim2.new(0, 14, 0, 0)
idLabel.Size = UDim2.new(1, -28, 1, 0)

local syncPill = Instance.new("Frame")
syncPill.Size = UDim2.new(1, -16, 0, 30)
syncPill.Position = UDim2.new(0, 8, 1, -38)
syncPill.BackgroundColor3 = Color3.fromRGB(25, 54, 82)
syncPill.Parent = profileCard
corner(syncPill, 999)
stroke(syncPill, 1.5, Color3.fromRGB(53, 92, 136), 0)
registerSoftFrame(syncPill)

local syncLabel = makeText(syncPill, "Status • Synced", Enum.Font.GothamBold, 13, Color3.fromRGB(229, 240, 255))
syncLabel.Position = UDim2.new(0, 14, 0, 0)
syncLabel.Size = UDim2.new(1, -28, 1, 0)

local navHolder = Instance.new("ScrollingFrame")
navHolder.Name = "NavScroll"
navHolder.Size = UDim2.new(1, 0, 1, -220)
navHolder.BackgroundTransparency = 1
navHolder.BorderSizePixel = 0
navHolder.CanvasSize = UDim2.new(0, 0, 0, 0)
navHolder.AutomaticCanvasSize = Enum.AutomaticSize.Y
navHolder.ScrollBarThickness = 6
navHolder.ScrollingDirection = Enum.ScrollingDirection.Y
navHolder.Parent = sidebar

local navList = list(navHolder, Enum.FillDirection.Vertical, 10)

local function makeTabButton(tabName, sub)
	local btn = Instance.new("TextButton")
	btn.AutoButtonColor = false
	btn.BackgroundColor3 = Color3.fromRGB(11, 21, 43)
	btn.Size = UDim2.new(1, 0, 0, 66)
	btn.Text = ""
	btn.Parent = navHolder
	corner(btn, 18)
	stroke(btn, 1.5, Color3.fromRGB(28, 46, 77), 0)
	registerSoftFrame(btn)

	local indicator = Instance.new("Frame")
	indicator.Size = UDim2.new(0, 6, 0, 40)
	indicator.Position = UDim2.new(0, 10, 0.5, -20)
	indicator.BackgroundColor3 = THEME_COLORS[State.Theme].Accent
	indicator.BackgroundTransparency = 1
	indicator.Parent = btn
	corner(indicator, 999)
	registerAccentFrame(indicator)

	local title = makeText(btn, tabName, Enum.Font.GothamBlack, 18, Color3.fromRGB(238, 244, 255))
	title.Position = UDim2.new(0, 26, 0, 10)
	title.Size = UDim2.new(1, -38, 0, 22)

	local subLabel = makeText(btn, sub, Enum.Font.GothamBold, 13, Color3.fromRGB(147, 164, 198))
	subLabel.Position = UDim2.new(0, 26, 0, 34)
	subLabel.Size = UDim2.new(1, -38, 0, 16)

	TAB_BUTTONS[tabName] = { Button = btn, Indicator = indicator, Title = title, Sub = subLabel }
	applyButtonFX(btn)
	return btn
end

local overviewTab = makeTabButton("Overview", "Quick status and presets")
local audioTab = makeTabButton("Audio", "Volume mix and mute routing")
local graphicsTab = makeTabButton("Graphics", "Performance and world visuals")
local interfaceTab = makeTabButton("Interface", "UI scale and feedback rules")
local styleTab = makeTabButton("Style", "Theme, font and finish")

--========================================================
-- CONTENT PANEL
--========================================================
local contentPanel = Instance.new("Frame")
contentPanel.Name = "ContentPanel"
contentPanel.Size = UDim2.new(1, -266, 1, 0)
contentPanel.LayoutOrder = 2
contentPanel.BackgroundColor3 = Color3.fromRGB(4, 9, 20)
contentPanel.Parent = main
corner(contentPanel, 24)
stroke(contentPanel, 2, Color3.fromRGB(35, 58, 95), 0)
registerCard(contentPanel)

local pageContainer = Instance.new("Frame")
pageContainer.BackgroundTransparency = 1
pageContainer.Size = UDim2.fromScale(1, 1)
pageContainer.Parent = contentPanel

local function createPage(name)
	local page = Instance.new("Frame")
	page.Name = name
	page.Size = UDim2.fromScale(1, 1)
	page.Visible = false
	page.BackgroundTransparency = 1
	page.Parent = pageContainer

	local scroll = Instance.new("ScrollingFrame")
	scroll.Name = "Scroll"
	scroll.Size = UDim2.fromScale(1, 1)
	scroll.BackgroundTransparency = 1
	scroll.BorderSizePixel = 0
	scroll.ScrollBarThickness = 8
	scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scroll.ScrollingDirection = Enum.ScrollingDirection.Y
	scroll.Parent = page

	local content = Instance.new("Frame")
	content.Name = "Content"
	content.BackgroundTransparency = 1
	content.AutomaticSize = Enum.AutomaticSize.Y
	content.Size = UDim2.new(1, -14, 0, 0)
	content.Parent = scroll
	padding(content, 18, 18, 18, 18)
	local lay = list(content, Enum.FillDirection.Vertical, 14)
	scroll:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		content.Size = UDim2.new(1, -14, 0, 0)
	end)

	PAGES[name] = { Page = page, Scroll = scroll, Content = content, Layout = lay }
	return PAGES[name]
end

local overviewPage = createPage("Overview")
local audioPage = createPage("Audio")
local graphicsPage = createPage("Graphics")
local interfacePage = createPage("Interface")
local stylePage = createPage("Style")

local function makeSection(parent, title, subtitle)
	local frame = Instance.new("Frame")
	frame.BackgroundColor3 = Color3.fromRGB(9, 18, 39)
	frame.AutomaticSize = Enum.AutomaticSize.Y
	frame.Size = UDim2.new(1, 0, 0, 0)
	frame.Parent = parent
	corner(frame, 22)
	stroke(frame, 1.5, Color3.fromRGB(31, 49, 82), 0)
	registerCard(frame)

	padding(frame, 18, 18, 16, 16)
	local lay = list(frame, Enum.FillDirection.Vertical, 12)

	local headerWrap = Instance.new("Frame")
	headerWrap.BackgroundTransparency = 1
	headerWrap.Size = UDim2.new(1, 0, 0, 58)
	headerWrap.Parent = frame

	local titleLbl = makeText(headerWrap, title, Enum.Font.GothamBlack, 18, Color3.fromRGB(240, 244, 255))
	titleLbl.Size = UDim2.new(1, 0, 0, 24)

	local subLbl = makeText(headerWrap, subtitle, Enum.Font.GothamBold, 14, Color3.fromRGB(147, 164, 198))
	subLbl.Position = UDim2.new(0, 0, 0, 26)
	subLbl.Size = UDim2.new(1, 0, 0, 20)

	return frame, lay
end

local function makeDualRow(parent)
	local row = Instance.new("Frame")
	row.BackgroundTransparency = 1
	row.ClipsDescendants = true
	row.Size = UDim2.new(1, 0, 0, 98)
	row.Parent = parent
	local layout = list(row, Enum.FillDirection.Horizontal, 16)
	return row, layout
end

local function makeStatCard(parent, title, value, sub)
	local card = Instance.new("Frame")
	card.Size = UDim2.new(0.5, -8, 0, 86)
	card.BackgroundColor3 = Color3.fromRGB(12, 24, 47)
	card.Parent = parent
	corner(card, 18)
	stroke(card, 1.5, Color3.fromRGB(31, 50, 84), 0)
	registerSoftFrame(card)

	local accentBar = Instance.new("Frame")
	accentBar.Size = UDim2.new(0, 6, 1, -18)
	accentBar.Position = UDim2.new(0, 0, 0, 9)
	accentBar.BackgroundColor3 = THEME_COLORS[State.Theme].Accent
	accentBar.Parent = card
	corner(accentBar, 999)
	registerAccentFrame(accentBar)

	local t = makeText(card, title, Enum.Font.GothamBlack, 16, Color3.fromRGB(166, 180, 205))
	t.Position = UDim2.new(0, 18, 0, 12)
	t.Size = UDim2.new(1, -24, 0, 20)

	local v = makeText(card, value, Enum.Font.GothamBlack, 26, Color3.fromRGB(245, 248, 255))
	v.Position = UDim2.new(0, 18, 0, 32)
	v.Size = UDim2.new(1, -24, 0, 28)

	local s = makeText(card, sub or "", Enum.Font.GothamBold, 13, Color3.fromRGB(141, 159, 196))
	s.Position = UDim2.new(0, 18, 1, -26)
	s.Size = UDim2.new(1, -24, 0, 16)

	table.insert(PREVIEW_LABELS, {Title = title, Value = v, Sub = s})
	return card, v, s
end

local function makePresetButton(parent, title, subtitle)
	local btn = makeButton(parent, "")
	btn.ClipsDescendants = true
	btn.Size = UDim2.new(0.5, -8, 0, 86)

	local tt = makeText(btn, title, Enum.Font.GothamBlack, 18, Color3.fromRGB(245, 248, 255))
	tt.Position = UDim2.new(0, 16, 0, 14)
	tt.Size = UDim2.new(1, -24, 0, 22)

	local ss = makeText(btn, subtitle, Enum.Font.GothamBold, 13, Color3.fromRGB(147, 164, 198))
	ss.Position = UDim2.new(0, 16, 0, 42)
	ss.Size = UDim2.new(1, -24, 0, 28)
	ss.TextWrapped = true
	ss.TextYAlignment = Enum.TextYAlignment.Top

	applyButtonFX(btn)
	return btn
end

local function makeSlider(parent, label, description, initialValue)
	local wrap = Instance.new("Frame")
	wrap.BackgroundTransparency = 1
	wrap.Size = UDim2.new(1, 0, 0, 96)
	wrap.Parent = parent

	local labelText = makeText(wrap, label, Enum.Font.GothamBlack, 17, Color3.fromRGB(242, 246, 255))
	labelText.Size = UDim2.new(1, -90, 0, 22)

	local descText = makeText(wrap, description, Enum.Font.GothamBold, 13, Color3.fromRGB(145, 161, 194))
	descText.Position = UDim2.new(0, 0, 0, 24)
	descText.Size = UDim2.new(1, -90, 0, 18)

	local valueText = makeText(wrap, tostring(math.floor((initialValue or 0) * 100 + 0.5)) .. "%", Enum.Font.GothamBlack, 16, THEME_COLORS[State.Theme].Accent, Enum.TextXAlignment.Right)
	valueText.Position = UDim2.new(1, -86, 0, 0)
	valueText.Size = UDim2.new(0, 86, 0, 22)
	registerAccentText(valueText)

	local track = Instance.new("Frame")
	track.Size = UDim2.new(1, 0, 0, 14)
	track.Position = UDim2.new(0, 0, 1, -20)
	track.BackgroundColor3 = Color3.fromRGB(26, 36, 65)
	track.Parent = wrap
	corner(track, 999)
	stroke(track, 1, Color3.fromRGB(34, 48, 79), 0)

	local fill = Instance.new("Frame")
	fill.Size = UDim2.new(initialValue or 0, 0, 1, 0)
	fill.BackgroundColor3 = THEME_COLORS[State.Theme].Accent
	fill.Parent = track
	corner(fill, 999)
	registerAccentFrame(fill)

	local knob = Instance.new("Frame")
	knob.Size = UDim2.new(0, 24, 0, 24)
	knob.AnchorPoint = Vector2.new(0.5, 0.5)
	knob.Position = UDim2.new(initialValue or 0, 0, 0.5, 0)
	knob.BackgroundColor3 = Color3.fromRGB(241, 245, 255)
	knob.Parent = track
	corner(knob, 999)
	stroke(knob, 1.5, Color3.fromRGB(64, 88, 132), 0)

	local dragging = false
	local value = initialValue or 0
	local onChanged = nil

	local function render(alpha)
		value = math.clamp(alpha, 0, 1)
		fill.Size = UDim2.new(value, 0, 1, 0)
		knob.Position = UDim2.new(value, 0, 0.5, 0)
		valueText.Text = tostring(math.floor(value * 100 + 0.5)) .. "%"
		if onChanged then
			onChanged(value)
		end
	end

	local function setFromX(x)
		local absPos = track.AbsolutePosition.X
		local absSize = track.AbsoluteSize.X
		local alpha = 0
		if absSize > 0 then
			alpha = (x - absPos) / absSize
		end
		render(alpha)
	end

	connect(track.InputBegan, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			playClickSound()
			setFromX(input.Position.X)
		end
	end)

	connect(track.InputEnded, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)

	connect(UserInputService.InputChanged, function(input)
		if not dragging then return end
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			setFromX(input.Position.X)
		end
	end)

	render(value)

	return {
		Root = wrap,
		Set = function(alpha) render(alpha) end,
		Get = function() return value end,
		OnChanged = function(fn) onChanged = fn; if fn then fn(value) end end,
		ValueText = valueText,
		Fill = fill,
	}
end

local function makeToggle(parent, title, description, initialOn)
	local row = Instance.new("Frame")
	row.BackgroundTransparency = 1
	row.Size = UDim2.new(1, 0, 0, 62)
	row.Parent = parent

	local t = makeText(row, title, Enum.Font.GothamBlack, 17, Color3.fromRGB(242, 246, 255))
	t.Size = UDim2.new(1, -132, 0, 22)

	local s = makeText(row, description, Enum.Font.GothamBold, 13, Color3.fromRGB(145, 161, 194))
	s.Position = UDim2.new(0, 0, 0, 24)
	s.Size = UDim2.new(1, -132, 0, 18)

	local btn = Instance.new("TextButton")
	btn.AutoButtonColor = false
	btn.Text = ""
	btn.AnchorPoint = Vector2.new(1, 0.5)
	btn.Position = UDim2.new(1, 0, 0.5, 0)
	btn.Size = UDim2.new(0, 88, 0, 34)
	btn.BackgroundColor3 = Color3.fromRGB(26, 42, 66)
	btn.Parent = row
	corner(btn, 999)
	stroke(btn, 1.5, Color3.fromRGB(43, 68, 108), 0)
	registerSoftFrame(btn)

	local dot = Instance.new("Frame")
	dot.Size = UDim2.new(0, 26, 0, 26)
	dot.Position = UDim2.new(0, 4, 0.5, -13)
	dot.BackgroundColor3 = THEME_COLORS[State.Theme].Accent
	dot.Parent = btn
	corner(dot, 999)
	stroke(dot, 1, Color3.fromRGB(255, 255, 255), 0.85)
	registerAccentFrame(dot)
	table.insert(TOGGLE_DOTS, dot)

	local value = initialOn and true or false
	local onChanged = nil

	local function render(immediate)
		local targetPos = value and UDim2.new(1, -30, 0.5, -13) or UDim2.new(0, 4, 0.5, -13)
		local targetColor = value and Color3.fromRGB(31, 70, 112) or Color3.fromRGB(26, 42, 66)
		if immediate then
			dot.Position = targetPos
			btn.BackgroundColor3 = targetColor
		else
			playTween(dot, TweenInfo.new(State.ReduceMotion and 0.08 or 0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = targetPos})
			playTween(btn, TweenInfo.new(State.ReduceMotion and 0.08 or 0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = targetColor})
		end
		if onChanged then
			onChanged(value)
		end
	end

	connect(btn.MouseButton1Click, function()
		playClickSound()
		value = not value
		render(false)
	end)

	render(true)

	return {
		Root = row,
		Get = function() return value end,
		Set = function(v) value = v and true or false; render(true) end,
		OnChanged = function(fn) onChanged = fn; if fn then fn(value) end end,
	}
end

local function setTab(tabName)
	State.Tab = tabName
	for name, data in pairs(PAGES) do
		data.Page.Visible = (name == tabName)
	end
	for name, data in pairs(TAB_BUTTONS) do
		local active = (name == tabName)
		data.Button.BackgroundColor3 = active and Color3.fromRGB(20, 57, 91) or Color3.fromRGB(11, 21, 43)
		data.Indicator.BackgroundTransparency = active and 0 or 1
		data.Title.TextColor3 = active and Color3.fromRGB(245, 248, 255) or Color3.fromRGB(230, 236, 247)
		data.Sub.TextColor3 = active and Color3.fromRGB(196, 214, 239) or Color3.fromRGB(147, 164, 198)
	end
end

--========================================================
-- OVERVIEW CONTENT
--========================================================
do
	local section, lay = makeSection(overviewPage.Content, "System Snapshot", "Live state overview with visible presets.")
	local row1 = makeDualRow(section)
	local levelCard, liveValue1, liveSub1 = makeStatCard(row1, "MASTER VOLUME", "65%", "Mirrors current SFX slider")
	local row2 = makeDualRow(section)
	local _, liveValue2, liveSub2 = makeStatCard(row2, "VISUAL PROFILE", "High", "Reads graphics and style state")
	local _, liveValue3, liveSub3 = makeStatCard(row2, "INTERFACE", "Standard", "Reflects compact, motion and notifications")

	local presetSection, presetLay = makeSection(overviewPage.Content, "Quick Presets", "Each button applies a fully visible preset instantly.")
	local presetRow1 = makeDualRow(presetSection)
	local quietBtn = makePresetButton(presetRow1, "Quiet Focus", "Lower music and ambience, keep UI clean and readable.")
	local performanceBtn = makePresetButton(presetRow1, "Performance", "Reduces visual load, disables heavy effects and motion.")
	local presetRow2 = makeDualRow(presetSection)
	local immersiveBtn = makePresetButton(presetRow2, "Immersive", "Boost ambience and bloom for richer scene feel.")
	local cleanBtn = makePresetButton(presetRow2, "Clean UI", "Compact layout, high contrast and lower motion.")

	quietBtn.MouseButton1Click:Connect(function()
		State.Sound = 0.55
		State.Music = 0.22
		State.Ambience = 0.25
		State.MuteMusic = false
		State.MuteAmbience = false
		State.MuteSFX = false
		State.LivePreview = true
		gui:SetAttribute("SettingsPreset", "QuietFocus")
		syncControlsFromState()
		applyAllVisuals()
		updateFooter("Quiet Focus preset applied.")
	end)

	performanceBtn.MouseButton1Click:Connect(function()
		State.Bloom = false
		State.ColorFX = false
		State.GlobalShadows = false
		State.ReduceMotion = true
		State.CompactMode = true
		State.HighContrast = false
		State.Brightness = 0.45
		State.FOV = 68
		gui:SetAttribute("SettingsPreset", "Performance")
		syncControlsFromState()
		applyAllVisuals()
		updateFooter("Performance preset applied.")
	end)

	immersiveBtn.MouseButton1Click:Connect(function()
		State.Sound = 0.72
		State.Music = 0.64
		State.Ambience = 0.78
		State.Bloom = true
		State.ColorFX = true
		State.GlobalShadows = true
		State.Brightness = 0.58
		State.FOV = 74
		gui:SetAttribute("SettingsPreset", "Immersive")
		syncControlsFromState()
		applyAllVisuals()
		updateFooter("Immersive preset applied.")
	end)

	cleanBtn.MouseButton1Click:Connect(function()
		State.CompactMode = true
		State.HighContrast = true
		State.ReduceMotion = true
		State.ShowNotifications = true
		gui:SetAttribute("SettingsPreset", "CleanUI")
		syncControlsFromState()
		applyAllVisuals()
		updateFooter("Clean UI preset applied.")
	end)

	table.insert(PREVIEW_LABELS, { Value = liveValue1, Sub = liveSub1, Key = "OverviewMaster" })
	table.insert(PREVIEW_LABELS, { Value = liveValue2, Sub = liveSub2, Key = "OverviewVisual" })
	table.insert(PREVIEW_LABELS, { Value = liveValue3, Sub = liveSub3, Key = "OverviewInterface" })
end

--========================================================
-- AUDIO CONTENT
--========================================================
local audioControls = {}
do
	local audioSection = makeSection(audioPage.Content, "Audio Mix", "All sliders apply immediately and update SoundGroups when present.")
	audioControls.Sound = makeSlider(audioSection, "Sound Effects", "Gameplay feedback, buttons, hits and UI sounds.", State.Sound)
	audioControls.Music = makeSlider(audioSection, "Music", "Menu tracks, ambient songs and cinematic layers.", State.Music)
	audioControls.Ambience = makeSlider(audioSection, "Ambience", "World atmosphere, loops and environmental beds.", State.Ambience)

	local routingSection = makeSection(audioPage.Content, "Audio Routing", "Quick mute switches that preserve each saved mix value.")
	audioControls.MuteMusic = makeToggle(routingSection, "Mute Music", "Instantly silences the Music sound group.", State.MuteMusic)
	audioControls.MuteSFX = makeToggle(routingSection, "Mute SFX", "Instantly silences the SFX sound group.", State.MuteSFX)
	audioControls.MuteAmbience = makeToggle(routingSection, "Mute Ambience", "Instantly silences the Ambience sound group.", State.MuteAmbience)
end

--========================================================
-- GRAPHICS CONTENT
--========================================================
local graphicsControls = {}
do
	local visualSection = makeSection(graphicsPage.Content, "World Visuals", "These controls update local lighting and camera behavior immediately.")
	graphicsControls.Brightness = makeSlider(visualSection, "Brightness", "Adds a local brightness bias through color correction.", 0.5)
	graphicsControls.FOV = makeSlider(visualSection, "Field of View", "Adjusts your camera field of view between 60 and 90.", 0.3333)

	local toggleSection = makeSection(graphicsPage.Content, "Render Features", "Every toggle has a direct visible effect.")
	graphicsControls.GlobalShadows = makeToggle(toggleSection, "Global Shadows", "Turns Lighting.GlobalShadows on or off.", State.GlobalShadows)
	graphicsControls.Bloom = makeToggle(toggleSection, "Bloom", "Enables or disables a local bloom effect.", State.Bloom)
	graphicsControls.ColorFX = makeToggle(toggleSection, "Color FX", "Enables or disables local color correction.", State.ColorFX)

	local qualitySection = makeSection(graphicsPage.Content, "Graphics Preset", "Cycles through Low, Medium and High with instant effect.")
	local qualityRow = makeDualRow(qualitySection)
	local presetBtn = makeButton(qualityRow, "QUALITY • HIGH")
	presetBtn.Size = UDim2.new(1, 0, 0, 66)
	presetBtn.TextSize = 20
	applyButtonFX(presetBtn)
	graphicsControls.QualityButton = presetBtn
	graphicsControls.QualityIndex = 3
end

--========================================================
-- INTERFACE CONTENT
--========================================================
local interfaceControls = {}
do
	local layoutSection = makeSection(interfacePage.Content, "Interface Behavior", "Every control updates the settings UI or exported attributes immediately.")
	interfaceControls.CompactMode = makeToggle(layoutSection, "Compact Mode", "Tightens cards, paddings and row heights.", State.CompactMode)
	interfaceControls.ShowNotifications = makeToggle(layoutSection, "Show Notifications", "Exports a visible attribute for your game notification system.", State.ShowNotifications)
	interfaceControls.DamageNumbers = makeToggle(layoutSection, "Damage Numbers", "Exports a visible attribute for your damage number system.", State.DamageNumbers)
	interfaceControls.ReduceMotion = makeToggle(layoutSection, "Reduce Motion", "Cuts animation timing for a calmer experience.", State.ReduceMotion)
	interfaceControls.LivePreview = makeToggle(layoutSection, "Live Preview", "Allows or pauses instant visual updates while editing.", State.LivePreview)

	local scaleSection = makeSection(interfacePage.Content, "Scale and Density", "Slider changes the panel scale immediately without overlap.")
	interfaceControls.Scale = makeSlider(scaleSection, "UI Density", "Low keeps things larger. High fits more content on screen.", 0.55)
end

--========================================================
-- STYLE CONTENT
--========================================================
local styleControls = {}
do
	local themeSection = makeSection(stylePage.Content, "Theme", "Buttons cycle theme and font instantly.")
	local styleRow = makeDualRow(themeSection)

	local themeBtn = makeButton(styleRow, "THEME • " .. State.Theme:upper())
	themeBtn.Size = UDim2.new(0.5, -8, 0, 68)
	themeBtn.TextSize = 19
	applyButtonFX(themeBtn)

	local fontBtn = makeButton(styleRow, "FONT • " .. State.Font:upper())
	fontBtn.Size = UDim2.new(0.5, -8, 0, 68)
	fontBtn.TextSize = 19
	applyButtonFX(fontBtn)

	styleControls.ThemeButton = themeBtn
	styleControls.FontButton = fontBtn
	styleControls.ThemeIndex = 1
	styleControls.FontIndex = 1

	local finishSection = makeSection(stylePage.Content, "Finish", "Visible finishing controls for contrast and accent intensity.")
	styleControls.HighContrast = makeToggle(finishSection, "High Contrast", "Deepens panel contrast and sharpens readability.", State.HighContrast)
	styleControls.AccentPower = makeSlider(finishSection, "Accent Power", "Controls how intense the accent tint appears across the UI.", 0.55)
end

--========================================================
-- FOOTER
--========================================================
local footer = Instance.new("Frame")
footer.Name = "Footer"
footer.ClipsDescendants = true
footer.Size = UDim2.new(1, 0, 0, 64)
footer.BackgroundColor3 = Color3.fromRGB(4, 11, 23)
footer.Position = UDim2.new(0, 0, 1, -64)
footer.Parent = panel
corner(footer, 24)
stroke(footer, 2, Color3.fromRGB(35, 58, 95), 0)
registerCard(footer)

local footerHint = makeText(footer, "Ready. Every button and slider has a live function.", Enum.Font.GothamBold, 15, Color3.fromRGB(166, 180, 205))
footerHint.Position = UDim2.new(0, 18, 0, 0)
footerHint.TextWrapped = false
footerHint.TextTruncate = Enum.TextTruncate.AtEnd
footerHint.Size = UDim2.new(1, -350, 1, 0)

local footerButtons = Instance.new("Frame")
footerButtons.AnchorPoint = Vector2.new(1, 0.5)
footerButtons.Position = UDim2.new(1, -14, 0.5, 0)
footerButtons.Size = UDim2.new(0, 308, 0, 46)
footerButtons.BackgroundTransparency = 1
footerButtons.Parent = footer
local footerButtonsLayout = list(footerButtons, Enum.FillDirection.Horizontal, 12)

local resetBtn = makeButton(footerButtons, "RESET")
resetBtn.Size = UDim2.new(0, 140, 1, 0)
resetBtn.TextSize = 21
resetBtn.Font = Enum.Font.GothamBlack
applyButtonFX(resetBtn)

local applyBtn = makeButton(footerButtons, "APPLY")
applyBtn.Size = UDim2.new(0, 156, 1, 0)
applyBtn.TextSize = 21
applyBtn.Font = Enum.Font.GothamBlack
registerAccentFrame(applyBtn)
applyButtonFX(applyBtn)

--========================================================
-- VISUAL APPLICATION
--========================================================
local function applyFont()
	local font = FONT_MAP[State.Font] or Enum.Font.Gotham
	for _, obj in ipairs(TEXT_OBJECTS) do
		if obj and obj.Parent then
			obj.Font = font
		end
	end
	titleText.Font = Enum.Font.GothamBlack
	exitBtn.Font = Enum.Font.GothamBlack
	applyBtn.Font = Enum.Font.GothamBlack
	resetBtn.Font = Enum.Font.GothamBlack
end

local function getAccentBundle()
	return THEME_COLORS[State.Theme] or THEME_COLORS.Cyan
end

local function scaleColor(c, alpha)
	return Color3.new(
		math.clamp(c.R * alpha, 0, 1),
		math.clamp(c.G * alpha, 0, 1),
		math.clamp(c.B * alpha, 0, 1)
	)
end

local function applyTheme()
	local bundle = getAccentBundle()
	local accent = bundle.Accent
	local soft = bundle.Soft
	local glow = bundle.Glow

	for _, obj in ipairs(ACCENT_FRAMES) do
		if obj and obj.Parent then
			obj.BackgroundColor3 = accent
		end
	end
	for _, obj in ipairs(ACCENT_STROKES) do
		if obj and obj.Parent then
			obj.Color = accent
		end
	end
	for _, obj in ipairs(ACCENT_TEXTS) do
		if obj and obj.Parent then
			obj.TextColor3 = accent
		end
	end
	for _, obj in ipairs(SOFT_FRAMES) do
		if obj and obj.Parent then
			obj.BackgroundColor3 = soft
		end
	end

	applyBtn.BackgroundColor3 = glow
	local liveOn = State.LivePreview
	livePill.BackgroundColor3 = liveOn and soft or Color3.fromRGB(31, 36, 49)
	liveLabel.TextColor3 = liveOn and Color3.fromRGB(115, 248, 167) or Color3.fromRGB(170, 178, 193)
	liveDot.BackgroundColor3 = liveOn and Color3.fromRGB(115, 248, 167) or Color3.fromRGB(148, 156, 174)
end

local function applyContrast()
	local high = State.HighContrast
	local panelColorA = high and Color3.fromRGB(2, 5, 12) or Color3.fromRGB(5, 9, 18)
	local panelColorB = high and Color3.fromRGB(1, 3, 9) or Color3.fromRGB(3, 7, 16)
	local cardBg = high and Color3.fromRGB(6, 14, 31) or Color3.fromRGB(9, 18, 39)

	panel.BackgroundColor3 = panelColorA
	panelGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, panelColorA),
		ColorSequenceKeypoint.new(1, panelColorB)
	})
	for _, card in ipairs(CARD_FRAMES) do
		if card and card.Parent then
			card.BackgroundColor3 = cardBg
		end
	end
	header.BackgroundColor3 = high and Color3.fromRGB(0, 4, 10) or Color3.fromRGB(2, 6, 14)
	contentPanel.BackgroundColor3 = high and Color3.fromRGB(1, 5, 13) or Color3.fromRGB(4, 9, 20)
	footer.BackgroundColor3 = high and Color3.fromRGB(2, 8, 18) or Color3.fromRGB(4, 11, 23)
	sidebar.BackgroundColor3 = high and Color3.fromRGB(3, 8, 19) or Color3.fromRGB(7, 13, 27)
end

local function applyLighting()
	if not State.LivePreview and State.IsOpen then
		return
	end

	bloom.Enabled = State.Bloom
	colorCorrection.Enabled = State.ColorFX
	Lighting.GlobalShadows = State.GlobalShadows

	local brightnessAlpha = State.Brightness
	colorCorrection.Brightness = (brightnessAlpha - 0.5) * 0.4
	colorCorrection.Contrast = State.HighContrast and 0.09 or 0.04
	colorCorrection.Saturation = State.ColorFX and 0.03 or 0
	colorCorrection.TintColor = getAccentBundle().Accent:Lerp(Color3.fromRGB(255, 255, 255), 0.92)

	if camera then
		camera.FieldOfView = State.FOV
	end
end

local compactTargets = {}
local function applyCompact()
	local compact = State.CompactMode
	for _, item in ipairs(compactTargets) do
		if item and item.obj and item.expanded and item.compact then
			local target = compact and item.compact or item.expanded
			item.obj.Size = target
		end
	end
end

local function updateExportAttributes()
	gui:SetAttribute("Settings_ShowNotifications", State.ShowNotifications)
	gui:SetAttribute("Settings_DamageNumbers", State.DamageNumbers)
	gui:SetAttribute("Settings_CompactMode", State.CompactMode)
	gui:SetAttribute("Settings_ReduceMotion", State.ReduceMotion)
	gui:SetAttribute("Settings_Theme", State.Theme)
	gui:SetAttribute("Settings_Font", State.Font)
	gui:SetAttribute("Settings_LivePreview", State.LivePreview)
	gui:SetAttribute("Settings_MasterVolume", State.Sound)
	gui:SetAttribute("Settings_MusicVolume", State.Music)
	gui:SetAttribute("Settings_AmbienceVolume", State.Ambience)
end

local function updateFooter(message)
	footerHint.Text = message
end

local function applyAudio()
	local sfx = ensureSoundGroup("SFX")
	local music = ensureSoundGroup("Music")
	local ambience = ensureSoundGroup("Ambience")

	if sfx then
		sfx.Volume = State.MuteSFX and 0 or State.Sound
	end
	if music then
		music.Volume = State.MuteMusic and 0 or State.Music
	end
	if ambience then
		ambience.Volume = State.MuteAmbience and 0 or State.Ambience
	end
end

local function updatePreview()
	for _, item in ipairs(PREVIEW_LABELS) do
		if item.Key == "OverviewMaster" then
			item.Value.Text = tostring(math.floor(State.Sound * 100 + 0.5)) .. "%"
			item.Sub.Text = "Music " .. tostring(math.floor(State.Music * 100 + 0.5)) .. "% • Ambience " .. tostring(math.floor(State.Ambience * 100 + 0.5)) .. "%"
		elseif item.Key == "OverviewVisual" then
			local quality = (State.GlobalShadows and State.Bloom and State.ColorFX) and "High" or ((State.Bloom or State.ColorFX or State.GlobalShadows) and "Medium" or "Low")
			item.Value.Text = quality
			item.Sub.Text = "Brightness " .. tostring(math.floor(((State.Brightness - 0) / 1) * 100 + 0.5)) .. "% • FOV " .. tostring(math.floor(State.FOV + 0.5))
		elseif item.Key == "OverviewInterface" then
			item.Value.Text = State.CompactMode and "Compact" or "Standard"
			item.Sub.Text = (State.ReduceMotion and "Low motion" or "Full motion") .. " • " .. (State.ShowNotifications and "Notifications on" or "Notifications off")
		end
	end
end

local function applyAllVisuals()
	applyFont()
	applyTheme()
	applyContrast()
	applyCompact()
	applyLighting()
	applyAudio()
	updatePreview()
	updateExportAttributes()
end

local function syncControlsFromState()
	if audioControls.Sound then audioControls.Sound.Set(State.Sound) end
	if audioControls.Music then audioControls.Music.Set(State.Music) end
	if audioControls.Ambience then audioControls.Ambience.Set(State.Ambience) end
	if audioControls.MuteMusic then audioControls.MuteMusic.Set(State.MuteMusic) end
	if audioControls.MuteSFX then audioControls.MuteSFX.Set(State.MuteSFX) end
	if audioControls.MuteAmbience then audioControls.MuteAmbience.Set(State.MuteAmbience) end
	if graphicsControls.Brightness then graphicsControls.Brightness.Set(State.Brightness) end
	if graphicsControls.FOV then
		local fovAlpha = math.clamp((State.FOV - 60) / 30, 0, 1)
		graphicsControls.FOV.Set(fovAlpha)
	end
	if graphicsControls.GlobalShadows then graphicsControls.GlobalShadows.Set(State.GlobalShadows) end
	if graphicsControls.Bloom then graphicsControls.Bloom.Set(State.Bloom) end
	if graphicsControls.ColorFX then graphicsControls.ColorFX.Set(State.ColorFX) end
	if interfaceControls.CompactMode then interfaceControls.CompactMode.Set(State.CompactMode) end
	if interfaceControls.ShowNotifications then interfaceControls.ShowNotifications.Set(State.ShowNotifications) end
	if interfaceControls.DamageNumbers then interfaceControls.DamageNumbers.Set(State.DamageNumbers) end
	if interfaceControls.ReduceMotion then interfaceControls.ReduceMotion.Set(State.ReduceMotion) end
	if interfaceControls.LivePreview then interfaceControls.LivePreview.Set(State.LivePreview) end
	if interfaceControls.Scale then
		interfaceControls.Scale.Set(0.5)
	end
	local quality = 1
	if State.GlobalShadows and State.ColorFX then
		quality = State.Bloom and 3 or 2
	end
	graphicsControls.QualityIndex = quality
	if graphicsControls.QualityButton then
		graphicsControls.QualityButton.Text = "QUALITY • " .. ({"LOW", "MEDIUM", "HIGH"})[quality]
	end
	if styleControls.ThemeButton then styleControls.ThemeButton.Text = "THEME • " .. State.Theme:upper() end
	if styleControls.FontButton then styleControls.FontButton.Text = "FONT • " .. State.Font:upper() end
	if styleControls.HighContrast then styleControls.HighContrast.Set(State.HighContrast) end
end

--========================================================
-- BIND CONTROL BEHAVIOR
--========================================================
audioControls.Sound.OnChanged(function(v)
	State.Sound = v
	updateFooter("Sound effects volume updated to " .. tostring(math.floor(v * 100 + 0.5)) .. "%.")
	applyAllVisuals()
end)
audioControls.Music.OnChanged(function(v)
	State.Music = v
	updateFooter("Music volume updated to " .. tostring(math.floor(v * 100 + 0.5)) .. "%.")
	applyAllVisuals()
end)
audioControls.Ambience.OnChanged(function(v)
	State.Ambience = v
	updateFooter("Ambience volume updated to " .. tostring(math.floor(v * 100 + 0.5)) .. "%.")
	applyAllVisuals()
end)

audioControls.MuteMusic.OnChanged(function(v)
	State.MuteMusic = v
	updateFooter(v and "Music muted." or "Music restored.")
	applyAllVisuals()
end)
audioControls.MuteSFX.OnChanged(function(v)
	State.MuteSFX = v
	updateFooter(v and "SFX muted." or "SFX restored.")
	applyAllVisuals()
end)
audioControls.MuteAmbience.OnChanged(function(v)
	State.MuteAmbience = v
	updateFooter(v and "Ambience muted." or "Ambience restored.")
	applyAllVisuals()
end)

graphicsControls.Brightness.OnChanged(function(v)
	State.Brightness = v
	updateFooter("Brightness updated.")
	applyAllVisuals()
end)
graphicsControls.FOV.OnChanged(function(v)
	State.FOV = 60 + (v * 30)
	updateFooter("Field of view set to " .. tostring(math.floor(State.FOV + 0.5)) .. ".")
	applyAllVisuals()
end)

graphicsControls.GlobalShadows.OnChanged(function(v)
	State.GlobalShadows = v
	updateFooter(v and "Global shadows enabled." or "Global shadows disabled.")
	applyAllVisuals()
end)
graphicsControls.Bloom.OnChanged(function(v)
	State.Bloom = v
	updateFooter(v and "Bloom enabled." or "Bloom disabled.")
	applyAllVisuals()
end)
graphicsControls.ColorFX.OnChanged(function(v)
	State.ColorFX = v
	updateFooter(v and "Color FX enabled." or "Color FX disabled.")
	applyAllVisuals()
end)

local qualityNames = {"LOW", "MEDIUM", "HIGH"}
graphicsControls.QualityButton.MouseButton1Click:Connect(function()
	graphicsControls.QualityIndex += 1
	if graphicsControls.QualityIndex > 3 then
		graphicsControls.QualityIndex = 1
	end
	local idx = graphicsControls.QualityIndex
	graphicsControls.QualityButton.Text = "QUALITY • " .. qualityNames[idx]
	if idx == 1 then
		State.GlobalShadows = false
		State.Bloom = false
		State.ColorFX = false
		State.Brightness = 0.45
	elseif idx == 2 then
		State.GlobalShadows = true
		State.Bloom = false
		State.ColorFX = true
		State.Brightness = 0.52
	else
		State.GlobalShadows = true
		State.Bloom = true
		State.ColorFX = true
		State.Brightness = 0.58
	end
	graphicsControls.GlobalShadows.Set(State.GlobalShadows)
	graphicsControls.Bloom.Set(State.Bloom)
	graphicsControls.ColorFX.Set(State.ColorFX)
	graphicsControls.Brightness.Set(State.Brightness)
	updateFooter("Graphics preset switched to " .. qualityNames[idx] .. ".")
	applyAllVisuals()
end)

interfaceControls.CompactMode.OnChanged(function(v)
	State.CompactMode = v
	updateFooter(v and "Compact mode enabled." or "Compact mode disabled.")
	applyAllVisuals()
end)
interfaceControls.ShowNotifications.OnChanged(function(v)
	State.ShowNotifications = v
	updateFooter(v and "Notifications flag enabled." or "Notifications flag disabled.")
	applyAllVisuals()
end)
interfaceControls.DamageNumbers.OnChanged(function(v)
	State.DamageNumbers = v
	updateFooter(v and "Damage numbers flag enabled." or "Damage numbers flag disabled.")
	applyAllVisuals()
end)
interfaceControls.ReduceMotion.OnChanged(function(v)
	State.ReduceMotion = v
	updateFooter(v and "Reduced motion enabled." or "Reduced motion disabled.")
	applyAllVisuals()
end)
interfaceControls.LivePreview.OnChanged(function(v)
	State.LivePreview = v
	updateFooter(v and "Live preview enabled." or "Live preview paused. Use Apply to commit visual changes.")
	applyAllVisuals()
end)
interfaceControls.Scale.OnChanged(function(v)
	local density = 0.82 + (v * 0.32)
	currentScale = math.clamp(density * currentScale, MIN_SCALE, MAX_SCALE)
	updateFooter("UI density adjusted.")
end)

local themeOrder = {"Cyan", "Purple", "Green", "Orange", "Red"}
local fontOrder = {"Gotham", "Arcade", "Fredoka", "SciFi"}

styleControls.ThemeButton.MouseButton1Click:Connect(function()
	styleControls.ThemeIndex += 1
	if styleControls.ThemeIndex > #themeOrder then
		styleControls.ThemeIndex = 1
	end
	State.Theme = themeOrder[styleControls.ThemeIndex]
	styleControls.ThemeButton.Text = "THEME • " .. State.Theme:upper()
	updateFooter("Theme changed to " .. State.Theme .. ".")
	applyAllVisuals()
	setTab(State.Tab)
end)

styleControls.FontButton.MouseButton1Click:Connect(function()
	styleControls.FontIndex += 1
	if styleControls.FontIndex > #fontOrder then
		styleControls.FontIndex = 1
	end
	State.Font = fontOrder[styleControls.FontIndex]
	styleControls.FontButton.Text = "FONT • " .. State.Font:upper()
	updateFooter("Font changed to " .. State.Font .. ".")
	applyAllVisuals()
end)

styleControls.HighContrast.OnChanged(function(v)
	State.HighContrast = v
	updateFooter(v and "High contrast enabled." or "High contrast disabled.")
	applyAllVisuals()
end)

styleControls.AccentPower.OnChanged(function(v)
	local theme = getAccentBundle()
	local baseAccent = theme.Accent
	local mix = 0.75 + (v * 0.55)
	THEME_COLORS[State.Theme].Accent = scaleColor(baseAccent, mix)
	updateFooter("Accent power changed.")
	applyAllVisuals()
end)

--========================================================
-- TAB SWITCHES
--========================================================
overviewTab.MouseButton1Click:Connect(function() setTab("Overview") end)
audioTab.MouseButton1Click:Connect(function() setTab("Audio") end)
graphicsTab.MouseButton1Click:Connect(function() setTab("Graphics") end)
interfaceTab.MouseButton1Click:Connect(function() setTab("Interface") end)
styleTab.MouseButton1Click:Connect(function() setTab("Style") end)

--========================================================
-- RESPONSIVE / NO OVERLAP
--========================================================
local function getSafeViewport()
	local vp = gui.AbsoluteSize
	local insetX, insetY = 0, 0

	local okInset, inset = pcall(function()
		return GuiService:GetGuiInset()
	end)
	if okInset and (typeof(inset) == "Vector2" or typeof(inset) == "Vector2int16") then
		insetY += inset.Y
	end

	local okSafe, left, top, right, bottom = pcall(function()
		return GuiService:GetSafeZoneOffsets()
	end)
	if okSafe then
		insetX += left + right
		insetY += top + bottom
	end

	return Vector2.new(math.max(1, vp.X - insetX), math.max(1, vp.Y - insetY))
end

local function fitPanel()
	local vp = getSafeViewport()
	local sx = vp.X / BASE_PANEL_SIZE.X
	local sy = vp.Y / BASE_PANEL_SIZE.Y
	local target = math.clamp(math.min(sx, sy) * MOBILE_SCALE_PADDING, MIN_SCALE, MAX_SCALE)
	currentScale = target

	panel.Size = UDim2.new(0, BASE_PANEL_SIZE.X, 0, BASE_PANEL_SIZE.Y)
	uiScale.Scale = target

	local compactSidebar = target < 0.78
	sidebar.Size = compactSidebar and UDim2.new(0, 226, 1, 0) or UDim2.new(0, 252, 1, 0)
	contentPanel.Size = compactSidebar and UDim2.new(1, -240, 1, 0) or UDim2.new(1, -266, 1, 0)

	local smallerHeader = target < 0.7
	header.Size = UDim2.new(1, 0, 0, smallerHeader and 88 or 96)
	main.Size = UDim2.new(1, 0, 1, smallerHeader and -166 or -174)

	for _, p in pairs(PAGES) do
		p.Scroll.CanvasPosition = Vector2.new(0, 0)
	end
end

connect(gui:GetPropertyChangedSignal("AbsoluteSize"), fitPanel)

--========================================================
-- OPEN / CLOSE
--========================================================
local function setAlpha(a)
	panel.BackgroundTransparency = a
	header.BackgroundTransparency = a
	contentPanel.BackgroundTransparency = a
	footer.BackgroundTransparency = a
	sidebar.BackgroundTransparency = a
	for _, d in ipairs(panel:GetDescendants()) do
		if d:IsA("TextLabel") or d:IsA("TextButton") then
			d.TextTransparency = a
		elseif d:IsA("ImageLabel") then
			d.ImageTransparency = a
			d.BackgroundTransparency = math.max(a, 0)
		elseif d:IsA("Frame") then
			if d ~= panel and d ~= header and d ~= contentPanel and d ~= footer and d ~= sidebar then
				d.BackgroundTransparency = math.min(1, d.BackgroundTransparency + a * 0.85)
			end
		elseif d:IsA("UIStroke") then
			d.Transparency = math.min(1, a)
		end
	end
end

local function openUI()
	if State.Busy or State.IsOpen then return end
	State.Busy = true
	State.IsOpen = true

	fitPanel()
	panel.Visible = true
	dim.Visible = true
	blur.Enabled = true
	blur.Size = 0

	panel.Position = UDim2.new(0.5, 0, 0.5, 34)
	panel.BackgroundTransparency = 1
	dim.BackgroundTransparency = 1

	for _, p in pairs(PAGES) do
		p.Page.Visible = false
	end
	setTab(State.Tab)

	playTween(dim, TweenInfo.new(State.ReduceMotion and 0.1 or 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0.38})
	playTween(panel, TweenInfo.new(State.ReduceMotion and 0.1 or 0.26, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		Position = UDim2.new(0.5, 0, 0.5, 0),
		BackgroundTransparency = 0
	})
	playTween(blur, TweenInfo.new(State.ReduceMotion and 0.1 or 0.20, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = 12})

	task.delay(State.ReduceMotion and 0.10 or 0.28, function()
		State.Busy = false
	end)
end

local function closeUI()
	if State.Busy or not State.IsOpen then return end
	State.Busy = true
	State.IsOpen = false

	playTween(dim, TweenInfo.new(State.ReduceMotion and 0.08 or 0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {BackgroundTransparency = 1})
	playTween(panel, TweenInfo.new(State.ReduceMotion and 0.08 or 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
		Position = UDim2.new(0.5, 0, 0.5, 30),
		BackgroundTransparency = 1
	})
	playTween(blur, TweenInfo.new(State.ReduceMotion and 0.08 or 0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = 0})

	task.delay(State.ReduceMotion and 0.10 or 0.20, function()
		panel.Visible = false
		dim.Visible = false
		blur.Enabled = false
		State.Busy = false
	end)
end

exitBtn.MouseButton1Click:Connect(closeUI)

if CLOSE_WITH_ESC then
	UserInputService.InputBegan:Connect(function(input, gp)
		if gp then return end
		if not State.IsOpen then return end
		if input.KeyCode == Enum.KeyCode.Escape then
			playClickSound()
			closeUI()
		end
	end)
end

-- IMPORTANT: clicking outside no longer closes the panel.
dim.InputBegan:Connect(function()
	-- absorb clicks intentionally; do not close
end)

task.defer(function()
	local openBtn = playerGui:FindFirstChild(OPEN_BUTTON_NAME, true)
	if openBtn and openBtn:IsA("GuiButton") then
		openBtn.MouseButton1Click:Connect(function()
			playClickSound()
			openUI()
		end)
	else
		warn("[SettingsUi] Open button not found: " .. tostring(OPEN_BUTTON_NAME))
	end
end)

--========================================================
-- APPLY / RESET
--========================================================
local function loadDefaults()
	State.Theme = DEFAULTS.Theme
	State.Font = DEFAULTS.Font
	State.Sound = DEFAULTS.Sound
	State.Music = DEFAULTS.Music
	State.Ambience = DEFAULTS.Ambience
	State.Brightness = DEFAULTS.Brightness
	State.FOV = DEFAULTS.FOV
	State.GlobalShadows = DEFAULTS.GlobalShadows
	State.Bloom = DEFAULTS.Bloom
	State.ColorFX = DEFAULTS.ColorFX
	State.CompactMode = DEFAULTS.CompactMode
	State.ShowNotifications = DEFAULTS.ShowNotifications
	State.DamageNumbers = DEFAULTS.DamageNumbers
	State.ReduceMotion = DEFAULTS.ReduceMotion
	State.HighContrast = DEFAULTS.HighContrast
	State.LivePreview = DEFAULTS.LivePreview
	State.MuteMusic = false
	State.MuteSFX = false
	State.MuteAmbience = false

	styleControls.ThemeIndex = 1
	styleControls.FontIndex = 1
	graphicsControls.QualityIndex = 3

	audioControls.Sound.Set(State.Sound)
	audioControls.Music.Set(State.Music)
	audioControls.Ambience.Set(State.Ambience)
	audioControls.MuteMusic.Set(State.MuteMusic)
	audioControls.MuteSFX.Set(State.MuteSFX)
	audioControls.MuteAmbience.Set(State.MuteAmbience)

	graphicsControls.Brightness.Set(0.5)
	graphicsControls.FOV.Set((State.FOV - 60) / 30)
	graphicsControls.GlobalShadows.Set(State.GlobalShadows)
	graphicsControls.Bloom.Set(State.Bloom)
	graphicsControls.ColorFX.Set(State.ColorFX)
	graphicsControls.QualityButton.Text = "QUALITY • HIGH"

	interfaceControls.CompactMode.Set(State.CompactMode)
	interfaceControls.ShowNotifications.Set(State.ShowNotifications)
	interfaceControls.DamageNumbers.Set(State.DamageNumbers)
	interfaceControls.ReduceMotion.Set(State.ReduceMotion)
	interfaceControls.LivePreview.Set(State.LivePreview)
	interfaceControls.Scale.Set(0.55)

	styleControls.HighContrast.Set(State.HighContrast)
	styleControls.AccentPower.Set(0.55)
	styleControls.ThemeButton.Text = "THEME • " .. State.Theme:upper()
	styleControls.FontButton.Text = "FONT • " .. State.Font:upper()

	applyAllVisuals()
end

resetBtn.MouseButton1Click:Connect(function()
	loadDefaults()
	updateFooter("All settings reset to the default profile.")
end)

applyBtn.MouseButton1Click:Connect(function()
	applyAllVisuals()
	updateFooter("Settings applied and exported to attributes.")
end)

--========================================================
-- INITIALIZE
--========================================================
table.insert(compactTargets, {obj = header, expanded = UDim2.new(1, 0, 0, 96), compact = UDim2.new(1, 0, 0, 84)})
table.insert(compactTargets, {obj = footer, expanded = UDim2.new(1, 0, 0, 64), compact = UDim2.new(1, 0, 0, 58)})
table.insert(compactTargets, {obj = profileCard, expanded = UDim2.new(1, 0, 0, 184), compact = UDim2.new(1, 0, 0, 166)})

panel.Visible = false
dim.Visible = false
setTab("Overview")
loadDefaults()
fitPanel()