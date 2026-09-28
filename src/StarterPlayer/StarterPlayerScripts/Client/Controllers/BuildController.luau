--[[
	SCRIPT NAME:  BuildController
	SCRIPT TYPE:  ModuleScript (client controller)
	WHERE:        StarterPlayerScripts/Client/Controllers/BuildController
	DEPENDENCIES: Shared.Net, Shared.Building.BuildingModels, Shared.Config.{BuildingConfig, BuildConfig,
	              ItemConfig, IslandConfig}, Shared.Util.{Placement, Format, R15}, Client.ClientState,
	              Client.Build.LandEditor, InputController, UIController, CameraController,
	              InteractionController, AudioController, Client.UI.{Components, Theme}

	BUILD MODE (spec §7-§9, §46-§48, §84). Press B (or the 🔨 button).

	  Top     "BUILD MODE" + category
	  Left    categories + building list (cost shows ✔ / ✖ as you can afford it)
	  Centre  a transparent GHOST that follows the mouse / your tap, snapped to
	          the grid, tinted GREEN (valid) or RED (invalid, with the reason)
	  Right   selected building info + PLACE / ROTATE / CANCEL (touch friendly)
	  Bottom  control hints

	  R rotate · Q / E turn · click (or PLACE) to build · X cancel · B exit
	  EXPAND tab: glowing squares on the sea — click one to buy that land.
	  PAINT tab:  pick a material, click / drag over your land to paint it.
	  EDIT tab:   click one of your buildings → MOVE or DELETE (50% refund),
	              or a natural tree / rock → CLEAR it for good.

	The preview runs the SAME rules as the server (Shared/Util/Placement,
	BuildConfig) so what looks valid is valid — but the server re-checks all of it.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Net = require(Shared:WaitForChild("Net"))
local BuildingModels = require(Shared.Building.BuildingModels)
local BuildingConfig = require(Shared.Config.BuildingConfig)
local BuildConfig = require(Shared.Config.BuildConfig)
local ItemConfig = require(Shared.Config.ItemConfig)
local IslandConfig = require(Shared.Config.IslandConfig)
local Placement = require(Shared.Util.Placement)
local Format = require(Shared.Util.Format)
local R15 = require(Shared.Util.R15)

local Client = script.Parent.Parent
local ClientState = require(Client.ClientState)
local LandEditor = require(Client.Build.LandEditor)
local InputController = require(script.Parent.InputController)
local UIController = require(script.Parent.UIController)
local CameraController = require(script.Parent.CameraController)
local InteractionController = require(script.Parent.InteractionController)
local AudioController = require(script.Parent.AudioController)
local Components = require(Client.UI.Components)
local Theme = require(Client.UI.Theme)

local Create = Components.Create
local player = Players.LocalPlayer

local VALID_COLOR = Color3.fromRGB(90, 230, 120)
local INVALID_COLOR = Color3.fromRGB(240, 80, 70)
local EDIT_COLOR = Color3.fromRGB(90, 170, 255)

local BuildController = {}

type Refs = {
	Root: Frame,
	Banner: TextLabel,
	Left: Frame,
	Tabs: { [string]: TextButton },
	List: ScrollingFrame,
	Right: Frame,
	InfoIcon: TextLabel,
	InfoName: TextLabel,
	InfoDescription: TextLabel,
	InfoCost: TextLabel,
	Status: TextLabel,
	PlaceButton: TextButton,
	RotateButton: TextButton,
	CancelButton: TextButton,
	MoveButton: TextButton,
	DeleteButton: TextButton,
	ClearButton: TextButton,
	Hints: TextLabel,
	BuildButton: TextButton,
}

local refs: Refs
local active = false
local mode = "Menu" -- Menu | Placing | Editing | Moving | Expand | Paint
local category = "Homes"
local selectedId: string? = nil
local rotation = 0
local ghost: Model? = nil
local ghostHighlight: Highlight
local selectionHighlight: Highlight
local renderConnection: RBXScriptConnection? = nil
local releases: { () -> () } = {}
local pointer: Vector2? = nil -- last touch position (screen space)
local cards: { TextButton } = {}
local editTarget: Model? = nil
local deleteArmedUntil = 0
local clearArmedUntil = 0
local landConnection: RBXScriptConnection? = nil

local current = { Valid = false, Reason = "", Center = Vector2.zero, Key = "" }
local lastValidation = 0

---------------------------------------------------------------------------
-- Helpers
---------------------------------------------------------------------------

-- The island model's pivot IS the island origin (IslandBuilder pins WorldPivot).
local function myIsland(): Model?
	local folder = workspace:FindFirstChild("Islands")
	local island = folder and folder:FindFirstChild("Island_" .. player.UserId)
	return if island and island:IsA("Model") then island else nil
end

local function affordable(def: any): (boolean, string)
	local coins = ClientState.Get("Coins") or 0
	local items = ClientState.Get("Inventory", "Items") or {}
	local ok = true
	local lines = {}
	local needCoins = def.Cost.Coins or 0
	if needCoins > 0 then
		local has = coins >= needCoins
		ok = ok and has
		table.insert(lines, ("%s %s 🪙"):format(if has then "✔" else "✖", Format.Commas(needCoins)))
	end
	for itemId, amount in def.Cost.Items do
		local owned = items[itemId] or 0
		local has = owned >= amount
		ok = ok and has
		local item = ItemConfig.Get(itemId)
		table.insert(lines, ("%s %d/%d %s %s"):format(if has then "✔" else "✖", math.min(owned, amount), amount, if item then item.Icon else "", if item then item.DisplayName else itemId))
	end
	return ok, table.concat(lines, "\n")
end

local function alreadyOwned(buildingId: string): boolean
	for _, entry in ClientState.Get("Island", "Buildings") or {} do
		if type(entry) == "table" and entry.BuildingId == buildingId then
			return true
		end
	end
	return false
end

local function islandLevel(): number
	return ClientState.Get("Island", "Level") or 1
end

local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Exclude
local groundParams = RaycastParams.new()
groundParams.FilterType = Enum.RaycastFilterType.Include
groundParams.IgnoreWater = true

local function pointerRay(): Ray?
	local camera = workspace.CurrentCamera
	if not camera then
		return nil
	end
	if InputController.IsTouch() then
		local position = pointer or (camera.ViewportSize / 2)
		return camera:ScreenPointToRay(position.X, position.Y)
	end
	local mouse = UserInputService:GetMouseLocation()
	return camera:ViewportPointToRay(mouse.X, mouse.Y)
end

local function groundHeight(worldX: number, worldZ: number, fallback: number): number
	groundParams.FilterDescendantsInstances = { workspace.Terrain }
	local result = workspace:Raycast(Vector3.new(worldX, fallback + 80, worldZ), Vector3.new(0, -200, 0), groundParams)
	return if result then result.Position.Y else fallback
end

local function blockingFolders(island: Model): { Instance }
	local list = {}
	for _, name in BuildConfig.BlockingFolders do
		local folder = island:FindFirstChild(name)
		if folder then
			table.insert(list, folder)
		end
	end
	return list
end

---------------------------------------------------------------------------
-- Ghost preview
---------------------------------------------------------------------------

local function clearGhost()
	if ghost then
		ghost:Destroy()
		ghost = nil
	end
	ghostHighlight.Adornee = nil
	ghostHighlight.Enabled = false
end

local function makeGhost(buildingId: string)
	clearGhost()
	local model = BuildingModels.Build(buildingId)
	BuildingModels.MakeGhost(model)
	local def = BuildingConfig.Get(buildingId)
	local plate = Instance.new("Part")
	plate.Name = "FootprintPlate"
	plate.Anchored = true
	plate.CanCollide = false
	plate.CanQuery = false
	plate.CanTouch = false
	plate.Material = Enum.Material.Neon
	plate.Transparency = 0.55
	plate.Size = Vector3.new(def.Footprint.X, 0.15, def.Footprint.Y)
	plate.CFrame = CFrame.new(0, 0.1, 0)
	plate.Parent = model
	model.Parent = workspace.CurrentCamera
	ghost = model
	ghostHighlight.Adornee = model
	ghostHighlight.Enabled = true
end

-- Runs the same checks the server will run.
local function validate(def: any, island: Model, center: Vector2, localY: number, worldCFrame: CFrame, checkCost: boolean): (boolean, string)
	local size = Placement.FootprintSize(def.Footprint, rotation)
	local sampler = LandEditor.GetSampler()
	if not sampler or not Placement.IsOnLand(sampler, center, size) then
		return false, "Must be on solid land (not the beach)"
	end
	local origin = island:GetPivot()
	local lowest, highest = localY, localY
	for _, corner in Placement.Corners(center, size) do
		local world = origin * CFrame.new(corner.X, 0, corner.Y)
		local height = groundHeight(world.X, world.Z, origin.Y) - origin.Y
		lowest = math.min(lowest, height)
		highest = math.max(highest, height)
	end
	if highest - lowest > BuildConfig.MaxSlope then
		return false, "Ground too steep"
	end
	local root = R15.GetRootPart(player.Character)
	if not root or (root.Position - worldCFrame.Position).Magnitude > BuildConfig.PlacementRange then
		return false, "Too far away — walk closer"
	end
	local shrink = BuildConfig.OverlapShrink
	local boxSize = Vector3.new(math.max(0.5, def.Footprint.X - shrink), def.Height, math.max(0.5, def.Footprint.Y - shrink))
	local boxCFrame = worldCFrame * CFrame.new(0, def.Height / 2 + 0.4, 0)
	local overlap = OverlapParams.new()
	overlap.FilterType = Enum.RaycastFilterType.Include
	overlap.FilterDescendantsInstances = blockingFolders(island)
	for _, hit in workspace:GetPartBoundsInBox(boxCFrame, boxSize, overlap) do
		if not (editTarget and mode == "Moving" and hit:IsDescendantOf(editTarget)) then
			return false, "Something is in the way"
		end
	end
	local relative = boxCFrame:PointToObjectSpace(root.Position)
	if math.abs(relative.X) < def.Footprint.X / 2 + 1 and math.abs(relative.Z) < def.Footprint.Y / 2 + 1 then
		return false, "Step out of the way"
	end
	if checkCost then
		if def.Unique and alreadyOwned(def.Id) then
			return false, "You already have one"
		end
		if islandLevel() < def.UnlockLevel then
			return false, ("Needs Island Level %d"):format(def.UnlockLevel)
		end
		local canAfford = affordable(def)
		if not canAfford then
			return false, "Not enough materials"
		end
	end
	return true, "Looks good! Click / PLACE to build"
end

local function currentDef(): any
	if mode == "Moving" and editTarget then
		return BuildingConfig.Get(editTarget:GetAttribute("BuildingId"))
	end
	return selectedId and BuildingConfig.Get(selectedId)
end

local function updateGhost()
	local def = currentDef()
	local island = myIsland()
	local ray = pointerRay()
	if not ghost or not def or not island or not ray then
		return
	end
	local exclude = { ghost }
	if player.Character then
		table.insert(exclude, player.Character)
	end
	for _, name in { "ClientEffects", "ClientAudio" } do
		local folder = workspace:FindFirstChild(name)
		if folder then
			table.insert(exclude, folder)
		end
	end
	rayParams.FilterDescendantsInstances = exclude
	local hit = workspace:Raycast(ray.Origin, ray.Direction * 400, rayParams)
	if not hit then
		return
	end
	local origin = island:GetPivot()
	local localHit = origin:PointToObjectSpace(hit.Position)
	local size = Placement.FootprintSize(def.Footprint, rotation)
	local center = Placement.Snap(Vector2.new(localHit.X, localHit.Z), size)
	local worldCenter = origin * CFrame.new(center.X, 0, center.Y)
	local localY = groundHeight(worldCenter.X, worldCenter.Z, origin.Y) - origin.Y
	local worldCFrame = origin * Placement.LocalCFrame(Vector3.new(center.X, localY, center.Y), rotation)
	ghost:PivotTo(worldCFrame)

	local key = ("%d,%d,%d"):format(center.X * 10, center.Y * 10, rotation)
	local now = os.clock()
	if key ~= current.Key or now - lastValidation > 0.4 then
		lastValidation = now
		current.Key = key
		current.Center = center
		current.Valid, current.Reason = validate(def, island, center, localY, worldCFrame, mode == "Placing")
		local color = if current.Valid then VALID_COLOR else INVALID_COLOR
		ghostHighlight.FillColor = color
		ghostHighlight.OutlineColor = color
		local plate = ghost:FindFirstChild("FootprintPlate")
		if plate and plate:IsA("BasePart") then
			plate.Color = color
		end
		refs.Status.Text = (if current.Valid then "✔ " else "✖ ") .. current.Reason
		refs.Status.TextColor3 = if current.Valid then Theme.Colors.Green else Theme.Colors.Red
	end
end

local function startRender()
	if renderConnection then
		return
	end
	renderConnection = RunService.RenderStepped:Connect(updateGhost)
end

local function stopRender()
	if renderConnection then
		renderConnection:Disconnect()
		renderConnection = nil
	end
end

-- Expand / Paint run the LandEditor every frame and mirror its status line.
local function startLand()
	if landConnection then
		return
	end
	landConnection = RunService.RenderStepped:Connect(function()
		local text, ok = LandEditor.Step()
		refs.Status.Text = text
		refs.Status.TextColor3 = if ok then Theme.Colors.Green else Theme.Colors.Red
	end)
end

local function stopLand()
	if landConnection then
		landConnection:Disconnect()
		landConnection = nil
	end
	LandEditor.Exit()
end

local function isLandMode(): boolean
	return mode == "Expand" or mode == "Paint"
end

---------------------------------------------------------------------------
-- UI state
---------------------------------------------------------------------------

local renderList: () -> ()

local function showInfo(def: any?)
	if mode == "Expand" then
		local count, maxChunks, cost = LandEditor.ExpansionInfo()
		refs.InfoIcon.Text = "🗺️"
		refs.InfoName.Text = "EXPAND LAND"
		refs.InfoDescription.Text = "Click a glowing square on the sea to raise new land there. Grow your island in any direction you like!"
		refs.InfoCost.Text = ("Land chunks: %d / %d\nNext chunk: %s 🪙\nLevel up your island for more room."):format(count, maxChunks, Format.Commas(cost))
		return
	elseif mode == "Paint" then
		local paint = IslandConfig.Paint[LandEditor.Material]
		refs.InfoIcon.Text = if paint then paint.Icon else "🧽"
		refs.InfoName.Text = "PAINT TERRAIN"
		refs.InfoDescription.Text = "Pick a material on the left, then click or drag across your land. Paths, plazas, gardens — it's free!"
		refs.InfoCost.Text = if paint then "Brush: " .. paint.DisplayName else "Eraser: restores the natural ground."
		return
	end
	if not def then
		refs.InfoIcon.Text = "🔨"
		refs.InfoName.Text = if mode == "Editing" then "EDIT MODE" else "Pick a building"
		refs.InfoDescription.Text = if mode == "Editing" then "Click one of your buildings to move or remove it, or a wild tree / rock to clear it." else "Choose something from the list on the left."
		refs.InfoCost.Text = ""
		return
	end
	local _, costText = affordable(def)
	refs.InfoIcon.Text = def.Icon
	refs.InfoName.Text = string.upper(def.DisplayName)
	refs.InfoDescription.Text = if def.Steps > 0
		then ("%s\nFootprint %dx%d · %d hammer hits"):format(def.Description, def.Footprint.X, def.Footprint.Y, def.Steps)
		else ("%s\nFootprint %dx%d · instant"):format(def.Description, def.Footprint.X, def.Footprint.Y)
	refs.InfoCost.Text = if mode == "Moving" then "Moving is free." else costText
end

local function editIsNatural(): boolean
	return editTarget ~= nil and editTarget:GetAttribute("UniqueId") == nil and editTarget:GetAttribute("NodeId") ~= nil
end

local function updateButtons()
	local placing = mode == "Placing" or mode == "Moving"
	local editing = mode == "Editing" and editTarget ~= nil
	local natural = editing and editIsNatural()
	local editDef = editing and not natural and editTarget and BuildingConfig.Get(editTarget:GetAttribute("BuildingId"))
	refs.PlaceButton.Visible = placing
	refs.PlaceButton.Text = if mode == "Moving" then "MOVE HERE" else "PLACE"
	refs.RotateButton.Visible = placing
	refs.CancelButton.Visible = placing or editing
	refs.MoveButton.Visible = editing and not natural
	refs.DeleteButton.Visible = editing and not natural and not (editDef and editDef.NoDelete)
	refs.ClearButton.Visible = natural
	refs.Status.Visible = placing or isLandMode()
	refs.Left.Visible = not placing
	local label = if mode == "Editing" or mode == "Moving" then "EDIT" elseif isLandMode() then string.upper(mode) else string.upper(category)
	refs.Banner.Text = "🔨 BUILD MODE · " .. label
	local touch = InputController.IsTouch()
	if mode == "Expand" then
		refs.Hints.Text = if touch then "Tap a glowing square to buy land · ✕ to leave" else "Click a glowing square to buy land · B exit"
	elseif mode == "Paint" then
		refs.Hints.Text = if touch then "Tap / drag on your land to paint" else "Click or drag on your land to paint · B exit"
	elseif touch then
		refs.Hints.Text = if placing then "Tap the ground to move · ⟳ to rotate · PLACE to build" else "Pick a building · tap ✕ to leave"
	else
		refs.Hints.Text = if placing then "Click to place · R rotate · Q/E turn · X cancel · B exit" else "Pick a building · B to exit"
	end
end

local function setMode(newMode: string)
	local wasLand = isLandMode()
	mode = newMode
	if isLandMode() then
		LandEditor.Enter(mode)
		startLand()
	elseif wasLand then
		stopLand()
	end
	if mode == "Placing" or mode == "Moving" then
		startRender()
	else
		stopRender()
		clearGhost()
	end
	if mode ~= "Editing" and mode ~= "Moving" then
		editTarget = nil
		selectionHighlight.Adornee = nil
		selectionHighlight.Enabled = false
	end
	current.Key = ""
	updateButtons()
	showInfo(currentDef())
end

local function selectBuilding(buildingId: string)
	local def = BuildingConfig.Get(buildingId)
	if not def then
		return
	end
	if islandLevel() < def.UnlockLevel then
		UIController.Notify("Error", ("%s unlocks at Island Level %d."):format(def.DisplayName, def.UnlockLevel))
		return
	end
	selectedId = buildingId
	makeGhost(buildingId)
	setMode("Placing")
end

local function confirmPlacement()
	if mode ~= "Placing" and mode ~= "Moving" then
		return
	end
	if not current.Valid then
		AudioController.Play("PlaceInvalid")
		UIController.Notify("Error", current.Reason)
		return
	end
	if mode == "Moving" and editTarget then
		Net.FireServer("MoveBuildRequest", editTarget:GetAttribute("UniqueId"), current.Center.X, current.Center.Y, rotation)
		setMode("Editing")
		return
	end
	local def = currentDef()
	if not def then
		return
	end
	Net.FireServer("BuildRequest", { Op = "Place", BuildingId = def.Id, X = current.Center.X, Z = current.Center.Y, Rotation = rotation })
	AudioController.Play("UIClick")
	-- Decorations and nature keep placing (fences, trees...); big buildings return to the menu.
	if def.Category == "Decoration" or def.Category == "Nature" or def.Id == "SoilTile" then
		current.Key = ""
	else
		BuildController.Exit()
	end
end

local function rotate(delta: number)
	if mode == "Placing" or mode == "Moving" then
		rotation = (rotation + delta) % 360
		current.Key = ""
		AudioController.Play("UIClick")
	end
end

local function cancel()
	if mode == "Placing" then
		setMode("Menu")
	elseif mode == "Moving" then
		setMode("Editing")
	elseif mode == "Editing" and editTarget then
		setMode("Editing")
	elseif isLandMode() then
		setMode("Menu")
		renderList()
	else
		BuildController.Exit()
	end
end

local function selectForEdit(model: Model)
	editTarget = model
	selectionHighlight.Adornee = model
	selectionHighlight.Enabled = true
	deleteArmedUntil = 0
	clearArmedUntil = 0
	refs.DeleteButton.Text = "DELETE"
	refs.ClearButton.Text = "🪓 CLEAR IT"
	updateButtons()
	if editIsNatural() then
		local nodeType = tostring(model:GetAttribute("NodeType"))
		refs.InfoIcon.Text = "🌲"
		refs.InfoName.Text = string.upper(nodeType)
		refs.InfoDescription.Text = "Part of your island's wild nature. Clearing it removes it for good (you keep a little of what it drops)."
		refs.InfoCost.Text = "Clearing is free."
		return
	end
	local def = BuildingConfig.Get(model:GetAttribute("BuildingId"))
	showInfo(def)
	if def then
		refs.InfoCost.Text = if def.NoDelete
			then "This one can be moved, but not removed."
			else ("Delete refunds %d%% of the cost."):format(math.floor(BuildingConfig.RefundPercent * 100))
	end
end

local function tryPickBuilding(screenPosition: Vector2?)
	local camera = workspace.CurrentCamera
	if not camera then
		return
	end
	local ray = if screenPosition
		then camera:ScreenPointToRay(screenPosition.X, screenPosition.Y)
		else (function()
			local mouse = UserInputService:GetMouseLocation()
			return camera:ViewportPointToRay(mouse.X, mouse.Y)
		end)()
	local island = myIsland()
	local buildings = island and island:FindFirstChild("Buildings")
	local resources = island and island:FindFirstChild("Resources")
	if not buildings or not resources then
		return
	end
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Include
	params.FilterDescendantsInstances = { buildings, resources }
	local hit = workspace:Raycast(ray.Origin, ray.Direction * 400, params)
	if not hit then
		return
	end
	local folder = if hit.Instance:IsDescendantOf(buildings) then buildings else resources
	local model = hit.Instance:FindFirstAncestorOfClass("Model")
	while model and model.Parent ~= folder do
		model = model:FindFirstAncestorOfClass("Model")
	end
	if model and model:GetAttribute("OwnerUserId") == player.UserId then
		AudioController.Play("UIClick")
		selectForEdit(model)
	end
end

---------------------------------------------------------------------------
-- UI construction
---------------------------------------------------------------------------

local function buildUI()
	local layer = UIController.GetModalLayer()
	local root = Create("Frame", { Name = "BuildMode", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Visible = false, Parent = layer })

	local banner = Components.Label({
		Name = "Banner",
		Size = UDim2.fromOffset(420, 40),
		Position = UDim2.new(0.5, 0, 0, 76),
		AnchorPoint = Vector2.new(0.5, 0),
		BackgroundTransparency = 0,
		BackgroundColor3 = Theme.Colors.Orange,
		TextColor3 = Theme.Colors.TextLight,
		TextSize = Theme.TextSize.Large,
		Text = "🔨 BUILD MODE",
		Parent = root,
	})
	Components.Corner(banner, UDim.new(1, 0))
	Components.Stroke(banner)
	Components.TextStroke(banner)

	-- LEFT: categories + list
	local left = Create("Frame", { Name = "Left", Size = UDim2.fromOffset(300, 500), Position = UDim2.fromOffset(110, 125), BackgroundColor3 = Theme.Colors.Panel, Parent = root })
	Components.Corner(left)
	Components.Stroke(left)
	Components.Gradient(left, Color3.new(1, 1, 1), Theme.Colors.PanelAlt)
	local tabRow = Create("Frame", { Size = UDim2.new(1, -16, 0, 130), Position = UDim2.fromOffset(8, 8), BackgroundTransparency = 1, Parent = left }, {
		Create("UIGridLayout", { CellSize = UDim2.fromOffset(90, 38), CellPadding = UDim2.fromOffset(4, 6), SortOrder = Enum.SortOrder.LayoutOrder }),
	})
	local tabs = {}
	local tabDefs = table.clone(BuildingConfig.Categories)
	table.insert(tabDefs, { Id = "Expand", DisplayName = "Expand", Icon = "🗺️" })
	table.insert(tabDefs, { Id = "Paint", DisplayName = "Paint", Icon = "🖌️" })
	table.insert(tabDefs, { Id = "Edit", DisplayName = "Edit", Icon = "✏️" })
	for index, cat in tabDefs do
		local button = Components.Button({
			Name = cat.Id,
			Text = cat.Icon .. " " .. cat.DisplayName,
			Color = Theme.Colors.PanelAlt,
			TextColor = Theme.Colors.Text,
			TextSize = Theme.TextSize.Small,
			Parent = tabRow,
			Flat = true,
			OnClick = function()
				if cat.Id == "Edit" then
					setMode("Editing")
				elseif cat.Id == "Expand" or cat.Id == "Paint" then
					setMode(cat.Id)
				else
					category = cat.Id
					setMode("Menu")
				end
				renderList()
			end,
		})
		button.LayoutOrder = index
		tabs[cat.Id] = button
	end
	local list = Create("ScrollingFrame", {
		Name = "List",
		Size = UDim2.new(1, -16, 1, -152),
		Position = UDim2.fromOffset(8, 146),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 6,
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Parent = left,
	}, {
		Create("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }),
	})

	-- RIGHT: info + actions
	local right = Create("Frame", { Name = "Right", Size = UDim2.fromOffset(280, 430), Position = UDim2.new(1, -12, 0, 125), AnchorPoint = Vector2.new(1, 0), BackgroundColor3 = Theme.Colors.Panel, Parent = root })
	Components.Corner(right)
	Components.Stroke(right)
	Components.Gradient(right, Color3.new(1, 1, 1), Theme.Colors.PanelAlt)
	Components.Padding(right, 12)
	local infoIcon = Components.Label({ Size = UDim2.new(1, 0, 0, 56), TextSize = 48, Text = "🔨", Parent = right })
	local infoName = Components.Label({ Size = UDim2.new(1, 0, 0, 28), Position = UDim2.fromOffset(0, 56), TextSize = Theme.TextSize.Large, Text = "", Parent = right })
	local infoDescription = Components.Label({ Size = UDim2.new(1, 0, 0, 60), Position = UDim2.fromOffset(0, 86), Font = Theme.Fonts.Body, TextSize = Theme.TextSize.Small, TextColor3 = Theme.Colors.TextMuted, TextYAlignment = Enum.TextYAlignment.Top, Text = "", Parent = right })
	local infoCost = Components.Label({ Size = UDim2.new(1, 0, 0, 84), Position = UDim2.fromOffset(0, 148), Font = Theme.Fonts.Bold, TextSize = Theme.TextSize.Small, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, Text = "", Parent = right })
	local status = Components.Label({ Size = UDim2.new(1, 0, 0, 36), Position = UDim2.fromOffset(0, 234), Font = Theme.Fonts.Bold, TextSize = Theme.TextSize.Small, Text = "", Parent = right })
	local placeButton = Components.Button({ Text = "PLACE", Color = Theme.Colors.Green, Size = UDim2.new(1, 0, 0, 48), Position = UDim2.fromOffset(0, 274), Parent = right, OnClick = confirmPlacement })
	local rotateButton = Components.Button({ Text = "⟳ ROTATE", Color = Theme.Colors.Blue, Size = UDim2.new(0.5, -4, 0, 44), Position = UDim2.fromOffset(0, 330), Parent = right, OnClick = function()
		rotate(90)
	end })
	local cancelButton = Components.Button({ Text = "CANCEL", Color = Theme.Colors.Red, Size = UDim2.new(0.5, -4, 0, 44), Position = UDim2.new(0.5, 4, 0, 330), Parent = right, OnClick = cancel })
	local moveButton = Components.Button({ Text = "MOVE", Color = Theme.Colors.Blue, Size = UDim2.new(0.5, -4, 0, 48), Position = UDim2.fromOffset(0, 274), Parent = right, OnClick = function()
		if editTarget then
			local uniqueId = editTarget:GetAttribute("UniqueId")
			local entry = ClientState.Get("Island", "Buildings", uniqueId)
			rotation = if entry and type(entry.Rotation) == "number" then entry.Rotation else 0
			makeGhost(tostring(editTarget:GetAttribute("BuildingId")))
			setMode("Moving")
		end
	end })
	local deleteButton = Components.Button({ Text = "DELETE", Color = Theme.Colors.Red, Size = UDim2.new(0.5, -4, 0, 48), Position = UDim2.new(0.5, 4, 0, 274), Parent = right, OnClick = function()
		if not editTarget then
			return
		end
		local now = os.clock()
		if now > deleteArmedUntil then
			-- Two taps to delete, so nothing is removed by accident.
			deleteArmedUntil = now + 3
			refs.DeleteButton.Text = "SURE?"
			return
		end
		Net.FireServer("DeleteBuildRequest", editTarget:GetAttribute("UniqueId"))
		setMode("Editing")
	end })
	local clearButton = Components.Button({ Text = "🪓 CLEAR IT", Color = Theme.Colors.Orange, Size = UDim2.new(1, 0, 0, 48), Position = UDim2.fromOffset(0, 274), Parent = right, OnClick = function()
		if not editTarget then
			return
		end
		local now = os.clock()
		if now > clearArmedUntil then
			clearArmedUntil = now + 3
			refs.ClearButton.Text = "SURE? (can't undo)"
			return
		end
		Net.FireServer("RemoveNodeRequest", editTarget:GetAttribute("NodeId"))
		setMode("Editing")
	end })

	local hints = Components.Label({
		Name = "Hints",
		Size = UDim2.fromOffset(640, 30),
		Position = UDim2.new(0.5, 0, 1, -118),
		AnchorPoint = Vector2.new(0.5, 1),
		BackgroundTransparency = 0.2,
		BackgroundColor3 = Theme.Colors.Outline,
		TextColor3 = Theme.Colors.TextLight,
		TextSize = Theme.TextSize.Small,
		Text = "",
		Parent = root,
	})
	Components.Corner(hints, UDim.new(1, 0))

	-- HUD button (left menu, under the bag).
	local buildButton = Components.IconButton({
		Icon = "🔨",
		Caption = "Build",
		Color = Theme.Colors.Orange,
		Parent = UIController.GetSlot("Left"),
		LayoutOrder = 2,
		OnClick = function()
			BuildController.Toggle()
		end,
	})

	refs = {
		Root = root,
		Banner = banner,
		Left = left,
		Tabs = tabs,
		List = list,
		Right = right,
		InfoIcon = infoIcon,
		InfoName = infoName,
		InfoDescription = infoDescription,
		InfoCost = infoCost,
		Status = status,
		PlaceButton = placeButton,
		RotateButton = rotateButton,
		CancelButton = cancelButton,
		MoveButton = moveButton,
		DeleteButton = deleteButton,
		ClearButton = clearButton,
		Hints = hints,
		BuildButton = buildButton,
	}
end

local paintCards: { TextButton } = {}

local function renderPalette()
	local entries = { "" }
	for _, material in IslandConfig.PaintOrder do
		table.insert(entries, material)
	end
	for index, material in entries do
		local card = paintCards[index]
		if not card then
			card = Create("TextButton", { Name = "Paint", Size = UDim2.new(1, -8, 0, 46), BackgroundColor3 = Theme.Colors.PanelAlt, AutoButtonColor = true, Text = "", Parent = refs.List })
			Components.Corner(card, Theme.SmallCorner)
			Components.Stroke(card, Theme.Colors.Outline, 2)
			local swatch = Create("Frame", { Name = "Swatch", Size = UDim2.fromOffset(34, 34), Position = UDim2.fromOffset(6, 6), Parent = card })
			Components.Corner(swatch, UDim.new(0, 8))
			Components.Stroke(swatch, Theme.Colors.Outline, 2)
			Components.Label({ Name = "Title", Size = UDim2.new(1, -56, 1, 0), Position = UDim2.fromOffset(50, 0), TextXAlignment = Enum.TextXAlignment.Left, TextSize = Theme.TextSize.Medium, Parent = card })
			card.Activated:Connect(function()
				local value = card:GetAttribute("Material")
				if type(value) == "string" then
					AudioController.Play("UIClick")
					LandEditor.SetMaterial(value)
					showInfo(nil)
					renderList()
				end
			end)
			paintCards[index] = card
		end
		card.Visible = true
		card.LayoutOrder = 100 + index
		card:SetAttribute("Material", material)
		local swatch = card:FindFirstChild("Swatch") :: Frame
		local title = card:FindFirstChild("Title") :: TextLabel
		local paint = IslandConfig.Paint[material]
		swatch.BackgroundColor3 = LandEditor.MaterialColors[material] or Theme.Colors.Panel
		title.Text = if paint then paint.DisplayName else "🧽 Eraser (natural)"
		card.BackgroundColor3 = if LandEditor.Material == material then Theme.Colors.Coins else Theme.Colors.PanelAlt
	end
end

renderList = function()
	for id, button in refs.Tabs do
		local selected
		if mode == "Editing" or mode == "Moving" then
			selected = id == "Edit"
		elseif isLandMode() then
			selected = id == mode
		else
			selected = id == category
		end
		Components.SetButtonColor(button, if selected then Theme.Colors.Coins else Theme.Colors.PanelAlt)
	end
	for _, card in paintCards do
		card.Visible = false
	end
	if mode == "Paint" then
		renderPalette()
	end
	local defs = {}
	if mode == "Menu" or mode == "Placing" then
		for _, def in BuildingConfig.Buildings do
			if def.Category == category and not def.Hidden then
				table.insert(defs, def)
			end
		end
		table.sort(defs, function(a, b)
			return a.Order < b.Order
		end)
	end
	for index, def in defs do
		local card = cards[index]
		if not card then
			card = Create("TextButton", { Name = "Card", Size = UDim2.new(1, -8, 0, 70), BackgroundColor3 = Theme.Colors.PanelAlt, AutoButtonColor = true, Text = "", Parent = refs.List })
			Components.Corner(card, Theme.SmallCorner)
			Components.Stroke(card, Theme.Colors.Outline, 2)
			Components.Label({ Name = "Icon", Size = UDim2.fromOffset(56, 56), Position = UDim2.fromOffset(6, 7), TextSize = 40, Parent = card })
			Components.Label({ Name = "Title", Size = UDim2.new(1, -72, 0, 24), Position = UDim2.fromOffset(66, 6), TextXAlignment = Enum.TextXAlignment.Left, TextSize = Theme.TextSize.Medium, Parent = card })
			Components.Label({ Name = "Cost", Size = UDim2.new(1, -72, 0, 36), Position = UDim2.fromOffset(66, 30), TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, Font = Theme.Fonts.Bold, TextSize = 12, TextColor3 = Theme.Colors.TextMuted, Parent = card })
			card.Activated:Connect(function()
				local buildingId = card:GetAttribute("BuildingId")
				if type(buildingId) == "string" then
					AudioController.Play("UIClick")
					selectBuilding(buildingId)
				end
			end)
			cards[index] = card
		end
		local canAfford = affordable(def)
		local locked = islandLevel() < def.UnlockLevel
		card.Visible = true
		card.LayoutOrder = index
		card:SetAttribute("BuildingId", def.Id)
		local icon = card:FindFirstChild("Icon") :: TextLabel
		local title = card:FindFirstChild("Title") :: TextLabel
		local cost = card:FindFirstChild("Cost") :: TextLabel
		icon.Text = def.Icon
		title.Text = def.DisplayName
		local parts = {}
		if (def.Cost.Coins or 0) > 0 then
			table.insert(parts, Format.Commas(def.Cost.Coins) .. " 🪙")
		end
		for itemId, amount in def.Cost.Items do
			local item = ItemConfig.Get(itemId)
			table.insert(parts, amount .. " " .. (if item then item.Icon else itemId))
		end
		local owned = def.Unique and alreadyOwned(def.Id)
		cost.Text = if locked then ("🔒 Island Level %d"):format(def.UnlockLevel) elseif owned then "✔ Already on your island" else table.concat(parts, "  ")
		cost.TextColor3 = if locked or owned then Theme.Colors.TextMuted elseif canAfford then Theme.Colors.Green else Theme.Colors.Red
		card.BackgroundColor3 = if locked then Theme.Colors.PanelDark else Theme.Colors.PanelAlt
	end
	for index = #defs + 1, #cards do
		cards[index].Visible = false
	end
end

---------------------------------------------------------------------------
-- Public API
---------------------------------------------------------------------------

function BuildController.IsActive(): boolean
	return active
end

function BuildController.Enter()
	if active or UIController.IsAnyModalOpen() then
		return
	end
	active = true
	refs.Root.Visible = true
	UIController.GetSlot("Right").Visible = false
	UIController.SetModalOpen("Build", true)
	CameraController.SetMode("Build")
	table.insert(releases, InteractionController.PausePrompts())
	table.insert(releases, InputController.Block("UseTool"))
	table.insert(releases, InputController.Block("Interact"))
	setMode("Menu")
	renderList()
end

function BuildController.Exit()
	if not active then
		return
	end
	active = false
	setMode("Menu")
	refs.Root.Visible = false
	UIController.GetSlot("Right").Visible = true
	UIController.SetModalOpen("Build", false)
	CameraController.SetMode("Default")
	for _, release in releases do
		release()
	end
	table.clear(releases)
end

-- Opens build mode straight on a tab ("Expand", "Paint", "Edit" or a category).
function BuildController.Open(tab: string?)
	if not active then
		BuildController.Enter()
	end
	if not active or not tab then
		return
	end
	if tab == "Expand" or tab == "Paint" then
		setMode(tab)
	elseif tab == "Edit" then
		setMode("Editing")
	else
		category = tab
		setMode("Menu")
	end
	renderList()
end

function BuildController.Toggle()
	if active then
		BuildController.Exit()
	else
		BuildController.Enter()
	end
end

function BuildController.Init()
	ghostHighlight = Instance.new("Highlight")
	ghostHighlight.Name = "BuildGhostHighlight"
	ghostHighlight.FillTransparency = 0.55
	ghostHighlight.OutlineTransparency = 0
	ghostHighlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	ghostHighlight.Enabled = false
	ghostHighlight.Parent = workspace.CurrentCamera

	selectionHighlight = Instance.new("Highlight")
	selectionHighlight.Name = "BuildSelectHighlight"
	selectionHighlight.FillColor = EDIT_COLOR
	selectionHighlight.OutlineColor = EDIT_COLOR
	selectionHighlight.FillTransparency = 0.7
	selectionHighlight.Enabled = false
	selectionHighlight.Parent = workspace.CurrentCamera

	buildUI()
end

function BuildController.Start()
	InputController.On("ToggleBuild", BuildController.Toggle)
	InputController.On("RotateBuild", function()
		rotate(90)
	end)
	InputController.On("RotateBuildRight", function()
		rotate(90)
	end)
	InputController.On("RotateBuildLeft", function()
		rotate(-90)
	end)
	InputController.On("Cancel", function()
		if active then
			cancel()
		end
	end)
	InputController.On("BuildPlace", function()
		if not active then
			return
		end
		if mode == "Editing" then
			tryPickBuilding(nil)
		elseif isLandMode() then
			LandEditor.Click(nil)
		else
			confirmPlacement()
		end
	end)
	UserInputService.TouchTapInWorld:Connect(function(position, processedByUI)
		if not active or processedByUI then
			return
		end
		pointer = position
		current.Key = ""
		if mode == "Editing" then
			tryPickBuilding(position)
		elseif isLandMode() then
			LandEditor.Click(position)
		end
	end)
	LandEditor.Start()
	-- Keep costs / locks fresh while the menu is open.
	for _, key in { "Coins", "Inventory", "Island" } do
		ClientState.Observe(key, function()
			if active and (mode == "Menu" or mode == "Paint") then
				renderList()
			elseif active and mode == "Expand" then
				showInfo(nil)
			end
		end)
	end
	InputController.DeviceChanged:Connect(function()
		if active then
			updateButtons()
		end
	end)
end

return BuildController
