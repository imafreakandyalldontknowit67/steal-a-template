--// Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TweenService = game:GetService("TweenService")

--// Variables
local animation = {}

local currentOpened: Frame?
local animating = false

--// Constants
local OPEN_TI = TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local CLOSE_TI = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local HIDE_POSITION = UDim2.fromScale(0.5, 1.5)

--// Functions
local function initFrame(frame: Frame)
    if animation[frame] == nil then
        animation[frame] = {
            Open = TweenService:Create(frame, OPEN_TI, {Position = UDim2.fromScale(0.5, 0.5)}),
            Close = TweenService:Create(frame, CLOSE_TI, {Position = HIDE_POSITION}),
        }
    end
end

local function fastclose()
    if currentOpened then
        currentOpened.Visible = false
		currentOpened = nil
    end
end

local function close()
    if animating or currentOpened == nil then
        return
    end

    animating = true

    if currentOpened and currentOpened:IsA("Frame") then
        animation[currentOpened].Close:Play()
        animation[currentOpened].Close.Completed:Wait()
    end

    fastclose()
    animating = false
end

local module = {}

function module.Open(frame: Frame, NoClose)
    if frame == currentOpened and not NoClose then
        close()
        return
    elseif NoClose and frame.Visible then
        return
    end
    
    if animating then
        return
    end

    animating = true

    initFrame(frame)
    fastclose()

    frame.Position = HIDE_POSITION
    frame.Visible = true
    currentOpened = frame

    animation[frame].Open:Play()
    animation[frame].Open.Completed:Wait()
   
    animating = false
end

module.Close = close
module.FastClose = fastclose
    
return module