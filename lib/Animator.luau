--!nocheck
-- Monster Animator (Script, RunContext = Client)
-- Plays the procedural animation in the sibling "Motion" module by driving
-- every Motor6D.Transform in the monster each frame. Runs on each client so
-- motion is buttery smooth and costs the server nothing.
--
-- Model attributes you can tweak in Studio:
--   AnimSpeed     (number, default 1)    playback speed multiplier
--   AnimOffset    (number, default rand) start time offset so copies desync
--   AnimDistance  (number, default 400)  stop animating beyond this camera distance
--   AnimEnabled   (bool,   default true) pause/resume
--
-- Monsters with gameplay states (guardians) also read:
--   AnimState     (string) looping state to play: "Idle", "Chase", "Return", ...
--                 "Reel" plays every state in a demo loop (used by the showcase)
--   AnimAction    (string) set to "<State>#<n>" to fire a one-shot ("Alert#3",
--                 "Attack#4"); change n to replay it. See the Control module.
-- Looping states with a Speed (studs/s) speed their stride up/down to match
-- how fast the model actually moves, so feet don't skate.

local RunService = game:GetService("RunService")

local animFolder = script.Parent
local model = animFolder:FindFirstAncestorWhichIsA("Model")
if not model then
	return
end

local AnimLib = require(animFolder:WaitForChild("AnimLib"))
local Motion = require(animFolder:WaitForChild("Motion"))
local cycle = Motion.Cycle or 10

-- Collect joints, emitters, lights and parts by name.
local motors = {}
local function scan()
	table.clear(motors)
	for _, d in model:GetDescendants() do
		if d:IsA("Motor6D") then
			motors[d.Name] = d
		end
	end
end
scan()

local namedCache = {}
local function findNamed(name, className)
	local key = className .. ":" .. name
	local hit = namedCache[key]
	if hit and hit.Parent then
		return hit
	end
	for _, d in model:GetDescendants() do
		if d.Name == name and d:IsA(className) then
			namedCache[key] = d
			return d
		end
	end
	return nil
end

local root = model.PrimaryPart or model:FindFirstChild("Root")
local offset = model:GetAttribute("AnimOffset")
if typeof(offset) ~= "number" then
	offset = math.random() * cycle
end

local clock = offset
local prevCycleT = clock % cycle
local curCycleT = prevCycleT
local pose = {}

-- ctx: optional helpers Motion.Update can call for effects.
local ctx = {}
ctx.cycle = cycle
-- true exactly once per loop when the cycle time passes `at` seconds.
function ctx.crossed(at)
	if curCycleT >= prevCycleT then
		return prevCycleT < at and at <= curCycleT
	end
	return at > prevCycleT or at <= curCycleT
end
-- Fire a burst from a ParticleEmitter by name.
function ctx.emit(name, count)
	local e = findNamed(name, "ParticleEmitter")
	if e then
		e:Emit(count or 20)
	end
end
-- Toggle a continuous ParticleEmitter by name.
function ctx.enable(name, on)
	local e = findNamed(name, "ParticleEmitter")
	if e and e.Enabled ~= on then
		e.Enabled = on
	end
end
-- Set a light's brightness by name (PointLight / SpotLight / SurfaceLight).
function ctx.light(name, brightness)
	local l = findNamed(name, "Light")
	if l then
		l.Brightness = brightness
	end
end
-- Set a part's transparency by name (blinks, flashes, glow pulses).
function ctx.transparency(name, value)
	local p = findNamed(name, "BasePart")
	if p then
		p.LocalTransparencyModifier = 0
		p.Transparency = value
	end
end

-- Gameplay state machine (only for monsters whose Motion defines States)
local runner = Motion.States and AnimLib.runner(Motion) or nil
local useReel = runner == nil
local lastAction = nil
local function syncState()
	local want = model:GetAttribute("AnimState")
	if runner == nil then
		return
	end
	if want == "Reel" then
		useReel = true
		return
	end
	useReel = false
	if typeof(want) == "string" and Motion.States[want] then
		runner.setBase(want)
	end
end
local function syncAction()
	local a = model:GetAttribute("AnimAction")
	if runner and typeof(a) == "string" and a ~= lastAction then
		lastAction = a
		local name = string.match(a, "^([^#]+)")
		if name and Motion.States[name] then
			useReel = false
			runner.play(name)
		end
	end
end
if runner then
	syncState()
	lastAction = model:GetAttribute("AnimAction")
	model:GetAttributeChangedSignal("AnimState"):Connect(syncState)
	model:GetAttributeChangedSignal("AnimAction"):Connect(syncAction)
end
local lastRootPos = root and root.Position
local moveSpeed = 0
local rate = 1

local warned = false
local function step(dt)
	if model:GetAttribute("AnimEnabled") == false then
		return
	end
	if not model:IsDescendantOf(workspace) then
		return
	end
	local speed = model:GetAttribute("AnimSpeed")
	if typeof(speed) ~= "number" then
		speed = 1
	end

	local cam = workspace.CurrentCamera
	local maxDist = model:GetAttribute("AnimDistance")
	if typeof(maxDist) ~= "number" then
		maxDist = 400
	end
	clock += dt * speed
	if cam and root and (cam.CFrame.Position - root.Position).Magnitude > maxDist then
		curCycleT = clock % cycle
		prevCycleT = curCycleT
		return
	end

	prevCycleT = curCycleT
	curCycleT = clock % cycle
	table.clear(pose)
	local ok, err
	if useReel then
		ok, err = pcall(Motion.Update, clock, pose, ctx)
	else
		-- stride matching: measure how fast the root really travels
		local scale0 = model:GetScale()
		if root and lastRootPos and dt > 0 then
			local d = root.Position - lastRootPos
			local v = Vector3.new(d.X, 0, d.Z).Magnitude / dt / scale0
			moveSpeed += (v - moveSpeed) * math.min(1, dt * 8)
		end
		lastRootPos = root and root.Position
		local st = Motion.States[(runner.current())]
		local want = 1
		if st and st.Speed and moveSpeed > 0.5 then
			want = math.clamp(moveSpeed / st.Speed, 0.6, 1.8)
		end
		rate += (want - rate) * math.min(1, dt * 6)
		ok, err = pcall(runner.step, dt * speed * rate, pose, ctx)
	end
	if not ok then
		if not warned then
			warned = true
			warn("[MonsterAnimator] " .. model.Name .. ": " .. tostring(err))
		end
		return
	end

	local scale = model:GetScale()
	for name, cf in pose do
		local m = motors[name]
		if m == nil then
			scan()
			m = motors[name]
		end
		if m then
			if scale ~= 1 then
				cf = cf.Rotation + cf.Position * scale
			end
			m.Transform = cf
		end
	end
end

local conn = RunService.PreSimulation:Connect(step)
model.Destroying:Connect(function()
	conn:Disconnect()
end)

-- Keep AnimLib referenced so it is clearly a dependency of this script.
local _ = AnimLib
