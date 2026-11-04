local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local Remotes = ReplicatedStorage:WaitForChild("DialogueRemotes")
local StartDialogue = Remotes:WaitForChild("StartDialogue")
local EndDialogue = Remotes:WaitForChild("EndDialogue")

local QuestRemotes = ReplicatedStorage:WaitForChild("QuestRemotes")
local QuestAction = QuestRemotes:WaitForChild("QuestAction")

local gui = player:WaitForChild("PlayerGui"):WaitForChild("DialogueGui")
local topBar = gui:WaitForChild("LetterboxTop")
local bottomBar = gui:WaitForChild("LetterboxBottom")

local box = gui:WaitForChild("DialogueBox")
local speakerName = box:WaitForChild("SpeakerName")
local dialogueText = box:WaitForChild("DialogueText")
local continueHint = box:WaitForChild("ContinueHint")

local choicesFrame = gui:WaitForChild("Choices")
local choiceTemplate = choicesFrame:WaitForChild("ChoiceTemplate")

speakerName.RichText = true
dialogueText.RichText = true

local blur = Lighting:FindFirstChild("DialogueBlur")
if not blur then
	blur = Instance.new("BlurEffect")
	blur.Name = "DialogueBlur"
	blur.Size = 0
	blur.Parent = Lighting
end

local typeSound = gui:FindFirstChild("TypeSFX")
if not typeSound then
	typeSound = Instance.new("Sound")
	typeSound.Name = "TypeSFX"
	typeSound.Volume = 0.35
	typeSound.RollOffMode = Enum.RollOffMode.InverseTapered
	typeSound.Parent = gui
end

local playing = false
local typing = false
local skipTypewriter = false
local waitingForChoice = false
local advanceRequested = false

local breatheConn = nil
local activeCameraPart = nil

local restore = {
	cameraType = nil,
	cameraCFrame = nil,
	cameraFOV = nil,
	walkSpeed = nil,
	jumpPower = nil,
	autoRotate = nil,
	controls = nil,
}

local function setQuestGuiVisible(visible)
	local pgui = player:FindFirstChildOfClass("PlayerGui")
	if not pgui then
		return
	end
	local qGui = pgui:FindFirstChild("QuestGui")
	if qGui and qGui:IsA("ScreenGui") then
		qGui.Enabled = visible
	end
end

local function tween(inst, info, props)
	local t = TweenService:Create(inst, info, props)
	t:Play()
	return t
end

local function toText(v)
	if typeof(v) == "string" then
		return v
	end
	if v == nil then
		return ""
	end
	return tostring(v)
end

local function utf8len(s)
	s = toText(s)
	local ok, n = pcall(utf8.len, s)
	if ok and n then
		return n
	end
	return string.len(s)
end

local function utf8sub(s, i, j)
	s = toText(s)
	i = i or 1
	j = j or -1
	local startByte = utf8.offset(s, i)
	if not startByte then
		return ""
	end
	local endByte
	if j == -1 then
		endByte = #s
	else
		local nextByte = utf8.offset(s, j + 1)
		endByte = nextByte and (nextByte - 1) or #s
	end
	return string.sub(s, startByte, endByte)
end

local function rgbTag(color3)
	return string.format("rgb(%d,%d,%d)", math.floor(color3.R * 255 + 0.5), math.floor(color3.G * 255 + 0.5), math.floor(color3.B * 255 + 0.5))
end

local function getStyle(settings, speaker)
	local styles = (settings and settings.SpeakerStyles) or {}
	local style = styles[speaker] or styles["*"] or {}
	return style.NameColor or Color3.fromRGB(255, 255, 255), style.TextColor or Color3.fromRGB(235, 235, 235)
end

local function setLetterbox(on, size, t)
	size = size or 0.12
	t = t or 0.25
	local ti = TweenInfo.new(t, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
	if on then
		tween(topBar, ti, { Size = UDim2.fromScale(1, size) })
		tween(bottomBar, ti, { Size = UDim2.fromScale(1, size), Position = UDim2.fromScale(0, 1 - size) })
	else
		tween(topBar, ti, { Size = UDim2.fromScale(1, 0) })
		tween(bottomBar, ti, { Size = UDim2.fromScale(1, 0), Position = UDim2.fromScale(0, 1) })
	end
end

local function setBlur(size, t)
	local ti = TweenInfo.new(t or 0.25, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
	tween(blur, ti, { Size = size })
end

local function resetUI()
	speakerName.Text = ""
	dialogueText.Text = ""
	if continueHint then
		continueHint.Visible = false
	end
end

local function clearChoices()
	for _, child in ipairs(choicesFrame:GetChildren()) do
		if child ~= choiceTemplate and child:IsA("GuiObject") then
			child:Destroy()
		end
	end
end

local function disableControls(on)
	local ps = player:FindFirstChild("PlayerScripts")
	if not ps then
		return
	end
	local pm = ps:FindFirstChild("PlayerModule")
	if not pm then
		return
	end
	local ok, mod = pcall(require, pm)
	if not ok or not mod then
		return
	end
	if not restore.controls then
		local ok2, controls = pcall(function()
			return mod:GetControls()
		end)
		if ok2 then
			restore.controls = controls
		end
	end
	if not restore.controls then
		return
	end
	if on then
		pcall(function()
			restore.controls:Disable()
		end)
	else
		pcall(function()
			restore.controls:Enable()
		end)
	end
end

local function lockHumanoid(on)
	local char = player.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if not hum then
		return
	end
	if on then
		restore.walkSpeed = hum.WalkSpeed
		restore.jumpPower = hum.JumpPower
		restore.autoRotate = hum.AutoRotate
		hum.WalkSpeed = 0
		hum.JumpPower = 0
		hum.AutoRotate = false
	else
		if restore.walkSpeed then
			hum.WalkSpeed = restore.walkSpeed
		end
		if restore.jumpPower then
			hum.JumpPower = restore.jumpPower
		end
		if restore.autoRotate ~= nil then
			hum.AutoRotate = restore.autoRotate
		end
	end
end

local function offsetUdim2(u, dx, dy)
	return UDim2.new(u.X.Scale, u.X.Offset + (dx or 0), u.Y.Scale, u.Y.Offset + (dy or 0))
end

local lastBlip = 0
local blipCount = 0

local function playTypeSfx(char, settings)
	local s = settings and settings.TypeSFX
	if not s or not s.SoundId or s.SoundId == "" or s.SoundId == "rbxassetid://0" then
		return
	end
	if skipTypewriter then
		return
	end
	if not char or char:match("%s") then
		return
	end
	blipCount += 1
	local every = s.Every or 2
	if every > 1 and (blipCount % every ~= 0) then
		return
	end
	local now = os.clock()
	local minInterval = s.MinInterval or 0.02
	if now - lastBlip < minInterval then
		return
	end
	lastBlip = now
	typeSound.SoundId = s.SoundId
	typeSound.Volume = s.Volume or 0.35
	local pMin = s.PitchMin or 0.95
	local pMax = s.PitchMax or 1.05
	if pMax < pMin then
		pMax = pMin
	end
	typeSound.PlaybackSpeed = pMin + (math.random() * (pMax - pMin))
	if typeSound.IsPlaying then
		typeSound:Stop()
	end
	typeSound.TimePosition = 0
	typeSound:Play()
end

local function typewriter(text, speed, textColor, settings)
	if type(text) == "function" then
		text = text()
	end
	text = toText(text)
	typing = true
	skipTypewriter = false
	blipCount = 0
	lastBlip = 0
	if continueHint then
		continueHint.Visible = false
	end
	local prefix = string.format('<font color="%s">', rgbTag(textColor))
	local suffix = "</font>"
	for i = 1, utf8len(text) do
		if skipTypewriter then
			break
		end
		dialogueText.Text = prefix .. utf8sub(text, 1, i) .. suffix
		playTypeSfx(utf8sub(text, i, i), settings)
		task.wait(speed)
	end
	dialogueText.Text = prefix .. text .. suffix
	typing = false
	if continueHint then
		continueHint.Visible = true
	end
end

local function stopBreathing()
	activeCameraPart = nil
	if breatheConn then
		breatheConn:Disconnect()
		breatheConn = nil
	end
end

local function startBreathing(camPart, settings)
	stopBreathing()
	activeCameraPart = camPart
	if not camPart or not camPart:IsA("BasePart") then
		return
	end
	local b = (settings and settings.Breathing) or {}
	local speed = b.Speed or 0.9
	local posAmp = b.PosAmp or Vector3.new(0.03, 0.06, 0.03)
	local rotAmp = b.RotAmp or Vector3.new(0.25, 0.35, 0.12)
	local t0 = os.clock()
	breatheConn = RunService.RenderStepped:Connect(function()
		if not playing then
			return
		end
		if not activeCameraPart or not activeCameraPart.Parent then
			return
		end
		local t = os.clock() - t0
		local a = math.sin(t * (speed * 2.0))
		local c = math.sin(t * (speed * 1.3) + 1.1)
		local pos = Vector3.new(posAmp.X * c, posAmp.Y * a, posAmp.Z * c)
		local rot = Vector3.new(rotAmp.X * a, rotAmp.Y * c, rotAmp.Z * c)
		local base = activeCameraPart.CFrame
		camera.CFrame = base * CFrame.new(pos) * CFrame.Angles(math.rad(rot.X), math.rad(rot.Y), math.rad(rot.Z))
	end)
end

local function getChoiceLabels(btn)
	local order = btn:FindFirstChild("Order", true)
	if not (order and order:IsA("TextLabel")) then
		order = nil
	end
	local tl = btn:FindFirstChild("TextLabel", true)
	if not (tl and tl:IsA("TextLabel")) then
		tl = nil
	end
	if not tl then
		for _, d in ipairs(btn:GetDescendants()) do
			if d:IsA("TextLabel") and d ~= order and d.Name ~= "Order" then
				tl = d
				break
			end
		end
	end
	return order, tl
end

local function bindAdvance()
	ContextActionService:UnbindAction("DialogueAdvance")
	ContextActionService:BindActionAtPriority(
		"DialogueAdvance",
		function(_, state, _)
			if state ~= Enum.UserInputState.Begin then
				return Enum.ContextActionResult.Sink
			end
			if not playing then
				return Enum.ContextActionResult.Pass
			end
			if UserInputService:GetFocusedTextBox() then
				return Enum.ContextActionResult.Pass
			end
			if waitingForChoice then
				return Enum.ContextActionResult.Pass
			end
			if typing then
				skipTypewriter = true
			else
				advanceRequested = true
			end
			return Enum.ContextActionResult.Sink
		end,
		false,
		3000,
		Enum.KeyCode.Space,
		Enum.KeyCode.Return,
		Enum.KeyCode.KeypadEnter,
		Enum.UserInputType.MouseButton1
	)
end

local function unbindAdvance()
	pcall(function()
		ContextActionService:UnbindAction("DialogueAdvance")
	end)
end

local function beginCinematic(settings, payload)
	playing = true
	typing = false
	skipTypewriter = true
	waitingForChoice = false
	advanceRequested = false

	restore.cameraType = camera.CameraType
	restore.cameraCFrame = camera.CFrame
	restore.cameraFOV = camera.FieldOfView
	camera.CameraType = Enum.CameraType.Scriptable

	resetUI()
	clearChoices()

	setQuestGuiVisible(false)

	box.Visible = true
	choicesFrame.Visible = true

	setLetterbox(true, settings.LetterboxSize or 0.12, settings.FadeTime or 0.2)
	setBlur(settings.BlurSize or 10, settings.FadeTime or 0.2)

	disableControls(true)
	lockHumanoid(true)
	bindAdvance()

	local camPart = payload and payload.Camera
	local fov = settings.DefaultFOV or 45
	local ct = (settings.CameraTween and settings.CameraTween.Time) or 0.85

	if camPart and camPart:IsA("BasePart") then
		tween(camera, TweenInfo.new(ct, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut), {
			CFrame = camPart.CFrame,
			FieldOfView = fov,
		}).Completed:Wait()
		startBreathing(camPart, settings)
	else
		camera.FieldOfView = fov
	end
end

local function endCinematic(settings)
	skipTypewriter = true
	typing = false
	waitingForChoice = false
	advanceRequested = false

	pcall(function()
		EndDialogue:FireServer()
	end)

	unbindAdvance()
	stopBreathing()

	setBlur(0, settings.FadeTime or 0.2)
	setLetterbox(false, settings.LetterboxSize or 0.12, settings.FadeTime or 0.2)

	camera.CameraType = restore.cameraType or Enum.CameraType.Custom
	if restore.cameraCFrame then
		camera.CFrame = restore.cameraCFrame
	end
	if restore.cameraFOV then
		camera.FieldOfView = restore.cameraFOV
	end

	lockHumanoid(false)
	disableControls(false)

	resetUI()
	clearChoices()

	box.Visible = false
	choicesFrame.Visible = false

	setQuestGuiVisible(true)

	playing = false
end

local function getQuestOk(okCall, a, b)
	if not okCall then
		return false
	end
	if type(a) == "boolean" then
		return a
	end
	if type(b) == "boolean" then
		return b
	end
	if type(a) == "table" then
		if a.Ok ~= nil then
			return a.Ok == true
		end
		if a.ok ~= nil then
			return a.ok == true
		end
		if a.Success ~= nil then
			return a.Success == true
		end
		if a.success ~= nil then
			return a.success == true
		end
	end
	return false
end

local function playDialogue(dialogueId, payload)
	if playing then
		return
	end

	local dialogueModule = ReplicatedStorage:WaitForChild("Dialogues"):FindFirstChild(dialogueId)
	if not dialogueModule then
		dialogueModule = ReplicatedStorage.Dialogues:FindFirstChild("Intro")
		if not dialogueModule then
			return
		end
	end

	local data = require(dialogueModule)
	local settings = data.Settings or {}

	local labels = {}
	for i, line in ipairs(data.Lines or {}) do
		if line.Label then
			labels[line.Label] = i
		end
	end

	beginCinematic(settings, payload)

	local index = 1
	if payload and payload.StartLabel and labels[payload.StartLabel] then
		index = labels[payload.StartLabel]
	end

	local forceEnd = false

	while playing and not forceEnd and data.Lines and data.Lines[index] do
		local line = data.Lines[index]

		local speaker = toText(line.Speaker)
		local nameColor, textColor = getStyle(settings, speaker)
		speakerName.Text = string.format('<font color="%s"><b>%s</b></font>', rgbTag(nameColor), speaker)

		typewriter(line.Text, settings.TypeSpeed or 0.03, textColor, settings)

		if line.Choices then
			waitingForChoice = true
			clearChoices()

			local slide = settings.ChoiceSlide or {}
			local slideOffsetX = slide.OffsetX or 90
			local slideStagger = slide.Stagger or 0.06
			local slideTime = slide.Time or 0.18

			local hov = settings.ChoiceHover or {}
			local hovStrokeColor = hov.StrokeColor or Color3.fromRGB(255, 255, 255)
			local hovStrokeTrans = hov.StrokeTransparency or 0.25
			local hovStrokeThick = hov.StrokeThickness or 2
			local hovBgTrans = hov.HoverBgTransparency or 0.12
			local hovX = hov.HoverXOffset or -8
			local hovTime = hov.HoverTime or 0.10

			local h = choiceTemplate.Size.Y.Offset
			local pad = 6
			local count = #line.Choices

			local targetPosByBtn = {}
			local currentHover = nil

			local function setHover(btn, on)
				local targetPos = targetPosByBtn[btn]
				if not targetPos then
					return
				end
				if on then
					if currentHover and currentHover ~= btn then
						setHover(currentHover, false)
					end
					currentHover = btn
				elseif currentHover == btn then
					currentHover = nil
				end
				local stroke = btn:FindFirstChildOfClass("UIStroke") or Instance.new("UIStroke")
				stroke.Parent = btn
				stroke.Color = hovStrokeColor
				stroke.Thickness = hovStrokeThick
				local ti = TweenInfo.new(hovTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
				if on then
					tween(btn, ti, {
						Position = offsetUdim2(targetPos, hovX, 0),
						BackgroundTransparency = hovBgTrans,
					})
					tween(stroke, ti, {
						Transparency = hovStrokeTrans,
					})
				else
					tween(btn, ti, {
						Position = targetPos,
						BackgroundTransparency = 0.25,
					})
					tween(stroke, ti, {
						Transparency = 1,
					})
				end
			end

			local chosenNext
			local chosenEnd = false
			local processing = false

			local function quoteFormat(s)
				s = toText(s):gsub("\n", " ")
				return '[" ' .. s .. ' "]'
			end

			for i, ch in ipairs(line.Choices) do
				local btn = choiceTemplate:Clone()
				btn.Visible = true
				btn.Parent = choicesFrame

				local order, tl = getChoiceLabels(btn)
				if order then
					order.Text = tostring(i) .. "."
				end
				if tl then
					tl.Text = quoteFormat(ch.Text or "...")
				end

				btn.AnchorPoint = Vector2.new(1, 1)
				btn.Size = choiceTemplate.Size

				local targetY = -((count - i) * (h + pad))
				local targetPos = UDim2.new(1, 0, 1, targetY)
				targetPosByBtn[btn] = targetPos

				btn.Position = offsetUdim2(targetPos, slideOffsetX, 0)
				btn.BackgroundTransparency = 1
				if tl then
					tl.TextTransparency = 1
				end
				if order then
					order.TextTransparency = 1
				end

				local stroke = btn:FindFirstChildOfClass("UIStroke") or Instance.new("UIStroke")
				stroke.Parent = btn
				stroke.Color = hovStrokeColor
				stroke.Thickness = hovStrokeThick
				stroke.Transparency = 1

				tween(btn, TweenInfo.new(slideTime, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
					Position = targetPos,
					BackgroundTransparency = 0.25,
				})
				if tl then
					tween(tl, TweenInfo.new(slideTime, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
						TextTransparency = 0,
					})
				end
				if order then
					tween(order, TweenInfo.new(slideTime, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
						TextTransparency = 0.15,
					})
				end

				btn.MouseEnter:Connect(function()
					if waitingForChoice and not processing then
						setHover(btn, true)
					end
				end)
				btn.MouseLeave:Connect(function()
					setHover(btn, false)
				end)
				btn.SelectionGained:Connect(function()
					if waitingForChoice and not processing then
						setHover(btn, true)
					end
				end)
				btn.SelectionLost:Connect(function()
					setHover(btn, false)
				end)

				btn.Activated:Connect(function()
					if not waitingForChoice or processing then
						return
					end
					processing = true

					chosenEnd = (ch.End == true)
					chosenNext = ch.Next

					if ch.StartQuest then
						local okCall, a, b = pcall(function()
							return QuestAction:InvokeServer("Start", ch.StartQuest)
						end)
						local ok = getQuestOk(okCall, a, b)
						if ok and ch.SuccessNext then
							chosenNext = ch.SuccessNext
						end
						if (not ok) and ch.FailNext then
							chosenNext = ch.FailNext
						end
					end

					if ch.TurnInQuest then
						local okCall, a, b = pcall(function()
							return QuestAction:InvokeServer("TurnIn", ch.TurnInQuest)
						end)
						local ok = getQuestOk(okCall, a, b)
						if ok and ch.SuccessNext then
							chosenNext = ch.SuccessNext
						end
						if (not ok) and ch.FailNext then
							chosenNext = ch.FailNext
						end
					end

					clearChoices()
					waitingForChoice = false
					processing = false
				end)

				task.wait(slideStagger)
			end

			while playing and waitingForChoice do
				task.wait()
			end
			if not playing then
				break
			end

			if chosenEnd then
				forceEnd = true
				break
			end

			if type(chosenNext) == "number" then
				index = chosenNext
			elseif type(chosenNext) == "string" then
				index = labels[chosenNext] or (index + 1)
			else
				index = index + 1
			end

			continue
		end

		advanceRequested = false
		while playing and not advanceRequested do
			task.wait()
		end

		if line.End then
			break
		end

		if line.Next then
			if type(line.Next) == "number" then
				index = line.Next
			elseif type(line.Next) == "string" then
				index = labels[line.Next] or (index + 1)
			else
				index += 1
			end
		else
			index += 1
		end
	end

	endCinematic(settings)
end

StartDialogue.OnClientEvent:Connect(function(dialogueId, payload)
	playDialogue(dialogueId, payload or {})
end)
