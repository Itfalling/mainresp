--[[
	SCRIPT NAME:  RarityConfig
	SCRIPT TYPE:  ModuleScript (shared config)
	WHERE:        ReplicatedStorage/Shared/Config/RarityConfig
	DEPENDENCIES: Shared.Util.TableUtil

	Central rarity table used by items, fish, animals, drops and UI colors.
]]

local TableUtil = require(script.Parent.Parent.Util.TableUtil)

local RarityConfig = {
	Order = { "Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic" },

	Rarities = {
		Common = { Rank = 1, DisplayName = "Common", Color = Color3.fromRGB(170, 170, 170), ValueMultiplier = 1, Glow = false },
		Uncommon = { Rank = 2, DisplayName = "Uncommon", Color = Color3.fromRGB(96, 200, 90), ValueMultiplier = 1.5, Glow = false },
		Rare = { Rank = 3, DisplayName = "Rare", Color = Color3.fromRGB(70, 150, 255), ValueMultiplier = 3, Glow = false },
		Epic = { Rank = 4, DisplayName = "Epic", Color = Color3.fromRGB(170, 90, 255), ValueMultiplier = 6, Glow = true },
		Legendary = { Rank = 5, DisplayName = "Legendary", Color = Color3.fromRGB(255, 180, 40), ValueMultiplier = 15, Glow = true },
		Mythic = { Rank = 6, DisplayName = "Mythic", Color = Color3.fromRGB(255, 80, 150), ValueMultiplier = 40, Glow = true },
	},
}

function RarityConfig.Get(rarity: string?)
	return RarityConfig.Rarities[rarity or "Common"] or RarityConfig.Rarities.Common
end

return TableUtil.DeepFreeze(RarityConfig)
