--[[
	SCRIPT NAME:  FishConfig
	SCRIPT TYPE:  ModuleScript (shared config)
	WHERE:        ReplicatedStorage/Shared/Config/FishConfig
	DEPENDENCIES: Shared.Util.TableUtil

	Fish, fishing zones and the reel minigame tuning. The SERVER rolls which
	fish bites (the client never names a fish); the client only plays the
	minigame, and the server checks the reel took a plausible amount of time.

	Zones come from where the fishing spot is: the starter dock is "Shore";
	unlocking areas adds River / Ocean / Cave spots (IslandConfig area Content).
]]

local TableUtil = require(script.Parent.Parent.Util.TableUtil)

local FishConfig = {
	CastCooldown = 1,
	BiteDelay = { Min = 2.5, Max = 6 }, -- seconds; better rods shorten it
	HookWindow = 1.6, -- seconds the player has to react to a bite
	MaxReelTime = 30,
	SpotRange = 14, -- how close the player must stand to a fishing spot

	-- Relative chance per rarity (rods multiply the rarer ones by RodLuck^(rank-1)).
	RarityWeights = { Common = 60, Uncommon = 26, Rare = 10, Epic = 3.2, Legendary = 0.7, Mythic = 0.1 },
	RodLuckPerTier = 0.12,

	-- Reel minigame (client simulates; server uses MinReelTime to reject impossible catches).
	Minigame = {
		StartProgress = 0.25,
		GainRate = 0.38, -- progress / second while the fish is inside the zone
		LossRate = 0.22,
		DifficultyScale = 0.15, -- gain is divided by (1 + Difficulty * scale)
		ZoneSize = 0.3, -- minus 0.03 per difficulty
		IndicatorSize = 0.06,
		Gravity = 2.4,
		Lift = 2.6,
		MaxSpeed = 1.3,
	},

	Zones = {
		Shore = { DisplayName = "Shoreline", Fish = { "Bluegill", "Sardine", "Clownfish", "Pufferfish", "GoldenKoi" } },
		River = { DisplayName = "Willow River", Fish = { "Trout", "Catfish", "Salmon", "RainbowTrout", "RiverKing" } },
		Ocean = { DisplayName = "Coral Ocean", Fish = { "Mackerel", "Tuna", "Swordfish", "Sunfish", "Marlin" } },
		Cave = { DisplayName = "Starfall Pool", Fish = { "Glowfish", "CrystalFish", "Moonfish", "Starfin" } },
	},

	Fish = {
		Bluegill = { DisplayName = "Bluegill", Rarity = "Common", SellValue = 12, Weight = { 0.2, 0.8 }, Difficulty = 1, Color = Color3.fromRGB(90, 150, 220), Description = "A friendly little fish that loves the shallows." },
		Sardine = { DisplayName = "Sardine", Rarity = "Common", SellValue = 10, Weight = { 0.1, 0.4 }, Difficulty = 1, Color = Color3.fromRGB(170, 190, 210), Description = "Small, silver and always in a hurry." },
		Clownfish = { DisplayName = "Clownfish", Rarity = "Uncommon", SellValue = 30, Weight = { 0.2, 0.5 }, Difficulty = 2, Color = Color3.fromRGB(255, 140, 40), Description = "Bright orange with white stripes." },
		Pufferfish = { DisplayName = "Pufferfish", Rarity = "Rare", SellValue = 85, Weight = { 0.5, 2 }, Difficulty = 3, Color = Color3.fromRGB(230, 210, 120), Description = "Puffs up when surprised. Handle gently!" },
		GoldenKoi = { DisplayName = "Golden Koi", Rarity = "Epic", SellValue = 260, Weight = { 1.5, 4 }, Difficulty = 4, Color = Color3.fromRGB(255, 200, 40), Description = "A lucky golden fish said to bless islands." },

		Trout = { DisplayName = "Trout", Rarity = "Uncommon", SellValue = 35, Weight = { 0.8, 2.5 }, Difficulty = 2, Color = Color3.fromRGB(150, 170, 120), Description = "A speckled river swimmer." },
		Catfish = { DisplayName = "Catfish", Rarity = "Common", SellValue = 22, Weight = { 1, 4 }, Difficulty = 1, Color = Color3.fromRGB(120, 110, 90), Description = "Whiskered bottom-dweller." },
		Salmon = { DisplayName = "Salmon", Rarity = "Rare", SellValue = 95, Weight = { 2, 6 }, Difficulty = 3, Color = Color3.fromRGB(240, 130, 110), Description = "Strong swimmer that fights the current." },
		RainbowTrout = { DisplayName = "Rainbow Trout", Rarity = "Epic", SellValue = 280, Weight = { 2, 5 }, Difficulty = 4, Color = Color3.fromRGB(200, 120, 220), Description = "Shimmers in every colour." },
		RiverKing = { DisplayName = "River King", Rarity = "Legendary", SellValue = 650, Weight = { 8, 20 }, Difficulty = 5, Color = Color3.fromRGB(80, 200, 160), Description = "The ruler of Willow River." },

		Mackerel = { DisplayName = "Mackerel", Rarity = "Common", SellValue = 20, Weight = { 0.5, 1.5 }, Difficulty = 1, Color = Color3.fromRGB(80, 120, 150), Description = "Striped and speedy." },
		Tuna = { DisplayName = "Tuna", Rarity = "Uncommon", SellValue = 60, Weight = { 5, 20 }, Difficulty = 2, Color = Color3.fromRGB(60, 80, 140), Description = "A powerful ocean fish." },
		Swordfish = { DisplayName = "Swordfish", Rarity = "Rare", SellValue = 160, Weight = { 20, 60 }, Difficulty = 3, Color = Color3.fromRGB(90, 110, 170), Description = "Fast, proud and pointy." },
		Sunfish = { DisplayName = "Sunfish", Rarity = "Epic", SellValue = 380, Weight = { 40, 120 }, Difficulty = 4, Color = Color3.fromRGB(220, 220, 200), Description = "A gentle giant that sunbathes at the surface." },
		Marlin = { DisplayName = "Blue Marlin", Rarity = "Legendary", SellValue = 850, Weight = { 60, 200 }, Difficulty = 5, Color = Color3.fromRGB(40, 90, 200), Description = "The ultimate ocean trophy." },

		Glowfish = { DisplayName = "Glowfish", Rarity = "Rare", SellValue = 170, Weight = { 0.5, 2 }, Difficulty = 3, Color = Color3.fromRGB(120, 255, 200), Description = "Lights up the dark cave pool." },
		CrystalFish = { DisplayName = "Crystal Fish", Rarity = "Epic", SellValue = 460, Weight = { 1, 3 }, Difficulty = 4, Color = Color3.fromRGB(150, 230, 255), Description = "Scales as clear as glass." },
		Moonfish = { DisplayName = "Moonfish", Rarity = "Legendary", SellValue = 1000, Weight = { 2, 6 }, Difficulty = 5, Color = Color3.fromRGB(220, 220, 255), Description = "Only bites when the cave is perfectly still." },
		Starfin = { DisplayName = "Starfin", Rarity = "Mythic", SellValue = 3000, Weight = { 3, 8 }, Difficulty = 5, Color = Color3.fromRGB(255, 120, 220), Description = "A fish made of starlight. Almost a legend." },
	},

	Items = {} :: { [string]: any },
}

for fishId, fish in FishConfig.Fish do
	fish.Id = fishId
	FishConfig.Items[fishId] = {
		DisplayName = fish.DisplayName,
		Category = "Fish",
		Rarity = fish.Rarity,
		SellValue = fish.SellValue,
		Icon = "🐟",
		Description = fish.Description,
	}
end

-- Seconds a perfect player needs to fill the reel bar (server rejects faster catches).
function FishConfig.MinReelTime(difficulty: number): number
	local minigame = FishConfig.Minigame
	local gain = minigame.GainRate / (1 + difficulty * minigame.DifficultyScale)
	return (1 - minigame.StartProgress) / gain * 0.8
end

return TableUtil.DeepFreeze(FishConfig)
