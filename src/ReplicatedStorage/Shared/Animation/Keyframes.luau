--!strict
--[[
	SCRIPT NAME:  Keyframes
	SCRIPT TYPE:  ModuleScript (shared animation data)
	WHERE:        ReplicatedStorage/Shared/Animation/Keyframes
	DEPENDENCIES: none

	Real R15 keyframe animations, authored in code so the game is fully
	animated without uploading anything. Every client plays them on every
	character (Client/Controllers/AnimationController) by writing the R15
	Motor6D.Transform values each frame, so all players see the same swing.

	FORMAT
		Actions[name] = { Keys = { { T = 0..1, Pose = { Joint = { X, Y, Z [, PX, PY, PZ] } }, Ease = "Out"? }, ... },
		                  Legs = true? }  -- true = the action also drives the legs (crouch, jump)
		Holds[name]   = { Pose = { ... }, Sway = number? }   -- looping upper-body hold poses

	T is a FRACTION of the animation's Length (AnimationConfig), so the
	impact keyframe sits exactly on the gameplay marker (e.g. AxeSwing Hit at
	0.30 of 0.60 s = T 0.5).

	ANGLES are degrees, in each joint's own frame (R15 joints are aligned
	with the body):
		Shoulder / Elbow / Wrist  X+ = forward / up        Z = out to the side
		                          (right arm: Z+ out, left arm: Z- out)
		Waist / Neck              X- = lean / look down     Y+ = turn left
		Hip  X+ = leg forward     Knee X- = bend            Ankle X+ = toes up
		Root (LowerTorso)         rotation + PX/PY/PZ offset in studs (PY- = crouch)
	A held tool points FORWARD from a hanging hand; every 90° of arm flex
	tips it 90° further up (so arm forward + elbow bent = tool upright).
]]

export type JointPose = { number }
export type Key = { T: number, Pose: { [string]: JointPose }, Ease: string? }
export type Action = { Keys: { Key }, Legs: boolean? }
export type Hold = { Pose: { [string]: JointPose }, Sway: number? }

local Keyframes = {}

Keyframes.ArmJoints = { "RightShoulder", "RightElbow", "RightWrist", "LeftShoulder", "LeftElbow", "LeftWrist" }
Keyframes.UpperJoints = { "Waist", "Neck", "RightShoulder", "RightElbow", "RightWrist", "LeftShoulder", "LeftElbow", "LeftWrist" }
Keyframes.LegJoints = { "Root", "RightHip", "RightKnee", "RightAnkle", "LeftHip", "LeftKnee", "LeftAnkle" }

-- Crouch used by planting / harvesting / milking.
local CROUCH = {
	Root = { 0, 0, 0, 0, -1.25, 0 },
	RightHip = { 78, 0, 4 },
	RightKnee = { -112, 0, 0 },
	RightAnkle = { 34, 0, 0 },
	LeftHip = { 70, 0, -4 },
	LeftKnee = { -108, 0, 0 },
	LeftAnkle = { 38, 0, 0 },
}

local STAND = {
	Root = { 0, 0, 0, 0, 0, 0 },
	RightHip = { 0, 0, 0 },
	RightKnee = { 0, 0, 0 },
	RightAnkle = { 0, 0, 0 },
	LeftHip = { 0, 0, 0 },
	LeftKnee = { 0, 0, 0 },
	LeftAnkle = { 0, 0, 0 },
}

local function merge(...: { [string]: JointPose }): { [string]: JointPose }
	local result = {}
	for _, pose in { ... } do
		for joint, value in pose do
			result[joint] = value
		end
	end
	return result
end

---------------------------------------------------------------------------
-- Hold poses (upper body; legs stay on Roblox's walk/idle animation)
---------------------------------------------------------------------------

Keyframes.Holds = {
	-- Axe / pickaxe / hammer upright in the right hand, relaxed.
	HoldAxe = { Pose = { RightShoulder = { 16, 0, 6 }, RightElbow = { 78, 0, 0 }, RightWrist = { -8, 0, 0 } }, Sway = 2 },
	HoldPickaxe = { Pose = { RightShoulder = { 18, 0, 6 }, RightElbow = { 74, 0, 0 }, RightWrist = { -10, 0, 0 } }, Sway = 2 },
	HoldHammer = { Pose = { RightShoulder = { 14, 0, 6 }, RightElbow = { 70, 0, 0 }, RightWrist = { -4, 0, 0 } }, Sway = 2 },
	HoldTool = { Pose = { RightShoulder = { 12, 0, 6 }, RightElbow = { 55, 0, 0 } }, Sway = 2 },
	-- Hoe / shovel held across the body with both hands.
	HoldHoe = { Pose = { RightShoulder = { 22, 0, 4 }, RightElbow = { 60, 0, 0 }, LeftShoulder = { 30, 0, 18 }, LeftElbow = { 50, 0, 0 } }, Sway = 2 },
	HoldShovel = { Pose = { RightShoulder = { 20, 0, 4 }, RightElbow = { 62, 0, 0 }, LeftShoulder = { 28, 0, 18 }, LeftElbow = { 48, 0, 0 } }, Sway = 2 },
	-- Watering can out in front, ready to pour.
	HoldCan = { Pose = { RightShoulder = { 34, 0, 4 }, RightElbow = { 30, 0, 0 }, RightWrist = { -20, 0, 0 } }, Sway = 2 },
	-- Fishing rod pointing forward and up.
	HoldRod = { Pose = { RightShoulder = { 30, 0, 4 }, RightElbow = { 18, 0, 0 }, LeftShoulder = { 26, 0, 14 }, LeftElbow = { 40, 0, 0 } }, Sway = 1.5 },
	-- Bucket hanging from the hand.
	HoldBucket = { Pose = { RightShoulder = { 8, 0, 8 }, RightElbow = { 12, 0, 0 }, RightWrist = { -80, 0, 0 } }, Sway = 3 },
	-- Seed sack / food held in front of the chest.
	HoldItem = { Pose = { RightShoulder = { 38, 0, -4 }, RightElbow = { 62, 0, 0 }, RightWrist = { -60, 0, 0 } }, Sway = 2 },
}

---------------------------------------------------------------------------
-- Actions
---------------------------------------------------------------------------

local A: { [string]: Action } = {}

-- Diagonal wood chop. Impact at T = 0.5 (AxeSwing Hit 0.30 / 0.60).
A.AxeSwing = {
	Keys = {
		{ T = 0, Pose = { Waist = { 0, 0, 0 }, RightShoulder = { 16, 0, 6 }, RightElbow = { 78, 0, 0 }, RightWrist = { -8, 0, 0 }, LeftShoulder = { 0, 0, 0 } } },
		{ T = 0.32, Ease = "Out", Pose = { Waist = { 6, -24, 0 }, Neck = { 0, 10, 0 }, RightShoulder = { 150, 0, 24 }, RightElbow = { 72, 0, 0 }, RightWrist = { 0, 0, 0 }, LeftShoulder = { 40, 0, -10 }, LeftElbow = { 40, 0, 0 } } },
		{ T = 0.5, Ease = "In", Pose = { Waist = { -14, 22, 0 }, Neck = { -6, -8, 0 }, RightShoulder = { 62, 0, -10 }, RightElbow = { 8, 0, 0 }, RightWrist = { -70, 0, 0 }, LeftShoulder = { 20, 0, 10 }, LeftElbow = { 30, 0, 0 } } },
		{ T = 0.66, Ease = "Out", Pose = { Waist = { -12, 26, 0 }, Neck = { -6, -8, 0 }, RightShoulder = { 48, 0, -14 }, RightElbow = { 10, 0, 0 }, RightWrist = { -60, 0, 0 }, LeftShoulder = { 14, 0, 8 }, LeftElbow = { 24, 0, 0 } } },
		{ T = 1, Pose = { Waist = { 0, 0, 0 }, Neck = { 0, 0, 0 }, RightShoulder = { 16, 0, 6 }, RightElbow = { 78, 0, 0 }, RightWrist = { -8, 0, 0 }, LeftShoulder = { 0, 0, 0 }, LeftElbow = { 0, 0, 0 } } },
	},
}

-- Big two-handed overhead chop (final hit). Impact at T = 0.56.
A.AxeHeavySwing = {
	Keys = {
		{ T = 0, Pose = { Waist = { 0, 0, 0 }, RightShoulder = { 16, 0, 6 }, RightElbow = { 78, 0, 0 }, LeftShoulder = { 0, 0, 0 } } },
		{ T = 0.38, Ease = "Out", Pose = { Waist = { 12, -10, 0 }, Neck = { 8, 0, 0 }, RightShoulder = { 170, 0, 14 }, RightElbow = { 70, 0, 0 }, LeftShoulder = { 160, 0, -14 }, LeftElbow = { 70, 0, 0 } } },
		{ T = 0.56, Ease = "In", Pose = { Waist = { -24, 10, 0 }, Neck = { -10, 0, 0 }, RightShoulder = { 56, 0, -6 }, RightElbow = { 6, 0, 0 }, RightWrist = { -72, 0, 0 }, LeftShoulder = { 50, 0, 8 }, LeftElbow = { 10, 0, 0 } } },
		{ T = 0.75, Pose = { Waist = { -18, 8, 0 }, RightShoulder = { 40, 0, -6 }, RightElbow = { 10, 0, 0 }, RightWrist = { -60, 0, 0 }, LeftShoulder = { 36, 0, 8 }, LeftElbow = { 14, 0, 0 } } },
		{ T = 1, Pose = { Waist = { 0, 0, 0 }, Neck = { 0, 0, 0 }, RightShoulder = { 16, 0, 6 }, RightElbow = { 78, 0, 0 }, RightWrist = { 0, 0, 0 }, LeftShoulder = { 0, 0, 0 }, LeftElbow = { 0, 0, 0 } } },
	},
}

-- Overhead downward mining strike. Impact at T = 0.49.
A.PickaxeSwing = {
	Keys = {
		{ T = 0, Pose = { Waist = { 0, 0, 0 }, RightShoulder = { 18, 0, 6 }, RightElbow = { 74, 0, 0 }, LeftShoulder = { 0, 0, 0 } } },
		{ T = 0.3, Ease = "Out", Pose = { Waist = { 10, -8, 0 }, Neck = { 6, 0, 0 }, RightShoulder = { 168, 0, 12 }, RightElbow = { 40, 0, 0 }, LeftShoulder = { 120, 0, -10 }, LeftElbow = { 50, 0, 0 } } },
		{ T = 0.49, Ease = "In", Pose = { Waist = { -26, 6, 0 }, Neck = { -14, 0, 0 }, RightShoulder = { 60, 0, -4 }, RightElbow = { 10, 0, 0 }, RightWrist = { -100, 0, 0 }, LeftShoulder = { 54, 0, 10 }, LeftElbow = { 12, 0, 0 } } },
		{ T = 0.62, Pose = { Waist = { -22, 6, 0 }, RightShoulder = { 58, 0, -4 }, RightElbow = { 14, 0, 0 }, RightWrist = { -90, 0, 0 }, LeftShoulder = { 48, 0, 10 }, LeftElbow = { 16, 0, 0 } } },
		{ T = 1, Pose = { Waist = { 0, 0, 0 }, Neck = { 0, 0, 0 }, RightShoulder = { 18, 0, 6 }, RightElbow = { 74, 0, 0 }, RightWrist = { 0, 0, 0 }, LeftShoulder = { 0, 0, 0 }, LeftElbow = { 0, 0, 0 } } },
	},
}

A.PickaxeHeavySwing = A.PickaxeSwing

-- Quick hammer strike on a construction site. Impact at T = 0.48.
A.HammerSwing = {
	Keys = {
		{ T = 0, Pose = { Waist = { 0, 0, 0 }, RightShoulder = { 14, 0, 6 }, RightElbow = { 70, 0, 0 } } },
		{ T = 0.25, Ease = "Out", Pose = { Waist = { 4, -10, 0 }, RightShoulder = { 146, 0, 16 }, RightElbow = { 82, 0, 0 }, RightWrist = { 10, 0, 0 }, LeftShoulder = { 30, 0, -6 }, LeftElbow = { 30, 0, 0 } } },
		{ T = 0.48, Ease = "In", Pose = { Waist = { -16, 8, 0 }, Neck = { -10, 0, 0 }, RightShoulder = { 58, 0, -2 }, RightElbow = { 16, 0, 0 }, RightWrist = { -84, 0, 0 }, LeftShoulder = { 34, 0, 6 }, LeftElbow = { 40, 0, 0 } } },
		{ T = 0.62, Pose = { Waist = { -12, 6, 0 }, RightShoulder = { 64, 0, -2 }, RightElbow = { 24, 0, 0 }, RightWrist = { -70, 0, 0 } } },
		{ T = 1, Pose = { Waist = { 0, 0, 0 }, Neck = { 0, 0, 0 }, RightShoulder = { 14, 0, 6 }, RightElbow = { 70, 0, 0 }, RightWrist = { 0, 0, 0 }, LeftShoulder = { 0, 0, 0 }, LeftElbow = { 0, 0, 0 } } },
	},
}

-- Final hammer blow: bigger windup, little hop. Impact at T = 0.56.
A.HammerHeavy = {
	Legs = true,
	Keys = {
		{ T = 0, Pose = merge(STAND, { Waist = { 0, 0, 0 }, RightShoulder = { 14, 0, 6 }, RightElbow = { 70, 0, 0 } }) },
		{ T = 0.36, Ease = "Out", Pose = merge(STAND, { Root = { 0, 0, 0, 0, 0.35, 0 }, Waist = { 14, -14, 0 }, RightShoulder = { 172, 0, 16 }, RightElbow = { 80, 0, 0 }, LeftShoulder = { 60, 0, -10 }, LeftElbow = { 40, 0, 0 } }) },
		{ T = 0.56, Ease = "In", Pose = merge(STAND, { Root = { 0, 0, 0, 0, -0.35, 0 }, RightHip = { 16, 0, 0 }, RightKnee = { -24, 0, 0 }, LeftHip = { 16, 0, 0 }, LeftKnee = { -24, 0, 0 }, Waist = { -26, 10, 0 }, Neck = { -12, 0, 0 }, RightShoulder = { 56, 0, -2 }, RightElbow = { 12, 0, 0 }, RightWrist = { -86, 0, 0 }, LeftShoulder = { 30, 0, 10 }, LeftElbow = { 40, 0, 0 } }) },
		{ T = 1, Pose = merge(STAND, { Waist = { 0, 0, 0 }, Neck = { 0, 0, 0 }, RightShoulder = { 14, 0, 6 }, RightElbow = { 70, 0, 0 }, RightWrist = { 0, 0, 0 }, LeftShoulder = { 0, 0, 0 }, LeftElbow = { 0, 0, 0 } }) },
	},
}

-- Two-handed hoe strike into the soil. Impact at T = 0.54.
A.HoeTill = {
	Keys = {
		{ T = 0, Pose = { Waist = { 0, 0, 0 }, RightShoulder = { 22, 0, 4 }, RightElbow = { 60, 0, 0 }, LeftShoulder = { 30, 0, 18 }, LeftElbow = { 50, 0, 0 } } },
		{ T = 0.34, Ease = "Out", Pose = { Waist = { 12, 0, 0 }, Neck = { 4, 0, 0 }, RightShoulder = { 150, 0, 8 }, RightElbow = { 50, 0, 0 }, LeftShoulder = { 140, 0, -4 }, LeftElbow = { 50, 0, 0 } } },
		{ T = 0.54, Ease = "In", Pose = { Waist = { -30, 0, 0 }, Neck = { -18, 0, 0 }, RightShoulder = { 52, 0, 0 }, RightElbow = { 0, 0, 0 }, RightWrist = { -96, 0, 0 }, LeftShoulder = { 48, 0, 6 }, LeftElbow = { 6, 0, 0 } } },
		{ T = 0.7, Pose = { Waist = { -26, 0, 0 }, Neck = { -14, 0, 0 }, RightShoulder = { 40, 0, 0 }, RightElbow = { 10, 0, 0 }, RightWrist = { -80, 0, 0 }, LeftShoulder = { 38, 0, 6 }, LeftElbow = { 14, 0, 0 } } },
		{ T = 1, Pose = { Waist = { 0, 0, 0 }, Neck = { 0, 0, 0 }, RightShoulder = { 22, 0, 4 }, RightElbow = { 60, 0, 0 }, RightWrist = { 0, 0, 0 }, LeftShoulder = { 30, 0, 18 }, LeftElbow = { 50, 0, 0 } } },
	},
}
A.HoeSwing = A.HoeTill
A.TillGround = A.HoeTill

-- Shovel: stab, lean on it, lift the dirt. Impact at T = 0.56.
A.ShovelDig = {
	Legs = true,
	Keys = {
		{ T = 0, Pose = merge(STAND, { Waist = { 0, 0, 0 }, RightShoulder = { 20, 0, 4 }, RightElbow = { 62, 0, 0 }, LeftShoulder = { 28, 0, 18 }, LeftElbow = { 48, 0, 0 } }) },
		{ T = 0.3, Ease = "Out", Pose = merge(STAND, { Waist = { 6, 0, 0 }, RightShoulder = { 60, 0, 4 }, RightElbow = { 30, 0, 0 }, RightWrist = { -60, 0, 0 }, LeftShoulder = { 70, 0, 10 }, LeftElbow = { 30, 0, 0 } }) },
		{ T = 0.56, Ease = "In", Pose = merge(STAND, { Root = { 0, 0, 0, 0, -0.5, 0 }, RightHip = { 30, 0, 0 }, RightKnee = { -44, 0, 0 }, LeftHip = { 20, 0, 0 }, LeftKnee = { -30, 0, 0 }, Waist = { -30, 0, 0 }, Neck = { -18, 0, 0 }, RightShoulder = { 30, 0, 0 }, RightElbow = { 10, 0, 0 }, RightWrist = { -110, 0, 0 }, LeftShoulder = { 40, 0, 10 }, LeftElbow = { 20, 0, 0 } }) },
		{ T = 0.8, Ease = "Out", Pose = merge(STAND, { Waist = { -4, -20, 0 }, RightShoulder = { 70, 0, 10 }, RightElbow = { 50, 0, 0 }, RightWrist = { -40, 0, 0 }, LeftShoulder = { 60, 0, 10 }, LeftElbow = { 40, 0, 0 } }) },
		{ T = 1, Pose = merge(STAND, { Waist = { 0, 0, 0 }, Neck = { 0, 0, 0 }, RightShoulder = { 20, 0, 4 }, RightElbow = { 62, 0, 0 }, RightWrist = { 0, 0, 0 }, LeftShoulder = { 28, 0, 18 }, LeftElbow = { 48, 0, 0 } }) },
	},
}
A.ShovelDigHeavy = A.ShovelDig

-- Crouch, press a seed into the soil, stand. Plant marker at T = 0.56.
A.PlantSeed = {
	Legs = true,
	Keys = {
		{ T = 0, Pose = merge(STAND, { Waist = { 0, 0, 0 }, Neck = { 0, 0, 0 }, RightShoulder = { 38, 0, -4 }, RightElbow = { 62, 0, 0 } }) },
		{ T = 0.32, Ease = "Out", Pose = merge(CROUCH, { Waist = { -28, 0, 0 }, Neck = { -20, 0, 0 }, RightShoulder = { 50, 0, 0 }, RightElbow = { 20, 0, 0 }, LeftShoulder = { 10, 0, -10 } }) },
		{ T = 0.56, Ease = "InOut", Pose = merge(CROUCH, { Waist = { -34, 0, 0 }, Neck = { -24, 0, 0 }, RightShoulder = { 34, 0, 6 }, RightElbow = { 6, 0, 0 }, RightWrist = { -30, 0, 0 }, LeftShoulder = { 14, 0, -10 } }) },
		{ T = 0.72, Pose = merge(CROUCH, { Waist = { -30, 0, 0 }, Neck = { -20, 0, 0 }, RightShoulder = { 40, 0, 6 }, RightElbow = { 14, 0, 0 }, RightWrist = { 10, 0, 0 } }) },
		{ T = 1, Pose = merge(STAND, { Waist = { 0, 0, 0 }, Neck = { 0, 0, 0 }, RightShoulder = { 38, 0, -4 }, RightElbow = { 62, 0, 0 }, RightWrist = { 0, 0, 0 }, LeftShoulder = { 0, 0, 0 } }) },
	},
}

-- Tilt the can and sprinkle. Water marker at T = 0.42.
A.WaterPlant = {
	Keys = {
		{ T = 0, Pose = { Waist = { 0, 0, 0 }, Neck = { 0, 0, 0 }, RightShoulder = { 34, 0, 4 }, RightElbow = { 30, 0, 0 }, RightWrist = { -20, 0, 0 } } },
		{ T = 0.25, Ease = "Out", Pose = { Waist = { -10, 0, 0 }, Neck = { -16, 0, 0 }, RightShoulder = { 60, 0, 4 }, RightElbow = { 14, 0, 0 }, RightWrist = { -30, 0, 0 } } },
		{ T = 0.42, Pose = { Waist = { -12, 0, 0 }, Neck = { -20, 0, 0 }, RightShoulder = { 62, 0, 4 }, RightElbow = { 10, 0, 0 }, RightWrist = { -80, 0, 0 } } },
		{ T = 0.58, Pose = { Waist = { -12, 6, 0 }, Neck = { -20, 4, 0 }, RightShoulder = { 60, 0, 0 }, RightElbow = { 10, 0, 0 }, RightWrist = { -84, 0, 0 } } },
		{ T = 0.74, Pose = { Waist = { -12, -6, 0 }, Neck = { -20, -4, 0 }, RightShoulder = { 60, 0, 8 }, RightElbow = { 10, 0, 0 }, RightWrist = { -84, 0, 0 } } },
		{ T = 1, Pose = { Waist = { 0, 0, 0 }, Neck = { 0, 0, 0 }, RightShoulder = { 34, 0, 4 }, RightElbow = { 30, 0, 0 }, RightWrist = { -20, 0, 0 } } },
	},
}
A.WaterStart = A.WaterPlant
A.WaterLoop = A.WaterPlant
A.WaterEnd = A.WaterPlant

-- Crouch, grab with both hands, pull up. Pick marker at T = 0.53.
A.HarvestCrop = {
	Legs = true,
	Keys = {
		{ T = 0, Pose = merge(STAND, { Waist = { 0, 0, 0 }, RightShoulder = { 0, 0, 0 }, LeftShoulder = { 0, 0, 0 } }) },
		{ T = 0.3, Ease = "Out", Pose = merge(CROUCH, { Waist = { -30, 0, 0 }, Neck = { -20, 0, 0 }, RightShoulder = { 46, 0, -8 }, RightElbow = { 10, 0, 0 }, LeftShoulder = { 46, 0, 8 }, LeftElbow = { 10, 0, 0 } }) },
		{ T = 0.53, Ease = "In", Pose = merge(CROUCH, { Root = { 0, 0, 0, 0, -0.9, 0 }, Waist = { -10, 0, 0 }, Neck = { 0, 0, 0 }, RightShoulder = { 70, 0, -8 }, RightElbow = { 60, 0, 0 }, LeftShoulder = { 70, 0, 8 }, LeftElbow = { 60, 0, 0 } }) },
		{ T = 0.75, Ease = "Out", Pose = merge(STAND, { Waist = { 6, 0, 0 }, Neck = { 6, 0, 0 }, RightShoulder = { 100, 0, -6 }, RightElbow = { 40, 0, 0 }, LeftShoulder = { 100, 0, 6 }, LeftElbow = { 40, 0, 0 } }) },
		{ T = 1, Pose = merge(STAND, { Waist = { 0, 0, 0 }, Neck = { 0, 0, 0 }, RightShoulder = { 0, 0, 0 }, RightElbow = { 0, 0, 0 }, LeftShoulder = { 0, 0, 0 }, LeftElbow = { 0, 0, 0 } }) },
	},
}

-- Quick pick by hand (bushes, sand, eggs). Pick marker at T = 0.5.
A.PickCrop = {
	Keys = {
		{ T = 0, Pose = { Waist = { 0, 0, 0 }, RightShoulder = { 0, 0, 0 }, RightElbow = { 0, 0, 0 } } },
		{ T = 0.3, Ease = "Out", Pose = { Waist = { -26, 8, 0 }, Neck = { -16, 0, 0 }, RightShoulder = { 60, 0, -6 }, RightElbow = { 10, 0, 0 }, RightWrist = { 10, 0, 0 } } },
		{ T = 0.5, Pose = { Waist = { -24, 8, 0 }, Neck = { -14, 0, 0 }, RightShoulder = { 58, 0, -6 }, RightElbow = { 40, 0, 0 }, RightWrist = { 30, 0, 0 } } },
		{ T = 0.75, Ease = "Out", Pose = { Waist = { -4, 0, 0 }, Neck = { 0, 0, 0 }, RightShoulder = { 40, 0, -10 }, RightElbow = { 90, 0, 0 } } },
		{ T = 1, Pose = { Waist = { 0, 0, 0 }, Neck = { 0, 0, 0 }, RightShoulder = { 0, 0, 0 }, RightElbow = { 0, 0, 0 }, RightWrist = { 0, 0, 0 } } },
	},
}

-- Hold food out, animal eats. Feed marker at T = 0.5.
A.FeedAnimal = {
	Keys = {
		{ T = 0, Pose = { Waist = { 0, 0, 0 }, RightShoulder = { 38, 0, -4 }, RightElbow = { 62, 0, 0 } } },
		{ T = 0.35, Ease = "Out", Pose = { Waist = { -20, 0, 0 }, Neck = { -10, 0, 0 }, RightShoulder = { 78, 0, 0 }, RightElbow = { 10, 0, 0 }, RightWrist = { -40, 0, 0 } } },
		{ T = 0.5, Pose = { Waist = { -22, 0, 0 }, Neck = { -12, 0, 0 }, RightShoulder = { 72, 0, 0 }, RightElbow = { 14, 0, 0 }, RightWrist = { -30, 0, 0 } } },
		{ T = 0.7, Pose = { Waist = { -22, 0, 0 }, Neck = { -8, 0, 0 }, RightShoulder = { 76, 0, 0 }, RightElbow = { 10, 0, 0 }, RightWrist = { -40, 0, 0 } } },
		{ T = 1, Pose = { Waist = { 0, 0, 0 }, Neck = { 0, 0, 0 }, RightShoulder = { 38, 0, -4 }, RightElbow = { 62, 0, 0 }, RightWrist = { 0, 0, 0 } } },
	},
}

-- Squat by the cow, alternate hands. Milk marker at T = 0.38.
A.MilkCow = {
	Legs = true,
	Keys = {
		{ T = 0, Pose = merge(STAND, { Waist = { 0, 0, 0 }, RightShoulder = { 8, 0, 8 }, LeftShoulder = { 0, 0, 0 } }) },
		{ T = 0.2, Ease = "Out", Pose = merge(CROUCH, { Waist = { -24, 0, 0 }, Neck = { -10, 0, 0 }, RightShoulder = { 56, 0, -6 }, RightElbow = { 30, 0, 0 }, LeftShoulder = { 56, 0, 6 }, LeftElbow = { 30, 0, 0 } }) },
		{ T = 0.38, Pose = merge(CROUCH, { Waist = { -24, 0, 0 }, Neck = { -10, 0, 0 }, RightShoulder = { 44, 0, -6 }, RightElbow = { 40, 0, 0 }, LeftShoulder = { 60, 0, 6 }, LeftElbow = { 24, 0, 0 } }) },
		{ T = 0.52, Pose = merge(CROUCH, { Waist = { -24, 0, 0 }, Neck = { -10, 0, 0 }, RightShoulder = { 60, 0, -6 }, RightElbow = { 24, 0, 0 }, LeftShoulder = { 44, 0, 6 }, LeftElbow = { 40, 0, 0 } }) },
		{ T = 0.66, Pose = merge(CROUCH, { Waist = { -24, 0, 0 }, Neck = { -10, 0, 0 }, RightShoulder = { 44, 0, -6 }, RightElbow = { 40, 0, 0 }, LeftShoulder = { 60, 0, 6 }, LeftElbow = { 24, 0, 0 } }) },
		{ T = 0.8, Ease = "Out", Pose = merge(CROUCH, { Waist = { -20, 0, 0 }, Neck = { -6, 0, 0 }, RightShoulder = { 56, 0, -6 }, RightElbow = { 30, 0, 0 }, LeftShoulder = { 56, 0, 6 }, LeftElbow = { 30, 0, 0 } }) },
		{ T = 1, Pose = merge(STAND, { Waist = { 0, 0, 0 }, Neck = { 0, 0, 0 }, RightShoulder = { 8, 0, 8 }, RightElbow = { 12, 0, 0 }, LeftShoulder = { 0, 0, 0 }, LeftElbow = { 0, 0, 0 } }) },
	},
}

-- Gentle strokes on the animal's head. Pet marker at T = 0.42.
A.PetAnimal = {
	Keys = {
		{ T = 0, Pose = { Waist = { 0, 0, 0 }, RightShoulder = { 0, 0, 0 }, RightElbow = { 0, 0, 0 } } },
		{ T = 0.25, Ease = "Out", Pose = { Waist = { -18, 0, 0 }, Neck = { -10, 0, 0 }, RightShoulder = { 70, 0, -4 }, RightElbow = { 24, 0, 0 }, RightWrist = { -20, 0, 0 } } },
		{ T = 0.42, Pose = { Waist = { -18, 0, 0 }, Neck = { -10, 6, 0 }, RightShoulder = { 70, -14, -4 }, RightElbow = { 30, 0, 0 }, RightWrist = { -20, 0, 0 } } },
		{ T = 0.58, Pose = { Waist = { -18, 0, 0 }, Neck = { -10, -6, 0 }, RightShoulder = { 70, 14, -4 }, RightElbow = { 24, 0, 0 }, RightWrist = { -20, 0, 0 } } },
		{ T = 0.74, Pose = { Waist = { -18, 0, 0 }, Neck = { -10, 6, 0 }, RightShoulder = { 70, -14, -4 }, RightElbow = { 30, 0, 0 }, RightWrist = { -20, 0, 0 } } },
		{ T = 1, Pose = { Waist = { 0, 0, 0 }, Neck = { 0, 0, 0 }, RightShoulder = { 0, 0, 0 }, RightElbow = { 0, 0, 0 }, RightWrist = { 0, 0, 0 } } },
	},
}

-- Overhead cast: rod back, whip forward, line flies. Cast marker at T = 0.5.
A.FishingCast = {
	Keys = {
		{ T = 0, Pose = { Waist = { 0, 0, 0 }, RightShoulder = { 30, 0, 4 }, RightElbow = { 18, 0, 0 }, LeftShoulder = { 26, 0, 14 }, LeftElbow = { 40, 0, 0 } } },
		{ T = 0.3, Ease = "Out", Pose = { Waist = { 10, -18, 0 }, Neck = { 4, 0, 0 }, RightShoulder = { 166, 0, 12 }, RightElbow = { 24, 0, 0 }, RightWrist = { 10, 0, 0 }, LeftShoulder = { 30, 0, -6 }, LeftElbow = { 20, 0, 0 } } },
		{ T = 0.5, Ease = "In", Pose = { Waist = { -14, 14, 0 }, Neck = { -2, 0, 0 }, RightShoulder = { 70, 0, -4 }, RightElbow = { 4, 0, 0 }, RightWrist = { -10, 0, 0 }, LeftShoulder = { 30, 0, 10 }, LeftElbow = { 30, 0, 0 } } },
		{ T = 1, Pose = { Waist = { 0, 0, 0 }, Neck = { 0, 0, 0 }, RightShoulder = { 34, 0, 4 }, RightElbow = { 16, 0, 0 }, RightWrist = { 0, 0, 0 }, LeftShoulder = { 26, 0, 14 }, LeftElbow = { 40, 0, 0 } } },
	},
}

-- Waiting for a bite: tiny bobbing of the rod (looped).
A.FishingWait = {
	Keys = {
		{ T = 0, Pose = { Neck = { -6, 0, 0 }, RightShoulder = { 32, 0, 4 }, RightElbow = { 16, 0, 0 }, LeftShoulder = { 26, 0, 14 }, LeftElbow = { 40, 0, 0 } } },
		{ T = 0.5, Pose = { Neck = { -8, 4, 0 }, RightShoulder = { 30, 0, 4 }, RightElbow = { 20, 0, 0 }, LeftShoulder = { 28, 0, 14 }, LeftElbow = { 42, 0, 0 } } },
		{ T = 1, Pose = { Neck = { -6, 0, 0 }, RightShoulder = { 32, 0, 4 }, RightElbow = { 16, 0, 0 }, LeftShoulder = { 26, 0, 14 }, LeftElbow = { 40, 0, 0 } } },
	},
}

-- Rod jerks down when a fish bites.
A.FishingBite = {
	Keys = {
		{ T = 0, Pose = { Waist = { 0, 0, 0 }, RightShoulder = { 32, 0, 4 }, RightElbow = { 16, 0, 0 } } },
		{ T = 0.3, Ease = "Out", Pose = { Waist = { -12, 0, 0 }, Neck = { -12, 0, 0 }, RightShoulder = { 10, 0, 4 }, RightElbow = { 6, 0, 0 } } },
		{ T = 1, Pose = { Waist = { 0, 0, 0 }, Neck = { 0, 0, 0 }, RightShoulder = { 32, 0, 4 }, RightElbow = { 16, 0, 0 } } },
	},
}

-- Reeling: lean back, left hand cranks (looped).
A.FishingReel = {
	Keys = {
		{ T = 0, Pose = { Waist = { 10, 0, 0 }, Neck = { -4, 0, 0 }, RightShoulder = { 46, 0, 4 }, RightElbow = { 30, 0, 0 }, LeftShoulder = { 40, 0, 10 }, LeftElbow = { 60, 0, 0 }, LeftWrist = { 0, 0, 0 } } },
		{ T = 0.25, Pose = { Waist = { 12, 2, 0 }, RightShoulder = { 50, 0, 4 }, RightElbow = { 34, 0, 0 }, LeftShoulder = { 52, 0, 16 }, LeftElbow = { 40, 0, 0 }, LeftWrist = { 20, 0, 0 } } },
		{ T = 0.5, Pose = { Waist = { 10, 0, 0 }, RightShoulder = { 46, 0, 4 }, RightElbow = { 30, 0, 0 }, LeftShoulder = { 40, 0, 22 }, LeftElbow = { 30, 0, 0 }, LeftWrist = { 0, 0, 0 } } },
		{ T = 0.75, Pose = { Waist = { 12, -2, 0 }, RightShoulder = { 50, 0, 4 }, RightElbow = { 34, 0, 0 }, LeftShoulder = { 30, 0, 12 }, LeftElbow = { 56, 0, 0 }, LeftWrist = { -20, 0, 0 } } },
		{ T = 1, Pose = { Waist = { 10, 0, 0 }, Neck = { -4, 0, 0 }, RightShoulder = { 46, 0, 4 }, RightElbow = { 30, 0, 0 }, LeftShoulder = { 40, 0, 10 }, LeftElbow = { 60, 0, 0 }, LeftWrist = { 0, 0, 0 } } },
	},
}
A.FishingStruggle = A.FishingReel

-- Yank the fish out of the water and hold it up.
A.FishingCatch = {
	Legs = true,
	Keys = {
		{ T = 0, Pose = merge(STAND, { Waist = { 10, 0, 0 }, RightShoulder = { 46, 0, 4 }, RightElbow = { 30, 0, 0 }, LeftShoulder = { 40, 0, 10 }, LeftElbow = { 60, 0, 0 } }) },
		{ T = 0.35, Ease = "Out", Pose = merge(STAND, { Root = { 0, 0, 0, 0, 0.3, 0 }, Waist = { 20, 0, 0 }, Neck = { 12, 0, 0 }, RightShoulder = { 150, 0, 10 }, RightElbow = { 20, 0, 0 }, LeftShoulder = { 140, 0, -10 }, LeftElbow = { 20, 0, 0 } }) },
		{ T = 0.7, Pose = merge(STAND, { Waist = { 6, 0, 0 }, Neck = { 6, 0, 0 }, RightShoulder = { 110, 0, 10 }, RightElbow = { 30, 0, 0 }, LeftShoulder = { 120, 0, -20 }, LeftElbow = { 40, 0, 0 } }) },
		{ T = 1, Pose = merge(STAND, { Waist = { 0, 0, 0 }, Neck = { 0, 0, 0 }, RightShoulder = { 30, 0, 4 }, RightElbow = { 18, 0, 0 }, LeftShoulder = { 26, 0, 14 }, LeftElbow = { 40, 0, 0 } }) },
	},
}

-- The fish got away: slump.
A.FishingFail = {
	Keys = {
		{ T = 0, Pose = { Waist = { 0, 0, 0 }, Neck = { 0, 0, 0 }, RightShoulder = { 32, 0, 4 } } },
		{ T = 0.35, Ease = "Out", Pose = { Waist = { -14, 0, 0 }, Neck = { -26, 0, 0 }, RightShoulder = { 10, 0, 4 }, RightElbow = { 10, 0, 0 }, LeftShoulder = { 4, 0, -4 } } },
		{ T = 0.75, Pose = { Waist = { -14, 0, 0 }, Neck = { -24, -10, 0 }, RightShoulder = { 12, 0, 4 }, RightElbow = { 10, 0, 0 } } },
		{ T = 1, Pose = { Waist = { 0, 0, 0 }, Neck = { 0, 0, 0 }, RightShoulder = { 30, 0, 4 }, RightElbow = { 18, 0, 0 }, LeftShoulder = { 0, 0, 0 } } },
	},
}

-- Jump for joy with both arms up.
A.Cheer = {
	Legs = true,
	Keys = {
		{ T = 0, Pose = merge(STAND, { Waist = { 0, 0, 0 }, RightShoulder = { 0, 0, 0 }, LeftShoulder = { 0, 0, 0 } }) },
		{ T = 0.15, Ease = "Out", Pose = merge(CROUCH, { Root = { 0, 0, 0, 0, -0.6, 0 }, RightHip = { 40, 0, 4 }, RightKnee = { -60, 0, 0 }, LeftHip = { 40, 0, -4 }, LeftKnee = { -60, 0, 0 }, Waist = { -10, 0, 0 }, RightShoulder = { 30, 0, 10 }, LeftShoulder = { 30, 0, -10 } }) },
		{ T = 0.35, Ease = "Out", Pose = merge(STAND, { Root = { 0, 0, 0, 0, 1.4, 0 }, RightKnee = { -30, 0, 0 }, LeftKnee = { -30, 0, 0 }, Waist = { 8, 0, 0 }, Neck = { 12, 0, 0 }, RightShoulder = { 170, 0, 24 }, RightElbow = { 10, 0, 0 }, LeftShoulder = { 170, 0, -24 }, LeftElbow = { 10, 0, 0 } }) },
		{ T = 0.55, Ease = "In", Pose = merge(STAND, { Waist = { 4, 0, 0 }, Neck = { 8, 0, 0 }, RightShoulder = { 160, 0, 30 }, LeftShoulder = { 160, 0, -30 } }) },
		{ T = 0.7, Pose = merge(STAND, { Waist = { 4, 8, 0 }, RightShoulder = { 170, 0, 18 }, RightElbow = { 30, 0, 0 }, LeftShoulder = { 170, 0, -18 }, LeftElbow = { 30, 0, 0 } }) },
		{ T = 0.85, Pose = merge(STAND, { Waist = { 4, -8, 0 }, RightShoulder = { 170, 0, 30 }, RightElbow = { 0, 0, 0 }, LeftShoulder = { 170, 0, -30 }, LeftElbow = { 0, 0, 0 } }) },
		{ T = 1, Pose = merge(STAND, { Waist = { 0, 0, 0 }, Neck = { 0, 0, 0 }, RightShoulder = { 0, 0, 0 }, RightElbow = { 0, 0, 0 }, LeftShoulder = { 0, 0, 0 }, LeftElbow = { 0, 0, 0 } }) },
	},
}
A.Celebrate = A.Cheer
A.CelebrateBuild = A.Cheer
A.CelebrateHarvest = A.Cheer
A.FishingCelebrate = A.Cheer
A.BuildFinish = A.HammerHeavy

-- Friendly wave (right arm up at the side, hand swinging).
A.Wave = {
	Keys = {
		{ T = 0, Pose = { Neck = { 0, 0, 0 }, RightShoulder = { 0, 0, 0 }, RightElbow = { 0, 0, 0 } } },
		{ T = 0.18, Ease = "Out", Pose = { Neck = { 4, 8, 0 }, RightShoulder = { 20, 0, 150 }, RightElbow = { 30, 0, 0 } } },
		{ T = 0.32, Pose = { RightShoulder = { 20, 0, 150 }, RightElbow = { 30, 0, 0 }, RightWrist = { 0, 0, 25 } } },
		{ T = 0.46, Pose = { RightShoulder = { 20, 0, 150 }, RightElbow = { 30, 0, 0 }, RightWrist = { 0, 0, -25 } } },
		{ T = 0.6, Pose = { RightShoulder = { 20, 0, 150 }, RightElbow = { 30, 0, 0 }, RightWrist = { 0, 0, 25 } } },
		{ T = 0.74, Pose = { Neck = { 4, 8, 0 }, RightShoulder = { 20, 0, 150 }, RightElbow = { 30, 0, 0 }, RightWrist = { 0, 0, -25 } } },
		{ T = 1, Pose = { Neck = { 0, 0, 0 }, RightShoulder = { 0, 0, 0 }, RightElbow = { 0, 0, 0 }, RightWrist = { 0, 0, 0 } } },
	},
}

A.Point = {
	Keys = {
		{ T = 0, Pose = { Waist = { 0, 0, 0 }, RightShoulder = { 0, 0, 0 }, RightElbow = { 0, 0, 0 } } },
		{ T = 0.2, Ease = "Out", Pose = { Waist = { 0, 10, 0 }, Neck = { 0, 6, 0 }, RightShoulder = { 92, 0, 4 }, RightElbow = { 0, 0, 0 } } },
		{ T = 0.8, Pose = { Waist = { 0, 10, 0 }, Neck = { 0, 6, 0 }, RightShoulder = { 94, 0, 4 }, RightElbow = { 0, 0, 0 } } },
		{ T = 1, Pose = { Waist = { 0, 0, 0 }, Neck = { 0, 0, 0 }, RightShoulder = { 0, 0, 0 }, RightElbow = { 0, 0, 0 } } },
	},
}

-- A happy little island dance (looped while it plays).
A.Dance = {
	Legs = true,
	Keys = {
		{ T = 0, Pose = merge(STAND, { Root = { 0, 0, 8, 0, 0, 0 }, Waist = { 0, 10, -6 }, Neck = { 0, -10, 6 }, RightShoulder = { 150, 0, 30 }, RightElbow = { 40, 0, 0 }, LeftShoulder = { 20, 0, -40 }, LeftElbow = { 60, 0, 0 } }) },
		{ T = 0.25, Pose = merge(STAND, { Root = { 0, 0, 0, 0, -0.4, 0 }, RightKnee = { -30, 0, 0 }, LeftKnee = { -30, 0, 0 }, RightHip = { 20, 0, 0 }, LeftHip = { 20, 0, 0 }, Waist = { 0, 0, 0 }, RightShoulder = { 90, 0, 20 }, RightElbow = { 90, 0, 0 }, LeftShoulder = { 90, 0, -20 }, LeftElbow = { 90, 0, 0 } }) },
		{ T = 0.5, Pose = merge(STAND, { Root = { 0, 0, -8, 0, 0, 0 }, Waist = { 0, -10, 6 }, Neck = { 0, 10, -6 }, RightShoulder = { 20, 0, 40 }, RightElbow = { 60, 0, 0 }, LeftShoulder = { 150, 0, -30 }, LeftElbow = { 40, 0, 0 } }) },
		{ T = 0.75, Pose = merge(STAND, { Root = { 0, 0, 0, 0, -0.4, 0 }, RightKnee = { -30, 0, 0 }, LeftKnee = { -30, 0, 0 }, RightHip = { 20, 0, 0 }, LeftHip = { 20, 0, 0 }, Waist = { 0, 0, 0 }, RightShoulder = { 90, 0, 20 }, RightElbow = { 90, 0, 0 }, LeftShoulder = { 90, 0, -20 }, LeftElbow = { 90, 0, 0 } }) },
		{ T = 1, Pose = merge(STAND, { Root = { 0, 0, 8, 0, 0, 0 }, Waist = { 0, 10, -6 }, Neck = { 0, -10, 6 }, RightShoulder = { 150, 0, 30 }, RightElbow = { 40, 0, 0 }, LeftShoulder = { 20, 0, -40 }, LeftElbow = { 60, 0, 0 } }) },
	},
}

-- Lift a heavy lid (starter chest).
A.OpenChest = {
	Legs = true,
	Keys = {
		{ T = 0, Pose = merge(STAND, { Waist = { 0, 0, 0 }, RightShoulder = { 0, 0, 0 }, LeftShoulder = { 0, 0, 0 } }) },
		{ T = 0.35, Ease = "Out", Pose = merge(CROUCH, { Root = { 0, 0, 0, 0, -0.7, 0 }, Waist = { -26, 0, 0 }, RightShoulder = { 56, 0, -6 }, RightElbow = { 20, 0, 0 }, LeftShoulder = { 56, 0, 6 }, LeftElbow = { 20, 0, 0 } }) },
		{ T = 0.7, Ease = "Out", Pose = merge(STAND, { Waist = { 6, 0, 0 }, Neck = { 10, 0, 0 }, RightShoulder = { 120, 0, -6 }, RightElbow = { 30, 0, 0 }, LeftShoulder = { 120, 0, 6 }, LeftElbow = { 30, 0, 0 } }) },
		{ T = 1, Pose = merge(STAND, { Waist = { 0, 0, 0 }, Neck = { 0, 0, 0 }, RightShoulder = { 0, 0, 0 }, RightElbow = { 0, 0, 0 }, LeftShoulder = { 0, 0, 0 }, LeftElbow = { 0, 0, 0 } }) },
	},
}

-- Crafting / building extras reuse the closest motion.
A.PlaceWood = A.PlantSeed
A.PlaceStone = A.PlantSeed
A.PlantConstruction = A.ShovelDig
A.SawWood = A.HammerSwing
A.Paint = A.WaterPlant
A.FillTrough = A.WaterPlant
A.CraftStart = A.PickCrop
A.CraftWork = A.HammerSwing
A.CraftFinish = A.Cheer

---------------------------------------------------------------------------
-- Swing variants: every tool has three swings, picked at random each use.
-- They keep the base swing's impact time (see AnimationConfig.Variants),
-- and use cartoon anticipation -> smash -> overshoot timing.
---------------------------------------------------------------------------

local AXE = { Waist = { 0, 0, 0 }, Neck = { 0, 0, 0 }, RightShoulder = { 16, 0, 6 }, RightElbow = { 78, 0, 0 }, RightWrist = { -8, 0, 0 }, LeftShoulder = { 0, 0, 0 }, LeftElbow = { 0, 0, 0 } }
local PICK = { Waist = { 0, 0, 0 }, Neck = { 0, 0, 0 }, RightShoulder = { 18, 0, 6 }, RightElbow = { 74, 0, 0 }, RightWrist = { 0, 0, 0 }, LeftShoulder = { 0, 0, 0 }, LeftElbow = { 0, 0, 0 } }
local HAMMER = { Waist = { 0, 0, 0 }, Neck = { 0, 0, 0 }, RightShoulder = { 14, 0, 6 }, RightElbow = { 70, 0, 0 }, RightWrist = { 0, 0, 0 }, LeftShoulder = { 0, 0, 0 }, LeftElbow = { 0, 0, 0 } }
local HOE = { Waist = { 0, 0, 0 }, Neck = { 0, 0, 0 }, RightShoulder = { 22, 0, 4 }, RightElbow = { 60, 0, 0 }, RightWrist = { 0, 0, 0 }, LeftShoulder = { 30, 0, 18 }, LeftElbow = { 50, 0, 0 } }
local SHOVEL = { Waist = { 0, 0, 0 }, Neck = { 0, 0, 0 }, RightShoulder = { 20, 0, 4 }, RightElbow = { 62, 0, 0 }, RightWrist = { 0, 0, 0 }, LeftShoulder = { 28, 0, 18 }, LeftElbow = { 48, 0, 0 } }
local CAN = { Waist = { 0, 0, 0 }, Neck = { 0, 0, 0 }, RightShoulder = { 34, 0, 4 }, RightElbow = { 30, 0, 0 }, RightWrist = { -20, 0, 0 } }
local ROD = { Waist = { 0, 0, 0 }, Neck = { 0, 0, 0 }, RightShoulder = { 30, 0, 4 }, RightElbow = { 18, 0, 0 }, RightWrist = { 0, 0, 0 }, LeftShoulder = { 26, 0, 14 }, LeftElbow = { 40, 0, 0 } }
local BUCKET = { Waist = { 0, 0, 0 }, Neck = { 0, 0, 0 }, RightShoulder = { 8, 0, 8 }, RightElbow = { 12, 0, 0 }, RightWrist = { -80, 0, 0 } }
local SHEARS = { Waist = { 0, 0, 0 }, Neck = { 0, 0, 0 }, RightShoulder = { 12, 0, 6 }, RightElbow = { 55, 0, 0 }, RightWrist = { 0, 0, 0 }, LeftShoulder = { 0, 0, 0 }, LeftElbow = { 0, 0, 0 } }

-- AXE 2: two-handed overhead chop straight down.
A.AxeChopHigh = {
	Keys = {
		{ T = 0, Pose = AXE },
		{ T = 0.3, Ease = "Out", Pose = { Waist = { 14, 0, 0 }, Neck = { 8, 0, 0 }, RightShoulder = { 172, 0, 8 }, RightElbow = { 64, 0, 0 }, RightWrist = { 10, 0, 0 }, LeftShoulder = { 160, 0, -10 }, LeftElbow = { 64, 0, 0 } } },
		{ T = 0.5, Ease = "In", Pose = { Waist = { -26, 0, 0 }, Neck = { -12, 0, 0 }, RightShoulder = { 66, 0, -6 }, RightElbow = { 4, 0, 0 }, RightWrist = { -76, 0, 0 }, LeftShoulder = { 60, 0, 10 }, LeftElbow = { 8, 0, 0 } } },
		{ T = 0.62, Ease = "Out", Pose = { Waist = { -20, 0, 0 }, Neck = { -8, 0, 0 }, RightShoulder = { 74, 0, -6 }, RightElbow = { 10, 0, 0 }, RightWrist = { -64, 0, 0 }, LeftShoulder = { 66, 0, 10 }, LeftElbow = { 12, 0, 0 } } },
		{ T = 1, Pose = AXE },
	},
}

-- AXE 3: flat horizontal slash with a big torso twist.
A.AxeSlash = {
	Keys = {
		{ T = 0, Pose = AXE },
		{ T = 0.3, Ease = "Out", Pose = { Waist = { 4, -48, 0 }, Neck = { 0, 30, 0 }, RightShoulder = { 90, 0, 62 }, RightElbow = { 40, 0, 0 }, RightWrist = { -60, 0, 0 }, LeftShoulder = { 40, 0, -20 }, LeftElbow = { 60, 0, 0 } } },
		{ T = 0.5, Ease = "In", Pose = { Waist = { -6, 40, 0 }, Neck = { 0, -24, 0 }, RightShoulder = { 86, 0, -18 }, RightElbow = { 6, 0, 0 }, RightWrist = { -84, 0, 0 }, LeftShoulder = { 20, 0, 20 }, LeftElbow = { 30, 0, 0 } } },
		{ T = 0.66, Ease = "Out", Pose = { Waist = { -4, 46, 0 }, Neck = { 0, -26, 0 }, RightShoulder = { 80, 0, -26 }, RightElbow = { 10, 0, 0 }, RightWrist = { -80, 0, 0 }, LeftShoulder = { 16, 0, 20 }, LeftElbow = { 26, 0, 0 } } },
		{ T = 1, Pose = AXE },
	},
}

-- PICKAXE 2: diagonal strike from the right shoulder.
A.PickaxeSide = {
	Keys = {
		{ T = 0, Pose = PICK },
		{ T = 0.3, Ease = "Out", Pose = { Waist = { 6, -30, 0 }, Neck = { 0, 14, 0 }, RightShoulder = { 140, 0, 40 }, RightElbow = { 60, 0, 0 }, RightWrist = { 10, 0, 0 }, LeftShoulder = { 50, 0, -6 }, LeftElbow = { 40, 0, 0 } } },
		{ T = 0.49, Ease = "In", Pose = { Waist = { -22, 20, 0 }, Neck = { -12, -8, 0 }, RightShoulder = { 54, 0, -12 }, RightElbow = { 8, 0, 0 }, RightWrist = { -96, 0, 0 }, LeftShoulder = { 30, 0, 12 }, LeftElbow = { 30, 0, 0 } } },
		{ T = 0.62, Ease = "Out", Pose = { Waist = { -18, 22, 0 }, Neck = { -10, -8, 0 }, RightShoulder = { 50, 0, -12 }, RightElbow = { 12, 0, 0 }, RightWrist = { -86, 0, 0 }, LeftShoulder = { 26, 0, 12 }, LeftElbow = { 26, 0, 0 } } },
		{ T = 1, Pose = PICK },
	},
}

-- PICKAXE 3: hop up and SLAM down with both hands.
A.PickaxeSlam = {
	Legs = true,
	Keys = {
		{ T = 0, Pose = merge(STAND, PICK) },
		{ T = 0.3, Ease = "Out", Pose = merge(STAND, { Root = { 0, 0, 0, 0, 0.5, 0 }, RightKnee = { -20, 0, 0 }, LeftKnee = { -20, 0, 0 }, Waist = { 16, 0, 0 }, Neck = { 10, 0, 0 }, RightShoulder = { 178, 0, 6 }, RightElbow = { 30, 0, 0 }, RightWrist = { 0, 0, 0 }, LeftShoulder = { 170, 0, -6 }, LeftElbow = { 30, 0, 0 } }) },
		{ T = 0.49, Ease = "In", Pose = merge(STAND, { Root = { 0, 0, 0, 0, -0.45, 0 }, RightHip = { 22, 0, 0 }, RightKnee = { -40, 0, 0 }, RightAnkle = { 18, 0, 0 }, LeftHip = { 22, 0, 0 }, LeftKnee = { -40, 0, 0 }, LeftAnkle = { 18, 0, 0 }, Waist = { -32, 0, 0 }, Neck = { -16, 0, 0 }, RightShoulder = { 56, 0, -2 }, RightElbow = { 6, 0, 0 }, RightWrist = { -104, 0, 0 }, LeftShoulder = { 52, 0, 4 }, LeftElbow = { 8, 0, 0 } }) },
		{ T = 0.66, Ease = "Out", Pose = merge(STAND, { Root = { 0, 0, 0, 0, -0.3, 0 }, RightHip = { 16, 0, 0 }, RightKnee = { -28, 0, 0 }, RightAnkle = { 12, 0, 0 }, LeftHip = { 16, 0, 0 }, LeftKnee = { -28, 0, 0 }, LeftAnkle = { 12, 0, 0 }, Waist = { -26, 0, 0 }, Neck = { -12, 0, 0 }, RightShoulder = { 58, 0, -2 }, RightElbow = { 10, 0, 0 }, RightWrist = { -94, 0, 0 }, LeftShoulder = { 50, 0, 4 }, LeftElbow = { 12, 0, 0 } }) },
		{ T = 1, Pose = merge(STAND, PICK) },
	},
}

-- HAMMER 2: sideways bash.
A.HammerBash = {
	Keys = {
		{ T = 0, Pose = HAMMER },
		{ T = 0.26, Ease = "Out", Pose = { Waist = { 2, -40, 0 }, Neck = { 0, 24, 0 }, RightShoulder = { 100, 0, 58 }, RightElbow = { 60, 0, 0 }, RightWrist = { -40, 0, 0 }, LeftShoulder = { 30, 0, -10 }, LeftElbow = { 40, 0, 0 } } },
		{ T = 0.48, Ease = "In", Pose = { Waist = { -6, 32, 0 }, Neck = { 0, -20, 0 }, RightShoulder = { 84, 0, -14 }, RightElbow = { 8, 0, 0 }, RightWrist = { -86, 0, 0 }, LeftShoulder = { 20, 0, 14 }, LeftElbow = { 30, 0, 0 } } },
		{ T = 0.62, Ease = "Out", Pose = { Waist = { -4, 36, 0 }, Neck = { 0, -22, 0 }, RightShoulder = { 80, 0, -20 }, RightElbow = { 12, 0, 0 }, RightWrist = { -80, 0, 0 }, LeftShoulder = { 18, 0, 14 }, LeftElbow = { 28, 0, 0 } } },
		{ T = 1, Pose = HAMMER },
	},
}

-- HAMMER 3: lean way back, then a big overhead slam with bent knees.
A.HammerSlam = {
	Legs = true,
	Keys = {
		{ T = 0, Pose = merge(STAND, HAMMER) },
		{ T = 0.28, Ease = "Out", Pose = merge(STAND, { Waist = { 18, -6, 0 }, Neck = { 12, 0, 0 }, RightShoulder = { 176, 0, 12 }, RightElbow = { 90, 0, 0 }, RightWrist = { 20, 0, 0 }, LeftShoulder = { 80, 0, -20 }, LeftElbow = { 50, 0, 0 } }) },
		{ T = 0.48, Ease = "In", Pose = merge(STAND, { Root = { 0, 0, 0, 0, -0.3, 0 }, RightHip = { 14, 0, 0 }, RightKnee = { -22, 0, 0 }, LeftHip = { 14, 0, 0 }, LeftKnee = { -22, 0, 0 }, Waist = { -24, 6, 0 }, Neck = { -12, 0, 0 }, RightShoulder = { 56, 0, -2 }, RightElbow = { 10, 0, 0 }, RightWrist = { -90, 0, 0 }, LeftShoulder = { 40, 0, 8 }, LeftElbow = { 30, 0, 0 } }) },
		{ T = 0.62, Ease = "Out", Pose = merge(STAND, { Root = { 0, 0, 0, 0, -0.18, 0 }, RightHip = { 8, 0, 0 }, RightKnee = { -12, 0, 0 }, LeftHip = { 8, 0, 0 }, LeftKnee = { -12, 0, 0 }, Waist = { -18, 6, 0 }, Neck = { -8, 0, 0 }, RightShoulder = { 60, 0, -2 }, RightElbow = { 16, 0, 0 }, RightWrist = { -80, 0, 0 }, LeftShoulder = { 36, 0, 8 }, LeftElbow = { 30, 0, 0 } }) },
		{ T = 1, Pose = merge(STAND, HAMMER) },
	},
}

-- HOE 2: short, snappy chop.
A.HoeChop = {
	Keys = {
		{ T = 0, Pose = HOE },
		{ T = 0.36, Ease = "Out", Pose = { Waist = { 6, 0, 0 }, Neck = { 2, 0, 0 }, RightShoulder = { 110, 0, 6 }, RightElbow = { 40, 0, 0 }, RightWrist = { 0, 0, 0 }, LeftShoulder = { 100, 0, -2 }, LeftElbow = { 40, 0, 0 } } },
		{ T = 0.54, Ease = "In", Pose = { Waist = { -24, 0, 0 }, Neck = { -14, 0, 0 }, RightShoulder = { 48, 0, 0 }, RightElbow = { 6, 0, 0 }, RightWrist = { -90, 0, 0 }, LeftShoulder = { 44, 0, 6 }, LeftElbow = { 10, 0, 0 } } },
		{ T = 0.64, Ease = "Out", Pose = { Waist = { -20, 0, 0 }, Neck = { -12, 0, 0 }, RightShoulder = { 54, 0, 0 }, RightElbow = { 10, 0, 0 }, RightWrist = { -80, 0, 0 }, LeftShoulder = { 48, 0, 6 }, LeftElbow = { 14, 0, 0 } } },
		{ T = 1, Pose = HOE },
	},
}

-- HOE 3: reach forward and rake the soil back towards you.
A.HoeScrape = {
	Keys = {
		{ T = 0, Pose = HOE },
		{ T = 0.3, Ease = "Out", Pose = { Waist = { -20, 0, 0 }, Neck = { -10, 0, 0 }, RightShoulder = { 80, 0, 4 }, RightElbow = { 10, 0, 0 }, RightWrist = { -60, 0, 0 }, LeftShoulder = { 76, 0, 8 }, LeftElbow = { 12, 0, 0 } } },
		{ T = 0.54, Ease = "In", Pose = { Waist = { -34, 0, 0 }, Neck = { -18, 0, 0 }, RightShoulder = { 40, 0, 0 }, RightElbow = { 40, 0, 0 }, RightWrist = { -100, 0, 0 }, LeftShoulder = { 38, 0, 6 }, LeftElbow = { 44, 0, 0 } } },
		{ T = 0.75, Ease = "Out", Pose = { Waist = { -10, 10, 0 }, Neck = { -4, 0, 0 }, RightShoulder = { 30, 0, 4 }, RightElbow = { 60, 0, 0 }, RightWrist = { -40, 0, 0 }, LeftShoulder = { 30, 0, 14 }, LeftElbow = { 50, 0, 0 } } },
		{ T = 1, Pose = HOE },
	},
}

-- SHOVEL 2: stab low and toss the dirt over your shoulder.
A.ShovelScoop = {
	Legs = true,
	Keys = {
		{ T = 0, Pose = merge(STAND, SHOVEL) },
		{ T = 0.3, Ease = "Out", Pose = merge(STAND, { Waist = { -14, 0, 0 }, RightShoulder = { 40, 0, 4 }, RightElbow = { 20, 0, 0 }, RightWrist = { -80, 0, 0 }, LeftShoulder = { 50, 0, 10 }, LeftElbow = { 20, 0, 0 } }) },
		{ T = 0.56, Ease = "In", Pose = merge(STAND, { Root = { 0, 0, 0, 0, -0.35, 0 }, RightHip = { 24, 0, 0 }, RightKnee = { -36, 0, 0 }, LeftHip = { 14, 0, 0 }, LeftKnee = { -24, 0, 0 }, Waist = { -30, 0, 0 }, Neck = { -14, 0, 0 }, RightShoulder = { 26, 0, 0 }, RightElbow = { 6, 0, 0 }, RightWrist = { -114, 0, 0 }, LeftShoulder = { 36, 0, 10 }, LeftElbow = { 14, 0, 0 } }) },
		{ T = 0.8, Ease = "Out", Pose = merge(STAND, { Waist = { 10, 40, 0 }, Neck = { 6, 20, 0 }, RightShoulder = { 110, 0, -10 }, RightElbow = { 40, 0, 0 }, RightWrist = { -20, 0, 0 }, LeftShoulder = { 100, 0, 10 }, LeftElbow = { 60, 0, 0 } }) },
		{ T = 1, Pose = merge(STAND, SHOVEL) },
	},
}

-- SHOVEL 3: lift a foot and stomp the blade into the ground.
A.ShovelStomp = {
	Legs = true,
	Keys = {
		{ T = 0, Pose = merge(STAND, SHOVEL) },
		{ T = 0.3, Ease = "Out", Pose = merge(STAND, { Root = { 0, 0, 0, 0, 0.15, 0 }, RightHip = { 60, 0, 0 }, RightKnee = { -70, 0, 0 }, Waist = { -10, 0, 0 }, RightShoulder = { 50, 0, 4 }, RightElbow = { 30, 0, 0 }, RightWrist = { -80, 0, 0 }, LeftShoulder = { 56, 0, 10 }, LeftElbow = { 30, 0, 0 } }) },
		{ T = 0.56, Ease = "In", Pose = merge(STAND, { Root = { 0, 0, 0, 0, -0.3, 0 }, RightHip = { 24, 0, 0 }, RightKnee = { -20, 0, 0 }, LeftHip = { 12, 0, 0 }, LeftKnee = { -26, 0, 0 }, Waist = { -26, 0, 0 }, Neck = { -14, 0, 0 }, RightShoulder = { 34, 0, 0 }, RightElbow = { 10, 0, 0 }, RightWrist = { -108, 0, 0 }, LeftShoulder = { 44, 0, 10 }, LeftElbow = { 18, 0, 0 } }) },
		{ T = 0.8, Ease = "Out", Pose = merge(STAND, { Waist = { -6, -16, 0 }, Neck = { -4, 0, 0 }, RightShoulder = { 70, 0, 10 }, RightElbow = { 50, 0, 0 }, RightWrist = { -40, 0, 0 }, LeftShoulder = { 60, 0, 10 }, LeftElbow = { 40, 0, 0 } }) },
		{ T = 1, Pose = merge(STAND, SHOVEL) },
	},
}

-- WATERING CAN 2: sweep the spout side to side.
A.WaterSweep = {
	Keys = {
		{ T = 0, Pose = CAN },
		{ T = 0.25, Ease = "Out", Pose = { Waist = { -10, 20, 0 }, Neck = { -16, 10, 0 }, RightShoulder = { 60, 0, 20 }, RightElbow = { 14, 0, 0 }, RightWrist = { -30, 0, 0 } } },
		{ T = 0.42, Pose = { Waist = { -12, 20, 0 }, Neck = { -20, 10, 0 }, RightShoulder = { 62, 0, 22 }, RightElbow = { 10, 0, 0 }, RightWrist = { -84, 0, 0 } } },
		{ T = 0.62, Pose = { Waist = { -12, -20, 0 }, Neck = { -20, -10, 0 }, RightShoulder = { 60, 0, -10 }, RightElbow = { 10, 0, 0 }, RightWrist = { -86, 0, 0 } } },
		{ T = 0.8, Pose = { Waist = { -12, 10, 0 }, Neck = { -18, 6, 0 }, RightShoulder = { 60, 0, 12 }, RightElbow = { 10, 0, 0 }, RightWrist = { -84, 0, 0 } } },
		{ T = 1, Pose = CAN },
	},
}

-- WATERING CAN 3: stand on tiptoe and pour from high up.
A.WaterHigh = {
	Legs = true,
	Keys = {
		{ T = 0, Pose = merge(STAND, CAN) },
		{ T = 0.25, Ease = "Out", Pose = merge(STAND, { Root = { 0, 0, 0, 0, 0.25, 0 }, RightAnkle = { -20, 0, 0 }, LeftAnkle = { -20, 0, 0 }, Waist = { 6, 0, 0 }, Neck = { 6, 0, 0 }, RightShoulder = { 130, 0, 6 }, RightElbow = { 30, 0, 0 }, RightWrist = { -20, 0, 0 }, LeftShoulder = { 40, 0, -10 } }) },
		{ T = 0.42, Pose = merge(STAND, { Root = { 0, 0, 0, 0, 0.25, 0 }, RightAnkle = { -20, 0, 0 }, LeftAnkle = { -20, 0, 0 }, Waist = { 0, 0, 0 }, Neck = { -10, 0, 0 }, RightShoulder = { 126, 0, 6 }, RightElbow = { 20, 0, 0 }, RightWrist = { -90, 0, 0 }, LeftShoulder = { 40, 0, -10 } }) },
		{ T = 0.7, Pose = merge(STAND, { Root = { 0, 0, 0, 0, 0.2, 0 }, RightAnkle = { -16, 0, 0 }, LeftAnkle = { -16, 0, 0 }, Waist = { 0, 8, 0 }, Neck = { -12, 8, 0 }, RightShoulder = { 124, 0, 8 }, RightElbow = { 20, 0, 0 }, RightWrist = { -96, 0, 0 }, LeftShoulder = { 36, 0, -10 } }) },
		{ T = 1, Pose = merge(STAND, merge(CAN, { LeftShoulder = { 0, 0, 0 } })) },
	},
}

-- FISHING ROD 2: sidearm cast.
A.FishingCastSide = {
	Keys = {
		{ T = 0, Pose = ROD },
		{ T = 0.3, Ease = "Out", Pose = { Waist = { 4, -40, 0 }, Neck = { 0, 20, 0 }, RightShoulder = { 70, 0, 70 }, RightElbow = { 30, 0, 0 }, RightWrist = { -20, 0, 0 }, LeftShoulder = { 20, 0, -10 }, LeftElbow = { 40, 0, 0 } } },
		{ T = 0.5, Ease = "In", Pose = { Waist = { -8, 30, 0 }, Neck = { 0, -14, 0 }, RightShoulder = { 70, 0, -16 }, RightElbow = { 4, 0, 0 }, RightWrist = { -10, 0, 0 }, LeftShoulder = { 30, 0, 14 }, LeftElbow = { 30, 0, 0 } } },
		{ T = 1, Pose = ROD },
	},
}

-- FISHING ROD 3: quick two-handed flick.
A.FishingCastFlick = {
	Keys = {
		{ T = 0, Pose = ROD },
		{ T = 0.34, Ease = "Out", Pose = { Waist = { 12, 0, 0 }, Neck = { 6, 0, 0 }, RightShoulder = { 140, 0, 8 }, RightElbow = { 50, 0, 0 }, RightWrist = { 20, 0, 0 }, LeftShoulder = { 130, 0, -8 }, LeftElbow = { 50, 0, 0 } } },
		{ T = 0.5, Ease = "In", Pose = { Waist = { -12, 0, 0 }, Neck = { -4, 0, 0 }, RightShoulder = { 74, 0, 0 }, RightElbow = { 6, 0, 0 }, RightWrist = { -6, 0, 0 }, LeftShoulder = { 70, 0, 6 }, LeftElbow = { 10, 0, 0 } } },
		{ T = 0.62, Ease = "Out", Pose = { Waist = { -8, 0, 0 }, Neck = { -2, 0, 0 }, RightShoulder = { 66, 0, 0 }, RightElbow = { 10, 0, 0 }, RightWrist = { -4, 0, 0 }, LeftShoulder = { 62, 0, 6 }, LeftElbow = { 14, 0, 0 } } },
		{ T = 1, Pose = ROD },
	},
}

-- BUCKET 1-3: pendulum swing, scoop from the ground, toss forward.
A.BucketSwing = {
	Keys = {
		{ T = 0, Pose = BUCKET },
		{ T = 0.28, Ease = "Out", Pose = { Waist = { 4, -10, 0 }, Neck = { 0, 0, 0 }, RightShoulder = { -40, 0, 10 }, RightElbow = { 8, 0, 0 }, RightWrist = { -70, 0, 0 } } },
		{ T = 0.5, Ease = "In", Pose = { Waist = { -6, 8, 0 }, Neck = { -4, 0, 0 }, RightShoulder = { 80, 0, 4 }, RightElbow = { 6, 0, 0 }, RightWrist = { -90, 0, 0 } } },
		{ T = 0.7, Ease = "Out", Pose = { Waist = { -4, 6, 0 }, Neck = { -2, 0, 0 }, RightShoulder = { 60, 0, 4 }, RightElbow = { 10, 0, 0 }, RightWrist = { -84, 0, 0 } } },
		{ T = 1, Pose = BUCKET },
	},
}
A.BucketScoop = {
	Legs = true,
	Keys = {
		{ T = 0, Pose = merge(STAND, BUCKET) },
		{ T = 0.3, Ease = "Out", Pose = merge(CROUCH, { Waist = { -30, 0, 0 }, Neck = { -16, 0, 0 }, RightShoulder = { 40, 0, 0 }, RightElbow = { 6, 0, 0 }, RightWrist = { -60, 0, 0 } }) },
		{ T = 0.5, Pose = merge(CROUCH, { Waist = { -26, 0, 0 }, Neck = { -12, 0, 0 }, RightShoulder = { 60, 0, 0 }, RightElbow = { 30, 0, 0 }, RightWrist = { -40, 0, 0 } }) },
		{ T = 0.75, Ease = "Out", Pose = merge(STAND, { Waist = { 4, 0, 0 }, Neck = { 4, 0, 0 }, RightShoulder = { 90, 0, 4 }, RightElbow = { 40, 0, 0 }, RightWrist = { -60, 0, 0 } }) },
		{ T = 1, Pose = merge(STAND, BUCKET) },
	},
}
A.BucketToss = {
	Keys = {
		{ T = 0, Pose = BUCKET },
		{ T = 0.28, Ease = "Out", Pose = { Waist = { 6, -20, 0 }, Neck = { 0, 8, 0 }, RightShoulder = { -30, 0, 20 }, RightElbow = { 10, 0, 0 }, RightWrist = { -80, 0, 0 } } },
		{ T = 0.5, Ease = "In", Pose = { Waist = { -10, 10, 0 }, Neck = { -4, 0, 0 }, RightShoulder = { 120, 0, 0 }, RightElbow = { 10, 0, 0 }, RightWrist = { -120, 0, 0 } } },
		{ T = 0.66, Ease = "Out", Pose = { Waist = { -8, 10, 0 }, Neck = { -2, 0, 0 }, RightShoulder = { 110, 0, 0 }, RightElbow = { 10, 0, 0 }, RightWrist = { -110, 0, 0 } } },
		{ T = 1, Pose = BUCKET },
	},
}

-- SHEARS 1-3: snip in front, low (crouched) and high.
A.ShearsSnip = {
	Keys = {
		{ T = 0, Pose = SHEARS },
		{ T = 0.25, Ease = "Out", Pose = { Waist = { -10, 0, 0 }, Neck = { -6, 0, 0 }, RightShoulder = { 70, 0, 0 }, RightElbow = { 20, 0, 0 }, RightWrist = { -10, 0, 0 }, LeftShoulder = { 40, 0, -10 }, LeftElbow = { 40, 0, 0 } } },
		{ T = 0.4, Pose = { Waist = { -10, 0, 0 }, RightShoulder = { 72, 0, 0 }, RightElbow = { 20, 0, 0 }, RightWrist = { 10, 0, 0 } } },
		{ T = 0.5, Ease = "In", Pose = { Waist = { -12, 0, 0 }, RightShoulder = { 74, 0, 0 }, RightElbow = { 18, 0, 0 }, RightWrist = { -20, 0, 0 } } },
		{ T = 0.62, Pose = { Waist = { -10, 0, 0 }, RightShoulder = { 72, 0, 0 }, RightElbow = { 20, 0, 0 }, RightWrist = { 10, 0, 0 } } },
		{ T = 1, Pose = SHEARS },
	},
}
A.ShearsSnipLow = {
	Legs = true,
	Keys = {
		{ T = 0, Pose = merge(STAND, SHEARS) },
		{ T = 0.3, Ease = "Out", Pose = merge(CROUCH, { Waist = { -24, 0, 0 }, Neck = { -14, 0, 0 }, RightShoulder = { 50, 0, -4 }, RightElbow = { 10, 0, 0 }, RightWrist = { -20, 0, 0 } }) },
		{ T = 0.5, Pose = merge(CROUCH, { Waist = { -24, 0, 0 }, Neck = { -14, 0, 0 }, RightShoulder = { 54, 0, -4 }, RightElbow = { 10, 0, 0 }, RightWrist = { 10, 0, 0 } }) },
		{ T = 0.65, Pose = merge(CROUCH, { Waist = { -22, 0, 0 }, Neck = { -12, 0, 0 }, RightShoulder = { 52, 0, -4 }, RightElbow = { 10, 0, 0 }, RightWrist = { -20, 0, 0 } }) },
		{ T = 1, Pose = merge(STAND, SHEARS) },
	},
}
A.ShearsSnipHigh = {
	Keys = {
		{ T = 0, Pose = SHEARS },
		{ T = 0.3, Ease = "Out", Pose = { Waist = { 6, 0, 0 }, Neck = { 12, 0, 0 }, RightShoulder = { 130, 0, 6 }, RightElbow = { 10, 0, 0 }, RightWrist = { 0, 0, 0 } } },
		{ T = 0.5, Pose = { Waist = { 6, 0, 0 }, Neck = { 12, 0, 0 }, RightShoulder = { 132, 0, 6 }, RightElbow = { 10, 0, 0 }, RightWrist = { -24, 0, 0 } } },
		{ T = 0.62, Pose = { Waist = { 6, 0, 0 }, Neck = { 12, 0, 0 }, RightShoulder = { 130, 0, 6 }, RightElbow = { 10, 0, 0 }, RightWrist = { 12, 0, 0 } } },
		{ T = 1, Pose = SHEARS },
	},
}

---------------------------------------------------------------------------
-- Mia the Merchant
---------------------------------------------------------------------------

local MIA_REST = merge(STAND, { Waist = { 0, 0, 0 }, Neck = { 0, 0, 0 }, RightShoulder = { 28, 0, -14 }, RightElbow = { 70, 0, 0 }, RightWrist = { 0, 0, 0 }, LeftShoulder = { 28, 0, 14 }, LeftElbow = { 70, 0, 0 }, LeftWrist = { 0, 0, 0 } })

-- Idle behind the counter: hands clasped, swaying, humming, looking around (looped).
A.MiaIdle = {
	Keys = {
		{ T = 0, Pose = merge(MIA_REST, { Root = { 0, 0, 2, 0, 0, 0 }, Waist = { 0, 4, 0 }, Neck = { 0, -6, 4 } }) },
		{ T = 0.25, Pose = merge(MIA_REST, { Root = { 0, 0, -2, 0, 0.04, 0 }, Waist = { 2, -4, 0 }, Neck = { 4, 10, -4 } }) },
		{ T = 0.5, Pose = merge(MIA_REST, { Root = { 0, 0, 2, 0, 0, 0 }, Waist = { 0, 4, 0 }, Neck = { -4, 24, 2 } }) },
		{ T = 0.62, Pose = merge(MIA_REST, { Root = { 0, 0, 1, 0, 0.02, 0 }, Waist = { 1, 2, 0 }, Neck = { 6, 20, 0 } }) },
		{ T = 0.75, Pose = merge(MIA_REST, { Root = { 0, 0, -2, 0, 0.04, 0 }, Waist = { 2, -4, 0 }, Neck = { 0, -18, -4 } }) },
		{ T = 1, Pose = merge(MIA_REST, { Root = { 0, 0, 2, 0, 0, 0 }, Waist = { 0, 4, 0 }, Neck = { 0, -6, 4 } }) },
	},
}

-- Big happy two-step wave on her toes, other hand on her hip.
A.MiaWave = {
	Legs = true,
	Keys = {
		{ T = 0, Pose = MIA_REST },
		{ T = 0.14, Ease = "Out", Pose = merge(STAND, { Root = { 0, 0, 0, 0, 0.2, 0 }, RightAnkle = { -16, 0, 0 }, LeftAnkle = { -16, 0, 0 }, Waist = { 4, 8, -4 }, Neck = { 6, 10, 6 }, RightShoulder = { 20, 0, 150 }, RightElbow = { 30, 0, 0 }, LeftShoulder = { -10, 0, -30 }, LeftElbow = { 90, 0, 0 } }) },
		{ T = 0.28, Pose = merge(STAND, { Root = { 0, 0, 0, 0, 0.2, 0 }, RightAnkle = { -16, 0, 0 }, LeftAnkle = { -16, 0, 0 }, Waist = { 4, 8, -4 }, Neck = { 6, 10, 6 }, RightShoulder = { 20, 0, 150 }, RightElbow = { 30, 0, 0 }, RightWrist = { 0, 0, 30 }, LeftShoulder = { -10, 0, -30 }, LeftElbow = { 90, 0, 0 } }) },
		{ T = 0.42, Pose = merge(STAND, { Root = { 0, 0, 0, 0, 0.05, 0 }, Waist = { 4, 8, 4 }, Neck = { 6, 10, -6 }, RightShoulder = { 20, 0, 150 }, RightElbow = { 30, 0, 0 }, RightWrist = { 0, 0, -30 }, LeftShoulder = { -10, 0, -30 }, LeftElbow = { 90, 0, 0 } }) },
		{ T = 0.56, Pose = merge(STAND, { Root = { 0, 0, 0, 0, 0.2, 0 }, RightAnkle = { -16, 0, 0 }, LeftAnkle = { -16, 0, 0 }, Waist = { 4, 8, -4 }, Neck = { 6, 10, 6 }, RightShoulder = { 20, 0, 150 }, RightElbow = { 30, 0, 0 }, RightWrist = { 0, 0, 30 }, LeftShoulder = { -10, 0, -30 }, LeftElbow = { 90, 0, 0 } }) },
		{ T = 0.7, Pose = merge(STAND, { Root = { 0, 0, 0, 0, 0.05, 0 }, Waist = { 4, 8, 4 }, Neck = { 6, 10, -6 }, RightShoulder = { 20, 0, 150 }, RightElbow = { 30, 0, 0 }, RightWrist = { 0, 0, -30 }, LeftShoulder = { -10, 0, -30 }, LeftElbow = { 90, 0, 0 } }) },
		{ T = 1, Pose = MIA_REST },
	},
}

-- "Take a look!": arms sweep open palms-up over the goods, a little bow.
A.MiaPresent = {
	Keys = {
		{ T = 0, Pose = MIA_REST },
		{ T = 0.25, Ease = "Out", Pose = merge(MIA_REST, { Waist = { 8, 0, 0 }, Neck = { 6, 0, 0 }, RightShoulder = { 40, 0, 20 }, RightElbow = { 40, 0, 0 }, LeftShoulder = { 40, 0, -20 }, LeftElbow = { 40, 0, 0 } }) },
		{ T = 0.5, Ease = "Out", Pose = merge(MIA_REST, { Waist = { -16, 0, 0 }, Neck = { -6, 0, 0 }, RightShoulder = { 60, 0, 55 }, RightElbow = { 12, 0, 0 }, RightWrist = { 0, 0, -20 }, LeftShoulder = { 60, 0, -55 }, LeftElbow = { 12, 0, 0 }, LeftWrist = { 0, 0, 20 } }) },
		{ T = 0.72, Pose = merge(MIA_REST, { Waist = { -10, 16, 0 }, Neck = { -14, 10, 0 }, RightShoulder = { 70, 0, 20 }, RightElbow = { 6, 0, 0 }, RightWrist = { -30, 0, 0 }, LeftShoulder = { 20, 0, -20 }, LeftElbow = { 60, 0, 0 } }) },
		{ T = 1, Pose = MIA_REST },
	},
}

-- "Thank you!": three happy claps, then a hop.
local CLAP_OPEN = { RightShoulder = { 70, 0, 26 }, RightElbow = { 40, 0, 0 }, LeftShoulder = { 70, 0, -26 }, LeftElbow = { 40, 0, 0 } }
local CLAP_SHUT = { RightShoulder = { 72, 0, -8 }, RightElbow = { 40, 0, 0 }, LeftShoulder = { 72, 0, 8 }, LeftElbow = { 40, 0, 0 } }
A.MiaSold = {
	Legs = true,
	Keys = {
		{ T = 0, Pose = MIA_REST },
		{ T = 0.1, Pose = merge(STAND, CLAP_OPEN, { Neck = { 8, 0, 8 } }) },
		{ T = 0.18, Pose = merge(STAND, CLAP_SHUT, { Neck = { 8, 0, 8 } }) },
		{ T = 0.28, Pose = merge(STAND, CLAP_OPEN, { Neck = { 8, 0, -8 } }) },
		{ T = 0.36, Pose = merge(STAND, CLAP_SHUT, { Neck = { 8, 0, -8 } }) },
		{ T = 0.46, Pose = merge(STAND, CLAP_OPEN, { Neck = { 8, 0, 8 } }) },
		{ T = 0.54, Pose = merge(STAND, CLAP_SHUT, { Neck = { 8, 0, 8 } }) },
		{ T = 0.64, Ease = "Out", Pose = merge(CROUCH, { Root = { 0, 0, 0, 0, -0.5, 0 }, RightHip = { 30, 0, 4 }, RightKnee = { -50, 0, 0 }, LeftHip = { 30, 0, -4 }, LeftKnee = { -50, 0, 0 }, RightAnkle = { 20, 0, 0 }, LeftAnkle = { 20, 0, 0 }, RightShoulder = { 20, 0, 20 }, LeftShoulder = { 20, 0, -20 } }) },
		{ T = 0.78, Ease = "Out", Pose = merge(STAND, { Root = { 0, 0, 0, 0, 1.2, 0 }, RightKnee = { -30, 0, 0 }, LeftKnee = { -30, 0, 0 }, Neck = { 12, 0, 0 }, RightShoulder = { 160, 0, 30 }, RightElbow = { 10, 0, 0 }, LeftShoulder = { 160, 0, -30 }, LeftElbow = { 10, 0, 0 } }) },
		{ T = 1, Pose = MIA_REST },
	},
}

-- Chatty hands: gesturing while she gives a tip.
A.MiaTalk = {
	Keys = {
		{ T = 0, Pose = MIA_REST },
		{ T = 0.18, Pose = merge(MIA_REST, { Neck = { 6, 6, 0 }, RightShoulder = { 50, 0, 20 }, RightElbow = { 70, 0, 0 }, RightWrist = { 0, 0, -20 } }) },
		{ T = 0.36, Pose = merge(MIA_REST, { Neck = { -4, -4, 0 }, RightShoulder = { 40, 0, 10 }, RightElbow = { 90, 0, 0 }, LeftShoulder = { 50, 0, -20 }, LeftElbow = { 70, 0, 0 } }) },
		{ T = 0.54, Pose = merge(MIA_REST, { Neck = { 6, 8, 6 }, RightShoulder = { 60, 0, 30 }, RightElbow = { 50, 0, 0 }, LeftShoulder = { 40, 0, -10 }, LeftElbow = { 90, 0, 0 } }) },
		{ T = 0.72, Pose = merge(MIA_REST, { Neck = { 10, 0, 0 }, RightShoulder = { 90, 0, 0 }, RightElbow = { 20, 0, 0 }, LeftShoulder = { 28, 0, 14 }, LeftElbow = { 70, 0, 0 } }) },
		{ T = 1, Pose = MIA_REST },
	},
}

Keyframes.Actions = A

-- Idle life for NPC rigs (no Animate script): breathing + looking around.
Keyframes.NPCIdle = {
	Keys = {
		{ T = 0, Pose = { Waist = { 0, 0, 0 }, Neck = { 0, 0, 0 }, RightShoulder = { 0, 0, 4 }, LeftShoulder = { 0, 0, -4 } } },
		{ T = 0.25, Pose = { Waist = { 2, 0, 0 }, Neck = { 2, 18, 0 }, RightShoulder = { 2, 0, 5 }, LeftShoulder = { 2, 0, -5 } } },
		{ T = 0.5, Pose = { Waist = { 0, 0, 0 }, Neck = { 0, 0, 0 }, RightShoulder = { 0, 0, 4 }, LeftShoulder = { 0, 0, -4 } } },
		{ T = 0.75, Pose = { Waist = { 2, 0, 0 }, Neck = { -2, -16, 0 }, RightShoulder = { 2, 0, 5 }, LeftShoulder = { 2, 0, -5 } } },
		{ T = 1, Pose = { Waist = { 0, 0, 0 }, Neck = { 0, 0, 0 }, RightShoulder = { 0, 0, 4 }, LeftShoulder = { 0, 0, -4 } } },
	},
} :: Action

-- Every joint an action touches (so joints it doesn't mention keep their pose).
function Keyframes.JointsOf(action: Action): { string }
	local set: { [string]: boolean } = {}
	for _, key in action.Keys do
		for joint in key.Pose do
			set[joint] = true
		end
	end
	local list = {}
	for joint in set do
		table.insert(list, joint)
	end
	table.sort(list)
	return list
end

return Keyframes
