--[[
	SCRIPT NAME:  ProgressionConfig
	SCRIPT TYPE:  ModuleScript (shared config)
	WHERE:        ReplicatedStorage/Shared/Config/ProgressionConfig
	DEPENDENCIES: Shared.Util.TableUtil

	XP curves, level titles and XP SOURCES. The server awards XP by source id
	(ProgressionService.Award(player, "StarterChest")); the amount always comes
	from this table, never from a client.
]]

local TableUtil = require(script.Parent.Parent.Util.TableUtil)

local ProgressionConfig = {
	Player = {
		MaxLevel = 100,
	},
	Island = {
		MaxLevel = 100,
		-- Rename freely; the highest title whose Level <= island level is shown.
		Titles = {
			{ Level = 1, Title = "Starter Island" },
			{ Level = 5, Title = "Small Farmer" },
			{ Level = 10, Title = "Established Island" },
			{ Level = 20, Title = "Prosperous Island" },
			{ Level = 35, Title = "Island Builder" },
			{ Level = 50, Title = "Master Islander" },
		},
	},

	-- XP granted per action. Player = player XP, Island = island XP.
	Sources = {
		StarterChest = { Player = 25, Island = 40 },
		UnlockArea = { Player = 100, Island = 150 },
		ChopTree = { Player = 3, Island = 2 },
		MineRock = { Player = 3, Island = 2 },
		GatherFiber = { Player = 2, Island = 1 },
		BuildStep = { Player = 2, Island = 1 },
		BuildComplete = { Player = 20, Island = 25 },
		PlantCrop = { Player = 1, Island = 1 },
		HarvestCrop = { Player = 4, Island = 3 },
		CatchFish = { Player = 8, Island = 4 }, -- multiplied by rarity rank
		FeedAnimal = { Player = 2, Island = 1 },
		CollectProduce = { Player = 6, Island = 4 },
		BuyAnimal = { Player = 10, Island = 15 },
		SellItems = { Player = 2, Island = 2 },
	},
}

-- XP needed to go from `level` to `level + 1`.
function ProgressionConfig.PlayerXPForLevel(level: number): number
	return math.floor(60 * level ^ 1.45)
end

function ProgressionConfig.IslandXPForLevel(level: number): number
	return math.floor(50 * level ^ 1.5)
end

function ProgressionConfig.GetIslandTitle(level: number): string
	local title = ProgressionConfig.Island.Titles[1].Title
	for _, entry in ProgressionConfig.Island.Titles do
		if level >= entry.Level then
			title = entry.Title
		end
	end
	return title
end

return TableUtil.DeepFreeze(ProgressionConfig)
