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

print(("\n%d passed, %d failed"):format(passed, failed))
if failed > 0 then
	error("logic tests failed")
end
