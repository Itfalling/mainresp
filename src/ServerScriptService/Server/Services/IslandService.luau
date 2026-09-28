--[[
	SCRIPT NAME:  IslandService
	SCRIPT TYPE:  ModuleScript (server service)
	WHERE:        ServerScriptService/Server/Services/IslandService
	DEPENDENCIES: DataService, EconomyService, InventoryService, ProgressionService,
	              InteractionService, ToolService, SoundService, VFXService, WorldService,
	              AntiExploitService, Server.Island.{IslandBuilder, IslandProps, IslandTerrain},
	              Shared.Config.{IslandConfig, GameConfig, ProgressionConfig}, Shared.Util.{IslandGen, IslandLayout, Validate}

	Owns everything about islands:
	  * CREATION: a new player picks a theme, shape, seed and name in the
	    Island Creator (CreateIslandRequest); the island is only built after.
	  * one island per player in a free server SLOT, built from saved data,
	  * ownership + ACCESS (owner, helpers, visitors) used by every interaction,
	  * EXPANSION: buy any water chunk touching your land (land rises from the sea),
	  * CUSTOMISATION: terrain paint, rename (TextService-filtered), visitor mode,
	    helper list,
	  * the island's built-in interactables (starter chest, sign).
]]

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextService = game:GetService("TextService")

local Shared = ReplicatedStorage.Shared
local Net = require(Shared.Net)
local GameConfig = require(Shared.Config.GameConfig)
local IslandConfig = require(Shared.Config.IslandConfig)
local IslandGen = require(Shared.Util.IslandGen)
local IslandLayout = require(Shared.Util.IslandLayout)
local Validate = require(Shared.Util.Validate)
local Format = require(Shared.Util.Format)
local Signal = require(Shared.Util.Signal)
local R15 = require(Shared.Util.R15)

local Services = script.Parent
local DataService = require(Services.DataService)
local EconomyService = require(Services.EconomyService)
local InventoryService = require(Services.InventoryService)
local ProgressionService = require(Services.ProgressionService)
local InteractionService = require(Services.InteractionService)
local ToolService = require(Services.ToolService)
local GameSoundService = require(Services.SoundService)
local VFXService = require(Services.VFXService)
local WorldService = require(Services.WorldService)
local AntiExploitService = require(Services.AntiExploitService)
local AnimationService = require(Services.AnimationService)

local ServerRoot = script.Parent.Parent
local IslandBuilder = require(ServerRoot.Island.IslandBuilder)
local IslandProps = require(ServerRoot.Island.IslandProps)
local IslandTerrain = require(ServerRoot.Island.IslandTerrain)
local Notify = require(ServerRoot.Util.Notify)

export type Island = {
	Id: string,
	Owner: Player,
	OwnerUserId: number,
	SlotIndex: number,
	Origin: CFrame,
	Model: Model,
	Folders: { [string]: Folder },
	Sign: Model,
	Chest: Model,
	SpawnCFrame: CFrame,
	Sampler: any,
	Theme: string,
}

local IslandService = {}

IslandService.IslandAssigned = Signal.new() -- (player, island)
IslandService.IslandReleased = Signal.new() -- (player, islandId)
IslandService.ChunkAdded = Signal.new() -- (player, island, cx, cz)
IslandService.IslandCreated = Signal.new() -- (player)
IslandService.Customized = Signal.new() -- (player, "Paint" | "Rename", amount)

local slots: { [number]: boolean } = {}
local islandsByPlayer: { [Player]: Island } = {}
local islandsById: { [string]: Island } = {}
local creationWaiters: { [Player]: any } = {}
local expanding: { [Player]: boolean } = {}

-- Permissions a HELPER gets on an island they were trusted on.
local HELPER_PERMISSIONS = { Gather = true, Farm = true, Animals = true, Hammer = true }
-- Permissions everyone who may visit gets.
local VISITOR_PERMISSIONS = { Visitor = true, Fish = true, Market = true }

---------------------------------------------------------------------------
-- Queries
---------------------------------------------------------------------------

function IslandService.GetIsland(player: Player): Island?
	return islandsByPlayer[player]
end

function IslandService.GetIslandById(islandId: string): Island?
	return islandsById[islandId]
end

function IslandService.GetIslands(): { Island }
	local list = {}
	for _, island in islandsById do
		table.insert(list, island)
	end
	return list
end

function IslandService.GetIslandOfUser(userId: number): Island?
	for player, island in islandsByPlayer do
		if player.UserId == userId then
			return island
		end
	end
	return nil
end

-- Finds the island an instance belongs to by walking up to the island model.
function IslandService.GetIslandFromInstance(instance: Instance): Island?
	local current: Instance? = instance
	while current and current ~= workspace do
		local islandId = current:GetAttribute("IslandId")
		if type(islandId) == "string" then
			return islandsById[islandId]
		end
		current = current.Parent
	end
	return nil
end

function IslandService.GetIslandAtPosition(worldPosition: Vector3): Island?
	local extent = (IslandConfig.GridRadius + 2) * IslandConfig.ChunkSize
	for _, island in islandsById do
		local offset = worldPosition - island.Origin.Position
		if math.abs(offset.X) <= extent and math.abs(offset.Z) <= extent then
			return island
		end
	end
	return nil
end

function IslandService.ToLocal(island: Island, worldPosition: Vector3): Vector3
	return island.Origin:PointToObjectSpace(worldPosition)
end

function IslandService.ToWorld(island: Island, localPosition: Vector3): Vector3
	return island.Origin:PointToWorldSpace(localPosition)
end

function IslandService.GetSampler(island: Island): any
	return island.Sampler
end

-- True if a world position is buildable land on this island.
function IslandService.IsPointBuildable(island: Island, worldPosition: Vector3): boolean
	local localPosition = IslandService.ToLocal(island, worldPosition)
	return IslandGen.IsBuildable(island.Sampler, localPosition.X, localPosition.Z)
end

local function accessOf(owner: Player): any
	return DataService.Get(owner, { "Island", "Access" }) or {}
end

function IslandService.IsHelper(island: Island, userId: number): boolean
	local helpers = accessOf(island.Owner).Helpers
	return type(helpers) == "table" and helpers[tostring(userId)] == true
end

-- permission: "Owner" | "Visitor" | "Fish" | "Market" | "Gather" | "Farm" | "Animals" | "Hammer" | "Build"
function IslandService.CanAccess(player: Player, island: Island, permission: string): boolean
	if island.OwnerUserId == player.UserId then
		return true
	end
	if VISITOR_PERMISSIONS[permission] then
		return true
	end
	if HELPER_PERMISSIONS[permission] then
		return IslandService.IsHelper(island, player.UserId)
	end
	return false
end

-- World CFrame on the terrain surface at an island-local XZ point.
function IslandService.GetGroundCFrame(island: Island, localXZ: Vector2, yawDegrees: number?): CFrame
	return IslandBuilder.GroundCFrame(island.Origin, localXZ, yawDegrees)
end

function IslandService.GetSpawnCFrame(player: Player): CFrame?
	local island = islandsByPlayer[player]
	return island and island.SpawnCFrame
end

local function islandData(player: Player): any
	return DataService.Get(player, { "Island" })
end

local function newSampler(player: Player): any
	local data = islandData(player)
	return IslandGen.NewSampler({
		Seed = data.Seed,
		Theme = data.Theme,
		Shape = data.Shape,
		Chunks = table.clone(data.Chunks),
		Paint = table.clone(data.Paint),
	})
end

---------------------------------------------------------------------------
-- Visual refresh
---------------------------------------------------------------------------

local function refreshSign(island: Island)
	local data = DataService.GetData(island.Owner)
	if not data then
		return
	end
	local level = data.Island.Level
	local theme = IslandConfig.Themes[data.Island.Theme]
	IslandProps.SetSignText(
		island.Sign,
		data.Island.Name,
		("%s Lv %d · ❤️ %s"):format(if theme then theme.Icon else "🏝️", level, Format.Abbreviate(data.Island.Likes or 0))
	)
	local model = island.Model
	model:SetAttribute("IslandName", data.Island.Name)
	model:SetAttribute("IslandLevel", level)
	model:SetAttribute("Likes", data.Island.Likes or 0)
	model:SetAttribute("Theme", data.Island.Theme)
	model:SetAttribute("Chunks", IslandGen.CountChunks(data.Island.Chunks))
	model:SetAttribute("VisitorMode", (data.Island.Access and data.Island.Access.Visitors) or "Everyone")
	model:SetAttribute("OwnerName", island.Owner.DisplayName)
	local helpers = {}
	for userId in (data.Island.Access and data.Island.Access.Helpers) or {} do
		table.insert(helpers, userId)
	end
	model:SetAttribute("Helpers", table.concat(helpers, ","))
end

local function refreshChest(island: Island)
	local claimed = DataService.Get(island.Owner, { "Flags", "StarterChestClaimed" }) == true
	if claimed then
		IslandProps.OpenChest(island.Chest)
		InteractionService.SetEnabled(island.Chest, false)
	end
end

---------------------------------------------------------------------------
-- Creation
---------------------------------------------------------------------------

function IslandService.IsCreated(player: Player): boolean
	return DataService.Get(player, { "Island", "Created" }) == true
end

-- Yields until the player has created their island (or left). Returns true if created.
function IslandService.WaitForCreation(player: Player): boolean
	if IslandService.IsCreated(player) then
		return true
	end
	local signal = creationWaiters[player]
	if not signal then
		signal = Signal.new()
		creationWaiters[player] = signal
	end
	while player.Parent and not IslandService.IsCreated(player) do
		signal:Wait()
	end
	creationWaiters[player] = nil
	return player.Parent ~= nil and IslandService.IsCreated(player)
end

-- Filters player text for everyone to see. Returns nil if it can't be filtered.
function IslandService.FilterText(player: Player, text: string): string?
	local ok, result = pcall(function()
		local filtered = TextService:FilterStringAsync(text, player.UserId, Enum.TextFilterContext.PublicChat)
		return filtered:GetNonChatStringForBroadcastAsync()
	end)
	if ok and type(result) == "string" then
		return result
	end
	return nil
end

local function cleanName(player: Player, name: any): (string?, string?)
	if type(name) ~= "string" then
		return nil, "Pick a name for your island."
	end
	name = string.gsub(name, "^%s+", "")
	name = string.gsub(name, "%s+$", "")
	if utf8.len(name) == nil or #name < 3 or (utf8.len(name) :: number) > IslandConfig.NameMaxLength then
		return nil, ("Island names need 3-%d characters."):format(IslandConfig.NameMaxLength)
	end
	local filtered = IslandService.FilterText(player, name)
	if not filtered then
		return nil, "Couldn't check that name right now — try again."
	end
	return filtered, nil
end

local function onCreateRequest(player: Player, payload: any)
	if type(payload) ~= "table" or IslandService.IsCreated(player) or not DataService.IsLoaded(player) then
		return
	end
	local theme, shape, seed = payload.Theme, payload.Shape, payload.Seed
	if not IslandConfig.Themes[theme] or not IslandConfig.Shapes[shape] or not Validate.Integer(seed, 1, 2_000_000_000) then
		AntiExploitService.Flag(player, "BadCreateIsland", 2)
		return
	end
	local name, reason = cleanName(player, payload.Name)
	if not name then
		name = IslandConfig.DefaultNameFormat:format(player.DisplayName)
		if reason and type(payload.Name) == "string" and payload.Name ~= "" then
			Notify.Toast(player, reason, "✏️")
		end
	end
	DataService.Set(player, { "Island", "Theme" }, theme)
	DataService.Set(player, { "Island", "Shape" }, shape)
	DataService.Set(player, { "Island", "Seed" }, seed)
	DataService.Set(player, { "Island", "Name" }, name)
	DataService.Set(player, { "Island", "Chunks" }, IslandGen.GenerateStarter(seed, shape))
	DataService.Set(player, { "Island", "Created" }, true)
	local signal = creationWaiters[player]
	if signal then
		signal:Fire()
	end
	IslandService.IslandCreated:Fire(player)
end

---------------------------------------------------------------------------
-- Lifecycle
---------------------------------------------------------------------------

-- Yields while terrain builds. Requires the profile to be loaded and the island created.
function IslandService.AssignIsland(player: Player): Island?
	local existing = islandsByPlayer[player]
	if existing then
		return existing
	end
	local data = DataService.GetData(player)
	if not data then
		warn("[IslandService] Cannot assign an island before data loads for " .. player.Name)
		return nil
	end

	local slotIndex = nil
	for index = 1, GameConfig.MaxIslandsPerServer do
		if not slots[index] then
			slotIndex = index
			break
		end
	end
	if not slotIndex then
		warn("[IslandService] No free island slots (raise GameConfig.MaxIslandsPerServer)")
		return nil
	end
	slots[slotIndex] = true

	if data.Island.IslandId == "" then
		DataService.Set(player, { "Island", "IslandId" }, HttpService:GenerateGUID(false))
	end
	if data.Island.Name == "" then
		DataService.Set(player, { "Island", "Name" }, IslandConfig.DefaultNameFormat:format(player.DisplayName))
	end
	local islandId = data.Island.IslandId

	local origin = IslandLayout.GetSlotOrigin(slotIndex)
	local model, folders = IslandBuilder.CreateModel("Island_" .. player.UserId, WorldService.GetFolder("Islands"), origin)
	model:SetAttribute("OwnerUserId", player.UserId)
	model:SetAttribute("IslandId", islandId)
	model:SetAttribute("SlotIndex", slotIndex)

	local sampler = newSampler(player)
	local ok, builtOrError = pcall(IslandBuilder.Build, origin, folders, sampler)
	if not ok then
		slots[slotIndex] = nil
		model:Destroy()
		error(builtOrError)
	end
	local built = builtOrError

	local island: Island = {
		Id = islandId,
		Owner = player,
		OwnerUserId = player.UserId,
		SlotIndex = slotIndex,
		Origin = origin,
		Model = model,
		Folders = folders,
		Sign = built.Sign,
		Chest = built.Chest,
		SpawnCFrame = built.SpawnCFrame,
		Sampler = sampler,
		Theme = data.Island.Theme,
	}
	islandsByPlayer[player] = island
	islandsById[islandId] = island

	InteractionService.Attach(island.Chest, "StarterChest", { OwnerUserId = player.UserId, Label = "Starter Chest" })
	InteractionService.Attach(island.Sign, "IslandSign", { OwnerUserId = player.UserId, Label = "Island Sign" })
	refreshSign(island)
	refreshChest(island)

	if player.Parent == nil then
		IslandService.ReleaseIsland(player)
		return nil
	end

	IslandService.IslandAssigned:Fire(player, island)
	if GameConfig.Debug then
		print(("[IslandService] %s -> slot %d (%s, %s %s, %d chunks)"):format(player.Name, slotIndex, islandId, data.Island.Theme, data.Island.Shape, IslandGen.CountChunks(data.Island.Chunks)))
	end
	return island
end

-- Destroys the island and restores open ocean. Call AFTER the final save.
function IslandService.ReleaseIsland(player: Player)
	local island = islandsByPlayer[player]
	if not island then
		return
	end
	islandsByPlayer[player] = nil
	islandsById[island.Id] = nil
	InteractionService.Detach(island.Chest)
	InteractionService.Detach(island.Sign)
	-- Visitors standing on the island go home first (VisitService listens too).
	IslandService.IslandReleased:Fire(player, island.Id)
	island.Model:Destroy()
	IslandTerrain.Clear(island.Origin)
	slots[island.SlotIndex] = nil
end

---------------------------------------------------------------------------
-- Expansion
---------------------------------------------------------------------------

function IslandService.GetChunkCount(player: Player): number
	return IslandGen.CountChunks(DataService.Get(player, { "Island", "Chunks" }) or {})
end

function IslandService.GetExpansionInfo(player: Player): (number, number, number)
	local count = IslandService.GetChunkCount(player)
	local level = DataService.Get(player, { "Island", "Level" }) or 1
	return count, IslandGen.MaxChunks(level), IslandGen.ExpansionCost(count)
end

local function liftCharacters(island: Island, minX: number, maxX: number, minZ: number, maxZ: number)
	for _, other in Players:GetPlayers() do
		local character = other.Character
		local root = R15.GetRootPart(character)
		if character and root then
			local localPosition = IslandService.ToLocal(island, root.Position)
			if localPosition.X >= minX and localPosition.X <= maxX and localPosition.Z >= minZ and localPosition.Z <= maxZ then
				local ground = IslandBuilder.GroundCFrame(island.Origin, Vector2.new(localPosition.X, localPosition.Z))
				if root.Position.Y < ground.Position.Y + 2 then
					AntiExploitService.AllowTeleport(other)
					character:PivotTo(CFrame.new(ground.Position + Vector3.new(0, 4, 0)) * root.CFrame.Rotation)
				end
			end
		end
	end
end

-- Returns (success, message).
function IslandService.TryExpand(player: Player, cx: any, cz: any): (boolean, string?)
	if not Validate.Integer(cx, -IslandConfig.GridRadius, IslandConfig.GridRadius) or not Validate.Integer(cz, -IslandConfig.GridRadius, IslandConfig.GridRadius) then
		AntiExploitService.Flag(player, "BadExpand", 2)
		return false, nil
	end
	local island = islandsByPlayer[player]
	if not island then
		return false, "Your island isn't ready yet."
	end
	if expanding[player] then
		return false, "Wait for the land to finish rising!"
	end
	local chunks = DataService.Get(player, { "Island", "Chunks" }) or {}
	local key = IslandGen.Key(cx, cz)
	if chunks[key] then
		return false, "You already own that land."
	end
	if not IslandGen.IsAdjacent(chunks, cx, cz) then
		return false, "New land must touch your island."
	end
	local count, maxChunks, cost = IslandService.GetExpansionInfo(player)
	if count >= maxChunks then
		return false, ("Level up your island to expand further (max %d land at this level)."):format(maxChunks)
	end
	if not EconomyService.SpendCoins(player, cost, "Expand:" .. key) then
		return false, ("You need %s 🪙 to expand here."):format(Format.Commas(cost))
	end

	expanding[player] = true
	local previous = island.Sampler
	DataService.Set(player, { "Island", "Chunks", key }, true)
	DataService.Increment(player, { "Stats", "AreasUnlocked" }, 1)
	local sampler = newSampler(player)
	island.Sampler = sampler

	local minX, maxX, minZ, maxZ = IslandTerrain.ChunkBounds(cx, cz)
	local centerWorld = IslandService.ToWorld(island, Vector3.new(cx * IslandConfig.ChunkSize, IslandConfig.LandHeight, cz * IslandConfig.ChunkSize))
	GameSoundService.PlayAt("AreaUnlock", centerWorld)
	VFXService.PlayAt("AreaUnlock", centerWorld)
	VFXService.ShakeCamera(player, 0.35, 0.8)
	task.spawn(function()
		local steps = 8
		for step = 1, steps do
			if islandsByPlayer[player] ~= island then
				expanding[player] = nil
				return
			end
			local alpha = step / steps
			IslandTerrain.Write(island.Origin, sampler, minX, maxX, minZ, maxZ, previous, alpha * alpha * (3 - 2 * alpha))
			task.wait(0.08)
		end
		liftCharacters(island, minX, maxX, minZ, maxZ)
		IslandBuilder.DecorateChunk(island.Origin, island.Folders, sampler, cx, cz)
		expanding[player] = nil
		refreshSign(island)
		IslandService.ChunkAdded:Fire(player, island, cx, cz)
	end)

	ProgressionService.Award(player, "UnlockArea")
	Notify.Toast(player, ("New land! (%d/%d)"):format(count + 1, maxChunks), "🏝️")
	return true, nil
end

---------------------------------------------------------------------------
-- Customisation
---------------------------------------------------------------------------

local PAINT_BATCH = 24

-- cells = { {X, Z}, ... } paint-grid coordinates; material "" erases.
function IslandService.Paint(player: Player, cells: any, material: any): (boolean, string?)
	local island = islandsByPlayer[player]
	if not island or type(cells) ~= "table" or #cells == 0 or #cells > PAINT_BATCH then
		return false, nil
	end
	if material ~= "" and not IslandConfig.Paint[material] then
		AntiExploitService.Flag(player, "BadPaintMaterial", 2)
		return false, nil
	end
	local paint = DataService.Get(player, { "Island", "Paint" }) or {}
	local count = 0
	for _ in paint do
		count += 1
	end
	local cellSize = IslandConfig.PaintCellSize
	local limit = (IslandConfig.GridRadius + 1) * IslandConfig.ChunkSize / cellSize
	local minX, maxX, minZ, maxZ = math.huge, -math.huge, math.huge, -math.huge
	local changed = 0
	for _, cell in cells do
		if type(cell) == "table" and Validate.Integer(cell.X, -limit, limit) and Validate.Integer(cell.Z, -limit, limit) then
			local centerX, centerZ = (cell.X + 0.5) * cellSize, (cell.Z + 0.5) * cellSize
			local cx, cz = IslandGen.ChunkOf(centerX, centerZ)
			local key = cell.X .. "_" .. cell.Z
			if island.Sampler:IsOwnedChunk(cx, cz) and (paint[key] or "") ~= material then
				if material ~= "" and paint[key] == nil then
					if count >= IslandConfig.MaxPaintCells then
						return false, "You've painted as much as an island can hold — erase some first."
					end
					count += 1
				end
				DataService.Set(player, { "Island", "Paint", key }, if material == "" then nil else material)
				minX, maxX = math.min(minX, cell.X * cellSize), math.max(maxX, (cell.X + 1) * cellSize)
				minZ, maxZ = math.min(minZ, cell.Z * cellSize), math.max(maxZ, (cell.Z + 1) * cellSize)
				changed += 1
			end
		end
	end
	if changed == 0 then
		return false, nil
	end
	island.Sampler = newSampler(player)
	IslandTerrain.Write(island.Origin, island.Sampler, minX - 4, maxX + 4, minZ - 4, maxZ + 4)
	if material ~= "" then
		IslandService.Customized:Fire(player, "Paint", changed)
	end
	return true, nil
end

function IslandService.Rename(player: Player, name: any): (boolean, string?)
	local island = islandsByPlayer[player]
	if not island then
		return false, nil
	end
	local cleaned, reason = cleanName(player, name)
	if not cleaned then
		return false, reason
	end
	DataService.Set(player, { "Island", "Name" }, cleaned)
	Notify.Success(player, "Island renamed to " .. cleaned .. "!", "✏️")
	IslandService.Customized:Fire(player, "Rename", 1)
	return true, nil
end

local function onSettingsRequest(player: Player, payload: any)
	local island = islandsByPlayer[player]
	if not island or type(payload) ~= "table" then
		return
	end
	if payload.Visitors ~= nil then
		if not table.find(IslandConfig.VisitorModes, payload.Visitors) then
			AntiExploitService.Flag(player, "BadVisitorMode", 2)
			return
		end
		DataService.Set(player, { "Island", "Access", "Visitors" }, payload.Visitors)
		Notify.Toast(player, "Visitors: " .. payload.Visitors, "🚪")
	end
	if payload.Helper ~= nil then
		local userId = payload.Helper
		if not Validate.Integer(userId, 1, 1e12) or userId == player.UserId then
			return
		end
		local allowed = payload.Allowed == true
		DataService.Set(player, { "Island", "Access", "Helpers", tostring(userId) }, if allowed then true else nil)
		local other = Players:GetPlayerByUserId(userId)
		if other then
			Notify.Toast(player, (if allowed then "%s can now help on your island." else "%s is no longer a helper."):format(other.DisplayName), "🤝")
			if allowed then
				Notify.Toast(other, ("%s made you a helper on their island!"):format(player.DisplayName), "🤝")
			end
		end
	end
	refreshSign(island)
end

---------------------------------------------------------------------------
-- Built-in interactables
---------------------------------------------------------------------------

local function claimStarterChest(player: Player, chest: Instance)
	if DataService.Get(player, { "Flags", "StarterChestClaimed" }) then
		Notify.Toast(player, "You already opened your starter chest.")
		return
	end
	local kit = GameConfig.StarterKit
	DataService.Set(player, { "Flags", "StarterChestClaimed" }, true)
	EconomyService.AddCoins(player, kit.Coins, "StarterChest")
	for _, toolId in kit.Tools do
		ToolService.GrantTool(player, toolId, "StarterChest")
	end
	for itemId, amount in kit.Items do
		InventoryService.AddItem(player, itemId, amount, "StarterChest", { IgnoreCapacity = true })
	end

	local island = islandsByPlayer[player]
	if island then
		refreshChest(island)
	end
	if player.Character then
		AnimationService.PlayAnimation(player.Character, "OpenChest")
	end
	if chest:IsA("Model") then
		local pivot = chest:GetPivot().Position
		VFXService.PlayAt("ChestOpen", pivot + Vector3.new(0, 2.5, 0))
	end
	GameSoundService.PlayFor(player, "ChestOpen")
	Notify.Banner(player, "STARTER KIT!", "Tools and seeds are in your hotbar — press 1-9 to hold one!", "Reward")
	ProgressionService.Award(player, "StarterChest")
end

local function openSign(player: Player, sign: Instance)
	local island = IslandService.GetIslandFromInstance(sign)
	if not island then
		return
	end
	if island.Owner == player then
		Net.FireClient("OpenUI", player, { Screen = "IslandSettings" })
		return
	end
	local data = DataService.GetData(island.Owner)
	if not data then
		return
	end
	Net.FireClient("OpenUI", player, {
		Screen = "IslandInfo",
		OwnerUserId = island.OwnerUserId,
		OwnerName = island.Owner.DisplayName,
		Name = data.Island.Name,
		Level = data.Island.Level,
		Likes = data.Island.Likes or 0,
		Theme = data.Island.Theme,
		Chunks = IslandGen.CountChunks(data.Island.Chunks),
	})
end

function IslandService.RefreshSign(player: Player)
	local island = islandsByPlayer[player]
	if island then
		refreshSign(island)
	end
end

function IslandService.Init()
	InteractionService.RegisterKind("StarterChest", {
		Permission = "Owner",
		MaxDistance = 12,
		Cooldown = 1,
		Handler = claimStarterChest,
	})
	InteractionService.RegisterKind("IslandSign", {
		Permission = "Visitor",
		MaxDistance = 14,
		Cooldown = 1,
		Handler = openSign,
	})

	InteractionService.SetAccessResolver(function(player, object, permission, ownerUserId)
		local island = IslandService.GetIslandFromInstance(object)
		if island then
			return IslandService.CanAccess(player, island, permission)
		end
		return permission == "Visitor" or ownerUserId == nil or ownerUserId == player.UserId
	end)

	Net.OnServerEvent("CreateIslandRequest", onCreateRequest)
	Net.OnServerEvent("ExpandIslandRequest", function(player: Player, cx: any, cz: any)
		local ok, message = IslandService.TryExpand(player, cx, cz)
		if not ok and message then
			Notify.Error(player, message)
		end
	end)
	Net.OnServerEvent("PaintTerrainRequest", function(player: Player, cells: any, material: any)
		local ok, message = IslandService.Paint(player, cells, material)
		if not ok and message then
			Notify.Error(player, message)
		end
	end)
	Net.OnServerEvent("RenameIslandRequest", function(player: Player, name: any)
		local ok, message = IslandService.Rename(player, name)
		if not ok and message then
			Notify.Error(player, message)
		end
	end)
	Net.OnServerEvent("IslandSettingsRequest", onSettingsRequest)
end

function IslandService.Start()
	DataService.Changed:Connect(function(player: Player, path: { string })
		if path[1] ~= "Island" then
			return
		end
		local key = path[2]
		if key == "Name" or key == "Level" or key == "Likes" or key == "Access" then
			local island = islandsByPlayer[player]
			if island then
				refreshSign(island)
			end
		end
	end)
	Players.PlayerRemoving:Connect(function(player)
		expanding[player] = nil
		local signal = creationWaiters[player]
		if signal then
			signal:Fire()
		end
	end)
end

return IslandService
