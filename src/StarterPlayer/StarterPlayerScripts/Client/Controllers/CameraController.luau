--[[
	SCRIPT NAME:  CameraController
	SCRIPT TYPE:  ModuleScript (client controller)
	WHERE:        StarterPlayerScripts/Client/Controllers/CameraController
	DEPENDENCIES: Shared.Net, Shared.Config.GameConfig, Client.ClientState

	Keeps Roblox's default R15 third-person camera (it already handles mobile,
	gamepad and collisions well) and layers on top:
	  * zoom limits + field of view per MODE (Default / Build / Fishing),
	  * gentle, CAPPED camera shake that only runs while shaking (no permanent
	    per-frame work) and respects the player's CameraShake setting,
	  * a short FOV "punch" for big moments.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Net = require(Shared:WaitForChild("Net"))
local GameConfig = require(Shared.Config.GameConfig)
local ClientState = require(script.Parent.Parent.ClientState)

local SHAKE_BIND_NAME = "IslandCameraShake"

local MODES = {
	Default = { FieldOfView = GameConfig.Camera.DefaultFieldOfView },
	Build = { FieldOfView = GameConfig.Camera.DefaultFieldOfView + 6 }, -- Phase 3
	Fishing = { FieldOfView = GameConfig.Camera.DefaultFieldOfView - 6 }, -- Phase 5
}

local CameraController = {}

local mode = "Default"
local trauma = 0
local shakeDuration = 0.3
local shakeBound = false
local noiseSeed = math.random() * 1000

local function camera(): Camera?
	return workspace.CurrentCamera
end

local function stepShake(deltaTime: number)
	local cam = camera()
	if trauma <= 0 or not cam then
		RunService:UnbindFromRenderStep(SHAKE_BIND_NAME)
		shakeBound = false
		return
	end
	local time = os.clock() * 25
	local strength = trauma * trauma
	local pitch = math.noise(noiseSeed, time) * 0.035 * strength
	local yaw = math.noise(noiseSeed + 10, time) * 0.035 * strength
	local roll = math.noise(noiseSeed + 20, time) * 0.02 * strength
	-- Applied after the default camera script each frame, so it never accumulates.
	cam.CFrame *= CFrame.Angles(pitch, yaw, roll)
	trauma = math.max(0, trauma - deltaTime / math.max(shakeDuration, 0.05))
end

function CameraController.Shake(intensity: number, duration: number?)
	if ClientState.Get("Settings", "CameraShake") == false then
		return
	end
	trauma = math.clamp(math.max(trauma, intensity), 0, GameConfig.Camera.MaxShakeIntensity)
	shakeDuration = duration or 0.3
	if not shakeBound then
		shakeBound = true
		RunService:BindToRenderStep(SHAKE_BIND_NAME, Enum.RenderPriority.Camera.Value + 1, stepShake)
	end
end

function CameraController.SetMode(newMode: string)
	local def = MODES[newMode]
	local cam = camera()
	if not def or not cam then
		return
	end
	mode = newMode
	TweenService:Create(cam, TweenInfo.new(0.35, Enum.EasingStyle.Quad), { FieldOfView = def.FieldOfView }):Play()
end

function CameraController.GetMode(): string
	return mode
end

-- Short FOV pulse for level ups / unlocks.
function CameraController.Punch(amount: number?)
	local cam = camera()
	if not cam then
		return
	end
	local base = MODES[mode].FieldOfView
	cam.FieldOfView = base + (amount or 4)
	TweenService:Create(cam, TweenInfo.new(0.5, Enum.EasingStyle.Back), { FieldOfView = base }):Play()
end

function CameraController.Init()
	local player = Players.LocalPlayer
	player.CameraMinZoomDistance = GameConfig.Camera.MinZoom
	player.CameraMaxZoomDistance = GameConfig.Camera.MaxZoom
end

function CameraController.Start()
	local cam = camera()
	if cam then
		cam.FieldOfView = MODES.Default.FieldOfView
	end
	Net.OnClientEvent("CameraShake", function(intensity: number, duration: number?)
		if type(intensity) == "number" then
			CameraController.Shake(intensity, duration)
		end
	end)
end

return CameraController
