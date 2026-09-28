--[[
	SCRIPT NAME:  LandEditor
	SCRIPT TYPE:  ModuleScript (client, used by BuildController)
	WHERE:        StarterPlayerScripts/Client/Build/LandEditor
	DEPENDENCIES: Shared.Net, Shared.Config.IslandConfig, Shared.Util.{IslandGen, Format}, Client.ClientState,
	              Controllers.InputController, Controllers.AudioController

	The two island-shaping tools in build mode:

	  EXPAND  every water chunk touching your land glows on the sea. Hover
	          one to see its price, click to buy it (ExpandIslandRequest);
	          the server raises the new land out of the sea. Grow in ANY
	          direction — no two islands end up the same shape.
	  PAINT   pick a material (grass, sand, snow, cobble path, brick, wood
	          deck...) and click / drag over your land to paint 8x8-stud
	          cells (PaintTerrainRequest, batched). The eraser restores the
	          natural look.

	Everything here is a preview: the server validates every request.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Net = require(Shared:WaitForChild("Net"))
local IslandConfig = require(Shared.Config.IslandConfig)
local IslandGen = require(Shared.Util.IslandGen)
local Format = require(Shared.Util.Format)

local Client = script.Parent.Parent
local ClientState = require(Client.ClientState)
local InputController = require(Client.Controllers.InputController)
local AudioController = require(Client.Controllers.AudioController)

local player = Players.LocalPlayer
local CHUNK = IslandConfig.ChunkSize
local CELL = IslandConfig.PaintCellSize
local PAINT_FLUSH = 0.1

-- Approximate swatch colours for the brush preview.
local MATERIAL_COLORS: { [string]: Color3 } = {
	Grass = Color3.fromRGB(106, 190, 72),
	LeafyGrass = Color3.fromRGB(226, 150, 60),
	Snow = Color3.fromRGB(245, 250, 255),
	Sand = Color3.fromRGB(240, 220, 160),
	Sandstone = Color3.fromRGB(220, 160, 100),
	Ground = Color3.fromRGB(140, 105, 70),
	Mud = Color3.fromRGB(100, 72, 50),
	Cobblestone = Color3.fromRGB(150, 150, 150),
	Brick = Color3.fromRGB(180, 90, 70),
	WoodPlanks = Color3.fromRGB(170, 120, 72),
	Pavement = Color3.fromRGB(120, 120, 124),
	Slate = Color3.fromRGB(90, 90, 96),
	Limestone = Color3.fromRGB(230, 225, 205),
}

local LandEditor = {}

LandEditor.Mode = nil :: string?
LandEditor.Material = "Cobblestone"

local sampler: any = nil
local expandFolder: Folder? = nil
local expandTiles: { [string]: Part } = {}
local hoverKey: string? = nil
local brush: Part? = nil
local pendingCells: { { X: number, Z: number } } = {}
local pendingSet: { [string]: boolean } = {}
local lastFlush = 0
local terrainParams = RaycastParams.new()
terrainParams.FilterType = Enum.RaycastFilterType.Include

local function myIsland(): Model?
	local folder = workspace:FindFirstChild("Islands")
	local island = folder and folder:FindFirstChild("Island_" .. player.UserId)
	return if island and island:IsA("Model") then island else nil
end

local function islandData(): any
	return ClientState.Get("Island") or {}
end

local function rebuildSampler()
	local data = islandData()
	if type(data.Chunks) ~= "table" then
		sampler = nil
		return
	end
	sampler = IslandGen.NewSampler({ Seed = data.Seed or 1, Theme = data.Theme or IslandConfig.DefaultTheme, Chunks = data.Chunks, Paint = data.Paint or {} })
end

function LandEditor.GetSampler(): any
	if not sampler then
		rebuildSampler()
	end
	return sampler
end

-- (count, max, cost)
function LandEditor.ExpansionInfo(): (number, number, number)
	local data = islandData()
	local count = IslandGen.CountChunks(data.Chunks or {})
	return count, IslandGen.MaxChunks(data.Level or 1), IslandGen.ExpansionCost(count)
end

local function pointerRay(screenPoint: Vector2?): Ray?
	local camera = workspace.CurrentCamera
	if not camera then
		return nil
	end
	local point = screenPoint or UserInputService:GetMouseLocation()
	if InputController.IsTouch() and not screenPoint then
		point = camera.ViewportSize / 2
	end
	return camera:ViewportPointToRay(point.X, point.Y)
end

---------------------------------------------------------------------------
-- EXPAND
---------------------------------------------------------------------------

local function clearExpand()
	if expandFolder then
		expandFolder:Destroy()
		expandFolder = nil
	end
	table.clear(expandTiles)
	hoverKey = nil
end

local function tileColor(affordable: boolean, hovered: boolean): Color3
	if not affordable then
		return if hovered then Color3.fromRGB(255, 120, 110) else Color3.fromRGB(230, 90, 80)
	end
	return if hovered then Color3.fromRGB(150, 255, 170) else Color3.fromRGB(90, 230, 255)
end

function LandEditor.RefreshExpand()
	clearExpand()
	if LandEditor.Mode ~= "Expand" then
		return
	end
	local island = myIsland()
	if not island then
		return
	end
	local origin = island:GetPivot()
	local folder = Instance.new("Folder")
	folder.Name = "ExpandTiles"
	folder.Parent = workspace.CurrentCamera
	expandFolder = folder
	local count, maxChunks, cost = LandEditor.ExpansionInfo()
	local coins = ClientState.Get("Coins") or 0
	local affordable = coins >= cost and count < maxChunks
	for _, candidate in IslandGen.ExpansionCandidates(islandData().Chunks or {}) do
		local tile = Instance.new("Part")
		tile.Name = IslandGen.Key(candidate.X, candidate.Z)
		tile.Anchored = true
		tile.CanCollide = false
		tile.CanTouch = false
		tile.CastShadow = false
		tile.Material = Enum.Material.Neon
		tile.Transparency = 0.62
		tile.Size = Vector3.new(CHUNK - 0.8, 0.4, CHUNK - 0.8)
		tile.CFrame = origin * CFrame.new(candidate.X * CHUNK, 0.35, candidate.Z * CHUNK)
		tile.Color = tileColor(affordable, false)
		tile:SetAttribute("CX", candidate.X)
		tile:SetAttribute("CZ", candidate.Z)
		tile.Parent = folder
		expandTiles[tile.Name] = tile
	end
end

local function expandTileUnder(screenPoint: Vector2?): Part?
	local ray = pointerRay(screenPoint)
	if not ray or not expandFolder then
		return nil
	end
	terrainParams.FilterDescendantsInstances = { expandFolder }
	local hit = workspace:Raycast(ray.Origin, ray.Direction * 600, terrainParams)
	return if hit and hit.Instance:IsA("Part") then hit.Instance else nil
end

---------------------------------------------------------------------------
-- PAINT
---------------------------------------------------------------------------

local function clearBrush()
	if brush then
		brush:Destroy()
		brush = nil
	end
end

local function ensureBrush(): Part
	if brush and brush.Parent then
		return brush
	end
	local part = Instance.new("Part")
	part.Name = "PaintBrush"
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.CastShadow = false
	part.Material = Enum.Material.Neon
	part.Transparency = 0.45
	part.Size = Vector3.new(CELL, 0.25, CELL)
	part.Parent = workspace.CurrentCamera
	brush = part
	return part
end

-- The paint cell under the pointer, if it's on your own land.
local function paintCellUnder(screenPoint: Vector2?): ({ X: number, Z: number }?, Vector3?)
	local island = myIsland()
	local ray = pointerRay(screenPoint)
	local currentSampler = LandEditor.GetSampler()
	if not island or not ray or not currentSampler then
		return nil, nil
	end
	terrainParams.FilterDescendantsInstances = { workspace.Terrain }
	terrainParams.IgnoreWater = true
	local hit = workspace:Raycast(ray.Origin, ray.Direction * 500, terrainParams)
	if not hit then
		return nil, nil
	end
	local origin = island:GetPivot()
	local localHit = origin:PointToObjectSpace(hit.Position)
	local cellX, cellZ = math.floor(localHit.X / CELL), math.floor(localHit.Z / CELL)
	local centerX, centerZ = (cellX + 0.5) * CELL, (cellZ + 0.5) * CELL
	local cx, cz = IslandGen.ChunkOf(centerX, centerZ)
	if not currentSampler:IsOwnedChunk(cx, cz) then
		return nil, nil
	end
	local world = origin * CFrame.new(centerX, localHit.Y + 0.15, centerZ)
	return { X = cellX, Z = cellZ }, world.Position
end

local function flushPaint(force: boolean?)
	if #pendingCells == 0 then
		return
	end
	local now = os.clock()
	if not force and now - lastFlush < PAINT_FLUSH then
		return
	end
	lastFlush = now
	local batch = {}
	for index = 1, math.min(24, #pendingCells) do
		table.insert(batch, pendingCells[index])
	end
	for _ = 1, #batch do
		table.remove(pendingCells, 1)
	end
	Net.FireServer("PaintTerrainRequest", batch, LandEditor.Material)
	AudioController.Play("UIClick")
	if #pendingCells == 0 then
		table.clear(pendingSet)
	end
end

local function queueCell(cell: { X: number, Z: number })
	local key = cell.X .. "_" .. cell.Z
	local painted = (islandData().Paint or {})[key] or ""
	if pendingSet[key] or painted == LandEditor.Material then
		return
	end
	pendingSet[key] = true
	table.insert(pendingCells, cell)
end

---------------------------------------------------------------------------
-- Public
---------------------------------------------------------------------------

function LandEditor.Enter(mode: string)
	LandEditor.Mode = mode
	rebuildSampler()
	clearExpand()
	clearBrush()
	if mode == "Expand" then
		LandEditor.RefreshExpand()
	end
end

function LandEditor.Exit()
	flushPaint(true)
	LandEditor.Mode = nil
	clearExpand()
	clearBrush()
end

function LandEditor.SetMaterial(material: string)
	LandEditor.Material = material
end

-- Per frame while a land mode is active. Returns a status line for the info panel.
function LandEditor.Step(): (string, boolean)
	if LandEditor.Mode == "Expand" then
		local tile = expandTileUnder(nil)
		local key = tile and tile.Name
		if key ~= hoverKey then
			local count, maxChunks, cost = LandEditor.ExpansionInfo()
			local affordable = (ClientState.Get("Coins") or 0) >= cost and count < maxChunks
			if hoverKey and expandTiles[hoverKey] then
				expandTiles[hoverKey].Color = tileColor(affordable, false)
				expandTiles[hoverKey].Transparency = 0.62
			end
			hoverKey = key
			if tile then
				tile.Color = tileColor(affordable, true)
				tile.Transparency = 0.35
			end
		end
		local count, maxChunks, cost = LandEditor.ExpansionInfo()
		if count >= maxChunks then
			return ("Land %d/%d — level up your island to expand further"):format(count, maxChunks), false
		end
		local coins = ClientState.Get("Coins") or 0
		return ("Land %d/%d · next chunk %s 🪙"):format(count, maxChunks, Format.Commas(cost)), coins >= cost
	elseif LandEditor.Mode == "Paint" then
		local cell, position = paintCellUnder(nil)
		if cell and position then
			local part = ensureBrush()
			part.Position = position
			part.Color = if LandEditor.Material == "" then Color3.fromRGB(255, 255, 255) else (MATERIAL_COLORS[LandEditor.Material] or Color3.new(1, 1, 1))
			part.Transparency = if LandEditor.Material == "" then 0.7 else 0.45
			if InputController.IsHeld("BuildPlace") then
				queueCell(cell)
			end
		elseif brush then
			brush.Transparency = 1
		end
		flushPaint(false)
		local name = if LandEditor.Material == "" then "Eraser" else IslandConfig.Paint[LandEditor.Material].DisplayName
		return ("Painting: %s · click or drag on your land"):format(name), true
	end
	return "", false
end

-- A click / tap in a land mode.
function LandEditor.Click(screenPoint: Vector2?)
	if LandEditor.Mode == "Expand" then
		local tile = expandTileUnder(screenPoint)
		if tile then
			local count, maxChunks, cost = LandEditor.ExpansionInfo()
			if count >= maxChunks then
				AudioController.Play("UIError")
				return
			end
			if (ClientState.Get("Coins") or 0) < cost then
				AudioController.Play("UIError")
				return
			end
			Net.FireServer("ExpandIslandRequest", tile:GetAttribute("CX"), tile:GetAttribute("CZ"))
			tile.Transparency = 0.2
			AudioController.Play("UIClick")
		end
	elseif LandEditor.Mode == "Paint" then
		local cell = paintCellUnder(screenPoint)
		if cell then
			queueCell(cell)
			flushPaint(true)
		end
	end
end

function LandEditor.Start()
	ClientState.Observe("Island", function()
		rebuildSampler()
		if LandEditor.Mode == "Expand" then
			LandEditor.RefreshExpand()
		end
	end)
	ClientState.Observe("Coins", function()
		if LandEditor.Mode == "Expand" then
			LandEditor.RefreshExpand()
		end
	end)
end

LandEditor.MaterialColors = MATERIAL_COLORS

return LandEditor
