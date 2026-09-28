--[[
	SCRIPT NAME:  FarmController
	SCRIPT TYPE:  ModuleScript (client controller)
	WHERE:        StarterPlayerScripts/Client/Controllers/FarmController
	DEPENDENCIES: Shared.Net, Shared.Config.CropConfig, Shared.Util.{CropGrowth, Format},
	              UIController, InputController, InteractionController, AudioController,
	              Client.UI.{Components, Theme}

	Client side of farming (spec §24-§28). The server owns every tile; this
	only SHOWS things and forwards choices:
	  * SEED PICKER — when you plant on a tilled tile while carrying more than
	    one kind of seed, the server sends OpenUI{Screen="SeedPicker"}; picking
	    one fires PlantCropRequest(tileId, seedId).
	  * CROP LABELS — a small billboard over each planted tile with the crop,
	    its stage, a live countdown ("ready in 0:42"), 💧 when watered and a
	    bouncing "READY!" when it can be harvested. Countdown math is the same
	    shared CropGrowth module the server uses, fed by the tile's attributes
	    (TileState, CropId, PlantedAt, WateredAt) and the synced server clock.
]]

local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Net = require(Shared:WaitForChild("Net"))
local CropConfig = require(Shared.Config.CropConfig)
local CropGrowth = require(Shared.Util.CropGrowth)
local Format = require(Shared.Util.Format)

local Client = script.Parent.Parent
local UIController = require(script.Parent.UIController)
local InputController = require(script.Parent.InputController)
local InteractionController = require(script.Parent.InteractionController)
local AudioController = require(script.Parent.AudioController)
local Components = require(Client.UI.Components)
local Theme = require(Client.UI.Theme)

local Create = Components.Create

local TILE_TAG = "FarmTile"
local LABEL_DISTANCE = 55
local UPDATE_INTERVAL = 0.5

local FarmController = {}

type Label = { Gui: BillboardGui, Title: TextLabel, Status: TextLabel, Bar: Frame, Fill: Frame }

local labels: { [BasePart]: Label } = {}
local picker: Frame
local pickerList: Frame
local pickerTileId: string? = nil
local pickerReleases: { () -> () } = {}

---------------------------------------------------------------------------
-- Seed picker
---------------------------------------------------------------------------

local function closePicker()
	if not picker.Visible then
		return
	end
	picker.Visible = false
	pickerTileId = nil
	UIController.SetModalOpen("SeedPicker", false)
	for _, release in pickerReleases do
		release()
	end
	table.clear(pickerReleases)
end

local function openPicker(tileId: string, seeds: { any })
	for _, child in pickerList:GetChildren() do
		if child:IsA("GuiButton") then
			child:Destroy()
		end
	end
	for index, option in seeds do
		local seedId = option.Seed
		local cropId = type(seedId) == "string" and CropConfig.SeedToCrop[seedId]
		local crop = cropId and CropConfig.Crops[cropId]
		if crop then
			local button = Components.Button({
				Name = seedId,
				Text = "",
				Color = Theme.Colors.PanelAlt,
				Size = UDim2.fromOffset(120, 132),
				Parent = pickerList,
				OnClick = function()
					if pickerTileId then
						Net.FireServer("PlantCropRequest", pickerTileId, seedId)
						AudioController.Play("PlantSeed")
					end
					closePicker()
				end,
			})
			button.LayoutOrder = index
			for _, child in button:GetChildren() do
				if child:IsA("UIStroke") and child.ApplyStrokeMode == Enum.ApplyStrokeMode.Contextual then
					child:Destroy()
				end
			end
			Components.Label({ Text = crop.Icon, Size = UDim2.new(1, 0, 0, 56), Position = UDim2.fromOffset(0, 6), TextSize = 44, Parent = button })
			Components.Label({ Text = crop.DisplayName, Size = UDim2.new(1, -8, 0, 22), Position = UDim2.fromOffset(4, 64), TextSize = Theme.TextSize.Medium, Parent = button })
			Components.Label({
				Text = ("x%d · %s"):format(tonumber(option.Count) or 0, Format.Duration(crop.GrowTime)),
				Size = UDim2.new(1, -8, 0, 18),
				Position = UDim2.fromOffset(4, 88),
				Font = Theme.Fonts.Bold,
				TextSize = 13,
				TextColor3 = Theme.Colors.TextMuted,
				Parent = button,
			})
			Components.Label({
				Text = ("sells %d 🪙"):format(crop.SellValue),
				Size = UDim2.new(1, -8, 0, 18),
				Position = UDim2.fromOffset(4, 106),
				Font = Theme.Fonts.Bold,
				TextSize = 13,
				TextColor3 = Theme.Colors.Green,
				Parent = button,
			})
		end
	end
	pickerTileId = tileId
	if picker.Visible then
		return
	end
	picker.Visible = true
	Components.Bounce(picker, 0.06)
	UIController.SetModalOpen("SeedPicker", true)
	table.insert(pickerReleases, InteractionController.PausePrompts())
end

local function buildPicker()
	local panel, content = Components.Panel({
		Title = "🌱 PICK A SEED",
		Size = UDim2.fromOffset(560, 250),
		Parent = UIController.GetModalLayer(),
		OnClose = closePicker,
	})
	panel.Name = "SeedPicker"
	panel.Visible = false
	local list = Create("ScrollingFrame", {
		Name = "Seeds",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 6,
		ScrollingDirection = Enum.ScrollingDirection.X,
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.X,
		Parent = content,
	}, {
		Create("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			Padding = UDim.new(0, 10),
			VerticalAlignment = Enum.VerticalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
		Create("UIPadding", { PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 4) }),
	})
	picker = panel
	pickerList = list
end

---------------------------------------------------------------------------
-- Crop labels
---------------------------------------------------------------------------

local function makeLabel(part: BasePart): Label
	local gui = Create("BillboardGui", {
		Name = "CropLabel",
		Size = UDim2.fromOffset(150, 58),
		StudsOffset = Vector3.new(0, 4.2, 0),
		MaxDistance = LABEL_DISTANCE,
		LightInfluence = 0,
		Enabled = false,
		Parent = part,
	})
	local title = Components.Label({
		Name = "Title",
		Size = UDim2.new(1, 0, 0, 24),
		TextSize = Theme.TextSize.Medium,
		TextColor3 = Theme.Colors.TextLight,
		Text = "",
		Parent = gui,
	})
	Components.TextStroke(title)
	local status = Components.Label({
		Name = "Status",
		Size = UDim2.new(1, 0, 0, 18),
		Position = UDim2.fromOffset(0, 23),
		Font = Theme.Fonts.Bold,
		TextSize = Theme.TextSize.Small,
		TextColor3 = Theme.Colors.TextLight,
		Text = "",
		Parent = gui,
	})
	Components.TextStroke(status, Theme.Colors.Outline, 1.5)
	local bar = Create("Frame", {
		Name = "Bar",
		Size = UDim2.new(0.7, 0, 0, 9),
		Position = UDim2.new(0.15, 0, 0, 45),
		BackgroundColor3 = Theme.Colors.Outline,
		Parent = gui,
	})
	Components.Corner(bar, UDim.new(1, 0))
	local fill = Create("Frame", { Name = "Fill", Size = UDim2.fromScale(0, 1), BackgroundColor3 = Theme.Colors.Green, Parent = bar })
	Components.Corner(fill, UDim.new(1, 0))
	local label = { Gui = gui, Title = title, Status = status, Bar = bar, Fill = fill }
	labels[part] = label
	part.Destroying:Once(function()
		labels[part] = nil
	end)
	return label
end

local function updateLabel(part: BasePart, label: Label, now: number)
	local state = part:GetAttribute("TileState")
	local cropId = part:GetAttribute("CropId")
	local crop = type(cropId) == "string" and CropConfig.Crops[cropId]
	if state ~= "Planted" or not crop then
		label.Gui.Enabled = false
		return
	end
	local entry = {
		CropId = cropId :: string,
		PlantedAt = part:GetAttribute("PlantedAt") :: number?,
		WateredAt = part:GetAttribute("WateredAt") :: number?,
	}
	local progress = CropGrowth.GetProgress(entry, now)
	local stage = CropGrowth.GetStage(entry, now)
	local watered = CropGrowth.IsWatered(entry)
	label.Gui.Enabled = true
	label.Title.Text = crop.Icon .. " " .. crop.DisplayName
	if progress >= 1 then
		label.Status.Text = "✨ READY! Harvest me"
		label.Status.TextColor3 = Theme.Colors.Coins
		label.Fill.BackgroundColor3 = Theme.Colors.Coins
		-- Gentle bounce so ready crops catch the eye.
		label.Gui.StudsOffset = Vector3.new(0, 4.2 + math.abs(math.sin(now * 3)) * 0.5, 0)
	else
		local remaining = CropGrowth.GetRemaining(entry, now)
		label.Status.Text = ("%s · %s%s"):format(CropConfig.Stages[stage], Format.Duration(math.ceil(remaining)), if watered then " 💧" else "")
		label.Status.TextColor3 = if watered then Color3.fromRGB(150, 215, 255) else Theme.Colors.TextLight
		label.Fill.BackgroundColor3 = if watered then Theme.Colors.Blue else Theme.Colors.Green
		label.Gui.StudsOffset = Vector3.new(0, 4.2, 0)
	end
	label.Fill.Size = UDim2.fromScale(progress, 1)
end

local function updateLabels()
	local camera = workspace.CurrentCamera
	if not camera then
		return
	end
	local now = workspace:GetServerTimeNow()
	local eye = camera.CFrame.Position
	for _, instance in CollectionService:GetTagged(TILE_TAG) do
		if instance:IsA("BasePart") then
			local label = labels[instance]
			if (instance.Position - eye).Magnitude <= LABEL_DISTANCE + 10 then
				updateLabel(instance, label or makeLabel(instance), now)
			elseif label then
				label.Gui.Enabled = false
			end
		end
	end
end

---------------------------------------------------------------------------
-- Lifecycle
---------------------------------------------------------------------------

function FarmController.Init()
	buildPicker()
end

function FarmController.Start()
	Net.OnClientEvent("OpenUI", function(payload: any)
		if type(payload) ~= "table" or payload.Screen ~= "SeedPicker" then
			return
		end
		if type(payload.TileId) ~= "string" or type(payload.Seeds) ~= "table" then
			return
		end
		if UIController.IsAnyModalOpen() and not picker.Visible then
			return
		end
		openPicker(payload.TileId, payload.Seeds)
	end)
	InputController.On("Cancel", closePicker)

	task.spawn(function()
		while true do
			updateLabels()
			task.wait(UPDATE_INTERVAL)
		end
	end)
end

return FarmController
