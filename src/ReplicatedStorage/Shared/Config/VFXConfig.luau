--[[
	SCRIPT NAME:  VFXConfig
	SCRIPT TYPE:  ModuleScript (shared config)
	WHERE:        ReplicatedStorage/Shared/Config/VFXConfig
	DEPENDENCIES: Shared.Util.TableUtil

	Procedural effects played by the client VFXController. These use Roblox's
	built-in default particle texture and plain parts, so they work with NO
	uploaded assets. To use custom art, set Texture to a real image id.

	Types:
		Burst   one-shot particle emission (pooled emitters)
		Ring    an expanding, fading neon ring (pooled parts)
		Puff    cartoon dust clouds: soft balls that swell and fade
		Debris  chunks that fly out, bounce on the ground, shrink away
		        (rock shatter; `Confetti = true` = colourful paper bits)
		Pop     a quick neon flash sphere (impact "pow")
		Jiggle  squash / tilt / pop the TARGET model (options.Target)
	Effects can take options from the server: { Color, Count, Scale,
	Target, Style, From }.
]]

local TableUtil = require(script.Parent.Parent.Util.TableUtil)

local VFXConfig = {
	MaxDistance = 250, -- clients skip effects farther than this from the camera

	Effects = {
		Sparkle = { Type = "Burst", Count = 14, Color = Color3.fromRGB(255, 240, 150), Size = 0.5, Lifetime = 0.8, Speed = 8, Spread = 180, LightEmission = 1 },
		CoinBurst = { Type = "Burst", Count = 12, Color = Color3.fromRGB(255, 205, 50), Size = 0.6, Lifetime = 0.7, Speed = 14, Spread = 60, LightEmission = 0.6, Acceleration = Vector3.new(0, -30, 0) },
		ChestOpen = { Type = "Burst", Count = 24, Color = Color3.fromRGB(255, 225, 120), Size = 0.6, Lifetime = 1, Speed = 16, Spread = 45, LightEmission = 1 },
		LevelUp = { Type = "Ring", Color = Color3.fromRGB(120, 255, 170), StartSize = 2, EndSize = 18, Duration = 0.8, Height = 0.4 },
		IslandLevelUp = { Type = "Ring", Color = Color3.fromRGB(255, 220, 90), StartSize = 4, EndSize = 40, Duration = 1.2, Height = 0.6 },
		AreaUnlock = { Type = "Ring", Color = Color3.fromRGB(120, 230, 255), StartSize = 10, EndSize = 140, Duration = 2, Height = 1 },
		DirtPuff = { Type = "Burst", Count = 8, Color = Color3.fromRGB(140, 100, 60), Size = 0.7, Lifetime = 0.6, Speed = 6, Spread = 70, LightEmission = 0 },
		BuildDust = { Type = "Burst", Count = 10, Color = Color3.fromRGB(220, 200, 170), Size = 0.9, Lifetime = 0.8, Speed = 5, Spread = 90, LightEmission = 0 },
		BuildComplete = { Type = "Burst", Count = 28, Color = Color3.fromRGB(255, 250, 200), Size = 0.7, Lifetime = 1.2, Speed = 14, Spread = 180, LightEmission = 1 },
		WoodChips = { Type = "Burst", Count = 7, Color = Color3.fromRGB(190, 140, 80), Size = 0.4, Lifetime = 0.6, Speed = 12, Spread = 50, LightEmission = 0, Acceleration = Vector3.new(0, -40, 0) },
		RockChips = { Type = "Burst", Count = 7, Color = Color3.fromRGB(150, 150, 155), Size = 0.4, Lifetime = 0.6, Speed = 12, Spread = 50, LightEmission = 0, Acceleration = Vector3.new(0, -40, 0) },
		LeafBurst = { Type = "Burst", Count = 10, Color = Color3.fromRGB(110, 200, 80), Size = 0.5, Lifetime = 0.9, Speed = 7, Spread = 120, LightEmission = 0 },
		WaterSplash = { Type = "Burst", Count = 12, Color = Color3.fromRGB(170, 225, 255), Size = 0.5, Lifetime = 0.6, Speed = 12, Spread = 35, LightEmission = 0.3, Acceleration = Vector3.new(0, -50, 0) },
		MilkSplash = { Type = "Burst", Count = 8, Color = Color3.fromRGB(255, 255, 250), Size = 0.4, Lifetime = 0.5, Speed = 6, Spread = 30, LightEmission = 0.2, Acceleration = Vector3.new(0, -40, 0) },
		Hearts = { Type = "Burst", Count = 5, Color = Color3.fromRGB(255, 110, 150), Size = 0.6, Lifetime = 1.1, Speed = 4, Spread = 30, LightEmission = 0.5, Acceleration = Vector3.new(0, 3, 0) },

		-- Cartoon juice
		HitRing = { Type = "Ring", Color = Color3.fromRGB(255, 255, 255), StartSize = 1, EndSize = 7, Duration = 0.22, Height = 0.15 },
		Stars = { Type = "Burst", Count = 6, Color = Color3.fromRGB(255, 232, 90), Size = 0.8, Lifetime = 0.55, Speed = 18, Spread = 180, LightEmission = 1 },
		HitPop = { Type = "Pop", Color = Color3.fromRGB(255, 250, 220), StartSize = 0.6, EndSize = 3.2, Duration = 0.16 },
		Puff = { Type = "Puff", Count = 6, Color = Color3.fromRGB(236, 226, 206), Size = 2.4, Radius = 3.5, Duration = 0.9 },
		BigPuff = { Type = "Puff", Count = 11, Color = Color3.fromRGB(232, 222, 200), Size = 4, Radius = 7, Duration = 1.2 },
		RockShatter = { Type = "Debris", Count = 11, Color = Color3.fromRGB(150, 150, 155), Size = 1.2, Speed = 24, Duration = 1.6 },
		WoodSplinters = { Type = "Debris", Count = 6, Color = Color3.fromRGB(176, 124, 72), Size = 0.6, Speed = 16, Duration = 1.1 },
		Confetti = { Type = "Debris", Count = 26, Color = Color3.fromRGB(255, 255, 255), Size = 0.5, Speed = 30, Duration = 2.2, Confetti = true },
		Jiggle = { Type = "Jiggle" },
	},
}

return TableUtil.DeepFreeze(VFXConfig)
