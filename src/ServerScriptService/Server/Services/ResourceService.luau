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
	VFXService.PlayAt("Puff", node.BaseCFrame.Position, { Scale = 0.6, Color = Color3.fromRGB(210, 240, 190) })
end

-- The main (largest visible) colour of a node, for its debris.
local function mainColor(model: Model): Color3
	local best, bestVolume = nil, 0
	for _, part in model:GetDescendants() do
		if part:IsA("BasePart") and part.Transparency < 0.5 then
			local volume = part.Size.X * part.Size.Y * part.Size.Z
			if volume > bestVolume then
				best, bestVolume = part, volume
			end
		end
	end
	return if best then best.Color else Color3.fromRGB(150, 150, 155)
end

-- TIMBER! The tree leans back a touch (anticipation), then crashes down
-- away from the player with a cartoon bounce. On impact: crash sound, a
-- big dust cloud, leaves and splinters, and the camera of everyone nearby
-- wobbles. Then it poofs away.
local FALL_TIME = 1.3
local FIRST_CONTACT = 0.364 -- Bounce/Out first reaches 1 at t = 1 / 2.75

local function fallOver(node: Node, fromPosition: Vector3?)
	local base = node.BaseCFrame
	local away = if fromPosition then (base.Position - fromPosition) * Vector3.new(1, 0, 1) else Vector3.new(1, 0, 0)
	if away.Magnitude < 0.1 then
		away = Vector3.new(1, 0, 0)
	end
	away = away.Unit
	local axis = Vector3.new(0, 1, 0):Cross(away).Unit
	local height = node.Model:GetExtentsSize().Y
	local landing = base.Position + away * math.max(4, height * 0.55)
	local driver = Instance.new("NumberValue")
	driver.Value = 0
	driver.Changed:Connect(function(alpha)
		if node.Model.Parent then
			node.Model:PivotTo(CFrame.fromAxisAngle(axis, math.rad(84) * alpha) * (base - base.Position) + base.Position)
		end
	end)
	local lean = TweenService:Create(driver, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Value = -0.07 })
	local fall = TweenService:Create(driver, TweenInfo.new(FALL_TIME, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out), { Value = 1 })
	lean.Completed:Once(function()
		if not node.Depleted or not node.Model.Parent then
			driver:Destroy()
			return
		end
		fall:Play()
		task.delay(FALL_TIME * FIRST_CONTACT, function()
			if node.Depleted and node.Model.Parent then
				GameSoundService.PlayAt("TreeFall", landing)
				VFXService.PlayAt("BigPuff", landing)
				VFXService.PlayAt(node.Def.BreakVFX or "LeafBurst", landing + Vector3.new(0, 1.5, 0), { Count = 22, Scale = 1.4 })
				VFXService.PlayAt("WoodSplinters", base.Position + Vector3.new(0, 1, 0))
				VFXService.WobbleNear(landing, 70, 1.1, 0.9)
			end
		end)
	end)
	fall.Completed:Once(function()
		driver:Destroy()
		task.wait(0.45)
		if node.Depleted and node.Model.Parent then
			NodeModels.SetVisible(node.Model, false)
			VFXService.PlayAt("Puff", landing, { Scale = 1.3 })
			VFXService.PlayAt("Sparkle", landing + Vector3.new(0, 1, 0))
		end
	end)
	lean:Play()
end

-- Rocks / ore burst into chunks with dust, a flash and a camera wobble.
local function shatter(node: Node)
	local position = node.BaseCFrame.Position
	local size = node.Model:GetExtentsSize()
	local scale = math.clamp(math.max(size.X, size.Z) / 5, 0.6, 1.8)
	local center = position + Vector3.new(0, size.Y * 0.4, 0)
	VFXService.PlayAt("RockShatter", center, { Color = mainColor(node.Model), Scale = scale })
	VFXService.PlayAt("Puff", position, { Scale = scale })
	VFXService.PlayAt("HitPop", center, { Scale = 1.6 * scale })
	VFXService.PlayAt("Stars", center)
	VFXService.WobbleNear(position, 50, 0.85, 0.7)
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
	local hitPoint = node.BaseCFrame.Position + Vector3.new(0, 2.5, 0)
	if node.Def.HitVFX then
		VFXService.PlayAt(node.Def.HitVFX, hitPoint)
	end
	if node.Health > 0 then
		-- Cartoon hit: a flash, a few stars and the node squashes / sways.
		VFXService.PlayAt("HitPop", hitPoint)
		VFXService.PlayAt("Stars", hitPoint, { Count = 4 })
		VFXService.Jiggle(node.Model, if node.Def.FallOver then "Tilt" else "Squash", fromPosition)
		return false
	end

	node.Depleted = true
	node.Model:SetAttribute("Depleted", true)
	InteractionService.SetEnabled(node.Model, false)
	if node.Def.FallOver then
		-- The crash sound plays when the tree hits the ground.
		fallOver(node, fromPosition)
	else
		if node.Def.BreakSound then
			GameSoundService.PlayAt(node.Def.BreakSound, node.BaseCFrame.Position)
		end
		if node.Def.ToolType == "Pickaxe" then
			shatter(node)
		else
			VFXService.PlayAt("Puff", node.BaseCFrame.Position, { Scale = 0.7 })
			VFXService.PlayAt("HitPop", node.BaseCFrame.Position + Vector3.new(0, 1, 0))
		end
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
