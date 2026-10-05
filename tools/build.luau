--!nocheck
-- Build pipeline (run from the repo root):
--   lune run tools/build.luau                 -> build every monster + packs
--   lune run tools/build.luau CelestialPeacock -> build just one (fast iteration)
--
-- Outputs (in out/):
--   models/<Id>.rbxm         one monster per file
--   preview/<Id>.json        geometry + baked animation for the web previewer
--   Monsters.rbxm            all monsters in one Folder (full build only)
--   MonsterShowcase.rbxl     ready-to-play showcase place (full build only)

local fs = require("@lune/fs")
local luau = require("@lune/luau")
local process = require("@lune/process")
local serde = require("@lune/serde")
local roblox = require("@lune/roblox")
local Instance, CFrame, Vector3, Color3, Enum = roblox.Instance, roblox.CFrame, roblox.Vector3, roblox.Color3, roblox.Enum

local Builder = require("../lib/Builder")

local ANIMLIB_SRC = fs.readFile("lib/AnimLib.luau")
local ANIMATOR_SRC = fs.readFile("lib/Animator.luau")

local FPS = 30

-- Fail fast if the runtime scripts shipped in every model don't compile.
do
	local ok, err = pcall(luau.compile, ANIMATOR_SRC)
	assert(ok, "lib/Animator.luau does not compile: " .. tostring(err))
	ok, err = pcall(luau.compile, ANIMLIB_SRC)
	assert(ok, "lib/AnimLib.luau does not compile: " .. tostring(err))
end

local function readIfExists(p)
	if fs.isFile(p) then
		return fs.readFile(p)
	end
	return nil
end

---------------------------------------------------------------------------
-- Load AnimLib + Motion in a Roblox-like sandbox
---------------------------------------------------------------------------

local function baseEnv()
	return {
		CFrame = CFrame,
		Vector3 = Vector3,
		Color3 = Color3,
		Vector2 = roblox.Vector2,
		typeof = typeof,
	}
end

local function loadAnimLib()
	local env = baseEnv()
	local fn = luau.load(ANIMLIB_SRC, { debugName = "AnimLib", environment = env, injectGlobals = true })
	return fn()
end

local SENTINEL = {}
local function loadMotion(id, src, L)
	local env = baseEnv()
	env.script = { Parent = { AnimLib = SENTINEL } }
	env.require = function(m)
		if m == SENTINEL then
			return L
		end
		error("Motion modules may only require(script.Parent.AnimLib)")
	end
	env.game = nil
	env.workspace = nil
	local fn = luau.load(src, { debugName = id .. "/motion", environment = env, injectGlobals = true })
	local M = fn()
	assert(type(M) == "table", id .. ": motion.luau must return a table")
	assert(type(M.Update) == "function", id .. ": motion.luau must define M.Update(t, pose, ctx)")
	assert(type(M.Cycle) == "number" and M.Cycle > 0, id .. ": motion.luau must set M.Cycle (seconds)")
	return M
end

---------------------------------------------------------------------------
-- Helpers
---------------------------------------------------------------------------

local function r4(x)
	return math.floor(x * 10000 + 0.5) / 10000
end

local function cfArr(cf)
	local t = { cf:GetComponents() }
	for i, v in t do
		t[i] = r4(v)
	end
	return t
end

local function hex(c)
	return string.format("#%02x%02x%02x", math.floor(c.R * 255 + 0.5), math.floor(c.G * 255 + 0.5), math.floor(c.B * 255 + 0.5))
end

local function angleOf(cf)
	-- rotation angle (deg) of a CFrame's rotation part
	local _, _, _, r00, _, _, _, r11, _, _, _, r22 = cf:GetComponents()
	local tr = math.clamp((r00 + r11 + r22 - 1) / 2, -1, 1)
	return math.deg(math.acos(tr))
end

local function isFinite(x)
	return x == x and x ~= math.huge and x ~= -math.huge
end

local function aabb(parts)
	local mn = Vector3.new(math.huge, math.huge, math.huge)
	local mx = -mn
	for _, p in parts do
		local cf, s = p.CFrame, p.Size
		local _, _, _, r00, r01, r02, r10, r11, r12, r20, r21, r22 = cf:GetComponents()
		local hx = math.abs(r00) * s.X / 2 + math.abs(r01) * s.Y / 2 + math.abs(r02) * s.Z / 2
		local hy = math.abs(r10) * s.X / 2 + math.abs(r11) * s.Y / 2 + math.abs(r12) * s.Z / 2
		local hz = math.abs(r20) * s.X / 2 + math.abs(r21) * s.Y / 2 + math.abs(r22) * s.Z / 2
		local c = cf.Position
		mn = Vector3.new(math.min(mn.X, c.X - hx), math.min(mn.Y, c.Y - hy), math.min(mn.Z, c.Z - hz))
		mx = Vector3.new(math.max(mx.X, c.X + hx), math.max(mx.Y, c.Y + hy), math.max(mx.Z, c.Z + hz))
	end
	return mn, mx
end

local function materialName(m)
	return tostring(m):match("Enum%.Material%.(%w+)") or tostring(m)
end

---------------------------------------------------------------------------
-- Build one monster
---------------------------------------------------------------------------

local function buildMonster(id, L)
	local dir = "monsters/" .. id
	local buildSrc = readIfExists(dir .. "/build.luau")
	local motionSrc = readIfExists(dir .. "/motion.luau")
	assert(buildSrc, id .. ": missing build.luau")
	assert(motionSrc, id .. ": missing motion.luau")

	local benv = baseEnv()
	benv.Enum = Enum
	local spec = luau.load(buildSrc, { debugName = id .. "/build", environment = benv, injectGlobals = true })()
	assert(type(spec) == "table" and type(spec.Build) == "function", id .. ": build.luau must return { DisplayName=..., Build=function(B, P) end }")

	local B = Builder.new(id, spec.DisplayName or id, {
		Rarity = spec.Rarity or "Legendary",
		Element = spec.Element or "",
	})
	spec.Build(B, Builder.P)

	local model = B:finish(motionSrc, ANIMLIB_SRC, ANIMATOR_SRC)

	-- Motion validation + bake
	local M = loadMotion(id, motionSrc, L)
	local jointNames = {}
	local jointSet = {}
	for _, n in B.boneOrder do
		if n ~= "Root" then
			table.insert(jointNames, n)
			jointSet[n] = true
		end
	end

	-- Names of effect instances for ctx validation
	local named = { ParticleEmitter = {}, Light = {}, BasePart = {} }
	for _, d in model:GetDescendants() do
		if d:IsA("ParticleEmitter") then named.ParticleEmitter[d.Name] = true end
		if d:IsA("Light") then named.Light[d.Name] = true end
		if d:IsA("BasePart") then named.BasePart[d.Name] = true end
	end
	local problems = {}
	local function problem(msg)
		if not problems[msg] then
			problems[msg] = true
			table.insert(problems, msg)
		end
	end

	local cycle = M.Cycle
	local prevC, curC = 0, 0
	local ctx = { cycle = cycle }
	local events = {}
	local frameIdx = 0
	function ctx.crossed(at)
		if curC >= prevC then
			return prevC < at and at <= curC
		end
		return at > prevC or at <= curC
	end
	function ctx.emit(name, count)
		if not named.ParticleEmitter[name] then problem("ctx.emit: no ParticleEmitter named '" .. tostring(name) .. "'") end
		table.insert(events, { f = frameIdx, kind = "emit", name = name, count = count or 20 })
	end
	function ctx.enable(name, on)
		if not named.ParticleEmitter[name] then problem("ctx.enable: no ParticleEmitter named '" .. tostring(name) .. "'") end
	end
	function ctx.light(name, b)
		if not named.Light[name] then problem("ctx.light: no Light named '" .. tostring(name) .. "'") end
	end
	function ctx.transparency(name, v)
		if not named.BasePart[name] then problem("ctx.transparency: no part named '" .. tostring(name) .. "'") end
	end

	local nFrames = math.max(1, math.floor(cycle * FPS + 0.5))
	local frames = {}
	local maxAng, maxPos, used = {}, {}, {}
	-- run one full warm-up cycle first so stateful motions settle, then record
	for pass = 1, 2 do
		for f = 0, nFrames - 1 do
			frameIdx = f
			local t = f / FPS + (pass - 1) * cycle
			prevC = curC
			curC = t % cycle
			local pose = {}
			M.Update(t, pose, ctx)
			if pass == 2 then
				local row = {}
				for name, cf in pose do
					if not jointSet[name] then
						problem("pose sets unknown joint '" .. tostring(name) .. "'")
					elseif typeof(cf) ~= "CFrame" then
						problem("pose." .. name .. " is not a CFrame")
					end
				end
				for _, name in jointNames do
					local cf = pose[name]
					if typeof(cf) ~= "CFrame" then
						cf = CFrame.new()
					else
						used[name] = true
					end
					local comps = cfArr(cf)
					for _, v in comps do
						if not isFinite(v) then
							problem("non-finite transform on joint '" .. name .. "'")
						end
					end
					for _, v in comps do
						table.insert(row, v)
					end
					maxAng[name] = math.max(maxAng[name] or 0, angleOf(cf))
					maxPos[name] = math.max(maxPos[name] or 0, cf.Position.Magnitude)
				end
				table.insert(frames, row)
			end
		end
	end

	-- Preview export
	local boneRest = {}
	local bones = {}
	for _, n in B.boneOrder do
		local b = B.bones[n]
		boneRest[n] = b.CFrame
		table.insert(bones, { name = n, parent = B.boneParent[n], cf = cfArr(b.CFrame) })
	end
	local parts = {}
	for _, p in B.parts do
		local info = B.partInfo[p]
		local rel = boneRest[info.bone]:Inverse() * p.CFrame
		table.insert(parts, {
			name = p.Name,
			bone = info.bone,
			kind = info.kind,
			size = { r4(p.Size.X), r4(p.Size.Y), r4(p.Size.Z) },
			cf = cfArr(rel),
			color = hex(p.Color),
			mat = materialName(p.Material),
			tr = r4(p.Transparency),
			studs = info.studs and true or false,
		})
	end
	local effects = {}
	for _, e in B.effects do
		local owner, pos
		if e.part then
			local info = B.partInfo[e.part]
			owner = info and info.bone or e.part.Name
			pos = cfArr(boneRest[owner]:Inverse() * e.part.CFrame)
		else
			owner = e.bone
			pos = cfArr(CFrame.new())
		end
		local col = e.color
		if type(col) == "table" and type(col[1]) ~= "number" then
			col = col[1]
		end
		local entry = { kind = e.kind, bone = owner, cf = pos, color = hex(Builder.toColor(col)), preset = e.preset, name = e.inst.Name }
		if e.kind == "emitter" then
			entry.rate = e.rate
			entry.size = e.part.Size and { r4(e.part.Size.X), r4(e.part.Size.Y), r4(e.part.Size.Z) } or nil
		elseif e.kind == "light" then
			entry.range = e.inst.Range
			entry.brightness = e.inst.Brightness
		end
		table.insert(effects, entry)
	end

	local mn, mx = aabb(B.parts)
	local preview = {
		id = id,
		displayName = spec.DisplayName or id,
		rarity = spec.Rarity or "Legendary",
		element = spec.Element or "",
		bounds = { min = { r4(mn.X), r4(mn.Y), r4(mn.Z) }, max = { r4(mx.X), r4(mx.Y), r4(mx.Z) } },
		bones = bones,
		parts = parts,
		effects = effects,
		anim = { fps = FPS, cycle = cycle, joints = jointNames, frames = frames, events = events },
	}
	fs.writeDir("out/preview")
	fs.writeFile("out/preview/" .. id .. ".json", serde.encode("json", preview))

	fs.writeDir("out/models")
	fs.writeFile("out/models/" .. id .. ".rbxm", roblox.serializeModel({ model }))

	-- Report
	local unused = {}
	for _, n in jointNames do
		if not used[n] then
			table.insert(unused, n)
		end
	end
	local nEmit, nLight, nTrail = 0, 0, 0
	for _, e in B.effects do
		if e.kind == "emitter" then nEmit += 1 elseif e.kind == "light" then nLight += 1 else nTrail += 1 end
	end
	local neon = 0
	for _, p in B.parts do
		if p.Material == Enum.Material.Neon then neon += 1 end
	end
	print(("== %s (%s, %s) =="):format(id, spec.DisplayName or id, spec.Rarity or "?"))
	print(("   parts %d (neon %d) | joints %d | emitters %d lights %d trails %d | cycle %.1fs"):format(B.partCount, neon, #jointNames, nEmit, nLight, nTrail, cycle))
	print(("   size W %.1f x H %.1f x L %.1f  (y %.1f..%.1f)"):format(mx.X - mn.X, mx.Y - mn.Y, mx.Z - mn.Z, mn.Y, mx.Y))
	local motionLines = {}
	for _, n in jointNames do
		table.insert(motionLines, ("%s %.0f°%s"):format(n, maxAng[n] or 0, (maxPos[n] or 0) > 0.05 and ("/" .. string.format("%.1f", maxPos[n])) or ""))
	end
	print("   motion range: " .. table.concat(motionLines, ", "))
	if #unused > 0 then
		print("   NOTE unanimated joints: " .. table.concat(unused, ", "))
	end
	for _, msg in problems do
		print("   PROBLEM: " .. msg)
	end
	return model, { mn = mn, mx = mx, problems = #problems, spec = spec }
end

---------------------------------------------------------------------------
-- Pack + showcase
---------------------------------------------------------------------------

local function moveModel(model, offset)
	for _, d in model:GetDescendants() do
		if d:IsA("BasePart") then
			d.CFrame = offset * d.CFrame
		end
	end
	model.WorldPivot = offset * model.WorldPivot
end

local RARITY_COLORS = {
	Common = "#b8b8b8",
	Rare = "#3d8bff",
	Epic = "#a64dff",
	Legendary = "#ffb21e",
	Mythic = "#ff3d6e",
	Secret = "#ffffff",
	Cosmic = "#8a2be2",
	Divine = "#ffe66b",
}

local function makeTag(parent, displayName, rarity, height)
	local anchor = Instance.new("Part")
	anchor.Name = "NameTag"
	anchor.Anchored = true
	anchor.CanCollide = false
	anchor.CanQuery = false
	anchor.CanTouch = false
	anchor.Transparency = 1
	anchor.Size = Vector3.new(1, 1, 1)
	anchor.CFrame = CFrame.new(0, height, 0)
	anchor.Parent = parent

	local gui = Instance.new("BillboardGui")
	gui.Name = "Tag"
	gui.Size = roblox.UDim2.new(16, 0, 5, 0)
	gui.StudsOffset = Vector3.new(0, 2.5, 0)
	gui.AlwaysOnTop = false
	gui.LightInfluence = 0
	gui.MaxDistance = 250
	gui.Parent = anchor

	local function label(text, y, h, color, strokeColor)
		local t = Instance.new("TextLabel")
		t.BackgroundTransparency = 1
		t.Size = roblox.UDim2.new(1, 0, h, 0)
		t.Position = roblox.UDim2.new(0, 0, y, 0)
		t.Text = text
		t.TextScaled = true
		t.FontFace = roblox.Font.fromEnum(Enum.Font.FredokaOne)
		t.TextColor3 = Builder.toColor(color)
		local s = Instance.new("UIStroke")
		s.Thickness = 3
		s.Color = Builder.toColor(strokeColor or "#000000")
		s.Parent = t
		t.Parent = gui
		return t
	end
	local rc = RARITY_COLORS[rarity] or "#ffffff"
	label(rarity, 0, 0.42, rc, rarity == "Secret" and "#000000" or "#1a1a1a")
	label(displayName, 0.42, 0.58, "#ffffff")
	return anchor
end

local function buildPacks(built)
	-- Pack: lay monsters out in two facing rows
	local folder = Instance.new("Folder")
	folder.Name = "Monsters"

	local game = Instance.new("DataModel")
	local workspace = game:GetService("Workspace")
	local lighting = game:GetService("Lighting")

	local showcase = Instance.new("Folder")
	showcase.Name = "MonsterShowcase"

	local half = math.ceil(#built / 2)
	local rows = { {}, {} }
	for i, b in built do
		table.insert(rows[i <= half and 1 or 2], b)
	end
	local rowZ = {}
	local maxDepth = { 0, 0 }
	for r = 1, 2 do
		for _, b in rows[r] do
			local d = b.info.mx.Z - b.info.mn.Z
			maxDepth[r] = math.max(maxDepth[r], d)
		end
	end
	local aisle = 34
	rowZ[1] = -(aisle / 2 + maxDepth[1] / 2 + 6) -- row 1 sits at -Z, faces +Z (toward the aisle)
	rowZ[2] = aisle / 2 + maxDepth[2] / 2 + 6 -- row 2 sits at +Z, faces -Z

	local totalLen = 0
	for r = 1, 2 do
		local x = 0
		local widths = {}
		for _, b in rows[r] do
			local w = b.info.mx.X - b.info.mn.X
			table.insert(widths, w)
			x += w + 14
		end
		local rowLen = x - 14
		totalLen = math.max(totalLen, rowLen)
		local cursor = -rowLen / 2
		for i, b in rows[r] do
			local w = widths[i]
			local cx = cursor + w / 2
			cursor += w + 14
			local center = (b.info.mn + b.info.mx) / 2
			local rot = r == 1 and CFrame.Angles(0, math.pi, 0) or CFrame.new()
			local offset = CFrame.new(cx, 0, rowZ[r]) * rot * CFrame.new(-center.X, 0, -center.Z)

			local packCopy = b.model:Clone()
			moveModel(packCopy, offset)
			packCopy.Parent = folder

			local placeCopy = b.model:Clone()
			moveModel(placeCopy, offset)
			placeCopy.Parent = showcase

			-- pedestal
			local ped = Instance.new("Part")
			ped.Name = "Pedestal"
			ped.Anchored = true
			ped.Size = Vector3.new(w + 6, 1, (b.info.mx.Z - b.info.mn.Z) + 6)
			ped.CFrame = CFrame.new(cx, -0.5, rowZ[r])
			ped.Color = Builder.toColor("#2b2f3a")
			ped.Material = Enum.Material.Plastic
			ped.TopSurface = Enum.SurfaceType.Studs
			ped.Parent = showcase
			local trim = Instance.new("Part")
			trim.Name = "PedestalTrim"
			trim.Anchored = true
			trim.CanCollide = false
			trim.Size = Vector3.new(w + 6.6, 0.4, (b.info.mx.Z - b.info.mn.Z) + 6.6)
			trim.CFrame = CFrame.new(cx, -0.85, rowZ[r])
			trim.Color = Builder.toColor(RARITY_COLORS[b.info.spec.Rarity or "Legendary"] or "#ffffff")
			trim.Material = Enum.Material.Neon
			trim.Parent = showcase

			local tag = makeTag(showcase, b.info.spec.DisplayName or b.id, b.info.spec.Rarity or "Legendary", b.info.mx.Y + 1)
			tag.CFrame = CFrame.new(cx, b.info.mx.Y + 1, rowZ[r])
		end
	end

	fs.writeFile("out/Monsters.rbxm", roblox.serializeModel({ folder }))

	-- Showcase place
	local base = Instance.new("Part")
	base.Name = "Baseplate"
	base.Anchored = true
	base.Locked = true
	base.Size = Vector3.new(math.max(512, totalLen + 120), 16, 512)
	base.CFrame = CFrame.new(0, -9, 0)
	base.Color = Builder.toColor("#5bd34a")
	base.Material = Enum.Material.Plastic
	base.TopSurface = Enum.SurfaceType.Studs
	base.Parent = workspace

	local spawn = Instance.new("SpawnLocation")
	spawn.Name = "SpawnLocation"
	spawn.Anchored = true
	spawn.Size = Vector3.new(12, 1, 12)
	spawn.CFrame = CFrame.new(-totalLen / 2 - 20, -0.5, 0)
	spawn.Color = Builder.toColor("#ffd34d")
	spawn.Material = Enum.Material.Neon
	spawn.TopSurface = Enum.SurfaceType.Smooth
	spawn.Duration = 0
	spawn.Parent = workspace

	showcase.Parent = workspace

	lighting.ClockTime = 14.5
	lighting.Brightness = 2.5
	lighting.Ambient = Builder.toColor("#5a5a6e")
	lighting.OutdoorAmbient = Builder.toColor("#8c8ca0")
	lighting.EnvironmentDiffuseScale = 0.6
	lighting.EnvironmentSpecularScale = 0.6
	lighting.GlobalShadows = true
	pcall(function()
		lighting.Technology = Enum.Technology.Future
	end)
	local bloom = Instance.new("BloomEffect")
	bloom.Intensity = 1.2
	bloom.Size = 30
	bloom.Threshold = 0.92
	bloom.Parent = lighting
	local cc = Instance.new("ColorCorrectionEffect")
	cc.Saturation = 0.18
	cc.Contrast = 0.08
	cc.Parent = lighting
	local atmo = Instance.new("Atmosphere")
	atmo.Density = 0.25
	atmo.Haze = 0.6
	atmo.Glare = 0.2
	atmo.Color = Builder.toColor("#c7e6ff")
	atmo.Decay = Builder.toColor("#6a8fbf")
	atmo.Parent = lighting

	fs.writeFile("out/MonsterShowcase.rbxl", roblox.serializePlace(game))
	print(("Wrote out/Monsters.rbxm and out/MonsterShowcase.rbxl (%d monsters)"):format(#built))
end

---------------------------------------------------------------------------
-- Main
---------------------------------------------------------------------------

local L = loadAnimLib()

local ids = {}
local only = {}
for _, a in process.args do
	if a ~= "--" then
		only[a] = true
		table.insert(ids, a)
	end
end
local full = #ids == 0
if full then
	for _, name in fs.readDir("monsters") do
		if fs.isDir("monsters/" .. name) and not name:match("^[_%.]") then
			table.insert(ids, name)
		end
	end
	table.sort(ids, function(a, b)
		local ma = readIfExists("monsters/" .. a .. "/order.txt")
		local mb = readIfExists("monsters/" .. b .. "/order.txt")
		if ma and mb then
			return tonumber(ma) < tonumber(mb)
		end
		return a < b
	end)
end

local built = {}
local failures = 0
for _, id in ids do
	local ok, model, info = pcall(buildMonster, id, L)
	if ok then
		table.insert(built, { id = id, model = model, info = info })
		if info.problems > 0 then
			failures += 1
		end
	else
		failures += 1
		print(("== %s FAILED ==\n   %s"):format(id, tostring(model)))
	end
end

if full and #built > 0 then
	buildPacks(built)
end

if failures > 0 then
	print(("%d monster(s) had problems"):format(failures))
	process.exit(1)
end
