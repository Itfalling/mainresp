--[[
	SCRIPT NAME:  AnimalModels
	SCRIPT TYPE:  ModuleScript (server)
	WHERE:        ServerScriptService/Server/Island/AnimalModels
	DEPENDENCIES: none

	Cute procedural animals. The anchored "Body" is the PrimaryPart; every
	other part is welded to it (explicit Weld C0), so moving/tweening the Body
	moves the whole animal. Each model also gets an AnimationController +
	Animator so real Cow*/Chicken* animations play once you upload them.
	Pivot = the animal's feet centre on the ground.

	Real art: ServerStorage/Animals/<AnimalId> with an anchored "Body"
	PrimaryPart and a "Head" part (for the Pet prompt).
]]

local ServerStorage = game:GetService("ServerStorage")

local AnimalModels = {}

local function add(model: Model, body: BasePart?, props: { [string]: any }): BasePart
	local newPart = Instance.new("Part")
	if props.Shape then
		newPart.Shape = props.Shape
	end
	for key, value in props do
		if key ~= "Shape" then
			(newPart :: any)[key] = value
		end
	end
	newPart.TopSurface = Enum.SurfaceType.Smooth
	newPart.BottomSurface = Enum.SurfaceType.Smooth
	if body then
		newPart.Anchored = false
		newPart.Massless = true
		local weld = Instance.new("Weld")
		weld.Part0 = body
		weld.Part1 = newPart
		weld.C0 = body.CFrame:ToObjectSpace(newPart.CFrame)
		weld.Parent = newPart
	else
		newPart.Anchored = true
	end
	newPart.Parent = model
	return newPart
end

local function finish(model: Model, body: BasePart)
	model.PrimaryPart = body
	model.WorldPivot = CFrame.new() -- feet centre
	local controller = Instance.new("AnimationController")
	local animator = Instance.new("Animator")
	animator.Parent = controller
	controller.Parent = model
end

local function cow(variant: any): Model
	local model = Instance.new("Model")
	local bodyColor, spotColor = variant.Body, variant.Spots
	local body = add(model, nil, { Name = "Body", Size = Vector3.new(2.6, 2.1, 4.2), CFrame = CFrame.new(0, 2.55, 0), Color = bodyColor, CanCollide = true })
	for _, spec in { { 1.31, 2.8, 0.6, 1.4 }, { -1.31, 2.4, -0.8, 1.2 }, { 1.31, 2.2, -1.2, 0.9 }, { -1.31, 2.9, 1, 1 } } do
		add(model, body, { Name = "Spot", Size = Vector3.new(0.05, spec[4], spec[4] * 1.2), CFrame = CFrame.new(spec[1], spec[2], spec[3]), Color = spotColor, CanCollide = false })
	end
	add(model, body, { Name = "Head", Size = Vector3.new(1.7, 1.6, 1.6), CFrame = CFrame.new(0, 3.3, -2.6), Color = bodyColor, CanCollide = false })
	add(model, body, { Name = "Snout", Size = Vector3.new(1.3, 0.8, 0.6), CFrame = CFrame.new(0, 2.9, -3.55), Color = Color3.fromRGB(245, 170, 170), CanCollide = false })
	for _, x in { -0.55, 0.55 } do
		add(model, body, { Name = "Eye", Shape = Enum.PartType.Ball, Size = Vector3.one * 0.3, CFrame = CFrame.new(x, 3.6, -3.4), Color = Color3.fromRGB(30, 30, 30), CanCollide = false })
		add(model, body, { Name = "Horn", Size = Vector3.new(0.25, 0.6, 0.25), CFrame = CFrame.new(x * 1.2, 4.3, -2.6), Color = Color3.fromRGB(245, 235, 210), CanCollide = false })
		add(model, body, { Name = "Ear", Size = Vector3.new(0.6, 0.3, 0.3), CFrame = CFrame.new(x * 2.1, 3.9, -2.5), Color = bodyColor, CanCollide = false })
	end
	for _, x in { -0.85, 0.85 } do
		for _, z in { -1.5, 1.5 } do
			add(model, body, { Name = "Leg", Size = Vector3.new(0.6, 1.5, 0.6), CFrame = CFrame.new(x, 0.75, z), Color = bodyColor, CanCollide = false })
			add(model, body, { Name = "Hoof", Size = Vector3.new(0.62, 0.25, 0.62), CFrame = CFrame.new(x, 0.12, z), Color = Color3.fromRGB(60, 45, 35), CanCollide = false })
		end
	end
	add(model, body, { Name = "Udder", Size = Vector3.new(0.9, 0.5, 0.9), CFrame = CFrame.new(0, 1.35, 0.9), Color = Color3.fromRGB(245, 175, 175), CanCollide = false })
	add(model, body, { Name = "Tail", Size = Vector3.new(0.2, 1.4, 0.2), CFrame = CFrame.new(0, 2.6, 2.2) * CFrame.Angles(math.rad(20), 0, 0), Color = bodyColor, CanCollide = false })
	finish(model, body)
	return model
end

local function chicken(variant: any): Model
	local model = Instance.new("Model")
	local body = add(model, nil, { Name = "Body", Size = Vector3.new(1.2, 1.1, 1.5), CFrame = CFrame.new(0, 1.15, 0), Color = variant.Body, CanCollide = true })
	add(model, body, { Name = "Head", Size = Vector3.new(0.75, 0.75, 0.75), CFrame = CFrame.new(0, 1.9, -0.6), Color = variant.Body, CanCollide = false })
	add(model, body, { Name = "Beak", Size = Vector3.new(0.3, 0.2, 0.35), CFrame = CFrame.new(0, 1.85, -1.1), Color = Color3.fromRGB(250, 170, 40), CanCollide = false })
	add(model, body, { Name = "Comb", Size = Vector3.new(0.15, 0.35, 0.45), CFrame = CFrame.new(0, 2.4, -0.6), Color = variant.Spots, CanCollide = false })
	for _, x in { -0.22, 0.22 } do
		add(model, body, { Name = "Eye", Shape = Enum.PartType.Ball, Size = Vector3.one * 0.15, CFrame = CFrame.new(x, 2, -0.95), Color = Color3.fromRGB(20, 20, 20), CanCollide = false })
		add(model, body, { Name = "Leg", Size = Vector3.new(0.12, 0.6, 0.12), CFrame = CFrame.new(x, 0.3, 0), Color = Color3.fromRGB(250, 170, 40), CanCollide = false })
		add(model, body, { Name = "Wing", Size = Vector3.new(0.15, 0.7, 1), CFrame = CFrame.new(x * 3, 1.2, 0.05), Color = variant.Body:Lerp(Color3.new(0, 0, 0), 0.08), CanCollide = false })
	end
	add(model, body, { Name = "Tail", Size = Vector3.new(0.7, 0.6, 0.3), CFrame = CFrame.new(0, 1.6, 0.8) * CFrame.Angles(math.rad(-30), 0, 0), Color = variant.Body, CanCollide = false })
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
