--[[
	SCRIPT NAME:  VisitService
	SCRIPT TYPE:  ModuleScript (server service)
	WHERE:        ServerScriptService/Server/Services/VisitService
	DEPENDENCIES: DataService, IslandService, AntiExploitService, SoundService, Shared.Net,
	              Shared.Config.IslandConfig, Shared.Util.{R15, Validate}, Server.Util.Notify

	Multiplayer VISITING (spec §56-§58). Every player's island lives in the
	same server, so visiting is instant:

	  VisitRequest(userId)   teleport to that player's island spawn, if their
	                         visitor setting allows it (Everyone / Friends /
	                         Nobody). VisitRequest(0) = go home.
	  LikeRequest(userId)    like an island you're standing on, once per day.

	  * Visitors can look around, fish, and use the market stall. Gathering,
	    farming, animals and hammering need the owner to make them a HELPER.
	  * Players get attribute OnIsland = the owner's UserId of the island they
	    stand on (the HUD shows "Visiting X's island" + a Home button).
	  * If an owner leaves or locks their island, visitors are sent home.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Shared
local Net = require(Shared.Net)
local R15 = require(Shared.Util.R15)
local Validate = require(Shared.Util.Validate)

local Services = script.Parent
local DataService = require(Services.DataService)
local IslandService = require(Services.IslandService)
local AntiExploitService = require(Services.AntiExploitService)
local GameSoundService = require(Services.SoundService)
local VFXService = require(Services.VFXService)
local Notify = require(script.Parent.Parent.Util.Notify)

local VisitService = {}

local LOCATION_TICK = 1.5
local friendCache: { [string]: boolean } = {}
local visitedThisSession: { [Player]: { [number]: boolean } } = {}

local function areFriends(a: Player, b: Player): boolean
	local key = math.min(a.UserId, b.UserId) .. ":" .. math.max(a.UserId, b.UserId)
	local cached = friendCache[key]
	if cached ~= nil then
		return cached
	end
	local ok, result = pcall(a.IsFriendsWithAsync, a, b.UserId)
	local friends = ok and result == true
	friendCache[key] = friends
	return friends
end

function VisitService.CanVisit(visitor: Player, owner: Player): (boolean, string?)
	if visitor == owner then
		return true, nil
	end
	local mode = DataService.Get(owner, { "Island", "Access", "Visitors" }) or "Everyone"
	if mode == "Nobody" then
		return false, owner.DisplayName .. "'s island is closed to visitors."
	end
	local island = IslandService.GetIsland(owner)
	local helper = island ~= nil and IslandService.IsHelper(island, visitor.UserId)
	if mode == "Friends" and not helper and not areFriends(visitor, owner) then
		return false, owner.DisplayName .. "'s island is friends-only."
	end
	return true, nil
end

local function teleport(player: Player, cframe: CFrame)
	local character = player.Character
	if not character or not R15.IsAlive(character) then
		return
	end
	AntiExploitService.AllowTeleport(player)
	local offset = CFrame.new(math.random(-3, 3), 0, math.random(-3, 3))
	character:PivotTo(cframe * offset)
	VFXService.PlayAt("Sparkle", cframe.Position)
	GameSoundService.PlayFor(player, "UIOpen")
end

function VisitService.GoHome(player: Player)
	local spawn = IslandService.GetSpawnCFrame(player)
	if spawn then
		teleport(player, spawn)
	end
end

function VisitService.Visit(player: Player, userId: number): (boolean, string?)
	if userId == player.UserId then
		VisitService.GoHome(player)
		return true, nil
	end
	local owner = Players:GetPlayerByUserId(userId)
	local island = owner and IslandService.GetIsland(owner)
	if not owner or not island then
		return false, "That island isn't here right now."
	end
	local allowed, reason = VisitService.CanVisit(player, owner)
	if not allowed then
		return false, reason
	end
	teleport(player, island.SpawnCFrame)
	local visited = visitedThisSession[player]
	if not visited then
		visited = {}
		visitedThisSession[player] = visited
	end
	if not visited[userId] then
		visited[userId] = true
		DataService.Increment(owner, { "Island", "Visits" }, 1)
		DataService.Increment(player, { "Social", "IslandsVisited" }, 1)
		Notify.Toast(owner, ("%s is visiting your island! 👋"):format(player.DisplayName), "🏝️")
	end
	local name = DataService.Get(owner, { "Island", "Name" }) or (owner.DisplayName .. "'s Island")
	Notify.Banner(player, "WELCOME TO " .. string.upper(name), "Visiting " .. owner.DisplayName .. " · click their sign to ❤️ like it", "Reward")
	return true, nil
end

local function today(): number
	return os.time() // 86400
end

function VisitService.Like(player: Player, ownerUserId: number): (boolean, string?)
	if ownerUserId == player.UserId then
		return false, "You can't like your own island (but we're sure it's great)."
	end
	local owner = Players:GetPlayerByUserId(ownerUserId)
	if not owner or not IslandService.GetIsland(owner) then
		return false, nil
	end
	if player:GetAttribute("OnIsland") ~= ownerUserId then
		return false, "Visit the island to like it."
	end
	local key = tostring(ownerUserId)
	if DataService.Get(player, { "Social", "LikesGiven", key }) == today() then
		return false, "You already liked this island today ❤️"
	end
	DataService.Set(player, { "Social", "LikesGiven", key }, today())
	DataService.Increment(owner, { "Island", "Likes" }, 1)
	Notify.Success(player, "You liked " .. owner.DisplayName .. "'s island! ❤️", "❤️")
	Notify.Toast(owner, player.DisplayName .. " liked your island! ❤️", "❤️")
	GameSoundService.PlayFor(owner, "RareReward")
	return true, nil
end

-- Where is everybody? (attribute for the HUD + permission enforcement)
local function updateLocations()
	for _, player in Players:GetPlayers() do
		local root = R15.GetRootPart(player.Character)
		local island = root and IslandService.GetIslandAtPosition(root.Position)
		local ownerId = if island then island.OwnerUserId else 0
		if player:GetAttribute("OnIsland") ~= ownerId then
			player:SetAttribute("OnIsland", ownerId)
		end
		if island and island.Owner ~= player and island.Owner.Parent then
			local allowed = VisitService.CanVisit(player, island.Owner)
			if not allowed then
				Notify.Toast(player, island.Owner.DisplayName .. " closed their island — heading home.", "🏠")
				VisitService.GoHome(player)
			end
		end
	end
end

function VisitService.Init()
	Net.OnServerEvent("VisitRequest", function(player: Player, userId: any)
		if userId == 0 or userId == nil then
			VisitService.GoHome(player)
			return
		end
		if not Validate.Integer(userId, 1, 1e12) then
			AntiExploitService.Flag(player, "BadVisit", 2)
			return
		end
		local ok, message = VisitService.Visit(player, userId)
		if not ok and message then
			Notify.Error(player, message)
		end
	end)
	Net.OnServerEvent("LikeRequest", function(player: Player, userId: any)
		if not Validate.Integer(userId, 1, 1e12) then
			return
		end
		local ok, message = VisitService.Like(player, userId)
		if not ok and message then
			Notify.Error(player, message)
		end
	end)
end

function VisitService.Start()
	IslandService.IslandReleased:Connect(function(owner: Player)
		for _, player in Players:GetPlayers() do
			if player ~= owner and player:GetAttribute("OnIsland") == owner.UserId then
				Notify.Toast(player, owner.DisplayName .. " left — heading home.", "🏠")
				task.defer(VisitService.GoHome, player)
			end
		end
	end)
	Players.PlayerRemoving:Connect(function(player)
		visitedThisSession[player] = nil
	end)
	task.spawn(function()
		while true do
			task.wait(LOCATION_TICK)
			local ok, err = pcall(updateLocations)
			if not ok then
				warn("[VisitService] " .. tostring(err))
			end
		end
	end)
end

return VisitService
