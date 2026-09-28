--[[
	SCRIPT NAME:  IslandProps
	SCRIPT TYPE:  ModuleScript (server)
	WHERE:        ServerScriptService/Server/Island/IslandProps
	DEPENDENCIES: none

	Procedural props for every island: the island sign, the starter chest,
	the spawn pad, and the small DECORATION scatter (flowers, tufts, shells,
	leaves, mushrooms, snowballs, pebbles) that makes each theme feel alive.

	Every builder returns an unparented Model with its pivot at the base
	(Y = 0), ready for :PivotTo(). Decorations are CanCollide/CanQuery false
	so they never block walking, building or clicking.

	To replace a prop with real art, put a Model with the same name in
	ServerStorage/Islands/Props (e.g. "StarterChest"); IslandBuilder uses it.
	The chest art needs a "Body" PrimaryPart and a "Lid" part.
]]

local IslandProps = {}

local COLORS = {
	Wood = Color3.fromRGB(176, 124, 76),
	WoodDark = Color3.fromRGB(118, 80, 48),
	SignBoard = Color3.fromRGB(226, 184, 124),
	ChestBody = Color3.fromRGB(160, 100, 55),
	Gold = Color3.fromRGB(255, 205, 70),
	Stone = Color3.fromRGB(214, 208, 196),
	StoneDark = Color3.fromRGB(150, 146, 140),
	Stem = Color3.fromRGB(70, 150, 60),
	Text = Color3.fromRGB(78, 50, 28),
}

local FLOWER_COLORS = {
	Color3.fromRGB(255, 110, 140),
	Color3.fromRGB(255, 214, 80),
	Color3.fromRGB(190, 130, 255),
	Color3.fromRGB(255, 255, 255),
	Color3.fromRGB(255, 150, 70),
	Color3.fromRGB(110, 180, 255),
}

type PartProps = {
	Name: string?,
	Size: Vector3,
	CFrame: CFrame,
	Color: Color3,
	Material: Enum.Material?,
	Shape: Enum.PartType?,
	CanCollide: boolean?,
	Transparency: number?,
	Mesh: string?, -- "Sphere" for a squashable ellipsoid
	Deco: boolean?, -- no collision, no queries, no shadow
}

local function part(parent: Instance, props: PartProps): Part
	local newPart = Instance.new("Part")
	newPart.Name = props.Name or "Part"
	newPart.Anchored = true
	newPart.Shape = props.Shape or Enum.PartType.Block
	newPart.Size = props.Size
	newPart.CFrame = props.CFrame
	newPart.Color = props.Color
	newPart.Material = props.Material or Enum.Material.SmoothPlastic
	newPart.CanCollide = if props.CanCollide == nil then not props.Deco else props.CanCollide
	newPart.Transparency = props.Transparency or 0
	newPart.TopSurface = Enum.SurfaceType.Smooth
	newPart.BottomSurface = Enum.SurfaceType.Smooth
	if props.Deco then
		newPart.CanQuery = false
		newPart.CanTouch = false
		newPart.CastShadow = false
	end
	if props.Mesh == "Sphere" then
		local mesh = Instance.new("SpecialMesh")
		mesh.MeshType = Enum.MeshType.Sphere
		mesh.Parent = newPart
	end
	newPart.Parent = parent
	return newPart
end

local function newModel(name: string): Model
	local model = Instance.new("Model")
	model.Name = name
	return model
end

local function finish(model: Model): Model
	model.WorldPivot = CFrame.new()
	return model
end

local function textLabel(parent: Instance, name: string, text: string, size: UDim2, position: UDim2, color: Color3): TextLabel
	local label = Instance.new("TextLabel")
	label.Name = name
	label.BackgroundTransparency = 1
	label.Size = size
	label.Position = position
	label.Font = Enum.Font.FredokaOne
	label.TextScaled = true
	label.TextColor3 = color
	label.Text = text
	label.Parent = parent
	return label
end

---------------------------------------------------------------------------
-- Landmarks
---------------------------------------------------------------------------

-- A sign whose readable face (Front / -Z) looks down -Z.
function IslandProps.Sign(title: string, subtitle: string): Model
	local model = newModel("IslandSign")
	for _, x in { -2.9, 2.9 } do
		part(model, { Name = "Post", Size = Vector3.new(0.55, 5.4, 0.55), CFrame = CFrame.new(x, 2.7, 0), Color = COLORS.WoodDark, Material = Enum.Material.Wood })
		part(model, { Name = "Cap", Size = Vector3.new(0.8, 0.3, 0.8), CFrame = CFrame.new(x, 5.5, 0), Color = COLORS.Wood, Material = Enum.Material.Wood })
	end
	local board = part(model, { Name = "Board", Size = Vector3.new(6.6, 3.2, 0.4), CFrame = CFrame.new(0, 3.9, -0.1), Color = COLORS.SignBoard, Material = Enum.Material.WoodPlanks })
	part(model, { Name = "Trim", Size = Vector3.new(6.9, 0.3, 0.5), CFrame = CFrame.new(0, 5.55, -0.1), Color = COLORS.WoodDark, Material = Enum.Material.Wood })
	part(model, { Name = "Trim", Size = Vector3.new(6.9, 0.3, 0.5), CFrame = CFrame.new(0, 2.25, -0.1), Color = COLORS.WoodDark, Material = Enum.Material.Wood })
	-- Flower boxes at the foot of the sign.
	for index, x in { -1.8, 0, 1.8 } do
		part(model, { Name = "Bloom", Shape = Enum.PartType.Ball, Size = Vector3.one * 0.7, CFrame = CFrame.new(x, 0.55, -0.9), Color = FLOWER_COLORS[index], Deco = true })
	end
	part(model, { Name = "Planter", Size = Vector3.new(5.2, 0.5, 0.8), CFrame = CFrame.new(0, 0.25, -0.9), Color = COLORS.WoodDark, Material = Enum.Material.Wood })

	local gui = Instance.new("SurfaceGui")
	gui.Name = "SignGui"
	gui.Face = Enum.NormalId.Front
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.PixelsPerStud = 60
	gui.LightInfluence = 0.5
	gui.Parent = board
	textLabel(gui, "Title", title, UDim2.fromScale(0.92, 0.5), UDim2.fromScale(0.04, 0.06), COLORS.Text)
	textLabel(gui, "Subtitle", subtitle, UDim2.fromScale(0.92, 0.34), UDim2.fromScale(0.04, 0.6), COLORS.WoodDark)
	model.PrimaryPart = board
	return finish(model)
end

function IslandProps.SetSignText(sign: Model, title: string, subtitle: string)
	local board = sign:FindFirstChild("Board")
	local gui = board and board:FindFirstChild("SignGui")
	if not gui then
		return
	end
	local titleLabel = gui:FindFirstChild("Title")
	local subtitleLabel = gui:FindFirstChild("Subtitle")
	if titleLabel and titleLabel:IsA("TextLabel") then
		titleLabel.Text = title
	end
	if subtitleLabel and subtitleLabel:IsA("TextLabel") then
		subtitleLabel.Text = subtitle
	end
end

function IslandProps.StarterChest(): Model
	local model = newModel("StarterChest")
	local body = part(model, { Name = "Body", Size = Vector3.new(3.4, 1.9, 2.3), CFrame = CFrame.new(0, 0.95, 0), Color = COLORS.ChestBody, Material = Enum.Material.WoodPlanks })
	for _, x in { -1.2, 1.2 } do
		part(model, { Name = "Band", Size = Vector3.new(0.32, 1.95, 2.35), CFrame = CFrame.new(x, 0.95, 0), Color = COLORS.Gold, Material = Enum.Material.Metal })
	end
	local lid = part(model, { Name = "Lid", Size = Vector3.new(3.5, 0.8, 2.4), CFrame = CFrame.new(0, 2.3, 0), Color = COLORS.ChestBody:Lerp(Color3.new(1, 1, 1), 0.08), Material = Enum.Material.WoodPlanks })
	part(model, { Name = "Lock", Size = Vector3.new(0.55, 0.65, 0.2), CFrame = CFrame.new(0, 1.8, -1.2), Color = COLORS.Gold, Material = Enum.Material.Metal, CanCollide = false })
	local sparkle = Instance.new("PointLight")
	sparkle.Name = "Glow"
	sparkle.Color = COLORS.Gold
	sparkle.Brightness = 1.5
	sparkle.Range = 8
	sparkle.Parent = body
	model.PrimaryPart = body
	lid:SetAttribute("ClosedOffset", body.CFrame:ToObjectSpace(lid.CFrame))
	return finish(model)
end

-- Rotates the lid open around its back edge and turns the glow off.
function IslandProps.OpenChest(chest: Model)
	local body = chest:FindFirstChild("Body")
	local lid = chest:FindFirstChild("Lid")
	if not body or not lid or not body:IsA("BasePart") or not lid:IsA("BasePart") then
		return
	end
	local closed = lid:GetAttribute("ClosedOffset")
	if typeof(closed) ~= "CFrame" then
		return
	end
	local hinge = body.CFrame * closed * CFrame.new(0, -lid.Size.Y / 2, lid.Size.Z / 2)
	lid.CFrame = hinge * CFrame.Angles(math.rad(100), 0, 0) * CFrame.new(0, lid.Size.Y / 2, -lid.Size.Z / 2)
	local lock = chest:FindFirstChild("Lock")
	if lock and lock:IsA("BasePart") then
		lock.Transparency = 1
	end
	local glow = body:FindFirstChild("Glow")
	if glow and glow:IsA("Light") then
		glow.Enabled = false
	end
end

function IslandProps.SpawnPad(): Model
	local model = newModel("SpawnPad")
	part(model, {
		Name = "Pad",
		Shape = Enum.PartType.Cylinder,
		Size = Vector3.new(0.5, 10, 10),
		CFrame = CFrame.new(0, 0.25, 0) * CFrame.Angles(0, 0, math.rad(90)),
		Color = COLORS.Stone,
		Material = Enum.Material.Cobblestone,
	})
	part(model, {
		Name = "Inlay",
		Shape = Enum.PartType.Cylinder,
		Size = Vector3.new(0.52, 6.5, 6.5),
		CFrame = CFrame.new(0, 0.26, 0) * CFrame.Angles(0, 0, math.rad(90)),
		Color = COLORS.StoneDark,
		Material = Enum.Material.Slate,
		CanCollide = false,
	})
	local ring = part(model, {
		Name = "Ring",
		Shape = Enum.PartType.Cylinder,
		Size = Vector3.new(0.54, 4, 4),
		CFrame = CFrame.new(0, 0.27, 0) * CFrame.Angles(0, 0, math.rad(90)),
		Color = Color3.fromRGB(120, 220, 255),
		Material = Enum.Material.Neon,
		CanCollide = false,
		Transparency = 0.3,
	})
	local light = Instance.new("PointLight")
	light.Color = ring.Color
	light.Range = 10
	light.Brightness = 1.2
	light.Parent = ring
	-- Little lantern posts around the pad.
	for index = 0, 3 do
		local angle = index * math.pi / 2 + math.pi / 4
		local x, z = math.cos(angle) * 5.8, math.sin(angle) * 5.8
		part(model, { Name = "LanternPost", Size = Vector3.new(0.3, 2.4, 0.3), CFrame = CFrame.new(x, 1.2, z), Color = COLORS.WoodDark, Material = Enum.Material.Wood })
		local lamp = part(model, { Name = "Lamp", Size = Vector3.new(0.6, 0.6, 0.6), CFrame = CFrame.new(x, 2.6, z), Color = Color3.fromRGB(255, 220, 140), Material = Enum.Material.Neon, CanCollide = false })
		local lampLight = Instance.new("PointLight")
		lampLight.Color = lamp.Color
		lampLight.Range = 9
		lampLight.Brightness = 0.8
		lampLight.Parent = lamp
	end
	return finish(model)
end

---------------------------------------------------------------------------
-- Decorations (cosmetic scatter per chunk)
---------------------------------------------------------------------------

local DECO: { [string]: (model: Model, random: Random) -> () } = {}

DECO.Flowers = function(model, random)
	for _ = 1, random:NextInteger(5, 9) do
		local x, z = random:NextNumber(-2.2, 2.2), random:NextNumber(-2.2, 2.2)
		local stem = random:NextNumber(0.5, 1.1)
		part(model, { Name = "Stem", Size = Vector3.new(0.1, stem, 0.1), CFrame = CFrame.new(x, stem / 2, z), Color = COLORS.Stem, Deco = true })
		local color = FLOWER_COLORS[random:NextInteger(1, #FLOWER_COLORS)]
		part(model, { Name = "Bloom", Size = Vector3.new(0.55, 0.3, 0.55), CFrame = CFrame.new(x, stem + 0.05, z), Color = color, Mesh = "Sphere", Deco = true })
		part(model, { Name = "Heart", Size = Vector3.new(0.2, 0.2, 0.2), CFrame = CFrame.new(x, stem + 0.2, z), Color = Color3.fromRGB(255, 225, 90), Mesh = "Sphere", Deco = true })
	end
end

local function tuft(model: Model, random: Random, color: Color3)
	for _ = 1, random:NextInteger(4, 7) do
		local height = random:NextNumber(0.8, 1.6)
		local lean = CFrame.Angles(math.rad(random:NextNumber(-25, 25)), math.rad(random:NextNumber(0, 360)), math.rad(random:NextNumber(-25, 25)))
		part(model, {
			Name = "Blade",
			Size = Vector3.new(0.12, height, 0.35),
			CFrame = CFrame.new(random:NextNumber(-0.6, 0.6), 0, random:NextNumber(-0.6, 0.6)) * lean * CFrame.new(0, height / 2, 0),
			Color = color:Lerp(Color3.new(1, 1, 0.6), random:NextNumber(0, 0.25)),
			Material = Enum.Material.Grass,
			Deco = true,
		})
	end
end

DECO.Tuft = function(model, random)
	tuft(model, random, Color3.fromRGB(80, 170, 60))
end

DECO.DryTuft = function(model, random)
	tuft(model, random, Color3.fromRGB(190, 165, 90))
end

DECO.Shells = function(model, random)
	local colors = { Color3.fromRGB(255, 220, 210), Color3.fromRGB(255, 190, 170), Color3.fromRGB(245, 240, 225) }
	for _ = 1, random:NextInteger(2, 4) do
		part(model, {
			Name = "Shell",
			Size = Vector3.new(0.6, 0.25, 0.5),
			CFrame = CFrame.new(random:NextNumber(-2, 2), 0.1, random:NextNumber(-2, 2)) * CFrame.Angles(0, random:NextNumber(0, 6.28), 0),
			Color = colors[random:NextInteger(1, #colors)],
			Mesh = "Sphere",
			Deco = true,
		})
	end
	if random:NextNumber() < 0.4 then
		part(model, { Name = "Starfish", Size = Vector3.new(0.9, 0.12, 0.9), CFrame = CFrame.new(random:NextNumber(-1.5, 1.5), 0.06, random:NextNumber(-1.5, 1.5)) * CFrame.Angles(0, random:NextNumber(0, 6.28), 0), Color = Color3.fromRGB(255, 120, 80), Mesh = "Sphere", Deco = true })
	end
end

DECO.Leaves = function(model, random)
	local colors = { Color3.fromRGB(235, 120, 40), Color3.fromRGB(215, 70, 40), Color3.fromRGB(245, 190, 60) }
	for _ = 1, random:NextInteger(6, 10) do
		part(model, {
			Name = "Leaf",
			Size = Vector3.new(0.6, 0.06, 0.45),
			CFrame = CFrame.new(random:NextNumber(-2.4, 2.4), 0.05, random:NextNumber(-2.4, 2.4)) * CFrame.Angles(0, random:NextNumber(0, 6.28), 0),
			Color = colors[random:NextInteger(1, #colors)],
			Material = Enum.Material.Fabric,
			Deco = true,
		})
	end
end

DECO.Mushrooms = function(model, random)
	for _ = 1, random:NextInteger(2, 4) do
		local x, z = random:NextNumber(-1.2, 1.2), random:NextNumber(-1.2, 1.2)
		local height = random:NextNumber(0.4, 0.8)
		part(model, { Name = "Stalk", Size = Vector3.new(0.22, height, 0.22), CFrame = CFrame.new(x, height / 2, z), Color = Color3.fromRGB(245, 235, 215), Deco = true })
		part(model, { Name = "Cap", Size = Vector3.new(0.75, 0.4, 0.75), CFrame = CFrame.new(x, height, z), Color = Color3.fromRGB(215, 60, 50), Mesh = "Sphere", Deco = true })
	end
end

DECO.Snowball = function(model, random)
	for _ = 1, random:NextInteger(1, 3) do
		local size = random:NextNumber(0.6, 1.3)
		part(model, { Name = "Snow", Size = Vector3.new(size * 1.3, size * 0.7, size), CFrame = CFrame.new(random:NextNumber(-1.5, 1.5), size * 0.25, random:NextNumber(-1.5, 1.5)), Color = Color3.fromRGB(245, 250, 255), Material = Enum.Material.Snow, Mesh = "Sphere", Deco = true })
	end
end

DECO.Pebbles = function(model, random)
	for _ = 1, random:NextInteger(3, 6) do
		local size = random:NextNumber(0.3, 0.8)
		part(model, {
			Name = "Pebble",
			Size = Vector3.new(size * 1.3, size * 0.6, size),
			CFrame = CFrame.new(random:NextNumber(-1.6, 1.6), size * 0.2, random:NextNumber(-1.6, 1.6)) * CFrame.Angles(0, random:NextNumber(0, 6.28), 0),
			Color = COLORS.StoneDark:Lerp(Color3.new(1, 1, 1), random:NextNumber(0, 0.3)),
			Material = Enum.Material.Slate,
			Mesh = "Sphere",
			Deco = true,
		})
	end
end

-- Cosmetic scatter model for a decoration kind (see IslandConfig theme Deco).
function IslandProps.Deco(kind: string, seed: number, scale: number): Model?
	local builder = DECO[kind]
	if not builder then
		return nil
	end
	local model = newModel("Deco_" .. kind)
	builder(model, Random.new(seed))
	finish(model)
	if scale ~= 1 then
		model:ScaleTo(scale)
	end
	return model
end

return IslandProps
