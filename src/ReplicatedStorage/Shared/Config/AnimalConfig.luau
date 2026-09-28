--[[
	SCRIPT NAME:  AnimalConfig
	SCRIPT TYPE:  ModuleScript (shared config)
	WHERE:        ReplicatedStorage/Shared/Config/AnimalConfig
	DEPENDENCIES: Shared.Util.TableUtil

	Animals, their products and the (gentle) care model.

	CARE LOOP:  Feed (costs Food) -> happiness up, production starts
	            -> after ProduceTime the product is READY -> Milk / Collect
	Happiness only drops while an animal is hungry, never below
	HappinessFloor, and high happiness gives a bonus product. Everything is
	computed from timestamps (Shared/Util/AnimalMath) — no per-frame work.
]]

local TableUtil = require(script.Parent.Parent.Util.TableUtil)

local AnimalConfig = {
	FullnessDurationMinutes = 12, -- a full animal gets hungry after this long
	HungryBelow = 25, -- fullness % at which it counts as hungry
	HappinessDecayPerMinute = 2, -- only while hungry
	HappinessFloor = 30,
	StartHappiness = 70,
	FeedHappiness = 15,
	PetHappiness = 8,
	PetCooldown = 30,
	BonusProduceAtHappiness = 80,
	WanderInterval = 2.5,
	ActiveRange = 160, -- animals only wander while a player is this close

	Animals = {
		Cow = {
			DisplayName = "Cow", Icon = "🐄", Price = 120, UnlockLevel = 1,
			Housing = "Barn", Food = "Wheat", FoodAmount = 1,
			Produce = "Milk", ProduceTime = 90, ProduceAmount = 1,
			ProduceVerb = "Milk Cow", ProduceTool = "Bucket", ProduceAnimation = "MilkCow", ProduceMarker = "Milk",
			ProduceVFX = "MilkSplash", ProduceSound = "Milk", WalkSpeed = 3, Voice = "CowMoo",
			Variants = {
				{ Id = "Brown", Weight = 50, Body = Color3.fromRGB(125, 85, 55), Spots = Color3.fromRGB(245, 240, 230) },
				{ Id = "Spotted", Weight = 42, Body = Color3.fromRGB(245, 245, 240), Spots = Color3.fromRGB(45, 40, 40) },
				{ Id = "Golden", Weight = 3, Body = Color3.fromRGB(245, 200, 70), Spots = Color3.fromRGB(255, 240, 180), ProduceBonus = 1 },
			},
		},
		Chicken = {
			DisplayName = "Chicken", Icon = "🐔", Price = 50, UnlockLevel = 1,
			Housing = "ChickenCoop", Food = "Wheat", FoodAmount = 1,
			Produce = "Egg", ProduceTime = 60, ProduceAmount = 1,
			ProduceVerb = "Collect Eggs", ProduceTool = nil, ProduceAnimation = "PickCrop", ProduceMarker = "Pick",
			ProduceVFX = "Sparkle", ProduceSound = "Harvest", WalkSpeed = 4, Voice = "ChickenCluck",
			Variants = {
				{ Id = "White", Weight = 55, Body = Color3.fromRGB(250, 250, 245), Spots = Color3.fromRGB(230, 60, 50) },
				{ Id = "Brown", Weight = 40, Body = Color3.fromRGB(170, 110, 60), Spots = Color3.fromRGB(230, 60, 50) },
				{ Id = "Golden", Weight = 3, Body = Color3.fromRGB(250, 205, 70), Spots = Color3.fromRGB(230, 60, 50), ProduceBonus = 1 },
			},
		},
	},

	Order = { "Cow", "Chicken" },

	Items = {
		Milk = { DisplayName = "Milk", Category = "AnimalProducts", Rarity = "Common", SellValue = 30, Icon = "🥛", Description = "Fresh milk from a happy cow." },
		Egg = { DisplayName = "Egg", Category = "AnimalProducts", Rarity = "Common", SellValue = 15, Icon = "🥚", Description = "A freshly laid egg." },
	},
}

for animalId, animal in AnimalConfig.Animals do
	animal.Id = animalId
end

return TableUtil.DeepFreeze(AnimalConfig)
