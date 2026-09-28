--[[
	SCRIPT NAME:  AnimalModels
	SCRIPT TYPE:  ModuleScript (server)
	WHERE:        ServerScriptService/Server/Island/AnimalModels
	DEPENDENCIES: none

	Cute procedural animals with a real JOINT RIG. The anchored "Body" is the
	PrimaryPart (the server tweens it around the pen); limbs hang off it on
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

local function cow(variant: any): Model
	local model = Instance.new("Model")
	local bodyColor, spotColor = variant.Body, variant.Spots
	local body = newPart(model, { Name = "Body", Size = Vector3.new(2.7, 2.2, 4.3), CFrame = CFrame.new(0, 2.6, 0), Color = bodyColor, Anchored = true, CanCollide = true })
	newPart(model, { Name = "Belly", Size = Vector3.new(2.8, 1.6, 3.6), CFrame = CFrame.new(0, 2.2, 0), Color = bodyColor, Mesh = "Sphere" })
	weld(body, model:FindFirstChild("Belly") :: BasePart)
	for _, spec in { { 1.36, 2.9, 0.6, 1.4 }, { -1.36, 2.5, -0.8, 1.2 }, { 1.36, 2.3, -1.2, 0.9 }, { -1.36, 3, 1, 1 } } do
		weld(body, newPart(model, { Name = "Spot", Size = Vector3.new(0.05, spec[4], spec[4] * 1.2), CFrame = CFrame.new(spec[1], spec[2], spec[3]), Color = spotColor }))
	end
	local head = newPart(model, { Name = "Head", Size = Vector3.new(1.7, 1.6, 1.7), CFrame = CFrame.new(0, 3.4, -2.7), Color = bodyColor })
	for _, piece in {
		{ Name = "Snout", Size = Vector3.new(1.35, 0.85, 0.7), CFrame = CFrame.new(0, 3.0, -3.65), Color = Color3.fromRGB(245, 170, 170) },
		{ Name = "Nostril", Size = Vector3.new(0.9, 0.25, 0.1), CFrame = CFrame.new(0, 3.1, -4.02), Color = Color3.fromRGB(150, 80, 80) },
	} do
		weld(head, newPart(model, piece))
	end
	for _, x in { -0.5, 0.5 } do
		weld(head, newPart(model, { Name = "Eye", Shape = Enum.PartType.Ball, Size = Vector3.one * 0.32, CFrame = CFrame.new(x, 3.7, -3.52), Color = Color3.fromRGB(25, 25, 25) }))
		weld(head, newPart(model, { Name = "Shine", Shape = Enum.PartType.Ball, Size = Vector3.one * 0.1, CFrame = CFrame.new(x + 0.06, 3.78, -3.66), Color = Color3.new(1, 1, 1) }))
		weld(head, newPart(model, { Name = "Horn", Size = Vector3.new(0.25, 0.6, 0.25), CFrame = CFrame.new(x * 1.2, 4.4, -2.6), Color = Color3.fromRGB(245, 235, 210) }))
		weld(head, newPart(model, { Name = "Ear", Size = Vector3.new(0.7, 0.3, 0.4), CFrame = CFrame.new(x * 2.2, 3.95, -2.55), Color = bodyColor, Mesh = "Sphere" }))
	end
	motor("Head", body, head, Vector3.new(0, 3.3, -2.0))
	for _, spec in { { "LegFL", -0.85, -1.5 }, { "LegFR", 0.85, -1.5 }, { "LegBL", -0.85, 1.5 }, { "LegBR", 0.85, 1.5 } } do
		local leg = newPart(model, { Name = spec[1], Size = Vector3.new(0.62, 1.6, 0.62), CFrame = CFrame.new(spec[2], 0.8, spec[3]), Color = bodyColor })
		weld(leg, newPart(model, { Name = "Hoof", Size = Vector3.new(0.66, 0.28, 0.66), CFrame = CFrame.new(spec[2], 0.14, spec[3]), Color = Color3.fromRGB(60, 45, 35) }))
		motor(spec[1], body, leg, Vector3.new(spec[2], 1.6, spec[3]))
	end
	weld(body, newPart(model, { Name = "Udder", Size = Vector3.new(0.95, 0.55, 0.95), CFrame = CFrame.new(0, 1.35, 0.9), Color = Color3.fromRGB(245, 175, 175), Mesh = "Sphere" }))
	local tail = newPart(model, { Name = "Tail", Size = Vector3.new(0.2, 1.4, 0.2), CFrame = CFrame.new(0, 2.7, 2.35) * CFrame.Angles(math.rad(20), 0, 0), Color = bodyColor })
	weld(tail, newPart(model, { Name = "Tuft", Size = Vector3.new(0.35, 0.45, 0.35), CFrame = tail.CFrame * CFrame.new(0, -0.75, 0), Color = spotColor, Mesh = "Sphere" }))
	motor("Tail", body, tail, Vector3.new(0, 3.35, 2.15))
	finish(model, body)
	return model
end

local function chicken(variant: any): Model
	local model = Instance.new("Model")
	local body = newPart(model, { Name = "Body", Size = Vector3.new(1.25, 1.15, 1.55), CFrame = CFrame.new(0, 1.2, 0), Color = variant.Body, Mesh = "Sphere", Anchored = true, CanCollide = true })
	local head = newPart(model, { Name = "Head", Size = Vector3.new(0.78, 0.8, 0.78), CFrame = CFrame.new(0, 1.95, -0.62), Color = variant.Body, Mesh = "Sphere" })
	weld(head, newPart(model, { Name = "Beak", Size = Vector3.new(0.3, 0.2, 0.38), CFrame = CFrame.new(0, 1.9, -1.12), Color = Color3.fromRGB(250, 170, 40) }))
	weld(head, newPart(model, { Name = "Comb", Size = Vector3.new(0.15, 0.38, 0.45), CFrame = CFrame.new(0, 2.45, -0.62), Color = variant.Spots, Mesh = "Sphere" }))
	weld(head, newPart(model, { Name = "Wattle", Size = Vector3.new(0.14, 0.25, 0.14), CFrame = CFrame.new(0, 1.68, -1.0), Color = variant.Spots, Mesh = "Sphere" }))
	for _, x in { -0.22, 0.22 } do
		weld(head, newPart(model, { Name = "Eye", Shape = Enum.PartType.Ball, Size = Vector3.one * 0.15, CFrame = CFrame.new(x, 2.05, -0.97), Color = Color3.fromRGB(20, 20, 20) }))
	end
	motor("Head", body, head, Vector3.new(0, 1.65, -0.45))
	for _, spec in { { "LegL", -0.22 }, { "LegR", 0.22 } } do
		local leg = newPart(model, { Name = spec[1], Size = Vector3.new(0.12, 0.66, 0.12), CFrame = CFrame.new(spec[2], 0.33, 0), Color = Color3.fromRGB(250, 170, 40) })
		weld(leg, newPart(model, { Name = "Foot", Size = Vector3.new(0.3, 0.06, 0.34), CFrame = CFrame.new(spec[2], 0.03, -0.08), Color = Color3.fromRGB(250, 170, 40) }))
		motor(spec[1], body, leg, Vector3.new(spec[2], 0.66, 0))
	end
	for _, spec in { { "WingL", -0.66 }, { "WingR", 0.66 } } do
		local wing = newPart(model, { Name = spec[1], Size = Vector3.new(0.16, 0.72, 1.05), CFrame = CFrame.new(spec[2], 1.25, 0.05), Color = variant.Body:Lerp(Color3.new(0, 0, 0), 0.08), Mesh = "Sphere" })
		motor(spec[1], body, wing, Vector3.new(spec[2], 1.55, 0.05))
	end
	local tail = newPart(model, { Name = "Tail", Size = Vector3.new(0.7, 0.65, 0.3), CFrame = CFrame.new(0, 1.65, 0.82) * CFrame.Angles(math.rad(-30), 0, 0), Color = variant.Body, Mesh = "Sphere" })
	motor("Tail", body, tail, Vector3.new(0, 1.4, 0.7))
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
