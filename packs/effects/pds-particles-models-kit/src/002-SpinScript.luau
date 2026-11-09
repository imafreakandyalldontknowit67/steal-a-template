--[[------------------------------------------------------------
--> You can put this either in a model, a part or an attachment, if it's in a model it will make all the parts inside the model spin.

--> You will also be able to switch through 2 modes in the configuration:
	1. Part Mode, only tweens parts and excludes attachments
	2. Attachment Mode, only tweens attachments and excludes parts
]]


local Part = script.Parent
local TweenService = game:GetService("TweenService")
local Trajectory = script.SpinTrajectory.Value

local TweenInfo1 = TweenInfo.new(
	script.SpinDuration.Value,							-- Tween Length
	Enum.EasingStyle[script.TweenEasingStyle.Value or "Linear"],		-- Easing Style (Animation Style)
	Enum.EasingDirection[script.TweenEasingDirection.Value or "InOut"],		-- Easing Direction
	-1,								-- Times repeated (0 is play once, -1 is infinite loop)
	script.ReverseTweenOnFinish.Value,							-- Reverse
	0								-- Delay
)

if (Part:IsA("BasePart") and not script.AttachmentMode.Value) or Part:IsA("Attachment") then
	TweenService:Create(Part,TweenInfo1,{Orientation = Part.Orientation + Trajectory}):Play()
elseif Part:IsA("Model") or (Part:IsA("BasePart") and script.AttachmentMode.Value) then
	for i,v in Part:GetDescendants() do
		if v:IsA("BasePart") and not script.AttachmentMode.Value then
			TweenService:Create(v,TweenInfo1,{Orientation = v.Orientation + Trajectory}):Play()
		elseif v:IsA("Attachment") and script.AttachmentMode.Value then
			TweenService:Create(v,TweenInfo1,{Orientation = v.Orientation + Trajectory}):Play()
		end
	end
end