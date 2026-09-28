--[[
	SCRIPT NAME:  ResourceService
	SCRIPT TYPE:  ModuleScript (server service)
	WHERE:        ServerScriptService/Server/Services/ResourceService
	DEPENDENCIES: DataService, IslandService, InteractionService, InventoryService, VFXService, SoundService,
	              AntiExploitService, Server.Island.NodeModels, Shared.Config.ResourceConfig, Shared.Util.IslandGen

	Owns resource NODES (trees, rocks, bushes, ore...) on every island.
	  * NATURAL nodes grow at deterministic spots per land chunk
	    (IslandGen.ChunkSpots), themed by the island (palms on tropical
	    islands, snowy pines on snowy ones, rarer ore far from home).
	  * PLANTED nodes come from Nature buildings (Oak Tree, Boulder...) the
	    player places anywhere (BuildService calls SpawnPlaced).
	  * POOLED: a broken node is hidden, not destroyed, and regrows after its
	    Respawn time in the same Model.
	  * The owner can CLEAR a natural node for good (edit mode) — it drops its
	    resources once and never comes back (Island.RemovedNodes).

	Node attributes: NodeId, NodeType, Health, MaxHealth, Depleted, OwnerUserId,
	ToolType, Placed. Tag: "ResourceNode". Interaction kind: "ResourceNode"
	(registered by GatherService).
]]

local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Shared = ReplicatedStorage.Shared
local Net = require(Shared.Net)
local ResourceConfig = require(Shared.Config.ResourceConfig)
local IslandGen = require(Shared.Util.IslandGen)
local Signal = require(Shared.Util.Signal)

local Services = script.Parent
local DataService = require(Services.DataService)
local IslandService = require(Services.IslandService)
local InteractionService = require(Services.InteractionService)
local InventoryService = require(Services.InventoryService)
local VFXService = require(Services.VFXService)
local GameSoundService = require(Services.SoundService)
local AntiExploitService = require(Services.AntiExploitService)
local NodeModels = require(script.Parent.Parent.Island.NodeModels)
local Notify = require(script.Parent.Parent.Util.Notify)

export type Node = {
	Id: string,
	SpotId: string,
	Type: string,
	Def: any,
	IslandId: string,
	OwnerUserId: number,
	Model: Model,
	BaseCFrame: CFrame,
	Health: number,
	Depleted: boolean,
	Placed: boolean,
	RespawnThread: thread?,
}

local ResourceService = {}

ResourceService.NodeBroken = Signal.new() -- (node)

local TAG = "ResourceNode"

local nodesById: { [string]: Node } = {}
local nodesByIsland: { [string]: { [string]: Node } } = {}

local function seedFor(text: string): number
	local seed = 17
	for index = 1, #text do
		seed = (seed * 33 + string.byte(text, index)) % 2147483647
	end
	return seed
end

local function register(island: any, spotId: string, nodeType: string, model: Model, baseCFrame: CFrame, placed: boolean): Node?
	local def = ResourceConfig.Nodes[nodeType]
	if not def then
		warn("[ResourceService] Unknown node type " .. tostring(nodeType))
		return nil
	end
	local nodeId = island.Id .. "/" .. spotId
	model.Name = nodeType
	model:SetAttribute("NodeId", nodeId)
	model:SetAttribute("NodeType", nodeType)
	model:SetAttribute("Health", def.Health)
	model:SetAttribute("MaxHealth", def.Health)
	model:SetAttribute("Depleted", false)
	model:SetAttribute("OwnerUserId", island.OwnerUserId)
	model:SetAttribute("Placed", placed)
	model:SetAttribute("ToolType", def.ToolType)
	CollectionService:AddTag(model, TAG)

	local node: Node = {
		Id = nodeId,
		SpotId = spotId,
		Type = nodeType,
		Def = def,
		IslandId = island.Id,
		OwnerUserId = island.OwnerUserId,
		Model = model,
		BaseCFrame = baseCFrame,
		Health = def.Health,
		Depleted = false,
		Placed = placed,
		RespawnThread = nil,
	}
	nodesById[nodeId] = node
	local list = nodesByIsland[island.Id]
	if not list then
		list = {}
		nodesByIsland[island.Id] = list
	end
	list[nodeId] = node

	InteractionService.Attach(model, "ResourceNode", {
		Label = def.DisplayName,
		OwnerUserId = island.OwnerUserId,
		MaxDistance = 9,
	})
	return node
end

local function spawnNatural(island: any, spotId: string, nodeType: string, localXZ: Vector2, yaw: number)
	local def = ResourceConfig.Nodes[nodeType]
	if not def or nodesById[island.Id .. "/" .. spotId] then
		return
	end
	local model = NodeModels.Build(def.Model, seedFor(island.Id .. spotId))
	local baseCFrame = IslandService.GetGroundCFrame(island, localXZ, yaw) * CFrame.new(0, -0.25, 0)
	model:PivotTo(baseCFrame)
	model.Parent = island.Folders.Resources
	register(island, spotId, nodeType, model, baseCFrame, false)
end

-- Spawns every natural spot of these chunks that is valid land right now.
local function spawnChunks(island: any, chunkList: { { X: number, Z: number } })
	local removed = DataService.Get(island.Owner, { "Island", "RemovedNodes" }) or {}
	local sampler = IslandService.GetSampler(island)
	for _, chunk in chunkList do
		if sampler:IsOwnedChunk(chunk.X, chunk.Z) then
			for _, spot in IslandGen.ChunkSpots(sampler, chunk.X, chunk.Z) do
				if not removed[spot.Id] then
					spawnNatural(island, spot.Id, spot.Type, spot.Position, spot.Yaw)
				end
			end
		end
	end
end

-- A Nature building (sapling / boulder) becomes a harvestable node. Returns its model.
function ResourceService.SpawnPlaced(island: any, uniqueId: string, nodeType: string, worldCFrame: CFrame): Model?
	local def = ResourceConfig.Nodes[nodeType]
	if not def then
		return nil
	end
	local model = NodeModels.Build(def.Model, seedFor(uniqueId))
	model:PivotTo(worldCFrame)
	model.Parent = island.Folders.Resources
	local node = register(island, "b:" .. uniqueId, nodeType, model, worldCFrame, true)
	return node and model
end

function ResourceService.RemovePlaced(island: any, uniqueId: string)
	local node = nodesById[island.Id .. "/b:" .. uniqueId]
	if node then
		ResourceService.Despawn(node)
	end
end

-- Moves a planted node (edit mode MOVE).
function ResourceService.MovePlaced(island: any, uniqueId: string, worldCFrame: CFrame)
	local node = nodesById[island.Id .. "/b:" .. uniqueId]
	if node then
		node.BaseCFrame = worldCFrame
		if not node.Depleted then
			node.Model:PivotTo(worldCFrame)
		end
	end
end

function ResourceService.Despawn(node: Node)
	if node.RespawnThread then
		pcall(task.cancel, node.RespawnThread)
	end
	nodesById[node.Id] = nil
	local list = nodesByIsland[node.IslandId]
	if list then
		list[node.Id] = nil
	end
	node.Model:Destroy()
end

function ResourceService.GetNode(nodeId: any): Node?
	if type(nodeId) ~= "string" then
		return nil
	end
	return nodesById[nodeId]
end

function ResourceService.GetNodeFromModel(model: Instance): Node?
	return ResourceService.GetNode(model:GetAttribute("NodeId"))
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
	-- Grow back in: start small and pop to full size.
	local scale = Instance.new("NumberValue")
	scale.Value = 0.3
	scale.Changed:Connect(function(value)
		if node.Model.Parent then
			node.Model:ScaleTo(math.max(value, 0.05))
		end
	end)
	node.Model:ScaleTo(0.3)
	local tween = TweenService:Create(scale, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Value = 1 })
	tween.Completed:Once(function()
		scale:Destroy()
		if node.Model.Parent then
			node.Model:ScaleTo(1)
			node.Model:PivotTo(node.BaseCFrame)
		end
	end)
	tween:Play()
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
			node.Model:PivotTo(CFrame.fromAxisAngle(axis, math.rad(84) * alpha) * (base - base.Position) + base.Position)
		end
	end)
	local tween = TweenService:Create(driver, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Value = 1 })
	tween.Completed:Once(function()
		driver:Destroy()
		if node.Depleted and node.Model.Parent then
			GameSoundService.PlayAt("RockHit", base.Position + away * 6)
			VFXService.PlayAt("BuildDust", base.Position + away * 6)
			task.wait(0.35)
			if node.Depleted and node.Model.Parent then
				NodeModels.SetVisible(node.Model, false)
				VFXService.PlayAt(node.Def.BreakVFX or "LeafBurst", base.Position + away * 5 + Vector3.new(0, 1, 0))
			end
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
	if node.Def.HitSound then
		GameSoundService.PlayAt(node.Def.HitSound, node.BaseCFrame.Position + Vector3.new(0, 2, 0))
	end
	if node.Def.HitVFX then
		VFXService.PlayAt(node.Def.HitVFX, node.BaseCFrame.Position + Vector3.new(0, 2.5, 0))
	end
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

function ResourceService.GetIslandNodes(islandId: string): { Node }
	local list = {}
	local nodes = nodesByIsland[islandId]
	if nodes then
		for _, node in nodes do
			table.insert(list, node)
		end
	end
	return list
end

-- Owner clears a natural node for good (it drops its minimum yield once).
local function onRemoveRequest(player: Player, nodeId: any)
	local node = ResourceService.GetNode(nodeId)
	if not node then
		return
	end
	local island = IslandService.GetIsland(player)
	if not island or node.IslandId ~= island.Id then
		AntiExploitService.Flag(player, "RemoveForeignNode", 2)
		return
	end
	if node.Placed then
		Notify.Error(player, "Use MOVE / DELETE in edit mode for things you planted.")
		return
	end
	DataService.Set(player, { "Island", "RemovedNodes", node.SpotId }, true)
	if not node.Depleted then
		InventoryService.AddItem(player, node.Def.Resource, node.Def.Drops.Min, "ClearNode", { IgnoreCapacity = true })
	end
	VFXService.PlayAt("BuildDust", node.BaseCFrame.Position + Vector3.new(0, 1, 0))
	GameSoundService.PlayAt("RockBreak", node.BaseCFrame.Position)
	ResourceService.Despawn(node)
end

local function clearIsland(islandId: string)
	for _, node in nodesByIsland[islandId] or {} :: { [string]: Node } do
		if node.RespawnThread then
			pcall(task.cancel, node.RespawnThread)
		end
		nodesById[node.Id] = nil
	end
	nodesByIsland[islandId] = nil
end

function ResourceService.Init()
	Net.OnServerEvent("RemoveNodeRequest", onRemoveRequest)
end

function ResourceService.Start()
	IslandService.IslandAssigned:Connect(function(_player: Player, island: any)
		local chunks = {}
		for key, owned in IslandService.GetSampler(island).Data.Chunks do
			local cx, cz = IslandGen.ParseKey(key)
			if owned and cx and cz then
				table.insert(chunks, { X = cx, Z = cz })
			end
		end
		spawnChunks(island, chunks)
	end)
	IslandService.ChunkAdded:Connect(function(_player: Player, island: any, cx: number, cz: number)
		-- The new chunk plus neighbours whose coast just moved inland.
		local around = {}
		for dx = -1, 1 do
			for dz = -1, 1 do
				table.insert(around, { X = cx + dx, Z = cz + dz })
			end
		end
		spawnChunks(island, around)
	end)
	IslandService.IslandReleased:Connect(function(_player: Player, islandId: string)
		clearIsland(islandId)
	end)
end

return ResourceService
