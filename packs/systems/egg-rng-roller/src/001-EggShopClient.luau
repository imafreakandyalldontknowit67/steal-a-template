--[[
	EggShopClient

	Drives the Check-UI shop interface: money counter, inventory, admin panel, toasts and the
	"Buy" prompts on the machine's pedestals for this player.

	The layout lives in this ScreenGui (edit it visually in StarterGui.EggShopGui). This script only
	DISPLAYS what the server says (Player.leaderstats, Player.EggInventory and the machine's
	attributes) and ASKS the server to do things (Remotes.BuyEgg / AdminAction). The server checks
	every request (EggShopServer), so nothing here can cheat.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local TextService = game:GetService("TextService")

local player = Players.LocalPlayer
local gui = script.Parent

local Shared = ReplicatedStorage:WaitForChild("EggRandomizer")
local Config = require(Shared:WaitForChild("Config"))
local Remotes = Shared:WaitForChild("Remotes")
local DisplayTemplates = Shared:WaitForChild("DisplayTemplates")

local ECONOMY = Config.Economy
local EGG_INFO, EGG_ORDER = {}, {}
for index, entry in Config.Eggs do
	EGG_INFO[entry.TemplateName] = entry
	EGG_ORDER[entry.TemplateName] = index
end

---------------------------------------------------------------------------
-- Style constants (Check-UI palette)
---------------------------------------------------------------------------
local C3 = Color3.fromRGB
local ICONS = {
	Check = "rbxassetid://75340450258025",
	Alert = "rbxassetid://113143163773771",
	Info = "rbxassetid://110199384922279",
	Cash = "rbxassetid://88694661500877", -- cash stack (same as the money counter)
}
local GOOD = C3(150, 255, 60)
local BAD = C3(255, 90, 90)
local MUTED = C3(225, 235, 245)
local FIELD_IDLE = C3(85, 140, 160)
local FIELD_FOCUS = C3(155, 225, 255)

local TOAST_STYLES = {
	success = { color = C3(150, 255, 40), icon = ICONS.Check },
	error = { color = C3(255, 50, 90), icon = ICONS.Alert },
	warn = { color = C3(255, 190, 0), icon = ICONS.Alert },
	info = { color = C3(0, 200, 255), icon = ICONS.Info },
}

-- inventory card colours per rarity; rarities not listed here use the egg's AccentColor
local RARITY_STYLES = {
	Common = { rank = 1, banner = ColorSequence.new(C3(216, 222, 228), C3(148, 160, 176)), accent = C3(235, 240, 245) },
	Uncommon = { rank = 2, banner = ColorSequence.new(C3(180, 255, 25), C3(105, 225, 0)), accent = C3(160, 255, 60) },
	Rare = { rank = 3, banner = ColorSequence.new(C3(0, 210, 255), C3(0, 120, 255)), accent = C3(40, 200, 255) },
	Epic = { rank = 4, banner = ColorSequence.new(C3(176, 32, 255), C3(112, 0, 224)), accent = C3(200, 110, 255) },
	Legendary = {
		rank = 5,
		rotation = 45,
		accent = C3(255, 215, 70),
		banner = ColorSequence.new({
			ColorSequenceKeypoint.new(0.00, C3(255, 30, 80)),
			ColorSequenceKeypoint.new(0.18, C3(255, 140, 0)),
			ColorSequenceKeypoint.new(0.35, C3(255, 230, 0)),
			ColorSequenceKeypoint.new(0.52, C3(40, 230, 50)),
			ColorSequenceKeypoint.new(0.70, C3(0, 210, 255)),
			ColorSequenceKeypoint.new(0.85, C3(90, 60, 255)),
			ColorSequenceKeypoint.new(1.00, C3(220, 0, 230)),
		}),
	},
	Mythic = { rank = 6, banner = ColorSequence.new(C3(208, 0, 224), C3(128, 0, 160)), accent = C3(255, 90, 230) },
}

---------------------------------------------------------------------------
-- UI references
---------------------------------------------------------------------------
local hud = gui:WaitForChild("HUD")
local dock = hud:WaitForChild("Dock") -- menu buttons, middle of the left edge
local moneyDock = hud:WaitForChild("MoneyDock") -- cash icon + amount, bottom-left corner
local moneyLabel = moneyDock:WaitForChild("Amount")
local moneyIcon = moneyDock:WaitForChild("IconSlot"):WaitForChild("Icon")
local floaters = moneyDock.IconSlot:WaitForChild("Floaters") -- next to the amount, outside the row layout
local plusButton = moneyDock:WaitForChild("PlusSlot"):WaitForChild("PlusButton")
local inventoryButton = dock:WaitForChild("InventorySlot"):WaitForChild("InventoryButton")
local adminButton = dock:WaitForChild("AdminSlot"):WaitForChild("AdminButton")
local inventoryWindow = gui:WaitForChild("InventoryWindow")
local adminWindow = gui:WaitForChild("AdminWindow")
local cashWindow = gui:WaitForChild("CashShopWindow")
local toasts = gui:WaitForChild("Toasts")
local templates = gui:WaitForChild("Templates")
local UIFx = require(Shared:WaitForChild("UIFx")) -- menu sounds + animations

-- stud texture over the plain window backgrounds (built in-game, see StudTexture)
local StudTexture = require(Shared:WaitForChild("StudTexture"))
for _, window in { inventoryWindow, adminWindow, cashWindow } do
	local studs = window:FindFirstChild("Studs")
	if studs and studs:IsA("ImageLabel") then
		StudTexture.apply(studs)
	end
end

local function withCommas(digits: string): string
	return (digits:reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", ""))
end

local function formatMoney(amount: number): string
	local digits = tostring(math.floor(math.abs(amount)))
	return (amount < 0 and "-" or "") .. ECONOMY.CurrencySymbol .. withCommas(digits)
end

---------------------------------------------------------------------------
-- Responsive scaling (design baseline 1050x620, clamped 0.52 - 1.18)
---------------------------------------------------------------------------
local deviceScale = 1
local function getDeviceScale(): number
	local camera = workspace.CurrentCamera
	local viewport = camera and camera.ViewportSize or Vector2.new(1050, 620)
	if viewport.X <= 0 or viewport.Y <= 0 then
		return 1
	end
	return math.clamp(math.min(viewport.X / 1050, viewport.Y / 620), 0.52, 1.18)
end
deviceScale = getDeviceScale()

---------------------------------------------------------------------------
-- Buttons: hover grow + icon tilt, press squash, springy release, click sound (see UIFx)
---------------------------------------------------------------------------
local HOVER = TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local RELEASE = TweenInfo.new(0.12, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

local function bindButton(button: GuiButton, scaleOverride: UIScale?)
	-- scaleOverride: scale a centered child instead (cards in a grid can't be center-anchored)
	local face = button:FindFirstChild("Face")
	UIFx.bindButton(button, {
		scale = scaleOverride,
		-- the [X] does a quarter spin on hover; the + tilts itself
		spin = if button.Name == "Close" and face then face:FindFirstChild("X") else nil,
		icon = if button.Name == "PlusButton" then button else nil,
	})
end

for _, descendant in gui:GetDescendants() do
	if descendant:IsA("GuiButton") and not descendant:IsDescendantOf(templates) then
		bindButton(descendant)
	end
end

---------------------------------------------------------------------------
-- Modal windows: open 0.72x -> 1 with a 16px slide (Back Out), close to 0.70x (Back In)
---------------------------------------------------------------------------
local OPEN_INFO = TweenInfo.new(0.24, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local CLOSE_INFO = TweenInfo.new(0.14, Enum.EasingStyle.Back, Enum.EasingDirection.In)

local function makeModal(frame: Frame)
	local scale = frame:WaitForChild("WindowScale") :: UIScale
	local home = frame.Position
	local modal = { frame = frame, isOpen = false }
	local tweens: { Tween } = {}

	local function play(info: TweenInfo, scaleTo: number, positionTo: UDim2): Tween
		for _, tween in tweens do
			tween:Cancel()
		end
		tweens = {
			TweenService:Create(scale, info, { Scale = scaleTo }),
			TweenService:Create(frame, info, { Position = positionTo }),
		}
		for _, tween in tweens do
			tween:Play()
		end
		return tweens[1]
	end

	function modal.open()
		if modal.isOpen then
			return
		end
		modal.isOpen = true
		UIFx.play("Open")
		frame.Visible = true
		scale.Scale = deviceScale * 0.72
		frame.Position = home + UDim2.fromOffset(0, 16)
		play(OPEN_INFO, deviceScale, home)
	end

	function modal.close()
		if not modal.isOpen then
			return
		end
		modal.isOpen = false
		UIFx.play("Close")
		local tween = play(CLOSE_INFO, scale.Scale * 0.7, home + UDim2.fromOffset(0, 14))
		tween.Completed:Connect(function(state)
			if state == Enum.PlaybackState.Completed and not modal.isOpen then
				frame.Visible = false
				scale.Scale = deviceScale
				frame.Position = home
			end
		end)
	end

	function modal.rescale()
		local busy = tweens[1] ~= nil and tweens[1].PlaybackState == Enum.PlaybackState.Playing
		if not busy then
			scale.Scale = deviceScale
		end
	end

	frame.Visible = false
	scale.Scale = deviceScale
	return modal
end

local inventoryModal = makeModal(inventoryWindow)
local adminModal = makeModal(adminWindow)
local cashModal = makeModal(cashWindow)
local modals = { inventoryModal, adminModal, cashModal }

local function applyScale()
	deviceScale = getDeviceScale()
	dock.WindowScale.Scale = deviceScale
	moneyDock.WindowScale.Scale = deviceScale
	toasts.WindowScale.Scale = deviceScale
	for _, modal in modals do
		modal.rescale()
	end
end

local viewportConnection: RBXScriptConnection? = nil
local function watchCamera()
	if viewportConnection then
		viewportConnection:Disconnect()
		viewportConnection = nil
	end
	if workspace.CurrentCamera then
		viewportConnection = workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(applyScale)
	end
	applyScale()
end
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(watchCamera)
watchCamera()

---------------------------------------------------------------------------
-- Toasts
---------------------------------------------------------------------------
local POP_IN = TweenInfo.new(0.24, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local POP_OUT = TweenInfo.new(0.14, Enum.EasingStyle.Back, Enum.EasingDirection.In)
local toastCount = 0

local function dismissToast(item: Frame)
	if item.Parent == nil or item:GetAttribute("Closing") then
		return
	end
	item:SetAttribute("Closing", true)
	local pop = TweenService:Create(item.Card.PopScale, POP_OUT, { Scale = 0 })
	pop:Play()
	pop.Completed:Wait()
	local collapse = TweenService:Create(item, TweenInfo.new(0.1), { Size = UDim2.fromOffset(item.Size.X.Offset, 0) })
	collapse:Play()
	collapse.Completed:Wait()
	item:Destroy()
end

-- keep at most MAX_STACK messages on screen: the oldest goes first
local MAX_STACK = 6
local function trimStack()
	local shown = {}
	for _, child in toasts:GetChildren() do
		if child:IsA("Frame") and not child:GetAttribute("Closing") then
			table.insert(shown, child)
		end
	end
	table.sort(shown, function(a, b)
		return a.LayoutOrder < b.LayoutOrder
	end)
	for index = 1, #shown - MAX_STACK do
		task.spawn(dismissToast, shown[index])
	end
end

local CASH_ICON = "rbxassetid://88694661500877"
local STRIP_TEXT_SIZE = templates.PurchaseBanner.Card.Message.TextSize
local EGG_ICON = templates.PurchaseBanner.Card.Icon.Image

-- Every message (purchases, sales, info, errors) shows on a black strip that fades out at both
-- ends, stacked at the top of the screen.
local function showStrip(text: string, icon: string?, duration: number?)
	toastCount += 1
	local item = templates.PurchaseBanner:Clone()
	item.LayoutOrder = toastCount
	item.Visible = true
	local card = item.Card
	local message = card.Message
	message.Text = text
	card.Icon.Image = icon or EGG_ICON
	-- long messages get a slightly smaller font so the strip keeps a sensible width
	local size = STRIP_TEXT_SIZE
	local width = TextService:GetTextSize(text, size, Enum.Font.GothamBlack, Vector2.new(2000, 100)).X
	if width > 420 then
		size = math.max(18, math.floor(size * 420 / width))
		width = TextService:GetTextSize(text, size, Enum.Font.GothamBlack, Vector2.new(2000, 100)).X
	end
	message.TextSize = size
	width += 6
	-- icon starts 48px in and the text 94px in; the extra room after the text keeps both in
	-- the dark middle of the strip while its ends fade out
	message.Size = UDim2.new(0, width, 1, 0)
	card.Size = UDim2.fromOffset(94 + width + 60, card.Size.Y.Offset)
	card.PopScale.Scale = 0.6
	item.Parent = toasts
	trimStack()
	TweenService:Create(card.PopScale, POP_IN, { Scale = 1 }):Play()
	task.delay(duration or 1.8, dismissToast, item)
end

local function toast(message: string, kind: string?)
	if kind == "cash" then
		-- a Robux cash pack was paid out (CashShopServer)
		UIFx.play("Purchase")
		showStrip(message, CASH_ICON)
		return
	end
	if kind == "error" then
		UIFx.play("Error")
	end
	local style = TOAST_STYLES[kind or "info"] or TOAST_STYLES.info
	showStrip(message, style.icon, 2.6)
end
Remotes.Notify.OnClientEvent:Connect(toast)

---------------------------------------------------------------------------
-- Money counter
---------------------------------------------------------------------------
local shownMoney = Instance.new("NumberValue")
shownMoney.Changed:Connect(function(value)
	moneyLabel.Text = formatMoney(math.floor(value + 0.5))
end)

local iconScale = Instance.new("UIScale")
iconScale.Parent = moneyIcon

local function floater(delta: number)
	local label = templates.Floater:Clone()
	label.Visible = true
	label.Text = (delta > 0 and "+" or "-") .. formatMoney(math.abs(delta))
	label.TextColor3 = delta > 0 and GOOD or BAD
	label.Position = UDim2.fromOffset(0, -18)
	label.Parent = floaters
	local info = TweenInfo.new(1.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	TweenService:Create(label, info, { Position = UDim2.fromOffset(0, -60), TextTransparency = 1 }):Play()
	TweenService:Create(label.UIStroke, info, { Transparency = 1 }):Play()
	task.delay(1.2, function()
		label:Destroy()
	end)

	-- the cash icon jumps (and tilts) whenever money changes
	iconScale.Scale = delta > 0 and 1.25 or 0.85
	UIFx.tween(iconScale, UIFx.Info.Release, { Scale = 1 })
	moneyIcon.Rotation = delta > 0 and -14 or 10
	UIFx.tween(moneyIcon, UIFx.Info.Release, { Rotation = 0 })
end

task.spawn(function()
	-- (no timeout warning: loading a save can take a few seconds)
	local leaderstats = player:WaitForChild("leaderstats", math.huge)
	local moneyValue = leaderstats:WaitForChild(ECONOMY.CurrencyName, math.huge) :: IntValue
	local lastMoney = moneyValue.Value
	shownMoney.Value = lastMoney
	moneyLabel.Text = formatMoney(lastMoney)
	moneyValue.Changed:Connect(function(value)
		if value ~= lastMoney then
			floater(value - lastMoney)
		end
		lastMoney = value
		TweenService:Create(shownMoney, TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Value = value }):Play()
	end)
end)

---------------------------------------------------------------------------
-- Inventory
---------------------------------------------------------------------------
local grid = inventoryWindow:WaitForChild("Grid")
local emptyState = inventoryWindow:WaitForChild("Empty")
local emptySunburst = emptyState:WaitForChild("Sunburst")
local hintLabel = inventoryWindow:WaitForChild("Hint")
local countLabel = inventoryWindow.Header:WaitForChild("CountChip"):WaitForChild("Count")
local EquipEggRemote = Remotes:WaitForChild("EquipEgg")
local SellEggsRemote = Remotes:WaitForChild("SellEggs")
local sellAllButton = inventoryWindow.Header:WaitForChild("SellAll")
local MAX_EGGS = (Config.Inventory and Config.Inventory.MaxEggs) or 200
local HELD_COLOR = C3(150, 255, 40)
local IDLE_BORDER = C3(0, 0, 0)
local IDLE_HIGHLIGHT = C3(75, 125, 145)

-- one card per egg (every egg is its own item, keyed by its id)
local cards = {} -- [id] = { id, egg, button, body, sunburst, preview }
local equippedId: number? = nil

local function styleFor(info)
	local style = info and RARITY_STYLES[info.Rarity]
	if style then
		return style
	end
	local accent = (info and typeof(info.AccentColor) == "Color3" and info.AccentColor) or C3(235, 240, 245)
	local h, s, v = accent:ToHSV()
	return { rank = 0, banner = ColorSequence.new(accent, Color3.fromHSV(h, math.min(s + 0.15, 1), v * 0.72)), accent = accent }
end

-- 3D picture of the egg inside its card. The camera circles the egg (cheaper than moving every
-- part of the model) and the light turns with it, so the egg always stays lit from the front.
local BASE_LIGHT = Vector3.new(-0.5, -1, -0.7)
local function buildPreview(viewport: ViewportFrame, eggId: string)
	local template = DisplayTemplates:FindFirstChild(eggId)
	if not (template and template:IsA("Model")) then
		return nil
	end
	local model = template:Clone()
	for _, descendant in model:GetDescendants() do
		if descendant:IsA("BaseScript") then
			descendant:Destroy()
		elseif descendant:IsA("BasePart") then
			descendant.Anchored = true
		end
	end
	model:PivotTo(CFrame.new())
	local box, size = model:GetBoundingBox()
	model.Parent = viewport
	-- soft light (too bright washes out white eggs)
	viewport.Ambient = Color3.fromRGB(175, 175, 180)
	viewport.LightColor = Color3.fromRGB(255, 250, 240)
	viewport.LightDirection = BASE_LIGHT
	local camera = Instance.new("Camera")
	camera.FieldOfView = 30
	camera.Parent = viewport
	viewport.CurrentCamera = camera
	-- frame by the egg's height; very wide eggs (Angel wings) may touch the card edges
	local halfExtent = math.max(size.Y, size.X * 0.7, size.Z * 0.7) / 2
	return {
		viewport = viewport,
		camera = camera,
		center = box.Position,
		distance = halfExtent / math.tan(math.rad(camera.FieldOfView / 2)) * 1.1 + halfExtent,
		height = halfExtent * 0.35,
	}
end

local function posePreview(preview, angle: number)
	local c, s = math.cos(angle), math.sin(angle)
	preview.camera.CFrame = CFrame.lookAt(preview.center + Vector3.new(s * preview.distance, preview.height, c * preview.distance), preview.center)
	preview.viewport.LightDirection = Vector3.new(BASE_LIGHT.X * c + BASE_LIGHT.Z * s, BASE_LIGHT.Y, -BASE_LIGHT.X * s + BASE_LIGHT.Z * c)
end

-- eggs picked for selling: [id] = true (tap SELL on a card; while any are picked, tapping
-- a card picks / unpicks it instead of equipping)
local selected: { [number]: boolean } = {}
local selectedCount = 0
local PICK_COLOR = C3(255, 60, 90)
local PICK_BG = C3(72, 14, 28)
local IDLE_BG = C3(26, 44, 52)

local function refreshHint()
	if selectedCount > 0 then
		hintLabel.Text = selectedCount .. " picked - tap eggs to add or remove them"
	elseif equippedId then
		hintLabel.Text = "Click your equipped egg to put it away  |  SELL picks eggs to sell"
	else
		hintLabel.Text = "Click an egg to carry it  |  SELL picks eggs to sell"
	end
end

local function paintCard(card)
	local held = card.id == equippedId
	local picked = selected[card.id] == true
	local body = card.body
	body.HeldBadge.Visible = held
	local accent = if picked then PICK_COLOR elseif held then HELD_COLOR else nil
	body.BackgroundColor3 = if picked then PICK_BG else IDLE_BG
	body.Border.Color = accent or IDLE_BORDER
	body.Border.Thickness = if accent then 3 else 2.8
	body.Inner.Highlight.Color = accent or IDLE_HIGHLIGHT
	body.Inner.Highlight.Transparency = if accent then 0.1 else 0.4
	body.SellButton.Label.Visible = not picked
	body.SellButton.Check.Visible = picked
end

local function refreshEquipped()
	local previous = equippedId
	local value = player:GetAttribute("EquippedEggId")
	equippedId = type(value) == "number" and value or nil
	for _, card in cards do
		paintCard(card)
	end
	-- the newly equipped card bounces and its EQUIPPED tag pops in
	local card = equippedId and equippedId ~= previous and cards[equippedId]
	if card then
		card.body.ButtonScale.Scale = 1.15
		UIFx.tween(card.body.ButtonScale, UIFx.Info.Release, { Scale = 1 })
		local badge = card.body.HeldBadge
		local badgeScale = badge:FindFirstChild("PopScale") or Instance.new("UIScale")
		badgeScale.Name = "PopScale"
		badgeScale.Parent = badge
		UIFx.pop(badgeScale, 0.3)
	end
	refreshHint()
end

local equipBusy = false
local function requestEquip(id: number?)
	if equipBusy then
		return
	end
	equipBusy = true
	local ok, success, message = pcall(function()
		return EquipEggRemote:InvokeServer(id)
	end)
	equipBusy = false
	if not ok then
		toast("Couldn't reach the server - try again.", "error")
	elseif not success then
		toast(message or "Couldn't equip that egg.", "error")
	else
		UIFx.play("Equip")
	end
end

-- Selling -------------------------------------------------------------------
local SELL_GRADIENT = ColorSequence.new(C3(255, 32, 80), C3(208, 0, 32))
local CONFIRM_GRADIENT = ColorSequence.new(C3(255, 208, 0), C3(255, 140, 0))

-- what one egg sells for (same rule as the server: SellPrice, or Price x Economy.SellRate)
local function sellPrice(eggId: string): number
	local info = EGG_INFO[eggId]
	if not info then
		return 0
	end
	if tonumber(info.SellPrice) then
		return math.floor(info.SellPrice)
	end
	return math.floor((tonumber(info.Price) or 0) * (tonumber(ECONOMY.SellRate) or 0.5))
end

local selling = false
local function requestSell(request: { [string]: any })
	if selling then
		return
	end
	selling = true
	local ok, success, message = pcall(function()
		return SellEggsRemote:InvokeServer(request)
	end)
	selling = false
	if not ok then
		toast("Couldn't reach the server - try again.", "error")
	elseif success then
		UIFx.play("Purchase")
		showStrip(message or "Sold!", CASH_ICON)
	else
		toast(message or "Couldn't sell that.", "error")
	end
end

-- the header button: "Sell All" (keeps the egg you're holding), or "Sell 3" when eggs are picked.
-- Tap once to arm it (turns orange, "Confirm?"), tap again within 3 seconds to sell.
local sellLabel = sellAllButton.Content.Label
local sellArmedUntil = 0

local function refreshSellButton()
	sellArmedUntil = 0
	sellAllButton.ButtonGradient.Color = SELL_GRADIENT
	sellLabel.Text = if selectedCount > 0 then "Sell " .. selectedCount else "Sell All"
	refreshHint()
	if selectedCount > 0 then
		-- show what the picked eggs are worth
		local total = 0
		for id in selected do
			local card = cards[id]
			if card then
				total += sellPrice(card.egg)
			end
		end
		hintLabel.Text = selectedCount .. " picked (worth " .. formatMoney(total) .. ")  |  tap eggs to add or remove them"
	end
end

local function toggleSelected(id: number)
	if selected[id] then
		selected[id] = nil
		selectedCount -= 1
	else
		selected[id] = true
		selectedCount += 1
	end
	local card = cards[id]
	if card then
		paintCard(card)
		card.body.ButtonScale.Scale = 0.9
		UIFx.tween(card.body.ButtonScale, UIFx.Info.Release, { Scale = 1 })
	end
	refreshSellButton()
end

local function clearSelection()
	if selectedCount == 0 then
		return
	end
	local ids = {}
	for id in selected do
		table.insert(ids, id)
	end
	table.clear(selected)
	selectedCount = 0
	for _, id in ids do
		local card = cards[id]
		if card then
			paintCard(card)
		end
	end
	refreshSellButton()
end

local chipScale = Instance.new("UIScale")
chipScale.Parent = countLabel.Parent
local lastTotal = -1

local function refreshTotal()
	local total = 0
	for _ in cards do
		total += 1
	end
	countLabel.Text = total .. "/" .. MAX_EGGS
	if lastTotal >= 0 and total ~= lastTotal then
		UIFx.pop(chipScale, 1.3)
	end
	lastTotal = total
	emptyState.Visible = total == 0
	hintLabel.Visible = total > 0
	sellAllButton.Visible = total > 0
end

local function addCard(value: Instance)
	if not value:IsA("StringValue") then
		return
	end
	local id = tonumber(value.Name)
	if not id or cards[id] then
		return
	end
	local eggId = value.Value
	local info = EGG_INFO[eggId]
	local style = styleFor(info)
	local button = templates.EggCard:Clone()
	button.Name = value.Name
	button.Visible = true
	-- rarest first, newest first inside each rarity
	button.LayoutOrder = (10 - style.rank) * 10000000 + math.max(0, 9999999 - id)
	local body = button.Body
	body.Banner.BannerGradient.Color = style.banner
	body.Banner.BannerGradient.Rotation = style.rotation or 90
	body.Banner.EggName.Text = (info and info.DisplayName) or eggId
	body.Rarity.Text = string.upper((info and info.Rarity) or "")
	body.Rarity.TextColor3 = style.accent
	body.Sunburst.ImageColor3 = style.accent
	button.Parent = grid

	local card = { id = id, egg = eggId, button = button, body = body, sunburst = body.Sunburst, preview = buildPreview(body.Preview, eggId) }
	if card.preview then
		posePreview(card.preview, 0)
	end
	cards[id] = card
	paintCard(card)
	bindButton(button, body.ButtonScale)
	-- SELL (top-left of the card) picks / unpicks this egg for selling
	local sellButton = body.SellButton
	bindButton(sellButton)
	sellButton.Activated:Connect(function()
		toggleSelected(id)
	end)
	button.Activated:Connect(function()
		if selectedCount > 0 then
			toggleSelected(card.id) -- picking eggs to sell: tapping a card picks it
			return
		end
		-- click the held egg to put it away, any other egg to hold that one
		requestEquip(if card.id == equippedId then nil else card.id)
	end)
end

local function removeCard(value: Instance)
	local id = tonumber(value.Name)
	local card = id and cards[id]
	if card then
		card.button:Destroy()
		cards[id] = nil
	end
	if id and selected[id] then
		selected[id] = nil
		selectedCount -= 1
		refreshSellButton()
	end
end

task.spawn(function()
	local folder = player:WaitForChild("EggInventory", math.huge) :: Folder
	for _, value in folder:GetChildren() do
		addCard(value)
	end
	folder.ChildAdded:Connect(function(value)
		addCard(value)
		refreshTotal()
	end)
	folder.ChildRemoved:Connect(function(value)
		removeCard(value)
		refreshTotal()
	end)
	refreshTotal()
end)
player:GetAttributeChangedSignal("EquippedEggId"):Connect(refreshEquipped)
refreshEquipped()
refreshTotal()

-- egg previews turn and sunbursts rotate (20 deg/s) only while the inventory is open,
-- and only for cards that are scrolled into view
local animConnection: RBXScriptConnection? = nil
local function setInventoryAnimating(on: boolean)
	if on and not animConnection then
		animConnection = RunService.RenderStepped:Connect(function(dt)
			local angle = os.clock() * 1.2
			local turn = 20 * dt
			emptySunburst.Rotation = (emptySunburst.Rotation + turn) % 360
			local top = grid.AbsolutePosition.Y
			local bottom = top + grid.AbsoluteSize.Y
			for _, card in cards do
				local y = card.button.AbsolutePosition.Y
				if y + card.button.AbsoluteSize.Y >= top and y <= bottom then
					card.sunburst.Rotation = (card.sunburst.Rotation + turn) % 360
					if card.preview then
						posePreview(card.preview, angle)
					end
				end
			end
		end)
	elseif not on and animConnection then
		animConnection:Disconnect()
		animConnection = nil
	end
end

local setCashAnimating = function(_on: boolean) end -- replaced in the cash shop section

-- what pops in after a window opens
local function playOpenAnimation(modal)
	if modal == inventoryModal then
		-- the first rows of cards pop in one after another
		local list = {}
		for _, card in cards do
			table.insert(list, card)
		end
		table.sort(list, function(a, b)
			return a.button.LayoutOrder < b.button.LayoutOrder
		end)
		local scales = {}
		for index = 1, math.min(#list, 12) do
			table.insert(scales, list[index].body.ButtonScale)
		end
		UIFx.popAll(scales, 0.03, 0.7)
	elseif modal == adminModal then
		local rows = adminWindow:FindFirstChild("Body")
		if rows then
			for index, name in { "TargetRow", "MoneyRow", "EggRow", "Status" } do
				local row = rows:FindFirstChild(name)
				if row then
					UIFx.slideIn(row, UDim2.fromOffset(0, 22), 0.04 + (index - 1) * 0.05)
				end
			end
		end
	elseif modal == cashModal then
		local scales = {}
		for _, card in cashWindow.Packs:GetChildren() do
			local popScale = card:FindFirstChild("Body") and card.Body:FindFirstChild("PopScale")
			if popScale then
				table.insert(scales, { order = card.LayoutOrder, scale = popScale })
			end
		end
		table.sort(scales, function(a, b)
			return a.order < b.order
		end)
		for index, entry in scales do
			UIFx.pop(entry.scale, 0.55, 0.05 + (index - 1) * 0.06)
		end
	end
end

local function showModal(modal, show: boolean)
	if show then
		for _, other in modals do
			if other ~= modal then
				other.close()
			end
		end
		modal.open()
		playOpenAnimation(modal)
	else
		modal.close()
	end
	setInventoryAnimating(inventoryModal.isOpen)
	setCashAnimating(cashModal.isOpen)
	if not inventoryModal.isOpen then
		clearSelection()
	end
end

inventoryButton.Activated:Connect(function()
	showModal(inventoryModal, not inventoryModal.isOpen)
end)
inventoryWindow.Header.Close.Activated:Connect(function()
	showModal(inventoryModal, false)
end)

-- "Sell All" / "Sell 3": tap, then tap again within 3 seconds to confirm
sellAllButton.Activated:Connect(function()
	if os.clock() > sellArmedUntil then
		local token = os.clock() + 3
		sellArmedUntil = token
		sellLabel.Text = "Confirm?"
		sellAllButton.ButtonGradient.Color = CONFIRM_GRADIENT
		task.delay(3, function()
			if sellArmedUntil == token then
				refreshSellButton()
			end
		end)
		return
	end
	if selectedCount > 0 then
		local ids = {}
		for id in selected do
			table.insert(ids, id)
		end
		clearSelection()
		requestSell({ Ids = ids })
	else
		refreshSellButton()
		requestSell({ All = true })
	end
end)

---------------------------------------------------------------------------
-- Admin panel (the server re-checks admin rights on every request)
---------------------------------------------------------------------------
local body = adminWindow:WaitForChild("Body")
local targetRow = body:WaitForChild("TargetRow")
local moneyRow = body:WaitForChild("MoneyRow")
local eggRow = body:WaitForChild("EggRow")
local targetText = targetRow.Display.Value
local targetSub = targetRow.Sub
local TARGET_SUB_TEXT = targetSub.Text
local eggText = eggRow.Display.Value
local amountField = moneyRow.AmountField
local amountBox = amountField.AmountBox :: TextBox
local statusLabel = body.Status
local clearButton = eggRow.ClearEggs
local clearLabel = clearButton.Label
local CLEAR_TEXT = clearLabel.Text

local selectedTarget: Player? = player
local eggIndex = 1

local function refreshAdminTexts()
	-- long names don't fit next to "(you)", so that goes on the subtitle line instead
	targetText.Text = selectedTarget and selectedTarget.Name or "-"
	targetSub.Text = selectedTarget == player and "That's you" or TARGET_SUB_TEXT
	local egg = Config.Eggs[eggIndex]
	eggText.Text = egg and (egg.DisplayName or egg.TemplateName) or "-"
end

local function cycleTarget(direction: number)
	local list = Players:GetPlayers()
	table.sort(list, function(a, b)
		return a.Name < b.Name
	end)
	local index = table.find(list, selectedTarget) or 1
	selectedTarget = list[(index - 1 + direction) % #list + 1]
	refreshAdminTexts()
end

local function cycleEgg(direction: number)
	eggIndex = (eggIndex - 1 + direction) % math.max(#Config.Eggs, 1) + 1
	refreshAdminTexts()
end

local function setStatus(ok: boolean, message: string)
	statusLabel.Text = message
	statusLabel.TextColor3 = ok and GOOD or BAD
end

-- amount box: digits only, shown with commas
local formatting = false
amountBox:GetPropertyChangedSignal("Text"):Connect(function()
	if formatting then
		return
	end
	local digits = (amountBox.Text:gsub("[^%d]", ""))
	digits = (digits:gsub("^0+(%d)", "%1")):sub(1, 12)
	local pretty = digits == "" and "" or withCommas(digits)
	if pretty ~= amountBox.Text then
		formatting = true
		amountBox.Text = pretty
		amountBox.CursorPosition = #pretty + 1
		formatting = false
	end
end)
amountBox.Focused:Connect(function()
	TweenService:Create(amountField.Border, HOVER, { Color = FIELD_FOCUS, Thickness = 2 }):Play()
end)
amountBox.FocusLost:Connect(function()
	TweenService:Create(amountField.Border, HOVER, { Color = FIELD_IDLE, Thickness = 1.2 }):Play()
end)

local function typedAmount(): number?
	local digits = (amountBox.Text:gsub("[^%d]", ""))
	return tonumber(digits)
end

local adminBusy = false
local function adminRequest(action: string, data: { [string]: any })
	if adminBusy then
		return
	end
	adminBusy = true
	data.TargetUserId = selectedTarget and selectedTarget.UserId
	local ok, success, message = pcall(function()
		return Remotes.AdminAction:InvokeServer(action, data)
	end)
	adminBusy = false
	if not ok then
		setStatus(false, "Request failed - try again.")
	else
		setStatus(success == true, message or "")
	end
end

targetRow.Prev.Activated:Connect(function()
	cycleTarget(-1)
end)
targetRow.Next.Activated:Connect(function()
	cycleTarget(1)
end)
eggRow.Prev.Activated:Connect(function()
	cycleEgg(-1)
end)
eggRow.Next.Activated:Connect(function()
	cycleEgg(1)
end)

for _, quick in moneyRow.QuickRow:GetChildren() do
	if quick:IsA("GuiButton") then
		quick.Activated:Connect(function()
			adminRequest("GiveMoney", { Amount = quick:GetAttribute("Amount") })
		end)
	end
end
moneyRow.GiveMoney.Activated:Connect(function()
	adminRequest("GiveMoney", { Amount = typedAmount() })
end)
moneyRow.SetMoney.Activated:Connect(function()
	adminRequest("SetMoney", { Amount = typedAmount() })
end)
eggRow.GiveEgg.Activated:Connect(function()
	local egg = Config.Eggs[eggIndex]
	adminRequest("GiveEgg", { EggId = egg and egg.TemplateName })
end)

-- clearing an inventory needs a second press to confirm
local confirmUntil = 0
clearButton.Activated:Connect(function()
	if os.clock() > confirmUntil then
		confirmUntil = os.clock() + 3
		clearLabel.Text = "Confirm Clear?"
		task.delay(3, function()
			if os.clock() >= confirmUntil then
				clearLabel.Text = CLEAR_TEXT
			end
		end)
		return
	end
	confirmUntil = 0
	clearLabel.Text = CLEAR_TEXT
	adminRequest("ClearEggs", {})
end)

Players.PlayerRemoving:Connect(function(leaving)
	if selectedTarget == leaving then
		selectedTarget = player
		refreshAdminTexts()
	end
end)

local function refreshAdminAccess()
	local isAdmin = player:GetAttribute("EggAdmin") == true
	-- hide the whole slot so the column re-centres around the Inventory button
	adminButton.Parent.Visible = isAdmin
	if not isAdmin and adminModal.isOpen then
		showModal(adminModal, false)
	end
end
player:GetAttributeChangedSignal("EggAdmin"):Connect(refreshAdminAccess)
refreshAdminAccess()
refreshAdminTexts()
statusLabel.TextColor3 = MUTED

adminButton.Activated:Connect(function()
	showModal(adminModal, not adminModal.isOpen)
end)
adminWindow.Header.Close.Activated:Connect(function()
	showModal(adminModal, false)
end)

---------------------------------------------------------------------------
-- Robux cash shop (the green + next to the money). Packs: Config.CashShop.
---------------------------------------------------------------------------
local MarketplaceService = game:GetService("MarketplaceService")
local cashPacks = cashWindow:WaitForChild("Packs")
local packSunbursts = {}
local SOON_GRADIENT = ColorSequence.new(C3(216, 222, 228), C3(148, 160, 176))

local BUY_GRADIENT = ColorSequence.new(C3(180, 255, 25), C3(105, 225, 0))
local packStates = {} -- [index] = { productId, buyButton }

-- point a pack at its Developer Product (0 = not for sale yet) and show its Robux price
local function applyProductId(state, productId: number)
	if state.productId == productId then
		return
	end
	state.productId = productId
	local buyButton = state.buyButton
	local price = buyButton.Content.Price
	if productId > 0 then
		buyButton.Content.RobuxIcon.Visible = true
		buyButton.ButtonGradient.Color = BUY_GRADIENT
		price.Text = "..."
		task.spawn(function()
			local ok, info = pcall(function()
				return MarketplaceService:GetProductInfo(productId, Enum.InfoType.Product)
			end)
			if state.productId == productId then
				price.Text = if ok and info and info.PriceInRobux then tostring(info.PriceInRobux) else "?"
			end
		end)
	else
		price.Text = "Soon"
		buyButton.Content.RobuxIcon.Visible = false
		buyButton.ButtonGradient.Color = SOON_GRADIENT
	end
end

for index, pack in (Config.CashShop and Config.CashShop.Packs) or {} do
	local card = templates.CashPackCard:Clone()
	card.Name = "Pack" .. index
	card.LayoutOrder = index
	card.Visible = true
	local packBody = card.Body
	packBody.Icon.Image = pack.Icon or CASH_ICON
	packBody.Amount.Text = formatMoney(tonumber(pack.Cash) or 0)
	packBody.PackName.Text = pack.Name or ""
	packBody.Sunburst.ImageColor3 = if index <= 2 then C3(150, 255, 60) else C3(255, 215, 70)
	packBody.Tag.Visible = pack.Tag ~= nil
	if pack.Tag then
		packBody.Tag.Label.Text = string.upper(pack.Tag)
	end
	table.insert(packSunbursts, packBody.Sunburst)

	local buyButton = packBody.BuyButton
	local state = { productId = -1, buyButton = buyButton }
	packStates[index] = state
	applyProductId(state, tonumber(pack.ProductId) or 0)
	bindButton(buyButton)
	buyButton.Activated:Connect(function()
		if state.productId <= 0 then
			toast("This pack isn't for sale yet.", "info")
			return
		end
		MarketplaceService:PromptProductPurchase(player, state.productId)
	end)
	card.Parent = cashPacks
end

-- CashShopServer links each pack to the Developer Product with the same name and shares
-- the IDs here ("id1,id2,..."), so new products work without touching any script
local function readLinkedIds()
	local text = Shared:GetAttribute("CashPackProductIds")
	if type(text) ~= "string" then
		return
	end
	for index, id in string.split(text, ",") do
		local state = packStates[index]
		if state then
			applyProductId(state, tonumber(id) or 0)
		end
	end
end
Shared:GetAttributeChangedSignal("CashPackProductIds"):Connect(readLinkedIds)
readLinkedIds()

local cashAnim: RBXScriptConnection? = nil
setCashAnimating = function(on: boolean)
	if on and not cashAnim then
		cashAnim = RunService.RenderStepped:Connect(function(dt)
			for _, sunburst in packSunbursts do
				sunburst.Rotation = (sunburst.Rotation + 20 * dt) % 360
			end
		end)
	elseif not on and cashAnim then
		cashAnim:Disconnect()
		cashAnim = nil
	end
end

plusButton.Activated:Connect(function()
	showModal(cashModal, not cashModal.isOpen)
end)
cashWindow.Header.Close.Activated:Connect(function()
	showModal(cashModal, false)
end)

-- the + gently pulses every few seconds so players notice it
task.spawn(function()
	local pulse = plusButton.Parent:WaitForChild("PulseScale") :: UIScale
	local half = TweenInfo.new(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
	while plusButton.Parent do
		task.wait(2.4)
		if not cashModal.isOpen then
			UIFx.tween(pulse, half, { Scale = 1.15 }).Completed:Wait()
			UIFx.tween(pulse, half, { Scale = 1 }).Completed:Wait()
		end
	end
end)

-- the HUD slides in when you join
task.defer(function()
	for index, slot in { dock:FindFirstChild("InventorySlot"), dock:FindFirstChild("AdminSlot") } do
		local button = slot and slot:FindFirstChildWhichIsA("GuiButton")
		if button then
			UIFx.slideIn(button, UDim2.fromOffset(-160, 0), 0.15 + index * 0.08)
		end
	end
	UIFx.slideIn(moneyDock, UDim2.fromOffset(0, 100), 0.25)
end)

---------------------------------------------------------------------------
-- "Buy" prompts on the pedestals (only shown to the player who rolled).
-- They use Style = Custom and are drawn by StarterPlayerScripts.CheckUIPrompts.
---------------------------------------------------------------------------
local promptFolder = Instance.new("Folder")
promptFolder.Name = "EggShop_LocalPrompts"
promptFolder.Parent = workspace

local machines = {} -- [machine] = { prompts = {[slotIndex] = prompt}, parts = {}, connections = {} }


-- No cooldown: buy as many eggs as fast as you like. Only the same pedestal can't be sent
-- twice while its first request is still on the way.
local pendingBuys = {} -- [machine] = { [slotIndex] = true }

local function buy(machine: Instance, slotIndex: number)
	local pending = pendingBuys[machine]
	if not pending then
		pending = {}
		pendingBuys[machine] = pending
	end
	if pending[slotIndex] then
		return
	end
	pending[slotIndex] = true
	local ok, success, message = pcall(function()
		return Remotes.BuyEgg:InvokeServer(machine, slotIndex)
	end)
	pending[slotIndex] = nil
	if not ok then
		toast("Couldn't reach the server - try again.", "error")
	elseif success then
		UIFx.play("Purchase")
		showStrip("Purchased!")
	else
		toast(message or "Couldn't buy that.", "error") -- not enough money, too far away, etc.
	end
end

local function refreshPrompts(entry)
	local machine = entry.machine
	local mine = machine:GetAttribute("RolledByUserId") == player.UserId
	local rolling = machine:GetAttribute("State") == "Rolling"
	local results = string.split(machine:GetAttribute("Results") or "", ",")
	local bought = machine:GetAttribute("Bought") or ""
	for slotIndex, prompt in entry.prompts do
		local eggId = results[slotIndex]
		local info = eggId and EGG_INFO[eggId]
		if info then
			-- the egg's name is already on its floating label, so the prompt only shows the price
			prompt.ObjectText = ""
			prompt.ActionText = "Buy " .. formatMoney(tonumber(info.Price) or 0)
		end
		prompt.Enabled = mine and not rolling and info ~= nil and bought:sub(slotIndex, slotIndex) ~= "1"
	end
end

local function removeMachine(machine: Instance)
	local entry = machines[machine]
	if not entry then
		return
	end
	machines[machine] = nil
	for _, connection in entry.connections do
		connection:Disconnect()
	end
	for _, part in entry.parts do
		part:Destroy()
	end
end

local function addMachine(machine: Instance)
	if machines[machine] or not machine:IsA("Model") then
		return
	end
	local entry = { machine = machine, prompts = {}, parts = {}, connections = {} }
	machines[machine] = entry
	local slots = machine:WaitForChild("Slots", 10)
	if not slots or machines[machine] ~= entry then
		return
	end
	for _, slot in slots:GetChildren() do
		local slotIndex = slot:GetAttribute("SlotIndex")
		local anchor = slot:FindFirstChild("EggAnchor")
		if type(slotIndex) == "number" and anchor and anchor:IsA("BasePart") then
			local part = Instance.new("Part")
			part.Name = "BuyPoint"
			part.Anchored = true
			part.CanCollide = false
			part.CanQuery = false
			part.CanTouch = false
			part.Transparency = 1
			part.Size = Vector3.new(1, 1, 1)
			part.CFrame = anchor.CFrame * CFrame.new(0, Config.Display.EggHeight * 0.5, 0)
			part.Parent = promptFolder

			local prompt = Instance.new("ProximityPrompt")
			prompt.Name = "BuyPrompt"
			prompt.Style = Enum.ProximityPromptStyle.Custom
			prompt.KeyboardKeyCode = Enum.KeyCode.F -- the lever uses E
			prompt.GamepadKeyCode = Enum.KeyCode.ButtonY
			prompt.HoldDuration = 0 -- one press / click / tap buys (a hold felt broken)
			prompt.MaxActivationDistance = 10
			prompt.RequiresLineOfSight = false
			prompt.Enabled = false
			prompt:SetAttribute("CheckUITheme", "Lime")
			prompt:SetAttribute("CheckUIIcon", ICONS.Cash)
			-- draw the button just under the egg so it never covers it
			prompt:SetAttribute("CheckUIOffset", Vector3.new(0, -Config.Display.EggHeight * 0.5 - 0.6, 0))
			prompt.Parent = part
			prompt.Triggered:Connect(function()
				buy(machine, slotIndex)
			end)

			entry.prompts[slotIndex] = prompt
			table.insert(entry.parts, part)
		end
	end
	for _, attribute in { "State", "Results", "Bought", "RolledByUserId" } do
		table.insert(entry.connections, machine:GetAttributeChangedSignal(attribute):Connect(function()
			refreshPrompts(entry)
		end))
	end
	refreshPrompts(entry)
end

for _, machine in CollectionService:GetTagged(Config.MachineTag) do
	task.spawn(addMachine, machine)
end
CollectionService:GetInstanceAddedSignal(Config.MachineTag):Connect(addMachine)
CollectionService:GetInstanceRemovedSignal(Config.MachineTag):Connect(removeMachine)
