--[[
	SCRIPT NAME:  EconomyConfig
	SCRIPT TYPE:  ModuleScript (shared config)
	WHERE:        ReplicatedStorage/Shared/Config/EconomyConfig
	DEPENDENCIES: Shared.Util.TableUtil

	Currencies and global economy knobs. Item base prices live on the item
	definitions (ResourceConfig / CropConfig / FishConfig ...), never here and
	never inside scripts.
]]

local TableUtil = require(script.Parent.Parent.Util.TableUtil)

local EconomyConfig = {
	Currencies = {
		Coins = { DisplayName = "Island Coins", Icon = "🪙", Max = 1e12, Color = Color3.fromRGB(255, 200, 40) },
		Gems = { DisplayName = "Gems", Icon = "💎", Max = 1e9, Color = Color3.fromRGB(90, 200, 255) },
	},

	-- Multiplier applied to every sale (Phase 7 market events adjust per item).
	GlobalSellMultiplier = 1,
}

return TableUtil.DeepFreeze(EconomyConfig)
