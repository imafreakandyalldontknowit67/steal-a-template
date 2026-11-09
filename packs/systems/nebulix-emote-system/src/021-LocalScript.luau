script.Parent.Changed:Connect(function()
	local plr = game.Players.LocalPlayer
	local emotes = plr:WaitForChild("Emotes")
	
	for i,v in pairs(emotes:GetChildren()) do
		if v:IsA("NumberValue") and v.Value == 1 and v.Name ~= "PendingClaims" and v.Name ~= "KillReward" then
			if not script.Parent.EmoteList:FindFirstChild(v.Name) then
				local template = script.Parent.EmoteList.Template:Clone()
				template.Name = v.Name
				template.Title.Text = v.Name
				template.Visible = true
				template.Parent = script.Parent.EmoteList
			end
		end
	end
end)