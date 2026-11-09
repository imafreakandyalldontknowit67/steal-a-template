--[[
--- EMIT SCRIPT ---
1. You put bool values in blacklisted objects, make sure their name is the same as the blacklisted particle obj and the bool value is set to true
2. Attachments Only makes it so the script only looks for emitters in attachments
3. Turn Off Emitters makes it so the emitters are turned to false if they are affected by this script
4. EmissionValue is how many particles per loop there are gonna be spawned
5. Cooldown is the delay between each loop
6. Exclude Attachments makes it so attachments are skipped

CUSTOM: Put in particles which have a custom config - in numbervalues > their value will represent the emit amount
1. Put in Cooldown and Delay, not putting delay will still make it work - the default delay is 0
2. Cooldown must be inside as another number value, if it's -1 then the script will only emit the particle once >>> WORKS FOR NORMAL PARTICLES TOO
]]

local function AddEmitter(Emitter : ParticleEmitter)
	if script.ExcludeAttachments.Value == true and Emitter.Parent:IsA("Attachment") then return end
	if script.AttachmentsOnly.Value == true and not Emitter.Parent:IsA("Attachment") then return end
	local BlacklistedObj: BoolValue = script.BlacklistedObjects:FindFirstChild(Emitter.Name)
	if BlacklistedObj and BlacklistedObj.Value then return end
	
	if script.TurnOffEmitters.Value == true then
		Emitter.Enabled = false
	end
	
	local obj = script.Custom:FindFirstChild(Emitter.Name)
	task.spawn(function()
		if obj and obj:FindFirstChild("Delay") then
			task.wait(obj.Delay.Value)
		end
		while script.Parent do
			if obj and obj.Value > 0 and obj:FindFirstChild("Cooldown") then
				Emitter:Emit(obj.Value)
				if obj.Cooldown.Value == -1 then
					break
				else
					task.wait(script.Cooldown.Value)
				end
			else
				Emitter:Emit(script.EmissionValue.Value)
				if script.Cooldown.Value == -1 then
					break
				else
					task.wait(script.Cooldown.Value)
				end
			end
		end
	end)
end

for i,v in script.Parent:GetDescendants() do
	if v:IsA("ParticleEmitter") then
		AddEmitter(v)
	end
end