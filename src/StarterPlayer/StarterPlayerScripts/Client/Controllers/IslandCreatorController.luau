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

	The screen has its own ScreenGui and scales to FILL any screen (phone,
	laptop or a small Studio window), with big chunky text.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

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
local PREVIEW_SIZE = 380

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

local gui: ScreenGui
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

local DESIGN = Vector2.new(1240, 720)

-- Soft floating bubbles behind the menu (cartoon sky).
local function addBubbles(parent: Frame)
	local spots = {
		{ 0.08, 0.2, 260 },
		{ 0.9, 0.15, 340 },
		{ 0.18, 0.85, 380 },
		{ 0.82, 0.8, 300 },
		{ 0.5, 0.05, 220 },
		{ 0.62, 0.95, 240 },
	}
	for index, spot in spots do
		local bubble = Create("Frame", {
			Name = "Bubble",
			Size = UDim2.fromOffset(spot[3], spot[3]),
			Position = UDim2.fromScale(spot[1], spot[2]),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Color3.new(1, 1, 1),
			BackgroundTransparency = 0.88,
			Parent = parent,
		})
		Components.Corner(bubble, UDim.new(1, 0))
		TweenService:Create(bubble, TweenInfo.new(3 + index * 0.7, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
			Position = UDim2.fromScale(spot[1], spot[2] - 0.035),
		}):Play()
	end
end

local function header(parent: Instance, text: string)
	local label = Components.Label({ Text = text, Size = UDim2.new(1, 0, 0, 38), TextSize = 34, TextColor3 = Theme.Colors.TextLight, Parent = parent })
	Components.TextStroke(label, Theme.Colors.Outline, 2.5)
end

local function column(parent: Instance, x: number, width: number, color: Color3): Frame
	local frame = Create("Frame", { Size = UDim2.fromOffset(width, 600), Position = UDim2.fromOffset(x, 0), BackgroundColor3 = color, Parent = parent })
	Components.Corner(frame, UDim.new(0, 26))
	Components.Stroke(frame, Theme.Colors.Outline, 5)
	Components.Gloss(frame, 0.3)
	Components.Padding(frame, 14)
	return frame
end

local function build()
	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	gui = Create("ScreenGui", {
		Name = "IslandCreatorGui",
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		DisplayOrder = 5,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		Enabled = false,
		Parent = playerGui,
	})
	root = Create("Frame", {
		Name = "IslandCreator",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.new(1, 1, 1),
		Parent = gui,
	})
	Create("UIGradient", {
		Rotation = 90,
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(130, 220, 255)),
			ColorSequenceKeypoint.new(0.6, Color3.fromRGB(60, 160, 235)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 105, 200)),
		}),
		Parent = root,
	})
	addBubbles(root)

	-- Everything below is laid out at DESIGN size and scaled to FILL the screen.
	local stage = Create("Frame", {
		Name = "Stage",
		Size = UDim2.fromOffset(DESIGN.X, DESIGN.Y),
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Parent = root,
	})
	local stageScale = Create("UIScale", { Parent = stage })
	local function fit()
		local size = root.AbsoluteSize
		if size.X > 0 and size.Y > 0 then
			stageScale.Scale = math.max(0.35, math.min(size.X * 0.97 / DESIGN.X, size.Y * 0.96 / DESIGN.Y))
		end
	end
	root:GetPropertyChangedSignal("AbsoluteSize"):Connect(fit)
	fit()

	local title = Components.Label({
		Text = "🏝️ CREATE YOUR ISLAND",
		Size = UDim2.new(1, 0, 0, 70),
		TextSize = 64,
		TextColor3 = Theme.Colors.TextLight,
		TextWrapped = false,
		Parent = stage,
	})
	Components.TextStroke(title, Theme.Colors.Outline, 4)
	TweenService:Create(title, TweenInfo.new(1.6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), { Rotation = 1.5 }):Play()
	local subtitle = Components.Label({
		Text = "Every island is unique — pick a look, then reroll until you love the shape!",
		Size = UDim2.new(1, 0, 0, 30),
		Position = UDim2.fromOffset(0, 72),
		Font = Theme.Fonts.Heavy,
		TextSize = 26,
		TextColor3 = Theme.Colors.TextLight,
		Parent = stage,
	})
	Components.TextStroke(subtitle, Theme.Colors.Outline, 2)

	local container = Create("Frame", {
		Size = UDim2.fromOffset(DESIGN.X, 600),
		Position = UDim2.fromOffset(0, 116),
		BackgroundTransparency = 1,
		Parent = stage,
	})

	-- 1: THEME
	local themeColumn = column(container, 0, 380, Color3.fromRGB(255, 196, 90))
	header(themeColumn, "1 · THEME")
	for index, themeId in IslandConfig.ThemeOrder do
		local theme = IslandConfig.Themes[themeId]
		local card = Components.Button({
			Name = themeId,
			Text = "",
			Color = Theme.Colors.PanelAlt,
			Size = UDim2.new(1, 0, 0, 100),
			Position = UDim2.fromOffset(0, 46 + (index - 1) * 108),
			Parent = themeColumn,
			Flat = true,
			OnClick = function()
				choice.Theme = themeId
				refresh()
			end,
		})
		Components.Label({ Text = theme.Icon, Size = UDim2.fromOffset(80, 100), TextSize = 56, Parent = card })
		local name = Components.Label({ Text = theme.DisplayName, Size = UDim2.new(1, -90, 0, 36), Position = UDim2.fromOffset(80, 10), TextXAlignment = Enum.TextXAlignment.Left, TextSize = 30, TextColor3 = Theme.Colors.TextLight, Parent = card })
		Components.TextStroke(name, Theme.Colors.Outline, 2.5)
		Components.Label({ Text = theme.Description, Size = UDim2.new(1, -92, 0, 46), Position = UDim2.fromOffset(80, 48), TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, Font = Theme.Fonts.Heavy, TextSize = 17, TextColor3 = Theme.Colors.Text, Parent = card })
		themeCards[themeId] = card
	end

	-- 2: SHAPE + PREVIEW
	local middle = column(container, 395, 450, Color3.fromRGB(120, 215, 140))
	header(middle, "2 · SHAPE")
	local map = Create("Frame", {
		Name = "Preview",
		Size = UDim2.fromOffset(PREVIEW_SIZE, PREVIEW_SIZE),
		Position = UDim2.new(0.5, 0, 0, 46),
		AnchorPoint = Vector2.new(0.5, 0),
		BackgroundColor3 = DEEP_WATER,
		ClipsDescendants = true,
		Parent = middle,
	})
	Components.Corner(map, UDim.new(0, 22))
	Components.Stroke(map, Theme.Colors.Outline, 5)
	local pixelSize = PREVIEW_SIZE / PREVIEW_PIXELS
	for row = 0, PREVIEW_PIXELS - 1 do
		for columnIndex = 0, PREVIEW_PIXELS - 1 do
			table.insert(pixels, Create("Frame", {
				Size = UDim2.fromOffset(math.ceil(pixelSize), math.ceil(pixelSize)),
				Position = UDim2.fromOffset(columnIndex * pixelSize, row * pixelSize),
				BackgroundColor3 = DEEP_WATER,
				BorderSizePixel = 0,
				Parent = map,
			}))
		end
	end
	local shapeRow = Create("Frame", { Size = UDim2.new(1, 0, 0, 70), Position = UDim2.fromOffset(0, 438), BackgroundTransparency = 1, Parent = middle }, {
		Create("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Center, Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }),
	})
	for index, shapeId in IslandConfig.ShapeOrder do
		local shape = IslandConfig.Shapes[shapeId]
		local button = Components.Button({
			Name = shapeId,
			Text = shape.Icon .. "\n" .. shape.DisplayName,
			Color = Theme.Colors.PanelAlt,
			TextColor = Theme.Colors.Text,
			Size = UDim2.fromOffset(78, 70),
			TextSize = 16,
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
		Size = UDim2.new(1, 0, 0, 58),
		Position = UDim2.fromOffset(0, 516),
		TextSize = 26,
		Parent = middle,
		OnClick = function()
			choice.Seed = newSeed()
			refresh()
		end,
	})

	-- 3: NAME + CREATE
	local right = column(container, 860, 380, Color3.fromRGB(255, 150, 190))
	header(right, "3 · NAME")
	nameBox = Create("TextBox", {
		Size = UDim2.new(1, 0, 0, 62),
		Position = UDim2.fromOffset(0, 48),
		BackgroundColor3 = Color3.new(1, 1, 1),
		Font = Theme.Fonts.Heavy,
		TextSize = 28,
		TextColor3 = Theme.Colors.Text,
		PlaceholderText = "My Island",
		ClearTextOnFocus = false,
		Text = "",
		Parent = right,
	})
	Components.Corner(nameBox, UDim.new(0, 16))
	Components.Stroke(nameBox, Theme.Colors.Outline, 4)
	nameBox:GetPropertyChangedSignal("Text"):Connect(function()
		if #nameBox.Text > IslandConfig.NameMaxLength then
			nameBox.Text = string.sub(nameBox.Text, 1, IslandConfig.NameMaxLength)
		end
	end)
	local card = Create("Frame", {
		Size = UDim2.new(1, 0, 0, 290),
		Position = UDim2.fromOffset(0, 124),
		BackgroundColor3 = Theme.Colors.Panel,
		Parent = right,
	})
	Components.Corner(card, UDim.new(0, 18))
	Components.Stroke(card, Theme.Colors.Outline, 3)
	Components.Padding(card, 12)
	summary = Components.Label({
		Size = UDim2.fromScale(1, 1),
		Font = Theme.Fonts.Heavy,
		TextSize = 22,
		TextColor3 = Theme.Colors.Text,
		TextYAlignment = Enum.TextYAlignment.Top,
		Text = "",
		Parent = card,
	})
	Components.Label({
		Text = "You can grow your island in any direction later!",
		Size = UDim2.new(1, 0, 0, 44),
		Position = UDim2.fromOffset(0, 420),
		Font = Theme.Fonts.Heavy,
		TextSize = 18,
		TextColor3 = Theme.Colors.TextLight,
		Parent = right,
	})
	createButton = Components.Button({
		Text = "✨ CREATE ISLAND!",
		Color = Theme.Colors.Green,
		Size = UDim2.new(1, 0, 0, 96),
		Position = UDim2.new(0, 0, 1, -100),
		TextSize = 36,
		Parent = right,
		OnClick = function()
			if submitted then
				return
			end
			submitted = true
			createButton.Text = "⏳ RAISING YOUR ISLAND…"
			createButton.TextSize = 24
			Components.SetButtonColor(createButton, Theme.Colors.PanelDark)
			AudioController.Play("LevelUp")
			Net.FireServer("CreateIslandRequest", { Theme = choice.Theme, Shape = choice.Shape, Seed = choice.Seed, Name = nameBox.Text })
			-- If the server rejected it, let the player try again.
			task.delay(12, function()
				if shown then
					submitted = false
					createButton.Text = "✨ CREATE ISLAND!"
					createButton.TextSize = 36
					Components.SetButtonColor(createButton, Theme.Colors.Green)
				end
			end)
		end,
	})
	-- A glow pulses behind the CREATE button to draw the eye.
	local glow = Create("Frame", {
		Name = "CreateGlow",
		Size = UDim2.new(1, 16, 0, 112),
		Position = UDim2.new(0, -8, 1, -108),
		BackgroundColor3 = Color3.fromRGB(255, 255, 160),
		BackgroundTransparency = 0.5,
		ZIndex = 0,
		Parent = right,
	})
	Components.Corner(glow, UDim.new(0, 22))
	TweenService:Create(glow, TweenInfo.new(0.9, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), { BackgroundTransparency = 0.9 }):Play()
	createButton.ZIndex = 2
end

local function show()
	if shown then
		return
	end
	shown = true
	submitted = false
	choice.Seed = newSeed()
	gui.Enabled = true
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
	gui.Enabled = false
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
