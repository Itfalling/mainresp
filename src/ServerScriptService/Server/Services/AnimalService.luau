--[[
	SCRIPT NAME:  AnimalService
	SCRIPT TYPE:  ModuleScript (server service)
	WHERE:        ServerScriptService/Server/Services/AnimalService
	DEPENDENCIES: DataService, IslandService, BuildService, InventoryService, ProgressionService,
	              InteractionService, ToolService, AnimationService, SoundService, VFXService,
	              Server.Island.AnimalModels, Shared.Config.AnimalConfig, Shared.Util.AnimalMath

	Animals that feel alive (spec §24-§28, §100, §114, §144).

	  * Every animal lives in a HOUSING building (Barn / Chicken Coop) and
	    wanders inside its pen. Buying needs free housing capacity.
	  * Care loop (AnimalMath, all timestamp-based) — hold something and CLICK:
	        holding 🌾 Wheat + hungry  -> Feed, production starts
	        ... ProduceTime ...        -> holding 🪣 Bucket: Milk Cow / any hand: Collect Eggs
	        anything else              -> Pet (cooldown) -> happiness
	  * The client animates legs / head / tail from the AnimalAnim attribute
	    ("Idle" | "Walk" | "Eat" | "Happy") the server sets.
	  * Server-authoritative: actions go through AnimationService.PerformAction
	    so the reward lands on the animation's Milk/Feed/Pet marker.
	  * Performance tiers: animals only wander while a player is within
	    ActiveRange; one shared loop, a few tweens — never per-frame AI.

	Model attributes (read by the client's billboards): AnimalId, UniqueId,
	Variant, Happiness, Status, ReadyAt, OwnerUserId. Tag: "Animal".
]]

local CollectionService = game:GetService("CollectionService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Shared = ReplicatedStorage.Shared
local AnimalConfig = require(Shared.Config.AnimalConfig)
local AnimalMath = require(Shared.Util.AnimalMath)
local Signal = require(Shared.Util.Signal)
local R15 = require(Shared.Util.R15)

local Services = script.Parent
local DataService = require(Services.DataService)
local IslandService = require(Services.IslandService)
local BuildService = require(Services.BuildService)
local InventoryService = require(Services.InventoryService)
local ProgressionService = require(Services.ProgressionService)
local InteractionService = require(Services.InteractionService)
local ToolService = require(Services.ToolService)
local AnimationService = require(Services.AnimationService)
local GameSoundService = require(Services.SoundService)
local VFXService = require(Services.VFXService)
local AnimalModels = require(script.Parent.Parent.Island.AnimalModels)
local Notify = require(script.Parent.Parent.Util.Notify)

local TAG = "Animal"
local STATUS_TICK = 2

type Animal = {
	UniqueId: string,
	AnimalId: string,
	Def: any,
	Owner: Player,
	Island: any,
	Model: Model,
	Body: BasePart,
	BodyOffset: CFrame,
	Home: CFrame,
	PenRadius: number,
	Moving: boolean,
	Status: string,
}

local AnimalService = {}

AnimalService.AnimalFed = Signal.new() -- (player, animalId)
AnimalService.ProduceCollected = Signal.new() -- (player, animalId, itemId, amount)
AnimalService.AnimalAdded = Signal.new() -- (player, animalId)

local animalsByIsland: { [string]: { [string]: Animal } } = {}
local random = Random.new()
local groundParams = RaycastParams.new()
groundParams.FilterType = Enum.RaycastFilterType.Include
groundParams.IgnoreWater = true

local function entryOf(animal: Animal): any
	return DataService.Get(animal.Owner, { "Island", "Animals", animal.UniqueId })
end

local function writeEntry(animal: Animal, changes: { [string]: any })
	local entry = entryOf(animal)
	if not entry then
		return
	end
	local updated = table.clone(entry)
	for key, value in changes do
		updated[key] = value
	end
	DataService.Set(animal.Owner, { "Island", "Animals", animal.UniqueId }, updated)
end

local function variantDef(def: any, variantId: string?): any
	for _, variant in def.Variants do
		if variant.Id == variantId then
			return variant
		end
	end
	return def.Variants[1]
end

local function rollVariant(def: any): string
	local total = 0
	for _, variant in def.Variants do
		total += variant.Weight
	end
	local roll = random:NextNumber(0, total)
	for _, variant in def.Variants do
		roll -= variant.Weight
		if roll <= 0 then
			return variant.Id
		end
	end
	return def.Variants[1].Id
end

---------------------------------------------------------------------------
-- Housing
---------------------------------------------------------------------------

local function housingSites(player: Player, animalId: string): { any }
	local list = {}
	for _, site in BuildService.GetSites(player) do
		if site.Def.Capacity and site.Def.Capacity[animalId] and BuildService.IsComplete(site) then
			table.insert(list, site)
		end
	end
	return list
end

local function residents(player: Player, housingId: string): number
	local count = 0
	for _, entry in DataService.Get(player, { "Island", "Animals" }) or {} do
		if entry.HousingId == housingId then
			count += 1
		end
	end
	return count
end

local function penOf(site: any): (CFrame, number)
	local pen = site.Def.Pen or { Offset = Vector2.zero, Radius = 3 }
	return site.Model:GetPivot() * CFrame.new(pen.Offset.X, 0, pen.Offset.Y), pen.Radius
end

-- Returns (housingSite?, reason?)
function AnimalService.FindHousing(player: Player, animalId: string): (any?, string?)
	local def = AnimalConfig.Animals[animalId]
	if not def then
		return nil, "Unknown animal."
	end
	local sitesList = housingSites(player, animalId)
	if #sitesList == 0 then
		return nil, ("Build a %s first to house a %s."):format(def.Housing == "ChickenCoop" and "Chicken Coop" or def.Housing, def.DisplayName)
	end
	for _, site in sitesList do
		if residents(player, site.UniqueId) < site.Def.Capacity[animalId] then
			return site, nil
		end
	end
	return nil, ("Your %s is full — build another one."):format(def.Housing == "ChickenCoop" and "Chicken Coop" or def.Housing)
end

---------------------------------------------------------------------------
-- Spawning
---------------------------------------------------------------------------

local function groundY(position: Vector3): number
	groundParams.FilterDescendantsInstances = { workspace.Terrain }
	local result = workspace:Raycast(position + Vector3.new(0, 20, 0), Vector3.new(0, -60, 0), groundParams)
	return if result then result.Position.Y else position.Y
end

local function statusText(animal: Animal, entry: any, now: number): string
	local status = AnimalMath.GetStatus(entry, now)
	if status == "Ready" then
		return animal.Def.ProduceVerb
	elseif status == "Hungry" then
		return ("Feed (%d %s)"):format(animal.Def.FoodAmount, animal.Def.Food)
	end
	return "Pet"
end

local function refresh(animal: Animal)
	local entry = entryOf(animal)
	if not entry then
		return
	end
	local now = os.time()
	local status = AnimalMath.GetStatus(entry, now)
	animal.Status = status
	local model = animal.Model
	model:SetAttribute("Status", status)
	model:SetAttribute("Happiness", math.floor(AnimalMath.GetHappiness(entry, now) + 0.5))
	model:SetAttribute("ReadyAt", entry.ProduceReadyAt)
	model:SetAttribute("FedAt", entry.FedAt)
	InteractionService.SetText(model, statusText(animal, entry, now), animal.Def.DisplayName)
end

local function spawnAnimal(player: Player, island: any, entry: any): Animal?
	local def = AnimalConfig.Animals[entry.AnimalId]
	if not def then
		return nil
	end
	local home: CFrame
	local radius = 3
	local site = BuildService.GetSite(entry.HousingId)
	if site then
		home, radius = penOf(site)
	else
		home = island.SpawnCFrame * CFrame.new(math.random(-6, 6), -4, math.random(-10, -4))
	end

	local model = AnimalModels.Build(entry.AnimalId, variantDef(def, entry.Variant))
	local body = model.PrimaryPart :: BasePart
	local bodyOffset = model:GetPivot():ToObjectSpace(body.CFrame)
	local start = CFrame.new(home.Position.X, groundY(home.Position), home.Position.Z) * CFrame.Angles(0, random:NextNumber(0, math.pi * 2), 0)
	model:PivotTo(start)
	model:SetAttribute("AnimalId", entry.AnimalId)
	model:SetAttribute("UniqueId", entry.UniqueId)
	model:SetAttribute("Variant", entry.Variant)
	model:SetAttribute("DisplayName", def.DisplayName)
	model:SetAttribute("OwnerUserId", island.OwnerUserId)
	model.Parent = island.Folders.Animals
	CollectionService:AddTag(model, TAG)

	local animal: Animal = {
		UniqueId = entry.UniqueId,
		AnimalId = entry.AnimalId,
		Def = def,
		Owner = player,
		Island = island,
		Model = model,
		Body = body,
		BodyOffset = bodyOffset,
		Home = home,
		PenRadius = radius,
		Moving = false,
		Status = "",
	}
	local list = animalsByIsland[island.Id]
	if not list then
		list = {}
		animalsByIsland[island.Id] = list
	end
	list[entry.UniqueId] = animal

	InteractionService.Attach(model, "Animal", { Label = def.DisplayName, OwnerUserId = island.OwnerUserId, MaxDistance = 6 })
	model:SetAttribute("AnimalAnim", "Idle")
	refresh(animal)
	return animal
end

local function findAnimal(player: Player, model: Instance): Animal?
	local animalModel = if model:IsA("Model") then model else model:FindFirstAncestorOfClass("Model")
	if not animalModel then
		return nil
	end
	local uniqueId = animalModel:GetAttribute("UniqueId")
	local island = IslandService.GetIslandFromInstance(animalModel)
	local list = island and animalsByIsland[island.Id]
	local animal = list and type(uniqueId) == "string" and list[uniqueId]
	if animal and IslandService.CanAccess(player, animal.Island, "Animals") then
		return animal
	end
	return nil
end

---------------------------------------------------------------------------
-- Actions
---------------------------------------------------------------------------

-- "Eat" / "Happy" play for a moment, then the animal goes back to idling.
local function playRig(animal: Animal, state: string)
	animal.Model:SetAttribute("AnimalAnim", state)
	task.delay(if state == "Eat" then 3 else 1.6, function()
		if animal.Model.Parent and animal.Model:GetAttribute("AnimalAnim") == state then
			animal.Model:SetAttribute("AnimalAnim", if animal.Moving then "Walk" else "Idle")
		end
	end)
end

local function faceAnimal(animal: Animal)
	-- Stop wandering while being cared for.
	animal.Moving = true
	task.delay(2.5, function()
		animal.Moving = false
	end)
end

local function pet(player: Player, animal: Animal)
	local entry = entryOf(animal)
	if not entry then
		return
	end
	local now = os.time()
	local wait = (entry.PettedAt or 0) + AnimalConfig.PetCooldown - now
	if wait > 0 then
		Notify.Toast(player, ("Your %s loved that! Pet again in %ds."):format(animal.Def.DisplayName, wait), "💕")
		return
	end
	faceAnimal(animal)
	AnimationService.PerformAction(player, "PetAnimal", "Pet", function()
		local current = entryOf(animal)
		if not current then
			return
		end
		local happiness = math.min(100, AnimalMath.GetHappiness(current, os.time()) + AnimalConfig.PetHappiness)
		writeEntry(animal, { Happiness = happiness, HappinessAt = os.time(), PettedAt = os.time() })
		VFXService.PlayAt("Hearts", animal.Body.Position + Vector3.new(0, 2, 0))
		GameSoundService.PlayAt(animal.Def.Voice, animal.Body.Position)
		refresh(animal)
	end)
end

local function feed(player: Player, animal: Animal)
	local def = animal.Def
	local held = ToolService.GetHeld(player)
	if not held or held.Id ~= def.Food then
		Notify.Error(player, ("Hold %s %s (on your hotbar) and click your %s to feed it."):format(def.FoodAmount, def.Food, def.DisplayName))
		return
	end
	if InventoryService.GetCount(player, def.Food) < def.FoodAmount then
		Notify.Error(player, ("Your %s needs %d %s — grow some on your farm!"):format(def.DisplayName, def.FoodAmount, def.Food))
		return
	end
	faceAnimal(animal)
	AnimationService.PerformAction(player, "FeedAnimal", "Feed", function()
		local entry = entryOf(animal)
		if not entry or AnimalMath.GetStatus(entry, os.time()) ~= "Hungry" then
			return
		end
		if not InventoryService.RemoveItem(player, def.Food, def.FoodAmount, "FeedAnimal") then
			return
		end
		local now = os.time()
		local happiness = math.min(100, AnimalMath.GetHappiness(entry, now) + AnimalConfig.FeedHappiness)
		writeEntry(animal, {
			Happiness = happiness,
			HappinessAt = now,
			FedAt = now,
			ProduceReadyAt = now + math.floor(AnimalMath.ProduceDuration(animal.AnimalId, happiness)),
		})
		VFXService.PlayAt("Hearts", animal.Body.Position + Vector3.new(0, 2, 0))
		GameSoundService.PlayAt("Feed", animal.Body.Position)
		playRig(animal, "Eat")
		ProgressionService.Award(player, "FeedAnimal")
		refresh(animal)
		Notify.Toast(player, ("%s fed! %s will be ready soon."):format(def.DisplayName, def.Produce), "🌾")
		AnimalService.AnimalFed:Fire(player, animal.AnimalId)
	end)
end

local function collect(player: Player, animal: Animal)
	local def = animal.Def
	if def.ProduceTool and not ToolService.GetHeldTool(player, def.ProduceTool) then
		local owned = ToolService.GetBestTool(player, def.ProduceTool)
		Notify.Error(player, if owned
			then ("Hold your 🪣 %s and click to collect the %s."):format(def.ProduceTool, def.Produce)
			else ("You need a %s — buy one at the market."):format(def.ProduceTool))
		return
	end
	faceAnimal(animal)
	AnimationService.PerformAction(player, def.ProduceAnimation, def.ProduceMarker, function()
		local entry = entryOf(animal)
		if not entry or AnimalMath.GetStatus(entry, os.time()) ~= "Ready" then
			return
		end
		local happiness = AnimalMath.GetHappiness(entry, os.time())
		local variant = variantDef(def, entry.Variant)
		local amount = def.ProduceAmount + (if happiness >= AnimalConfig.BonusProduceAtHappiness then 1 else 0) + (variant.ProduceBonus or 0)
		local added = InventoryService.AddItem(player, def.Produce, amount, "Animal")
		if added <= 0 then
			return
		end
		writeEntry(animal, { ProduceReadyAt = 0 })
		DataService.Increment(player, { "Stats", if def.Produce == "Milk" then "MilkCollected" else "EggsCollected" }, added)
		VFXService.PlayAt(def.ProduceVFX, animal.Body.Position + Vector3.new(0, 1, 0))
		GameSoundService.PlayAt(def.ProduceSound, animal.Body.Position)
		playRig(animal, "Happy")
		ProgressionService.Award(player, "CollectProduce")
		refresh(animal)
		AnimalService.ProduceCollected:Fire(player, animal.AnimalId, def.Produce, added)
	end)
end

local function onClicked(player: Player, animal: Animal)
	local entry = entryOf(animal)
	if not entry then
		return
	end
	local status = AnimalMath.GetStatus(entry, os.time())
	local held = ToolService.GetHeld(player)
	local def = animal.Def
	if status == "Ready" and (def.ProduceTool == nil or (held and held.Kind == "Tool" and held.Def.Type == def.ProduceTool)) then
		collect(player, animal)
	elseif status == "Hungry" and held and held.Id == def.Food then
		feed(player, animal)
	elseif status == "Ready" and def.ProduceTool then
		collect(player, animal) -- explains which tool to hold
	else
		pet(player, animal)
	end
end

---------------------------------------------------------------------------
-- Public API
---------------------------------------------------------------------------

function AnimalService.CanAdd(player: Player, animalId: string): (boolean, string?)
	local site, reason = AnimalService.FindHousing(player, animalId)
	return site ~= nil, reason
end

function AnimalService.AddAnimal(player: Player, animalId: string): (boolean, string?)
	local def = AnimalConfig.Animals[animalId]
	local island = IslandService.GetIsland(player)
	if not def or not island then
		return false, "Unknown animal."
	end
	local site, reason = AnimalService.FindHousing(player, animalId)
	if not site then
		return false, reason
	end
	local uniqueId = HttpService:GenerateGUID(false)
	local now = os.time()
	local entry = {
		AnimalId = animalId,
		UniqueId = uniqueId,
		Variant = rollVariant(def),
		HousingId = site.UniqueId,
		Happiness = AnimalConfig.StartHappiness,
		HappinessAt = now,
		FedAt = 0,
		ProduceReadyAt = 0,
		PettedAt = 0,
	}
	DataService.Set(player, { "Island", "Animals", uniqueId }, entry)
	DataService.Increment(player, { "Stats", "AnimalsOwned" }, 1)
	local animal = spawnAnimal(player, island, entry)
	if animal then
		VFXService.PlayAt("Hearts", animal.Body.Position + Vector3.new(0, 2, 0))
		GameSoundService.PlayAt(def.Voice, animal.Body.Position)
	end
	local variantName = if entry.Variant ~= "Default" then entry.Variant .. " " else ""
	Notify.Banner(player, "NEW ANIMAL!", ("Meet your %s%s! Feed it %s."):format(variantName, def.DisplayName, def.Food), "Reward")
	ProgressionService.Award(player, "BuyAnimal")
	AnimalService.AnimalAdded:Fire(player, animalId)
	return true, nil
end

-- Admin/testing: make every animal's product ready now.
function AnimalService.ReadyAll(player: Player)
	local island = IslandService.GetIsland(player)
	for _, animal in (island and animalsByIsland[island.Id]) or {} do
		writeEntry(animal, { ProduceReadyAt = os.time() - 1, FedAt = os.time() })
		refresh(animal)
	end
end

local function wander(animal: Animal)
	if animal.Moving or not animal.Body.Parent then
		return
	end
	local angle = random:NextNumber(0, math.pi * 2)
	local distance = math.sqrt(random:NextNumber()) * animal.PenRadius
	local target = animal.Home.Position + Vector3.new(math.cos(angle) * distance, 0, math.sin(angle) * distance)
	target = Vector3.new(target.X, groundY(target), target.Z)
	local current = animal.Model:GetPivot()
	local flat = Vector3.new(target.X - current.Position.X, 0, target.Z - current.Position.Z)
	if flat.Magnitude < 0.8 then
		return
	end
	local goal = CFrame.lookAt(target, target + flat.Unit) * animal.BodyOffset
	animal.Moving = true
	animal.Model:SetAttribute("AnimalAnim", "Walk")
	local tween = TweenService:Create(animal.Body, TweenInfo.new(flat.Magnitude / animal.Def.WalkSpeed, Enum.EasingStyle.Sine), { CFrame = goal })
	tween.Completed:Once(function()
		animal.Moving = false
		if animal.Model:GetAttribute("AnimalAnim") == "Walk" then
			animal.Model:SetAttribute("AnimalAnim", "Idle")
		end
	end)
	tween:Play()
end

local function playerNear(position: Vector3): boolean
	for _, player in Players:GetPlayers() do
		local root = R15.GetRootPart(player.Character)
		if root and (root.Position - position).Magnitude <= AnimalConfig.ActiveRange then
			return true
		end
	end
	return false
end

local function loadIsland(player: Player, island: any)
	animalsByIsland[island.Id] = {}
	for _, entry in DataService.Get(player, { "Island", "Animals" }) or {} do
		local ok, err = pcall(spawnAnimal, player, island, entry)
		if not ok then
			warn("[AnimalService] Could not load animal: " .. tostring(err))
		end
	end
end

function AnimalService.Init()
	InteractionService.RegisterKind("Animal", {
		Permission = "Animals",
		MaxDistance = 6,
		Cooldown = 0.4,
		Handler = function(player: Player, model: Instance)
			local animal = findAnimal(player, model)
			if animal then
				onClicked(player, animal)
			end
		end,
	})

	-- Housing with animals can't be deleted out from under them.
	BuildService.SetDeleteGuard(function(player: Player, site: any)
		if site.Def.Capacity and residents(player, site.UniqueId) > 0 then
			return false, "Animals live here — it can't be removed while they do."
		end
		return true, nil
	end)
end

function AnimalService.Start()
	IslandService.IslandAssigned:Connect(function(player: Player, island: any)
		-- Buildings (housing) load in BuildService's handler first; defer so pens exist.
		task.defer(loadIsland, player, island)
	end)
	IslandService.IslandReleased:Connect(function(_player: Player, islandId: string)
		animalsByIsland[islandId] = nil
	end)
	BuildService.BuildingMoved:Connect(function(_player: Player, site: any)
		local list = animalsByIsland[site.Island.Id]
		for _, animal in list or {} do
			local entry = entryOf(animal)
			if entry and entry.HousingId == site.UniqueId then
				animal.Home, animal.PenRadius = penOf(site)
				animal.Model:PivotTo(CFrame.new(animal.Home.Position.X, groundY(animal.Home.Position), animal.Home.Position.Z))
			end
		end
	end)

	task.spawn(function()
		local elapsed = 0
		while true do
			task.wait(STATUS_TICK)
			elapsed += STATUS_TICK
			local doWander = elapsed >= AnimalConfig.WanderInterval
			if doWander then
				elapsed = 0
			end
			for _, list in animalsByIsland do
				for _, animal in list do
					if animal.Model.Parent then
						local entry = entryOf(animal)
						if entry and AnimalMath.GetStatus(entry, os.time()) ~= animal.Status then
							refresh(animal)
						end
						if doWander and random:NextNumber() < 0.45 and playerNear(animal.Home.Position) then
							wander(animal)
						end
					end
				end
			end
		end
	end)
end

return AnimalService
