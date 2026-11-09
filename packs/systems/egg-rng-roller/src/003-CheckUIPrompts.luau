--[[
	CheckUIPrompts

	Draws every ProximityPrompt whose Style is "Custom" as a Check-UI button:

		[key cap]  [ icon  Action Text ]

	The button follows the Check-UI iconless-button recipe (sharp corners, 3px dark border,
	gradient, fading checkerboard, triple glass highlight, GothamBlack text with a dark outline).
	Holding fills the button; keyboard and gamepad work as normal, and clicking / tapping the
	button presses it too.

	Optional attributes on a prompt:
		CheckUITheme   "Lime" | "Amber" | "Cyan" | "Red" | "Pink" | "Purple"   (default "Lime")
		CheckUIIcon    image id shown left of the text, e.g. "rbxassetid://88694661500877" (cash stack)
		CheckUIOffset  Vector3 world offset for where the button is drawn
]]

local Players = game:GetService("Players")
local ProximityPromptService = game:GetService("ProximityPromptService")
local TweenService = game:GetService("TweenService")
local TextService = game:GetService("TextService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

local C3 = Color3.fromRGB
local WHITE = C3(255, 255, 255)
local BLACK = C3(0, 0, 0)
local CENTER = Vector2.new(0.5, 0.5)
local DAMIER_ID = "rbxassetid://385956923"

local THEMES = {
	Lime = ColorSequence.new(C3(180, 255, 25), C3(105, 225, 0)),
	Amber = ColorSequence.new(C3(255, 208, 0), C3(255, 140, 0)),
	Cyan = ColorSequence.new(C3(0, 210, 255), C3(0, 120, 255)),
	Red = ColorSequence.new(C3(255, 32, 80), C3(208, 0, 32)),
	Pink = ColorSequence.new(C3(255, 20, 128), C3(212, 0, 85)),
	Purple = ColorSequence.new(C3(176, 32, 255), C3(112, 0, 224)),
}
local GAMEPAD_KEYS = {
	ButtonA = "A", ButtonB = "B", ButtonX = "X", ButtonY = "Y",
	ButtonL1 = "LB", ButtonR1 = "RB", ButtonL2 = "LT", ButtonR2 = "RT",
	ButtonL3 = "L3", ButtonR3 = "R3",
}

local TEXT_SIZE = 24
local BUTTON_HEIGHT = 52
local KEY_SIZE = 46
local GAP = 10
local ICON_SIZE = 40

local SHOW_INFO = TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local HIDE_INFO = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
local PRESS_INFO = TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local RELEASE_INFO = TweenInfo.new(0.12, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local POP_INFO = TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

local holder = Instance.new("ScreenGui")
holder.Name = "CheckUIPrompts"
holder.ResetOnSpawn = false
holder.Parent = player:WaitForChild("PlayerGui")

local function new(className: string, props: { [string]: any }, parent: Instance?): any
	local object = Instance.new(className)
	for key, value in props do
		(object :: any)[key] = value
	end
	if parent then
		object.Parent = parent
	end
	return object
end

local function outline(parent: Instance, thickness: number, color: Color3, border: boolean?)
	return new("UIStroke", {
		Thickness = thickness,
		Color = color,
		ApplyStrokeMode = border and Enum.ApplyStrokeMode.Border or Enum.ApplyStrokeMode.Contextual,
		LineJoinMode = border and Enum.LineJoinMode.Miter or Enum.LineJoinMode.Round,
	}, parent)
end

-- same responsive rule as the menus (baseline 1050x620), but never smaller than 0.8 so it stays tappable
local function promptScale(): number
	local camera = workspace.CurrentCamera
	local viewport = camera and camera.ViewportSize or Vector2.new(1050, 620)
	if viewport.X <= 0 or viewport.Y <= 0 then
		return 1
	end
	return math.max(math.clamp(math.min(viewport.X / 1050, viewport.Y / 620), 0.52, 1.18), 0.8)
end

local function keyText(prompt: ProximityPrompt, inputType: Enum.ProximityPromptInputType): string
	if inputType == Enum.ProximityPromptInputType.Gamepad then
		local name = prompt.GamepadKeyCode.Name
		return GAMEPAD_KEYS[name] or name
	end
	local code = prompt.KeyboardKeyCode
	local ok, text = pcall(function()
		return UserInputService:GetStringForKeyCode(code)
	end)
	if not ok or type(text) ~= "string" or text == "" then
		text = code.Name
	end
	return string.upper(text)
end

local function build(prompt: ProximityPrompt, inputType: Enum.ProximityPromptInputType): () -> ()
	local touch = inputType == Enum.ProximityPromptInputType.Touch
	local theme = THEMES[prompt:GetAttribute("CheckUITheme")] or THEMES.Lime
	local iconId = prompt:GetAttribute("CheckUIIcon")
	local hasIcon = type(iconId) == "string" and iconId ~= ""
	local offset = prompt:GetAttribute("CheckUIOffset")
	local scale = promptScale()
	local connections: { RBXScriptConnection } = {}

	local billboard = new("BillboardGui", {
		Name = "Prompt_" .. prompt.Name,
		Adornee = prompt.Parent,
		AlwaysOnTop = true,
		LightInfluence = 0,
		ResetOnSpawn = false,
		Active = true,
		ClipsDescendants = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		StudsOffsetWorldSpace = typeof(offset) == "Vector3" and offset or Vector3.zero,
	})
	local root = new("Frame", { Name = "Root", BackgroundTransparency = 1, AnchorPoint = CENTER, Position = UDim2.fromScale(0.5, 0.5) }, billboard)
	local rootScale = new("UIScale", { Scale = 0 }, root)

	local objectLabel = new("TextLabel", {
		Name = "ObjectText", BackgroundTransparency = 1, Font = Enum.Font.GothamBlack, TextSize = 17, TextColor3 = WHITE,
		Size = UDim2.new(1, 0, 0, 22), TextXAlignment = Enum.TextXAlignment.Center,
	}, root)
	outline(objectLabel, 2.4, BLACK)

	-- key cap: dark slate key with a 4px bevel that closes when the key is pressed
	local keyCap, keyFace
	if not touch then
		keyCap = new("Frame", { Name = "KeyCap", Size = UDim2.fromOffset(KEY_SIZE, KEY_SIZE), AnchorPoint = CENTER,
			BackgroundColor3 = C3(16, 26, 32), BorderSizePixel = 0 }, root)
		outline(keyCap, 2.8, BLACK, true)
		keyFace = new("Frame", { Name = "Face", Size = UDim2.new(1, 0, 1, -4), BackgroundColor3 = WHITE, BorderSizePixel = 0 }, keyCap)
		new("UIGradient", { Rotation = 90, Color = ColorSequence.new(C3(78, 116, 134), C3(40, 64, 77)) }, keyFace)
		local keyInner = new("Frame", { Size = UDim2.new(1, -2, 1, -2), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = CENTER, BackgroundTransparency = 1 }, keyFace)
		new("UIStroke", { Thickness = 1.2, Color = C3(150, 200, 220), Transparency = 0.35, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, LineJoinMode = Enum.LineJoinMode.Miter }, keyInner)
		local keyLabel = new("TextLabel", {
			Name = "Key", BackgroundTransparency = 1, Font = Enum.Font.GothamBlack, TextSize = 24, TextColor3 = WHITE,
			Text = keyText(prompt, inputType), Size = UDim2.fromScale(1, 1), ZIndex = 2,
		}, keyFace)
		outline(keyLabel, 2.8, BLACK)
	end

	-- the action button (recipe 3.4 + icon)
	local button = new("ImageButton", {
		Name = "Button", AnchorPoint = CENTER, BackgroundColor3 = WHITE, BorderSizePixel = 0, AutoButtonColor = false,
		Image = "", ClipsDescendants = true, Active = true,
	}, root)
	outline(button, 3, C3(12, 20, 26), true)
	new("UIGradient", { Name = "ButtonGradient", Rotation = 90, Color = theme }, button)
	local checker = new("ImageLabel", {
		Name = "Checkerboard", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Image = DAMIER_ID,
		ScaleType = Enum.ScaleType.Tile, TileSize = UDim2.fromOffset(19, 19), ImageColor3 = BLACK, ZIndex = 1,
	}, button)
	new("UIGradient", { Rotation = 90, Transparency = NumberSequence.new(0.91, 0.62) }, checker)
	local fill = new("Frame", { Name = "HoldFill", Size = UDim2.fromScale(0, 1), BackgroundColor3 = WHITE, BackgroundTransparency = 0.55, BorderSizePixel = 0, ZIndex = 2 }, button)
	for index, glass in { { 2, 0.25 }, { 4, 0.45 }, { 6, 0.8 } } do
		local frame = new("Frame", { Name = "InnerHighlight" .. index, BackgroundTransparency = 1, Size = UDim2.new(1, -glass[1], 1, -glass[1]),
			Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = CENTER, ZIndex = 3 }, button)
		new("UIStroke", { Thickness = 1, Color = WHITE, Transparency = glass[2], ApplyStrokeMode = Enum.ApplyStrokeMode.Border, LineJoinMode = Enum.LineJoinMode.Miter }, frame)
	end
	local content = new("Frame", { Name = "Content", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ZIndex = 4 }, button)
	new("UIPadding", { PaddingBottom = UDim.new(0, 2) }, content) -- 1px optical lift
	new("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Center,
		VerticalAlignment = Enum.VerticalAlignment.Center, Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder,
	}, content)
	new("ImageLabel", { Name = "Icon", BackgroundTransparency = 1, Image = hasIcon and iconId or "", ScaleType = Enum.ScaleType.Fit,
		Size = UDim2.fromOffset(ICON_SIZE, ICON_SIZE), LayoutOrder = 1, Visible = hasIcon, ZIndex = 4 }, content)
	local actionLabel = new("TextLabel", { Name = "Action", BackgroundTransparency = 1, Font = Enum.Font.GothamBlack, TextSize = TEXT_SIZE,
		TextColor3 = WHITE, LayoutOrder = 2, ZIndex = 4 }, content)
	outline(actionLabel, 3, C3(17, 23, 26))
	local buttonScale = new("UIScale", { Name = "ButtonScale" }, button)

	local function layout()
		local action = prompt.ActionText ~= "" and prompt.ActionText or "Interact"
		local textWidth = TextService:GetTextSize(action, TEXT_SIZE, Enum.Font.GothamBlack, Vector2.new(1000, 100)).X + 4
		local buttonWidth = math.max(132, 36 + (hasIcon and ICON_SIZE + 6 or 0) + textWidth)
		local keyWidth = keyCap and (KEY_SIZE + GAP) or 0
		local hasObject = prompt.ObjectText ~= ""
		local top = hasObject and 26 or 0
		local width = keyWidth + buttonWidth
		local height = top + BUTTON_HEIGHT

		objectLabel.Visible = hasObject
		objectLabel.Text = prompt.ObjectText
		actionLabel.Text = action
		actionLabel.Size = UDim2.fromOffset(textWidth, BUTTON_HEIGHT)
		if keyCap then
			keyCap.Position = UDim2.fromOffset(KEY_SIZE / 2, top + BUTTON_HEIGHT / 2)
		end
		button.Size = UDim2.fromOffset(buttonWidth, BUTTON_HEIGHT)
		button.Position = UDim2.fromOffset(keyWidth + buttonWidth / 2, top + BUTTON_HEIGHT / 2)
		root.Size = UDim2.fromOffset(width, height)
		-- room around the root for strokes and the press/pop animations
		billboard.Size = UDim2.fromOffset(math.ceil((width + 24) * scale), math.ceil((height + 24) * scale))
	end
	layout()
	table.insert(connections, prompt:GetPropertyChangedSignal("ActionText"):Connect(layout))
	table.insert(connections, prompt:GetPropertyChangedSignal("ObjectText"):Connect(layout))

	local function pressKey(down: boolean)
		if keyFace then
			keyFace.Position = UDim2.fromOffset(0, down and 3 or 0)
		end
	end

	-- hold progress
	local holdTween: Tween? = nil
	table.insert(connections, prompt.PromptButtonHoldBegan:Connect(function()
		pressKey(true)
		TweenService:Create(buttonScale, PRESS_INFO, { Scale = 0.95 }):Play()
		fill.Size = UDim2.fromScale(0, 1)
		local tween = TweenService:Create(fill, TweenInfo.new(prompt.HoldDuration, Enum.EasingStyle.Linear), { Size = UDim2.fromScale(1, 1) })
		holdTween = tween
		tween:Play()
	end))
	table.insert(connections, prompt.PromptButtonHoldEnded:Connect(function()
		pressKey(false)
		if holdTween then
			holdTween:Cancel()
			holdTween = nil
		end
		TweenService:Create(fill, TweenInfo.new(0.12), { Size = UDim2.fromScale(0, 1) }):Play()
		TweenService:Create(buttonScale, RELEASE_INFO, { Scale = 1 }):Play()
	end))
	table.insert(connections, prompt.Triggered:Connect(function()
		buttonScale.Scale = 1.12
		TweenService:Create(buttonScale, POP_INFO, { Scale = 1 }):Play()
		fill.Size = UDim2.fromScale(1, 1)
		TweenService:Create(fill, TweenInfo.new(0.2), { Size = UDim2.fromScale(0, 1) }):Play()
	end))

	-- the key cap dips while its key is held (also for instant prompts)
	if keyCap then
		local code = inputType == Enum.ProximityPromptInputType.Gamepad and prompt.GamepadKeyCode or prompt.KeyboardKeyCode
		table.insert(connections, UserInputService.InputBegan:Connect(function(input, processed)
			if not processed and input.KeyCode == code then
				pressKey(true)
			end
		end))
		table.insert(connections, UserInputService.InputEnded:Connect(function(input)
			if input.KeyCode == code then
				pressKey(false)
			end
		end))
	end

	-- mouse click / tap on the button
	local holding = false
	local function release()
		if holding then
			holding = false
			prompt:InputHoldEnd()
		end
	end
	table.insert(connections, button.InputBegan:Connect(function(input)
		local kind = input.UserInputType
		if (kind == Enum.UserInputType.MouseButton1 or kind == Enum.UserInputType.Touch) and input.UserInputState == Enum.UserInputState.Begin then
			holding = true
			prompt:InputHoldBegin()
		end
	end))
	table.insert(connections, UserInputService.InputEnded:Connect(function(input)
		local kind = input.UserInputType
		if kind == Enum.UserInputType.MouseButton1 or kind == Enum.UserInputType.Touch then
			release()
		end
	end))

	billboard.Parent = holder
	TweenService:Create(rootScale, SHOW_INFO, { Scale = scale }):Play()

	return function()
		for _, connection in connections do
			connection:Disconnect()
		end
		release()
		local hide = TweenService:Create(rootScale, HIDE_INFO, { Scale = 0 })
		hide.Completed:Connect(function()
			billboard:Destroy()
		end)
		hide:Play()
	end
end

ProximityPromptService.PromptShown:Connect(function(prompt, inputType)
	if prompt.Style ~= Enum.ProximityPromptStyle.Custom then
		return
	end
	local cleanup = build(prompt, inputType)
	prompt.PromptHidden:Wait()
	cleanup()
end)
