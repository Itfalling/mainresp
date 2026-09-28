--[[
	SCRIPT NAME:  ResourceConfig
	SCRIPT TYPE:  ModuleScript (shared config)
	WHERE:        ReplicatedStorage/Shared/Config/ResourceConfig
	DEPENDENCIES: Shared.Util.TableUtil

	Raw gatherable resources + the resource NODES (trees, rocks, bushes...)
	that drop them. SellValue is the ONLY place the base price of a resource
	is defined (the market reads it through ItemConfig).

	NODES
		Resource        item id dropped
		Health          hit points (a tool hit deals Power x DamagePerPower)
		ToolType        tool type required (nil = gathered by hand)
		MinTier         minimum ToolConfig tier order (1 Wooden, 2 Stone, 3 Iron...)
		Drops           {Min, Max} per break (+1 chance from the tool's ResourceBonus)
		Respawn         seconds hidden before the node regrows (pooled, never destroyed)
		Action          verb shown on the prompt ("[E] Chop Tree")
		Animation/Marker  hand-gathered nodes only; tool nodes use the tool's Use animation
		XPSource        ProgressionConfig source id

	Icon: emoji used by the UI until real icon images exist. Image: optional
	Roblox image id (placeholder until you upload art).

	Future phases add their own item tables (CropConfig, FishConfig,
	AnimalConfig products, RecipeConfig outputs); ItemConfig merges them.
]]

local TableUtil = require(script.Parent.Parent.Util.TableUtil)

local PLACEHOLDER_IMAGE = "rbxassetid://PLACEHOLDER"

local ResourceConfig = {
	Items = {
		-- COMMON
		Wood = { DisplayName = "Wood", Category = "Resources", Rarity = "Common", SellValue = 2, Icon = "🪵", Image = PLACEHOLDER_IMAGE, Description = "Sturdy logs chopped from island trees. The backbone of every build." },
		Stone = { DisplayName = "Stone", Category = "Resources", Rarity = "Common", SellValue = 3, Icon = "🪨", Image = PLACEHOLDER_IMAGE, Description = "Solid rock mined with a pickaxe. Used for foundations and tools." },
		Fiber = { DisplayName = "Fiber", Category = "Resources", Rarity = "Common", SellValue = 2, Icon = "🌾", Image = PLACEHOLDER_IMAGE, Description = "Tough plant fibers used for rope, nets and baskets." },
		Clay = { DisplayName = "Clay", Category = "Resources", Rarity = "Common", SellValue = 4, Icon = "🟫", Image = PLACEHOLDER_IMAGE, Description = "Soft riverbank clay. Fire it into bricks and pots." },
		Sand = { DisplayName = "Sand", Category = "Resources", Rarity = "Common", SellValue = 2, Icon = "⏳", Image = PLACEHOLDER_IMAGE, Description = "Fine beach sand. Glassmakers love it." },
		Water = { DisplayName = "Water", Category = "Resources", Rarity = "Common", SellValue = 1, Icon = "💧", Image = PLACEHOLDER_IMAGE, Description = "Fresh water from a well or pump. Crops and animals need it." },

		-- ADVANCED
		Iron = { DisplayName = "Iron Ore", Category = "Materials", Rarity = "Uncommon", SellValue = 12, Icon = "⛓️", Image = PLACEHOLDER_IMAGE, Description = "Ore from the mountain. Smelt it into iron tools." },
		Copper = { DisplayName = "Copper Ore", Category = "Materials", Rarity = "Uncommon", SellValue = 10, Icon = "🟠", Image = PLACEHOLDER_IMAGE, Description = "Shiny orange ore used for pipes and machinery." },
		Gold = { DisplayName = "Gold Ore", Category = "Materials", Rarity = "Rare", SellValue = 45, Icon = "🟡", Image = PLACEHOLDER_IMAGE, Description = "Precious ore buried deep in the mountain." },
		Crystal = { DisplayName = "Crystal", Category = "Materials", Rarity = "Epic", SellValue = 120, Icon = "💎", Image = PLACEHOLDER_IMAGE, Description = "A glowing crystal found only in island caves." },
		StarShard = { DisplayName = "Star Shard", Category = "Materials", Rarity = "Legendary", SellValue = 400, Icon = "🌟", Image = PLACEHOLDER_IMAGE, Description = "A fragment of a fallen star. Appears during meteor showers." },
		AncientWood = { DisplayName = "Ancient Wood", Category = "Materials", Rarity = "Epic", SellValue = 150, Icon = "🌳", Image = PLACEHOLDER_IMAGE, Description = "Timber from trees older than the island itself." },
	},

	Nodes = {
		Tree = {
			DisplayName = "Oak Tree", Resource = "Wood", Health = 100, ToolType = "Axe", MinTier = 1, DamagePerPower = 25,
			Drops = { Min = 3, Max = 5 }, Respawn = 40, Action = "Chop", XPSource = "ChopTree", Model = "Oak",
			HitSound = "WoodHit", BreakSound = "TreeFall", HitVFX = "WoodChips", BreakVFX = "LeafBurst", FallOver = true,
		},
		PineTree = {
			DisplayName = "Pine Tree", Resource = "Wood", Health = 125, ToolType = "Axe", MinTier = 1, DamagePerPower = 25,
			Drops = { Min = 4, Max = 6 }, Respawn = 50, Action = "Chop", XPSource = "ChopTree", Model = "Pine",
			HitSound = "WoodHit", BreakSound = "TreeFall", HitVFX = "WoodChips", BreakVFX = "LeafBurst", FallOver = true,
		},
		AncientTree = {
			DisplayName = "Ancient Tree", Resource = "AncientWood", Health = 300, ToolType = "Axe", MinTier = 3, DamagePerPower = 25,
			Drops = { Min = 1, Max = 2 }, Respawn = 300, Action = "Chop", XPSource = "ChopTree", Model = "Ancient",
			HitSound = "WoodHit", BreakSound = "TreeFall", HitVFX = "WoodChips", BreakVFX = "Sparkle", FallOver = true,
		},
		Rock = {
			DisplayName = "Rock", Resource = "Stone", Health = 100, ToolType = "Pickaxe", MinTier = 1, DamagePerPower = 25,
			Drops = { Min = 2, Max = 4 }, Respawn = 50, Action = "Mine", XPSource = "MineRock", Model = "Rock",
			HitSound = "RockHit", BreakSound = "RockBreak", HitVFX = "RockChips", BreakVFX = "RockChips", Shake = 0.12,
		},
		IronRock = {
			DisplayName = "Iron Deposit", Resource = "Iron", Health = 150, ToolType = "Pickaxe", MinTier = 2, DamagePerPower = 25,
			Drops = { Min = 1, Max = 3 }, Respawn = 90, Action = "Mine", XPSource = "MineRock", Model = "Iron",
			HitSound = "RockHit", BreakSound = "RockBreak", HitVFX = "RockChips", BreakVFX = "RockChips", Shake = 0.15,
		},
		CrystalRock = {
			DisplayName = "Crystal Cluster", Resource = "Crystal", Health = 200, ToolType = "Pickaxe", MinTier = 3, DamagePerPower = 25,
			Drops = { Min = 1, Max = 2 }, Respawn = 180, Action = "Mine", XPSource = "MineRock", Model = "Crystal",
			HitSound = "RockHit", BreakSound = "RockBreak", HitVFX = "Sparkle", BreakVFX = "Sparkle", Shake = 0.15,
		},
		FiberBush = {
			DisplayName = "Fiber Bush", Resource = "Fiber", Health = 1, ToolType = nil, MinTier = 0, DamagePerPower = 1,
			Drops = { Min = 2, Max = 3 }, Respawn = 30, Action = "Pick", XPSource = "GatherFiber", Model = "Bush",
			Animation = "PickCrop", Marker = "Pick", HitSound = "Harvest", HitVFX = "LeafBurst", BreakVFX = "LeafBurst",
		},
		SandPile = {
			DisplayName = "Sand Pile", Resource = "Sand", Health = 1, ToolType = nil, MinTier = 0, DamagePerPower = 1,
			Drops = { Min = 2, Max = 4 }, Respawn = 40, Action = "Scoop", XPSource = "GatherFiber", Model = "Sand",
			Animation = "PickCrop", Marker = "Pick", HitSound = "ShovelDig", HitVFX = "DirtPuff", BreakVFX = "DirtPuff",
		},
		ClayPatch = {
			DisplayName = "Clay Patch", Resource = "Clay", Health = 1, ToolType = "Shovel", MinTier = 1, DamagePerPower = 1,
			Drops = { Min = 2, Max = 3 }, Respawn = 45, Action = "Dig", XPSource = "GatherFiber", Model = "Clay",
			HitSound = "ShovelDig", HitVFX = "DirtPuff", BreakVFX = "DirtPuff",
		},
	},
}

return TableUtil.DeepFreeze(ResourceConfig)
