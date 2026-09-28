--!nonstrict
-- Logic tests executed by tests/run_logic_tests.sh (see tests/build_harness.py).
-- Engine-free checks only: configs, cross-config references, DataSchema repair,
-- island layout math, utilities. Everything else is tested in Studio (docs/PHASE_1.md).

local passed, failed = 0, 0

local function test(name, fn)
	local ok, err = pcall(fn)
	if ok then
		passed += 1
		print("  PASS  " .. name)
	else
		failed += 1
		print("  FAIL  " .. name .. "\n        " .. tostring(err))
	end
end

local function eq(actual, expected, label)
	if actual ~= expected then
		error(("%s: expected %s, got %s"):format(label or "value", tostring(expected), tostring(actual)), 2)
	end
end

local RS = game:GetService("ReplicatedStorage")
local Shared = RS.Shared
local Server = game:GetService("ServerScriptService").Server

print("Build Your Island — logic tests")

test("all shared configs load (and freeze)", function()
	for _, name in { "GameConfig", "InputConfig", "IslandConfig", "ItemConfig", "ResourceConfig", "RarityConfig", "ToolConfig", "AnimationConfig", "SoundConfig", "VFXConfig", "EconomyConfig", "ProgressionConfig", "RemoteConfig" } do
		local config = require(Shared.Config[name])
		assert(type(config) == "table", name .. " did not return a table")
		assert(table.isfrozen(config), name .. " should be frozen")
	end
end)

test("ItemConfig registry", function()
	local ItemConfig = require(Shared.Config.ItemConfig)
	assert(ItemConfig.Exists("Wood"))
	assert(ItemConfig.Exists("StarShard"))
	assert(not ItemConfig.Exists("Bogus"))
	assert(not ItemConfig.Exists(42))
	eq(ItemConfig.Get("Wood").Id, "Wood", "item id injected")
end)

test("ToolConfig generation (types x tiers)", function()
	local ToolConfig = require(Shared.Config.ToolConfig)
	local axe = ToolConfig.Get("WoodenAxe")
	assert(axe, "WoodenAxe missing")
	eq(axe.Type, "Axe")
	eq(axe.Grip.Hand, "RightHand", "R15 grip hand")
	assert(ToolConfig.Get("MythicAxe"), "MythicAxe missing")
	assert(ToolConfig.Get("IronPickaxe"), "IronPickaxe missing")
	assert(ToolConfig.Get("StoneShears") == nil, "Shears have no Stone tier")
	assert(ToolConfig.Get("CrystalAxe").UseCooldown < axe.UseCooldown, "better tiers swing faster")
end)

test("every tool animation / sound referenced exists", function()
	local ToolConfig = require(Shared.Config.ToolConfig)
	local AnimationConfig = require(Shared.Config.AnimationConfig)
	local SoundConfig = require(Shared.Config.SoundConfig)
	for toolId, tool in ToolConfig.Tools do
		for slot, animationName in tool.Animations do
			assert(AnimationConfig.Get(animationName), ("%s.%s -> unknown animation %s"):format(toolId, slot, animationName))
		end
		for slot, soundName in tool.Sounds do
			assert(SoundConfig.Sounds[soundName], ("%s.%s -> unknown sound %s"):format(toolId, slot, soundName))
		end
	end
end)

test("animation marker effects reference real sounds/VFX; markers fit inside Length", function()
	local AnimationConfig = require(Shared.Config.AnimationConfig)
	local SoundConfig = require(Shared.Config.SoundConfig)
	local VFXConfig = require(Shared.Config.VFXConfig)
	local validPriorities = { Core = true, Idle = true, Movement = true, Action = true, Action2 = true, Action3 = true, Action4 = true }
	for name, def in AnimationConfig.Index do
		assert(validPriorities[def.Priority], name .. " has invalid priority " .. tostring(def.Priority))
		assert(string.find(def.Id, "PLACEHOLDER", 1, true), name .. " should ship as an honest placeholder")
		for marker, time in def.Markers do
			assert(time >= 0 and time <= def.Length, ("%s marker %s at %s is outside Length %s"):format(name, marker, time, def.Length))
		end
		for marker, effects in def.MarkerEffects do
			assert(def.Markers[marker], ("%s has effects for undefined marker %s"):format(name, marker))
			if effects.Sound then
				assert(SoundConfig.Sounds[effects.Sound], name .. " -> unknown sound " .. effects.Sound)
			end
			if effects.VFX then
				assert(VFXConfig.Effects[effects.VFX], name .. " -> unknown VFX " .. effects.VFX)
			end
		end
	end
	eq(AnimationConfig.Get("HammerSwing").Markers.HammerHit, 0.31, "spec §74 HammerHit timing")
	eq(AnimationConfig.Get("HammerSwing").Length, 0.65, "spec §74 HammerSwing length")
end)

test("RemoteConfig lists every spec remote once", function()
	local RemoteConfig = require(Shared.Config.RemoteConfig)
	for _, name in {
		"BuildRequest", "DeleteBuildRequest", "MoveBuildRequest", "GatherRequest", "PlantCropRequest",
		"WaterCropRequest", "HarvestCropRequest", "AnimalInteractRequest", "MilkAnimalRequest", "FishingRequest",
		"SellItemRequest", "CraftRequest", "UpgradeRequest", "PurchaseRequest", "QuestRequest",
		"IslandPermissionRequest", "IslandVisitRequest", "EquipToolRequest",
	} do
		eq(RemoteConfig.Known[name], "ClientToServer", name)
	end
	eq(RemoteConfig.Known.StateSync, "ServerToClient", "StateSync")
end)

test("island layout: slots, areas overlap the starter island, markers on land", function()
	local IslandConfig = require(Shared.Config.IslandConfig)
	local IslandLayout = require(Shared.Util.IslandLayout)
	local slot5 = IslandLayout.GetSlotOrigin(5).Position
	eq(slot5.X, 0, "slot 5 X")
	eq(slot5.Z, IslandConfig.SlotSpacing, "slot 5 Z")
	local starter = IslandConfig.Areas.Starter
	for _, areaId in IslandConfig.AreaOrder do
		local area = IslandConfig.Areas[areaId]
		assert(area, "AreaOrder references unknown area " .. areaId)
		if areaId ~= "Starter" then
			local center = IslandLayout.GetAreaCenter(areaId)
			assert(center.Magnitude < starter.Radius + area.Radius, areaId .. " does not touch the starter island")
			assert(center.Magnitude + area.Radius + IslandConfig.ShallowsWidth < IslandConfig.SlotSpacing / 2, areaId .. " would reach a neighbouring slot")
			local marker = IslandLayout.GetAreaMarkerPosition(areaId)
			assert(IslandLayout.IsInArea("Starter", marker, 1), areaId .. " marker is not on starter land")
			local requires = area.Unlock and area.Unlock.RequiresArea
			if requires then
				assert(table.find(IslandConfig.AreaOrder, requires) < table.find(IslandConfig.AreaOrder, areaId), areaId .. " requires a later area")
			end
		end
	end
	-- The front (+Z) stays open ocean for the dock.
	local dock = IslandConfig.StarterLayout.Dock.Start
	for _, areaId in IslandConfig.AreaOrder do
		if areaId ~= "Starter" then
			assert(not IslandLayout.IsInArea(areaId, dock + Vector2.new(0, 20)), "dock would be covered by " .. areaId)
		end
	end
	assert(IslandLayout.IsOnUnlockedLand({ Starter = true }, Vector2.new(0, 0), 4))
	assert(not IslandLayout.IsOnUnlockedLand({ Starter = true }, IslandLayout.GetAreaCenter("Mainland"), 4))
end)

test("starter layout props sit on starter land", function()
	local IslandConfig = require(Shared.Config.IslandConfig)
	local IslandLayout = require(Shared.Util.IslandLayout)
	local layout = IslandConfig.StarterLayout
	for label, point in { Spawn = layout.Spawn, Chest = layout.StarterChest, Sign = layout.IslandSign, House = layout.HousePlot.Center, Farm = layout.FarmPlot.Center } do
		assert(IslandLayout.IsInArea("Starter", point, 10), label .. " is too close to the shore")
	end
	for index, palm in layout.Palms do
		assert(IslandLayout.IsInArea("Starter", palm, 4), "palm " .. index .. " is off the island")
	end
end)

test("DataSchema template is valid and saveable", function()
	local DataSchema = require(Server.Data.DataSchema)
	local GameConfig = require(Shared.Config.GameConfig)
	local data = DataSchema.Sanitize(nil)
	eq(data.Coins, GameConfig.StartingCoins, "starting coins")
	eq(data.Island.UnlockedAreas.Starter, true, "starter unlocked")
	assert(DataSchema.IsSaveable(data))
	-- Template() hands out independent copies.
	local a, b = DataSchema.Template(), DataSchema.Template()
	a.Inventory.Items.Wood = 5
	eq(b.Inventory.Items.Wood, nil, "template copies are independent")
end)

test("DataSchema repairs corrupt data without destroying progress", function()
	local DataSchema = require(Server.Data.DataSchema)
	local nan = 0 / 0
	local corrupt = {
		Version = 1,
		Coins = "lots",
		Gems = -50,
		Level = nan,
		Inventory = { Items = { Wood = 12.7, Stone = -3, Bogus = 9 }, Capacity = 200 },
		Tools = {
			Owned = { WoodenAxe = true, FakeTool = true, WoodenPickaxe = "yes" },
			Hotbar = { "WoodenAxe", "FakeTool", "WoodenAxe", 42 },
			Equipped = "FakeTool",
		},
		Island = { Name = "Sunny Meadows", Level = 7, UnlockedAreas = { Forest = true, Atlantis = true, Starter = false } },
		Flags = "broken",
	}
	local data = DataSchema.Sanitize(corrupt)
	eq(data.Coins, 100, "string coins reset to default")
	eq(data.Quarantine.Values.Coins, "lots", "bad coins value quarantined")
	eq(data.Gems, 0, "negative gems clamped")
	eq(data.Level, 1, "NaN level repaired")
	eq(data.Inventory.Items.Wood, 12, "fractional count floored")
	eq(data.Inventory.Items.Stone, nil, "negative count removed")
	eq(data.Inventory.Items.Bogus, nil, "unknown item removed from inventory")
	eq(data.Quarantine.Items.Bogus, 9, "unknown item kept in quarantine")
	eq(data.Tools.Owned.FakeTool, nil, "unknown tool removed")
	eq(data.Quarantine.Tools.FakeTool, true, "unknown tool quarantined")
	eq(data.Tools.Owned.WoodenPickaxe, nil, "non-boolean ownership removed")
	eq(#data.Tools.Hotbar, 1, "hotbar deduped + filtered")
	eq(data.Tools.Equipped, "", "equipped unknown tool cleared")
	eq(data.Island.Name, "Sunny Meadows", "valid island name kept")
	eq(data.Island.Level, 7, "valid island level kept")
	eq(data.Island.UnlockedAreas.Forest, true, "valid area kept")
	eq(data.Island.UnlockedAreas.Starter, true, "starter always unlocked")
	eq(data.Quarantine.Areas.Atlantis, true, "unknown area quarantined")
	eq(type(data.Flags), "table", "wrong-typed table rebuilt")
	eq(data.Flags.StarterChestClaimed, false, "rebuilt table has defaults")
	assert(DataSchema.IsSaveable(data))

	-- Quarantined ids come back automatically once they are valid again.
	data.Quarantine.Items.Wood = 3
	local again = DataSchema.Sanitize(data)
	eq(again.Inventory.Items.Wood, 15, "quarantined item restored when valid")
	eq(again.Quarantine.Items.Wood, nil, "restored item left quarantine")
	eq(again.Quarantine.Items.Bogus, 9, "still-invalid item stays quarantined")
end)

test("DataSchema refuses to save garbage", function()
	local DataSchema = require(Server.Data.DataSchema)
	assert(not DataSchema.IsSaveable(nil))
	assert(not DataSchema.IsSaveable({ Version = 1, Coins = -1 }))
	local data = DataSchema.Sanitize(nil)
	data.Inventory = nil
	assert(not DataSchema.IsSaveable(data))
end)

test("RateLimiter token bucket", function()
	local RateLimiter = require(Shared.Util.RateLimiter)
	local limiter = RateLimiter.new(2, 3)
	local key = {}
	assert(limiter:Check(key) and limiter:Check(key) and limiter:Check(key), "burst allowed")
	assert(not limiter:Check(key), "4th immediate call rejected")
	__advance(1)
	assert(limiter:Check(key), "refilled after 1s")
end)

test("Signal connect / once / disconnect", function()
	local Signal = require(Shared.Util.Signal)
	local signal = Signal.new()
	local total, onceCount = 0, 0
	local connection = signal:Connect(function(n) total += n end)
	signal:Once(function() onceCount += 1 end)
	signal:Fire(2)
	signal:Fire(3)
	connection:Disconnect()
	signal:Fire(100)
	eq(total, 5, "connected handler sum")
	eq(onceCount, 1, "Once fires once")
end)

test("Format helpers", function()
	local Format = require(Shared.Util.Format)
	eq(Format.Commas(1234567), "1,234,567")
	eq(Format.Commas(999), "999")
	eq(Format.Commas(-4500), "-4,500")
	eq(Format.Abbreviate(9999), "9,999")
	eq(Format.Abbreviate(12345), "12.3K")
	eq(Format.Abbreviate(1000000), "1M")
	eq(Format.Duration(125), "2m 5s")
end)

test("Validate guards", function()
	local Validate = require(Shared.Util.Validate)
	assert(Validate.Id("WoodenAxe"))
	assert(not Validate.Id("Wooden Axe"))
	assert(not Validate.Id(string.rep("a", 65)))
	assert(not Validate.Integer(0 / 0))
	assert(not Validate.Integer(1.5))
	assert(Validate.Integer(5, 1, 10))
	assert(not Validate.Number(math.huge))
end)

test("progression curves and titles", function()
	local ProgressionConfig = require(Shared.Config.ProgressionConfig)
	assert(ProgressionConfig.IslandXPForLevel(1) > ProgressionConfig.Sources.StarterChest.Island, "starter chest alone shouldn't level the island")
	assert(ProgressionConfig.IslandXPForLevel(2) > ProgressionConfig.IslandXPForLevel(1), "curve increases")
	eq(ProgressionConfig.GetIslandTitle(1), "Starter Island")
	eq(ProgressionConfig.GetIslandTitle(12), "Established Island")
end)

test("AnimationPlayer virtual track fires markers then Ended (placeholder ids)", function()
	local AnimationPlayer = require(Shared.Animation.AnimationPlayer)
	local rig = { FindFirstChildOfClass = function() return nil end, GetFullName = function() return "Rig" end }
	local player = AnimationPlayer.new(rig)
	local events = {}
	local handle = player:Play("HammerSwing", {
		Markers = { HammerHit = function() table.insert(events, "HammerHit") end },
	})
	assert(handle, "handle returned for placeholder animation")
	handle.Ended:Connect(function() table.insert(events, "Ended") end)
	assert(player:IsPlaying("HammerSwing"))
	__advance(0.2)
	eq(#events, 0, "nothing before the marker time")
	__advance(0.2)
	eq(events[1], "HammerHit", "marker fired at config time")
	__advance(0.5)
	eq(events[2], "Ended", "ended after Length")
	assert(not player:IsPlaying("HammerSwing"))

	-- Speed scales the timeline.
	local fast = {}
	local h2 = player:Play("HammerSwing", { Speed = 2, Markers = { HammerHit = function() table.insert(fast, true) end } })
	__advance(0.16)
	eq(#fast, 1, "marker at 0.31/2 with Speed 2")
	h2:Stop()
	assert(not player:IsPlaying("HammerSwing"), "Stop ends the handle")
end)

---------------------------------------------------------------------------
-- First playable loop: gathering, building, farming, fishing, animals, shop, quests
---------------------------------------------------------------------------

test("gameplay configs load (and freeze)", function()
	for _, name in { "CropConfig", "FishConfig", "AnimalConfig", "BuildingConfig", "BuildConfig", "ShopConfig", "QuestConfig" } do
		local config = require(Shared.Config[name])
		assert(type(config) == "table", name .. " did not return a table")
		assert(table.isfrozen(config), name .. " should be frozen")
	end
end)

test("every item / tool / sound / effect a config references exists", function()
	local ItemConfig = require(Shared.Config.ItemConfig)
	local ToolConfig = require(Shared.Config.ToolConfig)
	local SoundConfig = require(Shared.Config.SoundConfig)
	local VFXConfig = require(Shared.Config.VFXConfig)
	local AnimationConfig = require(Shared.Config.AnimationConfig)
	local ProgressionConfig = require(Shared.Config.ProgressionConfig)
	local ResourceConfig = require(Shared.Config.ResourceConfig)
	local CropConfig = require(Shared.Config.CropConfig)
	local AnimalConfig = require(Shared.Config.AnimalConfig)
	local BuildingConfig = require(Shared.Config.BuildingConfig)
	local GameConfig = require(Shared.Config.GameConfig)

	local toolTypes = {}
	for _, tool in ToolConfig.Tools do
		toolTypes[tool.Type] = true
	end
	for nodeId, node in ResourceConfig.Nodes do
		assert(ItemConfig.Exists(node.Resource), nodeId .. " drops unknown item " .. tostring(node.Resource))
		assert(node.ToolType == nil or toolTypes[node.ToolType], nodeId .. " needs unknown tool type")
		assert(ProgressionConfig.Sources[node.XPSource], nodeId .. " has unknown XP source")
		for _, key in { "HitSound", "BreakSound" } do
			assert(node[key] == nil or SoundConfig.Sounds[node[key]], nodeId .. " " .. key .. " missing")
		end
		for _, key in { "HitVFX", "BreakVFX" } do
			assert(node[key] == nil or VFXConfig.Effects[node[key]], nodeId .. " " .. key .. " missing")
		end
		if node.Animation then
			local anim = AnimationConfig.Get(node.Animation)
			assert(anim and anim.Markers[node.Marker], nodeId .. " animation/marker missing")
		end
	end
	for cropId, crop in CropConfig.Crops do
		assert(ItemConfig.Exists(cropId), "crop item " .. cropId)
		assert(ItemConfig.Exists(crop.Seed), "seed item " .. crop.Seed)
		eq(CropConfig.SeedToCrop[crop.Seed], cropId, "seed maps back to crop")
	end
	for animalId, animal in AnimalConfig.Animals do
		assert(ItemConfig.Exists(animal.Food), animalId .. " food")
		assert(ItemConfig.Exists(animal.Produce), animalId .. " produce")
		assert(BuildingConfig.Get(animal.Housing), animalId .. " housing")
		assert(BuildingConfig.Get(animal.Housing).Capacity[animalId], animalId .. " housing has no capacity for it")
		assert(SoundConfig.Sounds[animal.ProduceSound] and SoundConfig.Sounds[animal.Voice], animalId .. " sounds")
		assert(VFXConfig.Effects[animal.ProduceVFX], animalId .. " produce vfx")
		local anim = AnimationConfig.Get(animal.ProduceAnimation)
		assert(anim and anim.Markers[animal.ProduceMarker], animalId .. " produce animation/marker")
		assert(animal.ProduceTool == nil or toolTypes[animal.ProduceTool], animalId .. " produce tool type")
	end
	for buildingId, building in BuildingConfig.Buildings do
		for itemId, amount in building.Cost.Items do
			assert(ItemConfig.Exists(itemId), buildingId .. " costs unknown item " .. itemId)
			assert(amount > 0, buildingId .. " cost amount")
		end
		assert(building.Steps >= 1, buildingId .. " needs at least one step")
	end
	for itemId in GameConfig.StarterKit.Items do
		assert(ItemConfig.Exists(itemId), "starter kit item " .. itemId)
	end
	for _, toolId in GameConfig.StarterKit.Tools do
		assert(ToolConfig.Get(toolId), "starter kit tool " .. toolId)
	end
	assert(#GameConfig.StarterKit.Tools <= ToolConfig.HotbarSize, "starter tools fit in the hotbar")
end)

test("shop items grant real things and prices are sane", function()
	local ShopConfig = require(Shared.Config.ShopConfig)
	local ItemConfig = require(Shared.Config.ItemConfig)
	local ToolConfig = require(Shared.Config.ToolConfig)
	local AnimalConfig = require(Shared.Config.AnimalConfig)
	local categories = {}
	for _, category in ShopConfig.Categories do
		categories[category.Id] = true
	end
	for shopId, def in ShopConfig.Items do
		assert(categories[def.Category], shopId .. " has unknown category")
		assert(def.Price > 0, shopId .. " price")
		local grant = def.Grant
		if grant.Tool then
			assert(ToolConfig.Get(grant.Tool), shopId .. " grants unknown tool")
		elseif grant.Item then
			assert(ItemConfig.Exists(grant.Item) and grant.Amount > 0, shopId .. " grants unknown item")
		elseif grant.Animal then
			assert(AnimalConfig.Animals[grant.Animal], shopId .. " grants unknown animal")
		elseif grant.Upgrade then
			assert(grant.Upgrade == "FarmTiles" or grant.Upgrade == "Capacity", shopId .. " unknown upgrade")
		else
			error(shopId .. " grants nothing")
		end
		for itemId in def.Items or {} do
			assert(ItemConfig.Exists(itemId), shopId .. " costs unknown item " .. itemId)
		end
	end
	-- Crops must be worth growing: a harvest pays back more than its seed.
	local CropConfig = require(Shared.Config.CropConfig)
	for cropId, crop in CropConfig.Crops do
		assert(crop.Yield.Min * crop.SellValue > crop.SeedCost, cropId .. " loses money")
	end
	for category in ShopConfig.SellAllCategories do
		local found = false
		for _, item in ItemConfig.Items do
			found = found or item.Category == category
		end
		assert(found, "sell-all category " .. category .. " has no items")
	end
end)

test("quest chain references real events and targets", function()
	local QuestConfig = require(Shared.Config.QuestConfig)
	local ItemConfig = require(Shared.Config.ItemConfig)
	local BuildingConfig = require(Shared.Config.BuildingConfig)
	local AnimalConfig = require(Shared.Config.AnimalConfig)
	local ShopConfig = require(Shared.Config.ShopConfig)
	local IslandConfig = require(Shared.Config.IslandConfig)
	local CropConfig = require(Shared.Config.CropConfig)
	local FishConfig = require(Shared.Config.FishConfig)
	local buildingCategories = {}
	for _, category in BuildingConfig.Categories do
		buildingCategories[category.Id] = true
	end
	local validTarget = {
		CollectItem = function(t) return ItemConfig.Exists(t) end,
		BuildComplete = function(t) return BuildingConfig.Get(t) ~= nil or buildingCategories[t] == true end,
		PlantCrop = function(t) return t == nil or CropConfig.Crops[t] ~= nil end,
		HarvestCrop = function(t) return t == nil or CropConfig.Crops[t] ~= nil end,
		CatchFish = function(t) return t == nil or FishConfig.Fish[t] ~= nil end,
		SellItem = function(t) return t == nil or ItemConfig.Exists(t) end,
		BuyAnimal = function(t) return AnimalConfig.Animals[t] ~= nil end,
		BuyTool = function(t) return ShopConfig.Items[t] ~= nil and ShopConfig.Items[t].Grant.Tool ~= nil end,
		FeedAnimal = function(t) return AnimalConfig.Animals[t] ~= nil end,
		CollectProduce = function(t) return ItemConfig.Exists(t) end,
		UnlockArea = function(t) return IslandConfig.Areas[t] ~= nil end,
		IslandLevel = function(t) return t == nil end,
	}
	for _, questId in QuestConfig.Chain do
		local quest = QuestConfig.Quests[questId]
		assert(quest, "chain quest " .. questId .. " missing")
		local seen = {}
		for _, questTask in quest.Tasks do
			assert(not seen[questTask.Id], questId .. " duplicate task id " .. questTask.Id)
			seen[questTask.Id] = true
			local check = validTarget[questTask.Event]
			assert(check, questId .. "." .. questTask.Id .. " unknown event " .. tostring(questTask.Event))
			assert(check(questTask.Target), questId .. "." .. questTask.Id .. " bad target " .. tostring(questTask.Target))
			assert(questTask.Amount >= 1 and type(questTask.Hint) == "string", questId .. "." .. questTask.Id .. " amount/hint")
		end
	end
	eq(QuestConfig.NextQuest(QuestConfig.Chain[1]), QuestConfig.Chain[2], "chain order")
	eq(QuestConfig.NextQuest(QuestConfig.Chain[#QuestConfig.Chain]), nil, "chain end")
end)

test("island content: deterministic nodes, spaced out, on their own area", function()
	local IslandContent = require(Shared.Util.IslandContent)
	local IslandConfig = require(Shared.Config.IslandConfig)
	local IslandLayout = require(Shared.Util.IslandLayout)
	local CropConfig = require(Shared.Config.CropConfig)
	for _, areaId in IslandConfig.AreaOrder do
		local first = IslandContent.AreaNodes(areaId)
		local second = IslandContent.AreaNodes(areaId)
		eq(#first, #second, areaId .. " node count stable")
		local ids = {}
		for index, spot in first do
			eq(spot.Position.X, second[index].Position.X, areaId .. " deterministic X")
			eq(spot.Id, second[index].Id, areaId .. " deterministic id")
			assert(not ids[spot.Id], "duplicate node id " .. spot.Id)
			ids[spot.Id] = true
			assert(IslandLayout.IsInArea(areaId, spot.Position, 2), spot.Id .. " is outside its area")
		end
		local content = IslandConfig.Areas[areaId].Content
		if areaId ~= "Starter" and content and content.Nodes then
			local wanted = 0
			for _, count in content.Nodes do
				wanted += count
			end
			eq(#first, wanted, areaId .. " placed every configured node")
		end
	end
	local plots = IslandContent.FarmPlots()
	eq(plots[1].Id, "S", "starter farm plot first")
	eq(#IslandContent.FarmTilePositions(plots[1].Center), CropConfig.Farm.Columns * CropConfig.Farm.Rows, "tile count")
	local dockSpot = IslandContent.FishingSpots()[1]
	eq(dockSpot.AreaId, "Starter", "first fishing spot is the dock")
	assert(dockSpot.OnDock, "starter spot is on the dock")
end)

test("crop growth from timestamps (watering speeds it up)", function()
	local CropGrowth = require(Shared.Util.CropGrowth)
	local CropConfig = require(Shared.Config.CropConfig)
	local grow = CropConfig.Crops.Wheat.GrowTime
	local dry = { CropId = "Wheat", PlantedAt = 1000, WateredAt = 0 }
	eq(CropGrowth.GetProgress(dry, 1000), 0, "just planted")
	eq(CropGrowth.GetProgress(dry, 1000 + grow / 2), 0.5, "half way")
	eq(CropGrowth.GetStage(dry, 1000), 1, "seed stage")
	eq(CropGrowth.GetStage(dry, 1000 + grow), #CropConfig.Stages, "harvestable at GrowTime")
	eq(CropGrowth.GetRemaining(dry, 1000 + grow + 50), 0, "never negative")
	local wet = { CropId = "Wheat", PlantedAt = 1000, WateredAt = 1000 }
	assert(CropGrowth.IsWatered(wet) and not CropGrowth.IsWatered(dry), "IsWatered")
	eq(CropGrowth.GetProgress(wet, 1000 + grow / CropConfig.WaterSpeedMultiplier), 1, "watered grows WaterSpeedMultiplier x faster")
	assert(CropGrowth.GetRemaining(wet, 1010) < CropGrowth.GetRemaining(dry, 1010), "watered finishes sooner")
	eq(CropGrowth.GetProgress({ CropId = "Nope", PlantedAt = 1 }, 99999), 0, "unknown crop is safe")
end)

test("animal care from timestamps (gentle happiness, clear status)", function()
	local AnimalMath = require(Shared.Util.AnimalMath)
	local AnimalConfig = require(Shared.Config.AnimalConfig)
	local hungry = { AnimalId = "Cow", Happiness = 70, HappinessAt = 0, FedAt = 0, ProduceReadyAt = 0 }
	eq(AnimalMath.GetStatus(hungry, 100), "Hungry", "unfed cow is hungry")
	local producing = { AnimalId = "Cow", Happiness = 90, HappinessAt = 0, FedAt = 0, ProduceReadyAt = 500 }
	eq(AnimalMath.GetStatus(producing, 100), "Producing", "producing before ReadyAt")
	eq(AnimalMath.GetStatus(producing, 500), "Ready", "ready at ReadyAt")
	local fed = { AnimalId = "Cow", Happiness = 90, HappinessAt = 1000, FedAt = 1000, ProduceReadyAt = 1090 }
	eq(AnimalMath.GetHappiness(fed, 1060), 90, "no decay while fed")
	local longAgo = AnimalMath.GetHappiness(fed, 1000 + 60 * 60 * 24)
	eq(longAgo, AnimalConfig.HappinessFloor, "happiness never drops below the floor")
	assert(AnimalMath.ProduceDuration("Cow", 100) < AnimalMath.ProduceDuration("Cow", 0), "happy animals produce faster")
end)

test("build placement grid math", function()
	local Placement = require(Shared.Util.Placement)
	local BuildConfig = require(Shared.Config.BuildConfig)
	local size = Placement.FootprintSize(Vector2.new(14, 22), 90)
	eq(size.X, 22, "rotation swaps X")
	eq(size.Y, 14, "rotation swaps Z")
	assert(Placement.IsValidRotation(0) and Placement.IsValidRotation(270), "valid rotations")
	assert(not Placement.IsValidRotation(45) and not Placement.IsValidRotation("90"), "invalid rotations")
	local grid = BuildConfig.GridSize
	for _, footprint in { Vector2.new(10, 10), Vector2.new(14, 22), Vector2.new(4, 2), Vector2.new(6, 6) } do
		local center = Placement.Snap(Vector2.new(13.37, -7.9), footprint)
		local edgeX = (center.X - footprint.X / 2) / grid
		local edgeZ = (center.Y - footprint.Y / 2) / grid
		eq(edgeX, math.floor(edgeX), "left edge on grid for " .. footprint.X)
		eq(edgeZ, math.floor(edgeZ), "top edge on grid for " .. footprint.Y)
	end
	assert(Placement.IsOnUnlockedLand({ Starter = true }, Vector2.new(0, 0), Vector2.new(10, 10)), "centre of starter island is buildable")
	assert(not Placement.IsOnUnlockedLand({ Starter = true }, Vector2.new(5000, 0), Vector2.new(10, 10)), "the sea is not buildable")
end)

test("fishing: zones are valid and the anti-cheat floor is beatable", function()
	local FishConfig = require(Shared.Config.FishConfig)
	local RarityConfig = require(Shared.Config.RarityConfig)
	for zoneId, zone in FishConfig.Zones do
		assert(#zone.Fish > 0, zoneId .. " has no fish")
		for _, fishId in zone.Fish do
			local fish = FishConfig.Fish[fishId]
			assert(fish, zoneId .. " lists unknown fish " .. fishId)
			assert(RarityConfig.Rarities[fish.Rarity], fishId .. " rarity")
			assert(FishConfig.RarityWeights[fish.Rarity], fishId .. " rarity has no weight")
		end
	end
	local tuning = FishConfig.Minigame
	for difficulty = 1, 5 do
		local gain = tuning.GainRate / (1 + difficulty * tuning.DifficultyScale)
		local perfect = (1 - tuning.StartProgress) / gain
		assert(perfect > FishConfig.MinReelTime(difficulty), "a perfect reel must pass the server check (difficulty " .. difficulty .. ")")
		assert(perfect < FishConfig.MaxReelTime / 2, "reel is finishable in time (difficulty " .. difficulty .. ")")
	end
end)

test("DataSchema v1 -> v2 migration gives old players the new starter kit", function()
	local DataSchema = require(Server.Data.DataSchema)
	local GameConfig = require(Shared.Config.GameConfig)
	local QuestConfig = require(Shared.Config.QuestConfig)
	local old = {
		Version = 1,
		Coins = 500,
		Inventory = { Items = { Wood = 40 }, Capacity = 200 },
		Tools = { Owned = { WoodenAxe = true }, Hotbar = { "WoodenAxe" }, Equipped = "" },
		Flags = { StarterChestClaimed = true },
		Quests = { Active = { Something = true } },
	}
	local data = DataSchema.Sanitize(old)
	eq(data.Version, DataSchema.CurrentVersion, "migrated to current version")
	eq(data.Coins, 500, "coins kept")
	eq(data.Inventory.Items.Wood, 40, "items kept")
	for _, toolId in GameConfig.StarterKit.Tools do
		eq(data.Tools.Owned[toolId], true, "owns " .. toolId)
	end
	eq(#data.Tools.Hotbar, #GameConfig.StarterKit.Tools, "hotbar has every starter tool once")
	eq(data.Inventory.Items.WheatSeeds, GameConfig.StarterKit.Items.WheatSeeds, "starter seeds granted")
	eq(data.Quests.Current, QuestConfig.Chain[1], "quest chain starts")
	eq(type(data.Island.Buildings), "table", "buildings table exists")
	assert(DataSchema.IsSaveable(data))

	-- A new player (chest not claimed) gets nothing extra from the migration.
	local fresh = DataSchema.Sanitize({ Version = 1, Flags = { StarterChestClaimed = false } })
	eq(fresh.Inventory.Items.WheatSeeds, nil, "no seeds before the chest is opened")
end)

test("DataSchema quarantines broken buildings / crops / animals", function()
	local DataSchema = require(Server.Data.DataSchema)
	local data = DataSchema.Sanitize(nil)
	data.Island.Buildings = {
		B1 = { BuildingId = "SmallCottage", Position = { X = 0, Y = 0, Z = 0 }, Rotation = 0, Progress = 99, State = "Constructing" },
		B2 = { BuildingId = "Skyscraper", Position = { X = 0, Y = 0, Z = 0 }, Rotation = 0 },
	}
	data.Island.Crops = {
		S1 = { State = "Planted", CropId = "Wheat", PlantedAt = 10, WateredAt = "wet" },
		S2 = { State = "Planted", CropId = "Moonberry", PlantedAt = 10 },
	}
	data.Island.Animals = { A1 = { AnimalId = "Cow", Happiness = 500 }, A2 = { AnimalId = "Dragon" } }
	local clean = DataSchema.Sanitize(data)
	local cottage = clean.Island.Buildings.B1
	assert(cottage, "valid building kept")
	eq(cottage.State, "Complete", "progress past the last step completes it")
	eq(clean.Island.Buildings.B2, nil, "unknown building removed")
	assert(clean.Quarantine.Buildings.B2, "unknown building quarantined")
	eq(clean.Island.Crops.S1.WateredAt, 0, "bad watered time repaired")
	assert(clean.Quarantine.Crops.S2 and clean.Island.Crops.S2 == nil, "unknown crop quarantined")
	eq(clean.Island.Animals.A1.Happiness, 100, "happiness clamped")
	assert(clean.Quarantine.Animals.A2 and clean.Island.Animals.A2 == nil, "unknown animal quarantined")
	assert(DataSchema.IsSaveable(clean))
end)

print(("\n%d passed, %d failed"):format(passed, failed))
if failed > 0 then
	error("logic tests failed")
end
