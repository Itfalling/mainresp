--[[
	SCRIPT NAME:  BuildConfig
	SCRIPT TYPE:  ModuleScript (shared config)
	WHERE:        ReplicatedStorage/Shared/Config/BuildConfig
	DEPENDENCIES: GameConfig, Shared.Util.TableUtil

	Placement rules shared by the client preview (BuildController) and the
	server validator (BuildService), so both always agree.
]]

local TableUtil = require(script.Parent.Parent.Util.TableUtil)
local GameConfig = require(script.Parent.GameConfig)

local BuildConfig = {
	GridSize = GameConfig.BuildGridSize,
	Rotations = { 0, 90, 180, 270 },
	MaxSlope = 4, -- max terrain height difference (studs) across a footprint
	PlacementRange = 80, -- how far from the player a building can be placed
	PlaceCooldown = 0.5,
	HammerRange = 16,
	HammerCooldown = 0.45,
	OverlapShrink = 0.4, -- shrink overlap boxes so neighbours can touch

	-- Island model folders whose contents block placement.
	-- (Decorations are cosmetic: builds hide the scatter under them instead.)
	BlockingFolders = { "Buildings", "Landmarks", "Interactables", "Resources", "Crops", "Animals" },
	RemoveNodeRefund = true, -- clearing a natural tree/rock gives its resources once
}

return TableUtil.DeepFreeze(BuildConfig)
