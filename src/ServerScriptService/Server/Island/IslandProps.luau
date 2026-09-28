--[[
	SCRIPT NAME:  IslandProps
	SCRIPT TYPE:  ModuleScript (server)
	WHERE:        ServerScriptService/Server/Island/IslandProps
	DEPENDENCIES: none

	Procedural low-poly props for the starter island (sign, chest, dock,
	palms, flowers, plots, locked-area markers). Every function builds the
	prop around the origin (base at Y = 0) and returns an unparented Model
	with WorldPivot at its base, ready for :PivotTo().

	To replace a prop with real art later, put a Model with the same name in
	ServerStorage/Islands/Props (e.g. "StarterChest"); IslandBuilder prefers
	art when it exists. Art must keep any "PromptAnchor" attachment and, for
	the chest, a "Lid" part.
]]

local IslandProps = {}

local COLORS = {
	Wood = Color3.fromRGB(165, 115, 70),
	WoodDark = Color3.fromRGB(120, 82, 50),
	SignBoard = Color3.fromRGB(215, 172, 115),
	ChestBody = Color3.fromRGB(150, 95, 52),
	Gold = Color3.fromRGB(255, 200, 60),
	Trunk = Color3.fromRGB(155, 115, 72),
	Leaves = Color3.fromRGB(70, 175, 75),
	LeavesDark = Color3.fromRGB(50, 145, 60),
	Stone = Color3.fromRGB(205, 200, 188),
	Soil = Color3.fromRGB(112, 76, 46),
	SoilDark = Color3.fromRGB(88, 58, 34),
	Text = Color3.fromRGB(70, 45, 25),
}

local FLOWER_COLORS = {
	Color3.fromRGB(255, 105, 130),
	Color3.fromRGB(255, 212, 80),
	Color3.fromRGB(185, 125, 255),
	Color3.fromRGB(255, 255, 255),
	Color3.fromRGB(255, 150, 70),
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
	newPart.CanCollide = if props.CanCollide == nil then true else props.CanCollide
	newPart.Transparency = props.Transparency or 0
	newPart.TopSurface = Enum.SurfaceType.Smooth
	newPart.BottomSurface = Enum.SurfaceType.Smooth
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

local function anchor(parent: BasePart, offset: Vector3)
	local attachment = Instance.new("Attachment")
	attachment.Name = "PromptAnchor"
	attachment.Position = offset
	attachment.Parent = parent
end

-- A sign whose readable face (Front / -Z) looks down -Z.
function IslandProps.Sign(title: string, subtitle: string): Model
	local model = newModel("IslandSign")
	part(model, { Name = "PostL", Size = Vector3.new(0.5, 5, 0.5), CFrame = CFrame.new(-2.6, 2.5, 0), Color = COLORS.WoodDark, Material = Enum.Material.Wood })
	part(model, { Name = "PostR", Size = Vector3.new(0.5, 5, 0.5), CFrame = CFrame.new(2.6, 2.5, 0), Color = COLORS.WoodDark, Material = Enum.Material.Wood })
	local board = part(model, { Name = "Board", Size = Vector3.new(6.4, 2.8, 0.35), CFrame = CFrame.new(0, 3.9, -0.1), Color = COLORS.SignBoard, Material = Enum.Material.Wood })
	part(model, { Name = "Roof", Size = Vector3.new(7, 0.3, 0.9), CFrame = CFrame.new(0, 5.45, -0.1), Color = COLORS.WoodDark, Material = Enum.Material.Wood })
	anchor(board, Vector3.new(0, -1, -0.5))

	local gui = Instance.new("SurfaceGui")
	gui.Name = "SignGui"
	gui.Face = Enum.NormalId.Front
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.PixelsPerStud = 60
	gui.LightInfluence = 0.6
	gui.Parent = board

	local titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "Title"
	titleLabel.BackgroundTransparency = 1
	titleLabel.Size = UDim2.fromScale(0.92, 0.55)
	titleLabel.Position = UDim2.fromScale(0.04, 0.05)
	titleLabel.Font = Enum.Font.FredokaOne
	titleLabel.TextScaled = true
	titleLabel.TextColor3 = COLORS.Text
	titleLabel.Text = title
	titleLabel.Parent = gui

	local subtitleLabel = Instance.new("TextLabel")
	subtitleLabel.Name = "Subtitle"
	subtitleLabel.BackgroundTransparency = 1
	subtitleLabel.Size = UDim2.fromScale(0.92, 0.32)
	subtitleLabel.Position = UDim2.fromScale(0.04, 0.62)
	subtitleLabel.Font = Enum.Font.FredokaOne
	subtitleLabel.TextScaled = true
	subtitleLabel.TextColor3 = COLORS.WoodDark
	subtitleLabel.Text = subtitle
	subtitleLabel.Parent = gui

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
	local body = part(model, { Name = "Body", Size = Vector3.new(3.2, 1.8, 2.2), CFrame = CFrame.new(0, 0.9, 0), Color = COLORS.ChestBody, Material = Enum.Material.Wood })
	part(model, { Name = "BandL", Size = Vector3.new(0.3, 1.85, 2.25), CFrame = CFrame.new(-1.1, 0.9, 0), Color = COLORS.Gold, Material = Enum.Material.Metal })
	part(model, { Name = "BandR", Size = Vector3.new(0.3, 1.85, 2.25), CFrame = CFrame.new(1.1, 0.9, 0), Color = COLORS.Gold, Material = Enum.Material.Metal })
	local lid = part(model, { Name = "Lid", Size = Vector3.new(3.3, 0.7, 2.3), CFrame = CFrame.new(0, 2.15, 0), Color = COLORS.ChestBody, Material = Enum.Material.Wood })
	part(model, { Name = "Lock", Size = Vector3.new(0.5, 0.6, 0.2), CFrame = CFrame.new(0, 1.7, -1.15), Color = COLORS.Gold, Material = Enum.Material.Metal, CanCollide = false })
	anchor(body, Vector3.new(0, 0.8, 0))
	model.PrimaryPart = body
	-- Remember the closed lid pose relative to the body for OpenChest().
	lid:SetAttribute("ClosedOffset", body.CFrame:ToObjectSpace(lid.CFrame))
	return finish(model)
end

-- Rotates the lid open around its back edge.
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
end

-- Dock extends along -Z from its origin (rotate with PivotTo).
function IslandProps.Dock(length: number, width: number): Model
	local model = newModel("Dock")
	local plankDepth = 1.2
	local count = math.floor(length / (plankDepth + 0.15))
	for i = 0, count - 1 do
		local z = -(i * (plankDepth + 0.15) + plankDepth / 2)
		local shade = if i % 2 == 0 then COLORS.Wood else COLORS.Wood:Lerp(COLORS.WoodDark, 0.25)
		part(model, { Name = "Plank", Size = Vector3.new(width, 0.35, plankDepth), CFrame = CFrame.new(0, 0, z), Color = shade, Material = Enum.Material.WoodPlanks })
	end
	for z = 2, length, 6 do
		for _, x in { -width / 2 + 0.3, width / 2 - 0.3 } do
			part(model, { Name = "Post", Size = Vector3.new(0.6, 9, 0.6), CFrame = CFrame.new(x, -4, -z), Color = COLORS.WoodDark, Material = Enum.Material.Wood })
		end
	end
	return finish(model)
end

function IslandProps.Palm(height: number, seed: number): Model
	local random = Random.new(seed)
	local model = newModel("PalmTree")
	local segments = 5
	local segmentHeight = height / segments
	local lean = random:NextNumber(-0.18, 0.18)
	local position = Vector3.zero
	for i = 1, segments do
		local offset = Vector3.new(lean * i * 0.6, segmentHeight, lean * i * 0.3)
		local center = position + offset / 2
		local thickness = 1.3 - i * 0.12
		part(model, {
			Name = "Trunk",
			Size = Vector3.new(thickness, segmentHeight + 0.2, thickness),
			CFrame = CFrame.lookAt(center, center + offset) * CFrame.Angles(-math.pi / 2, 0, 0),
			Color = if i % 2 == 0 then COLORS.Trunk else COLORS.Trunk:Lerp(COLORS.WoodDark, 0.3),
			Material = Enum.Material.Wood,
		})
		position += offset
	end
	local top = position
	for i = 1, 7 do
		local angle = (i / 7) * math.pi * 2 + random:NextNumber(-0.2, 0.2)
		local leaf = CFrame.new(top) * CFrame.Angles(0, angle, 0) * CFrame.new(0, 0, -2.6) * CFrame.Angles(math.rad(-22), 0, 0)
		part(model, {
			Name = "Leaf",
			Size = Vector3.new(1.4, 0.2, 5.4),
			CFrame = leaf,
			Color = if i % 2 == 0 then COLORS.Leaves else COLORS.LeavesDark,
			Material = Enum.Material.Grass,
			CanCollide = false,
		})
	end
	for i = 1, 3 do
		local angle = i * 2.1
		part(model, {
			Name = "Coconut",
			Shape = Enum.PartType.Ball,
			Size = Vector3.new(0.8, 0.8, 0.8),
			CFrame = CFrame.new(top + Vector3.new(math.cos(angle) * 0.6, -0.5, math.sin(angle) * 0.6)),
			Color = Color3.fromRGB(110, 80, 45),
			CanCollide = false,
		})
	end
	return finish(model)
end

function IslandProps.Flowers(seed: number): Model
	local random = Random.new(seed)
	local model = newModel("Flowers")
	for _ = 1, 9 do
		local x, z = random:NextNumber(-3, 3), random:NextNumber(-3, 3)
		local stemHeight = random:NextNumber(0.6, 1.2)
		part(model, { Name = "Stem", Size = Vector3.new(0.12, stemHeight, 0.12), CFrame = CFrame.new(x, stemHeight / 2, z), Color = COLORS.LeavesDark, CanCollide = false })
		part(model, {
			Name = "Bloom",
			Shape = Enum.PartType.Ball,
			Size = Vector3.new(0.55, 0.55, 0.55),
			CFrame = CFrame.new(x, stemHeight, z),
			Color = FLOWER_COLORS[random:NextInteger(1, #FLOWER_COLORS)],
			CanCollide = false,
		})
	end
	return finish(model)
end

-- kind: "HousePlot" | "FarmPlot". Size in studs (X, Z).
function IslandProps.Plot(kind: string, size: Vector2): Model
	local model = newModel(kind)
	local border = 0.6
	local height = 0.35
	local color = if kind == "FarmPlot" then COLORS.WoodDark else COLORS.Stone
	local material = if kind == "FarmPlot" then Enum.Material.Wood else Enum.Material.Cobblestone
	part(model, { Name = "EdgeN", Size = Vector3.new(size.X, height, border), CFrame = CFrame.new(0, height / 2, -size.Y / 2), Color = color, Material = material })
	part(model, { Name = "EdgeS", Size = Vector3.new(size.X, height, border), CFrame = CFrame.new(0, height / 2, size.Y / 2), Color = color, Material = material })
	part(model, { Name = "EdgeW", Size = Vector3.new(border, height, size.Y), CFrame = CFrame.new(-size.X / 2, height / 2, 0), Color = color, Material = material })
	part(model, { Name = "EdgeE", Size = Vector3.new(border, height, size.Y), CFrame = CFrame.new(size.X / 2, height / 2, 0), Color = color, Material = material })

	if kind == "FarmPlot" then
		local rows = math.floor((size.Y - 2) / 2.5)
		for i = 0, rows - 1 do
			local z = -size.Y / 2 + 1.8 + i * 2.5
			part(model, { Name = "SoilRow", Size = Vector3.new(size.X - 2, 0.3, 1.6), CFrame = CFrame.new(0, 0.12, z), Color = if i % 2 == 0 then COLORS.Soil else COLORS.SoilDark, Material = Enum.Material.Ground, CanCollide = false })
		end
	else
		part(model, { Name = "Pad", Size = Vector3.new(size.X - border, 0.12, size.Y - border), CFrame = CFrame.new(0, 0.06, 0), Color = Color3.fromRGB(226, 214, 180), Material = Enum.Material.Sand, CanCollide = false, Transparency = 0.35 })
	end
	if kind == "FarmPlot" then
		-- Invisible blocker so nothing can be built over the farm.
		part(model, { Name = "Zone", Size = Vector3.new(size.X, 3, size.Y), CFrame = CFrame.new(0, 1.5, 0), Color = Color3.new(1, 1, 1), CanCollide = false, Transparency = 1 })
	end
	return finish(model)
end

-- Market stall: counter ("Sell" prompt) + sign board ("Shop" prompt). Faces -Z.
function IslandProps.MarketStall(): Model
	local model = newModel("MarketStall")
	local counter = part(model, { Name = "Counter", Size = Vector3.new(9, 3, 2.4), CFrame = CFrame.new(0, 1.5, -1), Color = COLORS.Wood, Material = Enum.Material.WoodPlanks })
	part(model, { Name = "CounterTop", Size = Vector3.new(9.4, 0.3, 2.8), CFrame = CFrame.new(0, 3.15, -1), Color = COLORS.WoodDark, Material = Enum.Material.Wood })
	for _, x in { -4.3, 4.3 } do
		for _, z in { -2, 2.6 } do
			part(model, { Name = "Post", Size = Vector3.new(0.5, 7.5, 0.5), CFrame = CFrame.new(x, 3.75, z), Color = COLORS.WoodDark, Material = Enum.Material.Wood })
		end
	end
	-- Striped awning.
	for index = 0, 5 do
		local color = if index % 2 == 0 then Color3.fromRGB(235, 80, 70) else Color3.fromRGB(250, 245, 235)
		part(model, {
			Name = "Awning",
			Size = Vector3.new(1.6, 0.25, 6),
			CFrame = CFrame.new(-4 + index * 1.6, 7.8, 0.3) * CFrame.Angles(math.rad(-12), 0, 0),
			Color = color,
			Material = Enum.Material.Fabric,
			CanCollide = false,
		})
	end
	-- Produce crates on the counter.
	local produce = { Color3.fromRGB(235, 200, 90), Color3.fromRGB(255, 140, 40), Color3.fromRGB(230, 50, 45), Color3.fromRGB(120, 200, 90) }
	for index, color in produce do
		local x = -3.4 + (index - 1) * 2.2
		part(model, { Name = "Crate", Size = Vector3.new(1.8, 0.8, 1.4), CFrame = CFrame.new(x, 3.7, -1), Color = COLORS.Wood, Material = Enum.Material.WoodPlanks, CanCollide = false })
		for ball = 1, 3 do
			part(model, { Name = "Produce", Shape = Enum.PartType.Ball, Size = Vector3.new(0.6, 0.6, 0.6), CFrame = CFrame.new(x - 0.5 + (ball - 1) * 0.5, 4.2, -1 + (ball % 2) * 0.3), Color = color, CanCollide = false })
		end
	end
	local board = part(model, { Name = "SignBoard", Size = Vector3.new(6, 1.6, 0.3), CFrame = CFrame.new(0, 9.1, -1.8), Color = COLORS.SignBoard, Material = Enum.Material.Wood })
	local gui = Instance.new("SurfaceGui")
	gui.Face = Enum.NormalId.Front
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.PixelsPerStud = 50
	gui.LightInfluence = 0.5
	gui.Parent = board
	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Size = UDim2.fromScale(1, 1)
	label.Font = Enum.Font.FredokaOne
	label.TextScaled = true
	label.TextColor3 = COLORS.Text
	label.Text = "🛒 MARKET"
	label.Parent = gui
	-- Prompt anchors are the parts themselves (ShopService attaches to them).
	counter:SetAttribute("PromptRole", "Sell")
	local shopPost = part(model, { Name = "ShopCrate", Size = Vector3.new(1.6, 1.6, 1.6), CFrame = CFrame.new(5.6, 0.8, -2.2), Color = COLORS.Wood, Material = Enum.Material.WoodPlanks })
	shopPost:SetAttribute("PromptRole", "Shop")
	model.PrimaryPart = counter
	return finish(model)
end

-- Post + hanging sign marking where you can fish.
function IslandProps.FishingSpot(zoneName: string): Model
	local model = newModel("FishingSpot")
	local post = part(model, { Name = "Post", Size = Vector3.new(0.5, 4, 0.5), CFrame = CFrame.new(0, 2, 0), Color = COLORS.WoodDark, Material = Enum.Material.Wood })
	part(model, { Name = "Board", Size = Vector3.new(2.6, 1.2, 0.2), CFrame = CFrame.new(0, 3.4, -0.3), Color = COLORS.SignBoard, Material = Enum.Material.Wood, CanCollide = false })
	part(model, { Name = "Fish", Shape = Enum.PartType.Ball, Size = Vector3.new(0.9, 0.5, 0.5), CFrame = CFrame.new(0, 3.4, -0.45), Color = Color3.fromRGB(90, 160, 230), CanCollide = false })
	anchor(post, Vector3.new(0, -1, 0))
	local billboard = Instance.new("BillboardGui")
	billboard.Size = UDim2.fromScale(7, 1.4)
	billboard.StudsOffset = Vector3.new(0, 3.6, 0)
	billboard.MaxDistance = 90
	billboard.LightInfluence = 0
	billboard.Parent = post
	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Size = UDim2.fromScale(1, 1)
	label.Font = Enum.Font.FredokaOne
	label.TextScaled = true
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.TextStrokeTransparency = 0.3
	label.Text = "🎣 " .. zoneName
	label.Parent = billboard
	model.PrimaryPart = post
	return finish(model)
end

-- Marker on the starter shore for a locked expansion area. Faces -Z.
function IslandProps.LockMarker(areaName: string, requirementText: string): Model
	local model = newModel("AreaLock")
	local post = part(model, { Name = "Post", Size = Vector3.new(0.6, 6, 0.6), CFrame = CFrame.new(0, 3, 0), Color = COLORS.WoodDark, Material = Enum.Material.Wood })
	part(model, { Name = "Banner", Size = Vector3.new(3.2, 2, 0.15), CFrame = CFrame.new(1.8, 4.8, 0), Color = Color3.fromRGB(90, 190, 255), Material = Enum.Material.Fabric, CanCollide = false })
	part(model, { Name = "RopeL", Size = Vector3.new(0.2, 0.2, 6), CFrame = CFrame.new(-2.5, 1.2, 0) * CFrame.Angles(0, math.rad(90), 0), Color = Color3.fromRGB(220, 190, 130), CanCollide = false })
	part(model, { Name = "Stake", Size = Vector3.new(0.4, 2, 0.4), CFrame = CFrame.new(-5.5, 1, 0), Color = COLORS.WoodDark, Material = Enum.Material.Wood })
	anchor(post, Vector3.new(0, -1.5, 0))
	model.PrimaryPart = post

	local billboard = Instance.new("BillboardGui")
	billboard.Name = "LockBillboard"
	billboard.Size = UDim2.fromScale(9, 3.2)
	billboard.StudsOffset = Vector3.new(0, 4.5, 0)
	billboard.MaxDistance = 160
	billboard.LightInfluence = 0
	billboard.Parent = post

	local frame = Instance.new("Frame")
	frame.Size = UDim2.fromScale(1, 1)
	frame.BackgroundColor3 = Color3.fromRGB(255, 250, 238)
	frame.BackgroundTransparency = 0.05
	frame.Parent = billboard
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0.2, 0)
	corner.Parent = frame
	local stroke = Instance.new("UIStroke")
	stroke.Thickness = 3
	stroke.Color = Color3.fromRGB(70, 50, 30)
	stroke.Parent = frame

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Name = "AreaName"
	nameLabel.BackgroundTransparency = 1
	nameLabel.Size = UDim2.fromScale(0.94, 0.55)
	nameLabel.Position = UDim2.fromScale(0.03, 0.04)
	nameLabel.Font = Enum.Font.FredokaOne
	nameLabel.TextScaled = true
	nameLabel.TextColor3 = Color3.fromRGB(60, 40, 25)
	nameLabel.Text = "🔒 " .. areaName
	nameLabel.Parent = frame

	local requirementLabel = Instance.new("TextLabel")
	requirementLabel.Name = "Requirement"
	requirementLabel.BackgroundTransparency = 1
	requirementLabel.Size = UDim2.fromScale(0.94, 0.36)
	requirementLabel.Position = UDim2.fromScale(0.03, 0.58)
	requirementLabel.Font = Enum.Font.FredokaOne
	requirementLabel.TextScaled = true
	requirementLabel.TextColor3 = Color3.fromRGB(150, 100, 40)
	requirementLabel.Text = requirementText
	requirementLabel.Parent = frame

	return finish(model)
end

function IslandProps.SpawnPad(): Model
	local model = newModel("SpawnPad")
	part(model, {
		Name = "Pad",
		Shape = Enum.PartType.Cylinder,
		Size = Vector3.new(0.4, 9, 9),
		CFrame = CFrame.new(0, 0.2, 0) * CFrame.Angles(0, 0, math.rad(90)),
		Color = COLORS.Stone,
		Material = Enum.Material.Slate,
	})
	part(model, {
		Name = "Ring",
		Shape = Enum.PartType.Cylinder,
		Size = Vector3.new(0.42, 6, 6),
		CFrame = CFrame.new(0, 0.22, 0) * CFrame.Angles(0, 0, math.rad(90)),
		Color = Color3.fromRGB(120, 210, 255),
		Material = Enum.Material.SmoothPlastic,
		CanCollide = false,
	})
	return finish(model)
end

return IslandProps
