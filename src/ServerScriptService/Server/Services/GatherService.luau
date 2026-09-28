--[[
	SCRIPT NAME:  GatherService
	SCRIPT TYPE:  ModuleScript (server service)
	WHERE:        ServerScriptService/Server/Services/GatherService
	DEPENDENCIES: ResourceService, IslandService, ToolService, InventoryService, ProgressionService,
	              AnimationService, InteractionService, SoundService, VFXService,
	              Shared.Config.{ToolConfig, AnimationConfig, ResourceConfig}

	Server-authoritative gathering. HOLD the right tool and CLICK the node:
	  * trees / cacti need an Axe, rocks / ore a Pickaxe, clay a Shovel,
	    bushes and sand piles are picked by hand (empty hands or anything),
	  * better tiers are needed for iron, crystal and ancient trees,
	  * the swing animation plays for everyone and the hit lands on the
	    animation's impact marker (AnimationService.PerformAction),
	  * damage and drops come from ToolConfig / ResourceConfig on the server.
	Clicks are validated by InteractionService (range, owner/helper, cooldown).
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Shared
local ToolConfig = require(Shared.Config.ToolConfig)
local AnimationConfig = require(Shared.Config.AnimationConfig)
local R15 = require(Shared.Util.R15)

local Services = script.Parent
local ResourceService = require(Services.ResourceService)
local IslandService = require(Services.IslandService)
local ToolService = require(Services.ToolService)
local InventoryService = require(Services.InventoryService)
local ProgressionService = require(Services.ProgressionService)
local AnimationService = require(Services.AnimationService)
local InteractionService = require(Services.InteractionService)
local VFXService = require(Services.VFXService)
local Notify = require(script.Parent.Parent.Util.Notify)

local GatherService = {}

local random = Random.new()

local TOOL_ICONS = { Axe = "🪓", Pickaxe = "⛏️", Shovel = "🪏" }

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

-- Applies one hit and hands out drops if the node breaks.
local function applyHit(player: Player, node: any, tool: any)
	if node.Depleted or not player.Parent then
		return
	end
	local def = node.Def
	local damage = if tool then tool.Power * def.DamagePerPower else def.Health
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

-- Validates what the player holds and performs one gather action.
function GatherService.TryGather(player: Player, node: any)
	if node.Depleted then
		return
	end
	local island = IslandService.GetIslandById(node.IslandId)
	if not island or not IslandService.CanAccess(player, island, "Gather") then
		return
	end
	local def = node.Def
	local tool = nil
	if def.ToolType then
		tool = ToolService.GetHeldTool(player, def.ToolType)
		if not tool then
			local owned = ToolService.GetBestTool(player, def.ToolType)
			Notify.Error(player, if owned
				then ("Hold your %s %s to do that (pick it on your hotbar)."):format(TOOL_ICONS[def.ToolType] or "", def.ToolType)
				else ("You need a %s — buy one at the market."):format(def.ToolType))
			return
		end
		if tool.TierOrder < def.MinTier then
			Notify.Error(player, ("%s needs a %s %s or better."):format(def.DisplayName, tierName(def.MinTier), def.ToolType))
			return
		end
	end

	local animationName = if tool then tool.Animations.Use else (def.Animation or "PickCrop")
	local markerName = if tool then firstMarker(animationName) else def.Marker
	AnimationService.PerformAction(player, animationName, markerName, function()
		applyHit(player, node, tool)
	end, { Speed = if tool then tool.Speed else 1 })
end

function GatherService.Init()
	InteractionService.RegisterKind("ResourceNode", {
		Permission = "Gather",
		MaxDistance = 9,
		Cooldown = 0.2,
		Handler = function(player: Player, model: Instance)
			local node = ResourceService.GetNodeFromModel(model)
			if node then
				GatherService.TryGather(player, node)
			end
		end,
	})
end

return GatherService
