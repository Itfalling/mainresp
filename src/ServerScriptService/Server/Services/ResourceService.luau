--[[
	SCRIPT NAME:  ResourceService
	SCRIPT TYPE:  ModuleScript (server service)
	WHERE:        ServerScriptService/Server/Services/ResourceService
	DEPENDENCIES: IslandService, InteractionService, VFXService, SoundService,
	              Server.Island.NodeModels, Shared.Config.ResourceConfig, Shared.Util.IslandContent

	Owns resource NODES (trees, rocks, bushes, ore...) on every island.
	  * Spawns each unlocked area's nodes at deterministic spots
	    (Shared/Util/IslandContent) when an island loads or an area unlocks.
	  * POOLED (spec §115): a broken node is hidden, not destroyed, and
	    regrows after its Respawn time in the same Model.
	  * Tracks health on the server; clients read the Health attribute for
	    health bars. GatherService decides WHO may hit a node and what they get.

	Node attributes: NodeId, NodeType, Health, MaxHealth, Depleted, OwnerUserId.
	CollectionService tag: "ResourceNode".
]]

local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Shared = ReplicatedStorage.Shared
local ResourceConfig = require(Shared.Config.ResourceConfig)
local IslandContent = require(Shared.Util.IslandContent)
local Signal = require(Shared.Util.Signal)

local Services = script.Parent
local IslandService = require(Services.IslandService)
local InteractionService = require(Services.InteractionService)
local VFXService = require(Services.VFXService)
local GameSoundService = require(Services.SoundService)
local NodeModels = require(script.Parent.Parent.Island.NodeModels)

export type Node = {
	Id: string,
	Type: string,
	Def: any,
	IslandId: string,
	OwnerUserId: number,
	Model: Model,
	BaseCFrame: CFrame,
	Health: number,
	Depleted: boolean,
	RespawnThread: thread?,
}

local ResourceService = {}

ResourceService.NodeBroken = Signal.new() -- (node)

local TAG = "ResourceNode"

local nodesById: { [string]: Node } = {}
local nodesByIsland: { [string]: { Node } } = {}

local function seedFor(text: string): number
	local seed = 17
	for index = 1, #text do
		seed = (seed * 33 + string.byte(text, index)) % 2147483647
	end
	return seed
end

local function spawnNode(island: any, spotId: string, nodeType: string, localXZ: Vector2)
	local def = ResourceConfig.Nodes[nodeType]
	if not def then
		warn("[ResourceService] Unknown node type " .. tostring(nodeType))
		return
	end
	local nodeId = island.Id .. "/" .. spotId
	if nodesById[nodeId] then
		return
	end
	local seed = seedFor(nodeId)
	local model = NodeModels.Build(def.Model, seed)
	model.Name = nodeType
	local yaw = seed % 360
	local baseCFrame = IslandService.GetGroundCFrame(island, localXZ, yaw) * CFrame.new(0, -0.2, 0)
	model:PivotTo(baseCFrame)
	model:SetAttribute("NodeId", nodeId)
	model:SetAttribute("NodeType", nodeType)
	model:SetAttribute("Health", def.Health)
	model:SetAttribute("MaxHealth", def.Health)
	model:SetAttribute("Depleted", false)
	model:SetAttribute("OwnerUserId", island.OwnerUserId)
	if def.ToolType then
		model:SetAttribute("ToolType", def.ToolType)
	end
	model.Parent = island.Folders.Resources
	CollectionService:AddTag(model, TAG)

	local node: Node = {
		Id = nodeId,
		Type = nodeType,
		Def = def,
		IslandId = island.Id,
		OwnerUserId = island.OwnerUserId,
		Model = model,
		BaseCFrame = baseCFrame,
		Health = def.Health,
		Depleted = false,
		RespawnThread = nil,
	}
	nodesById[nodeId] = node
	local list = nodesByIsland[island.Id]
	if not list then
		list = {}
		nodesByIsland[island.Id] = list
	end
	table.insert(list, node)

	InteractionService.Attach(model, "ResourceNode", {
		ActionText = def.Action,
		ObjectText = def.DisplayName,
		OwnerUserId = island.OwnerUserId,
		MaxDistance = 11,
	})
end

function ResourceService.SpawnArea(island: any, areaId: string)
	for _, spot in IslandContent.AreaNodes(areaId) do
		spawnNode(island, spot.Id, spot.Type, spot.Position)
	end
end

function ResourceService.GetNode(nodeId: any): Node?
	if type(nodeId) ~= "string" then
		return nil
	end
	return nodesById[nodeId]
end

function ResourceService.GetNodeFromModel(model: Instance): Node?
	local nodeId = model:GetAttribute("NodeId")
	return ResourceService.GetNode(nodeId)
end

function ResourceService.GetPosition(node: Node): Vector3
	return node.BaseCFrame.Position
end

local function respawn(node: Node)
	node.RespawnThread = nil
	if not node.Model.Parent then
		return
	end
	node.Model:PivotTo(node.BaseCFrame)
	NodeModels.SetVisible(node.Model, true)
	node.Health = node.Def.Health
	node.Depleted = false
	node.Model:SetAttribute("Health", node.Health)
	node.Model:SetAttribute("Depleted", false)
	InteractionService.SetEnabled(node.Model, true)
	VFXService.PlayAt("Sparkle", node.BaseCFrame.Position + Vector3.new(0, 2, 0))
end

local function fallOver(node: Node, fromPosition: Vector3?)
	-- Tip the tree away from the player around its base, then hide it.
	local base = node.BaseCFrame
	local away = if fromPosition then (base.Position - fromPosition) * Vector3.new(1, 0, 1) else Vector3.new(1, 0, 0)
	if away.Magnitude < 0.1 then
		away = Vector3.new(1, 0, 0)
	end
	away = away.Unit
	local axis = Vector3.new(0, 1, 0):Cross(away).Unit
	local driver = Instance.new("NumberValue")
	driver.Value = 0
	driver.Changed:Connect(function(alpha)
		if node.Model.Parent then
			node.Model:PivotTo(CFrame.fromAxisAngle(axis, math.rad(82) * alpha) * (base - base.Position) + base.Position)
		end
	end)
	local tween = TweenService:Create(driver, TweenInfo.new(0.9, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Value = 1 })
	tween.Completed:Once(function()
		driver:Destroy()
		if node.Depleted and node.Model.Parent then
			NodeModels.SetVisible(node.Model, false)
			VFXService.PlayAt(node.Def.BreakVFX or "LeafBurst", base.Position + away * 5 + Vector3.new(0, 1, 0))
		end
	end)
	tween:Play()
end

-- Applies damage. Returns true if this hit broke the node.
function ResourceService.Damage(node: Node, amount: number, fromPosition: Vector3?): boolean
	if node.Depleted then
		return false
	end
	node.Health = math.max(0, node.Health - amount)
	node.Model:SetAttribute("Health", node.Health)
	if node.Health > 0 then
		return false
	end

	node.Depleted = true
	node.Model:SetAttribute("Depleted", true)
	InteractionService.SetEnabled(node.Model, false)
	if node.Def.BreakSound then
		GameSoundService.PlayAt(node.Def.BreakSound, node.BaseCFrame.Position)
	end
	if node.Def.FallOver then
		fallOver(node, fromPosition)
	else
		NodeModels.SetVisible(node.Model, false)
		VFXService.PlayAt(node.Def.BreakVFX or "RockChips", node.BaseCFrame.Position + Vector3.new(0, 1, 0))
	end
	node.RespawnThread = task.delay(node.Def.Respawn, respawn, node)
	ResourceService.NodeBroken:Fire(node)
	return true
end

-- Nodes near a world position (used by build validation & debugging).
function ResourceService.GetIslandNodes(islandId: string): { Node }
	return nodesByIsland[islandId] or {}
end

local function clearIsland(islandId: string)
	local list = nodesByIsland[islandId]
	if not list then
		return
	end
	for _, node in list do
		if node.RespawnThread then
			pcall(task.cancel, node.RespawnThread)
		end
		nodesById[node.Id] = nil
	end
	nodesByIsland[islandId] = nil
end

function ResourceService.Start()
	IslandService.IslandAssigned:Connect(function(player: Player, island: any)
		local unlocked = IslandService.GetUnlockedAreas(player)
		for areaId in unlocked do
			ResourceService.SpawnArea(island, areaId)
		end
	end)
	IslandService.AreaUnlocked:Connect(function(player: Player, areaId: string)
		local island = IslandService.GetIsland(player)
		if island then
			ResourceService.SpawnArea(island, areaId)
		end
	end)
	IslandService.IslandReleased:Connect(function(_player: Player, islandId: string)
		clearIsland(islandId)
	end)
end

return ResourceService
