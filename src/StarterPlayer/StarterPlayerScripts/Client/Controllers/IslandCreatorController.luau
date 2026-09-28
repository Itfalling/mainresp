--[[
	SCRIPT NAME:  IslandCreatorController
	SCRIPT TYPE:  ModuleScript (client controller)
	WHERE:        StarterPlayerScripts/Client/Controllers/IslandCreatorController
	DEPENDENCIES: Shared.Net, Shared.Config.IslandConfig, Shared.Util.IslandGen, Client.ClientState,
	              UIController, AudioController, Client.UI.{Components, Theme}

	The CREATE YOUR ISLAND screen, shown once to new players (while the
	replicated Island.Created is false; the server waits for it before
	spawning you).

	  1  THEME   Tropical / Meadow / Autumn / Snowy / Desert: ground colours,
	             trees, decorations and the fish near your shore.
	  2  SHAPE   Round / Crescent / Twin Isles / Longshore / Wild, and a
	             🎲 REROLL button: every seed grows a different coastline.
	  3  NAME    optional (filtered by the server).

	The map in the middle is a LIVE preview drawn with the exact same
	generator the server uses (Shared/Util/IslandGen), so what you see is
	the island you get. CREATE sends CreateIslandRequest{Theme, Shape, Seed, Name}.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Net = require(Shared:WaitForChild("Net"))
local IslandConfig = require(Shared.Config.IslandConfig)
local IslandGen = require(Shared.Util.IslandGen)

local Client = script.Parent.Parent
local ClientState = require(Client.ClientState)
local UIController = require(script.Parent.UIController)
local AudioController = require(script.Parent.AudioController)
local Components = require(Client.UI.Components)
local Theme = require(Client.UI.Theme)

local Create = Components.Create

local PREVIEW_PIXELS = 46
local PREVIEW_SIZE = 322

-- Map colours for the preview (terrain materials by name).
local MATERIAL_COLORS: { [string]: Color3 } = {
	Grass = Color3.fromRGB(104, 186, 74),
	LeafyGrass = Color3.fromRGB(222, 146, 58),
	Ground = Color3.fromRGB(150, 110, 72),
	Snow = Color3.fromRGB(240, 246, 255),
	Salt = Color3.fromRGB(226, 232, 238),
	Sand = Color3.fromRGB(240, 222, 160),
	Sandstone = Color3.fromRGB(222, 164, 104),
	Rock = Color3.fromRGB(128, 128, 132),
	Slate = Color3.fromRGB(100, 104, 112),
}
local DEEP_WATER = Color3.fromRGB(26, 92, 170)
local SHALLOW_WATER = Color3.fromRGB(70, 196, 220)

local IslandCreatorController = {}

local root: Frame
local shown = false
local submitted = false
local choice = { Theme = IslandConfig.DefaultTheme, Shape = IslandConfig.DefaultShape, Seed = 1 }
local themeCards: { [string]: TextButton } = {}
local shapeButtons: { [string]: TextButton } = {}
local pixels: { Frame } = {}
local nameBox: TextBox
local summary: TextLabel
local createButton: TextButton
local drawToken = 0

local function newSeed(): number
	return Random.new():NextInteger(1, 1_999_999_999)
end

local function drawPreview()
	drawToken += 1
	local token = drawToken
	local chunks = IslandGen.GenerateStarter(choice.Seed, choice.Shape)
	local sampler = IslandGen.NewSampler({ Seed = choice.Seed, Theme = choice.Theme, Chunks = chunks, Paint = {} })
	-- Frame the island: bounding box of its chunks plus some sea around it.
	local minX, maxX, minZ, maxZ = math.huge, -math.huge, math.huge, -math.huge
	for key in chunks do
		local cx, cz = IslandGen.ParseKey(key)
		if cx and cz then
			minX, maxX = math.min(minX, cx), math.max(maxX, cx)
			minZ, maxZ = math.min(minZ, cz), math.max(maxZ, cz)
		end
	end
	local chunk = IslandConfig.ChunkSize
	local span = (math.max(maxX - minX, maxZ - minZ) + 3) * chunk
	local centerX = (minX + maxX) / 2 * chunk
	local centerZ = (minZ + maxZ) / 2 * chunk
	local step = span / PREVIEW_PIXELS
	for row = 0, PREVIEW_PIXELS - 1 do
		for column = 0, PREVIEW_PIXELS - 1 do
			local x = centerX - span / 2 + (column + 0.5) * step
			local z = centerZ - span / 2 + (row + 0.5) * step
			local sample = sampler:Sample(x, z)
			local color: Color3
			if sample.Height < -0.4 then
				color = SHALLOW_WATER:Lerp(DEEP_WATER, math.clamp(-sample.Height / 10, 0, 1))
			else
				color = MATERIAL_COLORS[sample.Material] or Color3.fromRGB(110, 180, 80)
				-- Shade hills so the height reads on the flat map.
				local lift = math.clamp((sample.Height - IslandConfig.LandHeight) / 12, -0.3, 1)
				color = if lift > 0 then color:Lerp(Color3.new(1, 1, 1), lift * 0.35) else color:Lerp(Color3.new(0, 0, 0), -lift * 0.3)
			end
			pixels[row * PREVIEW_PIXELS + column + 1].BackgroundColor3 = color
		end
		-- Spread the work over a few frames so the UI never hitches.
		if row % 12 == 11 then
			task.wait()
			if token ~= drawToken then
				return
			end
		end
	end
end

local function refresh()
	local theme = IslandConfig.Themes[choice.Theme]
	local shape = IslandConfig.Shapes[choice.Shape]
	for id, card in themeCards do
		Components.SetButtonColor(card, if id == choice.Theme then IslandConfig.Themes[id].Color else Theme.Colors.PanelAlt)
	end
	for id, button in shapeButtons do
		Components.SetButtonColor(button, if id == choice.Shape then Theme.Colors.Coins else Theme.Colors.PanelAlt)
	end
	summary.Text = ("%s %s  ·  %s %s\n%s\n%s\nSeed #%d"):format(theme.Icon, theme.DisplayName, shape.Icon, shape.DisplayName, theme.Description, shape.Description, choice.Seed)
	task.spawn(drawPreview)
end

local function build()
	root = Create("Frame", {
		Name = "IslandCreator",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.fromRGB(40, 150, 210),
		Visible = false,
		ZIndex = 0, -- under the notifications that share the overlay
		Parent = UIController.GetOverlay(),
	})
	Create("UIGradient", {
		Rotation = 90,
		Color = ColorSequence.new(Color3.fromRGB(120, 215, 255), Color3.fromRGB(30, 110, 200)),
		Parent = root,
	})
	local title = Components.Label({
		Text = "🏝️ CREATE YOUR ISLAND",
		Size = UDim2.fromOffset(700, 56),
		Position = UDim2.new(0.5, 0, 0, 14),
		AnchorPoint = Vector2.new(0.5, 0),
		TextSize = Theme.TextSize.Huge,
		TextColor3 = Theme.Colors.TextLight,
		Parent = root,
	})
	Components.TextStroke(title, Theme.Colors.Outline, 3)
	local subtitle = Components.Label({
		Text = "Every island is unique — pick a look, reroll until you love the shape!",
		Size = UDim2.fromOffset(800, 24),
		Position = UDim2.new(0.5, 0, 0, 70),
		AnchorPoint = Vector2.new(0.5, 0),
		Font = Theme.Fonts.Bold,
		TextSize = Theme.TextSize.Medium,
		TextColor3 = Theme.Colors.TextLight,
		Parent = root,
	})
	Components.TextStroke(subtitle, Theme.Colors.Outline, 1.5)

	local container = Create("Frame", {
		Size = UDim2.fromOffset(1180, 560),
		Position = UDim2.new(0.5, 0, 0, 106),
		AnchorPoint = Vector2.new(0.5, 0),
		BackgroundTransparency = 1,
		Parent = root,
	})

	-- 1: THEME
	local themeColumn = Create("Frame", { Size = UDim2.fromOffset(360, 560), BackgroundColor3 = Theme.Colors.Panel, Parent = container })
	Components.Corner(themeColumn)
	Components.Stroke(themeColumn, Theme.Colors.Outline, 4)
	Components.Padding(themeColumn, 12)
	Components.Label({ Text = "1 · THEME", Size = UDim2.new(1, 0, 0, 30), TextSize = Theme.TextSize.Title, Parent = themeColumn })
	for index, themeId in IslandConfig.ThemeOrder do
		local theme = IslandConfig.Themes[themeId]
		local card = Components.Button({
			Name = themeId,
			Text = "",
			Color = Theme.Colors.PanelAlt,
			Size = UDim2.new(1, 0, 0, 90),
			Position = UDim2.fromOffset(0, 38 + (index - 1) * 98),
			Parent = themeColumn,
			Flat = true,
			OnClick = function()
				choice.Theme = themeId
				refresh()
			end,
		})
		Components.Label({ Text = theme.Icon, Size = UDim2.fromOffset(70, 90), TextSize = 46, Parent = card })
		local name = Components.Label({ Text = theme.DisplayName, Size = UDim2.new(1, -80, 0, 32), Position = UDim2.fromOffset(74, 10), TextXAlignment = Enum.TextXAlignment.Left, TextSize = Theme.TextSize.Large, TextColor3 = Theme.Colors.TextLight, Parent = card })
		Components.TextStroke(name, Theme.Colors.Outline, 2)
		Components.Label({ Text = theme.Description, Size = UDim2.new(1, -84, 0, 40), Position = UDim2.fromOffset(74, 42), TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, Font = Theme.Fonts.Bold, TextSize = Theme.TextSize.Small, TextColor3 = Theme.Colors.Text, Parent = card })
		themeCards[themeId] = card
	end

	-- 2: SHAPE + PREVIEW
	local middle = Create("Frame", { Size = UDim2.fromOffset(420, 560), Position = UDim2.fromOffset(380, 0), BackgroundColor3 = Theme.Colors.Panel, Parent = container })
	Components.Corner(middle)
	Components.Stroke(middle, Theme.Colors.Outline, 4)
	Components.Padding(middle, 12)
	Components.Label({ Text = "2 · SHAPE", Size = UDim2.new(1, 0, 0, 30), TextSize = Theme.TextSize.Title, Parent = middle })
	local map = Create("Frame", {
		Name = "Preview",
		Size = UDim2.fromOffset(PREVIEW_SIZE, PREVIEW_SIZE),
		Position = UDim2.new(0.5, 0, 0, 38),
		AnchorPoint = Vector2.new(0.5, 0),
		BackgroundColor3 = DEEP_WATER,
		ClipsDescendants = true,
		Parent = middle,
	})
	Components.Corner(map, UDim.new(0, 18))
	Components.Stroke(map, Theme.Colors.Outline, 4)
	local pixelSize = PREVIEW_SIZE / PREVIEW_PIXELS
	for row = 0, PREVIEW_PIXELS - 1 do
		for column = 0, PREVIEW_PIXELS - 1 do
			table.insert(pixels, Create("Frame", {
				Size = UDim2.fromOffset(math.ceil(pixelSize), math.ceil(pixelSize)),
				Position = UDim2.fromOffset(column * pixelSize, row * pixelSize),
				BackgroundColor3 = DEEP_WATER,
				BorderSizePixel = 0,
				Parent = map,
			}))
		end
	end
	local shapeRow = Create("Frame", { Size = UDim2.new(1, 0, 0, 56), Position = UDim2.fromOffset(0, 372), BackgroundTransparency = 1, Parent = middle }, {
		Create("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Center, Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }),
	})
	for index, shapeId in IslandConfig.ShapeOrder do
		local shape = IslandConfig.Shapes[shapeId]
		local button = Components.Button({
			Name = shapeId,
			Text = shape.Icon .. "\n" .. shape.DisplayName,
			Color = Theme.Colors.PanelAlt,
			TextColor = Theme.Colors.Text,
			Size = UDim2.fromOffset(72, 56),
			TextSize = Theme.TextSize.Tiny,
			Parent = shapeRow,
			Flat = true,
			OnClick = function()
				choice.Shape = shapeId
				refresh()
			end,
		})
		button.LayoutOrder = index
		shapeButtons[shapeId] = button
	end
	Components.Button({
		Text = "🎲 REROLL SHAPE",
		Color = Theme.Colors.Purple,
		Size = UDim2.new(1, 0, 0, 52),
		Position = UDim2.fromOffset(0, 440),
		Parent = middle,
		OnClick = function()
			choice.Seed = newSeed()
			refresh()
		end,
	})
	Components.Label({
		Text = "You can grow your island in any direction later!",
		Size = UDim2.new(1, 0, 0, 24),
		Position = UDim2.fromOffset(0, 500),
		Font = Theme.Fonts.Bold,
		TextSize = Theme.TextSize.Small,
		TextColor3 = Theme.Colors.TextMuted,
		Parent = middle,
	})

	-- 3: NAME + CREATE
	local right = Create("Frame", { Size = UDim2.fromOffset(360, 560), Position = UDim2.fromOffset(820, 0), BackgroundColor3 = Theme.Colors.Panel, Parent = container })
	Components.Corner(right)
	Components.Stroke(right, Theme.Colors.Outline, 4)
	Components.Padding(right, 12)
	Components.Label({ Text = "3 · NAME", Size = UDim2.new(1, 0, 0, 30), TextSize = Theme.TextSize.Title, Parent = right })
	nameBox = Create("TextBox", {
		Size = UDim2.new(1, 0, 0, 50),
		Position = UDim2.fromOffset(0, 40),
		BackgroundColor3 = Color3.new(1, 1, 1),
		Font = Theme.Fonts.Bold,
		TextSize = Theme.TextSize.Large,
		TextColor3 = Theme.Colors.Text,
		PlaceholderText = "My Island",
		ClearTextOnFocus = false,
		Text = "",
		Parent = right,
	})
	Components.Corner(nameBox, Theme.SmallCorner)
	Components.Stroke(nameBox, Theme.Colors.Outline, 3)
	nameBox:GetPropertyChangedSignal("Text"):Connect(function()
		if #nameBox.Text > IslandConfig.NameMaxLength then
			nameBox.Text = string.sub(nameBox.Text, 1, IslandConfig.NameMaxLength)
		end
	end)
	summary = Components.Label({
		Size = UDim2.new(1, 0, 0, 250),
		Position = UDim2.fromOffset(0, 110),
		Font = Theme.Fonts.Bold,
		TextSize = Theme.TextSize.Medium,
		TextColor3 = Theme.Colors.TextMuted,
		TextYAlignment = Enum.TextYAlignment.Top,
		Text = "",
		Parent = right,
	})
	createButton = Components.Button({
		Text = "✨ CREATE ISLAND!",
		Color = Theme.Colors.Green,
		Size = UDim2.new(1, 0, 0, 80),
		Position = UDim2.new(0, 0, 1, -84),
		TextSize = Theme.TextSize.Title,
		Parent = right,
		OnClick = function()
			if submitted then
				return
			end
			submitted = true
			createButton.Text = "⏳ RAISING YOUR ISLAND…"
			Components.SetButtonColor(createButton, Theme.Colors.PanelDark)
			AudioController.Play("LevelUp")
			Net.FireServer("CreateIslandRequest", { Theme = choice.Theme, Shape = choice.Shape, Seed = choice.Seed, Name = nameBox.Text })
			-- If the server rejected it, let the player try again.
			task.delay(12, function()
				if shown then
					submitted = false
					createButton.Text = "✨ CREATE ISLAND!"
					Components.SetButtonColor(createButton, Theme.Colors.Green)
				end
			end)
		end,
	})
end

local function show()
	if shown then
		return
	end
	shown = true
	submitted = false
	choice.Seed = newSeed()
	root.Visible = true
	UIController.SetModalOpen("IslandCreator", true)
	refresh()
end

local function hide()
	if not shown then
		return
	end
	shown = false
	drawToken += 1
	UIController.SetModalOpen("IslandCreator", false)
	root.Visible = false
end

function IslandCreatorController.IsOpen(): boolean
	return shown
end

function IslandCreatorController.Init()
	build()
end

function IslandCreatorController.Start()
	ClientState.Observe("Island", function(island)
		if type(island) ~= "table" then
			return
		end
		if island.Created == true then
			hide()
		else
			show()
		end
	end)
end

return IslandCreatorController
