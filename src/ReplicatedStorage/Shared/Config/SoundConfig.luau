--[[
	SCRIPT NAME:  SoundConfig
	SCRIPT TYPE:  ModuleScript (shared config)
	WHERE:        ReplicatedStorage/Shared/Config/SoundConfig
	DEPENDENCIES: Shared.Util.TableUtil

	Every sound in the game. ONLY two kinds of source are used, and each
	entry says which one it is:

	  BUILTIN   "rbxasset://sounds/..."  files that ship inside the Roblox
	            client itself (always available, no upload, no permissions).
	  DOCS      "rbxassetid://<n>"       audio assets used by Roblox's own
	            official Creator Hub tutorials (create.roblox.com/docs),
	            e.g. "Add 2D audio", "In-game sounds", "Create player tools".
	            The tutorial the id comes from is named next to it.

	Nothing here is made up. Sounds with no verified source yet
	(CowMoo, ChickenCluck...) stay "rbxassetid://PLACEHOLDER" and are
	skipped silently — paste your own ids from the Creator Store to fill
	them in (docs/ASSETS.md). PlaybackSpeed / PitchVariation turn the small
	set of real sounds into distinct effects for each action.
]]

local TableUtil = require(script.Parent.Parent.Util.TableUtil)

local PLACEHOLDER = "rbxassetid://PLACEHOLDER"

-- BUILTIN: files inside the Roblox client's content/sounds folder.
local BUILTIN = {
	Tick = "rbxasset://sounds/volume_slider.ogg", -- short UI tick
	Splash = "rbxasset://sounds/impact_water.mp3", -- water impact
	Hop = "rbxasset://sounds/action_jump.mp3", -- classic jump "boing"
	Thud = "rbxasset://sounds/action_jump_land.mp3", -- landing thud
	Step = "rbxasset://sounds/action_footsteps_plastic.mp3", -- footstep tap
	Boom = "rbxasset://sounds/impact_explosion_03.mp3", -- explosion (used quiet + slowed)
	Swim = "rbxasset://sounds/action_swim.mp3", -- water stroke
}

-- DOCS: asset ids from Roblox's official Creator Hub tutorials.
local DOCS = {
	Chime = "rbxassetid://4110925712", -- "In-game sounds": the simple feedback chime
	Jingle = "rbxassetid://3422389728", -- "Add 2D audio": retro jingle
	Chomp = "rbxassetid://9113723699", -- "Add 2D audio": gentle chomping
	Equip = "rbxassetid://282906960", -- "Create player tools": tool Equip sound
	Activate = "rbxassetid://130113322", -- "Create player tools": tool Activate sound
	Gate = "rbxassetid://5930776613", -- "Add 3D audio": sliding metal gate
	Music = "rbxassetid://1841461968", -- "Add 2D audio": upbeat music track
	Celebrate = "rbxassetid://1846248593", -- "Add 3D audio": cheerful celebratory track
	WaterAmbience = "rbxassetid://6564308795", -- "In-game sounds": waterfall ambience loop
	Rain = "rbxassetid://1516791621", -- "Add 3D audio": rain loop
}

local function sound(id: string, category: string, volume: number?, extra: { [string]: any }?)
	local def = {
		Id = id,
		Category = category,
		Volume = volume or 0.6,
		PlaybackSpeed = 1,
		PitchVariation = 0.05, -- random +/- speed so repeated hits don't sound robotic
		RollOffMaxDistance = 80,
	}
	if extra then
		for key, value in extra do
			def[key] = value
		end
	end
	return def
end

local SoundConfig = {
	Sources = { Builtin = BUILTIN, Docs = DOCS },

	-- Category volume mixers (multiplied with the player's SFX / music settings).
	Categories = {
		UI = 0.8,
		Coins = 0.8,
		Tools = 0.9,
		Building = 0.9,
		Farming = 0.9,
		Fishing = 0.9,
		Animals = 0.8,
		Environment = 0.5,
		Progress = 1,
		Rewards = 1,
		Music = 0.6,
	},

	Sounds = {
		-- UI
		UIClick = sound(BUILTIN.Tick, "UI", 0.5, { PitchVariation = 0.03, PlaybackSpeed = 1.2 }),
		UIHover = sound(BUILTIN.Tick, "UI", 0.15, { PitchVariation = 0, PlaybackSpeed = 1.6 }),
		UIOpen = sound(BUILTIN.Tick, "UI", 0.45, { PlaybackSpeed = 0.9 }),
		UIClose = sound(BUILTIN.Tick, "UI", 0.45, { PlaybackSpeed = 0.75 }),
		UINotify = sound(DOCS.Chime, "UI", 0.35, { PlaybackSpeed = 1.3 }),
		UIError = sound(BUILTIN.Tick, "UI", 0.6, { PitchVariation = 0, PlaybackSpeed = 0.5 }),

		-- Coins / rewards
		CoinGain = sound(DOCS.Chime, "Coins", 0.45, { PlaybackSpeed = 1.5 }),
		CoinSpend = sound(BUILTIN.Tick, "Coins", 0.4, { PlaybackSpeed = 0.9 }),
		ItemGain = sound(BUILTIN.Hop, "Rewards", 0.25, { PlaybackSpeed = 1.5 }),
		RareReward = sound(DOCS.Jingle, "Rewards", 0.7, { PitchVariation = 0 }),

		-- Progression
		LevelUp = sound(DOCS.Jingle, "Progress", 0.8, { PitchVariation = 0 }),
		IslandLevelUp = sound(DOCS.Jingle, "Progress", 0.9, { PitchVariation = 0, PlaybackSpeed = 0.9 }),
		AreaUnlock = sound(DOCS.Jingle, "Progress", 0.8, { PitchVariation = 0, PlaybackSpeed = 1.1 }),
		LandRise = sound(BUILTIN.Boom, "Progress", 0.35, { PitchVariation = 0, PlaybackSpeed = 0.45, RollOffMaxDistance = 200 }),
		ChestOpen = sound(DOCS.Chime, "Rewards", 0.8, { PlaybackSpeed = 0.8 }),
		QuestComplete = sound(DOCS.Chime, "Progress", 0.8, { PitchVariation = 0 }),

		-- Tools
		ToolEquip = sound(DOCS.Equip, "Tools", 0.35),
		ToolSwing = sound(DOCS.Activate, "Tools", 0.35, { PlaybackSpeed = 1.2 }),
		AxeSwing = sound(BUILTIN.Thud, "Tools", 0.8, { PlaybackSpeed = 1.25, PitchVariation = 0.1 }),
		PickaxeSwing = sound(BUILTIN.Thud, "Tools", 0.8, { PlaybackSpeed = 1.6, PitchVariation = 0.1 }),
		HammerSwing = sound(BUILTIN.Thud, "Tools", 0.7, { PlaybackSpeed = 1.4 }),
		ShovelDig = sound(BUILTIN.Step, "Tools", 0.8, { PlaybackSpeed = 0.7 }),
		HoeTill = sound(BUILTIN.Step, "Tools", 0.8, { PlaybackSpeed = 0.8 }),
		Shears = sound(BUILTIN.Tick, "Tools", 0.5, { PlaybackSpeed = 1.8 }),
		WoodHit = sound(BUILTIN.Thud, "Tools", 0.8, { PlaybackSpeed = 1.1 }),
		TreeFall = sound(BUILTIN.Boom, "Tools", 0.3, { PlaybackSpeed = 0.55, RollOffMaxDistance = 120 }),
		RockHit = sound(BUILTIN.Thud, "Tools", 0.8, { PlaybackSpeed = 1.7 }),
		RockBreak = sound(BUILTIN.Boom, "Tools", 0.25, { PlaybackSpeed = 0.9 }),

		-- Building
		HammerHit = sound(BUILTIN.Thud, "Building", 0.8, { PlaybackSpeed = 1.5, PitchVariation = 0.08 }),
		WoodPlace = sound(BUILTIN.Thud, "Building", 0.7, { PlaybackSpeed = 0.9 }),
		StonePlace = sound(BUILTIN.Thud, "Building", 0.7, { PlaybackSpeed = 0.7 }),
		Saw = sound(BUILTIN.Step, "Building", 0.6, { PlaybackSpeed = 1.6 }),
		Paint = sound(BUILTIN.Step, "Building", 0.4, { PlaybackSpeed = 1.3 }),
		ConstructionStart = sound(DOCS.Gate, "Building", 0.35, { PlaybackSpeed = 1.4 }),
		BuildComplete = sound(DOCS.Jingle, "Building", 0.7, { PitchVariation = 0, PlaybackSpeed = 1.05 }),
		PlaceInvalid = sound(BUILTIN.Tick, "Building", 0.6, { PitchVariation = 0, PlaybackSpeed = 0.5 }),

		-- Farming
		PlantSeed = sound(BUILTIN.Step, "Farming", 0.7, { PlaybackSpeed = 1.1 }),
		Watering = sound(BUILTIN.Swim, "Farming", 0.6, { PlaybackSpeed = 1.2 }),
		Harvest = sound(BUILTIN.Hop, "Farming", 0.5, { PlaybackSpeed = 1.3 }),

		-- Fishing
		FishingCast = sound(BUILTIN.Swim, "Fishing", 0.6, { PlaybackSpeed = 1.4 }),
		FishBite = sound(BUILTIN.Splash, "Fishing", 0.6, { PlaybackSpeed = 1.3 }),
		Reel = sound(BUILTIN.Tick, "Fishing", 0.3, { PlaybackSpeed = 2 }),
		FishCatch = sound(BUILTIN.Splash, "Fishing", 0.8),
		FishEscape = sound(BUILTIN.Splash, "Fishing", 0.5, { PlaybackSpeed = 0.7 }),

		-- Animals
		Feed = sound(DOCS.Chomp, "Animals", 0.7),
		Milk = sound(BUILTIN.Swim, "Animals", 0.5, { PlaybackSpeed = 0.8 }),
		Pet = sound(DOCS.Chime, "Animals", 0.4, { PlaybackSpeed = 1.8 }),
		CowMoo = sound(PLACEHOLDER, "Animals", 0.7), -- no verified source yet
		ChickenCluck = sound(PLACEHOLDER, "Animals", 0.6), -- no verified source yet

		-- Crafting
		CraftHit = sound(BUILTIN.Thud, "Building", 0.7, { PlaybackSpeed = 1.3 }),
		CraftComplete = sound(DOCS.Chime, "Rewards", 0.7),

		-- Social
		TradeInvite = sound(DOCS.Chime, "UI", 0.6, { PlaybackSpeed = 1.1 }),
		TradeComplete = sound(DOCS.Jingle, "Rewards", 0.7, { PlaybackSpeed = 1.15 }),
		Like = sound(DOCS.Chime, "UI", 0.6, { PlaybackSpeed = 1.6 }),

		-- Music + ambience (looped, 2D; AudioController keeps one of each playing)
		MusicMain = sound(DOCS.Music, "Music", 0.35, { Looped = true, PitchVariation = 0 }),
		AmbienceOcean = sound(DOCS.WaterAmbience, "Environment", 0.25, { Looped = true, PitchVariation = 0, PlaybackSpeed = 0.8 }),
		AmbienceRain = sound(DOCS.Rain, "Environment", 0.3, { Looped = true, PitchVariation = 0 }),
		AmbienceBirds = sound(PLACEHOLDER, "Environment", 0.3, { Looped = true, PitchVariation = 0 }),
	},
}

return TableUtil.DeepFreeze(SoundConfig)
