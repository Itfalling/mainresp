--[[
	SCRIPT NAME:  IslandService
	SCRIPT TYPE:  ModuleScript (server service)
	WHERE:        ServerScriptService/Server/Services/IslandService
	DEPENDENCIES: DataService, EconomyService, InventoryService, ProgressionService,
	              InteractionService, ToolService, SoundService, VFXService, WorldService,
	              AntiExploitService, Server.Island.IslandBuilder, Server.Island.IslandProps,
	              Shared.Config.{IslandConfig, GameConfig, ProgressionConfig}, Shared.Util.{IslandLayout, Validate}

	Owns everything about islands (spec §4-§6, §111):
	  * one island per player, placed in a free server SLOT,
	  * ownership (OwnerUserId + IslandId attributes on the model, and the
	    server-side maps below — never inferred from position alone),
	  * building / cleaning up island terrain and props,
	  * boundaries (IsPointBuildable) for later build/farm validation,
	  * access checks (CanAccess) used by every interaction,
	  * expansion unlocks (TryUnlockArea),
	  * the island's built-in interactables (starter chest, sign, 🔒 markers).
]]

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Shared
local Net = require(Shared.Net)
local GameConfig = require(Shared.Config.GameConfig)
local IslandConfig = require(Shared.Config.IslandConfig)
local ProgressionConfig = require(Shared.Config.ProgressionConfig)
local IslandLayout = require(Shared.Util.IslandLayout)
local Validate = require(Shared.Util.Validate)
local Format = require(Shared.Util.Format)
local Signal = require(Shared.Util.Signal)

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

local ServerRoot = script.Parent.Parent
local IslandBuilder = require(ServerRoot.Island.IslandBuilder)
local IslandProps = require(ServerRoot.Island.IslandProps)
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
	MarketStall: Model,
	SpawnCFrame: CFrame,
	AreaMarkers: { [string]: Model },
}

local IslandService = {}

IslandService.IslandAssigned = Signal.new() -- (player, island)
IslandService.IslandReleased = Signal.new() -- (player, islandId)
IslandService.AreaUnlocked = Signal.new() -- (player, areaId)

local slots: { [number]: boolean } = {}
local islandsByPlayer: { [Player]: Island } = {}
local islandsById: { [string]: Island } = {}

---------------------------------------------------------------------------
-- Queries
---------------------------------------------------------------------------

function IslandService.GetIsland(player: Player): Island?
	return islandsByPlayer[player]
end

function IslandService.GetIslandById(islandId: string): Island?
	return islandsById[islandId]
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
	local extent = IslandLayout.GetMaxExtent()
	for _, island in islandsById do
		local offset = worldPosition - island.Origin.Position
		if Vector2.new(offset.X, offset.Z).Magnitude <= extent then
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

function IslandService.GetUnlockedAreas(player: Player): { [string]: boolean }
	return DataService.Get(player, { "Island", "UnlockedAreas" }) or { Starter = true }
end

function IslandService.IsAreaUnlocked(player: Player, areaId: string): boolean
	return IslandService.GetUnlockedAreas(player)[areaId] == true
end

-- True if a world position is on land the island owner has unlocked.
function IslandService.IsPointBuildable(island: Island, worldPosition: Vector3): boolean
	local localPosition = IslandService.ToLocal(island, worldPosition)
	local unlocked = IslandService.GetUnlockedAreas(island.Owner)
	return IslandLayout.IsOnUnlockedLand(unlocked, Vector2.new(localPosition.X, localPosition.Z), IslandConfig.BuildMargin)
end

-- permission: "Owner" | "Visitor" | a future per-island permission key ("Build", "Fish", ...).
function IslandService.CanAccess(player: Player, island: Island, permission: string): boolean
	if island.OwnerUserId == player.UserId then
		return true
	end
	if permission == "Visitor" then
		return true
	end
	-- Phase 12 (VisitorService) adds Friends/Public + per-permission grants here.
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

---------------------------------------------------------------------------
-- Visual refresh
---------------------------------------------------------------------------

local function refreshSign(island: Island)
	local data = DataService.GetData(island.Owner)
	if not data then
		return
	end
	local level = data.Island.Level
	IslandProps.SetSignText(island.Sign, data.Island.Name, ("Lv %d · %s"):format(level, ProgressionConfig.GetIslandTitle(level)))
	island.Model:SetAttribute("IslandName", data.Island.Name)
	island.Model:SetAttribute("IslandLevel", level)
end

local function requirementText(areaId: string): string
	local unlock = IslandConfig.Areas[areaId].Unlock
	if not unlock then
		return ""
	end
	local text = ("%s 🪙 · Island Lv %d"):format(Format.Abbreviate(unlock.Coins or 0), unlock.IslandLevel or 1)
	if unlock.RequiresArea then
		text ..= " · after " .. IslandConfig.Areas[unlock.RequiresArea].DisplayName
	end
	return text
end

local function refreshChest(island: Island)
	local claimed = DataService.Get(island.Owner, { "Flags", "StarterChestClaimed" }) == true
	if claimed then
		IslandProps.OpenChest(island.Chest)
		InteractionService.SetEnabled(island.Chest, false)
	end
end

local function createAreaMarker(island: Island, areaId: string)
	local area = IslandConfig.Areas[areaId]
	local marker = IslandBuilder.CreateAreaMarker(island.Origin, island.Folders.AreaMarkers, areaId, requirementText(areaId))
	island.AreaMarkers[areaId] = marker
	InteractionService.Attach(marker, "AreaUnlock", {
		ObjectText = area.DisplayName,
		ActionText = ("Unlock (%s 🪙)"):format(Format.Abbreviate(area.Unlock and area.Unlock.Coins or 0)),
		OwnerUserId = island.OwnerUserId,
	})
end

---------------------------------------------------------------------------
-- Lifecycle
---------------------------------------------------------------------------

-- Yields while terrain builds. Requires the profile to be loaded.
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
	local model, folders = IslandBuilder.CreateModel("Island_" .. player.UserId, WorldService.GetFolder("Islands"))
	model:SetAttribute("OwnerUserId", player.UserId)
	model:SetAttribute("IslandId", islandId)
	model:SetAttribute("SlotIndex", slotIndex)
	model.WorldPivot = origin

	local built = IslandBuilder.Build(origin, model, folders, data.Island.UnlockedAreas)

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
		MarketStall = built.MarketStall,
		SpawnCFrame = built.SpawnCFrame,
		AreaMarkers = {},
	}
	islandsByPlayer[player] = island
	islandsById[islandId] = island

	InteractionService.Attach(island.Chest, "StarterChest", { OwnerUserId = player.UserId })
	InteractionService.Attach(island.Sign, "IslandSign", { OwnerUserId = player.UserId })
	for _, areaId in IslandConfig.AreaOrder do
		if not data.Island.UnlockedAreas[areaId] and IslandConfig.Areas[areaId].Unlock then
			createAreaMarker(island, areaId)
		end
	end
	refreshSign(island)
	refreshChest(island)

	if player.Parent == nil then
		-- Left while we were building.
		IslandService.ReleaseIsland(player)
		return nil
	end

	IslandService.IslandAssigned:Fire(player, island)
	if GameConfig.Debug then
		print(("[IslandService] %s -> slot %d (%s)"):format(player.Name, slotIndex, islandId))
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
	for _, marker in island.AreaMarkers do
		InteractionService.Detach(marker)
	end
	island.Model:Destroy()
	IslandBuilder.ClearTerrain(island.Origin, WorldService.RestoreOcean)
	slots[island.SlotIndex] = nil
	IslandService.IslandReleased:Fire(player, island.Id)
end

---------------------------------------------------------------------------
-- Expansion
---------------------------------------------------------------------------

local function liftCharactersOutOfArea(island: Island, areaId: string)
	for _, other in Players:GetPlayers() do
		local character = other.Character
		local root = character and character:FindFirstChild("HumanoidRootPart")
		if character and root and root:IsA("BasePart") then
			local localPosition = IslandService.ToLocal(island, root.Position)
			if IslandLayout.IsInArea(areaId, Vector2.new(localPosition.X, localPosition.Z), -2) and localPosition.Y < IslandConfig.SurfaceHeight + 2 then
				local ground = IslandBuilder.GroundCFrame(island.Origin, Vector2.new(localPosition.X, localPosition.Z))
				AntiExploitService.AllowTeleport(other)
				character:PivotTo(CFrame.new(ground.Position + Vector3.new(0, 4, 0)) * root.CFrame.Rotation)
			end
		end
	end
end

-- Returns (success, message).
function IslandService.TryUnlockArea(player: Player, areaId: any): (boolean, string?)
	if not Validate.Id(areaId) or not IslandConfig.Areas[areaId] then
		AntiExploitService.Flag(player, "InvalidAreaId", 2)
		return false, "That area doesn't exist."
	end
	local island = islandsByPlayer[player]
	if not island then
		return false, "Your island isn't ready yet."
	end
	local area = IslandConfig.Areas[areaId]
	local unlock = area.Unlock
	if not unlock or IslandService.IsAreaUnlocked(player, areaId) then
		return false, area.DisplayName .. " is already unlocked."
	end
	local islandLevel = DataService.Get(player, { "Island", "Level" }) or 1
	if islandLevel < (unlock.IslandLevel or 1) then
		return false, ("Reach Island Level %d to unlock %s."):format(unlock.IslandLevel, area.DisplayName)
	end
	if unlock.RequiresArea and not IslandService.IsAreaUnlocked(player, unlock.RequiresArea) then
		return false, ("Unlock %s first."):format(IslandConfig.Areas[unlock.RequiresArea].DisplayName)
	end
	if unlock.Items and not InventoryService.HasItems(player, unlock.Items) then
		return false, "You don't have the required materials."
	end
	local cost = unlock.Coins or 0
	if not EconomyService.SpendCoins(player, cost, "UnlockArea:" .. areaId) then
		return false, ("You need %s coins to unlock %s."):format(Format.Commas(cost), area.DisplayName)
	end
	if unlock.Items then
		InventoryService.RemoveItems(player, unlock.Items, "UnlockArea:" .. areaId)
	end

	DataService.Set(player, { "Island", "UnlockedAreas", areaId }, true)
	DataService.Increment(player, { "Stats", "AreasUnlocked" }, 1)

	local marker = island.AreaMarkers[areaId]
	if marker then
		island.AreaMarkers[areaId] = nil
		InteractionService.Detach(marker)
		marker:Destroy()
	end

	-- Satisfying reveal: the land rises out of the sea over ~1 second.
	local centerXZ = IslandLayout.GetAreaCenter(areaId)
	local centerWorld = IslandService.ToWorld(island, Vector3.new(centerXZ.X, IslandConfig.SurfaceHeight, centerXZ.Y))
	GameSoundService.PlayFor(player, "AreaUnlock")
	VFXService.PlayAt("AreaUnlock", centerWorld)
	VFXService.ShakeCamera(player, 0.5, 0.8)
	task.spawn(function()
		local steps = 12
		for step = 1, steps do
			IslandBuilder.FillAreaLand(island.Origin, areaId, step / steps)
			task.wait(0.07)
		end
		liftCharactersOutOfArea(island, areaId)
		-- Content (resources, fishing spots, farm plots) spawns once the land exists.
		if islandsByPlayer[player] == island then
			IslandService.AreaUnlocked:Fire(player, areaId)
		end
	end)

	Notify.Banner(player, "AREA UNLOCKED!", area.DisplayName .. " — " .. area.Reward, "AreaUnlock")
	ProgressionService.Award(player, "UnlockArea")
	return true, nil
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
	for itemId, amount in kit.Items do
		InventoryService.AddItem(player, itemId, amount, "StarterChest", { IgnoreCapacity = true })
	end
	for _, toolId in kit.Tools do
		ToolService.GrantTool(player, toolId, "StarterChest")
	end

	local island = islandsByPlayer[player]
	if island then
		refreshChest(island)
	end
	if chest:IsA("Model") then
		local pivot = chest:GetPivot().Position
		VFXService.PlayAt("ChestOpen", pivot + Vector3.new(0, 2.5, 0))
	end
	GameSoundService.PlayFor(player, "ChestOpen")
	Notify.Banner(player, "STARTER KIT!", "Tools, seeds, coins and materials — check your hotbar!", "Reward")
	ProgressionService.Award(player, "StarterChest")
end

local function readSign(player: Player, sign: Instance)
	local island = IslandService.GetIslandFromInstance(sign)
	if not island then
		return
	end
	local data = DataService.GetData(island.Owner)
	if not data then
		return
	end
	local unlockedCount = 0
	for _ in data.Island.UnlockedAreas do
		unlockedCount += 1
	end
	Notify.Toast(
		player,
		("%s · Level %d %s · %d/%d areas"):format(
			data.Island.Name,
			data.Island.Level,
			ProgressionConfig.GetIslandTitle(data.Island.Level),
			unlockedCount,
			#IslandConfig.AreaOrder
		),
		"🏝️"
	)
end

function IslandService.Init()
	InteractionService.RegisterKind("StarterChest", {
		ActionText = "Open",
		ObjectText = "Starter Chest",
		Permission = "Owner",
		HoldDuration = 0.4,
		MaxDistance = 10,
		Handler = claimStarterChest,
	})
	InteractionService.RegisterKind("IslandSign", {
		ActionText = "Read",
		ObjectText = "Island Sign",
		Permission = "Visitor",
		MaxDistance = 12,
		Cooldown = 1.5,
		Handler = readSign,
	})
	InteractionService.RegisterKind("AreaUnlock", {
		ActionText = "Unlock",
		ObjectText = "Locked Area",
		Permission = "Owner",
		HoldDuration = 0.8,
		MaxDistance = 12,
		Cooldown = 1,
		Handler = function(player: Player, marker: Instance)
			local ok, message = IslandService.TryUnlockArea(player, marker:GetAttribute("AreaId"))
			if not ok and message then
				Notify.Error(player, message)
			end
		end,
	})

	InteractionService.SetAccessResolver(function(player, object, permission, ownerUserId)
		local island = IslandService.GetIslandFromInstance(object)
		if island then
			return IslandService.CanAccess(player, island, permission)
		end
		return permission == "Visitor" or ownerUserId == nil or ownerUserId == player.UserId
	end)

	Net.OnServerEvent("UnlockAreaRequest", function(player: Player, areaId: any)
		local ok, message = IslandService.TryUnlockArea(player, areaId)
		if not ok and message then
			Notify.Error(player, message)
		end
	end)
end

function IslandService.Start()
	DataService.Changed:Connect(function(player: Player, path: { string })
		if path[1] ~= "Island" or (path[2] ~= "Name" and path[2] ~= "Level") then
			return
		end
		local island = islandsByPlayer[player]
		if island then
			refreshSign(island)
		end
	end)
end

return IslandService
