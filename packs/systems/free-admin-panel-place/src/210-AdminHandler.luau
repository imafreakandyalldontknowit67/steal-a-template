local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Get RemoteEvents
local AdminPanelRemote = ReplicatedStorage:WaitForChild("AdminPanelRemote")
local KickPlayerEvent = AdminPanelRemote:WaitForChild("KickPlayer")
local BanPlayerEvent = AdminPanelRemote:WaitForChild("BanPlayer")
local GlobalAnnounceEvent = AdminPanelRemote:WaitForChild("GlobalAnnounce")

-- Simple ban management (in-memory for this demo)
local BannedPlayers = {}
local BanDataStore -- Optional: Enable persistent bans by setting up DataStore

--[[
	Helper function to find a player by username (case-insensitive)
	Returns the Player object if found, nil otherwise
]]
local function findPlayerByUsername(username)
	for _, player in Players:GetPlayers() do
		if string.lower(player.Name) == string.lower(username) then
			return player
		end
	end
	return nil
end

--[[
	Process a kick command
	@param adminPlayer: Player who issued the command (for logging)
	@param targetUsername: Username of player to kick
	@param duration: Not used for kick, but kept for consistency
]]
local function processKick(adminPlayer, targetUsername, duration)
	local targetPlayer = findPlayerByUsername(targetUsername)
	
	if not targetPlayer then
		warn("[AdminPanel] Kick failed: Player '" .. targetUsername .. "' not found")
		return false, "Player not found"
	end
	
	-- Kick the player with a reason
	local reason = "Kicked by admin"
	if duration and duration ~= "" then
		reason = reason .. ": " .. duration
	end
	
	targetPlayer:Kick(reason)
	print("[AdminPanel] " .. (adminPlayer and adminPlayer.Name or "Console") .. " kicked " .. targetUsername .. " - Reason: " .. duration)
	return true, "Player kicked successfully"
end

--[[
	Process a ban command
	@param adminPlayer: Player who issued the command
	@param targetUsername: Username of player to ban
	@param duration: Duration string (e.g., "1d", "7d", "perm")
]]
local function processBan(adminPlayer, targetUsername, duration)
	local targetPlayer = findPlayerByUsername(targetUsername)
	
	if not targetPlayer then
		warn("[AdminPanel] Ban failed: Player '" .. targetUsername .. "' not found")
		return false, "Player not found"
	end
	
	-- Parse duration
	local banLength = 0
	local isPermanent = false
	
	if string.lower(duration) == "perm" or string.lower(duration) == "permanent" then
		isPermanent = true
	else
		-- Parse duration like "1d", "7d", "1h", etc.
		local num = tonumber(string.match(duration, "^(%d+)"))
		local unit = string.match(duration, "^%d+(%a+)")
		
		if num and unit then
			if unit == "d" or unit == "day" or unit == "days" then
				banLength = num * 24 * 60 * 60 -- days to seconds
			elseif unit == "h" or unit == "hour" or unit == "hours" then
				banLength = num * 60 * 60 -- hours to seconds
			elseif unit == "m" or unit == "min" or unit == "mins" or unit == "minute" or unit == "minutes" then
				banLength = num * 60 -- minutes to seconds
			else
				-- Default to days if unit unrecognized
				banLength = num * 24 * 60 * 60
			end
		else
			-- If duration format is unclear, default to 1 day
			banLength = 24 * 60 * 60
		end
	end
	
	-- Add to ban list (in-memory)
	BannedPlayers[targetPlayer.UserId] = {
		userId = targetPlayer.UserId,
		username = targetPlayer.Name,
		isPermanent = isPermanent,
		expiresAt = isPermanent and nil or (os.time() + banLength),
		bannedBy = adminPlayer and adminPlayer.Name or "Console",
		reason = "Banned by admin"
	}
	
	-- Kick immediately with ban message
	targetPlayer:Kick("You have been banned for: " .. (duration or "no duration specified"))
	
	local banMsg = isPermanent and "permanently" or "for " .. duration
	print("[AdminPanel] " .. (adminPlayer and adminPlayer.Name or "Console") .. " banned " .. targetUsername .. " " .. banMsg)
	return true, "Player banned successfully"
end

--[[
	Process a global announcement
	@param message: Announcement message to broadcast
]]
local function processGlobalAnnounce(message)
	if not message or message == "" then
		return false, "Message cannot be empty"
	end
	
	-- Fire the announcement to all players
	GlobalAnnounceEvent:FireAllClients(message)
	print("[AdminPanel] Global announcement sent: " .. message)
	return true, "Announcement sent"
end

--[[
	Player joining check - prevent banned players from joining
]]
local function onPlayerAdded(player)
	-- Check if player is banned
	local banData = BannedPlayers[player.UserId]
	
	if banData then
		if banData.isPermanent then
			player:Kick("You are permanently banned from this game.")
			return
		elseif banData.expiresAt and os.time() > banData.expiresAt then
			-- Ban expired, remove from list
			BannedPlayers[player.UserId] = nil
		else
			-- Still banned, kick
			player:Kick("You are banned. Time remaining: " .. tostring(math.ceil((banData.expiresAt - os.time()) / 60)) .. " minutes")
			return
		end
	end
end

-- Connect PlayerAdded event
Players.PlayerAdded:Connect(onPlayerAdded)

-- ============================================
-- RemoteEvent Handlers
-- ============================================

KickPlayerEvent.OnServerEvent:Connect(function(adminPlayer, targetUsername, duration)
	-- Optional: Add permission check here (e.g., check if adminPlayer is in admin list)
	-- For this demo, we'll allow anyone to use it
	
	local success, message = processKick(adminPlayer, targetUsername, duration)
	
	-- Send feedback back to admin
	-- Could use a separate RemoteEvent to send response
end)

BanPlayerEvent.OnServerEvent:Connect(function(adminPlayer, targetUsername, duration)
	local success, message = processBan(adminPlayer, targetUsername, duration)
end)

GlobalAnnounceEvent.OnServerEvent:Connect(function(adminPlayer, message)
	local success, message = processGlobalAnnounce(message)
end)

--[[
	NOTE: For production use, you should:
	1. Add an admin permission system (check if player has admin rights)
	2. Use DataStore to persist bans across server sessions
	3. Log all admin actions to a DataStore or external service
	4. Add rate limiting to prevent abuse
	5. Validate inputs more thoroughly
]]

print("[AdminPanel] AdminHandler loaded successfully")
