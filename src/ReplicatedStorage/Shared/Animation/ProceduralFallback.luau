--[[
	SCRIPT NAME:  ProceduralFallback
	SCRIPT TYPE:  ModuleScript (shared, prototyping aid)
	WHERE:        ReplicatedStorage/Shared/Animation/ProceduralFallback
	DEPENDENCIES: Shared.Util.R15

	PROTOTYPE-ONLY arm poses used while AnimationConfig still has placeholder
	ids. It gently rotates the R15 shoulder Motor6D.C0 values so you can see
	swing timing line up with markers during development.

	  * Only the R15 RightShoulder / LeftShoulder motors are touched.
	  * The Animator never writes C0, so this never fights real animations.
	  * Changes made on a client are local to that client (not replicated).
	  * Disabled entirely by AnimationConfig.UseProceduralFallback = false, and
	    never used for animations that have a real Id.
]]

local RunService = game:GetService("RunService")

local R15 = require(script.Parent.Parent.Util.R15)

type Key = { T: number, R: Vector3, L: Vector3? }
type Style = { Keys: { Key } }

-- Angles are degrees applied to shoulder C0 (X+ raises the arm forward/up).
local STYLES: { [string]: Style } = {
	Hold = { Keys = { { T = 0, R = Vector3.new(25, 0, 0) }, { T = 1, R = Vector3.new(25, 0, 0) } } },
	Carry = { Keys = { { T = 0, R = Vector3.new(60, 0, 8), L = Vector3.new(60, 0, -8) }, { T = 1, R = Vector3.new(60, 0, 8), L = Vector3.new(60, 0, -8) } } },
	Swing = { Keys = {
		{ T = 0, R = Vector3.new(25, 0, 0) },
		{ T = 0.4, R = Vector3.new(160, 0, 0) },
		{ T = 0.5, R = Vector3.new(40, 0, 0) },
		{ T = 1, R = Vector3.new(25, 0, 0) },
	} },
	HeavySwing = { Keys = {
		{ T = 0, R = Vector3.new(25, 0, 0) },
		{ T = 0.45, R = Vector3.new(175, 0, 0), L = Vector3.new(120, 0, 0) },
		{ T = 0.56, R = Vector3.new(30, 0, 0), L = Vector3.new(30, 0, 0) },
		{ T = 1, R = Vector3.new(25, 0, 0) },
	} },
	Dig = { Keys = {
		{ T = 0, R = Vector3.new(20, 0, 0), L = Vector3.new(20, 0, 0) },
		{ T = 0.35, R = Vector3.new(75, 0, 0), L = Vector3.new(75, 0, 0) },
		{ T = 0.55, R = Vector3.new(5, 0, 0), L = Vector3.new(5, 0, 0) },
		{ T = 1, R = Vector3.new(20, 0, 0), L = Vector3.new(20, 0, 0) },
	} },
	Till = { Keys = {
		{ T = 0, R = Vector3.new(20, 0, 0) },
		{ T = 0.4, R = Vector3.new(115, 0, 0) },
		{ T = 0.55, R = Vector3.new(15, 0, 0) },
		{ T = 1, R = Vector3.new(20, 0, 0) },
	} },
	Reach = { Keys = {
		{ T = 0, R = Vector3.new(0, 0, 0) },
		{ T = 0.5, R = Vector3.new(65, 0, 0) },
		{ T = 1, R = Vector3.new(0, 0, 0) },
	} },
	Pour = { Keys = {
		{ T = 0, R = Vector3.new(0, 0, 0) },
		{ T = 0.3, R = Vector3.new(70, 0, -20) },
		{ T = 1, R = Vector3.new(70, 0, -20) },
	} },
	Wave = { Keys = {
		{ T = 0, R = Vector3.new(0, 0, 0) },
		{ T = 0.2, R = Vector3.new(170, 0, -20) },
		{ T = 0.35, R = Vector3.new(170, 0, 20) },
		{ T = 0.5, R = Vector3.new(170, 0, -20) },
		{ T = 0.65, R = Vector3.new(170, 0, 20) },
		{ T = 0.8, R = Vector3.new(170, 0, 0) },
		{ T = 1, R = Vector3.new(0, 0, 0) },
	} },
	Cheer = { Keys = {
		{ T = 0, R = Vector3.new(0, 0, 0), L = Vector3.new(0, 0, 0) },
		{ T = 0.25, R = Vector3.new(170, 0, 20), L = Vector3.new(170, 0, -20) },
		{ T = 0.5, R = Vector3.new(150, 0, 10), L = Vector3.new(150, 0, -10) },
		{ T = 0.75, R = Vector3.new(170, 0, 20), L = Vector3.new(170, 0, -20) },
		{ T = 1, R = Vector3.new(0, 0, 0), L = Vector3.new(0, 0, 0) },
	} },
	Point = { Keys = {
		{ T = 0, R = Vector3.new(0, 0, 0) },
		{ T = 0.2, R = Vector3.new(90, 0, 0) },
		{ T = 0.8, R = Vector3.new(90, 0, 0) },
		{ T = 1, R = Vector3.new(0, 0, 0) },
	} },
	Cast = { Keys = {
		{ T = 0, R = Vector3.new(25, 0, 0) },
		{ T = 0.35, R = Vector3.new(165, 0, 0) },
		{ T = 0.5, R = Vector3.new(60, 0, 0) },
		{ T = 1, R = Vector3.new(40, 0, 0) },
	} },
	Reel = { Keys = {
		{ T = 0, R = Vector3.new(40, 0, 0), L = Vector3.new(35, 0, 0) },
		{ T = 0.5, R = Vector3.new(55, 0, 10), L = Vector3.new(45, 0, 0) },
		{ T = 1, R = Vector3.new(40, 0, 0), L = Vector3.new(35, 0, 0) },
	} },
}

type Entry = { Style: Style, Start: number, Duration: number, Looped: boolean }
type RigState = {
	Rig: Model,
	Right: Motor6D?,
	Left: Motor6D?,
	RightOriginal: CFrame?,
	LeftOriginal: CFrame?,
	Base: Entry?,
	Action: Entry?,
}

local ProceduralFallback = {}

local states: { [Model]: RigState } = {}
local stepConnection: RBXScriptConnection? = nil

local function sample(keys: { Key }, alpha: number, useLeft: boolean): Vector3
	local function valueOf(key: Key): Vector3
		if useLeft then
			return key.L or Vector3.zero
		end
		return key.R
	end
	if alpha <= keys[1].T then
		return valueOf(keys[1])
	end
	for i = 1, #keys - 1 do
		local a, b = keys[i], keys[i + 1]
		if alpha <= b.T then
			local span = math.max(b.T - a.T, 1e-3)
			local t = (alpha - a.T) / span
			t = t * t * (3 - 2 * t) -- smoothstep for less robotic motion
			return valueOf(a):Lerp(valueOf(b), t)
		end
	end
	return valueOf(keys[#keys])
end

local function toAngles(degrees: Vector3): CFrame
	return CFrame.Angles(math.rad(degrees.X), math.rad(degrees.Y), math.rad(degrees.Z))
end

local function restore(state: RigState)
	if state.Right and state.RightOriginal then
		state.Right.C0 = state.RightOriginal
	end
	if state.Left and state.LeftOriginal then
		state.Left.C0 = state.LeftOriginal
	end
end

local function step()
	local now = os.clock()
	for rig, state in states do
		if not rig.Parent then
			states[rig] = nil
			continue
		end
		local action = state.Action
		if action and not action.Looped and now - action.Start >= action.Duration then
			state.Action = nil
			action = nil
		end
		local entry = action or state.Base
		if not entry then
			restore(state)
			states[rig] = nil
			continue
		end
		local elapsed = now - entry.Start
		local alpha = if entry.Looped then (elapsed % entry.Duration) / entry.Duration else math.clamp(elapsed / entry.Duration, 0, 1)
		if state.Right and state.RightOriginal then
			state.Right.C0 = state.RightOriginal * toAngles(sample(entry.Style.Keys, alpha, false))
		end
		if state.Left and state.LeftOriginal then
			state.Left.C0 = state.LeftOriginal * toAngles(sample(entry.Style.Keys, alpha, true))
		end
	end
	if next(states) == nil and stepConnection then
		stepConnection:Disconnect()
		stepConnection = nil
	end
end

function ProceduralFallback.HasStyle(styleName: string?): boolean
	return styleName ~= nil and STYLES[styleName] ~= nil
end

-- Returns a stop function. Safe to call on any rig; no-ops for non-R15 rigs.
function ProceduralFallback.Play(rig: Model, styleName: string, duration: number, looped: boolean): () -> ()
	local style = STYLES[styleName]
	if not style or not R15.IsR15(rig) then
		return function() end
	end

	local state = states[rig]
	if not state then
		local right = R15.GetMotor(rig, "RightShoulder")
		local left = R15.GetMotor(rig, "LeftShoulder")
		local newState: RigState = {
			Rig = rig,
			Right = right,
			Left = left,
			RightOriginal = right and right.C0,
			LeftOriginal = left and left.C0,
		}
		states[rig] = newState
		state = newState
	end
	assert(state)

	local entry: Entry = { Style = style, Start = os.clock(), Duration = math.max(duration, 0.05), Looped = looped }
	if looped then
		state.Base = entry
	else
		state.Action = entry
	end

	if not stepConnection then
		stepConnection = RunService.Heartbeat:Connect(step)
	end

	return function()
		local current = states[rig]
		if not current then
			return
		end
		if current.Base == entry then
			current.Base = nil
		end
		if current.Action == entry then
			current.Action = nil
		end
	end
end

return ProceduralFallback
