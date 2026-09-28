--[[
	SCRIPT NAME:  AnimalController
	SCRIPT TYPE:  ModuleScript (client controller)
	WHERE:        StarterPlayerScripts/Client/Controllers/AnimalController
	DEPENDENCIES: Shared.Config.{AnimalConfig, ItemConfig}, Shared.Util.Format, Client.UI.{Components, Theme}

	Floating status over every animal (spec §34-§37, §101): name, a heart
	meter for happiness and what it needs RIGHT NOW —
	  🌾 Hungry  → feed it (1 Wheat)
	  ⏳ 0:42    → producing
	  🥛 READY!  → milk / collect
	Everything comes from attributes the server sets on the animal model
	(Status, Happiness, ReadyAt), so this never guesses. The countdown uses
	the synced server clock. Only animals near the camera are updated.
]]

local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local AnimalConfig = require(Shared.Config.AnimalConfig)
local ItemConfig = require(Shared.Config.ItemConfig)
local Format = require(Shared.Util.Format)

local Client = script.Parent.Parent
local Components = require(Client.UI.Components)
local Theme = require(Client.UI.Theme)

local Create = Components.Create

local TAG = "Animal"
local LABEL_DISTANCE = 60
local UPDATE_INTERVAL = 0.5

local AnimalController = {}

type Label = { Gui: BillboardGui, Name: TextLabel, Hearts: TextLabel, Status: TextLabel }

local labels: { [Model]: Label } = {}

local function makeLabel(model: Model): Label?
	local body = model.PrimaryPart
	if not body then
		return nil
	end
	local gui = Create("BillboardGui", {
		Name = "AnimalLabel",
		Size = UDim2.fromOffset(160, 62),
		StudsOffset = Vector3.new(0, body.Size.Y / 2 + 2.6, 0),
		MaxDistance = LABEL_DISTANCE,
		LightInfluence = 0,
		Parent = body,
	})
	local name = Components.Label({ Size = UDim2.new(1, 0, 0, 22), TextSize = Theme.TextSize.Medium, TextColor3 = Theme.Colors.TextLight, Text = "", Parent = gui })
	Components.TextStroke(name)
	local hearts = Components.Label({ Size = UDim2.new(1, 0, 0, 16), Position = UDim2.fromOffset(0, 22), TextSize = 13, Text = "", Parent = gui })
	local status = Components.Label({
		Size = UDim2.new(1, 0, 0, 22),
		Position = UDim2.fromOffset(0, 39),
		BackgroundTransparency = 0.15,
		BackgroundColor3 = Theme.Colors.Outline,
		Font = Theme.Fonts.Bold,
		TextSize = Theme.TextSize.Small,
		TextColor3 = Theme.Colors.TextLight,
		Text = "",
		Parent = gui,
	})
	Components.Corner(status, UDim.new(1, 0))
	local label = { Gui = gui, Name = name, Hearts = hearts, Status = status }
	labels[model] = label
	model.Destroying:Once(function()
		labels[model] = nil
	end)
	return label
end

local function heartsText(happiness: number): string
	local full = math.clamp(math.floor(happiness / 20 + 0.5), 0, 5)
	return string.rep("❤️", full) .. string.rep("🤍", 5 - full)
end

local function updateLabel(model: Model, label: Label, now: number)
	local def = AnimalConfig.Animals[model:GetAttribute("AnimalId") or ""]
	if not def then
		label.Gui.Enabled = false
		return
	end
	label.Gui.Enabled = true
	local variant = model:GetAttribute("Variant")
	label.Name.Text = (if variant == "Golden" then "✨ Golden " else "") .. def.DisplayName
	label.Name.TextColor3 = if variant == "Golden" then Theme.Colors.Coins else Theme.Colors.TextLight
	label.Hearts.Text = heartsText(tonumber(model:GetAttribute("Happiness")) or 0)

	local status = model:GetAttribute("Status")
	local produce = ItemConfig.Get(def.Produce)
	local produceIcon = if produce then produce.Icon else "✨"
	if status == "Ready" then
		label.Status.Text = ("%s READY! %s"):format(produceIcon, def.ProduceVerb)
		label.Status.BackgroundColor3 = Theme.Colors.Green
	elseif status == "Producing" then
		local readyAt = tonumber(model:GetAttribute("ReadyAt")) or now
		label.Status.Text = ("⏳ %s in %s"):format(def.Produce, Format.Duration(math.max(0, math.ceil(readyAt - now))))
		label.Status.BackgroundColor3 = Theme.Colors.Outline
	else
		local food = ItemConfig.Get(def.Food)
		label.Status.Text = ("%s Hungry — feed %d %s"):format(if food then food.Icon else "🍽️", def.FoodAmount, def.Food)
		label.Status.BackgroundColor3 = Theme.Colors.Orange
	end
end

local function updateAll()
	local camera = workspace.CurrentCamera
	if not camera then
		return
	end
	local now = workspace:GetServerTimeNow()
	local eye = camera.CFrame.Position
	for _, instance in CollectionService:GetTagged(TAG) do
		if instance:IsA("Model") then
			local label = labels[instance]
			local near = (instance:GetPivot().Position - eye).Magnitude <= LABEL_DISTANCE + 10
			if near then
				label = label or makeLabel(instance)
				if label then
					updateLabel(instance, label, now)
				end
			elseif label then
				label.Gui.Enabled = false
			end
		end
	end
end

function AnimalController.Start()
	task.spawn(function()
		while true do
			updateAll()
			task.wait(UPDATE_INTERVAL)
		end
	end)
end

return AnimalController
