--[[
	SCRIPT NAME:  AnimationConfig
	SCRIPT TYPE:  ModuleScript (shared config)
	WHERE:        ReplicatedStorage/Shared/Config/AnimationConfig
	DEPENDENCIES: Shared.Util.TableUtil

	HOW ANIMATION WORKS IN THIS GAME
	Every action below is FULLY ANIMATED out of the box: real R15 keyframes
	live in Shared/Animation/Keyframes and every client plays them on every
	character (so all players see each other chop, fish, milk, dance...).
	The Id fields are "rbxassetid://PLACEHOLDER" because no uploaded
	animation ships with this project (we never invent asset ids). If you
	upload your own R15 animation, paste its id here and clients play it
	instead of the built-in keyframes — nothing else changes.

	Length and Markers here drive BOTH the keyframes (impact frames sit on the
	markers) and the server's gameplay timing (AnimationService.PerformAction).

	MOVEMENT (idle / walk / run / jump / fall / swim / climb) is procedural:
	Client/Animation/Locomotion, which replaces Roblox's default Animate
	script. The Movement entries below are kept as documentation.

	Field reference (spec §74):
		Id            rbxassetid:// of the uploaded animation
		Purpose       what gameplay it supports
		Priority      Core | Idle | Movement | Action | Action2 | Action3 | Action4
		Length        seconds (at Speed 1). Used for placeholder timing.
		Looped        loops until stopped
		Markers       { MarkerName = timeInSeconds } — gameplay reacts to these
		MarkerEffects { MarkerName = { Sound = "<SoundConfig id>", VFX = "<VFXConfig id>", Shake = number } }
		BodyParts     which R15 parts the animation should key (documentation for animators)
		Start / End   start + end conditions (documentation)
		Interruptible can a new action cut it off
		Repeat        play the keyframe cycle this many times (emotes)
		Trail         { from, to } fraction of Length when the held tool's
		              swing trail is visible (cartoon smear)
		MarkerEffects[...].Punch   camera punch strength for YOUR swings

	SWING VARIANTS: every tool has three swings (AnimationConfig.Variants).
	Each swing plays a random one; the client picks it (so its prediction
	matches) and tells the server, which plays the same one for everyone.
		Fallback      (legacy, unused)
		AnimateSlot   (Movement only) { childName, animationName } inside the default Animate script

	Priority rules (spec §73):
		Movement -> Movement | Tool actions -> Action | Building -> Action
		Fishing -> Action2 | Major interactions -> Action2
		Celebration -> Action3 | Death -> Action4
]]

local TableUtil = require(script.Parent.Parent.Util.TableUtil)

local PLACEHOLDER = "rbxassetid://PLACEHOLDER"

local ARMS = "RightUpperArm, RightLowerArm, RightHand, LeftUpperArm, LeftLowerArm, LeftHand, UpperTorso"
local FULL_BODY = "All R15 parts"

local function anim(def: { [string]: any })
	def.Id = def.Id or PLACEHOLDER
	def.Priority = def.Priority or "Action"
	def.Length = def.Length or 1
	def.Looped = def.Looped or false
	def.Markers = def.Markers or {}
	def.MarkerEffects = def.MarkerEffects or {}
	if def.Interruptible == nil then
		def.Interruptible = true
	end
	def.FadeIn = def.FadeIn or 0.1
	def.FadeOut = def.FadeOut or 0.15
	def.BodyParts = def.BodyParts or ARMS
	return def
end

local AnimationConfig = {
	-- If a REAL animation is missing a configured marker, fire it anyway this
	-- many seconds after its configured time (and warn once).
	MarkerWatchdogGrace = 0.15,

	Categories = {
		Movement = {
			Idle = anim({ Purpose = "Standing idle", Priority = "Idle", Looped = true, Length = 2, BodyParts = FULL_BODY, AnimateSlot = { "idle", "Animation1" } }),
			Walk = anim({ Purpose = "Walking", Priority = "Movement", Looped = true, Length = 1, BodyParts = FULL_BODY, AnimateSlot = { "walk", "WalkAnim" }, Markers = { Footstep = 0.25 } }),
			Run = anim({ Purpose = "Running", Priority = "Movement", Looped = true, Length = 0.8, BodyParts = FULL_BODY, AnimateSlot = { "run", "RunAnim" }, Markers = { Footstep = 0.2 } }),
			Jump = anim({ Purpose = "Jump start", Priority = "Movement", Length = 0.4, BodyParts = FULL_BODY, AnimateSlot = { "jump", "JumpAnim" } }),
			Fall = anim({ Purpose = "Falling", Priority = "Movement", Looped = true, Length = 1, BodyParts = FULL_BODY, AnimateSlot = { "fall", "FallAnim" } }),
			Climb = anim({ Purpose = "Climbing", Priority = "Movement", Looped = true, Length = 1, BodyParts = FULL_BODY, AnimateSlot = { "climb", "ClimbAnim" } }),
			Swim = anim({ Purpose = "Swimming", Priority = "Movement", Looped = true, Length = 1.2, BodyParts = FULL_BODY, AnimateSlot = { "swim", "Swim" } }),
			SwimIdle = anim({ Purpose = "Treading water", Priority = "Movement", Looped = true, Length = 2, BodyParts = FULL_BODY, AnimateSlot = { "swimidle", "SwimIdle" } }),
		},

		Tools = {
			ToolHoldIdle = anim({ Purpose = "Generic one-handed tool hold", Looped = true, Length = 2, Fallback = "Hold", Start = "Tool equipped", End = "Tool unequipped" }),
			AxeIdle = anim({ Purpose = "Holding an axe", Looped = true, Length = 2, Fallback = "Hold", Start = "Axe equipped", End = "Axe unequipped" }),
			AxeSwing = anim({
				Purpose = "Chop a tree",
				Length = 0.6,
				Markers = { Hit = 0.3 },
				MarkerEffects = { Hit = { Sound = "AxeSwing", Punch = 1 } },
				Trail = { 0.3, 0.62 },
				Fallback = "Swing",
				Start = "UseTool with axe equipped",
				End = "Animation finishes (cooldown = ToolConfig UseCooldown)",
			}),
			AxeHeavySwing = anim({ Purpose = "Final chop / heavy hit", Length = 0.9, Markers = { Hit = 0.5 }, MarkerEffects = { Hit = { Sound = "AxeSwing", Punch = 1.6 } }, Trail = { 0.36, 0.66 }, Fallback = "HeavySwing" }),
			PickaxeIdle = anim({ Purpose = "Holding a pickaxe", Looped = true, Length = 2, Fallback = "Hold" }),
			PickaxeSwing = anim({ Purpose = "Mine a rock", Length = 0.65, Markers = { Hit = 0.32 }, MarkerEffects = { Hit = { Sound = "PickaxeSwing", Punch = 1 } }, Trail = { 0.28, 0.6 }, Fallback = "Swing" }),
			PickaxeHeavySwing = anim({ Purpose = "Break a rock", Length = 0.95, Markers = { Hit = 0.52 }, MarkerEffects = { Hit = { Sound = "PickaxeSwing", Punch = 1.6 } }, Trail = { 0.3, 0.62 }, Fallback = "HeavySwing" }),
			ShovelDig = anim({ Purpose = "Dig clay/sand", Length = 0.8, Markers = { Dig = 0.45 }, MarkerEffects = { Dig = { Sound = "ShovelDig", VFX = "DirtPuff", Punch = 0.6 } }, Trail = { 0.28, 0.62 }, Fallback = "Dig", BodyParts = FULL_BODY }),
			ShovelDigHeavy = anim({ Purpose = "Dig treasure", Length = 1.1, Markers = { Dig = 0.6 }, MarkerEffects = { Dig = { Sound = "ShovelDig", VFX = "DirtPuff", Punch = 1 } }, Trail = { 0.3, 0.62 }, Fallback = "Dig", BodyParts = FULL_BODY }),
			HoeTill = anim({ Purpose = "Till soil", Length = 0.7, Markers = { Till = 0.38 }, MarkerEffects = { Till = { Sound = "HoeTill", VFX = "DirtPuff", Punch = 0.6 } }, Trail = { 0.32, 0.62 }, Fallback = "Till" }),
			HoeSwing = anim({ Purpose = "Alias swing for hoe", Length = 0.7, Markers = { Till = 0.38 }, Fallback = "Till" }),
			WaterStart = anim({ Purpose = "Raise watering can", Length = 0.3, Fallback = "Pour" }),
			WaterLoop = anim({ Purpose = "Pouring water", Looped = true, Length = 0.8, Markers = { Water = 0.4 }, MarkerEffects = { Water = { VFX = "WaterSplash" } }, Fallback = "Pour" }),
			WaterEnd = anim({ Purpose = "Lower watering can", Length = 0.3, Fallback = "Pour" }),
			BucketSwing = anim({ Purpose = "Swing the bucket", Length = 0.7, Markers = { Hit = 0.35 }, MarkerEffects = { Hit = { Sound = "ToolSwing" } }, Trail = { 0.3, 0.62 } }),
			ShearsSnip = anim({ Purpose = "Snip with the shears", Length = 0.6, Markers = { Snip = 0.3 }, MarkerEffects = { Snip = { Sound = "Shears", VFX = "Sparkle" } }, Trail = { 0.3, 0.6 } }),
		},

		Building = {
			BuildIdle = anim({ Purpose = "Holding hammer / build stance", Looped = true, Length = 2, Fallback = "Hold" }),
			-- Spec §74 reference timeline: 0.00 prepare, 0.16 raise, 0.31 HammerHit, 0.35 progress, 0.40 VFX, 0.65 end.
			HammerSwing = anim({
				Purpose = "Advance construction by one step",
				Length = 0.65,
				Markers = { HammerHit = 0.31 },
				MarkerEffects = { HammerHit = { Sound = "HammerHit", VFX = "BuildDust", Punch = 1 } },
				Trail = { 0.28, 0.6 },
				Fallback = "Swing",
				Start = "Player hammers a construction site",
				End = "Animation finishes; loop again if still building",
			}),
			HammerHeavy = anim({ Purpose = "Final hammer hit", Length = 0.9, Markers = { HammerHit = 0.5 }, MarkerEffects = { HammerHit = { Sound = "HammerHit", VFX = "BuildDust", Punch = 1.8 } }, Trail = { 0.34, 0.64 }, Fallback = "HeavySwing" }),
			CarryMaterials = anim({ Purpose = "Carrying planks/stone", Looped = true, Length = 1, Fallback = "Carry" }),
			PlaceWood = anim({ Purpose = "Place a wood piece", Length = 0.7, Markers = { WoodPlace = 0.4 }, MarkerEffects = { WoodPlace = { Sound = "WoodPlace", VFX = "BuildDust" } }, Fallback = "Reach" }),
			PlaceStone = anim({ Purpose = "Place a stone piece", Length = 0.8, Markers = { StonePlace = 0.45 }, MarkerEffects = { StonePlace = { Sound = "StonePlace", VFX = "BuildDust" } }, Fallback = "Reach" }),
			SawWood = anim({ Purpose = "Sawing", Looped = true, Length = 0.6, Markers = { Saw = 0.3 }, MarkerEffects = { Saw = { Sound = "Saw" } }, Fallback = "Dig" }),
			PlantConstruction = anim({ Purpose = "Plant the construction stake", Length = 0.8, Markers = { Effect = 0.45 }, MarkerEffects = { Effect = { Sound = "ConstructionStart", VFX = "BuildDust" } }, Fallback = "Dig" }),
			Paint = anim({ Purpose = "Paint a structure", Looped = true, Length = 0.8, Markers = { Paint = 0.4 }, MarkerEffects = { Paint = { Sound = "Paint" } }, Fallback = "Wave" }),
			BuildFinish = anim({ Purpose = "Last touch on a building", Priority = "Action2", Length = 1, Markers = { BuildFinish = 0.55 }, MarkerEffects = { BuildFinish = { Sound = "BuildComplete", VFX = "BuildComplete", Shake = 0.35 } }, Fallback = "HeavySwing" }),
			CelebrateBuild = anim({ Purpose = "Celebrate a finished build", Priority = "Action3", Length = 1.4, BodyParts = FULL_BODY, Fallback = "Cheer" }),
		},

		Farming = {
			TillGround = anim({ Purpose = "Till a soil tile", Length = 0.7, Markers = { Till = 0.38 }, MarkerEffects = { Till = { Sound = "HoeTill", VFX = "DirtPuff" } }, Fallback = "Till" }),
			PlantSeed = anim({ Purpose = "Plant a seed", Length = 0.9, Markers = { Plant = 0.5 }, MarkerEffects = { Plant = { Sound = "PlantSeed", VFX = "DirtPuff" } }, Fallback = "Reach", BodyParts = FULL_BODY }),
			WaterPlant = anim({ Purpose = "Water a crop", Length = 1.2, Markers = { Water = 0.5 }, MarkerEffects = { Water = { Sound = "Watering", VFX = "WaterSplash" } }, Trail = { 0.2, 0.8 }, Fallback = "Pour" }),
			HarvestCrop = anim({ Purpose = "Harvest a mature crop", Length = 0.8, Markers = { Pick = 0.42 }, MarkerEffects = { Pick = { Sound = "Harvest", VFX = "LeafBurst" } }, Fallback = "Reach", BodyParts = FULL_BODY }),
			PickCrop = anim({ Purpose = "Pick fruit from a plant", Length = 0.6, Markers = { Pick = 0.3 }, MarkerEffects = { Pick = { Sound = "Harvest", VFX = "LeafBurst" } }, Fallback = "Reach" }),
			CarryBasket = anim({ Purpose = "Carry a harvest basket", Looped = true, Length = 1, Fallback = "Carry" }),
			CelebrateHarvest = anim({ Purpose = "Big harvest celebration", Priority = "Action3", Length = 1.3, BodyParts = FULL_BODY, Fallback = "Cheer" }),
		},

		AnimalCare = {
			FeedAnimal = anim({ Purpose = "Feed an animal", Priority = "Action2", Length = 1, Markers = { Feed = 0.5 }, MarkerEffects = { Feed = { Sound = "Feed", VFX = "Hearts" } }, Fallback = "Reach" }),
			MilkCow = anim({ Purpose = "Milk a cow", Priority = "Action2", Length = 1.6, Markers = { Milk = 0.6 }, MarkerEffects = { Milk = { Sound = "Milk", VFX = "MilkSplash" } }, Fallback = "Dig", BodyParts = FULL_BODY, Interruptible = false }),
			PetAnimal = anim({ Purpose = "Pet an animal", Priority = "Action2", Length = 1.2, Markers = { Pet = 0.5 }, MarkerEffects = { Pet = { Sound = "Pet", VFX = "Hearts" } }, Fallback = "Wave" }),
			CarryBucket = anim({ Purpose = "Carry a bucket", Looped = true, Length = 1, Fallback = "Hold" }),
			FillTrough = anim({ Purpose = "Fill a feeding trough", Priority = "Action2", Length = 1.2, Markers = { Pour = 0.6 }, MarkerEffects = { Pour = { Sound = "Watering" } }, Fallback = "Pour" }),
		},

		Fishing = {
			FishingIdle = anim({ Purpose = "Holding the rod", Priority = "Action", Looped = true, Length = 2, Fallback = "Hold" }),
			FishingCast = anim({ Purpose = "Cast the line", Priority = "Action2", Length = 0.9, Markers = { Cast = 0.45 }, MarkerEffects = { Cast = { Sound = "FishingCast", Punch = 0.5 } }, Trail = { 0.28, 0.6 }, Fallback = "Cast" }),
			FishingWait = anim({ Purpose = "Waiting for a bite", Priority = "Action2", Looped = true, Length = 3, Fallback = "Hold" }),
			FishingBite = anim({ Purpose = "Rod jerks on a bite", Priority = "Action2", Length = 0.4, Markers = { Splash = 0.1 }, MarkerEffects = { Splash = { Sound = "FishBite", VFX = "WaterSplash" } }, Fallback = "Reel" }),
			FishingReel = anim({ Purpose = "Reeling in", Priority = "Action2", Looped = true, Length = 0.6, Markers = { Reel = 0.3 }, MarkerEffects = { Reel = { Sound = "Reel" } }, Fallback = "Reel" }),
			FishingStruggle = anim({ Purpose = "Fighting a strong fish", Priority = "Action2", Looped = true, Length = 0.8, Fallback = "Reel" }),
			FishingCatch = anim({ Purpose = "Pull the fish out", Priority = "Action2", Length = 1, Markers = { Catch = 0.5 }, MarkerEffects = { Catch = { Sound = "FishCatch", VFX = "WaterSplash" } }, Fallback = "HeavySwing" }),
			FishingFail = anim({ Purpose = "Fish escapes", Priority = "Action2", Length = 0.8, Fallback = "Reach" }),
			FishingCelebrate = anim({ Purpose = "Rare catch celebration", Priority = "Action3", Length = 1.5, BodyParts = FULL_BODY, Fallback = "Cheer" }),
		},

		Crafting = {
			CraftStart = anim({ Purpose = "Begin crafting", Length = 0.5, Fallback = "Reach" }),
			CraftWork = anim({ Purpose = "Crafting loop", Looped = true, Length = 0.7, Markers = { CraftHit = 0.35 }, MarkerEffects = { CraftHit = { Sound = "CraftHit" } }, Fallback = "Swing" }),
			CraftFinish = anim({ Purpose = "Crafting done", Priority = "Action2", Length = 0.8, Markers = { Effect = 0.4 }, MarkerEffects = { Effect = { Sound = "CraftComplete", VFX = "Sparkle" } }, Fallback = "Cheer" }),
		},

		Social = {
			Wave = anim({ Purpose = "Wave", Priority = "Action3", Length = 1.5, Fallback = "Wave" }),
			Cheer = anim({ Purpose = "Cheer", Priority = "Action3", Length = 1.3, BodyParts = FULL_BODY, Fallback = "Cheer" }),
			Celebrate = anim({ Purpose = "Level up / unlock celebration", Priority = "Action3", Length = 1.6, BodyParts = FULL_BODY, Fallback = "Cheer" }),
			Sit = anim({ Purpose = "Sit on benches", Priority = "Action3", Looped = true, Length = 2, BodyParts = FULL_BODY }),
			Point = anim({ Purpose = "Point at something", Priority = "Action3", Length = 1.2, Fallback = "Point" }),
			Dance = anim({ Purpose = "Happy island dance (emote)", Priority = "Action3", Length = 0.9, Repeat = 4, BodyParts = FULL_BODY }),
			OpenChest = anim({ Purpose = "Lift a chest lid", Priority = "Action2", Length = 1.1, Markers = { Open = 0.75 }, MarkerEffects = { Open = { Sound = "ChestOpen" } }, BodyParts = FULL_BODY }),
		},

		-- Mia the Merchant (NPC rig, keyframed like players).
		Merchant = {
			MiaIdle = anim({ Purpose = "Mia waiting behind her counter", Priority = "Idle", Looped = true, Length = 5, BodyParts = FULL_BODY }),
			MiaWave = anim({ Purpose = "Mia greets a player who walks up", Priority = "Action3", Length = 1.6, BodyParts = FULL_BODY }),
			MiaPresent = anim({ Purpose = "Mia shows off her goods (market opened)", Priority = "Action2", Length = 1.4, Markers = { Present = 0.7 }, MarkerEffects = { Present = { VFX = "Sparkle" } } }),
			MiaSold = anim({ Purpose = "Mia claps and hops after a sale", Priority = "Action3", Length = 1.5, BodyParts = FULL_BODY, Markers = { Clap = 0.27, Hop = 1.17 }, MarkerEffects = { Clap = { Sound = "CoinGain" }, Hop = { VFX = "CoinBurst" } } }),
			MiaTalk = anim({ Purpose = "Mia chats while giving a tip", Priority = "Action2", Length = 2 }),
		},

		-- Non-humanoid rigs (AnimationController). Used from Phase 6.
		Cow = {
			CowIdle = anim({ Purpose = "Cow idle", Priority = "Idle", Looped = true, Length = 3, BodyParts = "Cow rig" }),
			CowWalk = anim({ Purpose = "Cow walk", Priority = "Movement", Looped = true, Length = 1.2, BodyParts = "Cow rig" }),
			CowEat = anim({ Purpose = "Cow eating", Looped = true, Length = 2, BodyParts = "Cow rig", Markers = { Chew = 1 } }),
			CowDrink = anim({ Purpose = "Cow drinking", Looped = true, Length = 2, BodyParts = "Cow rig" }),
			CowHappy = anim({ Purpose = "Cow happy hop", Priority = "Action2", Length = 1.2, BodyParts = "Cow rig" }),
			CowSleep = anim({ Purpose = "Cow sleeping", Priority = "Idle", Looped = true, Length = 4, BodyParts = "Cow rig" }),
			CowMilk = anim({ Purpose = "Cow being milked", Priority = "Action2", Length = 1.6, BodyParts = "Cow rig" }),
			CowHitReaction = anim({ Purpose = "Cow startled", Priority = "Action2", Length = 0.6, BodyParts = "Cow rig" }),
			CowInteract = anim({ Purpose = "Cow looks at player", Priority = "Action", Length = 1.2, BodyParts = "Cow rig" }),
		},
	},

	-- Every tool has THREE swings; a swing plays one of them at random.
	-- The first name is the "base" that configs and services refer to.
	Variants = {
		AxeSwing = { "AxeSwing", "AxeChopHigh", "AxeSlash" },
		PickaxeSwing = { "PickaxeSwing", "PickaxeSide", "PickaxeSlam" },
		HammerSwing = { "HammerSwing", "HammerBash", "HammerSlam" },
		HoeTill = { "HoeTill", "HoeChop", "HoeScrape" },
		ShovelDig = { "ShovelDig", "ShovelScoop", "ShovelStomp" },
		WaterPlant = { "WaterPlant", "WaterSweep", "WaterHigh" },
		FishingCast = { "FishingCast", "FishingCastSide", "FishingCastFlick" },
		BucketSwing = { "BucketSwing", "BucketScoop", "BucketToss" },
		ShearsSnip = { "ShearsSnip", "ShearsSnipLow", "ShearsSnipHigh" },
	} :: { [string]: { string } },

	-- Built below: flat lookup { [AnimationName] = def } (names must be unique).
	Index = {} :: { [string]: any },
}

-- Variants share the base's timing (Length, markers, effects, trail) so
-- gameplay is identical whichever one plays; only the keyframes differ.
for baseName, names in AnimationConfig.Variants do
	for _, entries in AnimationConfig.Categories do
		local base = entries[baseName]
		if base then
			for index = 2, #names do
				local copy = TableUtil.DeepCopy(base)
				copy.Purpose = base.Purpose .. " (variant " .. index .. ")"
				copy.VariantOf = baseName
				entries[names[index]] = copy
			end
		end
	end
end

for categoryName, entries in AnimationConfig.Categories do
	for name, def in entries do
		assert(AnimationConfig.Index[name] == nil, "Duplicate animation name: " .. name)
		def.Name = name
		def.Category = categoryName
		AnimationConfig.Index[name] = def
	end
end

function AnimationConfig.Get(name: string)
	return AnimationConfig.Index[name]
end

-- How many swings `name` has (1 if it has no variants).
function AnimationConfig.VariantCount(name: string): number
	local names = AnimationConfig.Variants[name]
	return if names then #names else 1
end

-- The index-th variant of `name` (index is clamped; unknown -> name).
function AnimationConfig.Variant(name: string, index: number): string
	local names = AnimationConfig.Variants[name]
	if not names then
		return name
	end
	return names[math.clamp(math.floor(index), 1, #names)]
end

return TableUtil.DeepFreeze(AnimationConfig)
