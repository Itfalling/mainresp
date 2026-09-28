--[[
	SCRIPT NAME:  AnimalModels
	SCRIPT TYPE:  ModuleScript (server)
	WHERE:        ServerScriptService/Server/Island/AnimalModels
	DEPENDENCIES: none

	Cartoon-realistic procedural animals with a real JOINT RIG: rounded
	bodies built from ellipsoids, big shiny eyes, soft colours (a cow with
	patches, a pink muzzle, horns, floppy ears and a bell collar; a plump
	chicken with a comb, wattles, fanned tail and toes). Golden variants
	sparkle. The anchored, invisible "Body" is the PrimaryPart (the server
	tweens it around the pen); limbs hang off it on
	Motor6Ds named after the limb (LegFL, LegFR, LegBL, LegBR, Head, Tail,
	WingL, WingR). Every client animates those joints (Motor6D.Transform) from
	the AnimalAnim attribute — walk cycles, head bobs, pecking, tail wags —
	with no uploaded animations needed. Pivot = the animal's feet centre.

	Real art: ServerStorage/Animals/<AnimalId> with an anchored "Body"
	PrimaryPart (joints with the same names are animated automatically).
]]

local ServerStorage = game:GetService("ServerStorage")

local AnimalModels = {}

local function newPart(model: Model, props: { [string]: any }): BasePart
	local part = Instance.new("Part")
	part.Material = Enum.Material.SmoothPlastic
	if props.Shape then
		part.Shape = props.Shape
	end
	for key, value in props do
		if key ~= "Shape" and key ~= "Mesh" then
			(part :: any)[key] = value
		end
	end
	if props.Mesh == "Sphere" then
		local mesh = Instance.new("SpecialMesh")
		mesh.MeshType = Enum.MeshType.Sphere
		mesh.Parent = part
	end
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Parent = model
	return part
end

-- Rigidly attach `part` to `parent` (decorations on a limb or the body).
local function weld(parent: BasePart, part: BasePart)
	part.Anchored = false
	part.Massless = true
	part.CanCollide = false
	local joint = Instance.new("Weld")
	joint.Part0 = parent
	joint.Part1 = part
	joint.C0 = parent.CFrame:ToObjectSpace(part.CFrame)
	joint.Parent = part
end

-- Animated joint: rotation happens around `pivot` (world, at build time).
local function motor(name: string, body: BasePart, limb: BasePart, pivot: Vector3)
	limb.Anchored = false
	limb.Massless = true
	limb.CanCollide = false
	local joint = Instance.new("Motor6D")
	joint.Name = name
	joint.Part0 = body
	joint.Part1 = limb
	joint.C0 = body.CFrame:ToObjectSpace(CFrame.new(pivot))
	joint.C1 = limb.CFrame:ToObjectSpace(CFrame.new(pivot))
	joint.Parent = body
end

local function finish(model: Model, body: BasePart)
	body.PivotOffset = body.CFrame:ToObjectSpace(CFrame.new()) -- feet centre
	model.PrimaryPart = body
end

local EYE_WHITE = Color3.fromRGB(252, 252, 250)
local PUPIL = Color3.fromRGB(28, 22, 20)

-- A cartoon eye: white, big pupil, a sparkle highlight (all welded to `head`).
local function eye(model: Model, head: BasePart, center: Vector3, size: number, lookZ: number)
	weld(head, newPart(model, { Name = "EyeWhite", Shape = Enum.PartType.Ball, Size = Vector3.one * size, CFrame = CFrame.new(center), Color = EYE_WHITE }))
	weld(head, newPart(model, { Name = "Pupil", Shape = Enum.PartType.Ball, Size = Vector3.one * size * 0.6, CFrame = CFrame.new(center + Vector3.new(0, 0.01, lookZ * size * 0.34)), Color = PUPIL }))
	weld(head, newPart(model, { Name = "Sparkle", Shape = Enum.PartType.Ball, Size = Vector3.one * size * 0.22, CFrame = CFrame.new(center + Vector3.new(size * 0.1, size * 0.14, lookZ * size * 0.52)), Color = Color3.new(1, 1, 1), Material = Enum.Material.Neon }))
end

-- The anchored root the server moves around; invisible (the visible body is rounded parts).
local function root(model: Model, size: Vector3, y: number): BasePart
	return newPart(model, { Name = "Body", Size = size, CFrame = CFrame.new(0, y, 0), Transparency = 1, Anchored = true, CanCollide = true })
end

local function goldenShine(body: BasePart)
	local emitter = Instance.new("ParticleEmitter")
	emitter.Name = "GoldenSparkle"
	emitter.Rate = 3
	emitter.Lifetime = NumberRange.new(0.8, 1.3)
	emitter.Speed = NumberRange.new(0.5, 1.5)
	emitter.SpreadAngle = Vector2.new(180, 180)
	emitter.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.25), NumberSequenceKeypoint.new(1, 0) })
	emitter.Color = ColorSequence.new(Color3.fromRGB(255, 240, 150))
	emitter.LightEmission = 1
	emitter.Parent = body
end

local function cow(variant: any): Model
	local model = Instance.new("Model")
	local bodyColor, spotColor = variant.Body, variant.Spots
	local pink = Color3.fromRGB(246, 184, 176)
	local hoofColor = Color3.fromRGB(58, 44, 36)
	local body = root(model, Vector3.new(2.6, 2.2, 4.6), 2.7)

	-- Round barrel body: chest, belly, rump.
	for _, spec in {
		{ "Torso", Vector3.new(2.9, 2.6, 4.9), Vector3.new(0, 2.75, 0.1) },
		{ "Chest", Vector3.new(2.6, 2.5, 2.4), Vector3.new(0, 2.8, -1.7) },
		{ "Rump", Vector3.new(2.75, 2.55, 2.4), Vector3.new(0, 2.9, 1.8) },
		{ "Neck", Vector3.new(1.55, 1.7, 1.7), Vector3.new(0, 3.35, -2.75) },
	} do
		weld(body, newPart(model, { Name = spec[1], Size = spec[2], CFrame = CFrame.new(spec[3]), Color = bodyColor, Mesh = "Sphere" }))
	end
	-- Patches that wrap the body (flattened ellipsoids on the surface).
	for _, spec in {
		{ Vector3.new(0.35, 1.6, 1.9), CFrame.new(1.3, 3.0, 0.4) * CFrame.Angles(0, 0, math.rad(8)) },
		{ Vector3.new(0.35, 1.3, 1.5), CFrame.new(-1.3, 2.7, -0.9) * CFrame.Angles(0, 0, math.rad(-8)) },
		{ Vector3.new(0.35, 1.1, 1.2), CFrame.new(1.25, 2.6, 1.95) },
		{ Vector3.new(1.4, 0.3, 1.6), CFrame.new(0.6, 4.0, 1.2) },
		{ Vector3.new(1.2, 0.3, 1.2), CFrame.new(-0.7, 3.95, -0.5) },
	} do
		weld(body, newPart(model, { Name = "Patch", Size = spec[1], CFrame = spec[2], Color = spotColor, Mesh = "Sphere" }))
	end

	-- Head (animated): skull, muzzle, nostrils, eyes, ears, horns, forelock.
	local head = newPart(model, { Name = "Head", Size = Vector3.new(1.55, 1.5, 1.75), CFrame = CFrame.new(0, 3.75, -3.4), Color = bodyColor, Mesh = "Sphere" })
	weld(head, newPart(model, { Name = "Muzzle", Size = Vector3.new(1.4, 1.0, 1.1), CFrame = CFrame.new(0, 3.3, -4.15), Color = pink, Mesh = "Sphere" }))
	weld(head, newPart(model, { Name = "Blaze", Size = Vector3.new(0.55, 0.9, 0.3), CFrame = CFrame.new(0, 3.95, -4.12) * CFrame.Angles(math.rad(-20), 0, 0), Color = spotColor, Mesh = "Sphere" }))
	for _, side in { -1, 1 } do
		weld(head, newPart(model, { Name = "Nostril", Shape = Enum.PartType.Ball, Size = Vector3.one * 0.2, CFrame = CFrame.new(side * 0.3, 3.42, -4.66), Color = Color3.fromRGB(150, 80, 80) }))
		eye(model, head, Vector3.new(side * 0.5, 3.98, -3.98), 0.44, -1)
		local ear = newPart(model, { Name = "Ear", Size = Vector3.new(0.95, 0.36, 0.56), CFrame = CFrame.new(side * 1.0, 3.95, -3.2) * CFrame.Angles(0, 0, math.rad(side * -22)), Color = bodyColor, Mesh = "Sphere" })
		weld(head, ear)
		weld(head, newPart(model, { Name = "EarInner", Size = Vector3.new(0.62, 0.2, 0.34), CFrame = ear.CFrame * CFrame.new(0, 0.06, -0.08), Color = pink, Mesh = "Sphere" }))
		local hornAngle = if side > 0 then math.rad(55) else math.rad(125)
		weld(head, newPart(model, { Name = "Horn", Shape = Enum.PartType.Cylinder, Size = Vector3.new(0.6, 0.24, 0.24), CFrame = CFrame.new(side * 0.52, 4.52, -3.3) * CFrame.Angles(0, 0, hornAngle), Color = Color3.fromRGB(246, 236, 212) }))
	end
	weld(head, newPart(model, { Name = "Forelock", Size = Vector3.new(0.85, 0.38, 0.65), CFrame = CFrame.new(0, 4.45, -3.45), Color = spotColor, Mesh = "Sphere" }))
	motor("Head", body, head, Vector3.new(0, 3.55, -2.9))

	-- Red collar with a golden bell.
	weld(body, newPart(model, { Name = "Collar", Shape = Enum.PartType.Cylinder, Size = Vector3.new(0.32, 1.8, 1.8), CFrame = CFrame.new(0, 3.2, -2.85) * CFrame.Angles(0, math.rad(90), 0), Color = Color3.fromRGB(206, 58, 58) }))
	weld(body, newPart(model, { Name = "Bell", Shape = Enum.PartType.Ball, Size = Vector3.one * 0.6, CFrame = CFrame.new(0, 2.3, -3.1), Color = Color3.fromRGB(250, 200, 60), Material = Enum.Material.Metal }))

	-- Legs (animated): rounded legs with dark hooves.
	for _, spec in { { "LegFL", -0.8, -1.6 }, { "LegFR", 0.8, -1.6 }, { "LegBL", -0.8, 1.7 }, { "LegBR", 0.8, 1.7 } } do
		local x, z = spec[2], spec[3]
		local leg = newPart(model, { Name = spec[1], Size = Vector3.new(0.74, 2.0, 0.74), CFrame = CFrame.new(x, 1.05, z), Color = bodyColor, Mesh = "Sphere" })
		weld(leg, newPart(model, { Name = "Hoof", Shape = Enum.PartType.Cylinder, Size = Vector3.new(0.36, 0.7, 0.7), CFrame = CFrame.new(x, 0.18, z) * CFrame.Angles(0, 0, math.rad(90)), Color = hoofColor }))
		motor(spec[1], body, leg, Vector3.new(x, 1.95, z))
	end

	-- Udder.
	weld(body, newPart(model, { Name = "Udder", Size = Vector3.new(1.1, 0.65, 1.05), CFrame = CFrame.new(0, 1.55, 1.1), Color = pink, Mesh = "Sphere" }))
	for _, offset in { Vector2.new(-0.22, -0.2), Vector2.new(0.22, -0.2), Vector2.new(-0.22, 0.2), Vector2.new(0.22, 0.2) } do
		weld(body, newPart(model, { Name = "Teat", Size = Vector3.new(0.14, 0.3, 0.14), CFrame = CFrame.new(offset.X, 1.2, 1.1 + offset.Y), Color = pink, Mesh = "Sphere" }))
	end

	-- Tail (animated) with a tuft.
	local tail = newPart(model, { Name = "Tail", Size = Vector3.new(0.2, 1.7, 0.2), CFrame = CFrame.new(0, 2.75, 3.05) * CFrame.Angles(math.rad(14), 0, 0), Color = bodyColor, Mesh = "Sphere" })
	weld(tail, newPart(model, { Name = "Tuft", Size = Vector3.new(0.42, 0.6, 0.42), CFrame = tail.CFrame * CFrame.new(0, -0.85, 0), Color = spotColor, Mesh = "Sphere" }))
	motor("Tail", body, tail, Vector3.new(0, 3.55, 2.95))

	if variant.Id == "Golden" then
		goldenShine(body)
	end
	finish(model, body)
	return model
end

local function chicken(variant: any): Model
	local model = Instance.new("Model")
	local feathers = variant.Body
	local dark = feathers:Lerp(Color3.new(0, 0, 0), 0.12)
	local light = feathers:Lerp(Color3.new(1, 1, 1), 0.25)
	local red = variant.Spots
	local orange = Color3.fromRGB(250, 170, 40)
	local body = root(model, Vector3.new(1.2, 1.1, 1.5), 1.25)

	-- Plump body with a puffed-out breast.
	weld(body, newPart(model, { Name = "Torso", Size = Vector3.new(1.35, 1.25, 1.65), CFrame = CFrame.new(0, 1.25, 0.05), Color = feathers, Mesh = "Sphere" }))
	weld(body, newPart(model, { Name = "Breast", Size = Vector3.new(1.12, 1.15, 1.0), CFrame = CFrame.new(0, 1.35, -0.45), Color = light, Mesh = "Sphere" }))

	-- Head (animated): comb, beak, wattles, eyes.
	local head = newPart(model, { Name = "Head", Size = Vector3.new(0.8, 0.82, 0.8), CFrame = CFrame.new(0, 2.05, -0.62), Color = feathers, Mesh = "Sphere" })
	for index, z in { -0.78, -0.62, -0.46 } do
		weld(head, newPart(model, { Name = "Comb", Size = Vector3.new(0.14, if index == 2 then 0.36 else 0.28, 0.22), CFrame = CFrame.new(0, 2.5 + (if index == 2 then 0.04 else 0), z), Color = red, Mesh = "Sphere" }))
	end
	weld(head, newPart(model, { Name = "Beak", Size = Vector3.new(0.26, 0.16, 0.36), CFrame = CFrame.new(0, 2.02, -1.08) * CFrame.Angles(math.rad(10), 0, 0), Color = orange, Mesh = "Sphere" }))
	weld(head, newPart(model, { Name = "BeakLow", Size = Vector3.new(0.2, 0.1, 0.24), CFrame = CFrame.new(0, 1.93, -1.02), Color = Color3.fromRGB(230, 140, 30), Mesh = "Sphere" }))
	for _, side in { -1, 1 } do
		weld(head, newPart(model, { Name = "Wattle", Size = Vector3.new(0.12, 0.26, 0.14), CFrame = CFrame.new(side * 0.07, 1.75, -0.98), Color = red, Mesh = "Sphere" }))
		eye(model, head, Vector3.new(side * 0.27, 2.14, -0.9), 0.2, -1)
	end
	motor("Head", body, head, Vector3.new(0, 1.7, -0.45))

	-- Legs (animated) with three front toes and one back toe.
	for _, spec in { { "LegL", -0.24 }, { "LegR", 0.24 } } do
		local x = spec[2]
		local leg = newPart(model, { Name = spec[1], Shape = Enum.PartType.Cylinder, Size = Vector3.new(0.66, 0.11, 0.11), CFrame = CFrame.new(x, 0.35, 0) * CFrame.Angles(0, 0, math.rad(90)), Color = orange })
		for toe, angle in { -30, 0, 30, 180 } do
			local length = if toe == 4 then 0.18 else 0.3
			weld(leg, newPart(model, { Name = "Toe", Size = Vector3.new(0.07, 0.05, length), CFrame = CFrame.new(x, 0.03, 0) * CFrame.Angles(0, math.rad(angle), 0) * CFrame.new(0, 0, -length / 2), Color = orange }))
		end
		motor(spec[1], body, leg, Vector3.new(x, 0.68, 0))
	end

	-- Wings (animated): a flight-feather layer and a lighter covert.
	for _, spec in { { "WingL", -0.7 }, { "WingR", 0.7 } } do
		local x = spec[2]
		local wing = newPart(model, { Name = spec[1], Size = Vector3.new(0.22, 0.76, 1.08), CFrame = CFrame.new(x, 1.28, 0.1) * CFrame.Angles(math.rad(-10), 0, 0), Color = dark, Mesh = "Sphere" })
		weld(wing, newPart(model, { Name = "Covert", Size = Vector3.new(0.12, 0.5, 0.7), CFrame = CFrame.new(x * 1.06, 1.42, -0.05), Color = light, Mesh = "Sphere" }))
		motor(spec[1], body, wing, Vector3.new(x, 1.58, 0.05))
	end

	-- Tail (animated): three fanned feathers.
	local tail = newPart(model, { Name = "Tail", Size = Vector3.new(0.26, 0.95, 0.55), CFrame = CFrame.new(0, 1.85, 0.8) * CFrame.Angles(math.rad(-28), 0, 0), Color = dark, Mesh = "Sphere" })
	for _, side in { -1, 1 } do
		weld(tail, newPart(model, { Name = "TailFeather", Size = Vector3.new(0.22, 0.85, 0.5), CFrame = CFrame.new(side * 0.2, 1.78, 0.78) * CFrame.Angles(math.rad(-30), 0, math.rad(side * 20)), Color = feathers, Mesh = "Sphere" }))
	end
	motor("Tail", body, tail, Vector3.new(0, 1.45, 0.7))

	if variant.Id == "Golden" then
		goldenShine(body)
	end
	finish(model, body)
	return model
end

local BUILDERS = { Cow = cow, Chicken = chicken }

function AnimalModels.Build(animalId: string, variant: any): Model
	local folder = ServerStorage:FindFirstChild("Animals")
	local art = folder and folder:FindFirstChild(animalId)
	if art and art:IsA("Model") and art:FindFirstChild("Body") then
		local clone = art:Clone()
		clone.PrimaryPart = clone:FindFirstChild("Body") :: BasePart
		return clone
	end
	local builder = BUILDERS[animalId] or cow
	local model = builder(variant)
	model.Name = animalId
	return model
end

return AnimalModels
