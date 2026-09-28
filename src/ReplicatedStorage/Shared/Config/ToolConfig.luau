--[[
	SCRIPT NAME:  ToolConfig
	SCRIPT TYPE:  ModuleScript (shared config)
	WHERE:        ReplicatedStorage/Shared/Config/ToolConfig
	DEPENDENCIES: Shared.Util.TableUtil

	Every tool in the game. Tools are generated from TYPES x TIERS so adding a
	new tier (or a new tool type) is one table entry.

	Tool ID format: <Tier><Type>, e.g. "WoodenAxe", "IronPickaxe".

	Stats:
		Power         how much "damage" one hit does to a tree/rock (Phase 2)
		Speed         use-speed multiplier (animation + cooldown)
		ResourceBonus chance (0..1) for +1 extra resource per drop
		UnlockLevel   player level required to buy/craft (Phase 7/8)
		Price         coin price in the shop (Phase 7)

	Visuals:
		Grip.Hand     R15 hand the tool attaches to ("RightHand" or "LeftHand")
		Grip.Offset   extra CFrame applied on top of the hand's grip attachment
		Shape         procedural placeholder model (see Server/Tools/ToolModelFactory)
		If ServerStorage/Tools/<ToolId> exists (a Model with a "Handle" part and
		a "Grip" Attachment), that art is used instead of the placeholder shape.
]]

local TableUtil = require(script.Parent.Parent.Util.TableUtil)

local ToolConfig = {
	HotbarSize = 9,

	Tiers = {
		Wooden = { Order = 1, DisplayName = "Wooden", Power = 1, Speed = 1.0, ResourceBonus = 0, UnlockLevel = 1, Price = 0, HeadColor = Color3.fromRGB(165, 115, 65), HeadMaterial = Enum.Material.Wood },
		Stone = { Order = 2, DisplayName = "Stone", Power = 2, Speed = 1.1, ResourceBonus = 0.05, UnlockLevel = 3, Price = 250, HeadColor = Color3.fromRGB(140, 140, 145), HeadMaterial = Enum.Material.Slate },
		Iron = { Order = 3, DisplayName = "Iron", Power = 3, Speed = 1.2, ResourceBonus = 0.1, UnlockLevel = 8, Price = 1500, HeadColor = Color3.fromRGB(205, 205, 215), HeadMaterial = Enum.Material.Metal },
		Gold = { Order = 4, DisplayName = "Gold", Power = 4, Speed = 1.35, ResourceBonus = 0.15, UnlockLevel = 15, Price = 8000, HeadColor = Color3.fromRGB(255, 200, 50), HeadMaterial = Enum.Material.Metal },
		Crystal = { Order = 5, DisplayName = "Crystal", Power = 6, Speed = 1.5, ResourceBonus = 0.22, UnlockLevel = 25, Price = 40000, HeadColor = Color3.fromRGB(120, 220, 255), HeadMaterial = Enum.Material.Glass },
		Mythic = { Order = 6, DisplayName = "Mythic", Power = 9, Speed = 1.7, ResourceBonus = 0.3, UnlockLevel = 40, Price = 250000, HeadColor = Color3.fromRGB(190, 90, 255), HeadMaterial = Enum.Material.Neon },
	},

	Types = {
		Axe = {
			DisplayName = "Axe",
			Icon = "🪓",
			Shape = "Axe",
			Tiers = { "Wooden", "Stone", "Iron", "Gold", "Crystal", "Mythic" },
			UseCooldown = 0.7,
			Grip = { Hand = "RightHand", Offset = CFrame.new() },
			Animations = { Idle = "AxeIdle", Use = "AxeSwing", Heavy = "AxeHeavySwing" },
			Sounds = { Use = "AxeSwing" },
			Description = "Chops trees for wood.",
		},
		Pickaxe = {
			DisplayName = "Pickaxe",
			Icon = "⛏️",
			Shape = "Pickaxe",
			Tiers = { "Wooden", "Stone", "Iron", "Gold", "Crystal", "Mythic" },
			UseCooldown = 0.75,
			Grip = { Hand = "RightHand", Offset = CFrame.new() },
			Animations = { Idle = "PickaxeIdle", Use = "PickaxeSwing", Heavy = "PickaxeHeavySwing" },
			Sounds = { Use = "PickaxeSwing" },
			Description = "Mines rocks and ore.",
		},
		Hammer = {
			DisplayName = "Hammer",
			Icon = "🔨",
			Shape = "Hammer",
			Tiers = { "Wooden", "Stone", "Iron", "Gold" },
			UseCooldown = 0.65,
			Grip = { Hand = "RightHand", Offset = CFrame.new() },
			Animations = { Idle = "BuildIdle", Use = "HammerSwing", Heavy = "HammerHeavy" },
			Sounds = { Use = "HammerSwing" },
			Description = "Builds and upgrades structures faster.",
		},
		Shovel = {
			DisplayName = "Shovel",
			Icon = "🪏",
			Shape = "Shovel",
			Tiers = { "Wooden", "Stone", "Iron", "Gold" },
			UseCooldown = 0.8,
			Grip = { Hand = "RightHand", Offset = CFrame.new() },
			Animations = { Idle = "ToolHoldIdle", Use = "ShovelDig", Heavy = "ShovelDigHeavy" },
			Sounds = { Use = "ShovelDig" },
			Description = "Digs clay, sand and buried treasure.",
		},
		Hoe = {
			DisplayName = "Hoe",
			Icon = "🌱",
			Shape = "Hoe",
			Tiers = { "Wooden", "Stone", "Iron", "Gold" },
			UseCooldown = 0.7,
			Grip = { Hand = "RightHand", Offset = CFrame.new() },
			Animations = { Idle = "ToolHoldIdle", Use = "HoeTill" },
			Sounds = { Use = "HoeTill" },
			Description = "Tills soil so seeds can be planted.",
		},
		WateringCan = {
			DisplayName = "Watering Can",
			Icon = "🚿",
			Shape = "WateringCan",
			Tiers = { "Wooden", "Iron", "Gold" },
			UseCooldown = 1.0,
			Grip = { Hand = "RightHand", Offset = CFrame.new() },
			Animations = { Idle = "ToolHoldIdle", Use = "WaterPlant", Loop = "WaterLoop", End = "WaterEnd" },
			Sounds = { Use = "Watering" },
			Description = "Waters crops so they grow faster.",
		},
		FishingRod = {
			DisplayName = "Fishing Rod",
			Icon = "🎣",
			Shape = "FishingRod",
			Tiers = { "Wooden", "Iron", "Gold", "Crystal", "Mythic" },
			UseCooldown = 1.2,
			Grip = { Hand = "RightHand", Offset = CFrame.new() },
			Animations = { Idle = "FishingIdle", Use = "FishingCast", Reel = "FishingReel" },
			Sounds = { Use = "FishingCast" },
			Description = "Cast into water to catch fish.",
		},
		Bucket = {
			DisplayName = "Bucket",
			Icon = "🪣",
			Shape = "Bucket",
			Tiers = { "Wooden", "Iron" },
			UseCooldown = 1.0,
			Grip = { Hand = "RightHand", Offset = CFrame.new() },
			Animations = { Idle = "CarryBucket", Use = "BucketSwing" },
			Sounds = { Use = "Milk" },
			Description = "Carries water and collects milk.",
		},
		Shears = {
			DisplayName = "Shears",
			Icon = "✂️",
			Shape = "Shears",
			Tiers = { "Iron", "Gold" },
			UseCooldown = 1.0,
			Grip = { Hand = "RightHand", Offset = CFrame.new() },
			Animations = { Idle = "ToolHoldIdle", Use = "ShearsSnip" },
			Sounds = { Use = "Shears" },
			Description = "Shears wool from happy sheep.",
		},
	},

	Tools = {} :: { [string]: any },
}

-- Generate the flat Tools table.
for typeId, typeDef in ToolConfig.Types do
	for _, tierId in typeDef.Tiers do
		local tier = ToolConfig.Tiers[tierId]
		assert(tier, ("Tool type %s references unknown tier %s"):format(typeId, tierId))
		local toolId = tierId .. typeId
		ToolConfig.Tools[toolId] = {
			Id = toolId,
			Type = typeId,
			Tier = tierId,
			TierOrder = tier.Order,
			DisplayName = tier.DisplayName .. " " .. typeDef.DisplayName,
			Icon = typeDef.Icon,
			Description = typeDef.Description,
			Shape = typeDef.Shape,
			Power = tier.Power,
			Speed = tier.Speed,
			ResourceBonus = tier.ResourceBonus,
			UnlockLevel = tier.UnlockLevel,
			Price = tier.Price,
			UseCooldown = typeDef.UseCooldown / tier.Speed,
			Grip = typeDef.Grip,
			Animations = typeDef.Animations,
			Sounds = typeDef.Sounds,
			HeadColor = tier.HeadColor,
			HeadMaterial = tier.HeadMaterial,
		}
	end
end

function ToolConfig.Get(toolId: any)
	if type(toolId) ~= "string" then
		return nil
	end
	return ToolConfig.Tools[toolId]
end

return TableUtil.DeepFreeze(ToolConfig)
