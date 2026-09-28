--[[
	SCRIPT NAME:  NodeModels
	SCRIPT TYPE:  ModuleScript (server)
	WHERE:        ServerScriptService/Server/Island/NodeModels
	DEPENDENCIES: none

	Procedural resource-node models (trees, rocks, ore, crystals, bushes,
	sand, clay). Each model:
	  * is built around the origin with its base at Y = 0,
	  * has an invisible "Hitbox" PrimaryPart (targeting + build blocking),
	  * has a "PromptAnchor" attachment at a comfortable height,
	  * stores BaseTransparency on every part so pooling can hide/show it.
	Put a Model named after the node's Model key in ServerStorage/Resources
	to use real art instead (keep a Hitbox part and a PromptAnchor).
]]

local ServerStorage = game:GetService("ServerStorage")

local NodeModels = {}

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
		if key ~= "Shape" then
			(newPart :: any)[key] = value
		end
	end
	newPart:SetAttribute("BaseTransparency", newPart.Transparency)
	newPart:SetAttribute("BaseCanCollide", newPart.CanCollide)
	newPart.Parent = model
	return newPart
end

local function hitbox(model: Model, size: Vector3, promptHeight: number)
	local box = part(model, {
		Name = "Hitbox",
		Size = size,
		CFrame = CFrame.new(0, size.Y / 2, 0),
		Transparency = 1,
		CanCollide = false,
	})
	local anchor = Instance.new("Attachment")
	anchor.Name = "PromptAnchor"
	anchor.Position = Vector3.new(0, promptHeight - size.Y / 2, 0)
	anchor.Parent = box
	model.PrimaryPart = box
end

local function vertical(height: number, diameter: number): Vector3
	return Vector3.new(height, diameter, diameter)
end
local UPRIGHT = CFrame.Angles(0, 0, math.rad(90))

local BUILDERS: { [string]: (Model, Random) -> () } = {}

BUILDERS.Oak = function(model, random)
	local trunkHeight = random:NextNumber(5.5, 7)
	part(model, { Name = "Trunk", Shape = Enum.PartType.Cylinder, Size = vertical(trunkHeight, 1.6), CFrame = CFrame.new(0, trunkHeight / 2, 0) * UPRIGHT, Color = Color3.fromRGB(120, 85, 55), Material = Enum.Material.Wood })
	local greens = { Color3.fromRGB(80, 170, 70), Color3.fromRGB(95, 185, 80), Color3.fromRGB(70, 150, 60) }
	for index, spec in { { 0, 0, 0, 6.2 }, { 1.6, -0.6, 0.8, 4.6 }, { -1.4, -0.4, -1, 4.4 } } do
		part(model, {
			Name = "Leaves",
			Shape = Enum.PartType.Ball,
			Size = Vector3.one * spec[4],
			CFrame = CFrame.new(spec[1], trunkHeight + 1.8 + spec[2], spec[3]),
			Color = greens[index],
			Material = Enum.Material.Grass,
			CanCollide = false,
		})
	end
	hitbox(model, Vector3.new(3, trunkHeight + 1, 3), 3)
end

BUILDERS.Pine = function(model, random)
	local trunkHeight = random:NextNumber(4, 5)
	part(model, { Name = "Trunk", Shape = Enum.PartType.Cylinder, Size = vertical(trunkHeight + 3, 1.2), CFrame = CFrame.new(0, (trunkHeight + 3) / 2, 0) * UPRIGHT, Color = Color3.fromRGB(105, 70, 45), Material = Enum.Material.Wood })
	for index = 1, 4 do
		local width = 6.4 - index * 1.25
		part(model, {
			Name = "Needles",
			Size = Vector3.new(width, 1.8, width),
			CFrame = CFrame.new(0, trunkHeight + index * 1.5, 0) * CFrame.Angles(0, math.rad(index * 22), 0),
			Color = Color3.fromRGB(40, 120 + index * 8, 70),
			Material = Enum.Material.Grass,
			CanCollide = false,
		})
	end
	hitbox(model, Vector3.new(2.6, trunkHeight + 1, 2.6), 3)
end

BUILDERS.Ancient = function(model, _random)
	part(model, { Name = "Trunk", Shape = Enum.PartType.Cylinder, Size = vertical(10, 2.8), CFrame = CFrame.new(0, 5, 0) * UPRIGHT, Color = Color3.fromRGB(95, 70, 60), Material = Enum.Material.Wood })
	for index, spec in { { 0, 0, 0, 8 }, { 2.4, -1, 1, 6 }, { -2.2, -0.6, -1.4, 6 } } do
		part(model, {
			Name = "Leaves",
			Shape = Enum.PartType.Ball,
			Size = Vector3.one * spec[4],
			CFrame = CFrame.new(spec[1], 12 + spec[2], spec[3]),
			Color = if index == 1 then Color3.fromRGB(90, 200, 170) else Color3.fromRGB(70, 170, 150),
			Material = Enum.Material.Grass,
			CanCollide = false,
		})
	end
	hitbox(model, Vector3.new(4, 10, 4), 3.5)
end

local function rockPile(model: Model, random: Random, color: Color3, scale: number)
	for index = 1, 3 do
		local size = Vector3.new(random:NextNumber(2.2, 3.2), random:NextNumber(1.6, 2.6), random:NextNumber(2.2, 3.2)) * scale
		part(model, {
			Name = "Rock",
			Size = size,
			CFrame = CFrame.new(random:NextNumber(-0.8, 0.8), size.Y / 2 - 0.3, random:NextNumber(-0.8, 0.8))
				* CFrame.Angles(random:NextNumber(-0.3, 0.3), random:NextNumber(0, math.pi), random:NextNumber(-0.3, 0.3)),
			Color = color:Lerp(Color3.new(1, 1, 1), (index - 1) * 0.06),
			Material = Enum.Material.Slate,
		})
	end
end

BUILDERS.Rock = function(model, random)
	rockPile(model, random, Color3.fromRGB(135, 132, 128), 1)
	hitbox(model, Vector3.new(4.4, 3, 4.4), 2)
end

BUILDERS.Iron = function(model, random)
	rockPile(model, random, Color3.fromRGB(110, 105, 100), 1.1)
	for _ = 1, 5 do
		part(model, {
			Name = "Ore",
			Shape = Enum.PartType.Ball,
			Size = Vector3.one * random:NextNumber(0.6, 0.9),
			CFrame = CFrame.new(random:NextNumber(-1.4, 1.4), random:NextNumber(1, 2.4), random:NextNumber(-1.4, 1.4)),
			Color = Color3.fromRGB(190, 110, 70),
			Material = Enum.Material.Metal,
			CanCollide = false,
		})
	end
	hitbox(model, Vector3.new(4.6, 3.2, 4.6), 2)
end

BUILDERS.Crystal = function(model, random)
	rockPile(model, random, Color3.fromRGB(90, 85, 110), 0.9)
	for index = 1, 4 do
		local height = random:NextNumber(2.2, 3.6)
		part(model, {
			Name = "Crystal",
			Size = Vector3.new(0.7, height, 0.7),
			CFrame = CFrame.new(random:NextNumber(-1, 1), 1.4 + height / 2, random:NextNumber(-1, 1))
				* CFrame.Angles(random:NextNumber(-0.4, 0.4), index, random:NextNumber(-0.4, 0.4)),
			Color = Color3.fromRGB(130, 230, 255),
			Material = Enum.Material.Neon,
			Transparency = 0.15,
			CanCollide = false,
		})
	end
	hitbox(model, Vector3.new(4, 4, 4), 2)
end

BUILDERS.Bush = function(model, random)
	for index = 1, 3 do
		part(model, {
			Name = "Bush",
			Shape = Enum.PartType.Ball,
			Size = Vector3.one * random:NextNumber(2, 2.8),
			CFrame = CFrame.new(math.cos(index * 2.1) * 0.8, 1, math.sin(index * 2.1) * 0.8),
			Color = Color3.fromRGB(95, 160 + index * 10, 70),
			Material = Enum.Material.Grass,
			CanCollide = false,
		})
	end
	for index = 1, 5 do
		part(model, {
			Name = "Fiber",
			Size = Vector3.new(0.12, 1.4, 0.12),
			CFrame = CFrame.new(math.cos(index) * 0.7, 2.2, math.sin(index) * 0.7) * CFrame.Angles(0.2, index, 0.2),
			Color = Color3.fromRGB(225, 210, 140),
			CanCollide = false,
		})
	end
	hitbox(model, Vector3.new(3, 2.6, 3), 1.5)
end

BUILDERS.Sand = function(model, _random)
	part(model, { Name = "Pile", Shape = Enum.PartType.Cylinder, Size = vertical(1.2, 4), CFrame = CFrame.new(0, 0.5, 0) * UPRIGHT, Color = Color3.fromRGB(240, 220, 160), Material = Enum.Material.Sand })
	part(model, { Name = "Top", Shape = Enum.PartType.Cylinder, Size = vertical(0.6, 2.6), CFrame = CFrame.new(0, 1.3, 0) * UPRIGHT, Color = Color3.fromRGB(245, 228, 175), Material = Enum.Material.Sand })
	part(model, { Name = "Shell", Shape = Enum.PartType.Ball, Size = Vector3.one * 0.5, CFrame = CFrame.new(0.8, 1.2, -0.4), Color = Color3.fromRGB(255, 200, 190), CanCollide = false })
	hitbox(model, Vector3.new(4, 1.6, 4), 1.2)
end

BUILDERS.Clay = function(model, _random)
	part(model, { Name = "Clay", Shape = Enum.PartType.Cylinder, Size = vertical(0.5, 4), CFrame = CFrame.new(0, 0.2, 0) * UPRIGHT, Color = Color3.fromRGB(185, 110, 75), Material = Enum.Material.Mud })
	part(model, { Name = "Lump", Shape = Enum.PartType.Ball, Size = Vector3.one * 1, CFrame = CFrame.new(-0.6, 0.5, 0.4), Color = Color3.fromRGB(170, 100, 70), Material = Enum.Material.Mud })
	hitbox(model, Vector3.new(4, 1.2, 4), 1)
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

-- Hide / show a pooled node without destroying it.
function NodeModels.SetVisible(model: Model, visible: boolean)
	for _, descendant in model:GetDescendants() do
		if descendant:IsA("BasePart") then
			local baseTransparency = descendant:GetAttribute("BaseTransparency")
			local baseCollide = descendant:GetAttribute("BaseCanCollide")
			descendant.Transparency = if visible then (if type(baseTransparency) == "number" then baseTransparency else 0) else 1
			descendant.CanCollide = visible and baseCollide == true
		end
	end
end

return NodeModels
