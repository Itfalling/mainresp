--[[
	SCRIPT NAME:  QuestConfig
	SCRIPT TYPE:  ModuleScript (shared config)
	WHERE:        ReplicatedStorage/Shared/Config/QuestConfig
	DEPENDENCIES: Shared.Util.TableUtil

	Progression quests that double as the tutorial (spec §118/§119): each quest
	teaches one part of the core loop, and finishing it starts the next.

	Task events (recorded by QuestService from server-side signals only):
		CollectItem     Target = item id        (gathered, not bought)
		BuildComplete   Target = building id or category
		PlantCrop / HarvestCrop   Target = crop id (optional)
		CatchFish       Target = fish id (optional)
		SellItem        Target = item id (optional)
		BuyAnimal / BuyTool       Target = id
		FeedAnimal      Target = animal id
		CollectProduce  Target = item id (Milk, Egg)
		ExpandIsland    buy one chunk of land (additive)
		PaintTerrain    paint terrain cells (additive)
		RenameIsland    give the island a name
		IslandLevel     progress = current island level (not additive)
]]

local TableUtil = require(script.Parent.Parent.Util.TableUtil)

local QuestConfig = {
	Chain = { "StartYourIsland", "FirstAnimal", "GrowYourIsland", "IslandDesigner", "Adventurer" },

	Quests = {
		StartYourIsland = {
			DisplayName = "START YOUR ISLAND",
			Tasks = {
				{ Id = "Wood", Text = "Collect 20 Wood", Hint = "Hold your 🪓 Axe (press 1) and click a tree", Event = "CollectItem", Target = "Wood", Amount = 20 },
				{ Id = "Stone", Text = "Collect 10 Stone", Hint = "Hold your ⛏️ Pickaxe (press 2) and click a rock", Event = "CollectItem", Target = "Stone", Amount = 10 },
				{ Id = "House", Text = "Build your first house", Hint = "Press B → Homes → Small Cottage, then hold your 🔨 and click it", Event = "BuildComplete", Target = "Homes", Amount = 1 },
				{ Id = "Plant", Text = "Plant 5 crops", Hint = "Hoe: click soil to till · hold a seed sack: click to plant", Event = "PlantCrop", Amount = 5 },
				{ Id = "Fish", Text = "Catch 1 fish", Hint = "Hold your 🎣 rod and click the water", Event = "CatchFish", Amount = 1 },
				{ Id = "Sell", Text = "Sell 1 item", Hint = "Click the market stall near your spawn", Event = "SellItem", Amount = 1 },
			},
			Reward = { Coins = 250, XP = 100, IslandXP = 150 },
		},
		FirstAnimal = {
			DisplayName = "RAISE YOUR FIRST ANIMAL",
			Tasks = {
				{ Id = "Barn", Text = "Build a Barn", Hint = "Build mode → Farm → Barn", Event = "BuildComplete", Target = "Barn", Amount = 1 },
				{ Id = "Cow", Text = "Buy a Cow", Hint = "Market stall → Buy → Animals", Event = "BuyAnimal", Target = "Cow", Amount = 1 },
				{ Id = "Feed", Text = "Feed your Cow", Hint = "Hold 🌾 Wheat (hotbar) and click your cow", Event = "FeedAnimal", Target = "Cow", Amount = 1 },
				{ Id = "Milk", Text = "Milk your Cow", Hint = "When it says READY, hold your 🪣 bucket and click", Event = "CollectProduce", Target = "Milk", Amount = 1 },
			},
			Reward = { Coins = 300, XP = 150, IslandXP = 200 },
		},
		GrowYourIsland = {
			DisplayName = "GROW YOUR ISLAND",
			Tasks = {
				{ Id = "Harvest", Text = "Harvest 20 crops", Hint = "Water crops to grow them faster", Event = "HarvestCrop", Amount = 20 },
				{ Id = "Fish", Text = "Catch 5 fish", Hint = "Better rods find rarer fish", Event = "CatchFish", Amount = 5 },
				{ Id = "Sell", Text = "Sell 30 items", Hint = "Check the market demand bonus!", Event = "SellItem", Amount = 30 },
				{ Id = "Expand", Text = "Expand your island 3 times", Hint = "Build mode (B) → 🏝️ Expand → click glowing water squares", Event = "ExpandIsland", Amount = 3 },
			},
			Reward = { Coins = 500, XP = 250, IslandXP = 300 },
		},
		IslandDesigner = {
			DisplayName = "ISLAND DESIGNER",
			Tasks = {
				{ Id = "Rename", Text = "Rename your island", Hint = "Click your island sign by the spawn", Event = "RenameIsland", Amount = 1 },
				{ Id = "Paint", Text = "Paint 12 patches of terrain", Hint = "Build mode (B) → 🎨 Paint → pick a path or grass", Event = "PaintTerrain", Amount = 12 },
				{ Id = "Trees", Text = "Plant 3 trees", Hint = "Build mode → 🌳 Nature → Oak / Palm / Pine", Event = "BuildComplete", Target = "Nature", Amount = 3 },
				{ Id = "Tiles", Text = "Own 10 soil tiles", Hint = "Build mode → 🐄 Farm → Soil Tile (you start with 6)", Event = "BuildComplete", Target = "SoilTile", Amount = 10 },
			},
			Reward = { Coins = 400, XP = 200, IslandXP = 250 },
		},
		Adventurer = {
			DisplayName = "ISLAND ADVENTURER",
			Tasks = {
				{ Id = "Pickaxe", Text = "Buy a Stone Pickaxe", Hint = "Market stall → Buy → Tools", Event = "BuyTool", Target = "StonePickaxe", Amount = 1 },
				{ Id = "Cabin", Text = "Build a Wooden Cabin", Hint = "Needs Island Level 3", Event = "BuildComplete", Target = "WoodenCabin", Amount = 1 },
				{ Id = "Chicken", Text = "Collect 3 Eggs", Hint = "Build a Chicken Coop and buy chickens", Event = "CollectProduce", Target = "Egg", Amount = 3 },
				{ Id = "Level", Text = "Reach Island Level 5", Hint = "Everything you do grows your island", Event = "IslandLevel", Amount = 5 },
			},
			Reward = { Coins = 1000, XP = 400, IslandXP = 500 },
		},
	},
}

for questId, quest in QuestConfig.Quests do
	quest.Id = questId
end

function QuestConfig.NextQuest(questId: string): string?
	local index = table.find(QuestConfig.Chain, questId)
	if not index then
		return nil
	end
	return QuestConfig.Chain[index + 1]
end

return TableUtil.DeepFreeze(QuestConfig)
