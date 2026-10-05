--!nocheck
-- Builder: offline (Lune) toolkit for constructing part-built, rigged monsters.
--
-- Conventions
--   * Model space: feet on Y = 0, centered on X = 0, the monster FACES -Z
--     (Roblox "forward"). Its RIGHT side is +X, LEFT side is -X.
--   * All CFrames / positions you pass are in MODEL (world) space.
--   * Bones are tiny invisible parts joined by Motor6Ds. Visual parts are
--     welded to a bone. Animation drives Motor6D.Transform (see Motion module).
--   * Every bone pivot has the orientation you give it (identity by default).
--     Animation rotations are applied about the bone pivot in that frame.
--
-- Typical use (inside monsters/<Id>/build.luau):
--   return function(B, P)          -- B = this builder, P = helpers (CFrame, Vector3, ...)
--     local body = B:bone("Body", "Root", P.v(0, 8, 0))
--     B:block(body, P.v(6, 5, 8), P.cf(0, 8, 0), "#ffffff")
--     B:sym(function(side)
--       local arm = B:bone("Arm" .. side, "Body", P.v(3, 9, 0))
--       B:ball(arm, 2, P.cf(3.5, 9, 0), "#ffcc33", { mat = "Neon" })
--     end)
--   end

local roblox = require("@lune/roblox")
local Instance, CFrame, Vector3, Color3, Enum = roblox.Instance, roblox.CFrame, roblox.Vector3, roblox.Color3, roblox.Enum
local ColorSequence, ColorSequenceKeypoint = roblox.ColorSequence, roblox.ColorSequenceKeypoint
local NumberSequence, NumberSequenceKeypoint = roblox.NumberSequence, roblox.NumberSequenceKeypoint
local NumberRange = roblox.NumberRange

local Builder = {}
Builder.__index = Builder

---------------------------------------------------------------------------
-- Value helpers
---------------------------------------------------------------------------

local MATERIALS = {
	Plastic = Enum.Material.Plastic,
	SmoothPlastic = Enum.Material.SmoothPlastic,
	Neon = Enum.Material.Neon,
	Glass = Enum.Material.Glass,
	Metal = Enum.Material.Metal,
	Foil = Enum.Material.Foil,
	ForceField = Enum.Material.ForceField,
	Ice = Enum.Material.Ice,
	Slate = Enum.Material.Slate,
	Rock = Enum.Material.Rock,
	Basalt = Enum.Material.Basalt,
	CrackedLava = Enum.Material.CrackedLava,
	Granite = Enum.Material.Granite,
	Marble = Enum.Material.Marble,
	Wood = Enum.Material.Wood,
	WoodPlanks = Enum.Material.WoodPlanks,
	Grass = Enum.Material.Grass,
	LeafyGrass = Enum.Material.LeafyGrass,
	Fabric = Enum.Material.Fabric,
	Sand = Enum.Material.Sand,
	Pebble = Enum.Material.Pebble,
	Concrete = Enum.Material.Concrete,
	CorrodedMetal = Enum.Material.CorrodedMetal,
	DiamondPlate = Enum.Material.DiamondPlate,
	Glacier = Enum.Material.Glacier,
	Salt = Enum.Material.Salt,
}

local function toColor(c)
	if typeof(c) == "Color3" then
		return c
	end
	if type(c) == "string" then
		local hex = c:gsub("#", "")
		assert(#hex == 6, "bad hex color: " .. c)
		return Color3.fromRGB(tonumber(hex:sub(1, 2), 16), tonumber(hex:sub(3, 4), 16), tonumber(hex:sub(5, 6), 16))
	end
	if type(c) == "table" then
		return Color3.fromRGB(c[1], c[2], c[3])
	end
	error("bad color value: " .. tostring(c))
end
Builder.toColor = toColor

local function toVec(v)
	if type(v) == "number" then
		return Vector3.new(v, v, v)
	end
	if typeof(v) == "Vector3" then
		return v
	end
	if type(v) == "table" then
		return Vector3.new(v[1], v[2], v[3])
	end
	error("bad Vector3 value: " .. tostring(v))
end

local function toCF(c)
	if typeof(c) == "CFrame" then
		return c
	end
	if typeof(c) == "Vector3" then
		return CFrame.new(c)
	end
	if type(c) == "table" then
		return CFrame.new(c[1], c[2], c[3])
	end
	error("bad CFrame value: " .. tostring(c))
end

-- Reflect a model-space CFrame across the YZ plane (x -> -x), keeping it a
-- proper rotation. Shapes symmetric about their local X (Block, Ball,
-- Wedge, Cylinder, ellipsoids) mirror perfectly this way.
local function mirrorCF(cf)
	local x, y, z, r00, r01, r02, r10, r11, r12, r20, r21, r22 = cf:GetComponents()
	return CFrame.new(-x, y, z, r00, -r01, -r02, -r10, r11, r12, -r20, r21, r22)
end
Builder.mirrorCF = mirrorCF

-- Helpers handed to build files as `P`.
local P = {}
Builder.P = P
P.CFrame, P.Vector3, P.Color3, P.Enum = CFrame, Vector3, Color3, Enum
P.mirrorCF = mirrorCF
function P.v(x, y, z)
	return Vector3.new(x, y, z)
end
-- CFrame from position + rotation in DEGREES (applied X, then Y, then Z like CFrame.Angles)
function P.cf(x, y, z, rx, ry, rz)
	return CFrame.new(x, y, z) * CFrame.Angles(math.rad(rx or 0), math.rad(ry or 0), math.rad(rz or 0))
end
function P.ang(rx, ry, rz)
	return CFrame.Angles(math.rad(rx or 0), math.rad(ry or 0), math.rad(rz or 0))
end
-- CFrame at `from`, looking toward `to` (both Vector3 or {x,y,z}).
function P.look(from, to, up)
	return CFrame.lookAt(toVec(from), toVec(to), up and toVec(up) or Vector3.new(0, 1, 0))
end
-- A CFrame positioned halfway between a and b whose local -Z points from a to b,
-- plus the distance. Great for limbs/tubes: B:block(bone, P.v(w, h, len), cf, ...)
function P.span(a, b, up)
	a, b = toVec(a), toVec(b)
	local mid = (a + b) / 2
	local dir = b - a
	local len = dir.Magnitude
	assert(len > 1e-4, "P.span: points must differ")
	local upv = up and toVec(up) or Vector3.new(0, 1, 0)
	if math.abs(dir.Unit:Dot(upv)) > 0.98 then
		upv = Vector3.new(0, 0, 1)
	end
	return CFrame.lookAt(mid, b, upv), len
end
P.color = toColor

---------------------------------------------------------------------------
-- Construction
---------------------------------------------------------------------------

function Builder.new(id, displayName, meta)
	local self = setmetatable({}, Builder)
	self.id = id
	self.model = Instance.new("Model")
	self.model.Name = id
	self.model:SetAttribute("DisplayName", displayName or id)
	for k, v in meta or {} do
		self.model:SetAttribute(k, v)
	end
	self.mirror = false
	self.bones = {}
	self.boneParent = {}
	self.boneOrder = {}
	self.parts = {}
	self.partInfo = {}
	self.effects = {}
	self.partCount = 0
	self.names = {}
	self.defaultStuds = true

	local root = Instance.new("Part")
	root.Name = "Root"
	root.Size = Vector3.new(1, 1, 1)
	root.CFrame = CFrame.new(0, 0.5, 0)
	root.Anchored = true
	root.CanCollide = false
	root.CanTouch = false
	root.CanQuery = true
	root.Transparency = 1
	root.TopSurface = Enum.SurfaceType.Smooth
	root.BottomSurface = Enum.SurfaceType.Smooth
	root.Parent = self.model
	self.model.PrimaryPart = root
	self.bones.Root = root
	self.root = root
	table.insert(self.boneOrder, "Root")
	return self
end

function Builder:xf(cf)
	cf = toCF(cf)
	if self.mirror then
		return mirrorCF(cf)
	end
	return cf
end

-- Run fn twice: first for the RIGHT side (side = "R", s = 1) exactly as you
-- wrote it (+X), then mirrored for the LEFT side (side = "L", s = -1).
-- Everything created inside is reflected automatically.
function Builder:sym(fn)
	local was = self.mirror
	self.mirror = false
	fn("R", 1)
	self.mirror = true
	fn("L", -1)
	self.mirror = was
end

local function resolveBone(self, bone)
	if type(bone) == "string" then
		local b = self.bones[bone]
		assert(b, ("[%s] unknown bone '%s'"):format(self.id, bone))
		return b
	end
	return bone
end

-- Create a bone (joint) named `name`, child of `parent` (name or bone part),
-- pivoting at `pivot` (Vector3 or CFrame, model space).
function Builder:bone(name, parent, pivot)
	assert(not self.bones[name], ("[%s] duplicate bone name '%s'"):format(self.id, name))
	local parentPart = resolveBone(self, parent)
	local cf = self:xf(pivot)
	local b = Instance.new("Part")
	b.Name = name
	b.Size = Vector3.new(0.2, 0.2, 0.2)
	b.CFrame = cf
	b.Transparency = 1
	b.CanCollide = false
	b.CanTouch = false
	b.CanQuery = false
	b.Massless = true
	b.TopSurface = Enum.SurfaceType.Smooth
	b.BottomSurface = Enum.SurfaceType.Smooth
	b.Parent = self.model

	local m = Instance.new("Motor6D")
	m.Name = name
	m.Part0 = parentPart
	m.Part1 = b
	m.C0 = parentPart.CFrame:Inverse() * cf
	m.C1 = CFrame.new()
	m.Parent = parentPart

	self.bones[name] = b
	self.boneParent[name] = parentPart.Name
	table.insert(self.boneOrder, name)
	return b
end

local SHAPES = {
	block = { class = "Part", shape = Enum.PartType.Block, studs = true },
	ball = { class = "Part", shape = Enum.PartType.Ball, studs = false },
	cyl = { class = "Part", shape = Enum.PartType.Cylinder, studs = false },
	wedge = { class = "WedgePart", studs = true },
	cwedge = { class = "CornerWedgePart", studs = true },
	ellipsoid = { class = "Part", shape = Enum.PartType.Block, mesh = "Sphere", studs = false },
}

-- Core part factory. opts: mat, tr (transparency), refl, name, studs (bool),
-- glow (alias for mat="Neon").
function Builder:make(kind, bone, size, cf, color, opts)
	opts = opts or {}
	local spec = SHAPES[kind]
	assert(spec, "unknown part kind " .. tostring(kind))
	local bonePart = resolveBone(self, bone)
	if self.mirror and kind == "cwedge" then
		error(("[%s] cwedge cannot be used inside B:sym() (corner wedges are not mirror-symmetric); use wedge/block instead"):format(self.id))
	end

	local p = Instance.new(spec.class)
		p.Name = opts.name or "P"
	local sz = toVec(size)
	if kind == "ball" then
		local d = sz.X
		sz = Vector3.new(d, d, d)
	end
	assert(sz.X > 0 and sz.Y > 0 and sz.Z > 0, ("[%s] part sizes must be positive"):format(self.id))
	if spec.shape then
		p.Shape = spec.shape
	end
	p.Size = sz
	p.CFrame = self:xf(cf)
	p.Color = toColor(color)
	local matName = opts.glow and "Neon" or (opts.mat or "Plastic")
	local mat = MATERIALS[matName]
	assert(mat, ("[%s] unknown material '%s'"):format(self.id, tostring(matName)))
	p.Material = mat
	p.Transparency = opts.tr or 0
	p.Reflectance = opts.refl or 0
	p.CanCollide = false
	p.CanTouch = false
	p.CanQuery = opts.query or false
	p.Massless = true
	p.CastShadow = opts.shadow ~= false and matName ~= "Neon"

	local studs = opts.studs
	if studs == nil then
		studs = self.defaultStuds and spec.studs and matName == "Plastic"
	end
	local st = studs and Enum.SurfaceType.Studs or Enum.SurfaceType.Smooth
	p.TopSurface = st
	p.BottomSurface = studs and Enum.SurfaceType.Inlet or Enum.SurfaceType.Smooth
	p.FrontSurface = st
	p.BackSurface = st
	p.LeftSurface = st
	p.RightSurface = st

	if spec.mesh then
		local m = Instance.new("SpecialMesh")
		m.MeshType = Enum.MeshType[spec.mesh]
		m.Parent = p
	end

	p.Parent = self.model

	local w = Instance.new("Weld")
	w.Name = "W"
	w.Part0 = bonePart
	w.Part1 = p
	w.C0 = bonePart.CFrame:Inverse() * p.CFrame
	w.C1 = CFrame.new()
	w.Parent = p

	self.partCount += 1
	table.insert(self.parts, p)
	self.partInfo[p] = { kind = kind, bone = bonePart.Name, studs = studs }
	return p
end

-- Shape shortcuts. size: Vector3 / {x,y,z} / number; cf: CFrame / Vector3 / {x,y,z}
function Builder:block(bone, size, cf, color, opts) return self:make("block", bone, size, cf, color, opts) end
function Builder:wedge(bone, size, cf, color, opts) return self:make("wedge", bone, size, cf, color, opts) end
function Builder:cwedge(bone, size, cf, color, opts) return self:make("cwedge", bone, size, cf, color, opts) end
-- Ball: size is the DIAMETER (number). Use ellipsoid for squashed spheres.
function Builder:ball(bone, diameter, cf, color, opts) return self:make("ball", bone, diameter, cf, color, opts) end
-- Cylinder: axis along the part's local X. size = (length, diameter, diameter)
function Builder:cyl(bone, size, cf, color, opts) return self:make("cyl", bone, size, cf, color, opts) end
-- Smooth stretched sphere (SpecialMesh Sphere). size = full extents.
function Builder:ellipsoid(bone, size, cf, color, opts) return self:make("ellipsoid", bone, size, cf, color, opts) end

-- A block spanning from point a to point b (thickness w x h). Handy for limbs,
-- tusks, spikes, bars. Local -Z runs from a toward b.
function Builder:beam(bone, a, b, w, h, color, opts)
	local cf, len = P.span(a, b, opts and opts.up)
	return self:block(bone, Vector3.new(w, h or w, len), cf, color, opts)
end

-- A tapered spike/horn/claw made of 2 wedges back-to-back so it reads as a
-- pointed blade, from base point `a` to tip `b`. width = base width (local X),
-- depth = base thickness. Returns both parts.
function Builder:spike(bone, a, b, width, depth, color, opts)
	local cf, len = P.span(a, b, opts and opts.up)
	-- The wedge's tall face is at +Z (base end) and it slopes down toward -Z (tip).
	-- Two wedges: one upright, one flipped, form a symmetric pointed blade.
	local d = depth or width
	local top = self:wedge(bone, Vector3.new(width, d / 2, len), cf * CFrame.new(0, d / 4, 0), color, opts)
	local bot = self:wedge(bone, Vector3.new(width, d / 2, len), cf * CFrame.new(0, -d / 4, 0) * CFrame.Angles(0, 0, math.pi), color, opts)
	return top, bot
end

-- Any flat triangle from 3 model-space points, built from 2 wedges (the
-- classic Roblox triangle technique). Perfect for wings, fins, membranes,
-- feathers, leaves, teeth, ears, flames. `thickness` is the slab depth.
-- Returns the two wedges (either may be nil for degenerate halves).
function Builder:tri(bone, a, b, c, thickness, color, opts)
	a, b, c = toVec(a), toVec(b), toVec(c)
	if self.mirror then
		a = Vector3.new(-a.X, a.Y, a.Z)
		b = Vector3.new(-b.X, b.Y, b.Z)
		c = Vector3.new(-c.X, c.Y, c.Z)
	end
	local ab, ac, bc = b - a, c - a, c - b
	local abd, acd, bcd = ab:Dot(ab), ac:Dot(ac), bc:Dot(bc)
	if abd > acd and abd > bcd then
		c, a = a, c
	elseif acd > bcd and acd > abd then
		a, b = b, a
	end
	ab, ac, bc = b - a, c - a, c - b
	local cross = ac:Cross(ab)
	if cross.Magnitude < 1e-6 then
		return nil, nil
	end
	local right = cross.Unit
	local up = bc:Cross(right).Unit
	local back = bc.Unit
	local height = math.abs(ab:Dot(up))
	local was = self.mirror
	self.mirror = false
	local w1, w2
	local ok, err = pcall(function()
		local d1 = math.abs(ab:Dot(back))
		local d2 = math.abs(ac:Dot(back))
		if height > 1e-3 and d1 > 1e-3 then
			w1 = self:make("wedge", bone, Vector3.new(thickness, height, d1), CFrame.fromMatrix((a + b) / 2, right, up, back), color, opts)
		end
		if height > 1e-3 and d2 > 1e-3 then
			w2 = self:make("wedge", bone, Vector3.new(thickness, height, d2), CFrame.fromMatrix((a + c) / 2, -right, up, -back), color, opts)
		end
	end)
	self.mirror = was
	if not ok then
		error(err, 0)
	end
	return w1, w2
end

-- Flat quad / convex polygon (points in order) as a triangle fan.
function Builder:poly(bone, points, thickness, color, opts)
	local out = {}
	for i = 2, #points - 1 do
		local w1, w2 = self:tri(bone, points[1], points[i], points[i + 1], thickness, color, opts)
		if w1 then table.insert(out, w1) end
		if w2 then table.insert(out, w2) end
	end
	return out
end

-- Ring of `count` blocks around a circle (halos, collars, rings, crowns).
-- centerCF: model-space CFrame whose local Y is the ring's axis.
-- seg: Vector3 size of each block (X = along the ring tangent).
function Builder:ring(bone, centerCF, radius, count, seg, color, opts)
	local out = {}
	centerCF = toCF(centerCF)
	for i = 0, count - 1 do
		local a = (i / count) * math.pi * 2
		local cf = centerCF * CFrame.Angles(0, a, 0) * CFrame.new(0, 0, -radius)
		table.insert(out, self:make(opts and opts.kind or "block", bone, seg, cf, color, opts))
	end
	return out
end

---------------------------------------------------------------------------
-- Effects
---------------------------------------------------------------------------

local TEX = {
	sparkle = "rbxasset://textures/particles/sparkles_main.dds",
	fire = "rbxasset://textures/particles/fire_main.dds",
	smoke = "rbxasset://textures/particles/smoke_main.dds",
}

local function seq(v)
	if type(v) == "number" then
		return NumberSequence.new(v)
	end
	local kps = {}
	for i, val in v do
		local tt = (i - 1) / (#v - 1)
		table.insert(kps, NumberSequenceKeypoint.new(tt, val))
	end
	return NumberSequence.new(kps)
end

local function cseq(c)
	if type(c) == "table" and #c >= 2 and type(c[1]) ~= "number" then
		local kps = {}
		for i, val in c do
			table.insert(kps, ColorSequenceKeypoint.new((i - 1) / (#c - 1), toColor(val)))
		end
		return ColorSequence.new(kps)
	end
	return ColorSequence.new(toColor(c))
end

local PRESETS = {
	-- twinkling star sparkles around a glowing part
	sparkle = { tex = "sparkle", rate = 10, life = { 0.6, 1.4 }, speed = { 0.5, 2 }, size = { 0.2, 1.2, 0 }, trans = { 0.1, 0, 1 }, light = 1, spread = 180, rot = { -180, 180 } },
	-- soft glow orb, few big particles
	glow = { tex = "sparkle", rate = 3, life = { 1, 2 }, speed = { 0, 0.3 }, size = { 2, 4, 1 }, trans = { 0.7, 0.5, 1 }, light = 1, spread = 180, rot = { -45, 45 } },
	-- rising embers / magic motes
	ember = { tex = "fire", rate = 14, life = { 1, 2 }, speed = { 1, 3 }, size = { 0.4, 0.25, 0 }, trans = { 0, 0.2, 1 }, light = 1, spread = 35, accel = { 0, 3, 0 }, rot = { -90, 90 } },
	-- licking flames
	fire = { tex = "fire", rate = 30, life = { 0.4, 0.9 }, speed = { 2, 5 }, size = { 1.6, 1.2, 0 }, trans = { 0.2, 0.3, 1 }, light = 1, spread = 15, accel = { 0, 4, 0 }, rot = { -60, 60 } },
	-- drifting smoke / mist
	smoke = { tex = "smoke", rate = 6, life = { 2, 4 }, speed = { 0.5, 1.5 }, size = { 1.5, 4, 6 }, trans = { 0.6, 0.7, 1 }, light = 0, spread = 40, accel = { 0, 0.6, 0 }, rot = { -30, 30 } },
	-- dripping goo / slime / water drops
	drip = { tex = "sparkle", rate = 6, life = { 0.8, 1.4 }, speed = { 0, 0.5 }, size = { 0.5, 0.45, 0.2 }, trans = { 0, 0, 0.6 }, light = 0.4, spread = 10, accel = { 0, -25, 0 }, rot = { 0, 0 }, emitDir = "Bottom" },
	-- floating bubbles
	bubble = { tex = "sparkle", rate = 5, life = { 1.5, 3 }, speed = { 0.5, 1.5 }, size = { 0.3, 0.6, 0.8 }, trans = { 0.3, 0.4, 1 }, light = 0.6, spread = 60, accel = { 0, 2, 0 }, rot = { 0, 0 } },
	-- crackling electricity sparks
	spark = { tex = "sparkle", rate = 20, life = { 0.15, 0.4 }, speed = { 6, 14 }, size = { 0.5, 0.2, 0 }, trans = { 0, 0, 1 }, light = 1, spread = 180, rot = { -360, 360 }, drag = 4 },
	-- burst used with ctx.emit (Rate 0): big radial explosion of light
	burst = { tex = "sparkle", rate = 0, life = { 0.5, 1.1 }, speed = { 10, 22 }, size = { 1.5, 1, 0 }, trans = { 0, 0, 1 }, light = 1, spread = 180, rot = { -360, 360 }, drag = 3 },
	-- leaves / petals / feathers fluttering down
	leaf = { tex = "sparkle", rate = 4, life = { 2, 4 }, speed = { 1, 2 }, size = { 0.5, 0.5, 0.3 }, trans = { 0, 0, 1 }, light = 0.2, spread = 70, accel = { 0, -2, 0 }, rot = { -120, 120 }, rotSpeed = { -180, 180 } },
}
Builder.PRESETS = PRESETS

-- Particle emitter on a part (emits from its volume).
-- preset: one of PRESETS keys. opts override: color (Color3/hex or list for
-- gradient), rate, size (number or list), life {min,max}, speed {min,max},
-- light (LightEmission), spread, accel {x,y,z}, name, tex ("sparkle"/"fire"/"smoke"), enabled
function Builder:emitter(part, preset, opts)
	opts = opts or {}
	local p = PRESETS[preset]
	assert(p, ("[%s] unknown emitter preset '%s'"):format(self.id, tostring(preset)))
	local e = Instance.new("ParticleEmitter")
	e.Name = opts.name or (preset:sub(1, 1):upper() .. preset:sub(2))
	e.Texture = TEX[opts.tex or p.tex]
	e.Rate = opts.rate or p.rate
	local life = opts.life or p.life
	e.Lifetime = NumberRange.new(life[1], life[2])
	local spd = opts.speed or p.speed
	e.Speed = NumberRange.new(spd[1], spd[2])
	e.Size = seq(opts.size or p.size)
	e.Transparency = seq(opts.trans or p.trans)
	e.LightEmission = opts.light or p.light
	e.LightInfluence = opts.lightInfluence or 0
	local sp = opts.spread or p.spread
	e.SpreadAngle = roblox.Vector2.new(sp, sp)
	local ac = opts.accel or p.accel
	if ac then
		e.Acceleration = toVec(ac)
	end
	local rot = opts.rot or p.rot
	e.Rotation = NumberRange.new(rot[1], rot[2])
	local rs = opts.rotSpeed or p.rotSpeed
	if rs then
		e.RotSpeed = NumberRange.new(rs[1], rs[2])
	end
	e.Drag = opts.drag or p.drag or 0
	e.Color = cseq(opts.color or "#ffffff")
	e.EmissionDirection = Enum.NormalId[opts.dir or p.emitDir or "Top"]
	if opts.zoffset then
		e.ZOffset = opts.zoffset
	end
	e.LockedToPart = opts.locked or false
	e.Enabled = opts.enabled ~= false
	e.Parent = part
	table.insert(self.effects, { kind = "emitter", preset = preset, part = part, inst = e, color = opts.color or "#ffffff", rate = e.Rate })
	return e
end

-- Point light on a part. opts: color, brightness, range, shadows, name
function Builder:light(part, opts)
	opts = opts or {}
	local l = Instance.new("PointLight")
	l.Name = opts.name or "Light"
	l.Color = toColor(opts.color or "#ffffff")
	l.Brightness = opts.brightness or 2
	l.Range = opts.range or 14
	l.Shadows = opts.shadows or false
	l.Parent = part
	table.insert(self.effects, { kind = "light", part = part, inst = l, color = opts.color or "#ffffff" })
	return l
end

-- Motion trail between two model-space points carried by `bone` (e.g. a tail
-- tip or claw). opts: color (or list), life, width {a,b}, trans {a,b}, name, light
function Builder:trail(bone, a, b, opts)
	opts = opts or {}
	local bonePart = resolveBone(self, bone)
	local function att(pos, n)
		local at = Instance.new("Attachment")
		at.Name = n
		at.CFrame = bonePart.CFrame:Inverse() * CFrame.new(self:xf(pos).Position)
		at.Parent = bonePart
		return at
	end
	local nm = opts.name or "Trail"
	local a0, a1 = att(a, nm .. "A0"), att(b, nm .. "A1")
	local tr = Instance.new("Trail")
	tr.Name = nm
	tr.Attachment0, tr.Attachment1 = a0, a1
	tr.Lifetime = opts.life or 0.35
	tr.MinLength = 0.05
	tr.FaceCamera = opts.faceCamera or false
	tr.LightEmission = opts.light or 1
	tr.LightInfluence = 0
	tr.Color = cseq(opts.color or "#ffffff")
	local trn = opts.trans or { 0.2, 1 }
	tr.Transparency = NumberSequence.new(trn[1], trn[2])
	local wd = opts.width or { 1, 0 }
	tr.WidthScale = NumberSequence.new(wd[1], wd[2])
	tr.Parent = bonePart
	table.insert(self.effects, { kind = "trail", bone = bonePart.Name, inst = tr, color = opts.color or "#ffffff" })
	return tr
end

-- Shorthand: neon glow part + point light inside it.
function Builder:gem(bone, size, cf, color, opts)
	opts = opts or {}
	local kind = opts.kind or "block"
	local p = self:make(kind, bone, size, cf, color, { mat = "Neon", name = opts.name or "Gem", tr = opts.tr })
	if opts.light ~= false then
		self:light(p, { color = color, brightness = opts.brightness or 1.5, range = opts.range or 10 })
	end
	return p
end

---------------------------------------------------------------------------
-- Finish
---------------------------------------------------------------------------

function Builder:finish(motionSource, animLibSource, animatorSource)
	local model = self.model
	local folder = Instance.new("Folder")
	folder.Name = "Animation"
	folder.Parent = model

	local lib = Instance.new("ModuleScript")
	lib.Name = "AnimLib"
	lib.Source = animLibSource
	lib.Parent = folder

	local motion = Instance.new("ModuleScript")
	motion.Name = "Motion"
	motion.Source = motionSource
	motion.Parent = folder

	local anim = Instance.new("Script")
	anim.Name = "Animator"
	anim.RunContext = Enum.RunContext.Client
	anim.Source = animatorSource
	anim.Parent = folder

	model:SetAttribute("AnimSpeed", 1)
	model:SetAttribute("PartCount", self.partCount)
	model.WorldPivot = CFrame.new(0, 0, 0)
	return model
end

return Builder
