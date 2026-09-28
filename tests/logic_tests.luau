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
		"InteractRequest", "SwingRequest", "EquipToolRequest", "HotbarRequest", "EmoteRequest",
		"CreateIslandRequest", "ExpandIslandRequest", "PaintTerrainRequest", "RenameIslandRequest", "IslandSettingsRequest",
		"RemoveNodeRequest", "BuildRequest", "DeleteBuildRequest", "MoveBuildRequest", "FishingRequest",
		"SellItemRequest", "PurchaseRequest", "VisitRequest", "LikeRequest", "TradeRequest", "SettingsRequest",
	} do
		eq(RemoteConfig.Known[name], "ClientToServer", name)
	end
	eq(RemoteConfig.Known.StateSync, "ServerToClient", "StateSync")
	eq(RemoteConfig.Known.TradeEvent, "ServerToClient", "TradeEvent")
end)

test("island slots are far apart", function()
	local IslandConfig = require(Shared.Config.IslandConfig)
	local IslandLayout = require(Shared.Util.IslandLayout)
	local slot5 = IslandLayout.GetSlotOrigin(5).Position
	eq(slot5.X, 0, "slot 5 X")
	eq(slot5.Z, IslandConfig.SlotSpacing, "slot 5 Z")
	-- A fully grown island never reaches the neighbouring slot.
	assert(IslandLayout.GetMaxExtent() * 2 < IslandConfig.SlotSpacing, "max island fits its slot")
end)

test("IslandGen: every seed / shape grows a connected, unique starter island", function()
	local IslandConfig = require(Shared.Config.IslandConfig)
	local IslandGen = require(Shared.Util.IslandGen)
	local signatures = {}
	for _, shape in IslandConfig.ShapeOrder do
		for seed = 1, 6 do
			local chunks = IslandGen.GenerateStarter(seed * 7919, shape)
			local again = IslandGen.GenerateStarter(seed * 7919, shape)
			local count = IslandGen.CountChunks(chunks)
			assert(count >= IslandConfig.StarterChunks, shape .. " too small: " .. count)
			eq(count, IslandGen.CountChunks(again), shape .. " deterministic count")
			for key in chunks do
				assert(again[key], shape .. " deterministic chunk " .. key)
				local cx, cz = IslandGen.ParseKey(key)
				assert(cx and cz and IslandGen.InGrid(cx, cz), "chunk in grid " .. key)
			end
			assert(chunks[IslandGen.Key(0, 0)], "plaza chunk owned")
			-- Connected: flood fill from the centre reaches every chunk.
			local seen, stack, reached = { [IslandGen.Key(0, 0)] = true }, { { 0, 0 } }, 1
			while #stack > 0 do
				local cell = table.remove(stack)
				for _, d in { { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } } do
					local key = IslandGen.Key(cell[1] + d[1], cell[2] + d[2])
					if chunks[key] and not seen[key] then
						seen[key] = true
						reached += 1
						table.insert(stack, { cell[1] + d[1], cell[2] + d[2] })
					end
				end
			end
			eq(reached, count, shape .. " seed " .. seed .. " is one connected island")
			local keys = {}
			for key in chunks do
				table.insert(keys, key)
			end
			table.sort(keys)
			signatures[table.concat(keys, ",")] = true
		end
	end
	local distinct = 0
	for _ in signatures do
		distinct += 1
	end
	assert(distinct >= #IslandConfig.ShapeOrder * 6 - 2, "islands should almost never repeat (" .. distinct .. " distinct)")
end)

test("IslandGen: sampler, buildable land, spots and starter layout", function()
	local IslandConfig = require(Shared.Config.IslandConfig)
	local IslandGen = require(Shared.Util.IslandGen)
	local ResourceConfig = require(Shared.Config.ResourceConfig)
	for _, themeId in IslandConfig.ThemeOrder do
		local seed = 424242
		local chunks = IslandGen.GenerateStarter(seed, "Round")
		local sampler = IslandGen.NewSampler({ Seed = seed, Theme = themeId, Chunks = chunks, Paint = {} })
		local layout = IslandConfig.StarterLayout
		for label, point in { Spawn = layout.Spawn, Chest = layout.StarterChest, Sign = layout.IslandSign, Stall = layout.MarketStall.Position } do
			assert(IslandGen.IsBuildable(sampler, point.X, point.Y), themeId .. ": " .. label .. " must be on flat land")
		end
		for index, tile in layout.SoilTiles do
			assert(IslandGen.IsBuildable(sampler, tile.X, tile.Y), themeId .. ": soil tile " .. index .. " off the land")
		end
		assert(IslandGen.IsWater(sampler, 30 * IslandConfig.ChunkSize, 0), "far away is sea")
		local spawnHeight = sampler:Sample(layout.Spawn.X, layout.Spawn.Y).Height
		assert(math.abs(spawnHeight - IslandConfig.LandHeight) < 0.5, themeId .. " spawn plaza is flat")
		-- Resource spots: on their island, unique, never on the plaza, real node types.
		local spots = IslandGen.AllSpots(sampler, nil)
		assert(#spots > 10, themeId .. " has resources (" .. #spots .. ")")
		local ids = {}
		for _, spot in spots do
			assert(not ids[spot.Id], "duplicate spot " .. spot.Id)
			ids[spot.Id] = true
			assert(ResourceConfig.Nodes[spot.Type], themeId .. " unknown node " .. tostring(spot.Type))
			assert(spot.Position.Magnitude > IslandConfig.StarterLayout.KeepClearRadius - 0.01, "spot inside the keep-clear plaza")
		end
		-- Removed nodes stay removed.
		local removed = { [spots[1].Id] = true }
		eq(#IslandGen.AllSpots(sampler, removed), #spots - 1, "removed spot skipped")
		-- Theme node weights only name real nodes.
		for nodeType in IslandConfig.Themes[themeId].Nodes do
			assert(ResourceConfig.Nodes[nodeType], themeId .. " weights unknown node " .. nodeType)
		end
	end
end)

test("IslandGen: painting, expansion candidates and costs", function()
	local IslandConfig = require(Shared.Config.IslandConfig)
	local IslandGen = require(Shared.Util.IslandGen)
	local chunks = IslandGen.GenerateStarter(99, "Long")
	local painted = IslandGen.NewSampler({ Seed = 99, Theme = "Meadow", Chunks = chunks, Paint = { ["0_1"] = "Brick" } })
	eq(painted:Sample(4, 12).Material, "Brick", "paint overrides the ground material")
	local candidates = IslandGen.ExpansionCandidates(chunks)
	assert(#candidates > 8, "plenty of directions to grow")
	for _, candidate in candidates do
		local key = IslandGen.Key(candidate.X, candidate.Z)
		assert(not chunks[key], "candidate already owned " .. key)
		assert(IslandGen.IsAdjacent(chunks, candidate.X, candidate.Z), "candidate touches the island " .. key)
	end
	assert(not IslandGen.IsAdjacent(chunks, 12, 12), "far chunk is not adjacent")
	local count = IslandGen.CountChunks(chunks)
	assert(IslandGen.ExpansionCost(count) >= IslandConfig.Expansion.BaseCost, "cost floor")
	assert(IslandGen.ExpansionCost(count + 50) > IslandGen.ExpansionCost(count), "land gets pricier")
	eq(IslandGen.ExpansionCost(count) % 10, 0, "rounded price")
	assert(IslandGen.MaxChunks(1) > count, "room to expand at level 1")
	assert(IslandGen.MaxChunks(10) > IslandGen.MaxChunks(1), "levels unlock more land")
	assert(IslandGen.MaxChunks(1000) <= IslandConfig.Expansion.MaxChunks, "hard cap")
end)

test("DataSchema template is valid and saveable", function()
	local DataSchema = require(Server.Data.DataSchema)
	local GameConfig = require(Shared.Config.GameConfig)
	local data = DataSchema.Sanitize(nil)
	eq(data.Coins, GameConfig.StartingCoins, "starting coins")
	eq(data.Island.Created, false, "new players see the island creator")
	eq(next(data.Island.Chunks), nil, "no land before creation")
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
		Version = DataSchema.CurrentVersion,
		Coins = "lots",
		Gems = -50,
		Level = nan,
		Inventory = { Items = { Wood = 12.7, Stone = -3, Bogus = 9 }, Capacity = 200 },
		Tools = {
			Owned = { WoodenAxe = true, FakeTool = true, WoodenPickaxe = "yes" },
			Hotbar = { "WoodenAxe", "FakeTool", "WoodenAxe", 42 },
			Equipped = "FakeTool",
		},
		Island = {
			Name = "Sunny Meadows",
			Level = 7,
			Created = true,
			Seed = 1234,
			Theme = "Lava",
			Shape = "Round",
			Chunks = { ["0_0"] = true, ["99_99"] = true, bogus = true, ["1_0"] = "yes" },
			Paint = { ["1_2"] = "Brick", ["3_4"] = "Lava", nope = "Grass" },
			Access = { Visitors = "Pirates", Helpers = { ["123"] = true, abc = true } },
		},
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
	eq(data.Island.Theme, "Tropical", "unknown theme reset")
	eq(data.Island.Chunks["99_99"], nil, "out-of-grid chunk dropped")
	assert(data.Island.Chunks["0_0"], "centre chunk kept")
	local IslandGen = require(Shared.Util.IslandGen)
	assert(IslandGen.CountChunks(data.Island.Chunks) >= 4, "a broken island is regrown from its seed")
	eq(data.Island.Paint["1_2"], "Brick", "valid paint kept")
	eq(data.Island.Paint["3_4"], nil, "unknown paint material removed")
	eq(data.Island.Paint.nope, nil, "bad paint key removed")
	eq(data.Island.Access.Visitors, "Everyone", "bad visitor mode reset")
	eq(data.Island.Access.Helpers["123"], true, "valid helper kept")
	eq(data.Island.Access.Helpers.abc, nil, "bad helper removed")
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

test("keyframe animations: every action has real keyframes on real R15 joints", function()
	local Keyframes = require(Shared.Animation.Keyframes)
	local AnimationConfig = require(Shared.Config.AnimationConfig)
	local ToolConfig = require(Shared.Config.ToolConfig)
	local valid = {}
	for _, list in { Keyframes.UpperJoints, Keyframes.LegJoints } do
		for _, joint in list do
			valid[joint] = true
		end
	end
	local function checkAction(name, action)
		assert(#action.Keys >= 2, name .. " needs at least two keys")
		local last = -1
		for _, key in action.Keys do
			assert(key.T >= 0 and key.T <= 1 and key.T >= last, name .. " key times must rise within 0..1")
			last = key.T
			for joint, pose in key.Pose do
				assert(valid[joint], name .. " uses unknown joint " .. joint)
				assert(#pose == 3 or #pose == 6, name .. "." .. joint .. " pose needs 3 or 6 numbers")
			end
		end
	end
	for name, action in Keyframes.Actions do
		checkAction(name, action)
	end
	checkAction("NPCIdle", Keyframes.NPCIdle)
	-- Everything tools and emotes play is animated.
	for toolId, tool in ToolConfig.Tools do
		-- (Idle is replaced by the hold poses below.)
		for _, slot in { "Use", "Heavy" } do
			local animationName = tool.Animations[slot]
			assert(animationName == nil or Keyframes.Actions[animationName], toolId .. " plays " .. tostring(animationName) .. " which has no keyframes")
		end
	end
	for _, name in { "Wave", "Cheer", "Point", "Dance", "OpenChest", "PlantSeed", "HarvestCrop", "FeedAnimal", "PetAnimal", "MilkCow", "FishingCast", "FishingReel", "FishingCatch" } do
		assert(Keyframes.Actions[name], name .. " has no keyframes")
		assert(AnimationConfig.Get(name), name .. " has no AnimationConfig entry")
	end
	for _, hold in { "HoldAxe", "HoldPickaxe", "HoldHammer", "HoldShovel", "HoldHoe", "HoldCan", "HoldRod", "HoldBucket", "HoldTool", "HoldItem" } do
		assert(Keyframes.Holds[hold], hold .. " hold pose missing")
	end
end)

test("every tool has three swings that share timing, with keyframes and a trail window", function()
	local AnimationConfig = require(Shared.Config.AnimationConfig)
	local Keyframes = require(Shared.Animation.Keyframes)
	local ToolConfig = require(Shared.Config.ToolConfig)
	local VFXConfig = require(Shared.Config.VFXConfig)
	for toolId, tool in ToolConfig.Tools do
		eq(AnimationConfig.VariantCount(tool.Animations.Use), 3, toolId .. " swing variants")
	end
	for base, names in AnimationConfig.Variants do
		local baseDef = AnimationConfig.Get(base)
		assert(baseDef, "variant base " .. base .. " missing")
		eq(names[1], base, base .. " lists itself first")
		local seen = {}
		for index, name in names do
			assert(not seen[name], base .. " repeats " .. name)
			seen[name] = true
			local def = AnimationConfig.Get(name)
			assert(def, name .. " has no AnimationConfig entry")
			assert(Keyframes.Actions[name], name .. " has no keyframes")
			eq(def.Length, baseDef.Length, name .. " length matches its base")
			for marker, time in baseDef.Markers do
				eq(def.Markers[marker], time, name .. " marker " .. marker)
			end
			eq(AnimationConfig.Variant(base, index), name, "Variant(" .. base .. ", " .. index .. ")")
		end
		eq(AnimationConfig.Variant(base, 99), names[#names], base .. " index clamps")
	end
	eq(AnimationConfig.Variant("PlantSeed", 2), "PlantSeed", "no variants -> itself")
	for name, def in AnimationConfig.Index do
		if def.Trail then
			assert(def.Trail[1] >= 0 and def.Trail[1] < def.Trail[2] and def.Trail[2] <= 1, name .. " trail window")
		end
		for marker, effects in def.MarkerEffects do
			assert(effects.Punch == nil or (effects.Punch > 0 and effects.Punch <= 3), name .. "." .. marker .. " punch")
		end
	end
	for _, effect in { "HitRing", "Stars", "HitPop", "Puff", "BigPuff", "RockShatter", "WoodSplinters", "Confetti", "Jiggle" } do
		assert(VFXConfig.Effects[effect], "VFX " .. effect .. " missing")
	end
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
		assert(building.Steps >= 1 or building.Node or building.Id == "SoilTile" or building.Hidden, buildingId .. " needs at least one step")
		if building.Node then
			assert(ResourceConfig.Nodes[building.Node], buildingId .. " plants unknown node " .. building.Node)
		end
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
			eq(grant.Upgrade, "Capacity", shopId .. " unknown upgrade")
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
		ExpandIsland = function(t) return t == nil end,
		PaintTerrain = function(t) return t == nil end,
		RenameIsland = function(t) return t == nil end,
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
	local IslandGen = require(Shared.Util.IslandGen)
	local sampler = IslandGen.NewSampler({ Seed = 7, Theme = "Tropical", Chunks = IslandGen.GenerateStarter(7, "Round"), Paint = {} })
	assert(Placement.IsOnLand(sampler, Vector2.new(0, 0), Vector2.new(10, 10)), "centre of the island is buildable")
	assert(not Placement.IsOnLand(sampler, Vector2.new(5000, 0), Vector2.new(10, 10)), "the sea is not buildable")
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
	data.Island.Buildings.S1 = { BuildingId = "SoilTile", Position = { X = 20, Y = 3, Z = 0 }, Rotation = 0, State = "Complete", Progress = 0 }
	data.Island.Buildings.S2 = { BuildingId = "SoilTile", Position = { X = 25, Y = 3, Z = 0 }, Rotation = 0, State = "Complete", Progress = 0 }
	data.Island.Crops = {
		S1 = { State = "Planted", CropId = "Wheat", PlantedAt = 10, WateredAt = "wet" },
		S2 = { State = "Planted", CropId = "Moonberry", PlantedAt = 10 },
		Gone = { State = "Planted", CropId = "Wheat", PlantedAt = 10 },
	}
	data.Island.Animals = { A1 = { AnimalId = "Cow", Happiness = 500 }, A2 = { AnimalId = "Dragon" } }
	local clean = DataSchema.Sanitize(data)
	local cottage = clean.Island.Buildings.B1
	assert(cottage, "valid building kept")
	eq(cottage.State, "Complete", "progress past the last step completes it")
	eq(clean.Island.Buildings.B2, nil, "unknown building removed")
	assert(clean.Quarantine.Buildings.B2, "unknown building quarantined")
	eq(clean.Island.Crops.S1.WateredAt, 0, "bad watered time repaired")
	eq(clean.Island.Crops.Gone, nil, "crop without a soil tile removed")
	assert(clean.Quarantine.Crops.S2 and clean.Island.Crops.S2 == nil, "unknown crop quarantined")
	eq(clean.Island.Animals.A1.Happiness, 100, "happiness clamped")
	assert(clean.Quarantine.Animals.A2 and clean.Island.Animals.A2 == nil, "unknown animal quarantined")
	assert(DataSchema.IsSaveable(clean))
end)

test("DataSchema v2 -> v3 migration turns areas into a unique chunk island", function()
	local DataSchema = require(Server.Data.DataSchema)
	local IslandGen = require(Shared.Util.IslandGen)
	local IslandConfig = require(Shared.Config.IslandConfig)
	local old = {
		Version = 2,
		Coins = 900,
		Island = {
			IslandId = "abc-123",
			Name = "Old Island",
			Level = 4,
			UnlockedAreas = { Starter = true, Forest = true },
			FarmTiles = 6,
			Buildings = {
				House1 = { BuildingId = "SmallCottage", UniqueId = "House1", Position = { X = 60, Y = 3, Z = -40 }, Rotation = 0, State = "Complete", Progress = 0 },
			},
			Crops = { S2 = { State = "Planted", CropId = "Wheat", PlantedAt = 50, WateredAt = 0 } },
			Upgrades = { FarmTiles = 1, Capacity = 2 },
		},
	}
	local data = DataSchema.Sanitize(old)
	eq(data.Version, DataSchema.CurrentVersion, "migrated")
	local island = data.Island
	eq(island.Created, true, "old players skip the island creator")
	eq(island.Name, "Old Island", "name kept")
	eq(island.UnlockedAreas, nil, "areas removed")
	eq(island.FarmTiles, nil, "farm tile count removed")
	assert(IslandGen.CountChunks(island.Chunks) >= IslandConfig.StarterChunks + 10, "extra area became extra land")
	local sampler = IslandGen.NewSampler({ Seed = island.Seed, Theme = island.Theme, Chunks = island.Chunks, Paint = {} })
	local cx, cz = IslandGen.ChunkOf(60, -40)
	assert(sampler:IsOwnedChunk(cx, cz), "the old house is still on owned land")
	assert(island.Buildings.House1, "house kept")
	local soil = 0
	for _, entry in island.Buildings do
		if entry.BuildingId == "SoilTile" then
			soil += 1
		end
	end
	eq(soil, 6, "old farm tiles became soil tiles")
	eq(island.Crops.SoilS2.CropId, "Wheat", "growing crop moved to its soil tile")
	eq(island.Upgrades.Capacity, 2, "other upgrades kept")
	eq(island.Upgrades.FarmTiles, nil, "farm upgrade removed")
	assert(DataSchema.IsSaveable(data))
	-- Deterministic: the same save migrates to the same island.
	local again = DataSchema.Sanitize(old)
	eq(IslandGen.CountChunks(again.Island.Chunks), IslandGen.CountChunks(island.Chunks), "stable migration")
end)

print(("\n%d passed, %d failed"):format(passed, failed))
if failed > 0 then
	error("logic tests failed")
end
