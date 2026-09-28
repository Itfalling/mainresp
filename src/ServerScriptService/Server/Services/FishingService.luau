--[[
	SCRIPT NAME:  FishingService
	SCRIPT TYPE:  ModuleScript (server service)
	WHERE:        ServerScriptService/Server/Services/FishingService
	DEPENDENCIES: DataService, IslandService, ToolService, InventoryService, ProgressionService,
	              AnimationService, InteractionService, AntiExploitService, SoundService, VFXService,
	              Server.Island.IslandProps, Shared.Net, Shared.Config.{FishConfig, RarityConfig},
	              Shared.Util.IslandContent

	Skill-based, server-authoritative fishing (spec §29-§32, §61, §143):

	  Cast   FishingRequest{Op="Cast"} or the spot's "[E] Fish" prompt.
	         Server checks: rod owned (auto-equips it), near a fishing spot,
	         not already fishing, cooldown. It rolls the fish NOW (weighted by
	         zone + rarity + rod luck) and a bite time — the client never knows
	         which fish it is.
	  Bite   at the bite time the server sends FishingEvent{Op="Bite"}. The
	         player has HookWindow seconds to press USE (FishingRequest Hook).
	  Reel   the client plays the reel minigame; the server only reveals the
	         rarity. The client reports Success/Fail; a success faster than
	         FishConfig.MinReelTime(difficulty) is rejected as impossible.
	  Catch  the server grants the fish, records the collection + stats, XP.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Shared
local Net = require(Shared.Net)
local FishConfig = require(Shared.Config.FishConfig)
local RarityConfig = require(Shared.Config.RarityConfig)
local IslandContent = require(Shared.Util.IslandContent)
local Signal = require(Shared.Util.Signal)
local R15 = require(Shared.Util.R15)

local Services = script.Parent
local DataService = require(Services.DataService)
local IslandService = require(Services.IslandService)
local ToolService = require(Services.ToolService)
local InventoryService = require(Services.InventoryService)
local ProgressionService = require(Services.ProgressionService)
local AnimationService = require(Services.AnimationService)
local InteractionService = require(Services.InteractionService)
local AntiExploitService = require(Services.AntiExploitService)
local GameSoundService = require(Services.SoundService)
local VFXService = require(Services.VFXService)
local IslandProps = require(script.Parent.Parent.Island.IslandProps)
local Notify = require(script.Parent.Parent.Util.Notify)

local HOOK_LATENCY = 0.4 -- network grace on top of the hook window
local LEASH = 26 -- walking this far from the spot cancels fishing

type Spot = { Id: string, Zone: string, Position: Vector3, Model: Model, IslandId: string }
type Session = {
	Stage: string, -- "Waiting" | "Bite" | "Reeling"
	FishId: string,
	Spot: Spot,
	Rod: any,
	BiteAt: number,
	HookDeadline: number,
	ReelStartedAt: number,
	Token: number,
}

local FishingService = {}

FishingService.FishCaught = Signal.new() -- (player, fishId, rarity, weight)

local spotsByIsland: { [string]: { Spot } } = {}
local sessions: { [Player]: Session } = {}
local lastCast: { [Player]: number } = setmetatable({}, { __mode = "k" }) :: any
local tokenCounter = 0
local random = Random.new()

local function send(player: Player, payload: { [string]: any })
	Net.FireClient("FishingEvent", player, payload)
end

local function nearestSpot(player: Player): Spot?
	local root = R15.GetRootPart(player.Character)
	if not root then
		return nil
	end
	local best, bestDistance = nil, FishConfig.SpotRange
	for _, spots in spotsByIsland do
		for _, spot in spots do
			local island = IslandService.GetIslandById(spot.IslandId)
			if island and IslandService.CanAccess(player, island, "Fish") then
				local distance = (root.Position - spot.Position).Magnitude
				if distance <= bestDistance then
					best, bestDistance = spot, distance
				end
			end
		end
	end
	return best
end

local function rollFish(zone: string, rod: any): string?
	local zoneDef = FishConfig.Zones[zone]
	if not zoneDef then
		return nil
	end
	local luck = 1 + (rod.TierOrder - 1) * FishConfig.RodLuckPerTier
	local total = 0
	local weights = {}
	for _, fishId in zoneDef.Fish do
		local fish = FishConfig.Fish[fishId]
		local rank = RarityConfig.Get(fish.Rarity).Rank
		local weight = (FishConfig.RarityWeights[fish.Rarity] or 1) * luck ^ (rank - 1)
		weights[fishId] = weight
		total += weight
	end
	local roll = random:NextNumber(0, total)
	for _, fishId in zoneDef.Fish do
		roll -= weights[fishId]
		if roll <= 0 then
			return fishId
		end
	end
	return zoneDef.Fish[1]
end

local function endSession(player: Player, reason: string?, animation: string?)
	local session = sessions[player]
	if not session then
		return
	end
	sessions[player] = nil
	local character = player.Character
	if character then
		AnimationService.StopAnimation(character, "FishingWait")
		AnimationService.StopAnimation(character, "FishingReel")
		if animation then
			AnimationService.PlayAnimation(character, animation)
		end
	end
	if reason then
		send(player, { Op = "End", Reason = reason })
	end
end

local function stillValid(player: Player, session: Session): boolean
	if sessions[player] ~= session or not player.Parent then
		return false
	end
	local root = R15.GetRootPart(player.Character)
	if not root or (root.Position - session.Spot.Position).Magnitude > LEASH then
		endSession(player, "You walked away from the water.")
		return false
	end
	local equipped = ToolService.GetEquipped(player)
	if not equipped or equipped.Type ~= "FishingRod" then
		endSession(player, "You put your rod away.")
		return false
	end
	return true
end

function FishingService.Cast(player: Player)
	if sessions[player] then
		return
	end
	local now = os.clock()
	if lastCast[player] and now - lastCast[player] < FishConfig.CastCooldown then
		return
	end
	local spot = nearestSpot(player)
	if not spot then
		Notify.Error(player, "Find a 🎣 fishing spot first (try the end of your dock).")
		return
	end
	local rod = ToolService.EquipBestOfType(player, "FishingRod")
	if not rod then
		Notify.Error(player, "You need a Fishing Rod.")
		return
	end
	local fishId = rollFish(spot.Zone, rod)
	if not fishId then
		return
	end
	lastCast[player] = now

	tokenCounter += 1
	local delayRange = FishConfig.BiteDelay
	local biteDelay = random:NextNumber(delayRange.Min, delayRange.Max) / (1 + (rod.TierOrder - 1) * 0.15)
	local session: Session = {
		Stage = "Waiting",
		FishId = fishId,
		Spot = spot,
		Rod = rod,
		BiteAt = now + biteDelay,
		HookDeadline = 0,
		ReelStartedAt = 0,
		Token = tokenCounter,
	}
	sessions[player] = session

	local character = player.Character
	AnimationService.PerformAction(player, "FishingCast", "Cast", function()
		if sessions[player] == session and character then
			AnimationService.PlayAnimation(character, "FishingWait")
		end
	end, { Speed = rod.Speed })
	send(player, { Op = "Cast", Spot = spot.Position, Zone = spot.Zone })

	task.delay(biteDelay, function()
		if not stillValid(player, session) or session.Stage ~= "Waiting" then
			return
		end
		session.Stage = "Bite"
		session.HookDeadline = os.clock() + FishConfig.HookWindow + HOOK_LATENCY
		if character then
			AnimationService.PlayAnimation(character, "FishingBite")
		end
		GameSoundService.PlayAt("FishBite", spot.Position)
		send(player, { Op = "Bite", Window = FishConfig.HookWindow })
		task.delay(FishConfig.HookWindow + HOOK_LATENCY + 0.1, function()
			if sessions[player] == session and session.Stage == "Bite" then
				GameSoundService.PlayFor(player, "FishEscape")
				endSession(player, "Too slow — the fish got away!", "FishingFail")
			end
		end)
	end)
end

local function hook(player: Player)
	local session = sessions[player]
	if not session then
		return
	end
	if session.Stage == "Waiting" then
		-- Pulled too early: the fish is scared off.
		endSession(player, "Too early! Wait for the bite (!) before reeling.", "FishingFail")
		return
	end
	if session.Stage ~= "Bite" or not stillValid(player, session) then
		return
	end
	if os.clock() > session.HookDeadline then
		endSession(player, "Too slow — the fish got away!", "FishingFail")
		return
	end
	local fish = FishConfig.Fish[session.FishId]
	session.Stage = "Reeling"
	session.ReelStartedAt = os.clock()
	local character = player.Character
	if character then
		AnimationService.PlayAnimation(character, "FishingReel")
	end
	-- Only the rarity and difficulty are revealed — never the fish itself.
	local difficulty = math.max(1, fish.Difficulty - (session.Rod.TierOrder - 1) * 0.25)
	send(player, { Op = "Reel", Rarity = fish.Rarity, Difficulty = difficulty, Token = session.Token })

	task.delay(FishConfig.MaxReelTime, function()
		if sessions[player] == session and session.Stage == "Reeling" then
			endSession(player, "The line went slack...", "FishingFail")
		end
	end)
end

local function finishReel(player: Player, success: boolean, token: any)
	local session = sessions[player]
	if not session or session.Stage ~= "Reeling" or token ~= session.Token then
		return
	end
	if not stillValid(player, session) then
		return
	end
	if not success then
		GameSoundService.PlayFor(player, "FishEscape")
		endSession(player, "It got away! Keep the fish inside the zone.", "FishingFail")
		return
	end
	local fish = FishConfig.Fish[session.FishId]
	local difficulty = math.max(1, fish.Difficulty - (session.Rod.TierOrder - 1) * 0.25)
	local elapsed = os.clock() - session.ReelStartedAt
	if elapsed < FishConfig.MinReelTime(difficulty) then
		AntiExploitService.Flag(player, "ImpossibleReel", 4)
		endSession(player, "The fish slipped off the hook.", "FishingFail")
		return
	end

	sessions[player] = nil
	local character = player.Character
	if character then
		AnimationService.StopAnimation(character, "FishingReel")
		AnimationService.StopAnimation(character, "FishingWait")
	end
	local added = InventoryService.AddItem(player, session.FishId, 1, "Fishing")
	if added <= 0 then
		send(player, { Op = "End", Reason = "Your backpack is full — sell some items first." })
		return
	end
	local weight = math.floor(random:NextNumber(fish.Weight[1], fish.Weight[2]) * 10 + 0.5) / 10
	local rarity = RarityConfig.Get(fish.Rarity)
	local collection = DataService.Get(player, { "Collection", "Fish", session.FishId })
	local isNew = collection == nil
	local best = if type(collection) == "table" then math.max(collection.BestWeight or 0, weight) else weight
	local count = if type(collection) == "table" then (collection.Count or 0) + 1 else 1
	DataService.Set(player, { "Collection", "Fish", session.FishId }, { Count = count, BestWeight = best })
	DataService.Increment(player, { "Stats", "FishCaught" }, 1)
	if rarity.Rank >= 3 then
		DataService.Increment(player, { "Stats", "RareItemsFound" }, 1)
	end

	if character then
		AnimationService.PlayAnimation(character, if rarity.Rank >= 4 then "FishingCelebrate" else "FishingCatch")
	end
	VFXService.PlayAt("WaterSplash", session.Spot.Position + Vector3.new(0, 1, 0))
	if rarity.Rank >= 3 then
		VFXService.PlayAt("Sparkle", session.Spot.Position + Vector3.new(0, 3, 0))
	end
	GameSoundService.PlayFor(player, if rarity.Rank >= 4 then "RareReward" else "FishCatch")
	ProgressionService.Award(player, "CatchFish", rarity.Rank)
	send(player, { Op = "Caught", FishId = session.FishId, Weight = weight, New = isNew })
	FishingService.FishCaught:Fire(player, session.FishId, fish.Rarity, weight)
end

local function spawnSpots(player: Player, island: any)
	local unlocked = IslandService.GetUnlockedAreas(player)
	local list = spotsByIsland[island.Id]
	if not list then
		list = {}
		spotsByIsland[island.Id] = list
	end
	for _, spotDef in IslandContent.FishingSpots() do
		local already = false
		for _, existing in list do
			if existing.Id == spotDef.Id then
				already = true
				break
			end
		end
		if unlocked[spotDef.AreaId] and not already then
			local worldCFrame = if spotDef.OnDock
				then island.Origin * CFrame.new(spotDef.Position.X, 2.4, spotDef.Position.Y)
				else IslandService.GetGroundCFrame(island, spotDef.Position)
			local zone = FishConfig.Zones[spotDef.Zone]
			local model = IslandProps.FishingSpot(if zone then zone.DisplayName else spotDef.Zone)
			model:PivotTo(worldCFrame)
			model:SetAttribute("FishingZone", spotDef.Zone)
			model:SetAttribute("OwnerUserId", island.OwnerUserId)
			model.Parent = island.Folders.FishingSpots
			local spot: Spot = { Id = spotDef.Id, Zone = spotDef.Zone, Position = worldCFrame.Position, Model = model, IslandId = island.Id }
			table.insert(list, spot)
			InteractionService.Attach(model, "FishingSpot", { ObjectText = if zone then zone.DisplayName else "Fishing Spot", OwnerUserId = island.OwnerUserId })
		end
	end
end

function FishingService.IsFishing(player: Player): boolean
	return sessions[player] ~= nil
end

function FishingService.Init()
	InteractionService.RegisterKind("FishingSpot", {
		ActionText = "Fish",
		ObjectText = "Fishing Spot",
		Permission = "Fish",
		MaxDistance = 10,
		Cooldown = 0.5,
		Handler = function(player: Player)
			FishingService.Cast(player)
		end,
	})

	Net.OnServerEvent("FishingRequest", function(player: Player, payload: any)
		if type(payload) ~= "table" then
			AntiExploitService.Flag(player, "BadFishingRequest", 2)
			return
		end
		if payload.Op == "Cast" then
			FishingService.Cast(player)
		elseif payload.Op == "Hook" then
			hook(player)
		elseif payload.Op == "Reel" then
			finishReel(player, payload.Success == true, payload.Token)
		elseif payload.Op == "Cancel" then
			endSession(player, nil)
		end
	end)
end

function FishingService.Start()
	IslandService.IslandAssigned:Connect(spawnSpots)
	IslandService.AreaUnlocked:Connect(function(player: Player)
		local island = IslandService.GetIsland(player)
		if island then
			spawnSpots(player, island)
		end
	end)
	IslandService.IslandReleased:Connect(function(_player: Player, islandId: string)
		spotsByIsland[islandId] = nil
	end)
	game:GetService("Players").PlayerRemoving:Connect(function(player)
		sessions[player] = nil
	end)
end

return FishingService
