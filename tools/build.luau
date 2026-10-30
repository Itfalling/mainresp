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
--   <Pack>Monsters.rbxm / <Pack>Showcase.rbxl   per themed pack (monsters/<Id>/pack.txt)

local fs = require("@lune/fs")
local luau = require("@lune/luau")
local process = require("@lune/process")
local serde = require("@lune/serde")
local roblox = require("@lune/roblox")
local Instance, CFrame, Vector3, Color3, Enum = roblox.Instance, roblox.CFrame, roblox.Vector3, roblox.Color3, roblox.Enum

local Builder = require("../lib/Builder")

local ANIMLIB_SRC = fs.readFile("lib/AnimLib.luau")
local ANIMATOR_SRC = fs.readFile("lib/Animator.luau")
local CONTROL_SRC = fs.readFile("lib/Control.luau")
local UNIONBAKER_SRC = fs.readFile("lib/UnionBaker.luau")
local SWINGCLIENT_SRC = fs.readFile("lib/SwingToolClient.luau")
local SWINGSERVER_SRC = fs.readFile("lib/SwingToolServer.luau")
local AUTOBAKE_SRC = fs.readFile("lib/AutoBake.luau")

local FPS = 30

-- Fail fast if the runtime scripts shipped in every model don't compile.
do
	local ok, err = pcall(luau.compile, ANIMATOR_SRC)
	assert(ok, "lib/Animator.luau does not compile: " .. tostring(err))
	ok, err = pcall(luau.compile, ANIMLIB_SRC)
	assert(ok, "lib/AnimLib.luau does not compile: " .. tostring(err))
	ok, err = pcall(luau.compile, SWINGCLIENT_SRC)
	assert(ok, "lib/SwingToolClient.luau does not compile: " .. tostring(err))
	ok, err = pcall(luau.compile, SWINGSERVER_SRC)
	assert(ok, "lib/SwingToolServer.luau does not compile: " .. tostring(err))
	ok, err = pcall(luau.compile, CONTROL_SRC)
	assert(ok, "lib/Control.luau does not compile: " .. tostring(err))
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
	-- no motion.luau = static prop (crops, decor): built and previewed without animation

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
	if B.hasUnions then
		-- union groups are baked into real UnionOperations in Roblox (CSG can't run offline)
		local baker = Instance.new("ModuleScript")
		baker.Name = "UnionBaker"
		baker.Source = UNIONBAKER_SRC
		baker.Parent = model
		local auto = Instance.new("Script")
		auto.Name = "AutoBake"
		auto.Source = AUTOBAKE_SRC
		auto.Parent = model
		model:SetAttribute("HasUnions", true)
	end

	-- Motion validation + bake
	local M = motionSrc and loadMotion(id, motionSrc, L) or { Cycle = 1, Update = function() end }
	if M.States then
		-- gameplay states: ship the Control helper + per-state timing for game scripts
		local control = Instance.new("ModuleScript")
		control.Name = "Control"
		control.Source = CONTROL_SRC
		control.Parent = model:FindFirstChild("Animation")
		model:SetAttribute("HasStates", true)
		model:SetAttribute("AnimState", M.Base)
		for name, st in M.States do
			model:SetAttribute("Length_" .. name, st.Length)
			if st.Speed then
				model:SetAttribute("Speed_" .. name, st.Speed)
			end
		end
	end
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
	local problems, seenProblem = {}, {}
	local function problem(msg)
		if not seenProblem[msg] then
			seenProblem[msg] = true
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
	local maxCtxLight = 0
	function ctx.light(name, b)
		if not named.Light[name] then problem("ctx.light: no Light named '" .. tostring(name) .. "'") end
		if type(b) == "number" then maxCtxLight = math.max(maxCtxLight, b) end
	end
	local transTracks = {}
	function ctx.transparency(name, v)
		if not named.BasePart[name] then problem("ctx.transparency: no part named '" .. tostring(name) .. "'") end
		transTracks[name] = transTracks[name] or {}
		transTracks[name][frameIdx + 1] = r4(v)
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
			union = info.union,
			neg = info.negate,
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

	local visible = {}
	for _, p in B.parts do
		if p.Transparency < 0.95 then
			table.insert(visible, p)
		end
	end
	local mn, mx = aabb(visible)
	local preview = {
		id = id,
		displayName = spec.DisplayName or id,
		rarity = spec.Rarity or "Legendary",
		element = spec.Element or "",
		bounds = { min = { r4(mn.X), r4(mn.Y), r4(mn.Z) }, max = { r4(mx.X), r4(mx.Y), r4(mx.Z) } },
		bones = bones,
		parts = parts,
		effects = effects,
		anim = { fps = FPS, cycle = cycle, joints = jointNames, frames = frames, events = events, trans = transTracks },
	}
	fs.writeDir("out/preview")
	fs.writeFile("out/preview/" .. id .. ".json", serde.encode("json", preview))

	fs.writeDir("out/models")
	fs.writeFile("out/models/" .. id .. ".rbxm", roblox.serializeModel({ model }))

	-- Hand-held tools: spec.Tool turns the (static) model into a Roblox Tool.
	-- The part named "Handle" is gripped; everything else is welded to it.
	local tool = nil
	if spec.Tool then
		local cfg = spec.Tool
		tool = Instance.new("Tool")
		tool.Name = cfg.Name or (spec.DisplayName or id)
		tool.ToolTip = cfg.ToolTip or tool.Name
		tool.RequiresHandle = true
		tool.CanBeDropped = false
		local src = model:Clone()
		local handle = nil
		for _, d in src:GetDescendants() do
			if d:IsA("BasePart") and d.Name == "Handle" then
				handle = d
			end
		end
		assert(handle, id .. ": spec.Tool needs a part named 'Handle'")
		for _, d in src:GetDescendants() do
			if d:IsA("BasePart") and d.Transparency < 1 then
				local w = d:FindFirstChild("W")
				if w then
					w:Destroy()
				end
				d.Anchored = false
				d.CanCollide = false
				d.Massless = d ~= handle
				d.Parent = tool
				if d ~= handle then
					local weld = Instance.new("Weld")
					weld.Name = "W"
					weld.Part0 = handle
					weld.Part1 = d
					weld.C0 = handle.CFrame:Inverse() * d.CFrame
					weld.Parent = d
				end
			end
		end
		handle.CanTouch = true
		-- default grip assumes the R15 RightGripAttachment (rotated -90 deg on X);
		-- the server script refits it to the real attachment on equip
		local hold = CFrame.fromMatrix(Vector3.new(0, 0, 0), Vector3.new(0, -1, 0), Vector3.new(0, 0, -1), Vector3.new(1, 0, 0))
		tool.Grip = CFrame.new(0, cfg.GripY or 0, 0) * hold:Inverse() * CFrame.Angles(math.rad(-90), 0, 0)
		tool:SetAttribute("GripY", cfg.GripY or 0)
		if cfg.Swing then
			local ev = Instance.new("RemoteEvent")
			ev.Name = "SwingEvent"
			ev.Parent = tool
			local server = Instance.new("Script")
			server.Name = "SwingServer"
			server.Source = SWINGSERVER_SRC
			server.Parent = tool
			local client = Instance.new("Script")
			client.Name = "SwingClient"
			client.RunContext = Enum.RunContext.Client
			client.Source = SWINGCLIENT_SRC
			client.Parent = tool
		end
		fs.writeFile("out/models/" .. id .. "Tool.rbxm", roblox.serializeModel({ tool }))
	end

	-- Style / glow budget checks (stud style, "calm glow")
	local nLights, maxBright = 0, 0
	for _, e in B.effects do
		if e.kind == "light" then
			nLights += 1
			maxBright = math.max(maxBright, e.inst.Brightness)
		end
	end
	local neonPct = B.totalArea > 0 and (B.neonArea / B.totalArea * 100) or 0
	if neonPct > 7 then
		problem(("too much glow: Neon is %.1f%% of the visible surface (max 7%%) - keep neon to small tips, eyes, thin strips"):format(neonPct))
	end
	if nLights > 4 then problem(("too many PointLights: %d (max 4)"):format(nLights)) end
	if maxBright > 1.5 then problem(("PointLight brightness %.1f too high (max 1.5)"):format(maxBright)) end
	if maxCtxLight > 2 then problem(("ctx.light brightness %.1f too high (max 2)"):format(maxCtxLight)) end
	-- part cap scales with rarity: high tiers must be the most detailed pets
	local CAPS = { Common = 260, Uncommon = 280, Rare = 320, Epic = 360, Legendary = 440, Mythic = 460, Secret = 460, Cosmic = 480, Divine = 520, Apex = 680 }
	local cap = CAPS[spec.Rarity or "Legendary"] or 360
	if B.partCount > cap then problem(("too many parts: %d (max %d for %s) - get detail from color blocking, not part spam"):format(B.partCount, cap, spec.Rarity or "?")) end
	local maxH = spec.Rarity == "Apex" and 56 or 24
	if mx.Y - mn.Y > maxH then problem(("too tall: %.1f studs (max %d - a player is 5 studs)"):format(mx.Y - mn.Y, maxH)) end

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
	print(("   neon %.1f%% of surface | lights %d (max brightness %.1f)"):format(neonPct, nLights, maxBright))
	print(("   parts %d (neon %d) | joints %d | emitters %d lights %d trails %d | cycle %.1fs"):format(B.partCount, neon, #jointNames, nEmit, nLight, nTrail, cycle))
	print(("   size W %.1f x H %.1f x L %.1f  (y %.1f..%.1f)"):format(mx.X - mn.X, mx.Y - mn.Y, mx.Z - mn.Z, mn.Y, mx.Y))
	local motionLines = {}
	for _, n in jointNames do
		table.insert(motionLines, ("%s %.0f°%s"):format(n, maxAng[n] or 0, (maxPos[n] or 0) > 0.05 and ("/" .. string.format("%.1f", maxPos[n])) or ""))
	end
	print("   motion range: " .. table.concat(motionLines, ", "))
	if #unused > 0 and motionSrc then
		print("   NOTE unanimated joints: " .. table.concat(unused, ", "))
	end
	if M.ReelSegments then
		local segs = {}
		for _, sg in M.ReelSegments do
			table.insert(segs, ("%s %.2f-%.2f"):format(sg.name, sg.start, sg.start + sg.dur))
		end
		print("   reel (preview times): " .. table.concat(segs, " | "))
	end
	for _, msg in problems do
		print("   PROBLEM: " .. msg)
	end
	local pack = readIfExists(dir .. "/pack.txt")
	pack = pack and pack:gsub("%s", "") or nil
	return model, { mn = mn, mx = mx, problems = #problems, spec = spec, pack = pack ~= "" and pack or nil, tool = tool }
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

-- Rarity name colors (gradient stops), styled like the tycoon tags in the references.
local RARITY_GRADIENTS = {
	Common = { "#d9d9d9", "#a6a6a6" },
	Uncommon = { "#8dff7a", "#2fbf4a" },
	Rare = { "#5fb4ff", "#2f6bff" },
	Epic = { "#d07bff", "#8a3dff" },
	Legendary = { "#ffe35c", "#ff9a1a" },
	Mythic = { "#ff6b9a", "#ff2a4d" },
	Secret = { "#ffffff", "#9aa0b4" },
	Cosmic = { "#7b5cff", "#ff5ce1", "#5ce1ff" },
	Divine = { "#ff8fd8", "#ffe36b", "#8dff8a", "#7fd4ff" },
	Apex = { "#ff3b3b", "#ffb21a", "#ff3b3b" },
}

local function colorSeq(list)
	local kps = {}
	for i, c in list do
		table.insert(kps, roblox.ColorSequenceKeypoint.new((i - 1) / math.max(1, #list - 1), Builder.toColor(c)))
	end
	if #kps == 1 then
		table.insert(kps, roblox.ColorSequenceKeypoint.new(1, Builder.toColor(list[1])))
	end
	return roblox.ColorSequence.new(kps)
end

local function makeTag(parent, displayName, rarity, pos)
	local anchor = Instance.new("Part")
	anchor.Name = "NameTag"
	anchor.Anchored = true
	anchor.CanCollide = false
	anchor.CanQuery = false
	anchor.CanTouch = false
	anchor.Transparency = 1
	anchor.Size = Vector3.new(1, 1, 1)
	anchor.CFrame = CFrame.new(pos)
	anchor.Parent = parent

	local gui = Instance.new("BillboardGui")
	gui.Name = "Tag"
	gui.Size = roblox.UDim2.new(0, 360, 0, 96)
	gui.StudsOffset = Vector3.new(0, 2, 0)
	gui.LightInfluence = 0
	gui.MaxDistance = 160
	gui.Parent = anchor

	local function label(text, y, h, white)
		local t = Instance.new("TextLabel")
		t.BackgroundTransparency = 1
		t.Size = roblox.UDim2.new(1, 0, h, 0)
		t.Position = roblox.UDim2.new(0, 0, y, 0)
		t.Text = text
		t.TextScaled = true
		t.FontFace = roblox.Font.fromEnum(Enum.Font.FredokaOne)
		t.TextColor3 = Color3.new(1, 1, 1)
		local s = Instance.new("UIStroke")
		s.Thickness = 2.5
		s.Color = Builder.toColor("#141414")
		s.Parent = t
		if not white then
			local g = Instance.new("UIGradient")
			g.Color = colorSeq(RARITY_GRADIENTS[rarity] or { "#ffffff" })
			g.Parent = t
		end
		t.Parent = gui
		return t
	end
	label(rarity, 0, 0.42, false)
	label(displayName, 0.42, 0.58, true)
	return anchor
end

-- Blue X-braced pen fence (like the pet pens in the reference game).
local POST, RAIL, BRACE = "#1f5fe0", "#2f8cff", "#36b9ff"
local sceneParts = {}
local function block(parent, size, cf, color, name)
	table.insert(sceneParts, { size = { r4(size.X), r4(size.Y), r4(size.Z) }, cf = cfArr(cf), color = color })
	local p = Instance.new("Part")
	p.Name = name or "Fence"
	p.Anchored = true
	p.Size = size
	p.CFrame = cf
	p.Color = Builder.toColor(color)
	p.Material = Enum.Material.Plastic
	for _, f in { "TopSurface", "BottomSurface", "FrontSurface", "BackSurface", "LeftSurface", "RightSurface" } do
		p[f] = Enum.SurfaceType.Studs
	end
	p.Parent = parent
	return p
end

local function fenceRun(parent, a, b)
	-- a, b: Vector3 corners on the ground; posts + top/bottom rails + X braces
	local dir = b - a
	local len = dir.Magnitude
	local n = math.max(1, math.floor(len / 6 + 0.5))
	local seg = len / n
	local yaw = CFrame.lookAt(a, b)
	local H = 3.6
	for i = 0, n do
		local p = a + dir.Unit * (seg * i)
		block(parent, Vector3.new(1.2, H + 0.6, 1.2), CFrame.new(p + Vector3.new(0, (H + 0.6) / 2, 0)) * yaw.Rotation, POST, "FencePost")
	end
	local mid = (a + b) / 2
	block(parent, Vector3.new(0.6, 0.6, len), CFrame.new(mid + Vector3.new(0, H - 0.3, 0)) * yaw.Rotation, RAIL, "FenceRail")
	block(parent, Vector3.new(0.6, 0.6, len), CFrame.new(mid + Vector3.new(0, 0.6, 0)) * yaw.Rotation, RAIL, "FenceRail")
	for i = 0, n - 1 do
		local c = a + dir.Unit * (seg * (i + 0.5)) + Vector3.new(0, H / 2 + 0.15, 0)
		local diag = math.sqrt(seg * seg + (H - 1.2) ^ 2)
		local ang = math.atan2(H - 1.2, seg)
		for _, sgn in { 1, -1 } do
			block(parent, Vector3.new(0.45, 0.6, diag - 0.4), CFrame.new(c) * yaw.Rotation * CFrame.Angles(sgn * ang, 0, 0), BRACE, "FenceBrace")
		end
	end
end

local function makePen(parent, cx, cz, w, d)
	local pen = Instance.new("Model")
	pen.Name = "Pen"
	pen.Parent = parent
	local x0, x1, z0, z1 = cx - w / 2, cx + w / 2, cz - d / 2, cz + d / 2
	local y = 0
	fenceRun(pen, Vector3.new(x0, y, z0), Vector3.new(x1, y, z0))
	fenceRun(pen, Vector3.new(x1, y, z0), Vector3.new(x1, y, z1))
	fenceRun(pen, Vector3.new(x1, y, z1), Vector3.new(x0, y, z1))
	fenceRun(pen, Vector3.new(x0, y, z1), Vector3.new(x0, y, z0))
	-- slightly darker grass pad inside the pen
	local pad = block(pen, Vector3.new(w - 1.2, 0.2, d - 1.2), CFrame.new(cx, -0.05, cz), "#4fc23d", "PenFloor")
	pad.CanCollide = false
	return pen
end

local function buildPacks(built, rbxmPath, rbxlPath, scenePath)
	table.clear(sceneParts) -- fences are per showcase
	local sceneMonsters = {}
	local folder = Instance.new("Folder")
	folder.Name = "Monsters"

	local game = Instance.new("DataModel")
	local workspace = game:GetService("Workspace")
	local lighting = game:GetService("Lighting")

	local showcase = Instance.new("Folder")
	showcase.Name = "MonsterShowcase"
	local pens = Instance.new("Folder")
	pens.Name = "Pens"
	pens.Parent = showcase
	local tags = Instance.new("Folder")
	tags.Name = "NameTags"
	tags.Parent = showcase

	local half = math.ceil(#built / 2)
	local rows = { {}, {} }
	for i, b in built do
		table.insert(rows[i <= half and 1 or 2], b)
	end
	local GAP = 9
	local aisle = 26
	-- each pen fits its own monster; all pens line up along the aisle
	local function penDepth(b)
		return b.info.mx.Z - b.info.mn.Z + 16
	end

	local totalLen = 0
	for r = 1, 2 do
		local widths = {}
		local x = 0
		for _, b in rows[r] do
			local w = math.max(b.info.mx.X - b.info.mn.X, b.info.mx.Z - b.info.mn.Z) + 12
			table.insert(widths, w)
			x += w + GAP
		end
		local rowLen = x - GAP
		totalLen = math.max(totalLen, rowLen)
		local cursor = -rowLen / 2
		for i, b in rows[r] do
			local w = widths[i]
			local cx = cursor + w / 2
			cursor += w + GAP
			local center = (b.info.mn + b.info.mx) / 2
			local d = penDepth(b)
			local cz = (r == 1 and -1 or 1) * (aisle / 2 + d / 2)
			-- row 1 (at -Z) turns around to face +Z, the aisle; row 2 faces -Z (default)
			local rot = r == 1 and CFrame.Angles(0, math.pi, 0) or CFrame.new()
			local offset = CFrame.new(cx, 0, cz) * rot * CFrame.new(-center.X, 0, -center.Z)

			local packCopy = b.model:Clone()
			moveModel(packCopy, offset)
			packCopy.Parent = folder

			local placeCopy = b.model:Clone()
			moveModel(placeCopy, offset)
			if placeCopy:GetAttribute("HasStates") then
				placeCopy:SetAttribute("AnimState", "Reel") -- showcase: demo every state
			end
			placeCopy.Parent = showcase
			if b.info.tool then
				-- every player spawns holding it
				b.info.tool:Clone().Parent = game:GetService("StarterPack")
			end

			makePen(pens, cx, cz, w, d)
			table.insert(sceneMonsters, { id = b.id, cf = cfArr(offset), name = b.info.spec.DisplayName or b.id, rarity = b.info.spec.Rarity or "Legendary", tag = { cx, b.info.mx.Y + 2.5, cz } })
			makeTag(tags, b.info.spec.DisplayName or b.id, b.info.spec.Rarity or "Legendary", Vector3.new(cx, b.info.mx.Y + 1.5, cz))
		end
	end

	fs.writeFile(rbxmPath, roblox.serializeModel({ folder }))
	fs.writeFile(scenePath, serde.encode("json", { monsters = sceneMonsters, parts = sceneParts, length = totalLen }))

	-- Showcase place: studded green baseplate, spawn in the aisle, tuned lighting
	local base = Instance.new("Part")
	base.Name = "Baseplate"
	base.Anchored = true
	base.Locked = true
	base.Size = Vector3.new(math.max(512, totalLen + 160), 16, 512)
	base.CFrame = CFrame.new(0, -8, 0)
	base.Color = Builder.toColor("#5ad13f")
	base.Material = Enum.Material.Plastic
	base.TopSurface = Enum.SurfaceType.Studs
	base.Parent = workspace

	local spawn = Instance.new("SpawnLocation")
	spawn.Name = "SpawnLocation"
	spawn.Anchored = true
	spawn.Size = Vector3.new(8, 1, 8)
	spawn.CFrame = CFrame.new(-totalLen / 2 - 14, 0.5, 0) * CFrame.Angles(0, -math.pi / 2, 0)
	spawn.Color = Builder.toColor("#f2f2f2")
	spawn.Material = Enum.Material.Plastic
	spawn.TopSurface = Enum.SurfaceType.Studs
	spawn.Duration = 0
	spawn.Parent = workspace

	showcase.Parent = workspace

	-- Bright, clean daylight. Bloom threshold is high so ONLY neon accents glow
	-- (low thresholds make white plastic bloom and wash the pets out).
	lighting.ClockTime = 14
	lighting.GeographicLatitude = 35
	lighting.Brightness = 3
	lighting.Ambient = Builder.toColor("#4a4a55")
	lighting.OutdoorAmbient = Builder.toColor("#8f93a3")
	lighting.EnvironmentDiffuseScale = 0.5
	lighting.EnvironmentSpecularScale = 0.25
	lighting.ShadowSoftness = 0.25
	lighting.GlobalShadows = true
	lighting.ExposureCompensation = 0
	pcall(function()
		lighting.Technology = Enum.Technology.Future
	end)
	local bloom = Instance.new("BloomEffect")
	bloom.Intensity = 0.55
	bloom.Size = 18
	bloom.Threshold = 1.8
	bloom.Parent = lighting
	local cc = Instance.new("ColorCorrectionEffect")
	cc.Saturation = 0.12
	cc.Contrast = 0.06
	cc.Brightness = 0.01
	cc.Parent = lighting
	local rays = Instance.new("SunRaysEffect")
	rays.Intensity = 0.04
	rays.Spread = 0.6
	rays.Parent = lighting
	local atmo = Instance.new("Atmosphere")
	atmo.Density = 0.22
	atmo.Offset = 0.1
	atmo.Haze = 0.3
	atmo.Glare = 0
	atmo.Color = Builder.toColor("#cfe9ff")
	atmo.Decay = Builder.toColor("#8fb7e0")
	atmo.Parent = lighting
	local sky = Instance.new("Sky")
	sky.Name = "Sky"
	sky.SunAngularSize = 14
	sky.Parent = lighting

	fs.writeFile(rbxlPath, roblox.serializePlace(game))
	print(("Wrote %s and %s (%d monsters)"):format(rbxmPath, rbxlPath, #built))
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
	local order = {}
	for _, id in ids do
		local o = readIfExists("monsters/" .. id .. "/order.txt")
		order[id] = o and tonumber((o:gsub("%s", ""))) or 999
	end
	table.sort(ids, function(a, b)
		if order[a] ~= order[b] then
			return order[a] < order[b]
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
	buildPacks(built, "out/Monsters.rbxm", "out/MonsterShowcase.rbxl", "out/preview/_showcase.json")
	-- themed packs: monsters/<Id>/pack.txt names the pack (e.g. Atlantis, Guardian)
	local packs, packOrder = {}, {}
	for _, b in built do
		local p = b.info.pack
		if p then
			if not packs[p] then
				packs[p] = {}
				table.insert(packOrder, p)
			end
			table.insert(packs[p], b)
		end
	end
	for _, p in packOrder do
		buildPacks(packs[p], "out/" .. p .. "Monsters.rbxm", "out/" .. p .. "Showcase.rbxl", "out/preview/_showcase_" .. p .. ".json")
	end
end

if failures > 0 then
	print(("%d monster(s) had problems"):format(failures))
	process.exit(1)
end
