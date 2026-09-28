--[[
	SCRIPT NAME:  VFXController
	SCRIPT TYPE:  ModuleScript (client controller)
	WHERE:        StarterPlayerScripts/Client/Controllers/VFXController
	DEPENDENCIES: Shared.Net, Shared.Config.VFXConfig

	Renders VFXConfig effects locally with POOLED emitters and parts (no
	Instances are created per effect after warm-up; far effects are skipped).
	Everything is procedural, so it works without uploaded art:

	  Burst   particles (sparkles, chips, leaves, hearts, stars...)
	  Ring    expanding neon ring
	  Puff    cartoon dust clouds: soft balls swell, drift and fade
	  Debris  chunks fly out, bounce on the ground and shrink (rock shatter),
	          or colourful confetti that flutters down
	  Pop     quick neon flash sphere at an impact
	  Jiggle  cartoon squash / tilt / pop / hop / nudge of a MODEL (trees
	          wobble when chopped, rocks squash, crops and buildings pop,
	          whatever you hover gives a tiny boing)

	Jiggles move / scale the model LOCALLY and put it back exactly where it
	was, so they never fight the server.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Net = require(Shared:WaitForChild("Net"))
local VFXConfig = require(Shared.Config.VFXConfig)

local BURST_POOL = 12
local RING_POOL = 8
local PUFF_POOL = 40
local DEBRIS_POOL = 60
local POP_POOL = 8
local GRAVITY = Vector3.new(0, -70, 0)

type BurstEmitter = { Part: Part, Emitter: ParticleEmitter, BusyUntil: number }
type PooledPart = { Part: Part, BusyUntil: number, Token: number }
type Chunk = {
	Item: PooledPart,
	Token: number,
	Position: Vector3,
	Velocity: Vector3,
	Spin: Vector3,
	Rotation: CFrame,
	Size: Vector3,
	Born: number,
	Life: number,
	Ground: number,
	Flutter: boolean,
}
type Jiggle = {
	Model: Model,
	Style: string,
	Start: number,
	Duration: number,
	BasePivot: CFrame,
	BaseScale: number,
	Axis: Vector3,
	Amplitude: number,
}

local CONFETTI_COLORS = {
	Color3.fromRGB(255, 90, 110),
	Color3.fromRGB(255, 200, 60),
	Color3.fromRGB(90, 210, 120),
	Color3.fromRGB(80, 170, 255),
	Color3.fromRGB(190, 120, 255),
	Color3.fromRGB(255, 150, 70),
}

local VFXController = {}

local bursts: { BurstEmitter } = {}
local rings: { PooledPart } = {}
local puffs: { PooledPart } = {}
local debris: { PooledPart } = {}
local pops: { PooledPart } = {}
local chunks: { Chunk } = {}
local jiggles: { [Model]: Jiggle } = {}
local folder: Folder
local groundParams = RaycastParams.new()
groundParams.FilterType = Enum.RaycastFilterType.Include
groundParams.IgnoreWater = false
local random = Random.new()

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
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
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

local function groundHeight(position: Vector3): number
	groundParams.FilterDescendantsInstances = { workspace.Terrain }
	local hit = workspace:Raycast(position + Vector3.new(0, 6, 0), Vector3.new(0, -40, 0), groundParams)
	return if hit then hit.Position.Y else position.Y - 3
end

---------------------------------------------------------------------------
-- Effect types
---------------------------------------------------------------------------

local function playBurst(def: any, position: Vector3, options: any)
	local item = acquire(bursts)
	if not item then
		return
	end
	local emitter = item.Emitter
	local scale = options.Scale or 1
	item.Part.CFrame = CFrame.new(position)
	emitter.Color = ColorSequence.new(options.Color or def.Color)
	emitter.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, def.Size * scale),
		NumberSequenceKeypoint.new(0.2, def.Size * scale * 1.15),
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
	emitter:Emit(options.Count or def.Count)
	item.BusyUntil = os.clock() + def.Lifetime + 0.1
end

local function playRing(def: any, position: Vector3, options: any)
	local item = acquire(rings)
	if not item then
		return
	end
	local part = item.Part
	local scale = options.Scale or 1
	part.Color = options.Color or def.Color
	part.Transparency = 0.15
	part.Size = Vector3.new(def.Height, def.StartSize * scale, def.StartSize * scale)
	part.CFrame = CFrame.new(position) * CFrame.Angles(0, 0, math.rad(90))
	TweenService:Create(part, TweenInfo.new(def.Duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = Vector3.new(def.Height * 0.3, def.EndSize * scale, def.EndSize * scale),
		Transparency = 1,
	}):Play()
	item.BusyUntil = os.clock() + def.Duration
end

local function playPuff(def: any, position: Vector3, options: any)
	local scale = options.Scale or 1
	local count = options.Count or def.Count
	local color = options.Color or def.Color
	local ground = groundHeight(position)
	for index = 1, count do
		local item = acquire(puffs)
		if not item then
			return
		end
		local part = item.Part
		local angle = (index / count) * math.pi * 2 + random:NextNumber(-0.4, 0.4)
		local direction = Vector3.new(math.cos(angle), 0, math.sin(angle))
		local startSize = def.Size * scale * random:NextNumber(0.35, 0.55)
		local endSize = def.Size * scale * random:NextNumber(0.9, 1.35)
		local start = Vector3.new(position.X, math.max(ground + startSize * 0.4, position.Y - 1), position.Z) + direction * 0.6 * scale
		part.Color = color:Lerp(Color3.new(1, 1, 1), random:NextNumber(0, 0.25))
		part.Size = Vector3.one * startSize
		part.CFrame = CFrame.new(start)
		part.Transparency = 0.05
		local duration = def.Duration * random:NextNumber(0.8, 1.15)
		TweenService:Create(part, TweenInfo.new(duration, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
			Size = Vector3.one * endSize,
			CFrame = CFrame.new(start + direction * def.Radius * scale + Vector3.new(0, endSize * 0.45, 0)),
		}):Play()
		TweenService:Create(part, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Transparency = 1 }):Play()
		item.BusyUntil = os.clock() + duration + 0.05
	end
end

local function playDebris(def: any, position: Vector3, options: any)
	local scale = options.Scale or 1
	local count = options.Count or def.Count
	local color = options.Color or def.Color
	local ground = groundHeight(position)
	local now = os.clock()
	for _ = 1, count do
		local item = acquire(debris)
		if not item then
			return
		end
		local part = item.Part
		local size: Vector3
		if def.Confetti then
			size = Vector3.new(0.5, 0.05, 0.3) * def.Size * 2 * scale
			part.Color = CONFETTI_COLORS[random:NextInteger(1, #CONFETTI_COLORS)]
			part.Material = Enum.Material.SmoothPlastic
		else
			local s = def.Size * scale * random:NextNumber(0.55, 1.2)
			size = Vector3.new(s, s * random:NextNumber(0.6, 1), s * random:NextNumber(0.7, 1.1))
			local shade = random:NextNumber(-0.12, 0.12)
			part.Color = if shade > 0 then color:Lerp(Color3.new(1, 1, 1), shade) else color:Lerp(Color3.new(0, 0, 0), -shade)
			part.Material = Enum.Material.SmoothPlastic
		end
		part.Size = size
		part.Transparency = 0
		local horizontal = random:NextUnitVector() * Vector3.new(1, 0, 1)
		local speed = def.Speed * random:NextNumber(0.5, 1)
		local velocity = horizontal * speed * 0.55 + Vector3.new(0, speed * random:NextNumber(0.6, 1.1), 0)
		local chunk: Chunk = {
			Item = item,
			Token = 0,
			Position = position + horizontal * 0.4,
			Velocity = velocity,
			Spin = Vector3.new(random:NextNumber(-12, 12), random:NextNumber(-12, 12), random:NextNumber(-12, 12)),
			Rotation = CFrame.Angles(random:NextNumber(0, 6.28), random:NextNumber(0, 6.28), random:NextNumber(0, 6.28)),
			Size = size,
			Born = now,
			Life = def.Duration * random:NextNumber(0.8, 1.2),
			Ground = ground,
			Flutter = def.Confetti == true,
		}
		item.BusyUntil = now + chunk.Life + 0.1
		item.Token += 1
		chunk.Token = item.Token
		table.insert(chunks, chunk)
	end
end

local function playPop(def: any, position: Vector3, options: any)
	local item = acquire(pops)
	if not item then
		return
	end
	local scale = options.Scale or 1
	local part = item.Part
	part.Color = options.Color or def.Color
	part.Size = Vector3.one * def.StartSize * scale
	part.CFrame = CFrame.new(position)
	part.Transparency = 0.1
	TweenService:Create(part, TweenInfo.new(def.Duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = Vector3.one * def.EndSize * scale,
		Transparency = 1,
	}):Play()
	item.BusyUntil = os.clock() + def.Duration
end

---------------------------------------------------------------------------
-- Jiggles (local-only squash / tilt / pop of a model)
---------------------------------------------------------------------------

local function restore(jiggle: Jiggle)
	local model = jiggle.Model
	if not model.Parent then
		return
	end
	if jiggle.Style == "Tilt" or jiggle.Style == "Hop" then
		model:PivotTo(jiggle.BasePivot)
	else
		pcall(model.ScaleTo, model, jiggle.BaseScale)
	end
end

local function playJiggle(options: any)
	local model = options.Target
	if typeof(model) ~= "Instance" or not model:IsA("Model") or not model.Parent then
		return
	end
	local existing = jiggles[model]
	if existing then
		restore(existing)
		jiggles[model] = nil
	end
	local style = if type(options.Style) == "string" then options.Style else "Squash"
	local pivot = model:GetPivot()
	local axis = Vector3.new(1, 0, 0)
	if style == "Tilt" then
		local away = if typeof(options.From) == "Vector3" then (pivot.Position - options.From) * Vector3.new(1, 0, 1) else Vector3.new(1, 0, 0)
		if away.Magnitude < 0.1 then
			away = Vector3.new(1, 0, 0)
		end
		axis = Vector3.new(0, 1, 0):Cross(away.Unit).Unit
	end
	jiggles[model] = {
		Model = model,
		Style = style,
		Start = os.clock(),
		Duration = if style == "Pop" then 0.55 elseif style == "Tilt" then 0.7 elseif style == "Hop" then 0.5 elseif style == "Nudge" then 0.3 else 0.45,
		BasePivot = pivot,
		BaseScale = model:GetScale(),
		Axis = axis,
		Amplitude = if style == "Tilt" then math.rad(7) elseif style == "Pop" then 0.4 elseif style == "Nudge" then 0.045 else 0.14,
	}
end

local function stepJiggle(jiggle: Jiggle, now: number): boolean
	local model = jiggle.Model
	if not model.Parent then
		return false
	end
	local t = now - jiggle.Start
	if t >= jiggle.Duration then
		restore(jiggle)
		return false
	end
	local decay = math.exp(-t * 7)
	if jiggle.Style == "Tilt" then
		local angle = jiggle.Amplitude * decay * math.sin(t * 26)
		local base = jiggle.BasePivot
		model:PivotTo(CFrame.fromAxisAngle(jiggle.Axis, angle) * (base - base.Position) + base.Position)
	elseif jiggle.Style == "Hop" then
		local height = math.max(0, math.sin(t / jiggle.Duration * math.pi)) * 1.2
		model:PivotTo(jiggle.BasePivot + Vector3.new(0, height, 0))
	elseif jiggle.Style == "Pop" then
		-- Grow in from small with a springy overshoot.
		local alpha = t / jiggle.Duration
		local s = 1 - jiggle.Amplitude * math.exp(-alpha * 6) * math.cos(alpha * 14)
		pcall(model.ScaleTo, model, jiggle.BaseScale * math.max(0.05, s))
	else
		-- Squash: quick dip then springy bounce back.
		local s = 1 - jiggle.Amplitude * decay * math.sin(t * 30 + 0.6)
		pcall(model.ScaleTo, model, jiggle.BaseScale * s)
	end
	return true
end

---------------------------------------------------------------------------
-- Per-frame simulation
---------------------------------------------------------------------------

local function step(dt: number)
	dt = math.min(dt, 1 / 20)
	local now = os.clock()
	for index = #chunks, 1, -1 do
		local chunk = chunks[index]
		local age = now - chunk.Born
		local part = chunk.Item.Part
		if chunk.Item.Token ~= chunk.Token then
			table.remove(chunks, index) -- the part was reused by a newer chunk
		elseif age >= chunk.Life then
			part.Transparency = 1
			table.remove(chunks, index)
		else
			if chunk.Flutter then
				-- Confetti: heavy drag, gentle fall, side-to-side flutter.
				chunk.Velocity += (GRAVITY * 0.18 - chunk.Velocity * 2.2) * dt
				chunk.Velocity += Vector3.new(math.sin(age * 9 + chunk.Spin.X), 0, math.cos(age * 7 + chunk.Spin.Z)) * 6 * dt
			else
				chunk.Velocity += GRAVITY * dt
			end
			chunk.Position += chunk.Velocity * dt
			local bottom = chunk.Ground + chunk.Size.Y * 0.5
			if chunk.Position.Y < bottom then
				chunk.Position = Vector3.new(chunk.Position.X, bottom, chunk.Position.Z)
				if chunk.Flutter then
					chunk.Velocity = Vector3.zero
					chunk.Spin = Vector3.zero
				else
					chunk.Velocity = Vector3.new(chunk.Velocity.X * 0.55, -chunk.Velocity.Y * 0.35, chunk.Velocity.Z * 0.55)
					chunk.Spin *= 0.6
				end
			end
			chunk.Rotation *= CFrame.Angles(chunk.Spin.X * dt, chunk.Spin.Y * dt, chunk.Spin.Z * dt)
			local fade = math.clamp((chunk.Life - age) / 0.35, 0, 1)
			part.Size = chunk.Size * math.max(0.05, fade)
			part.CFrame = CFrame.new(chunk.Position) * chunk.Rotation
		end
	end
	for model, jiggle in jiggles do
		if not stepJiggle(jiggle, now) then
			jiggles[model] = nil
		end
	end
end

---------------------------------------------------------------------------
-- Public
---------------------------------------------------------------------------

function VFXController.Play(effectName: string, position: Vector3, options: any?)
	local def = VFXConfig.Effects[effectName]
	if not def then
		warn("[VFX] Unknown effect '" .. tostring(effectName) .. "'")
		return
	end
	if not isVisible(position) then
		return
	end
	local opts = if type(options) == "table" then options else {}
	if def.Type == "Burst" then
		playBurst(def, position, opts)
	elseif def.Type == "Ring" then
		playRing(def, position, opts)
	elseif def.Type == "Puff" then
		playPuff(def, position, opts)
	elseif def.Type == "Debris" then
		playDebris(def, position, opts)
	elseif def.Type == "Pop" then
		playPop(def, position, opts)
	elseif def.Type == "Jiggle" then
		playJiggle(opts)
	end
end

-- Cartoon squash / tilt / pop / hop of a model on this client only.
function VFXController.Jiggle(model: Model, style: string, from: Vector3?)
	playJiggle({ Target = model, Style = style, From = from })
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
		table.insert(rings, { Part = part, BusyUntil = 0, Token = 0 })
	end
	for _ = 1, PUFF_POOL do
		local part = newAnchorPart("Puff")
		part.Shape = Enum.PartType.Ball
		part.Material = Enum.Material.SmoothPlastic
		table.insert(puffs, { Part = part, BusyUntil = 0, Token = 0 })
	end
	for _ = 1, DEBRIS_POOL do
		local part = newAnchorPart("Debris")
		part.CastShadow = true
		table.insert(debris, { Part = part, BusyUntil = 0, Token = 0 })
	end
	for _ = 1, POP_POOL do
		local part = newAnchorPart("Pop")
		part.Shape = Enum.PartType.Ball
		part.Material = Enum.Material.Neon
		table.insert(pops, { Part = part, BusyUntil = 0, Token = 0 })
	end
end

function VFXController.Start()
	Net.OnClientEvent("PlayVFX", function(effectName: string, position: Vector3, options: any)
		if typeof(position) == "Vector3" then
			VFXController.Play(effectName, position, options)
		end
	end)
	RunService.RenderStepped:Connect(step)
end

return VFXController
