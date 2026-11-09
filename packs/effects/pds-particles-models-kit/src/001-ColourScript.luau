--[[------------------------------------------------------------
--> You can put this either in a model or a part, if it's in a model it will make all the parts inside the model change colour.
--> To create a colour point you have to duplicate the final guideline in the folder of guidelines and change its name to the current number +1
--> You can also put this scripts in particles, or on the parent of a part / model and say "IgnoreParts"

-- Upd 1
--> You can also put it in lights now
]]


local Part = script.Parent
local TweenService = game:GetService("TweenService")

local Info = TweenInfo.new(
	script.Speed.Value,
	Enum.EasingStyle[script.TweenEasingStyle.Value or "Linear"],
	Enum.EasingDirection[script.TweenEasingDirection.Value or "InOut"],
	0,
	false,
	0
)

local function MakeTween(Part)
	task.spawn(function()
		if Part:IsA("ParticleEmitter") then
			while task.wait() do
				for Index, Colour in script.ColourGuidelines:GetChildren() do
					TweenService:Create(Part, Info, {Color = ColorSequence.new(script.ColourGuidelines[Index].Value)}):Play()
					task.wait(script.Speed.Value)
				end
			end
		elseif Part:IsA("BasePart") or Part:IsA("Light") and not script.IgnoreParts.Value then
			while task.wait() do
				for Index, Colour in script.ColourGuidelines:GetChildren() do
					TweenService:Create(Part, Info, {Color = script.ColourGuidelines[Index].Value}):Play()
					task.wait(script.Speed.Value)
				end
			end
		end
	end)
end

repeat task.wait(1) until script:IsDescendantOf(workspace)
if script.Parent:IsA("BasePart") then
	if script.IgnoreParts.Value then
		for i,v in script.Parent:GetDescendants() do
			MakeTween(v)
		end
	else
		MakeTween(script.Parent)
	end
elseif script.Parent:IsA("ParticleEmitter") then
	MakeTween(script.Parent)
elseif script.Parent:IsA("Model") then
	for i,v in script.Parent:GetDescendants() do
		MakeTween(v)
	end
elseif script.Parent:IsA("Light") then
	MakeTween(script.Parent)
end