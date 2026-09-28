--[[
	SCRIPT NAME:  AnimationController
	SCRIPT TYPE:  ModuleScript (client controller)
	WHERE:        StarterPlayerScripts/Client/Controllers/AnimationController
	DEPENDENCIES: Shared.Animation.Keyframes, Shared.Config.AnimationConfig, Shared.Util.{AssetId, R15, Signal},
	              AudioController, VFXController, CameraController

	Animates EVERY rig this client can see — your character, other players,
	NPCs and animals — so everyone sees the same thing:

	  * MOVEMENT (Client/Animation/Locomotion): the game's own idle, walk,
	             run (sprint), jump, fall, landing squash, swim, climb and
	             sit animations. Roblox's default Animate script is replaced
	             (StarterCharacterScripts/Animate), so every joint is ours.
	             Other players' movement is read from their velocity, a
	             ground raycast and the water around them.
	  * HIT RECOIL: when a swing actually connects the server stamps the
	             character's "Recoil" attribute and the arms bounce back off
	             the tree / rock / construction site.
	  * ACTIONS  (chop, mine, hammer, till, plant, water, harvest, cast, reel,
	             milk, feed, pet, cheer, wave, dance...) come from the rig's
	             ActionAnim attribute ("Name;ServerStartTime;Speed;Seq") set by
	             the server. Keyframes (Shared/Animation/Keyframes) are sampled
	             at the synced server time and written to the R15 Motor6D
	             .Transform values every frame, blended over Roblox's own
	             walk/idle animation (legs keep walking unless the action
	             crouches or jumps).
	  * HOLD POSES (HoldPose attribute) keep your arms around whatever you hold.
	  * NPC rigs (tag "NPCRig") breathe and look around.
	  * ANIMALS (tag "Animal") walk, graze, chew, wag and flap from their
	             AnimalAnim attribute using their own joints.
	  * MARKER EFFECTS (AnimationConfig) — whoosh sounds / dust — fire at the
	             marker time on every client, positioned at that rig; your
	             own hits also kick the camera (CameraController.Kick).
	  * SWING TRAILS: during an action's Trail window the held tool's
	             SwingTrail is switched on (with a whoosh), on every client.

	Your own actions are PREDICTED: PlayLocal() starts instantly on click; the
	server's attribute for the same action simply continues it.
	If an AnimationConfig entry has a real uploaded Id, that animation is
	played through the rig's Animator instead of the keyframes.
]]

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Keyframes = require(Shared:WaitForChild("Animation"):WaitForChild("Keyframes"))
local AnimationConfig = require(Shared.Config.AnimationConfig)
local AssetId = require(Shared.Util.AssetId)
local Signal = require(Shared.Util.Signal)
local R15 = require(Shared.Util.R15)

local Controllers = script.Parent
local Locomotion = require(Controllers.Parent:WaitForChild("Animation"):WaitForChild("Locomotion"))
local AudioController = require(Controllers.AudioController)
local VFXController = require(Controllers.VFXController)
local CameraController = require(Controllers.CameraController)

local AnimationController = {}

AnimationController.CharacterReady = Signal.new() -- (character)
AnimationController.MarkerReached = Signal.new() -- (animationName, markerName, rig)

local MAX_DISTANCE = 180 -- rigs further than this from the camera are not animated
local FADE_IN = 0.08
local FADE_OUT = 0.16
local HOLD_FADE = 0.15

type ActionState = {
	Name: string,
	Def: any,
	Frames: any?,
	Joints: { string },
	Start: number, -- server time
	Speed: number,
	Seq: string,
	Duration: number,
	Fired: { [string]: boolean },
	Predicted: boolean,
	Track: AnimationTrack?,
}

type Rig = {
	Model: Model,
	Motors: { [string]: Motor6D },
	Action: ActionState?,
	Ending: { State: ActionState, EndedAt: number }?,
	HoldName: string?,
	HoldWeight: number,
	IsNPC: boolean,
	Tracks: { [string]: AnimationTrack },
	Connections: { RBXScriptConnection },
	TrailOn: boolean,
	Loco: Locomotion.State,
	RayParams: RaycastParams,
	WaterCheckAt: number,
	InWater: boolean,
	Recoil: { Start: number, Strength: number }?,
	LookYaw: number,
}

local rigs: { [Model]: Rig } = {}
local animals: { [Model]: { Motors: { [string]: Motor6D }, Phase: number } } = {}
local localCharacter: Model? = nil

local MOTOR_NAMES = {
	Root = true,
	Waist = true,
	Neck = true,
	RightShoulder = true,
	RightElbow = true,
	RightWrist = true,
	LeftShoulder = true,
	LeftElbow = true,
	LeftWrist = true,
	RightHip = true,
	RightKnee = true,
	RightAnkle = true,
	LeftHip = true,
	LeftKnee = true,
	LeftAnkle = true,
}

---------------------------------------------------------------------------
-- Sampling
---------------------------------------------------------------------------

local function ease(kind: string?, t: number): number
	if kind == "In" then
		return t * t
	elseif kind == "Out" then
		return 1 - (1 - t) * (1 - t)
	end
	return t * t * (3 - 2 * t) -- smooth in/out
end

local function toCFrame(value: { number }): CFrame
	local rotation = CFrame.Angles(math.rad(value[1] or 0), math.rad(value[2] or 0), math.rad(value[3] or 0))
	if value[4] or value[5] or value[6] then
		return CFrame.new(value[4] or 0, value[5] or 0, value[6] or 0) * rotation
	end
	return rotation
end

-- Pose of one joint at fraction t, interpolating between the keys that mention it.
local function sampleJoint(keys: { any }, joint: string, t: number): CFrame
	local before, after = nil, nil
	for _, key in keys do
		if key.Pose[joint] then
			if key.T <= t then
				before = key
			elseif not after then
				after = key
			end
		end
	end
	if not before and not after then
		return CFrame.identity
	end
	if not before then
		return toCFrame(after.Pose[joint])
	end
	if not after then
		return toCFrame(before.Pose[joint])
	end
	local span = math.max(after.T - before.T, 1e-3)
	local alpha = ease(after.Ease, math.clamp((t - before.T) / span, 0, 1))
	return toCFrame(before.Pose[joint]):Lerp(toCFrame(after.Pose[joint]), alpha)
end

---------------------------------------------------------------------------
-- Rig bookkeeping
---------------------------------------------------------------------------

local function findMotors(model: Model): { [string]: Motor6D }
	local motors = {}
	for _, descendant in model:GetDescendants() do
		if descendant:IsA("Motor6D") and MOTOR_NAMES[descendant.Name] then
			motors[descendant.Name] = descendant
		end
	end
	return motors
end

local function effectPosition(rig: Rig): Vector3?
	local root = R15.GetRootPart(rig.Model)
	if not root then
		return nil
	end
	return (root.CFrame * CFrame.new(0, -1.5, -3)).Position
end

local function fireMarkers(rig: Rig, state: ActionState, elapsed: number)
	for markerName, time in state.Def.Markers do
		if not state.Fired[markerName] and elapsed * state.Speed >= time then
			state.Fired[markerName] = true
			local effects = state.Def.MarkerEffects[markerName]
			if effects then
				local position = effectPosition(rig)
				if position then
					if effects.Sound then
						AudioController.PlayAt(effects.Sound, position)
					end
					if effects.VFX then
						VFXController.Play(effects.VFX, position)
					end
				end
				if rig.Model == localCharacter then
					if effects.Punch then
						CameraController.Kick(effects.Punch)
					end
					if effects.Shake then
						CameraController.Shake(effects.Shake, 0.25)
					end
				end
			end
			AnimationController.MarkerReached:Fire(state.Name, markerName, rig.Model)
		end
	end
end

local function stopTrack(state: ActionState?)
	if state and state.Track then
		state.Track:Stop(FADE_OUT)
	end
end

local function realTrack(rig: Rig, name: string, def: any): AnimationTrack?
	if AssetId.IsPlaceholder(def.Id) then
		return nil
	end
	local cached = rig.Tracks[name]
	if cached then
		return cached
	end
	local controller = rig.Model:FindFirstChildOfClass("Humanoid") or rig.Model:FindFirstChildOfClass("AnimationController")
	local animator = controller and controller:FindFirstChildOfClass("Animator")
	if not animator then
		return nil
	end
	local animation = Instance.new("Animation")
	animation.AnimationId = def.Id
	local ok, track = pcall(animator.LoadAnimation, animator, animation)
	if not ok or not track then
		return nil
	end
	track.Looped = def.Looped
	local priority = (Enum.AnimationPriority :: any)[def.Priority]
	if priority then
		track.Priority = priority
	end
	rig.Tracks[name] = track
	return track
end

local function startAction(rig: Rig, name: string, start: number, speed: number, seq: string, predicted: boolean)
	local def = AnimationConfig.Get(name)
	if not def then
		return
	end
	local current = rig.Action
	if current and current.Name == name and (current.Predicted or current.Seq == seq) and math.abs(current.Start - start) < 0.6 then
		-- The server confirmed what we already predicted: keep playing smoothly.
		current.Predicted = false
		current.Seq = seq
		return
	end
	if current then
		rig.Ending = { State = current, EndedAt = os.clock() }
		stopTrack(current)
	end
	local frames = Keyframes.Actions[name]
	local repeatCount = def.Repeat or 1
	local state: ActionState = {
		Name = name,
		Def = def,
		Frames = frames,
		Joints = if frames then Keyframes.JointsOf(frames) else {},
		Start = start,
		Speed = speed,
		Seq = seq,
		Duration = if def.Looped then math.huge else def.Length * repeatCount / speed,
		Fired = {},
		Predicted = predicted,
		Track = nil,
	}
	local track = realTrack(rig, name, def)
	if track then
		track:Play(def.FadeIn, 1, speed)
		state.Track = track
	end
	rig.Action = state
end

local function endAction(rig: Rig)
	local current = rig.Action
	if current then
		rig.Ending = { State = current, EndedAt = os.clock() }
		stopTrack(current)
		rig.Action = nil
	end
end

local function readAction(rig: Rig)
	local value = rig.Model:GetAttribute("ActionAnim")
	if type(value) ~= "string" or value == "" then
		endAction(rig)
		return
	end
	local name, start, speed, seq = string.match(value, "^([^;]+);([%d%.]+);([%d%.]+);(%d+)$")
	if not name then
		return
	end
	local startTime = tonumber(start) or workspace:GetServerTimeNow()
	local def = AnimationConfig.Get(name)
	-- Ignore actions that already finished before we saw them (late join / streaming).
	if def and not def.Looped and workspace:GetServerTimeNow() - startTime > def.Length * (def.Repeat or 1) / (tonumber(speed) or 1) then
		return
	end
	startAction(rig, name, startTime, tonumber(speed) or 1, seq :: string, false)
end

local function addRig(model: Model, isNPC: boolean)
	if rigs[model] then
		return
	end
	local rig: Rig = {
		Model = model,
		Motors = findMotors(model),
		Action = nil,
		Ending = nil,
		HoldName = nil,
		HoldWeight = 0,
		IsNPC = isNPC,
		Tracks = {},
		Connections = {},
		TrailOn = false,
		Loco = Locomotion.NewState(),
		RayParams = RaycastParams.new(),
		WaterCheckAt = 0,
		InWater = false,
		Recoil = nil,
		LookYaw = 0,
	}
	rig.RayParams.FilterType = Enum.RaycastFilterType.Exclude
	rig.RayParams.FilterDescendantsInstances = { model }
	rig.RayParams.IgnoreWater = true
	table.insert(rig.Connections, model:GetAttributeChangedSignal("Recoil"):Connect(function()
		local value = model:GetAttribute("Recoil")
		local strength = if type(value) == "string" then tonumber(string.match(value, "^([%d%.]+);")) else nil
		if strength then
			rig.Recoil = { Start = os.clock(), Strength = math.clamp(strength, 0, 2) }
		end
	end))
	rigs[model] = rig
	table.insert(rig.Connections, model:GetAttributeChangedSignal("ActionAnim"):Connect(function()
		readAction(rig)
	end))
	table.insert(rig.Connections, model.DescendantAdded:Connect(function(descendant)
		if descendant:IsA("Motor6D") and MOTOR_NAMES[descendant.Name] then
			rig.Motors[descendant.Name] = descendant
		end
	end))
	table.insert(rig.Connections, model.AncestryChanged:Connect(function()
		if not model:IsDescendantOf(workspace) then
			for _, connection in rig.Connections do
				connection:Disconnect()
			end
			rigs[model] = nil
		end
	end))
	readAction(rig)
end

---------------------------------------------------------------------------
-- Per-frame application
---------------------------------------------------------------------------

local function inWater(position: Vector3): boolean
	local region = Region3.new(position - Vector3.new(1, 2, 1), position + Vector3.new(1, 1, 1)):ExpandToGrid(4)
	local ok, materials, occupancies = pcall(function()
		return workspace.Terrain:ReadVoxels(region, 4)
	end)
	if not ok or not materials then
		return false
	end
	for x, plane in materials do
		for y, row in plane do
			for z, material in row do
				if material == Enum.Material.Water and occupancies[x][y][z] > 0.5 then
					return true
				end
			end
		end
	end
	return false
end

-- What the character is doing right now (for the movement animations).
local function locomotionInput(rig: Rig, root: BasePart, humanoid: Humanoid, clock: number, dt: number): Locomotion.Input
	local anchored = root.Anchored
	local velocity = if anchored then Vector3.zero else root.AssemblyLinearVelocity
	local grounded, swimming, climbing = true, false, false
	if rig.Model == localCharacter then
		local state = humanoid:GetState()
		swimming = state == Enum.HumanoidStateType.Swimming
		climbing = state == Enum.HumanoidStateType.Climbing
		grounded = humanoid.FloorMaterial ~= Enum.Material.Air
	elseif not anchored then
		local reach = humanoid.HipHeight + root.Size.Y / 2 + 0.8
		grounded = workspace:Raycast(root.Position, Vector3.new(0, -reach, 0), rig.RayParams) ~= nil
		if clock >= rig.WaterCheckAt then
			rig.WaterCheckAt = clock + 0.25
			rig.InWater = inWater(root.Position)
		end
		swimming = rig.InWater and not grounded
	end
	return {
		Speed = Vector3.new(velocity.X, 0, velocity.Z).Magnitude,
		VerticalSpeed = velocity.Y,
		TurnRate = if anchored then 0 else root.AssemblyAngularVelocity.Y,
		Grounded = grounded,
		Swimming = swimming,
		Climbing = climbing,
		Sitting = humanoid.Sit,
		Clock = clock,
		Dt = dt,
	}
end

local function footPosition(root: BasePart, humanoid: Humanoid): Vector3
	return root.Position - Vector3.new(0, humanoid.HipHeight + root.Size.Y / 2 - 0.2, 0)
end

local function applyRig(rig: Rig, now: number, clock: number, dt: number)
	local model = rig.Model
	local motors = rig.Motors
	-- Hold pose (fades in/out when you equip / unequip).
	local holdName = model:GetAttribute("HoldPose")
	local hold = if type(holdName) == "string" then Keyframes.Holds[holdName] else nil
	if hold then
		rig.HoldName = holdName :: string
		rig.HoldWeight = math.min(1, rig.HoldWeight + dt / HOLD_FADE)
	else
		rig.HoldWeight = math.max(0, rig.HoldWeight - dt / HOLD_FADE)
	end
	local activeHold = if rig.HoldName then Keyframes.Holds[rig.HoldName] else nil
	if rig.HoldWeight <= 0 then
		rig.HoldName = nil
	end

	local action = rig.Action
	if action and now - action.Start >= action.Duration then
		rig.Ending = { State = action, EndedAt = clock }
		rig.Action = nil
		action = nil
	end

	local targets: { [string]: CFrame } = {}
	local weights: { [string]: number } = {}

	-- Base layer: our own movement animations on every joint.
	local humanoid = model:FindFirstChildOfClass("Humanoid")
	local root = model:FindFirstChild("HumanoidRootPart")
	if humanoid and root and root:IsA("BasePart") then
		local pose, landed, stepped = Locomotion.Update(rig.Loco, locomotionInput(rig, root, humanoid, clock, dt))
		for joint, value in pose do
			targets[joint] = toCFrame(value)
			weights[joint] = 1
		end
		-- Cartoon dust: a puff on hard landings and under sprinting feet.
		if landed and landed > 0.35 then
			VFXController.Play("Puff", footPosition(root, humanoid), { Scale = 0.25 + 0.35 * landed, Count = 5 })
		elseif stepped and rig.Loco.Run > 0.6 then
			VFXController.Play("Puff", footPosition(root, humanoid), { Scale = 0.2, Count = 2 })
		end
	end

	if activeHold and rig.HoldWeight > 0 then
		local sway = math.sin(clock * 1.6) * (activeHold.Sway or 0)
		for joint, value in activeHold.Pose do
			local cf = toCFrame(value)
			if joint == "RightShoulder" then
				cf = CFrame.Angles(math.rad(sway), 0, 0) * cf
			end
			local base = targets[joint]
			targets[joint] = if base then base:Lerp(cf, rig.HoldWeight) else cf
			weights[joint] = if base then 1 else rig.HoldWeight
		end
	end

	if rig.IsNPC and not action then
		-- NPCs can name their own looping idle (e.g. Mia's "MiaIdle").
		local idleName = model:GetAttribute("IdleAnim")
		local custom = if type(idleName) == "string" then Keyframes.Actions[idleName] else nil
		local idleDef = if custom and type(idleName) == "string" then AnimationConfig.Get(idleName) else nil
		local idle = custom or Keyframes.NPCIdle
		local t = (clock / (if idleDef then idleDef.Length else 6)) % 1
		for _, joint in Keyframes.JointsOf(idle) do
			targets[joint] = sampleJoint(idle.Keys, joint, t)
			weights[joint] = 1
		end
	end

	local function applyAction(state: ActionState, weight: number)
		if not state.Frames or state.Track then
			return
		end
		local elapsed = math.max(0, now - state.Start)
		local length = state.Def.Length / state.Speed
		local t = if state.Def.Looped or (state.Def.Repeat or 1) > 1 then (elapsed / length) % 1 else math.clamp(elapsed / length, 0, 1)
		local legs = state.Frames.Legs == true
		for _, joint in state.Joints do
			if legs or not (joint == "Root" or string.find(joint, "Hip") or string.find(joint, "Knee") or string.find(joint, "Ankle")) then
				local target = sampleJoint(state.Frames.Keys, joint, t)
				local existing = targets[joint]
				if existing and weights[joint] then
					targets[joint] = existing:Lerp(target, weight)
					weights[joint] = math.max(weights[joint], weight)
				else
					targets[joint] = target
					weights[joint] = weight
				end
			end
		end
	end

	local ending = rig.Ending
	if ending then
		local fade = 1 - (clock - ending.EndedAt) / FADE_OUT
		if fade <= 0 then
			rig.Ending = nil
		else
			applyAction(ending.State, fade)
		end
	end
	if action then
		local elapsed = now - action.Start
		fireMarkers(rig, action, elapsed)
		if action.Def.Looped and elapsed * action.Speed >= action.Def.Length then
			-- Looped actions re-fire their markers every cycle.
			action.Start += action.Def.Length / action.Speed
			table.clear(action.Fired)
		end
		applyAction(action, math.clamp(elapsed / FADE_IN, 0, 1))
	end

	-- NPCs turn their head and shoulders towards a player (LookAt = UserId).
	local lookAt = model:GetAttribute("LookAt")
	local wantedYaw = 0
	if type(lookAt) == "number" and lookAt ~= 0 then
		local target = Players:GetPlayerByUserId(lookAt)
		local targetRoot = target and target.Character and target.Character:FindFirstChild("HumanoidRootPart")
		local selfRoot = model:FindFirstChild("HumanoidRootPart")
		if targetRoot and targetRoot:IsA("BasePart") and selfRoot and selfRoot:IsA("BasePart") then
			local relative = selfRoot.CFrame:PointToObjectSpace(targetRoot.Position)
			wantedYaw = math.clamp(math.deg(math.atan2(-relative.X, -relative.Z)), -80, 80)
		end
	end
	rig.LookYaw += (wantedYaw - rig.LookYaw) * math.min(1, dt * 5)
	if math.abs(rig.LookYaw) > 0.5 then
		local waist = targets.Waist
		if waist then
			targets.Waist = waist * CFrame.Angles(0, math.rad(rig.LookYaw * 0.35), 0)
		end
		local neck = targets.Neck
		if neck then
			targets.Neck = neck * CFrame.Angles(0, math.rad(rig.LookYaw * 0.55), 0)
		end
	end

	-- Hit recoil: the arms bounce back off whatever the swing hit.
	local recoil = rig.Recoil
	if recoil then
		local t = clock - recoil.Start
		if t > 0.35 then
			rig.Recoil = nil
		else
			local a = recoil.Strength * math.exp(-t * 11) * math.cos(t * 28)
			local function kick(joint: string, degrees: number)
				local current = targets[joint]
				if current then
					targets[joint] = current * CFrame.Angles(math.rad(degrees * a), 0, 0)
					weights[joint] = 1
				end
			end
			kick("RightShoulder", 16)
			kick("RightElbow", 20)
			kick("LeftShoulder", 10)
			kick("Waist", 6)
			kick("Neck", 8)
		end
	end

	-- Swing trail on the held tool during the action's Trail window.
	local trailOn = false
	if action and action.Def.Trail then
		local fraction = (now - action.Start) * action.Speed / action.Def.Length
		trailOn = fraction >= action.Def.Trail[1] and fraction <= action.Def.Trail[2]
	end
	if trailOn ~= rig.TrailOn then
		rig.TrailOn = trailOn
		local tool = model:FindFirstChild("EquippedTool")
		local trail = tool and tool:FindFirstChild("SwingTrail", true)
		if trail and trail:IsA("Trail") then
			trail.Enabled = trailOn
			if trailOn then
				local rootPart = R15.GetRootPart(model)
				if rootPart then
					AudioController.PlayAt("ToolSwing", rootPart.Position)
				end
			end
		end
	end

	for joint, target in targets do
		local motor = motors[joint]
		if motor and motor.Parent then
			local weight = weights[joint] or 1
			motor.Transform = if weight >= 0.999 then target else motor.Transform:Lerp(target, weight)
		end
	end
end

local function applyAnimal(model: Model, data: { Motors: { [string]: Motor6D }, Phase: number }, clock: number)
	local state = model:GetAttribute("AnimalAnim") or "Idle"
	local t = clock + data.Phase
	local walking = state == "Walk"
	local stride = if walking then math.sin(t * 7) * 28 else 0
	local motors = data.Motors
	local function set(name: string, cf: CFrame)
		local motor = motors[name]
		if motor and motor.Parent then
			motor.Transform = cf
		end
	end
	set("LegFL", CFrame.Angles(math.rad(stride), 0, 0))
	set("LegBR", CFrame.Angles(math.rad(stride), 0, 0))
	set("LegFR", CFrame.Angles(math.rad(-stride), 0, 0))
	set("LegBL", CFrame.Angles(math.rad(-stride), 0, 0))
	set("LegL", CFrame.Angles(math.rad(stride * 1.2), 0, 0))
	set("LegR", CFrame.Angles(math.rad(-stride * 1.2), 0, 0))

	local head: CFrame
	if state == "Eat" then
		head = CFrame.Angles(math.rad(-38 + math.sin(t * 9) * 6), 0, 0)
	elseif state == "Happy" then
		head = CFrame.Angles(math.rad(math.sin(t * 12) * 10), math.rad(math.sin(t * 6) * 12), 0)
	elseif walking then
		head = CFrame.Angles(math.rad(math.sin(t * 14) * 5), 0, 0)
	else
		-- Idle: slow look-around, the odd peck / graze.
		local graze = math.max(0, math.sin(t * 0.7)) ^ 6
		head = CFrame.Angles(math.rad(-40 * graze), math.rad(math.sin(t * 0.45) * 18), 0)
	end
	set("Head", head)

	local wagSpeed = if state == "Happy" then 16 elseif walking then 8 else 3
	set("Tail", CFrame.Angles(0, math.rad(math.sin(t * wagSpeed) * (if state == "Happy" then 32 else 16)), 0))
	local flap = if state == "Happy" then math.abs(math.sin(t * 18)) * 55 elseif walking then math.abs(math.sin(t * 7)) * 8 else 0
	set("WingL", CFrame.Angles(0, 0, math.rad(-flap)))
	set("WingR", CFrame.Angles(0, 0, math.rad(flap)))
end

local function step(dt: number)
	local camera = workspace.CurrentCamera
	if not camera then
		return
	end
	local eye = camera.CFrame.Position
	local now = workspace:GetServerTimeNow()
	local clock = os.clock()
	for model, rig in rigs do
		local root = model.PrimaryPart or model:FindFirstChild("HumanoidRootPart")
		if root and root:IsA("BasePart") and (root.Position - eye).Magnitude <= MAX_DISTANCE then
			applyRig(rig, now, clock, dt)
		end
	end
	for model, data in animals do
		local body = model.PrimaryPart
		if body and (body.Position - eye).Magnitude <= MAX_DISTANCE then
			applyAnimal(model, data, clock)
		end
	end
end

---------------------------------------------------------------------------
-- Public API
---------------------------------------------------------------------------

local lastVariant: { [string]: number } = {}

-- Picks one of an action's swing variants at random (never the same one
-- twice in a row). Returns (animationName, index); send the index to the
-- server so everyone sees the same swing.
function AnimationController.PickVariant(base: string): (string, number)
	local count = AnimationConfig.VariantCount(base)
	if count <= 1 then
		return base, 1
	end
	local index = math.random(1, count)
	if index == lastVariant[base] then
		index = index % count + 1
	end
	lastVariant[base] = index
	return AnimationConfig.Variant(base, index), index
end

-- Starts an action on YOUR character right away (the server will confirm it).
function AnimationController.PlayLocal(name: string, speed: number?)
	local character = localCharacter
	local rig = character and rigs[character]
	if rig then
		startAction(rig, name, workspace:GetServerTimeNow(), speed or 1, "local", true)
	end
end

function AnimationController.IsPlaying(name: string): boolean
	local rig = localCharacter and rigs[localCharacter]
	return rig ~= nil and rig.Action ~= nil and rig.Action.Name == name
end

local function watchCharacter(character: Model)
	task.spawn(function()
		local humanoid = character:WaitForChild("Humanoid", 10)
		if not humanoid or not character.Parent then
			return
		end
		character:WaitForChild("UpperTorso", 5)
		addRig(character, false)
	end)
end

local function watchPlayer(player: Player)
	if player.Character then
		watchCharacter(player.Character)
	end
	player.CharacterAdded:Connect(watchCharacter)
end

local function addAnimal(model: Instance)
	if not model:IsA("Model") or animals[model] then
		return
	end
	local motors = {}
	local function scan(descendant: Instance)
		if descendant:IsA("Motor6D") then
			motors[descendant.Name] = descendant
		end
	end
	for _, descendant in model:GetDescendants() do
		scan(descendant)
	end
	animals[model] = { Motors = motors, Phase = math.random() * 10 }
	model.DescendantAdded:Connect(scan)
	model.AncestryChanged:Connect(function()
		if not model:IsDescendantOf(workspace) then
			animals[model] = nil
		end
	end)
end

function AnimationController.Start()
	local player = Players.LocalPlayer
	local function onCharacter(character: Model)
		localCharacter = character
		task.spawn(function()
			local humanoid = character:WaitForChild("Humanoid", 10)
			if humanoid then
				humanoid:WaitForChild("Animator", 10)
				AnimationController.CharacterReady:Fire(character)
			end
		end)
	end
	player.CharacterAdded:Connect(onCharacter)
	if player.Character then
		onCharacter(player.Character)
	end

	for _, other in Players:GetPlayers() do
		watchPlayer(other)
	end
	Players.PlayerAdded:Connect(watchPlayer)

	for _, npc in CollectionService:GetTagged("NPCRig") do
		if npc:IsA("Model") then
			addRig(npc, true)
		end
	end
	CollectionService:GetInstanceAddedSignal("NPCRig"):Connect(function(npc)
		if npc:IsA("Model") then
			addRig(npc, true)
		end
	end)
	for _, model in CollectionService:GetTagged("Animal") do
		addAnimal(model)
	end
	CollectionService:GetInstanceAddedSignal("Animal"):Connect(addAnimal)

	-- After the Animator has written this frame's poses, before physics/render.
	RunService.Stepped:Connect(function(_time: number, dt: number)
		step(dt)
	end)
end

return AnimationController
