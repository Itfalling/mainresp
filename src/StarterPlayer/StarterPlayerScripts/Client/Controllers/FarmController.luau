--[[
	SCRIPT NAME:  FarmController
	SCRIPT TYPE:  ModuleScript (client controller)
	WHERE:        StarterPlayerScripts/Client/Controllers/FarmController
	DEPENDENCIES: Shared.Config.CropConfig, Shared.Util.{CropGrowth, Format}, Client.UI.{Components, Theme}

	Crop labels over every planted soil tile: the crop, its stage, a live
	countdown ("ready in 0:42"), 💧 when watered and a bouncing "READY!" when
	it can be harvested. Farming itself is click-to-interact (hold a hoe,
	seed sack or watering can and click the tile — InteractionController).
	Countdown math is the same shared CropGrowth module the server uses, fed
	by the tile's attributes and the synced server clock.
]]

local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local CropConfig = require(Shared.Config.CropConfig)
local CropGrowth = require(Shared.Util.CropGrowth)
local Format = require(Shared.Util.Format)

local Client = script.Parent.Parent
local Components = require(Client.UI.Components)
local Theme = require(Client.UI.Theme)

local Create = Components.Create

local TILE_TAG = "Interactable"
local LABEL_DISTANCE = 55
local UPDATE_INTERVAL = 0.5

local FarmController = {}

type Label = { Gui: BillboardGui, Title: TextLabel, Status: TextLabel, Bar: Frame, Fill: Frame }

local labels: { [BasePart]: Label } = {}
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
		if instance:IsA("BasePart") and instance:GetAttribute("Interact") == "FarmTile" then
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

function FarmController.Start()
	task.spawn(function()
		while true do
			updateLabels()
			task.wait(UPDATE_INTERVAL)
		end
	end)
end

return FarmController
