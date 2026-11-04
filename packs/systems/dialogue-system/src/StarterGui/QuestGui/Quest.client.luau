local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local QuestConfig = require(ReplicatedStorage:WaitForChild("QuestConfig"))
local QuestRemotes = ReplicatedStorage:WaitForChild("QuestRemotes")
local QuestUpdate = QuestRemotes:WaitForChild("QuestUpdate")
local QuestAction = QuestRemotes:WaitForChild("QuestAction")

local player = Players.LocalPlayer
local gui = player:WaitForChild("PlayerGui"):WaitForChild("QuestGui")

local progressFrame = gui:WaitForChild("ProgressFrame")
local scrollingFrame = progressFrame:WaitForChild("ScrollingFrame")
local template = scrollingFrame:WaitForChild("Quest Temp")

template.Visible = false

local activeQuestFrames = {}

local function animateSlideIn(frame)
	local nameLabel = frame:FindFirstChild("Name")
	local line = frame:FindFirstChild("StrikethroughLine")

	if nameLabel then
		nameLabel.TextTransparency = 1
	end
	if line then
		line.BackgroundTransparency = 1
		line.Size = UDim2.new(0, 0, 0, line.Size.Y.Offset)
	end

	if nameLabel then
		TweenService:Create(nameLabel, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			TextTransparency = 0,
		}):Play()
	end
	if line then
		TweenService:Create(line, TweenInfo.new(0.35), {
			BackgroundTransparency = 0,
		}):Play()
	end
end

local function animateSlideOut(frame)
	local nameLabel = frame:FindFirstChild("Name")
	local line = frame:FindFirstChild("StrikethroughLine")

	if nameLabel then
		TweenService:Create(nameLabel, TweenInfo.new(0.25), {
			TextTransparency = 1,
		}):Play()
	end
	if line then
		TweenService:Create(line, TweenInfo.new(0.25), {
			BackgroundTransparency = 1,
		}):Play()
	end

	task.delay(0.27, function()
		if frame.Parent then
			frame:Destroy()
		end
	end)
end

local function update(snapshot)
	local quests = snapshot.Quests or {}
	local currentValidQuests = {}

	for questId, st in pairs(quests) do
		if not st.TurnedIn then
			currentValidQuests[questId] = true

			local qdef = QuestConfig.Quests[questId]
			if qdef then
				local obj = qdef.Objective or {}
				local req = obj.Required or 1
				local prog = st.Progress or 0
				local target = obj.Item or obj.Target or "Quest"

				local frame = activeQuestFrames[questId]
				if not frame then
					frame = template:Clone()
					frame.Name = questId
					frame.Visible = true
					frame.Parent = scrollingFrame
					activeQuestFrames[questId] = frame
					animateSlideIn(frame)
				end

				local nameLabel = frame:FindFirstChild("Name")
				local line = frame:FindFirstChild("StrikethroughLine")

				if nameLabel then
					nameLabel.Text = string.format("%s %d/%d", target, prog, req)
				end

				if st.Completed then
					if nameLabel then
						nameLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
						local bounds = nameLabel.TextBounds.X
						if line then
							line.AnchorPoint = Vector2.new(0, 0.5)
							line.Position = UDim2.new(0, 0, 0.5, 0)
							line.BackgroundTransparency = 0
							TweenService:Create(line, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
								Size = UDim2.new(0, bounds + 6, 0, line.Size.Y.Offset),
							}):Play()
						end
					end
				else
					if nameLabel then
						nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
					end
					if line then
						TweenService:Create(line, TweenInfo.new(0.25), {
							Size = UDim2.new(0, 0, 0, line.Size.Y.Offset),
						}):Play()
					end
				end
			end
		end
	end

	for questId, frame in pairs(activeQuestFrames) do
		if not currentValidQuests[questId] then
			animateSlideOut(frame)
			activeQuestFrames[questId] = nil
		end
	end
end

local ok, snap = pcall(function()
	return QuestAction:InvokeServer("Get")
end)

if ok and snap then
	update(snap)
end

QuestUpdate.OnClientEvent:Connect(update)
