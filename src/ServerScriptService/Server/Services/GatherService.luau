--[[
	SCRIPT NAME:  GatherService
	SCRIPT TYPE:  ModuleScript (server service)
	WHERE:        ServerScriptService/Server/Services/GatherService
	DEPENDENCIES: ResourceService, IslandService, ToolService, InventoryService, ProgressionService,
	              AnimationService, InteractionService, AntiExploitService, SoundService, VFXService,
	              Shared.Net, Shared.Config.{ToolConfig, AnimationConfig, ResourceConfig}

	Server-authoritative gathering (spec §15-§17, §103). Two ways to hit a node:
	  1. PROMPT  "[E] Chop Oak Tree": the server equips your best axe, plays the
	     swing on your client and applies the hit at the animation's Hit marker.
	  2. SWING   click with a tool equipped: your client plays the swing and, at
	     the Hit marker, sends GatherRequest(nodeId). The server re-checks
	     everything (owner, distance, tool type/tier, swing cooldown).
	The client never says how much it gathered — damage and drops come from
	ToolConfig / ResourceConfig on the server.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Shared
local Net = require(Shared.Net)
local ToolConfig = require(Shared.Config.ToolConfig)
local AnimationConfig = require(Shared.Config.AnimationConfig)
local R15 = require(Shared.Util.R15)
local Validate = require(Shared.Util.Validate)

local Services = script.Parent
local ResourceService = require(Services.ResourceService)
local IslandService = require(Services.IslandService)
local ToolService = require(Services.ToolService)
local InventoryService = require(Services.InventoryService)
local ProgressionService = require(Services.ProgressionService)
local AnimationService = require(Services.AnimationService)
local InteractionService = require(Services.InteractionService)
local AntiExploitService = require(Services.AntiExploitService)
local GameSoundService = require(Services.SoundService)
local VFXService = require(Services.VFXService)
local Notify = require(script.Parent.Parent.Util.Notify)

local SWING_RANGE = 13
local PROMPT_RANGE = 16

local GatherService = {}

local lastHit: { [Player]: number } = setmetatable({}, { __mode = "k" }) :: any
local random = Random.new()

local function firstMarker(animationName: string?): string?
	local def = animationName and AnimationConfig.Get(animationName)
	if not def then
		return nil
	end
	for markerName in def.Markers do
		return markerName
	end
	return nil
end

local function tierName(order: number): string
	for tierId, tier in ToolConfig.Tiers do
		if tier.Order == order then
			return tierId
		end
	end
	return "better"
end

local function inRange(player: Player, node: any, range: number): boolean
	local root = R15.GetRootPart(player.Character)
	if not root then
		return false
	end
	local offset = root.Position - ResourceService.GetPosition(node)
	return Vector3.new(offset.X, 0, offset.Z).Magnitude <= range
end

-- Applies one hit and hands out drops if the node breaks.
local function applyHit(player: Player, node: any, tool: any)
	if node.Depleted or not player.Parent then
		return
	end
	local def = node.Def
	local position = ResourceService.GetPosition(node)
	local damage = if tool then tool.Power * def.DamagePerPower else def.Health
	if def.HitSound then
		GameSoundService.PlayAt(def.HitSound, position)
	end
	if def.HitVFX then
		VFXService.PlayAt(def.HitVFX, position + Vector3.new(0, 2, 0))
	end
	if def.Shake then
		VFXService.ShakeCamera(player, def.Shake, 0.2)
	end

	local root = R15.GetRootPart(player.Character)
	local broke = ResourceService.Damage(node, damage, root and root.Position)
	if not broke then
		return
	end

	local amount = random:NextInteger(def.Drops.Min, def.Drops.Max)
	if tool and tool.ResourceBonus > 0 and random:NextNumber() < tool.ResourceBonus then
		amount += 1
	end
	InventoryService.AddItem(player, def.Resource, amount, "Gather:" .. node.Type)
	ProgressionService.Award(player, def.XPSource)
end

-- Validates and performs a gather attempt. source = "Prompt" | "Swing".
function GatherService.TryGather(player: Player, node: any, source: string)
	if node.Depleted then
		return
	end
	local island = IslandService.GetIslandById(node.IslandId)
	if not island or not IslandService.CanAccess(player, island, "Gather") then
		AntiExploitService.Flag(player, "GatherForeignNode", 1)
		return
	end
	if not inRange(player, node, if source == "Prompt" then PROMPT_RANGE else SWING_RANGE) then
		AntiExploitService.Flag(player, "GatherTooFar", 1)
		return
	end

	local def = node.Def
	local tool = nil
	if def.ToolType then
		tool = if source == "Prompt" then ToolService.EquipBestOfType(player, def.ToolType) else ToolService.GetEquipped(player)
		if not tool or tool.Type ~= def.ToolType then
			local owned = ToolService.GetBestTool(player, def.ToolType)
			Notify.Error(player, if owned then ("Equip your %s to do that."):format(def.ToolType) else ("You need a %s — buy one at the market."):format(def.ToolType))
			return
		end
		if tool.TierOrder < def.MinTier then
			Notify.Error(player, ("%s needs a %s %s or better."):format(def.DisplayName, tierName(def.MinTier), def.ToolType))
			return
		end
	end

	-- Swing-speed limit shared by both paths.
	local now = os.clock()
	local interval = if tool then tool.UseCooldown * 0.75 else 0.5
	if lastHit[player] and now - lastHit[player] < interval then
		return
	end
	lastHit[player] = now

	if source == "Swing" then
		applyHit(player, node, tool)
		return
	end

	local animationName = if tool then tool.Animations.Use else def.Animation
	local markerName = if tool then firstMarker(animationName) else def.Marker
	AnimationService.PerformAction(player, animationName or "PickCrop", markerName, function()
		applyHit(player, node, tool)
	end, { Speed = if tool then tool.Speed else 1 })
end

function GatherService.Init()
	InteractionService.RegisterKind("ResourceNode", {
		ActionText = "Gather",
		Permission = "Gather",
		MaxDistance = 11,
		Cooldown = 0.2,
		Handler = function(player: Player, model: Instance)
			local node = ResourceService.GetNodeFromModel(model)
			if node then
				GatherService.TryGather(player, node, "Prompt")
			end
		end,
	})

	Net.OnServerEvent("GatherRequest", function(player: Player, nodeId: any)
		if not Validate.String(nodeId, 120) then
			AntiExploitService.Flag(player, "BadGatherRequest", 2)
			return
		end
		local node = ResourceService.GetNode(nodeId)
		if not node then
			return
		end
		GatherService.TryGather(player, node, "Swing")
	end)
end

return GatherService
