--!nocheck
-- SwingAnim (ModuleScript): a natural two-handed overhead axe swing for R15
-- characters, blended on top of the normal one-handed tool-hold pose and back.
-- R15 only.
--
--   local Swing = require(tool.SwingAnim)
--   Swing.play(character, tool)   -- returns false if the character isn't R15
--   Swing.stop()

local RunService = game:GetService("RunService")

local Swing = {}
Swing.DURATION = 1.45
local WRIST_LAG = 0.05 -- elbows/wrists trail the shoulders a little (whip, not robot)

-- Pose = { [joint] = {pitch, yaw, roll} in degrees (in the torso's axes), Root = y offset }.
-- +pitch raises an arm/leg forward, -pitch on a knee bends it, +pitch on Waist/Neck
-- leans back / looks up; inward roll = -Z for the right arm, +Z for the left.
local READY = {
	Waist = { 0, 0, 0 }, Neck = { 0, 0, 0 },
	RightShoulder = { 88, 0, 0 }, RightElbow = { 0, 0, 0 }, RightWrist = { 0, 0, 0 },
	LeftShoulder = { 0, 0, 0 }, LeftElbow = { 0, 0, 0 }, LeftWrist = { 0, 0, 0 },
	RightHip = { 0, 0, 0 }, RightKnee = { 0, 0, 0 }, LeftHip = { 0, 0, 0 }, LeftKnee = { 0, 0, 0 },
	Root = 0,
}
-- both hands meet on the haft above the head, axe hanging back behind it
local TOP = {
	Waist = { 10, 9, 0 }, Neck = { 7, -6, 0 },
	RightShoulder = { 158, 0, -42 }, RightElbow = { 46, 0, 0 }, RightWrist = { -6, 0, 30 },
	LeftShoulder = { 150, 0, 44 }, LeftElbow = { 52, 0, 0 }, LeftWrist = { 0, 0, 0 },
	RightHip = { 3, 0, 0 }, RightKnee = { -5, 0, 0 }, LeftHip = { 2, 0, 0 }, LeftKnee = { -4, 0, 0 },
	Root = 0.02,
}
-- the brief hang at the top of the wind-up
local HANG = {
	Waist = { 13, 11, 0 }, Neck = { 8, -7, 0 },
	RightShoulder = { 163, 0, -43 }, RightElbow = { 52, 0, 0 }, RightWrist = { -12, 0, 30 },
	LeftShoulder = { 155, 0, 45 }, LeftElbow = { 57, 0, 0 }, LeftWrist = { 0, 0, 0 },
	RightHip = { 4, 0, 0 }, RightKnee = { -6, 0, 0 }, LeftHip = { 3, 0, 0 }, LeftKnee = { -5, 0, 0 },
	Root = 0.03,
}
-- the chop: arms extended forward-down, body bent into it, knees giving
local IMPACT = {
	Waist = { -22, -6, 0 }, Neck = { -12, 4, 0 },
	RightShoulder = { 52, 0, -42 }, RightElbow = { 6, 0, 0 }, RightWrist = { -62, 0, 30 },
	LeftShoulder = { 46, 0, 46 }, LeftElbow = { 10, 0, 0 }, LeftWrist = { -40, 0, 0 },
	RightHip = { 18, 0, 0 }, RightKnee = { -34, 0, 0 }, LeftHip = { 14, 0, 0 }, LeftKnee = { -28, 0, 0 },
	Root = -0.12,
}
-- small bounce back off the hit
local REBOUND = {
	Waist = { -16, -4, 0 }, Neck = { -8, 3, 0 },
	RightShoulder = { 61, 0, -38 }, RightElbow = { 11, 0, 0 }, RightWrist = { -50, 0, 28 },
	LeftShoulder = { 55, 0, 42 }, LeftElbow = { 15, 0, 0 }, LeftWrist = { -34, 0, 0 },
	RightHip = { 12, 0, 0 }, RightKnee = { -23, 0, 0 }, LeftHip = { 10, 0, 0 }, LeftKnee = { -19, 0, 0 },
	Root = -0.08,
}

local function sineInOut(x) return -(math.cos(math.pi * x) - 1) / 2 end
local function sineOut(x) return math.sin(x * math.pi / 2) end
local function quadIn(x) return x * x end

-- key times (s) and the easing used to arrive at each key
local KEYS = {
	{ 0.00, READY },
	{ 0.50, TOP, sineInOut },
	{ 0.62, HANG, sineOut },
	{ 0.85, IMPACT, quadIn },
	{ 0.98, REBOUND, sineOut },
	{ 1.32, READY, sineInOut },
}
local LAGGED = { RightElbow = true, RightWrist = true, LeftElbow = true, LeftWrist = true }

local function poseAt(t)
	t = math.clamp(t, 0, KEYS[#KEYS][1])
	for i = 2, #KEYS do
		local k0, k1 = KEYS[i - 1], KEYS[i]
		if t <= k1[1] then
			return k0[2], k1[2], k1[3]((t - k0[1]) / (k1[1] - k0[1]))
		end
	end
	return READY, READY, 0
end

local function anglesOf(name, t)
	local p0, p1, a = poseAt(LAGGED[name] and t - WRIST_LAG or t)
	local x0, x1 = p0[name], p1[name]
	return x0[1] + (x1[1] - x0[1]) * a, x0[2] + (x1[2] - x0[2]) * a, x0[3] + (x1[3] - x0[3]) * a
end

local function rootOffset(t)
	local p0, p1, a = poseAt(t)
	return p0.Root + (p1.Root - p0.Root) * a
end

-- blend in over 0.22 s, hold, blend back into the normal hold pose at the end
local function weight(t)
	if t < 0.22 then
		return sineInOut(t / 0.22)
	elseif t > 1.05 then
		return 1 - sineInOut(math.clamp((t - 1.05) / (Swing.DURATION - 1.05), 0, 1))
	end
	return 1
end

local JOINTS = {
	"Waist", "Neck",
	"RightShoulder", "RightElbow", "RightWrist",
	"LeftShoulder", "LeftElbow", "LeftWrist",
	"RightHip", "RightKnee", "LeftHip", "LeftKnee",
}

local function rigJoints(character)
	local hum = character:FindFirstChildOfClass("Humanoid")
	if not hum or hum.RigType ~= Enum.HumanoidRigType.R15 then
		return nil
	end
	local m = {}
	for _, d in character:GetDescendants() do
		if d:IsA("Motor6D") then
			m[d.Name] = d
		end
	end
	local list = {}
	for _, n in JOINTS do
		if m[n] then
			table.insert(list, { motor = m[n], name = n })
		end
	end
	if m.Root then
		table.insert(list, { motor = m.Root, name = "Root" })
	end
	return #list > 0 and list or nil
end

-- The pose goes into Motor6D.C0 (which the Animator never touches), offset so
-- the result equals blend(animated pose -> swing pose). The original C0s are
-- remembered per motor and always put back when a swing ends.
local originalC0 = setmetatable({}, { __mode = "k" })
local playing = nil

function Swing.stop()
	local s = playing
	playing = nil
	if s then
		s.conn:Disconnect()
		for _, j in s.joints do
			local c0 = originalC0[j.motor]
			if c0 and j.motor.Parent then
				j.motor.C0 = c0
			end
		end
	end
end

function Swing.play(character, tool)
	Swing.stop()
	local joints = character and rigJoints(character)
	if not joints then
		warn("[Wooden Axe] the swing needs an R15 character")
		return false
	end
	for _, j in joints do
		if originalC0[j.motor] == nil then
			originalC0[j.motor] = j.motor.C0
		end
	end
	local start = os.clock()
	local state = { joints = joints }
	playing = state
	state.conn = RunService.Stepped:Connect(function()
		if playing ~= state then
			return
		end
		local t = os.clock() - start
		if t >= Swing.DURATION or (tool and tool.Parent ~= character) then
			Swing.stop()
			return
		end
		local w = weight(t)
		for _, j in joints do
			local m = j.motor
			local target
			if j.name == "Root" then
				target = CFrame.new(0, rootOffset(t), 0)
			else
				local p, y, r = anglesOf(j.name, t)
				target = CFrame.Angles(math.rad(p), math.rad(y), math.rad(r))
			end
			local animated = m.Transform
			m.C0 = originalC0[m] * animated:Lerp(target, w) * animated:Inverse()
		end
	end)
	return true
end

return Swing
