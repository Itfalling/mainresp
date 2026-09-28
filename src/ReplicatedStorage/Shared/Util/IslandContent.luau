--!strict
--[[
	SCRIPT NAME:  IslandContent
	SCRIPT TYPE:  ModuleScript (shared utility)
	WHERE:        ReplicatedStorage/Shared/Util/IslandContent
	DEPENDENCIES: Shared.Config.{IslandConfig, CropConfig}, Shared.Util.IslandLayout

	Deterministic island-local layout of everything areas contain: resource
	node spots, fishing spots and farm plots / tiles. Deterministic means the
	same island always gets the same layout on every server, so saved data
	(e.g. farm tile ids, node ids) always lines up.
]]

local Config = script.Parent.Parent.Config
local IslandConfig = require(Config.IslandConfig)
local CropConfig = require(Config.CropConfig)
local IslandLayout = require(script.Parent.IslandLayout)

local IslandContent = {}

export type NodeSpot = { Id: string, Type: string, AreaId: string, Position: Vector2 }
export type FishingSpot = { Id: string, Zone: string, AreaId: string, Position: Vector2, OnDock: boolean }
export type FarmPlot = { Id: string, AreaId: string, Center: Vector2 }

local NODE_SPACING = 9
local KEEP_CLEAR = 16 -- distance nodes keep from farm plots and fishing spots

local function seedFor(text: string): number
	local seed = 7
	for index = 1, #text do
		seed = (seed * 31 + string.byte(text, index)) % 2147483647
	end
	return seed
end

-- Farm plots: the starter plot plus one per area with Content.FarmPlot.
function IslandContent.FarmPlots(): { FarmPlot }
	local plots: { FarmPlot } = {
		{ Id = "S", AreaId = "Starter", Center = IslandConfig.StarterLayout.FarmPlot.Center } :: FarmPlot,
	}
	for _, areaId in IslandConfig.AreaOrder do
		local area = IslandConfig.Areas[areaId]
		if area.Content and area.Content.FarmPlot then
			table.insert(plots, { Id = string.sub(areaId, 1, 1), AreaId = areaId, Center = IslandLayout.GetAreaCenter(areaId) } :: FarmPlot)
		end
	end
	return plots
end

-- Tile centres of a plot in index order (row-major). Tile ids are PlotId .. index.
function IslandContent.FarmTilePositions(center: Vector2): { Vector2 }
	local farm = CropConfig.Farm
	local pitch = farm.TileSize + farm.TileGap
	local positions = {}
	for row = 1, farm.Rows do
		for column = 1, farm.Columns do
			local x = (column - (farm.Columns + 1) / 2) * pitch
			local z = (row - (farm.Rows + 1) / 2) * pitch
			table.insert(positions, center + Vector2.new(x, z))
		end
	end
	return positions
end

function IslandContent.FishingSpots(): { FishingSpot }
	local spots: { FishingSpot } = {}
	for _, areaId in IslandConfig.AreaOrder do
		local area = IslandConfig.Areas[areaId]
		local zone = area.Content and area.Content.FishingZone
		if zone then
			if areaId == "Starter" then
				table.insert(spots, { Id = areaId, Zone = zone, AreaId = areaId, Position = IslandConfig.StarterLayout.FishingSpot, OnDock = true } :: FishingSpot)
			else
				local center = IslandLayout.GetAreaCenter(areaId)
				local outward = if center.Magnitude > 0 then center.Unit else Vector2.new(0, 1)
				table.insert(spots, {
					Id = areaId,
					Zone = zone,
					AreaId = areaId,
					Position = center + outward * (area.Radius - 5),
					OnDock = false,
				} :: FishingSpot)
			end
		end
	end
	return spots
end

local function keepClearPoints(): { Vector2 }
	local points = {}
	for _, plot in IslandContent.FarmPlots() do
		table.insert(points, plot.Center)
	end
	for _, spot in IslandContent.FishingSpots() do
		table.insert(points, spot.Position)
	end
	for _, areaId in IslandConfig.AreaOrder do
		if areaId ~= "Starter" then
			table.insert(points, IslandLayout.GetAreaMarkerPosition(areaId))
		end
	end
	return points
end

-- Node spots for one area (hand-placed for the starter island, seeded-random elsewhere).
function IslandContent.AreaNodes(areaId: string): { NodeSpot }
	local spots: { NodeSpot } = {}
	if areaId == "Starter" then
		for index, node in IslandConfig.StarterLayout.Nodes do
			table.insert(spots, { Id = "Starter_" .. index, Type = node.Type, AreaId = areaId, Position = node.Position } :: NodeSpot)
		end
		return spots
	end

	local area = IslandConfig.Areas[areaId]
	local nodes = area and area.Content and area.Content.Nodes
	if not nodes then
		return spots
	end

	local random = Random.new(seedFor(areaId))
	local center = IslandLayout.GetAreaCenter(areaId)
	local clear = keepClearPoints()
	local starterRadius = IslandConfig.Areas.Starter.Radius
	local placed: { Vector2 } = {}

	-- Stable order so the same area always produces the same ids.
	local types = {}
	for nodeType in nodes do
		table.insert(types, nodeType)
	end
	table.sort(types)

	for _, nodeType in types do
		for _ = 1, nodes[nodeType] do
			for _ = 1, 200 do
				local angle = random:NextNumber(0, math.pi * 2)
				local distance = math.sqrt(random:NextNumber()) * (area.Radius - 8)
				local point = center + Vector2.new(math.cos(angle), math.sin(angle)) * distance
				local ok = point.Magnitude > starterRadius + 4
				if ok then
					for _, other in placed do
						if (other - point).Magnitude < NODE_SPACING then
							ok = false
							break
						end
					end
				end
				if ok then
					for _, other in clear do
						if (other - point).Magnitude < KEEP_CLEAR then
							ok = false
							break
						end
					end
				end
				if ok then
					table.insert(placed, point)
					table.insert(spots, { Id = areaId .. "_" .. #placed, Type = nodeType, AreaId = areaId, Position = point } :: NodeSpot)
					break
				end
			end
		end
	end
	return spots
end

return IslandContent
