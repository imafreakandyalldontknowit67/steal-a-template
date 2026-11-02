-- Client-local presentation demo. No purchases, rewards, or server communication.
local gui = script.Parent
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local canvas = gui:WaitForChild("DesignCanvas")
local hud = canvas:WaitForChild("HUD")
local modals = canvas:WaitForChild("Modals")
local toast = canvas:WaitForChild("DemoFeedback")
local connections, activeTweens, bases = {}, {}, {}
local alive, current, transition, transitionConnection = true, nil, nil, nil
local generation, toastGeneration = 0, 0
local soundEnabled = true
local reducedMotion = gui:GetAttribute("ReducedMotion") == true
local volume = math.clamp(gui:GetAttribute("SoundVolume") or 0.35, 0, 1)
local state = {
    money = 572831, level = 5, rebirths = 4, rebirthTier = 1,
    day = 2, claimedDays = {[1] = true}, premium = false, starter = false,
    passClaims = {}, stocks = {3, 5, 2, 1, 0, 1}, upgrades = {0, 0, 0},
    boosts = {}, purchases = 0,
}
-- Local sample catalog. Rarity filtering selects actual entries, then reuses
-- the twelve editable card slots instead of cloning decorative descendants.
local catalog = {}
local rarityColors = {
    Common = Color3.fromRGB(185, 192, 202), Rare = Color3.fromRGB(39, 168, 255),
    Epic = Color3.fromRGB(197, 43, 255), Legendary = Color3.fromRGB(255, 185, 24),
    Mythical = Color3.fromRGB(255, 33, 113), Secret = Color3.fromRGB(90, 101, 120),
}
for _, rarity in ipairs({"Common", "Rare", "Epic", "Legendary", "Mythical", "Secret"}) do
    for index = 1, 12 do
        table.insert(catalog, {id = rarity .. index, rarity = rarity, name = rarity == "Common" and "Item Name" or (rarity .. " Item " .. index)})
    end
end

local function connect(signal, fn)
    local connection = signal:Connect(fn)
    table.insert(connections, connection)
    return connection
end

local function find(name)
    return canvas:FindFirstChild(name, true)
end

local function setText(name, value)
    local object = find(name)
    if object then object.Text = value end
end

local function feedback(message)
    if not alive then return end
    toastGeneration = toastGeneration + 1
    local token = toastGeneration
    toast.Text = "DEMO ONLY  |  " .. message
    toast.Visible = true
    task.delay(3.5, function()
        if alive and token == toastGeneration then toast.Visible = false end
    end)
end

local sounds = {}
for _, kind in ipairs({"Open", "Close", "Hover", "Click"}) do
    local id = gui:GetAttribute(kind .. "SoundId")
    -- Empty configuration is deliberately silent. Only owner-supplied IDs are used.
    if type(id) == "string" and id:match("%S") then
        local sound = Instance.new("Sound")
        sound.Name = kind .. "Sound"
        sound.SoundId = id
        sound.Volume = kind == "Hover" and volume * 0.25 or volume
        sound.PlaybackSpeed = ({Open=1.25, Close=0.8, Hover=1.8, Click=1.5})[kind] or 1
        sound.Parent = gui
        sounds[kind] = sound
    end
end
local function play(kind)
    local sound = sounds[kind]
    if soundEnabled and sound then sound.TimePosition = 0; sound:Play() end
end

local function animate(object, properties, seconds)
    local old = activeTweens[object]
    if old then
        old.connection:Disconnect()
        old.tween:Cancel()
        activeTweens[object] = nil
    end
    if reducedMotion then
        for key, value in pairs(properties) do object[key] = value end
        return
    end
    local tween = TweenService:Create(object, TweenInfo.new(seconds, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), properties)
    local record = {tween = tween}
    record.connection = tween.Completed:Connect(function()
        record.connection:Disconnect()
        if activeTweens[object] == record then activeTweens[object] = nil end
    end)
    activeTweens[object] = record
    tween:Play()
end

local function resize()
    local size = gui.AbsoluteSize
    if size.X <= 0 or size.Y <= 0 then return end
    local scale = math.min(size.X / 2000, size.Y / 1125)
    canvas.ResponsiveScale.Scale = scale
    canvas.Size = UDim2.fromOffset(size.X / scale, size.Y / scale)
end
connect(gui:GetPropertyChangedSignal("AbsoluteSize"), resize)
resize()

for _, panel in ipairs(modals:GetChildren()) do
    if panel:IsA("Frame") then
        bases[panel] = panel.Position
        panel.Visible = false
        panel.Active = false
    end
end

local function cancelTransition()
    generation = generation + 1
    if transitionConnection then transitionConnection:Disconnect(); transitionConnection = nil end
    if transition then transition:Cancel(); transition = nil end
end

local function navigate(target)
    cancelTransition()
    -- Hide/reset all old panels synchronously BEFORE the next panel becomes visible.
    -- No delayed close callback can hide a subsequently reopened panel.
    for panel, base in pairs(bases) do
        panel.Visible = false
        panel.Active = false
        panel.Position = base
    end
    current = nil
    local panel = target and modals:FindFirstChild(target)
    if not panel or not bases[panel] then return end
    current = panel
    panel.Visible = true
    panel.Active = true
    if not reducedMotion then
        panel.Position = bases[panel] + UDim2.fromOffset(0, canvas.Size.Y.Offset + panel.Size.Y.Offset)
        transition = TweenService:Create(panel, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position = bases[panel]})
        transition:Play()
    end
    play("Open")
end

local function closePanel()
    if not current then return end
    cancelTransition()
    play("Close")
    local panel, token = current, generation
    if reducedMotion then navigate(nil); return end
    transition = TweenService:Create(panel, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Position = bases[panel] + UDim2.fromOffset(0, canvas.Size.Y.Offset + panel.Size.Y.Offset)})
    transitionConnection = transition.Completed:Connect(function(result)
        if not alive or token ~= generation or result ~= Enum.PlaybackState.Completed then return end
        transitionConnection:Disconnect()
        transitionConnection = nil
        transition = nil
        panel.Visible = false
        panel.Active = false
        panel.Position = bases[panel]
        current = nil
    end)
    transition:Play()
end
connect(UserInputService.InputBegan, function(input)
    if input.KeyCode == Enum.KeyCode.Escape and not UserInputService:GetFocusedTextBox() then closePanel() end
end)

local function comma(number)
    local value = tostring(math.floor(number))
    while true do
        local formatted, count = value:gsub("^(%-?%d+)(%d%d%d)", "%1,%2")
        value = formatted
        if count == 0 then return value end
    end
end

local function tintButton(button, top, bottom)
    local gradient = button:FindFirstChild("SurfaceGradient")
    if gradient then gradient.Color = ColorSequence.new(top, bottom) end
end

local function refresh()
    setText("MoneyValue", "$" .. comma(state.money))
    setText("RebirthCount", tostring(state.rebirths))
    setText("LevelValue", "Level " .. state.level)
    setText("PassLevel", "Lvl " .. state.level)
    setText("CurrentTier", "Rebirth " .. state.rebirthTier)
    setText("NextTier", "Rebirth " .. (state.rebirthTier + 1))
    setText("CurrentMultiplier", ("X" .. string.format("%.1f", 1 + (state.rebirthTier - 1) * 0.3):gsub("%.0$", "") .. " Money"))
    setText("NextMultiplier", string.format("X%.1f Money", 1 + state.rebirthTier * 0.3))
    find("RebirthProgress").Size = UDim2.fromScale(math.clamp(state.money / 1000000, 0, 1), 1)
    setText("RequirementValue", "$" .. comma(state.money) .. " / $1,000,000")
    for day = 1, 7 do
        local button = find("ClaimDay" .. day)
        local claimed = state.claimedDays[day]
        local available = day == state.day and not claimed
        button.Caption.Text = claimed and "CLAIMED" or (available and "CLAIM" or "LOCKED")
        button:SetAttribute("DemoState", claimed and "Claimed" or (available and "Available" or "Locked"))
        tintButton(button, claimed and Color3.fromRGB(194, 199, 205) or (available and Color3.fromRGB(241, 255, 0) or Color3.fromRGB(255, 0, 183)), claimed and Color3.fromRGB(90, 94, 103) or (available and Color3.fromRGB(53, 239, 0) or Color3.fromRGB(248, 0, 26)))
    end
    for i, count in ipairs(state.stocks) do setText("StockCount" .. i, "Stock x" .. count) end
    for _, object in ipairs(modals.SeasonPass:GetDescendants()) do
        if object:IsA("GuiButton") and object:GetAttribute("StudsAction") == "ClaimPassReward" then
            local level, track = object:GetAttribute("Level"), object:GetAttribute("Track")
            local key = track .. level
            local locked = level > state.level or (track == "Premium" and not state.premium)
            local claimed = state.passClaims[key]
            object.Status.Text = claimed and "CLAIMED" or (locked and "LOCKED" or "CLAIM")
            if object:FindFirstChild("ClaimCheck") then object.ClaimCheck.Visible = claimed == true end
            if object:FindFirstChild("RewardLock") then object.RewardLock.Visible = locked and not claimed end
            object.Status.TextColor3 = claimed and Color3.fromRGB(110, 255, 62) or (locked and Color3.fromRGB(255, 210, 54) or Color3.new(1, 1, 1))
        end
    end
    find("PremiumPass").Caption.Text = state.premium and "Premium ON" or "Premium Pass"
    find("StarterBuy").Caption.Text = state.starter and "CLAIMED" or "19  ·  GET PACK"
    setText("SoundSetting", soundEnabled and "ON" or "OFF")
    setText("MotionSetting", reducedMotion and "REDUCED" or "FULL")
    setText("VolumeValue", math.floor(volume * 100 + 0.5) .. "%")
    for i, level in ipairs(state.upgrades) do
        if level > 0 then
            local values = {string.format("%.1f sec", math.max(1, 9.5 - level * 0.5)), string.format("x%.2f", 1.1 + level * 0.1), tostring(150 + level * 50)}
            local nextValues = {string.format("%.1f sec", math.max(1, 9 - level * 0.5)), string.format("x%.2f", 1.2 + level * 0.1), tostring(200 + level * 50)}
            setText("UpgradeFrom" .. i, values[i])
            setText("UpgradeTo" .. i, nextValues[i])
        end
    end
end
for level = 1, 4 do state.passClaims["Free" .. level] = true end

local function claimDay(day)
    if state.claimedDays[day] then feedback("Day " .. day .. " was already claimed locally."); return end
    if day ~= state.day then feedback("Day " .. day .. " is locked. Claim the available day first."); return end
    state.claimedDays[day] = true
    state.day = math.min(8, day + 1)
    state.money = state.money + day * 100
    feedback("Day " .. day .. " claimed. Demo advances immediately; no real reward.")
end

local function claimPass(level, track)
    if level > state.level or (track == "Premium" and not state.premium) then return false end
    local key = track .. level
    if state.passClaims[key] then return false end
    state.passClaims[key] = true
    return true
end

local actions = {}
actions.OpenPanel = function(button)
    local target = button:GetAttribute("StudsTarget")
    if current and current.Name == target then closePanel() else navigate(target) end
end
actions.ClosePanel = closePanel
actions.MyBase = function() navigate(nil); feedback("My Base selected. No character teleport is performed.") end
actions.ClaimDaily = function(button) claimDay(button:GetAttribute("Day")) end
actions.ClaimAllDaily = function()
    if state.day > 7 then feedback("All seven demo days have been claimed.") else claimDay(state.day) end
end
actions.FilterRarity = function(button)
    local rarity = button:GetAttribute("Rarity")
    local filtered = {}
    for _, item in ipairs(catalog) do
        if item.rarity == rarity then table.insert(filtered, item) end
    end
    for index = 1, 12 do
        local card = find("IndexItem" .. index)
        local item = filtered[index]
        card.Visible = item ~= nil
        if item then
            card:SetAttribute("Rarity", item.rarity)
            card:SetAttribute("ItemId", item.id)
            card.ItemName.Text = item.name
            card.ItemName.TextSize = rarity == "Common" and 35 or (#item.name > 14 and 23 or 28)
            tintButton(card, rarityColors[rarity], Color3.fromRGB(25, 30, 38))
        end
    end
    for _, tab in ipairs(find("RarityTabs"):GetChildren()) do
        if tab:IsA("GuiButton") then
            local selected = tab == button
            tab:SetAttribute("Selected", selected)
            tab:FindFirstChild("SelectionLine").Visible = selected
        end
    end
    find("IndexCards").CanvasPosition = Vector2.zero
    feedback(rarity .. " collection selected: 12 editable demo items.")
end
actions.InspectItem = function(button) feedback(button:GetAttribute("Rarity") .. " · " .. button:GetAttribute("ItemId") .. " · demo collection entry.") end
actions.ShopOffer = function(button)
    state.purchases = state.purchases + 1
    button:SetAttribute("DemoPurchases", (button:GetAttribute("DemoPurchases") or 0) + 1)
    feedback(button:GetAttribute("Offer") .. " previewed (#" .. state.purchases .. "). Nothing was purchased.")
end
actions.Boost = function(button)
    local boost = button:GetAttribute("Boost")
    state.boosts[boost] = not state.boosts[boost]
    setText(boost .. "BoostStatus", state.boosts[boost] and "X2 · DEMO" or "X1.1")
    feedback(boost .. " boost " .. (state.boosts[boost] and "enabled" or "disabled") .. " locally.")
end
actions.AddLevels = function(button)
    state.level = math.min(99, state.level + (button:GetAttribute("Amount") or 1))
    feedback("Demo level is now " .. state.level .. ".")
end
actions.SkipPass = function() state.level = math.min(99, state.level + 1); feedback("Skipped one demo season level.") end
actions.PremiumPass = function() state.premium = not state.premium; feedback("Premium track toggled locally. No purchase.") end
actions.ClaimPassReward = function(button)
    local claimed = claimPass(button:GetAttribute("Level"), button:GetAttribute("Track"))
    feedback(claimed and "Season reward marked claimed locally." or "Reward locked or already claimed.")
end
actions.ClaimPass = function()
    local count = 0
    for level = 1, 12 do
        for _, track in ipairs({"Free", "Premium"}) do if claimPass(level, track) then count = count + 1 end end
    end
    feedback(count .. " available season rewards marked claimed locally.")
end
actions.DemoProgress = function() state.money = state.money + 250000; feedback("Added $250,000 to the local demo balance.") end
actions.Rebirth = function()
    if state.money < 1000000 then feedback("Requires $1,000,000. Use DEMO +$250K to preview progress."); return end
    state.money = state.money - 1000000
    state.rebirths = state.rebirths + 1
    state.rebirthTier = state.rebirthTier + 1
    feedback("Rebirth simulated. Only the local demo balance changed.")
end
actions.SkipRebirth = function()
    state.rebirths = state.rebirths + 1
    state.rebirthTier = state.rebirthTier + 1
    feedback("Rebirth skipped locally; kept the demo balance. No purchase.")
end
actions.Upgrade = function(button)
    local index = button:GetAttribute("Upgrade")
    local cost = button:GetAttribute("Cost") or 0
    if state.money < cost then feedback("Not enough demo money."); return end
    state.money = state.money - cost
    state.upgrades[index] = state.upgrades[index] + 1
    feedback("Upgrade " .. index .. " advanced to demo rank " .. state.upgrades[index] .. ".")
end
actions.BuyStock = function(button)
    local index, cost = button:GetAttribute("Stock"), button:GetAttribute("Cost") or 0
    if state.stocks[index] <= 0 then feedback("Out of stock. Use Restock to reset local counts."); return end
    if state.money < cost then feedback("Not enough demo money."); return end
    state.stocks[index] = state.stocks[index] - 1
    state.money = state.money - cost
    feedback("Stock reduced locally. No real item or currency changed.")
end
actions.Restock = function() state.stocks = {3, 5, 2, 1, 0, 1}; feedback("Demo stock reset. Mythical remains sold out.") end
actions.StarterPack = function()
    if state.starter then feedback("Starter Pack already claimed in this session."); return end
    state.starter = true
    feedback("Starter Pack marked claimed locally. No purchase or real inventory change.")
end
actions.ToggleSound = function()
    soundEnabled = not soundEnabled
    if not soundEnabled then for _, sound in pairs(sounds) do sound:Stop() end end
    feedback("Sound " .. (soundEnabled and "ON" or "OFF") .. ". Empty sound IDs remain silent.")
end
actions.AdjustVolume = function(button)
    volume = math.clamp(volume + button:GetAttribute("Delta"), 0, 1)
    for _, sound in pairs(sounds) do sound.Volume = volume end
    feedback("Local UI volume: " .. math.floor(volume * 100 + 0.5) .. "%")
end
actions.ToggleMotion = function()
    reducedMotion = not reducedMotion
    local openName = current and current.Name
    navigate(openName)
    for object, record in pairs(activeTweens) do
        record.connection:Disconnect()
        record.tween:Cancel()
        if object:IsA("UIScale") then object.Scale = 1 end
    end
    table.clear(activeTweens)
    feedback(reducedMotion and "Reduced motion enabled." or "Full motion enabled.")
end

local buttons = {}
for _, button in ipairs(gui:GetDescendants()) do
    if button:IsA("GuiButton") then
        local action = button:GetAttribute("StudsAction")
        local scale = button:FindFirstChild("InteractionScale")
        local hover, pressed = false, false
        local function draw()
            if scale then animate(scale, {Scale = pressed and 0.97 or (hover and 1.025 or 1)}, 0.09) end
        end
        local entry = {
            release = function() if pressed then pressed = false; draw() end end,
            reset = function() if hover or pressed then hover = false; pressed = false; draw() end end,
        }
        table.insert(buttons, entry)
        connect(button.MouseEnter, function() hover = true; draw(); play("Hover") end)
        connect(button.MouseLeave, function() hover = false; pressed = false; draw() end)
        connect(button.SelectionGained, function() hover = true; draw() end)
        connect(button.SelectionLost, function() hover = false; pressed = false; draw() end)
        connect(button.InputBegan, function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then pressed = true; draw() end
        end)
        connect(button.Activated, function()
            if not alive then return end
            pressed = false; draw(); play("Click")
            local fn = actions[action]
            if fn then fn(button); refresh() else feedback("This control is a visual demo.") end
        end)
    end
end
connect(UserInputService.InputEnded, function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        for _, entry in ipairs(buttons) do entry.release() end
    end
end)
connect(UserInputService.WindowFocusReleased, function() for _, entry in ipairs(buttons) do entry.reset() end end)

-- Local presentation API for integrations and automated Studio checks. No remotes.
local api = Instance.new("BindableFunction")
api.Name = "PreviewAction"
api.Parent = gui
api.OnInvoke = function(command, target)
    if command == "Open" then navigate(target)
    elseif command == "Close" then closePanel()
    elseif command == "Activate" then
        local button = find(target)
        assert(button and button:IsA("GuiButton"), "Unknown UI button")
        local action = actions[button:GetAttribute("StudsAction")]
        assert(action, "Unknown demo action")
        action(button)
        refresh()
    elseif command ~= "State" then error("Unknown preview command") end
    return {panel = current and current.Name or "", level = state.level, money = state.money, sound = soundEnabled, reducedMotion = reducedMotion}
end
gui:SetAttribute("ControllerReady", true)

refresh()
local function cleanup()
    if not alive then return end
    alive = false
    toastGeneration = toastGeneration + 1
    cancelTransition()
    for _, connection in ipairs(connections) do connection:Disconnect() end
    for _, record in pairs(activeTweens) do record.connection:Disconnect(); record.tween:Cancel() end
    for _, sound in pairs(sounds) do sound:Destroy() end
    table.clear(connections)
    table.clear(activeTweens)
    if api.Parent then api:Destroy() end
end
connect(gui.Destroying, cleanup)
connect(script.Destroying, cleanup)
