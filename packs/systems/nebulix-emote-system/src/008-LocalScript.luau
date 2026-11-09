local button = script.Parent
local UserInputService = game:GetService("UserInputService")


local function openList()
	button.Parent.ListHolder.Visible = true
	button.Parent.ListHolder.Slot.Value = 1
end

button.MouseButton2Click:Connect(openList)

button.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then

		local start = tick()

		local connection
		connection = UserInputService.InputEnded:Connect(function(endedInput)
			if endedInput == input then
				connection:Disconnect()
			end
		end)

		task.wait(0.55)

		if connection.Connected then
			connection:Disconnect()
			openList()
		end
	end
end)