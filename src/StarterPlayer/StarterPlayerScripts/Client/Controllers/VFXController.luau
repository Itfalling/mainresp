--[[
	SCRIPT NAME:  VFXController
	SCRIPT TYPE:  ModuleScript (client controller)
	WHERE:        StarterPlayerScripts/Client/Controllers/VFXController
	DEPENDENCIES: Shared.Net, Shared.Config.VFXConfig

	Renders VFXConfig effects locally with pooled emitters/parts (spec §79):
	no Instances are created per effect after warm-up, effects far from the
	camera are skipped, and everything uses the engine's default particle
	texture so it works without uploaded art.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Net = require(Shared:WaitForChild("Net"))
local VFXConfig = require(Shared.Config.VFXConfig)

local BURST_POOL = 10
local RING_POOL = 6

type BurstEmitter = { Part: Part, Emitter: ParticleEmitter, BusyUntil: number }
type Ring = { Part: Part, BusyUntil: number }

local VFXController = {}

local bursts: { BurstEmitter } = {}
local rings: { Ring } = {}
local folder: Folder

local function newAnchorPart(name: string): Part
	local part = Instance.new("Part")
	part.Name = name
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.CastShadow = false
	part.Transparency = 1
	part.Size = Vector3.one
	part.Parent = folder
	return part
end

local function acquire(pool: { any }): any
	local now = os.clock()
	local oldest = nil
	for _, item in pool do
		if item.BusyUntil <= now then
			return item
		end
		if not oldest or item.BusyUntil < oldest.BusyUntil then
			oldest = item
		end
	end
	return oldest -- steal the oldest rather than allocate
end

local function isVisible(position: Vector3): boolean
	local camera = workspace.CurrentCamera
	return camera ~= nil and (camera.CFrame.Position - position).Magnitude <= VFXConfig.MaxDistance
end

local function playBurst(def: any, position: Vector3)
	local item = acquire(bursts)
	if not item then
		return
	end
	local emitter = item.Emitter
	item.Part.CFrame = CFrame.new(position)
	emitter.Color = ColorSequence.new(def.Color)
	emitter.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, def.Size),
		NumberSequenceKeypoint.new(1, 0),
	})
	emitter.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(0.7, 0.1),
		NumberSequenceKeypoint.new(1, 1),
	})
	emitter.Lifetime = NumberRange.new(def.Lifetime * 0.7, def.Lifetime)
	emitter.Speed = NumberRange.new(def.Speed * 0.6, def.Speed)
	emitter.SpreadAngle = Vector2.new(def.Spread, def.Spread)
	emitter.Acceleration = def.Acceleration or Vector3.zero
	emitter.LightEmission = def.LightEmission or 0
	emitter:Emit(def.Count)
	item.BusyUntil = os.clock() + def.Lifetime + 0.1
end

local function playRing(def: any, position: Vector3)
	local item = acquire(rings)
	if not item then
		return
	end
	local part = item.Part
	part.Color = def.Color
	part.Transparency = 0.2
	part.Size = Vector3.new(def.Height, def.StartSize, def.StartSize)
	part.CFrame = CFrame.new(position) * CFrame.Angles(0, 0, math.rad(90))
	TweenService:Create(part, TweenInfo.new(def.Duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = Vector3.new(def.Height * 0.3, def.EndSize, def.EndSize),
		Transparency = 1,
	}):Play()
	item.BusyUntil = os.clock() + def.Duration
end

function VFXController.Play(effectName: string, position: Vector3)
	local def = VFXConfig.Effects[effectName]
	if not def then
		warn("[VFX] Unknown effect '" .. tostring(effectName) .. "'")
		return
	end
	if not isVisible(position) then
		return
	end
	if def.Type == "Burst" then
		playBurst(def, position)
	elseif def.Type == "Ring" then
		playRing(def, position)
	end
end

function VFXController.Init()
	folder = Instance.new("Folder")
	folder.Name = "ClientEffects"
	folder.Parent = workspace

	for _ = 1, BURST_POOL do
		local part = newAnchorPart("BurstAnchor")
		local emitter = Instance.new("ParticleEmitter")
		emitter.Enabled = false
		emitter.Rate = 0
		emitter.Drag = 2
		emitter.RotSpeed = NumberRange.new(-90, 90)
		emitter.Parent = part
		table.insert(bursts, { Part = part, Emitter = emitter, BusyUntil = 0 })
	end
	for _ = 1, RING_POOL do
		local part = newAnchorPart("Ring")
		part.Shape = Enum.PartType.Cylinder
		part.Material = Enum.Material.Neon
		part.Transparency = 1
		table.insert(rings, { Part = part, BusyUntil = 0 })
	end
end

function VFXController.Start()
	Net.OnClientEvent("PlayVFX", function(effectName: string, position: Vector3)
		if typeof(position) == "Vector3" then
			VFXController.Play(effectName, position)
		end
	end)
end

return VFXController
