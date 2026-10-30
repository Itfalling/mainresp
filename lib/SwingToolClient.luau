--!nocheck
-- Two-handed overhead swing for a held tool (Script, RunContext = Client, so it
-- runs on EVERY client: the owner swings on click, everyone else plays the same
-- swing when the server bumps the tool's "SwingCount" attribute).
--
-- The tool is held one-handed by the default Animate script ("toolnone").
-- During a swing we override the R15 joints' Motor6D.Transform after the
-- Animator has run, then blend smoothly back into its normal hold pose.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local tool = script.Parent
local remote = tool:WaitForChild("SwingEvent")

local DURATION = 1.45
local WRIST_LAG = 0.05 -- elbows/wrists trail the shoulders a little (whip, not robot)

-- Pose = { [joint] = {pitch, yaw, roll} in degrees, Root = y offset }.
-- R15 signs: +pitch raises an arm/leg forward, -pitch on a knee bends it,
-- +pitch on Waist/Neck leans back / looks up; inward roll = -Z right, +Z left.
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

local JOINTS = {
	"Waist", "Neck",
	"RightShoulder", "RightElbow", "RightWrist",
	"LeftShoulder", "LeftElbow", "LeftWrist",
	"RightHip", "RightKnee", "LeftHip", "LeftKnee",
}
local LAGGED = { RightElbow = true, RightWrist = true, LeftElbow = true, LeftWrist = true }

local function poseAt(t)
	t = math.clamp(t, 0, KEYS[#KEYS][1])
	for i = 2, #KEYS do
		local k0, k1 = KEYS[i - 1], KEYS[i]
		if t <= k1[1] then
			local a = k1[3]((t - k0[1]) / (k1[1] - k0[1]))
			return k0[2], k1[2], a
		end
	end
	return READY, READY, 0
end

local function jointAngles(name, t)
	local p0, p1, a = poseAt(LAGGED[name] and t - WRIST_LAG or t)
	local x0, x1 = p0[name], p1[name]
	return CFrame.Angles(
		math.rad(x0[1] + (x1[1] - x0[1]) * a),
		math.rad(x0[2] + (x1[2] - x0[2]) * a),
		math.rad(x0[3] + (x1[3] - x0[3]) * a)
	)
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
		return 1 - sineInOut(math.clamp((t - 1.05) / (DURATION - 1.05), 0, 1))
	end
	return 1
end

local function findMotors(character)
	local motors = {}
	for _, d in character:GetDescendants() do
		if d:IsA("Motor6D") then
			motors[d.Name] = d
		end
	end
	if not motors.RightShoulder then
		return nil -- R15 only; R6 characters keep the default tool animation
	end
	return motors
end

local playing = nil
local function stop()
	if playing then
		for _, c in playing.conns do
			c:Disconnect()
		end
		for _, m in playing.motors do
			if m.Parent then
				m.Transform = CFrame.new()
			end
		end
		playing = nil
	end
end

local function play(character)
	stop()
	local motors = character and findMotors(character)
	if not motors then
		return
	end
	local start = os.clock()
	local used = {}
	for _, n in JOINTS do
		if motors[n] then
			used[n] = motors[n]
		end
	end
	if motors.Root then
		used.Root = motors.Root
	end
	local state = { motors = used, conns = {} }
	playing = state
	-- clear our joints before the Animator runs, so joints it isn't animating
	-- start from rest instead of from our last frame
	table.insert(state.conns, RunService.PreAnimation:Connect(function()
		for _, m in used do
			m.Transform = CFrame.new()
		end
	end))
	table.insert(state.conns, RunService.PreSimulation:Connect(function()
		local t = os.clock() - start
		if t >= DURATION or tool.Parent ~= character then
			stop()
			return
		end
		local w = weight(t)
		for n, m in used do
			local target = n == "Root" and CFrame.new(0, rootOffset(t), 0) or jointAngles(n, t)
			m.Transform = m.Transform:Lerp(target, w)
		end
	end))
end

local function isMine()
	local me = Players.LocalPlayer
	return me and me.Character ~= nil and tool.Parent == me.Character
end

local lastLocal = 0
tool.Activated:Connect(function()
	if not isMine() or os.clock() - lastLocal < DURATION - 0.05 then
		return
	end
	lastLocal = os.clock()
	play(tool.Parent)
	remote:FireServer()
end)

tool:GetAttributeChangedSignal("SwingCount"):Connect(function()
	if not isMine() and tool.Parent and tool.Parent:FindFirstChildOfClass("Humanoid") then
		play(tool.Parent)
	end
end)

tool.Unequipped:Connect(stop)
script.Destroying:Connect(stop)
