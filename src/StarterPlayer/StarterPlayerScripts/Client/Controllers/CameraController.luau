--[[
	SCRIPT NAME:  CameraController
	SCRIPT TYPE:  ModuleScript (client controller)
	WHERE:        StarterPlayerScripts/Client/Controllers/CameraController
	DEPENDENCIES: Shared.Net, Shared.Config.GameConfig, Client.ClientState

	Keeps Roblox's default R15 third-person camera (it already handles mobile,
	gamepad and collisions well) and layers CARTOON camera feel on top:

	  Kick(strength)          a springy nod on every hit you land (pitch
	                          down + a little roll + a tiny zoom-in squash)
	  Wobble(strength, time)  a wobbly, bouncy roll/pitch for big moments:
	                          a tree crashing down, a rock shattering,
	                          new land rising
	  Shake(strength, time)   classic noisy shake (capped)
	  Punch(amount)           a springy field-of-view pop (level ups)
	  SetMode(mode)           Default / Build / Fishing field of view

	Everything runs through one damped spring. IMPORTANT: Roblox's camera
	script reads the camera's current rotation every frame, so an offset
	left on the camera would be fed back in and ADD UP (the view slowly
	tipped towards the ground). We therefore remove last frame's offset
	just BEFORE the camera script runs and add the new one just AFTER it:
	the player's own camera angle is never changed. Rotation effects respect
	the "Camera shake" setting; FOV pops always play.

	Sprinting widens the field of view a little (SetSprint).
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Net = require(Shared:WaitForChild("Net"))
local GameConfig = require(Shared.Config.GameConfig)
local ClientState = require(script.Parent.Parent.ClientState)

local BIND_UNDO = "IslandCameraJuiceUndo"
local BIND_APPLY = "IslandCameraJuice"

local MODES = {
	Default = { FieldOfView = GameConfig.Camera.DefaultFieldOfView },
	Build = { FieldOfView = GameConfig.Camera.DefaultFieldOfView + 6 },
	Fishing = { FieldOfView = GameConfig.Camera.DefaultFieldOfView - 6 },
}

-- Spring tuning: stiff + light damping = bouncy, cartoony.
local STIFFNESS = 170
local DAMPING = 11
local FOV_STIFFNESS = 120
local FOV_DAMPING = 9
local MAX_ANGLE = math.rad(4.5)
local SPRINT_FOV = 7

local CameraController = {}

local mode = "Default"
local baseFov = GameConfig.Camera.DefaultFieldOfView
local targetFov = baseFov
-- Spring state: X = pitch, Y = yaw, Z = roll (radians).
local angle = Vector3.zero
local angleVelocity = Vector3.zero
local fovOffset, fovVelocity = 0, 0
-- Noise shake.
local trauma, traumaDuration = 0, 0.3
local noiseSeed = math.random() * 1000
-- Wobbles: several can overlap (a tree falling while you mine).
type Wobble = { Start: number, Duration: number, Strength: number, Phase: number }
local wobbles: { Wobble } = {}
-- The rotation offset currently applied on top of the camera script's result.
local appliedOffset = CFrame.identity
local sprinting = false

local function shakeAllowed(): boolean
	return ClientState.Get("Settings", "CameraShake") ~= false
end

-- Before the camera script: take last frame's offset back off.
local function undo()
	local cam = workspace.CurrentCamera
	if cam and appliedOffset ~= CFrame.identity then
		cam.CFrame *= appliedOffset:Inverse()
	end
	appliedOffset = CFrame.identity
end

local function step(dt: number)
	local cam = workspace.CurrentCamera
	if not cam then
		return
	end
	dt = math.min(dt, 1 / 20)

	-- Base field of view eases towards the mode's FOV (+ a bit while sprinting).
	local wanted = targetFov + (if sprinting then SPRINT_FOV else 0)
	baseFov += (wanted - baseFov) * math.min(1, dt * 8)

	-- Springs.
	local accel = -angle * STIFFNESS - angleVelocity * DAMPING
	angleVelocity += accel * dt
	angle += angleVelocity * dt
	local fovAccel = -fovOffset * FOV_STIFFNESS - fovVelocity * FOV_DAMPING
	fovVelocity += fovAccel * dt
	fovOffset += fovVelocity * dt

	local pitch, yaw, roll = angle.X, angle.Y, angle.Z

	-- Wobbles: decaying sine on roll + pitch (cartoon "boing").
	local now = os.clock()
	for index = #wobbles, 1, -1 do
		local wobble = wobbles[index]
		local t = now - wobble.Start
		if t >= wobble.Duration then
			table.remove(wobbles, index)
		else
			local decay = (1 - t / wobble.Duration) ^ 2
			local s = wobble.Strength * decay
			roll += math.sin(t * 17 + wobble.Phase) * 0.032 * s
			pitch += math.sin(t * 23 + wobble.Phase * 2) * 0.014 * s
			yaw += math.sin(t * 11 + wobble.Phase) * 0.008 * s
		end
	end

	-- Noise shake.
	if trauma > 0 then
		local time = now * 25
		local strength = trauma * trauma
		pitch += math.noise(noiseSeed, time) * 0.025 * strength
		yaw += math.noise(noiseSeed + 10, time) * 0.025 * strength
		roll += math.noise(noiseSeed + 20, time) * 0.015 * strength
		trauma = math.max(0, trauma - dt / math.max(traumaDuration, 0.05))
	end

	pitch = math.clamp(pitch, -MAX_ANGLE, MAX_ANGLE)
	yaw = math.clamp(yaw, -MAX_ANGLE, MAX_ANGLE)
	roll = math.clamp(roll, -MAX_ANGLE, MAX_ANGLE)
	if math.abs(pitch) + math.abs(yaw) + math.abs(roll) > 1e-5 then
		appliedOffset = CFrame.Angles(pitch, yaw, roll)
		cam.CFrame *= appliedOffset
	end
	cam.FieldOfView = math.clamp(baseFov + fovOffset, 30, 110)
end

-- A springy nod when YOUR hit lands.
function CameraController.Kick(strength: number?)
	local s = math.clamp(strength or 1, 0, 3)
	fovVelocity -= 18 * s -- quick little zoom-in squash
	if not shakeAllowed() then
		return
	end
	local side = if math.random() < 0.5 then -1 else 1
	angleVelocity += Vector3.new(-0.3 * s, 0.06 * s * side, 0.22 * s * side)
end

-- A decaying, bouncy wobble (tree falls, rocks shatter, land rises).
function CameraController.Wobble(strength: number, duration: number?)
	if not shakeAllowed() then
		return
	end
	table.insert(wobbles, {
		Start = os.clock(),
		Duration = math.clamp(duration or 0.8, 0.1, 3),
		Strength = math.clamp(strength, 0, 2),
		Phase = math.random() * math.pi * 2,
	})
	if #wobbles > 4 then
		table.remove(wobbles, 1)
	end
	angleVelocity += Vector3.new(-0.2 * strength, 0, 0)
end

function CameraController.Shake(intensity: number, duration: number?)
	if not shakeAllowed() then
		return
	end
	trauma = math.clamp(math.max(trauma, intensity), 0, GameConfig.Camera.MaxShakeIntensity)
	traumaDuration = duration or 0.3
end

function CameraController.SetMode(newMode: string)
	local def = MODES[newMode]
	if not def then
		return
	end
	mode = newMode
	targetFov = def.FieldOfView
end

function CameraController.GetMode(): string
	return mode
end

-- Slightly wider view while sprinting (speed feel).
function CameraController.SetSprint(isSprinting: boolean)
	sprinting = isSprinting
end

-- Springy FOV pop for level ups / unlocks.
function CameraController.Punch(amount: number?)
	fovVelocity += 55 * (amount or 4) / 4
end

function CameraController.Init()
	local player = Players.LocalPlayer
	player.CameraMinZoomDistance = GameConfig.Camera.MinZoom
	player.CameraMaxZoomDistance = GameConfig.Camera.MaxZoom
end

function CameraController.Start()
	-- Undo just before the default camera script, re-apply just after it.
	RunService:BindToRenderStep(BIND_UNDO, Enum.RenderPriority.Camera.Value - 1, undo)
	RunService:BindToRenderStep(BIND_APPLY, Enum.RenderPriority.Camera.Value + 1, step)
	Net.OnClientEvent("CameraShake", function(intensity: any, duration: any, style: any)
		if type(intensity) ~= "number" then
			return
		end
		local time = if type(duration) == "number" then duration else nil
		if style == "Wobble" then
			CameraController.Wobble(intensity, time)
		elseif style == "Kick" then
			CameraController.Kick(intensity)
		else
			CameraController.Shake(intensity, time)
		end
	end)
end

return CameraController
