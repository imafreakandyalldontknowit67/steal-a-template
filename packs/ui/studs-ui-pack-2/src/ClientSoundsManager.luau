--// Services
local SoundService = game:GetService("SoundService")

local module = {}

function module.PlaySFX(name: string)
    local sfxFolder = SoundService:FindFirstChild("SFX")
    local sound = sfxFolder and sfxFolder:FindFirstChild(name) :: Sound

    if sound then
        sound:Play()
    end
end

return module