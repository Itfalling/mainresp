--[[
	SCRIPT NAME:  BuildService
	SCRIPT TYPE:  ModuleScript (server service)
	WHERE:        ServerScriptService/Server/Services/BuildService
	DEPENDENCIES: DataService, IslandService, EconomyService, InventoryService, ProgressionService,
	              InteractionService, ToolService, AnimationService, AntiExploitService, SoundService,
	              VFXService, Shared.Building.BuildingModels, Shared.Config.{BuildingConfig, BuildConfig},
	              Shared.Util.{Placement, Serializer, Validate}

	THE authority for buildings (spec §7-§12, §111, §141).

	PLACE   BuildRequest{Op="Place", BuildingId, X, Z, Rotation} (island-local X/Z)
	        -> validate (own island, id, unlock level, rotation, grid snap,
	           owned land away from the water, slope, overlap, distance, cost)
	        -> charge coins + items atomically -> construction SITE appears
	           (Steps = 0 things — soil tiles, trees, rocks — appear finished)
	BUILD   HOLD your hammer and CLICK the site: HammerSwing plays for
	        everyone and the site advances at the HammerHit marker. Each hit
	        reveals the next Stage of the model; the last hit plays HammerHeavy
	        and the completion reveal (dust, sparkle, banner, XP).
	NATURE  buildings with a Node (Oak Tree, Boulder...) become harvestable
	        resource nodes the player planted (ResourceService.SpawnPlaced).
	MOVE    MoveBuildRequest(uniqueId, X, Z, Rotation) — same validation, free.
	DELETE  DeleteBuildRequest(uniqueId) — refunds RefundPercent of the cost.
	STARTER every island gets a market stall (movable, never deletable) and
	        six soil tiles the first time it loads.

	Every building model knows OwnerUserId, IslandId, BuildingId, UniqueId.
	Saved in Island.Buildings[uniqueId] with island-local position.
]]

local CollectionService = game:GetService("CollectionService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Shared = ReplicatedStorage.Shared
local Net = require(Shared.Net)
local BuildingConfig = require(Shared.Config.BuildingConfig)
local BuildConfig = require(Shared.Config.BuildConfig)
local BuildingModels = require(Shared.Building.BuildingModels)
local Placement = require(Shared.Util.Placement)
local IslandGen = require(Shared.Util.IslandGen)
local Serializer = require(Shared.Util.Serializer)
local Validate = require(Shared.Util.Validate)
local Format = require(Shared.Util.Format)
local Signal = require(Shared.Util.Signal)
local R15 = require(Shared.Util.R15)

local IslandConfig = require(Shared.Config.IslandConfig)

local Services = script.Parent
local DataService = require(Services.DataService)
local IslandService = require(Services.IslandService)
local ResourceService = require(Services.ResourceService)
local EconomyService = require(Services.EconomyService)
local InventoryService = require(Services.InventoryService)
local ProgressionService = require(Services.ProgressionService)
local InteractionService = require(Services.InteractionService)
local ToolService = require(Services.ToolService)
local AnimationService = require(Services.AnimationService)
local AntiExploitService = require(Services.AntiExploitService)
local GameSoundService = require(Services.SoundService)
local VFXService = require(Services.VFXService)
local Notify = require(script.Parent.Parent.Util.Notify)
local IslandBuilder = require(script.Parent.Parent.Island.IslandBuilder)

export type Site = {
	UniqueId: string,
	BuildingId: string,
	Def: any,
	Island: any,
	OwnerUserId: number,
	Model: Model,
	Label: TextLabel?,
}

local SITE_TAG = "ConstructionSite"

local BuildService = {}

BuildService.BuildingPlaced = Signal.new() -- (player, site)
BuildService.BuildingCompleted = Signal.new() -- (player, buildingId, def, site)
BuildService.BuildingRemoved = Signal.new() -- (player, uniqueId, buildingId)
BuildService.BuildingMoved = Signal.new() -- (player, site)
BuildService.SiteReady = Signal.new() -- (site) a COMPLETE building exists (loaded or just finished)
BuildService.SiteRemoved = Signal.new() -- (site) about to be destroyed

local sites: { [string]: Site } = {}
local sitesByIsland: { [string]: { [string]: Site } } = {}
local lastPlace: { [Player]: number } = setmetatable({}, { __mode = "k" }) :: any
local lastHammer: { [Player]: number } = setmetatable({}, { __mode = "k" }) :: any
local deleteGuard: ((Player, Site) -> (boolean, string?))? = nil

-- AnimalService installs this so housing with animals can't be deleted.
function BuildService.SetDeleteGuard(guard: (Player, Site) -> (boolean, string?))
	deleteGuard = guard
end

local function entryOf(site: Site): any
	local island = site.Island
	local owner = island and island.Owner
	return owner and DataService.Get(owner, { "Island", "Buildings", site.UniqueId })
end

function BuildService.GetSite(uniqueId: any): Site?
	if type(uniqueId) ~= "string" then
		return nil
	end
	return sites[uniqueId]
end

function BuildService.IsComplete(site: Site): boolean
	local entry = entryOf(site)
	return entry ~= nil and entry.State == "Complete"
end

-- All buildings on a player's island.
function BuildService.GetSites(player: Player): { Site }
	local island = IslandService.GetIsland(player)
	local list = {}
	if island and sitesByIsland[island.Id] then
		for _, site in sitesByIsland[island.Id] do
			table.insert(list, site)
		end
	end
	return list
end

function BuildService.CountComplete(player: Player, buildingId: string?, category: string?): number
	local count = 0
	for _, site in BuildService.GetSites(player) do
		if BuildService.IsComplete(site) and (buildingId == nil or site.BuildingId == buildingId) and (category == nil or site.Def.Category == category) then
			count += 1
		end
	end
	return count
end

---------------------------------------------------------------------------
-- Validation
---------------------------------------------------------------------------

local function overlapParams(island: any): OverlapParams
	local params = OverlapParams.new()
	params.FilterType = Enum.RaycastFilterType.Include
	local folders = {}
	for _, name in BuildConfig.BlockingFolders do
		local folder = island.Folders[name]
		if folder then
			table.insert(folders, folder)
		end
	end
	params.FilterDescendantsInstances = folders
	return params
end

-- Returns (ok, reason, worldCFrame, localPosition)
function BuildService.ValidatePlacement(player: Player, island: any, def: any, localX: number, localZ: number, rotation: number, ignore: Model?): (boolean, string?, CFrame?, Vector3?)
	if not Placement.IsValidRotation(rotation) then
		return false, "Invalid rotation.", nil, nil
	end
	local size = Placement.FootprintSize(def.Footprint, rotation)
	local center = Placement.Snap(Vector2.new(localX, localZ), size)
	if (center - Vector2.new(localX, localZ)).Magnitude > BuildConfig.GridSize then
		return false, "Invalid position.", nil, nil
	end

	if not Placement.IsOnLand(IslandService.GetSampler(island), center, size) then
		return false, "Build on your own land, away from the water.", nil, nil
	end

	-- Slope: compare terrain height at the centre and corners.
	local originY = island.Origin.Position.Y
	local heights = { IslandService.GetGroundCFrame(island, center).Position.Y }
	for _, corner in Placement.Corners(center, size) do
		table.insert(heights, IslandService.GetGroundCFrame(island, corner).Position.Y)
	end
	local lowest, highest = math.huge, -math.huge
	for _, height in heights do
		lowest = math.min(lowest, height)
		highest = math.max(highest, height)
	end
	if highest - lowest > BuildConfig.MaxSlope then
		return false, "The ground is too steep here.", nil, nil
	end

	local localPosition = Vector3.new(center.X, heights[1] - originY, center.Y)
	local worldCFrame = island.Origin * Placement.LocalCFrame(localPosition, rotation)

	local shrink = BuildConfig.OverlapShrink
	local boxSize = Vector3.new(math.max(0.5, def.Footprint.X - shrink), def.Height, math.max(0.5, def.Footprint.Y - shrink))
	local boxCFrame = worldCFrame * CFrame.new(0, def.Height / 2 + 0.4, 0)
	for _, hit in workspace:GetPartBoundsInBox(boxCFrame, boxSize, overlapParams(island)) do
		if not (ignore and hit:IsDescendantOf(ignore)) then
			return false, "Something is in the way.", nil, nil
		end
	end

	local root = R15.GetRootPart(player.Character)
	if not root or (root.Position - worldCFrame.Position).Magnitude > BuildConfig.PlacementRange then
		return false, "Move closer to build there.", nil, nil
	end
	-- Don't build on top of the player.
	local relative = boxCFrame:PointToObjectSpace(root.Position)
	if math.abs(relative.X) < def.Footprint.X / 2 + 1 and math.abs(relative.Z) < def.Footprint.Y / 2 + 1 then
		return false, "Step out of the way first!", nil, nil
	end
	return true, nil, worldCFrame, localPosition
end

---------------------------------------------------------------------------
-- Models / sites
---------------------------------------------------------------------------

local function buildModel(buildingId: string): Model
	local folder = ServerStorage:FindFirstChild("Buildings")
	local art = folder and folder:FindFirstChild(buildingId)
	if art and art:IsA("Model") and art.PrimaryPart then
		local clone = art:Clone()
		for _, descendant in clone:GetDescendants() do
			if descendant:IsA("BasePart") then
				descendant.Anchored = true
				if descendant:GetAttribute("BaseTransparency") == nil then
					descendant:SetAttribute("BaseTransparency", descendant.Transparency)
					descendant:SetAttribute("BaseCanCollide", descendant.CanCollide)
				end
			end
		end
		return clone
	end
	return BuildingModels.Build(buildingId)
end

local function updateSiteLabel(site: Site, progress: number)
	if site.Label then
		site.Label.Text = ("🔨 %s  %d/%d"):format(site.Def.DisplayName, progress, site.Def.Steps)
	end
	InteractionService.SetText(site.Model, ("Build (%d/%d)"):format(progress, site.Def.Steps), site.Def.DisplayName)
end

local function addSiteVisuals(site: Site)
	local def = site.Def
	local model = site.Model
	local frame = Instance.new("Folder")
	frame.Name = "SiteFrame"
	local base = model.PrimaryPart :: BasePart
	for _, spec in {
		{ Vector3.new(def.Footprint.X, 0.3, 0.3), Vector3.new(0, 0.2, -def.Footprint.Y / 2) },
		{ Vector3.new(def.Footprint.X, 0.3, 0.3), Vector3.new(0, 0.2, def.Footprint.Y / 2) },
		{ Vector3.new(0.3, 0.3, def.Footprint.Y), Vector3.new(-def.Footprint.X / 2, 0.2, 0) },
		{ Vector3.new(0.3, 0.3, def.Footprint.Y), Vector3.new(def.Footprint.X / 2, 0.2, 0) },
	} do
		local edge = Instance.new("Part")
		edge.Name = "SiteEdge"
		edge.Anchored = true
		edge.CanCollide = false
		edge.Material = Enum.Material.Neon
		edge.Color = Color3.fromRGB(255, 190, 60)
		edge.Size = spec[1]
		edge.CFrame = base.CFrame * CFrame.new(spec[2])
		edge.Parent = frame
	end
	frame.Parent = model

	local billboard = Instance.new("BillboardGui")
	billboard.Name = "SiteBillboard"
	billboard.Size = UDim2.fromScale(10, 1.6)
	billboard.StudsOffset = Vector3.new(0, def.Height * 0.5 + 3, 0)
	billboard.MaxDistance = 80
	billboard.LightInfluence = 0
	billboard.Parent = base
	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Size = UDim2.fromScale(1, 1)
	label.Font = Enum.Font.FredokaOne
	label.TextScaled = true
	label.TextColor3 = Color3.fromRGB(255, 225, 120)
	label.TextStrokeTransparency = 0.2
	label.Parent = billboard
	site.Label = label

	CollectionService:AddTag(model, SITE_TAG)
	InteractionService.Attach(model, "ConstructionSite", {
		Label = def.DisplayName .. " (building)",
		OwnerUserId = site.OwnerUserId,
		MaxDistance = 9,
	})
end

-- Cosmetic scatter never pokes through floors: hide decorations under footprints.
local function hideDecoUnder(island: any, model: Model, def: any)
	local pivot = model:GetPivot()
	local halfX, halfZ = def.Footprint.X / 2 + 1, def.Footprint.Y / 2 + 1
	for _, deco in island.Folders.Decorations:GetChildren() do
		if deco:IsA("Model") then
			local relative = pivot:PointToObjectSpace(deco:GetPivot().Position)
			if math.abs(relative.X) <= halfX and math.abs(relative.Z) <= halfZ then
				deco:Destroy()
			end
		end
	end
end

-- Re-grow the scatter of the chunks a building left (move / delete).
local function restoreDecoAround(island: any, localPosition: Vector3, def: any)
	local reach = math.max(def.Footprint.X, def.Footprint.Y) / 2 + 1
	local done = {}
	for _, dx in { -reach, reach } do
		for _, dz in { -reach, reach } do
			local cx, cz = IslandGen.ChunkOf(localPosition.X + dx, localPosition.Z + dz)
			local key = IslandGen.Key(cx, cz)
			if not done[key] and IslandService.GetSampler(island):IsOwnedChunk(cx, cz) then
				done[key] = true
				IslandBuilder.DecorateChunk(island.Origin, island.Folders, IslandService.GetSampler(island), cx, cz)
			end
		end
	end
	for _, other in sitesByIsland[island.Id] or {} :: { [string]: Site } do
		hideDecoUnder(island, other.Model, other.Def)
	end
end

local function removeSiteVisuals(site: Site)
	local model = site.Model
	CollectionService:RemoveTag(model, SITE_TAG)
	InteractionService.Detach(model)
	local frame = model:FindFirstChild("SiteFrame")
	if frame then
		frame:Destroy()
	end
	local base = model.PrimaryPart
	local billboard = base and base:FindFirstChild("SiteBillboard")
	if billboard then
		billboard:Destroy()
	end
	site.Label = nil
end

local function spawnSite(island: any, entry: any): Site?
	local def = BuildingConfig.Get(entry.BuildingId)
	local position = Serializer.ToVector3(entry.Position)
	if not def or not position then
		return nil
	end
	local worldCFrame = island.Origin * Placement.LocalCFrame(position, entry.Rotation)
	local model: Model
	if def.Node then
		-- Planted nature: a harvestable node that lives in the Resources folder.
		local nodeModel = ResourceService.SpawnPlaced(island, entry.UniqueId, def.Node, worldCFrame)
		if not nodeModel then
			return nil
		end
		model = nodeModel
		entry.State = "Complete"
	else
		model = buildModel(entry.BuildingId)
		model.Name = entry.BuildingId
		model:PivotTo(worldCFrame)
		model.Parent = island.Folders.Buildings
	end
	model:SetAttribute("OwnerUserId", island.OwnerUserId)
	model:SetAttribute("IslandId", island.Id)
	model:SetAttribute("BuildingId", entry.BuildingId)
	model:SetAttribute("UniqueId", entry.UniqueId)

	local site: Site = {
		UniqueId = entry.UniqueId,
		BuildingId = entry.BuildingId,
		Def = def,
		Island = island,
		OwnerUserId = island.OwnerUserId,
		Model = model,
		Label = nil,
	}
	sites[entry.UniqueId] = site
	local list = sitesByIsland[island.Id]
	if not list then
		list = {}
		sitesByIsland[island.Id] = list
	end
	list[entry.UniqueId] = site

	if def.Node then
		-- nothing: node models are always "complete"
	elseif entry.State == "Complete" then
		BuildingModels.SetStage(model, math.huge, false)
	else
		BuildingModels.SetStage(model, entry.Progress, false)
		addSiteVisuals(site)
		updateSiteLabel(site, entry.Progress)
	end
	hideDecoUnder(island, model, def)
	if entry.State == "Complete" then
		BuildService.SiteReady:Fire(site)
	end
	return site
end

local function despawnSite(site: Site)
	BuildService.SiteRemoved:Fire(site)
	if site.Def.Node then
		ResourceService.RemovePlaced(site.Island, site.UniqueId)
	end
	sites[site.UniqueId] = nil
	local list = sitesByIsland[site.Island.Id]
	if list then
		list[site.UniqueId] = nil
	end
	InteractionService.Detach(site.Model)
	site.Model:Destroy()
end

---------------------------------------------------------------------------
-- Actions
---------------------------------------------------------------------------

local function costText(def: any, share: number?): string
	local parts = {}
	local scale = share or 1
	if def.Cost.Coins and def.Cost.Coins > 0 then
		table.insert(parts, ("%s 🪙"):format(Format.Commas(math.floor(def.Cost.Coins * scale))))
	end
	for itemId, amount in def.Cost.Items do
		table.insert(parts, ("%d %s"):format(math.floor(amount * scale), itemId))
	end
	return table.concat(parts, ", ")
end

function BuildService.Place(player: Player, buildingId: any, localX: any, localZ: any, rotation: any): (boolean, string?)
	local def = BuildingConfig.Get(buildingId)
	if not def or not Validate.Number(localX, -2000, 2000) or not Validate.Number(localZ, -2000, 2000) then
		AntiExploitService.Flag(player, "BadBuildRequest", 2)
		return false, "Invalid build request."
	end
	local now = os.clock()
	if lastPlace[player] and now - lastPlace[player] < BuildConfig.PlaceCooldown then
		return false, nil
	end
	lastPlace[player] = now

	local island = IslandService.GetIsland(player)
	if not island then
		return false, "Your island isn't ready yet."
	end
	local islandLevel = DataService.Get(player, { "Island", "Level" }) or 1
	if islandLevel < def.UnlockLevel then
		return false, ("%s unlocks at Island Level %d."):format(def.DisplayName, def.UnlockLevel)
	end
	if def.Hidden then
		AntiExploitService.Flag(player, "PlaceHiddenBuilding", 2)
		return false, nil
	end
	if def.Unique and BuildService.FindSite(island, buildingId) then
		return false, ("You already have a %s — move it instead."):format(def.DisplayName)
	end

	local ok, reason, worldCFrame, localPosition = BuildService.ValidatePlacement(player, island, def, localX, localZ, rotation)
	if not ok or not worldCFrame or not localPosition then
		return false, reason
	end

	-- Atomic payment: check everything first, then charge.
	local coins = def.Cost.Coins or 0
	if not EconomyService.CanAfford(player, coins) or not InventoryService.HasItems(player, def.Cost.Items) then
		return false, "You need " .. costText(def) .. "."
	end
	if not EconomyService.SpendCoins(player, coins, "Build:" .. buildingId) then
		return false, "You can't afford that."
	end
	if not InventoryService.RemoveItems(player, def.Cost.Items, "Build:" .. buildingId) then
		if coins > 0 then
			EconomyService.AddCoins(player, coins, "BuildRefund")
		end
		return false, "You don't have the materials."
	end

	local uniqueId = HttpService:GenerateGUID(false)
	local instant = def.Steps <= 0
	local entry = {
		BuildingId = buildingId,
		UniqueId = uniqueId,
		Position = Serializer.Vector3(localPosition),
		Rotation = rotation,
		Variant = "Default",
		State = if instant then "Complete" else "Constructing",
		Progress = 0,
	}
	DataService.Set(player, { "Island", "Buildings", uniqueId }, entry)
	local site = spawnSite(island, entry)
	if not site then
		return false, "Build failed."
	end
	BuildService.BuildingPlaced:Fire(player, site)
	if instant then
		GameSoundService.PlayAt(if def.Node then "PlantSeed" else "WoodPlace", worldCFrame.Position)
		VFXService.PlayAt(if def.Node then "LeafBurst" else "BuildDust", worldCFrame.Position + Vector3.new(0, 1, 0))
		VFXService.PlayAt("Puff", worldCFrame.Position, { Scale = 0.7 })
		VFXService.Jiggle(site.Model, "Pop")
		ProgressionService.Award(player, "BuildStep")
		BuildService.BuildingCompleted:Fire(player, site.BuildingId, def, site)
	else
		GameSoundService.PlayAt("ConstructionStart", worldCFrame.Position)
		VFXService.PlayAt("BuildDust", worldCFrame.Position + Vector3.new(0, 1, 0))
		VFXService.PlayAt("Puff", worldCFrame.Position, { Scale = 0.8 })
		VFXService.Jiggle(site.Model, "Pop")
		Notify.Success(player, ("%s placed! Hold your 🔨 hammer and click it %d times."):format(def.DisplayName, def.Steps), "🔨")
	end
	return true, nil
end

-- First site of a building type on an island (market stall lookups).
function BuildService.FindSite(island: any, buildingId: string): Site?
	for _, site in sitesByIsland[island.Id] or {} :: { [string]: Site } do
		if site.BuildingId == buildingId then
			return site
		end
	end
	return nil
end

local function complete(player: Player, site: Site)
	local def = site.Def
	DataService.Set(player, { "Island", "Buildings", site.UniqueId, "State" }, "Complete")
	removeSiteVisuals(site)
	BuildingModels.SetStage(site.Model, math.huge, true)
	local position = site.Model:GetPivot().Position
	VFXService.PlayAt("BuildComplete", position + Vector3.new(0, def.Height * 0.5, 0))
	VFXService.PlayAt("Confetti", position + Vector3.new(0, def.Height * 0.8, 0))
	VFXService.PlayAt("BigPuff", position, { Scale = math.clamp(def.Footprint.X / 10, 0.7, 1.6) })
	VFXService.Jiggle(site.Model, "Pop")
	GameSoundService.PlayAt("BuildComplete", position)
	VFXService.WobbleNear(position, 60, 0.8, 0.8)
	Notify.Banner(player, "BUILD COMPLETE!", def.DisplayName, "Build")
	ProgressionService.Award(player, "BuildComplete")
	DataService.Increment(player, { "Stats", "BuildingsBuilt" }, 1)
	if def.CapacityBonus then
		InventoryService.AddCapacity(player, def.CapacityBonus)
	end
	local character = player.Character
	if character then
		task.delay(0.6, function()
			AnimationService.PlayAnimation(character, "CelebrateBuild")
		end)
	end
	BuildService.SiteReady:Fire(site)
	BuildService.BuildingCompleted:Fire(player, site.BuildingId, def, site)
end

local function advance(player: Player, site: Site)
	local entry = entryOf(site)
	if not entry or entry.State ~= "Constructing" or not sites[site.UniqueId] then
		return
	end
	local progress = math.min(entry.Progress + 1, site.Def.Steps)
	DataService.Set(player, { "Island", "Buildings", site.UniqueId, "Progress" }, progress)
	BuildingModels.SetStage(site.Model, progress, true)
	local pivot = site.Model:GetPivot()
	local def = site.Def
	local offset = Vector3.new((math.random() - 0.5) * def.Footprint.X * 0.6, math.random() * def.Height * 0.6, (math.random() - 0.5) * def.Footprint.Y * 0.6)
	local hitPoint = (pivot * CFrame.new(offset)).Position
	AnimationService.Recoil(player.Character, 0.9)
	VFXService.PlayAt("BuildDust", hitPoint)
	VFXService.PlayAt("HitPop", hitPoint)
	VFXService.PlayAt("Stars", hitPoint, { Count = 4 })
	VFXService.Jiggle(site.Model, "Squash")
	GameSoundService.PlayAt("HammerHit", pivot.Position)
	ProgressionService.Award(player, "BuildStep")
	if progress >= def.Steps then
		complete(player, site)
	else
		updateSiteLabel(site, progress)
	end
end

-- A click on a construction site while holding a hammer.
function BuildService.Hammer(player: Player, uniqueId: any)
	local site = BuildService.GetSite(uniqueId)
	if not site then
		return
	end
	if not IslandService.CanAccess(player, site.Island, "Hammer") then
		return
	end
	local entry = entryOf(site)
	if not entry or entry.State ~= "Constructing" then
		return
	end
	local tool = ToolService.GetHeldTool(player, "Hammer")
	if not tool then
		local owned = ToolService.GetBestTool(player, "Hammer")
		Notify.Error(player, if owned then "Hold your 🔨 Hammer to build (pick it on your hotbar)." else "You need a Hammer — buy one at the market.")
		return
	end
	local now = os.clock()
	if lastHammer[player] and now - lastHammer[player] < BuildConfig.HammerCooldown then
		return
	end
	lastHammer[player] = now

	local isLast = entry.Progress + 1 >= site.Def.Steps
	AnimationService.PerformAction(player, if isLast then "HammerHeavy" else "HammerSwing", "HammerHit", function()
		-- The site's owner gets the progress (a helper can build for you).
		local owner = site.Island.Owner
		if owner and owner.Parent then
			advance(owner, site)
		end
	end, { Speed = tool.Speed })
end

function BuildService.Delete(player: Player, uniqueId: any): (boolean, string?)
	local site = BuildService.GetSite(uniqueId)
	if not site then
		return false, nil
	end
	if site.OwnerUserId ~= player.UserId then
		AntiExploitService.Flag(player, "DeleteForeignBuilding", 3)
		return false, "That isn't your building."
	end
	if site.Def.NoDelete then
		return false, ("Your %s can be moved, but not removed."):format(site.Def.DisplayName)
	end
	if deleteGuard then
		local allowed, reason = deleteGuard(player, site)
		if not allowed then
			return false, reason
		end
	end
	local entry = entryOf(site)
	local wasComplete = entry ~= nil and entry.State == "Complete"
	local share = if entry and entry.State == "Constructing" and entry.Progress == 0 then 1 else BuildingConfig.RefundPercent
	local def = site.Def

	local refundCoins = math.floor((def.Cost.Coins or 0) * share)
	if refundCoins > 0 then
		EconomyService.AddCoins(player, refundCoins, "BuildRefund")
	end
	for itemId, amount in def.Cost.Items do
		local refund = math.floor(amount * share)
		if refund > 0 then
			InventoryService.AddItem(player, itemId, refund, "BuildRefund", { IgnoreCapacity = true })
		end
	end
	if wasComplete and def.CapacityBonus then
		InventoryService.AddCapacity(player, -def.CapacityBonus)
	end

	local position = site.Model:GetPivot().Position
	local island = site.Island
	local localPosition = IslandService.ToLocal(island, position)
	despawnSite(site)
	DataService.Set(player, { "Island", "Buildings", uniqueId }, nil)
	restoreDecoAround(island, localPosition, def)
	VFXService.PlayAt("BuildDust", position + Vector3.new(0, 1, 0))
	Notify.Toast(player, ("Removed %s (refunded %s)."):format(def.DisplayName, if costText(def, share) ~= "" then costText(def, share) else "nothing"), "🗑️")
	BuildService.BuildingRemoved:Fire(player, uniqueId, site.BuildingId)
	return true, nil
end

function BuildService.Move(player: Player, uniqueId: any, localX: any, localZ: any, rotation: any): (boolean, string?)
	local site = BuildService.GetSite(uniqueId)
	if not site or not Validate.Number(localX, -2000, 2000) or not Validate.Number(localZ, -2000, 2000) then
		return false, nil
	end
	if site.OwnerUserId ~= player.UserId then
		AntiExploitService.Flag(player, "MoveForeignBuilding", 3)
		return false, "That isn't your building."
	end
	local ok, reason, worldCFrame, localPosition = BuildService.ValidatePlacement(player, site.Island, site.Def, localX, localZ, rotation, site.Model)
	if not ok or not worldCFrame or not localPosition then
		return false, reason
	end
	local oldLocal = IslandService.ToLocal(site.Island, site.Model:GetPivot().Position)
	if site.Def.Node then
		ResourceService.MovePlaced(site.Island, site.UniqueId, worldCFrame)
	else
		site.Model:PivotTo(worldCFrame)
	end
	restoreDecoAround(site.Island, oldLocal, site.Def)
	DataService.Set(player, { "Island", "Buildings", uniqueId, "Position" }, Serializer.Vector3(localPosition))
	DataService.Set(player, { "Island", "Buildings", uniqueId, "Rotation" }, rotation)
	VFXService.PlayAt("BuildDust", worldCFrame.Position + Vector3.new(0, 1, 0))
	GameSoundService.PlayAt("WoodPlace", worldCFrame.Position)
	BuildService.BuildingMoved:Fire(player, site)
	return true, nil
end

---------------------------------------------------------------------------
-- Admin / lifecycle
---------------------------------------------------------------------------

function BuildService.FinishAll(player: Player)
	for _, site in BuildService.GetSites(player) do
		local entry = entryOf(site)
		if entry and entry.State == "Constructing" then
			DataService.Set(player, { "Island", "Buildings", site.UniqueId, "Progress" }, site.Def.Steps)
			complete(player, site)
		end
	end
end

-- Every island gets a market stall and six soil tiles the first time it loads.
local function ensureStarterBuildings(player: Player)
	local layout = IslandConfig.StarterLayout
	local buildings = DataService.Get(player, { "Island", "Buildings" }) or {}
	local function add(buildingId: string, localXZ: Vector2, rotation: number)
		local uniqueId = HttpService:GenerateGUID(false)
		DataService.Set(player, { "Island", "Buildings", uniqueId }, {
			BuildingId = buildingId,
			UniqueId = uniqueId,
			Position = { X = localXZ.X, Y = IslandConfig.LandHeight, Z = localXZ.Y },
			Rotation = rotation,
			Variant = "Default",
			State = "Complete",
			Progress = 0,
		})
	end
	if not DataService.Get(player, { "Island", "StallPlaced" }) then
		local hasStall = false
		for _, entry in buildings do
			hasStall = hasStall or entry.BuildingId == "MarketStall"
		end
		if not hasStall then
			add("MarketStall", layout.MarketStall.Position, layout.MarketStall.Rotation)
		end
		DataService.Set(player, { "Island", "StallPlaced" }, true)
	end
	if not DataService.Get(player, { "Island", "StarterTilesPlaced" }) then
		for _, position in layout.SoilTiles do
			add("SoilTile", position, 0)
		end
		DataService.Set(player, { "Island", "StarterTilesPlaced" }, true)
	end
end

-- Snaps a saved Y to the real ground (starter buildings / migrated data).
local function groundedEntry(island: any, entry: any): any
	local position = Serializer.ToVector3(entry.Position)
	if position then
		local ground = IslandService.GetGroundCFrame(island, Vector2.new(position.X, position.Z))
		local y = ground.Position.Y - island.Origin.Position.Y
		if math.abs(y - position.Y) > 0.05 then
			entry.Position = { X = position.X, Y = y, Z = position.Z }
		end
	end
	return entry
end

local function loadIsland(player: Player, island: any)
	ensureStarterBuildings(player)
	local buildings = DataService.Get(player, { "Island", "Buildings" }) or {}
	for uniqueId, entry in buildings do
		local grounded = groundedEntry(island, table.clone(entry))
		if grounded.Position.Y ~= entry.Position.Y then
			DataService.Set(player, { "Island", "Buildings", uniqueId, "Position" }, grounded.Position)
		end
	end
	buildings = DataService.Get(player, { "Island", "Buildings" }) or {}
	for _, entry in buildings do
		local ok, err = pcall(spawnSite, island, entry)
		if not ok then
			warn("[BuildService] Could not load building " .. tostring(entry.UniqueId) .. ": " .. tostring(err))
		end
	end
end

local function clearIsland(islandId: string)
	local list = sitesByIsland[islandId]
	if not list then
		return
	end
	for uniqueId in list do
		sites[uniqueId] = nil
	end
	sitesByIsland[islandId] = nil
end

function BuildService.Init()
	InteractionService.RegisterKind("ConstructionSite", {
		Permission = "Hammer",
		MaxDistance = 9,
		Cooldown = 0.2,
		Handler = function(player: Player, model: Instance)
			BuildService.Hammer(player, model:GetAttribute("UniqueId"))
		end,
	})

	Net.OnServerEvent("BuildRequest", function(player: Player, payload: any)
		if type(payload) ~= "table" then
			AntiExploitService.Flag(player, "BadBuildRequest", 2)
			return
		end
		if payload.Op == "Place" then
			local ok, reason = BuildService.Place(player, payload.BuildingId, payload.X, payload.Z, payload.Rotation)
			if not ok and reason then
				Notify.Error(player, reason)
			end
		end
	end)

	Net.OnServerEvent("DeleteBuildRequest", function(player: Player, uniqueId: any)
		local ok, reason = BuildService.Delete(player, uniqueId)
		if not ok and reason then
			Notify.Error(player, reason)
		end
	end)

	Net.OnServerEvent("MoveBuildRequest", function(player: Player, uniqueId: any, localX: any, localZ: any, rotation: any)
		local ok, reason = BuildService.Move(player, uniqueId, localX, localZ, rotation)
		if not ok and reason then
			Notify.Error(player, reason)
		end
	end)
end

function BuildService.Start()
	IslandService.IslandAssigned:Connect(loadIsland)
	IslandService.IslandReleased:Connect(function(_player: Player, islandId: string)
		clearIsland(islandId)
	end)
end

return BuildService
