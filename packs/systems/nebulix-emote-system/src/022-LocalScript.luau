script.Parent.MouseButton1Click:Connect(function()
	local plr = game.Players.LocalPlayer
	local emotes = plr:WaitForChild("Emotes")
	
	script.Parent.Parent.Parent.Parent.Visible = false
	
	game.ReplicatedStorage:WaitForChild("Functions").ChangeStat:FireServer("Emotes", 
		emotes:FindFirstChild("Slot"..tostring(script.Parent.Parent.Parent.Parent.Slot.Value)),
		script.Parent.Parent.Name
		
	)
end)