--!strict
--[[
	SCRIPT NAME:  Locomotion
	SCRIPT TYPE:  ModuleScript (client animation)
	WHERE:        StarterPlayerScripts/Client/Animation/Locomotion
	DEPENDENCIES: none

	The game's OWN R15 movement animations (they replace Roblox's default
	"Animate" script — see StarterCharacterScripts/Animate). Cartoon-bouncy,
	procedural and speed-matched, so feet don't slide:

	  IDLE    breathing, gentle arm sway, the odd look around
	  WALK    arm/leg swing, hip twist, head bob          (normal speed)
	  RUN     big strides, pumping bent arms, forward lean (sprinting, Shift)
	  JUMP    knee tuck, arms thrown up
	  FALL    arms flailing, legs dangling
	  LAND    cartoon squash on landing (bigger drop = bigger squash)
	  SWIM    front crawl when moving, treading water when still
	  CLIMB   hand-over-hand
	  SIT     seated
	  + a slight bank into turns

	Update(state, input) returns joint poses { [joint] = {X, Y, Z, PX, PY, PZ} }
	(degrees / studs, same format as Shared/Animation/Keyframes). Each pose
	blends smoothly into the next. AnimationController runs it for every
	character (yours and everyone else's), so all players see it.
]]

export type Pose = { [string]: { number } }

export type State = {
	Phase: number,
	Walk: number,
	Run: number,
	Air: number,
	Swim: number,
	Climb: number,
	Sit: number,
	Rise: number,
	Lean: number,
	AirTime: number,
	LandAt: number,
	LandStrength: number,
	FallSpeed: number,
	Steps: number, -- footsteps taken (half cycles), for footstep effects
}

export type Input = {
	Speed: number, -- horizontal studs/s
	VerticalSpeed: number,
	TurnRate: number, -- radians/s (yaw)
	Grounded: boolean,
	Swimming: boolean,
	Climbing: boolean,
	Sitting: boolean,
	Clock: number,
	Dt: number,
}

local Locomotion = {}

local JOINTS = {
	"Root", "Waist", "Neck",
	"RightShoulder", "RightElbow", "RightWrist",
	"LeftShoulder", "LeftElbow", "LeftWrist",
	"RightHip", "RightKnee", "RightAnkle",
	"LeftHip", "LeftKnee", "LeftAnkle",
}
Locomotion.Joints = JOINTS

local WALK_STRIDE = 8.5 -- studs per full walk cycle (two steps)
local RUN_STRIDE = 13
local RUN_FROM = 18 -- speed where running starts to blend in
local RUN_FULL = 23

local function v(x: number?, y: number?, z: number?, px: number?, py: number?, pz: number?): { number }
	return { x or 0, y or 0, z or 0, px or 0, py or 0, pz or 0 }
end

local function approach(current: number, target: number, rate: number, dt: number): number
	return current + (target - current) * math.min(1, rate * dt)
end

local function blend(a: Pose, b: Pose, w: number): Pose
	if w <= 0 then
		return a
	elseif w >= 1 then
		return b
	end
	local out: Pose = {}
	for _, joint in JOINTS do
		local pa = a[joint]
		local pb = b[joint]
		if pa or pb then
			local x = pa or v()
			local y = pb or v()
			out[joint] = {
				x[1] + (y[1] - x[1]) * w,
				x[2] + (y[2] - x[2]) * w,
				x[3] + (y[3] - x[3]) * w,
				(x[4] or 0) + ((y[4] or 0) - (x[4] or 0)) * w,
				(x[5] or 0) + ((y[5] or 0) - (x[5] or 0)) * w,
				(x[6] or 0) + ((y[6] or 0) - (x[6] or 0)) * w,
			}
		end
	end
	return out
end

local function add(pose: Pose, joint: string, delta: { number })
	local current = pose[joint] or v()
	pose[joint] = {
		current[1] + (delta[1] or 0),
		current[2] + (delta[2] or 0),
		current[3] + (delta[3] or 0),
		(current[4] or 0) + (delta[4] or 0),
		(current[5] or 0) + (delta[5] or 0),
		(current[6] or 0) + (delta[6] or 0),
	}
end

---------------------------------------------------------------------------
-- Poses
---------------------------------------------------------------------------

local function idlePose(t: number): Pose
	local breathe = math.sin(t * 1.8)
	local look = math.sin(t * 0.35) ^ 3 -- mostly still, sometimes looks around
	return {
		Root = v(0, 0, 0, 0, 0.03 * breathe, 0),
		Waist = v(1.2 * breathe, 0, 0),
		Neck = v(-1 * breathe, 14 * look, 0),
		RightShoulder = v(3 + 1.5 * breathe, 0, 5),
		LeftShoulder = v(3 + 1.5 * breathe, 0, -5),
		RightElbow = v(8),
		LeftElbow = v(8),
		RightHip = v(),
		LeftHip = v(),
		RightKnee = v(),
		LeftKnee = v(),
		RightAnkle = v(),
		LeftAnkle = v(),
	}
end

local function walkPose(p: number): Pose
	local s, c = math.sin(p), math.cos(p)
	local rightKnee = -(6 + 44 * math.max(0, c))
	local leftKnee = -(6 + 44 * math.max(0, -c))
	return {
		Root = v(0, -6 * s, 0, 0, 0.05 - 0.15 * math.abs(s), 0),
		Waist = v(0, 9 * s, 0),
		Neck = v(0, -3 * s, 0),
		RightHip = v(32 * s),
		LeftHip = v(-32 * s),
		RightKnee = v(rightKnee),
		LeftKnee = v(leftKnee),
		RightAnkle = v(-(32 * s + rightKnee) * 0.3),
		LeftAnkle = v(-(-32 * s + leftKnee) * 0.3),
		RightShoulder = v(-28 * s, 0, 6),
		LeftShoulder = v(28 * s, 0, -6),
		RightElbow = v(14 + 18 * math.max(0, -s)),
		LeftElbow = v(14 + 18 * math.max(0, s)),
	}
end

local function runPose(p: number): Pose
	local s, c = math.sin(p), math.cos(p)
	return {
		Root = v(-9, -8 * s, 0, 0, 0.2 * math.abs(s) - 0.12, 0),
		Waist = v(-6, 13 * s, 0),
		Neck = v(10, -5 * s, 0),
		RightHip = v(50 * s + 8),
		LeftHip = v(-50 * s + 8),
		RightKnee = v(-(18 + 88 * math.max(0, c))),
		LeftKnee = v(-(18 + 88 * math.max(0, -c))),
		RightAnkle = v(12 * s),
		LeftAnkle = v(-12 * s),
		RightShoulder = v(-55 * s + 6, 0, 10),
		LeftShoulder = v(55 * s + 6, 0, -10),
		RightElbow = v(82),
		LeftElbow = v(82),
	}
end

local function jumpPose(): Pose
	return {
		Root = v(6),
		Waist = v(6),
		Neck = v(8),
		RightHip = v(62),
		RightKnee = v(-88),
		RightAnkle = v(20),
		LeftHip = v(20),
		LeftKnee = v(-42),
		LeftAnkle = v(10),
		RightShoulder = v(150, 0, 30),
		LeftShoulder = v(110, 0, -40),
		RightElbow = v(20),
		LeftElbow = v(24),
	}
end

local function fallPose(t: number): Pose
	local flail = math.sin(t * 14)
	local kick = math.sin(t * 10)
	return {
		Root = v(0),
		Waist = v(-4),
		Neck = v(12),
		RightShoulder = v(130 + 18 * flail, 0, 55),
		LeftShoulder = v(130 - 18 * flail, 0, -55),
		RightElbow = v(30 + 10 * flail),
		LeftElbow = v(30 - 10 * flail),
		RightHip = v(26 + 12 * kick),
		LeftHip = v(10 - 12 * kick),
		RightKnee = v(-36),
		LeftKnee = v(-22),
		RightAnkle = v(10),
		LeftAnkle = v(10),
	}
end

local function swimPose(t: number, moving: number): Pose
	local a = t * 4.5
	local flutter = math.sin(t * 9)
	local crawl: Pose = {
		Root = v(-72),
		Waist = v(0, 10 * math.sin(a), 0),
		Neck = v(45),
		RightShoulder = v(90 + 100 * math.sin(a), 0, 18),
		LeftShoulder = v(90 - 100 * math.sin(a), 0, -18),
		RightElbow = v(25),
		LeftElbow = v(25),
		RightHip = v(18 * flutter),
		LeftHip = v(-18 * flutter),
		RightKnee = v(-14),
		LeftKnee = v(-14),
		RightAnkle = v(-30),
		LeftAnkle = v(-30),
	}
	local tread = math.sin(t * 3)
	local treading: Pose = {
		Root = v(0, 0, 0, 0, 0.1 * tread, 0),
		Waist = v(0),
		Neck = v(0),
		RightShoulder = v(40, 0, 40 + 25 * tread),
		LeftShoulder = v(40, 0, -40 - 25 * tread),
		RightElbow = v(30),
		LeftElbow = v(30),
		RightHip = v(30 + 25 * math.sin(t * 4)),
		LeftHip = v(30 - 25 * math.sin(t * 4)),
		RightKnee = v(-50),
		LeftKnee = v(-50),
		RightAnkle = v(),
		LeftAnkle = v(),
	}
	return blend(treading, crawl, moving)
end

local function climbPose(t: number, moving: boolean): Pose
	local a = t * (if moving then 7 else 1.5)
	local s = math.sin(a)
	return {
		Root = v(0),
		Waist = v(0),
		Neck = v(15),
		RightShoulder = v(150 + 25 * s, 0, 10),
		LeftShoulder = v(150 - 25 * s, 0, -10),
		RightElbow = v(40 + 25 * math.max(0, -s)),
		LeftElbow = v(40 + 25 * math.max(0, s)),
		RightHip = v(45 + 30 * s),
		LeftHip = v(45 - 30 * s),
		RightKnee = v(-70),
		LeftKnee = v(-70),
		RightAnkle = v(),
		LeftAnkle = v(),
	}
end

local function sitPose(t: number): Pose
	local breathe = math.sin(t * 1.8)
	return {
		Root = v(0),
		Waist = v(2 * breathe),
		Neck = v(0),
		RightHip = v(90),
		LeftHip = v(90),
		RightKnee = v(-90),
		LeftKnee = v(-90),
		RightAnkle = v(),
		LeftAnkle = v(),
		RightShoulder = v(12, 0, 4),
		LeftShoulder = v(12, 0, -4),
		RightElbow = v(30),
		LeftElbow = v(30),
	}
end

---------------------------------------------------------------------------
-- Public
---------------------------------------------------------------------------

function Locomotion.NewState(): State
	return {
		Phase = math.random() * math.pi * 2,
		Walk = 0,
		Run = 0,
		Air = 0,
		Swim = 0,
		Climb = 0,
		Sit = 0,
		Rise = 0,
		Lean = 0,
		AirTime = 0,
		LandAt = -10,
		LandStrength = 0,
		FallSpeed = 0,
		Steps = 0,
	}
end

-- Advances the state and returns this frame's pose. Also returns
-- (landed: number?, stepped: boolean) so the caller can add dust puffs.
function Locomotion.Update(state: State, input: Input): (Pose, number?, boolean)
	local dt = math.min(input.Dt, 1 / 15)
	local t = input.Clock
	local speed = input.Speed
	local airborne = not input.Grounded and not input.Swimming and not input.Climbing and not input.Sitting

	-- Landing detection (cartoon squash).
	local landed: number? = nil
	if airborne then
		state.AirTime += dt
		state.FallSpeed = math.max(state.FallSpeed, -input.VerticalSpeed)
	else
		if state.AirTime > 0.28 and input.Grounded then
			state.LandAt = t
			state.LandStrength = math.clamp((state.FallSpeed - 8) / 45, 0.3, 1)
			landed = state.LandStrength
		end
		state.AirTime = 0
		state.FallSpeed = 0
	end

	-- Smooth blend weights.
	local grounded = input.Grounded and not input.Swimming and not input.Sitting
	state.Walk = approach(state.Walk, if grounded then math.clamp((speed - 0.6) / 4, 0, 1) else 0, 10, dt)
	state.Run = approach(state.Run, if grounded then math.clamp((speed - RUN_FROM) / (RUN_FULL - RUN_FROM), 0, 1) else 0, 8, dt)
	state.Air = approach(state.Air, if airborne and state.AirTime > 0.06 then 1 else 0, 14, dt)
	state.Swim = approach(state.Swim, if input.Swimming then 1 else 0, 8, dt)
	state.Climb = approach(state.Climb, if input.Climbing then 1 else 0, 10, dt)
	state.Sit = approach(state.Sit, if input.Sitting then 1 else 0, 10, dt)
	state.Rise = approach(state.Rise, math.clamp(input.VerticalSpeed / 25, -1, 1), 10, dt)
	state.Lean = approach(state.Lean, math.clamp(-input.TurnRate * 3, -10, 10) * math.clamp(speed / 16, 0, 1), 6, dt)

	-- Stride phase follows distance travelled (no foot sliding).
	local stepped = false
	if grounded and speed > 0.3 then
		local stride = WALK_STRIDE + (RUN_STRIDE - WALK_STRIDE) * state.Run
		local before = math.floor(state.Phase / math.pi)
		state.Phase += (speed / stride) * math.pi * 2 * dt
		if math.floor(state.Phase / math.pi) ~= before then
			state.Steps += 1
			stepped = true
		end
		if state.Phase > 1e4 then
			state.Phase %= math.pi * 2
		end
	end

	local pose = idlePose(t)
	pose = blend(pose, walkPose(state.Phase), state.Walk)
	pose = blend(pose, runPose(state.Phase), state.Run * state.Walk)
	if state.Air > 0.001 then
		local air = blend(fallPose(t), jumpPose(), (state.Rise + 1) / 2)
		pose = blend(pose, air, state.Air)
	end
	if state.Swim > 0.001 then
		pose = blend(pose, swimPose(t, math.clamp(speed / 10, 0, 1)), state.Swim)
	end
	if state.Climb > 0.001 then
		pose = blend(pose, climbPose(t, math.abs(input.VerticalSpeed) > 1), state.Climb)
	end
	if state.Sit > 0.001 then
		pose = blend(pose, sitPose(t), state.Sit)
	end

	-- Bank into turns.
	if math.abs(state.Lean) > 0.05 then
		add(pose, "Root", { 0, 0, state.Lean })
	end

	-- Landing squash: knees give, arms flare, then spring back.
	local sinceLand = t - state.LandAt
	if sinceLand < 0.34 then
		local x = sinceLand / 0.34
		local amount = state.LandStrength * (1 - x) ^ 2
		add(pose, "Root", { 0, 0, 0, 0, -0.75 * amount, 0 })
		add(pose, "RightHip", { 42 * amount })
		add(pose, "LeftHip", { 42 * amount })
		add(pose, "RightKnee", { -75 * amount })
		add(pose, "LeftKnee", { -75 * amount })
		add(pose, "RightAnkle", { 32 * amount })
		add(pose, "LeftAnkle", { 32 * amount })
		add(pose, "Waist", { -14 * amount })
		add(pose, "RightShoulder", { 10 * amount, 0, 30 * amount })
		add(pose, "LeftShoulder", { 10 * amount, 0, -30 * amount })
	end

	return pose, landed, stepped
end

return Locomotion
