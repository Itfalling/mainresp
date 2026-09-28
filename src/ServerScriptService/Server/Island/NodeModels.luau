--[[
	SCRIPT NAME:  NodeModels
	SCRIPT TYPE:  ModuleScript (server)
	WHERE:        ServerScriptService/Server/Island/NodeModels
	DEPENDENCIES: none

	Procedural resource-node models: oak, pine, snowy pine, palm, maple,
	ancient tree, cactus, rocks, iron, crystal, fiber bush, sand, clay.
	Cartoon-realistic: soft smooth colours, ellipsoid canopies with light
	tops and darker undersides (painted-on shading), branches reaching into
	the leaves, tapered wood-textured trunks, rocks with highlights and
	pebbles, flowers and berries for a little life.

	Each model:
	  * is built around the origin with its base at Y = 0,
	  * has an invisible "Hitbox" PrimaryPart (click target + build blocking),
	  * stores BaseTransparency / BaseCanCollide so pooling can hide/show it.
	Put a Model named after the node's Model key in ServerStorage/Resources
	to use real art instead (keep a Hitbox part).
]]

local ServerStorage = game:GetService("ServerStorage")

local NodeModels = {}

local UPRIGHT = CFrame.Angles(0, 0, math.rad(90))

local function part(model: Model, props: { [string]: any }): BasePart
	local newPart = Instance.new("Part")
	newPart.Anchored = true
	newPart.TopSurface = Enum.SurfaceType.Smooth
	newPart.BottomSurface = Enum.SurfaceType.Smooth
	newPart.Material = Enum.Material.SmoothPlastic
	-- Shape first: changing Shape afterwards can resize the part.
	if props.Shape then
		newPart.Shape = props.Shape
	end
	for key, value in props do
		if key ~= "Shape" and key ~= "Mesh" then
			(newPart :: any)[key] = value
		end
	end
	if props.Mesh == "Sphere" then
		local mesh = Instance.new("SpecialMesh")
		mesh.MeshType = Enum.MeshType.Sphere
		mesh.Parent = newPart
	end
	newPart:SetAttribute("BaseTransparency", newPart.Transparency)
	newPart:SetAttribute("BaseCanCollide", newPart.CanCollide)
	newPart.Parent = model
	return newPart
end

local function hitbox(model: Model, size: Vector3)
	local box = part(model, {
		Name = "Hitbox",
		Size = size,
		CFrame = CFrame.new(0, size.Y / 2, 0),
		Transparency = 1,
		CanCollide = false,
	})
	-- Model pivot = the node's base on the ground (not the hitbox centre).
	box.PivotOffset = CFrame.new(0, -size.Y / 2, 0)
	model.PrimaryPart = box
end

-- Tapered trunk: two stacked cylinders + a root flare.
local function trunk(model: Model, height: number, diameter: number, color: Color3)
	local lower = height * 0.55
	part(model, { Name = "Trunk", Shape = Enum.PartType.Cylinder, Size = Vector3.new(lower, diameter, diameter), CFrame = CFrame.new(0, lower / 2, 0) * UPRIGHT, Color = color, Material = Enum.Material.Wood })
	part(model, {
		Name = "Trunk",
		Shape = Enum.PartType.Cylinder,
		Size = Vector3.new(height - lower + 0.4, diameter * 0.78, diameter * 0.78),
		CFrame = CFrame.new(0, lower + (height - lower) / 2 - 0.2, 0) * UPRIGHT,
		Color = color:Lerp(Color3.new(1, 1, 1), 0.05),
		Material = Enum.Material.Wood,
	})
	part(model, { Name = "Roots", Size = Vector3.new(diameter * 1.8, 0.9, diameter * 1.8), CFrame = CFrame.new(0, 0.2, 0), Color = color:Lerp(Color3.new(0, 0, 0), 0.1), Material = Enum.Material.Wood, Mesh = "Sphere", CanCollide = false })
end

local function canopy(model: Model, random: Random, center: Vector3, radius: number, colors: { Color3 }, count: number, material: Enum.Material?)
	local base = colors[1]
	local leafMaterial = material or Enum.Material.SmoothPlastic
	for index = 1, count do
		local angle = random:NextNumber(0, math.pi * 2)
		local spread = if index == 1 then 0 else random:NextNumber(0.35, 0.75) * radius
		local size = radius * (if index == 1 then 2 else random:NextNumber(1.1, 1.5))
		part(model, {
			Name = "Leaves",
			Size = Vector3.new(size, size * random:NextNumber(0.72, 0.9), size),
			CFrame = CFrame.new(center + Vector3.new(math.cos(angle) * spread, random:NextNumber(-0.6, 0.8), math.sin(angle) * spread)),
			Color = colors[(index - 1) % #colors + 1],
			Material = leafMaterial,
			Mesh = "Sphere",
			CanCollide = false,
		})
	end
	-- Painted-on shading: darker clumps underneath, sunlit clumps on top.
	for index = 1, 3 do
		local angle = index * 2.1 + random:NextNumber(-0.4, 0.4)
		local size = radius * random:NextNumber(1.0, 1.3)
		part(model, {
			Name = "LeavesShade",
			Size = Vector3.new(size, size * 0.6, size),
			CFrame = CFrame.new(center + Vector3.new(math.cos(angle) * radius * 0.55, -radius * 0.55, math.sin(angle) * radius * 0.55)),
			Color = base:Lerp(Color3.new(0, 0, 0), 0.22),
			Material = leafMaterial,
			Mesh = "Sphere",
			CanCollide = false,
		})
	end
	for index = 1, 4 do
		local angle = index * 1.6 + random:NextNumber(-0.3, 0.3)
		local size = radius * random:NextNumber(0.7, 0.95)
		part(model, {
			Name = "LeavesLight",
			Size = Vector3.new(size, size * 0.75, size),
			CFrame = CFrame.new(center + Vector3.new(math.cos(angle) * radius * 0.4, radius * random:NextNumber(0.45, 0.7), math.sin(angle) * radius * 0.4)),
			Color = base:Lerp(Color3.fromRGB(255, 255, 200), 0.22),
			Material = leafMaterial,
			Mesh = "Sphere",
			CanCollide = false,
		})
	end
end

-- A few branches reaching from the trunk top into the canopy.
local function branches(model: Model, random: Random, from: Vector3, radius: number, color: Color3)
	for index = 1, 3 do
		local angle = index * 2.1 + random:NextNumber(-0.3, 0.3)
		local target = from + Vector3.new(math.cos(angle) * radius * 0.7, radius * 0.6, math.sin(angle) * radius * 0.7)
		local length = (target - from).Magnitude
		local middle = (from + target) / 2
		part(model, {
			Name = "Branch",
			Shape = Enum.PartType.Cylinder,
			Size = Vector3.new(length, 0.5, 0.5),
			CFrame = CFrame.lookAt(middle, target) * CFrame.Angles(0, math.rad(90), 0),
			Color = color,
			Material = Enum.Material.Wood,
			CanCollide = false,
		})
	end
end

local BUILDERS: { [string]: (Model, Random) -> () } = {}

BUILDERS.Oak = function(model, random)
	local height = random:NextNumber(6, 7.5)
	trunk(model, height, 1.5, Color3.fromRGB(122, 86, 56))
	branches(model, random, Vector3.new(0, height - 0.5, 0), 3.3, Color3.fromRGB(112, 78, 50))
	canopy(model, random, Vector3.new(0, height + 1.8, 0), 3.3, { Color3.fromRGB(86, 176, 72), Color3.fromRGB(104, 192, 84), Color3.fromRGB(72, 156, 62) }, 5)
	-- A couple of red apples peeking out.
	for index = 1, 3 do
		local angle = index * 2.2 + random:NextNumber(-0.3, 0.3)
		part(model, { Name = "Apple", Shape = Enum.PartType.Ball, Size = Vector3.one * 0.55, CFrame = CFrame.new(math.cos(angle) * 3.1, height + 0.9 + random:NextNumber(0, 1.2), math.sin(angle) * 3.1), Color = Color3.fromRGB(226, 52, 48), CanCollide = false })
	end
	hitbox(model, Vector3.new(3, height + 2, 3))
end

BUILDERS.Maple = function(model, random)
	local height = random:NextNumber(6, 7.5)
	trunk(model, height, 1.4, Color3.fromRGB(96, 66, 50))
	branches(model, random, Vector3.new(0, height - 0.5, 0), 3.2, Color3.fromRGB(86, 58, 44))
	canopy(model, random, Vector3.new(0, height + 1.8, 0), 3.2, { Color3.fromRGB(236, 120, 40), Color3.fromRGB(214, 70, 42), Color3.fromRGB(246, 180, 60) }, 5)
	-- Fallen leaves around the base.
	for index = 1, 5 do
		local angle = index * 1.3 + random:NextNumber(-0.3, 0.3)
		part(model, { Name = "FallenLeaf", Size = Vector3.new(0.7, 0.08, 0.5), CFrame = CFrame.new(math.cos(angle) * random:NextNumber(1.4, 2.6), 0.05, math.sin(angle) * random:NextNumber(1.4, 2.6)) * CFrame.Angles(0, angle, 0), Color = if index % 2 == 0 then Color3.fromRGB(236, 120, 40) else Color3.fromRGB(246, 180, 60), Mesh = "Sphere", CanCollide = false })
	end
	hitbox(model, Vector3.new(3, height + 2, 3))
end

BUILDERS.Ancient = function(model, random)
	trunk(model, 10, 2.8, Color3.fromRGB(96, 72, 62))
	branches(model, random, Vector3.new(0, 9, 0), 4.6, Color3.fromRGB(88, 66, 56))
	canopy(model, random, Vector3.new(0, 12.5, 0), 4.6, { Color3.fromRGB(90, 200, 170), Color3.fromRGB(70, 170, 150), Color3.fromRGB(120, 220, 190) }, 6)
	local glow = part(model, { Name = "Glow", Size = Vector3.new(1, 1, 1), CFrame = CFrame.new(0, 12, 0), Transparency = 1, CanCollide = false })
	local light = Instance.new("PointLight")
	light.Color = Color3.fromRGB(140, 255, 210)
	light.Range = 14
	light.Brightness = 1
	light.Parent = glow
	hitbox(model, Vector3.new(4, 11, 4))
end

-- Stacked, drooping tiers of needles (dark underside, light top) + a tip.
local function pineLayers(model: Model, random: Random, height: number, colors: { Color3 }, snow: boolean)
	local tiers = 6
	local topY = height * 0.35
	for index = 1, tiers do
		local width = 6.6 - index * 0.95
		local y = height * 0.35 + index * 1.35
		topY = y
		local color = colors[(index - 1) % #colors + 1]
		part(model, {
			Name = "NeedlesUnder",
			Size = Vector3.new(width * 1.02, 1.1, width * 1.02),
			CFrame = CFrame.new(0, y - 0.55, 0),
			Color = color:Lerp(Color3.new(0, 0, 0), 0.25),
			Mesh = "Sphere",
			CanCollide = false,
		})
		part(model, {
			Name = "Needles",
			Size = Vector3.new(width, 1.9, width),
			CFrame = CFrame.new(0, y, 0) * CFrame.Angles(0, random:NextNumber(0, 6.28), 0),
			Color = color,
			Mesh = "Sphere",
			CanCollide = false,
		})
		if snow then
			part(model, {
				Name = "Snow",
				Size = Vector3.new(width * 0.78, 0.6, width * 0.78),
				CFrame = CFrame.new(0, y + 0.72, 0),
				Color = Color3.fromRGB(250, 253, 255),
				Mesh = "Sphere",
				CanCollide = false,
			})
		end
	end
	part(model, { Name = "Tip", Size = Vector3.new(1.1, 1.8, 1.1), CFrame = CFrame.new(0, topY + 1.3, 0), Color = if snow then Color3.fromRGB(250, 253, 255) else colors[1]:Lerp(Color3.new(1, 1, 1), 0.15), Mesh = "Sphere", CanCollide = false })
end

BUILDERS.Pine = function(model, random)
	local height = random:NextNumber(7, 8.5)
	trunk(model, height, 1.2, Color3.fromRGB(104, 70, 45))
	pineLayers(model, random, height, { Color3.fromRGB(42, 124, 72), Color3.fromRGB(52, 138, 80), Color3.fromRGB(38, 112, 66) }, false)
	hitbox(model, Vector3.new(2.6, height, 2.6))
end

BUILDERS.SnowPine = function(model, random)
	local height = random:NextNumber(7, 8.5)
	trunk(model, height, 1.2, Color3.fromRGB(96, 70, 52))
	pineLayers(model, random, height, { Color3.fromRGB(46, 110, 84), Color3.fromRGB(56, 124, 92) }, true)
	hitbox(model, Vector3.new(2.6, height, 2.6))
end

BUILDERS.Palm = function(model, random)
	local segments = 6
	local height = random:NextNumber(10, 13)
	local segmentHeight = height / segments
	local lean = random:NextNumber(0.12, 0.25)
	local direction = random:NextNumber(0, math.pi * 2)
	local position = Vector3.zero
	for index = 1, segments do
		local bend = lean * index * 0.5
		local offset = Vector3.new(math.cos(direction) * bend, segmentHeight, math.sin(direction) * bend)
		local center = position + offset / 2
		local thickness = 1.25 - index * 0.09
		part(model, {
			Name = "Trunk",
			Size = Vector3.new(thickness, segmentHeight + 0.25, thickness),
			CFrame = CFrame.lookAt(center, center + offset) * CFrame.Angles(-math.pi / 2, 0, 0),
			Color = if index % 2 == 0 then Color3.fromRGB(168, 126, 80) else Color3.fromRGB(146, 106, 66),
			Material = Enum.Material.Wood,
		})
		position += offset
	end
	for index = 1, 8 do
		-- Each frond rises from the crown, then droops at the tip.
		local angle = (index / 8) * math.pi * 2 + random:NextNumber(-0.2, 0.2)
		local color = if index % 2 == 0 then Color3.fromRGB(76, 178, 82) else Color3.fromRGB(56, 152, 68)
		local crown = CFrame.new(position) * CFrame.Angles(0, angle, 0)
		part(model, { Name = "Frond", Size = Vector3.new(1.6, 0.22, 3.4), CFrame = crown * CFrame.Angles(math.rad(18), 0, 0) * CFrame.new(0, 0, -1.6), Color = color, Mesh = "Sphere", CanCollide = false })
		part(model, { Name = "FrondTip", Size = Vector3.new(1.35, 0.2, 3.4), CFrame = crown * CFrame.Angles(math.rad(18), 0, 0) * CFrame.new(0, 0, -3.1) * CFrame.Angles(math.rad(-42), 0, 0) * CFrame.new(0, 0, -1.4), Color = color:Lerp(Color3.fromRGB(255, 255, 200), 0.1), Mesh = "Sphere", CanCollide = false })
	end
	for index = 1, 3 do
		local angle = index * 2.1
		part(model, {
			Name = "Coconut",
			Shape = Enum.PartType.Ball,
			Size = Vector3.one * 0.85,
			CFrame = CFrame.new(position + Vector3.new(math.cos(angle) * 0.6, -0.6, math.sin(angle) * 0.6)),
			Color = Color3.fromRGB(112, 80, 46),
			CanCollide = false,
		})
	end
	hitbox(model, Vector3.new(2.4, height, 2.4))
end

BUILDERS.Cactus = function(model, random)
	local height = random:NextNumber(4.5, 6.5)
	local green = Color3.fromRGB(80, 160, 90)
	part(model, { Name = "Body", Size = Vector3.new(1.6, height + 0.4, 1.6), CFrame = CFrame.new(0, height / 2, 0), Color = green, Mesh = "Sphere" })
	part(model, { Name = "Body", Shape = Enum.PartType.Cylinder, Size = Vector3.new(height * 0.85, 1.45, 1.45), CFrame = CFrame.new(0, height * 0.42, 0) * UPRIGHT, Color = green })
	-- Light ribs down the body.
	for index = 1, 4 do
		local angle = index * math.pi / 2
		part(model, { Name = "Rib", Size = Vector3.new(0.18, height * 0.9, 0.18), CFrame = CFrame.new(math.cos(angle) * 0.72, height * 0.48, math.sin(angle) * 0.72), Color = green:Lerp(Color3.new(1, 1, 1), 0.18), Mesh = "Sphere", CanCollide = false })
	end
	for _, side in { -1, 1 } do
		local armHeight = random:NextNumber(1.6, 2.4)
		local armY = random:NextNumber(height * 0.35, height * 0.6)
		part(model, { Name = "ArmOut", Size = Vector3.new(1.3, 0.8, 0.8), CFrame = CFrame.new(side * 1.1, armY, 0), Color = green, Mesh = "Sphere" })
		part(model, { Name = "ArmUp", Size = Vector3.new(0.85, armHeight, 0.85), CFrame = CFrame.new(side * 1.5, armY + armHeight / 2, 0), Color = green, Mesh = "Sphere" })
	end
	-- Tiny spines.
	for index = 1, 10 do
		local angle = index * 2.4
		part(model, { Name = "Spine", Shape = Enum.PartType.Ball, Size = Vector3.one * 0.14, CFrame = CFrame.new(math.cos(angle) * 0.8, 0.8 + (index / 10) * height * 0.85, math.sin(angle) * 0.8), Color = Color3.fromRGB(250, 246, 220), CanCollide = false })
	end
	part(model, { Name = "Flower", Size = Vector3.new(0.8, 0.4, 0.8), CFrame = CFrame.new(0, height + 0.1, 0), Color = Color3.fromRGB(255, 120, 160), Mesh = "Sphere", CanCollide = false })
	hitbox(model, Vector3.new(2.4, height, 2.4))
end

-- A chunky boulder pile: shaded body, sunlit highlights, moss and pebbles.
local function rockPile(model: Model, random: Random, color: Color3, scale: number)
	for index = 1, 4 do
		local size = Vector3.new(random:NextNumber(2.2, 3.4), random:NextNumber(1.6, 2.6), random:NextNumber(2.2, 3.4)) * scale * (if index == 1 then 1.2 else 0.8)
		local position = Vector3.new(random:NextNumber(-1, 1), size.Y * 0.35, random:NextNumber(-1, 1))
		local shade = color:Lerp(Color3.new(1, 1, 1), (index - 1) * 0.05)
		part(model, {
			Name = "Rock",
			Size = size,
			CFrame = CFrame.new(position) * CFrame.Angles(random:NextNumber(-0.3, 0.3), random:NextNumber(0, math.pi), random:NextNumber(-0.3, 0.3)),
			Color = shade,
			Mesh = "Sphere",
		})
		-- Sunlit top facet.
		part(model, {
			Name = "RockLight",
			Size = Vector3.new(size.X * 0.62, size.Y * 0.35, size.Z * 0.6),
			CFrame = CFrame.new(position + Vector3.new(-size.X * 0.08, size.Y * 0.3, -size.Z * 0.05)),
			Color = shade:Lerp(Color3.new(1, 1, 1), 0.22),
			Mesh = "Sphere",
			CanCollide = false,
		})
	end
	-- Moss on top and pebbles around the base.
	part(model, { Name = "Moss", Size = Vector3.new(1.6, 0.4, 1.4) * scale, CFrame = CFrame.new(0.2, 2.1 * scale, 0), Color = Color3.fromRGB(104, 168, 76), Mesh = "Sphere", CanCollide = false })
	for index = 1, 5 do
		local angle = index * 1.25 + random:NextNumber(-0.3, 0.3)
		local pebble = random:NextNumber(0.35, 0.6) * scale
		part(model, { Name = "Pebble", Size = Vector3.new(pebble, pebble * 0.6, pebble * 0.9), CFrame = CFrame.new(math.cos(angle) * 2.4 * scale, pebble * 0.2, math.sin(angle) * 2.4 * scale), Color = color:Lerp(Color3.new(1, 1, 1), 0.12), Mesh = "Sphere", CanCollide = false })
	end
end

BUILDERS.Rock = function(model, random)
	rockPile(model, random, Color3.fromRGB(138, 134, 128), 1)
	hitbox(model, Vector3.new(4.4, 3, 4.4))
end

BUILDERS.Iron = function(model, random)
	rockPile(model, random, Color3.fromRGB(108, 104, 100), 1.1)
	for _ = 1, 6 do
		part(model, {
			Name = "Ore",
			Size = Vector3.one * random:NextNumber(0.6, 0.95),
			CFrame = CFrame.new(random:NextNumber(-1.4, 1.4), random:NextNumber(1, 2.4), random:NextNumber(-1.4, 1.4)),
			Color = Color3.fromRGB(214, 128, 78),
			Material = Enum.Material.SmoothPlastic,
			Mesh = "Sphere",
			Reflectance = 0.15,
			CanCollide = false,
		})
	end
	hitbox(model, Vector3.new(4.6, 3.2, 4.6))
end

BUILDERS.Crystal = function(model, random)
	rockPile(model, random, Color3.fromRGB(90, 85, 110), 0.9)
	for index = 1, 5 do
		local height = random:NextNumber(2.2, 3.8)
		local crystalCFrame = CFrame.new(random:NextNumber(-1, 1), 1.4 + height / 2, random:NextNumber(-1, 1)) * CFrame.Angles(random:NextNumber(-0.4, 0.4), index, random:NextNumber(-0.4, 0.4))
		part(model, {
			Name = "Crystal",
			Size = Vector3.new(0.7, height, 0.7),
			CFrame = crystalCFrame,
			Color = Color3.fromRGB(130, 230, 255),
			Material = Enum.Material.Glass,
			Transparency = 0.2,
			Reflectance = 0.2,
			CanCollide = false,
		})
		-- Glowing core inside each crystal.
		part(model, {
			Name = "CrystalCore",
			Size = Vector3.new(0.32, height * 0.8, 0.32),
			CFrame = crystalCFrame,
			Color = Color3.fromRGB(180, 245, 255),
			Material = Enum.Material.Neon,
			Transparency = 0.3,
			CanCollide = false,
		})
	end
	hitbox(model, Vector3.new(4, 4, 4))
end

BUILDERS.Bush = function(model, random)
	for index = 1, 4 do
		local size = random:NextNumber(2, 2.8)
		part(model, {
			Name = "Bush",
			Size = Vector3.new(size, size * 0.8, size),
			CFrame = CFrame.new(math.cos(index * 1.7) * 0.8, 0.9, math.sin(index * 1.7) * 0.8),
			Color = Color3.fromRGB(90, 156 + index * 8, 70),
			Mesh = "Sphere",
			CanCollide = false,
		})
	end
	-- Little white flowers dotted on the bush.
	for index = 1, 5 do
		local angle = index * 1.3
		part(model, { Name = "Flower", Shape = Enum.PartType.Ball, Size = Vector3.one * 0.35, CFrame = CFrame.new(math.cos(angle) * 1.2, 1.5 + (index % 2) * 0.35, math.sin(angle) * 1.2), Color = Color3.fromRGB(255, 250, 236), CanCollide = false })
	end
	for index = 1, 6 do
		part(model, {
			Name = "Fiber",
			Size = Vector3.new(0.12, 1.5, 0.12),
			CFrame = CFrame.new(math.cos(index) * 0.7, 2.1, math.sin(index) * 0.7) * CFrame.Angles(0.2, index, 0.2),
			Color = Color3.fromRGB(232, 214, 140),
			CanCollide = false,
		})
	end
	hitbox(model, Vector3.new(3, 2.6, 3))
end

BUILDERS.Sand = function(model, random)
	part(model, { Name = "Pile", Size = Vector3.new(4.2, 1.6, 4.2), CFrame = CFrame.new(0, 0.4, 0), Color = Color3.fromRGB(240, 220, 160), Material = Enum.Material.Sand, Mesh = "Sphere" })
	part(model, { Name = "Top", Size = Vector3.new(2.6, 1.2, 2.6), CFrame = CFrame.new(0.2, 1, 0.1), Color = Color3.fromRGB(246, 230, 178), Material = Enum.Material.Sand, Mesh = "Sphere" })
	part(model, { Name = "Shell", Size = Vector3.new(0.6, 0.3, 0.5), CFrame = CFrame.new(0.8, 1.3, -0.4) * CFrame.Angles(0, random:NextNumber(0, 6), 0), Color = Color3.fromRGB(255, 200, 190), Mesh = "Sphere", CanCollide = false })
	hitbox(model, Vector3.new(4, 1.6, 4))
end

BUILDERS.Clay = function(model, _random)
	part(model, { Name = "Clay", Size = Vector3.new(4.2, 0.7, 4.2), CFrame = CFrame.new(0, 0.15, 0), Color = Color3.fromRGB(186, 112, 76), Material = Enum.Material.Mud, Mesh = "Sphere" })
	part(model, { Name = "Lump", Size = Vector3.new(1.2, 0.9, 1.1), CFrame = CFrame.new(-0.6, 0.45, 0.4), Color = Color3.fromRGB(170, 100, 70), Material = Enum.Material.Mud, Mesh = "Sphere" })
	part(model, { Name = "Lump", Size = Vector3.new(0.9, 0.7, 0.9), CFrame = CFrame.new(0.8, 0.35, -0.5), Color = Color3.fromRGB(176, 106, 72), Material = Enum.Material.Mud, Mesh = "Sphere" })
	hitbox(model, Vector3.new(4, 1.2, 4))
end

-- seed keeps each node's random shape stable across servers.
function NodeModels.Build(modelKey: string, seed: number): Model
	local folder = ServerStorage:FindFirstChild("Resources")
	local art = folder and folder:FindFirstChild(modelKey)
	if art and art:IsA("Model") and art:FindFirstChild("Hitbox") then
		local clone = art:Clone()
		clone.PrimaryPart = clone:FindFirstChild("Hitbox") :: BasePart
		for _, descendant in clone:GetDescendants() do
			if descendant:IsA("BasePart") then
				descendant.Anchored = true
				descendant:SetAttribute("BaseTransparency", descendant.Transparency)
				descendant:SetAttribute("BaseCanCollide", descendant.CanCollide)
			end
		end
		clone.WorldPivot = CFrame.new()
		return clone
	end

	local model = Instance.new("Model")
	model.Name = modelKey
	local builder = BUILDERS[modelKey] or BUILDERS.Rock
	builder(model, Random.new(seed))
	model.WorldPivot = CFrame.new()
	return model
end

-- Hide / show a pooled node without destroying it (hidden nodes can't be clicked).
function NodeModels.SetVisible(model: Model, visible: boolean)
	for _, descendant in model:GetDescendants() do
		if descendant:IsA("BasePart") then
			local baseTransparency = descendant:GetAttribute("BaseTransparency")
			local baseCollide = descendant:GetAttribute("BaseCanCollide")
			descendant.Transparency = if visible then (if type(baseTransparency) == "number" then baseTransparency else 0) else 1
			descendant.CanCollide = visible and baseCollide == true
			descendant.CanQuery = visible
		elseif descendant:IsA("Light") then
			descendant.Enabled = visible
		end
	end
end

return NodeModels
