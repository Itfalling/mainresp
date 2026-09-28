--[[
	SCRIPT NAME:  GatherController
	SCRIPT TYPE:  ModuleScript (client controller)
	WHERE:        StarterPlayerScripts/Client/Controllers/GatherController
	DEPENDENCIES: Shared.Net, ToolController, Shared.Util.R15, Shared.Config.{BuildingConfig, BuildConfig},
	              Client.UI.{Theme, Components}

	What a tool swing HITS. When ToolController reports the swing's impact
	marker (Hit / Dig / HammerHit), this finds the node or construction site
	in front of you and asks the server to apply it:
	  Axe / Pickaxe / Shovel -> GatherRequest(nodeId)
	  Hammer                 -> BuildRequest{Op="Hammer", UniqueId}
	The server re-validates distance, tool and ownership.

	Feedback (client-only, no network): a health bar over a hit node and a
	quick wobble so every hit visibly lands (spec §15 "each chop gives progress").
]]

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Net = require(Shared:WaitForChild("Net"))
local R15 = require(Shared.Util.R15)
local BuildingConfig = require(Shared.Config.BuildingConfig)
local BuildConfig = require(Shared.Config.BuildConfig)

local Client = script.Parent.Parent
local ToolController = require(script.Parent.ToolController)
local Theme = require(Client.UI.Theme)
local Components = require(Client.UI.Components)

local NODE_TAG = "ResourceNode"
local SITE_TAG = "ConstructionSite"
local SWING_REACH = 10
local BAR_VISIBLE_TIME = 3

local GatherController = {}

local bars: { [Model]: { Gui: BillboardGui, Fill: Frame, HideAt: number } } = {}

local function rootPart(): BasePart?
	return R15.GetRootPart(Players.LocalPlayer.Character)
end

-- Nearest tagged model in front of the character within reach.
local function findTarget(tag: string, reach: number, filter: (Model) -> boolean): Model?
	local root = rootPart()
	if not root then
		return nil
	end
	local best, bestScore = nil, math.huge
	for _, instance in CollectionService:GetTagged(tag) do
		if instance:IsA("Model") and filter(instance) then
			local pivot = instance:GetPivot().Position
			local offset = Vector3.new(pivot.X - root.Position.X, 0, pivot.Z - root.Position.Z)
			local distance = offset.Magnitude
			local facing = if distance > 0.1 then root.CFrame.LookVector:Dot(offset.Unit) else 1
			if distance <= reach and facing > -0.2 then
				local score = distance - facing * 3
				if score < bestScore then
					best, bestScore = instance, score
				end
			end
		end
	end
	return best
end

local function onImpact(toolDef: any)
	if toolDef.Type == "Hammer" then
		-- Same reach rule as BuildService: HammerRange + half the footprint.
		local root = rootPart()
		local site = findTarget(SITE_TAG, 80, function(model)
			local def = BuildingConfig.Get(model:GetAttribute("BuildingId"))
			if not def or not root then
				return false
			end
			local reach = BuildConfig.HammerRange + math.max(def.Footprint.X, def.Footprint.Y) / 2
			return (model:GetPivot().Position - root.Position).Magnitude <= reach
		end)
		if site then
			Net.FireServer("BuildRequest", { Op = "Hammer", UniqueId = site:GetAttribute("UniqueId") })
		end
		return
	end
	local node = findTarget(NODE_TAG, SWING_REACH, function(model)
		return model:GetAttribute("Depleted") ~= true and model:GetAttribute("ToolType") == toolDef.Type
	end)
	if node then
		Net.FireServer("GatherRequest", node:GetAttribute("NodeId"))
	end
end

local function barFor(model: Model)
	local existing = bars[model]
	if existing then
		return existing
	end
	local anchor = model.PrimaryPart
	if not anchor then
		return nil
	end
	local gui = Instance.new("BillboardGui")
	gui.Name = "HealthBar"
	gui.Size = UDim2.fromOffset(110, 16)
	gui.StudsOffset = Vector3.new(0, anchor.Size.Y / 2 + 1.5, 0)
	gui.AlwaysOnTop = true
	gui.MaxDistance = 60
	gui.Enabled = false
	local back = Instance.new("Frame")
	back.Size = UDim2.fromScale(1, 1)
	back.BackgroundColor3 = Theme.Colors.Outline
	back.Parent = gui
	Components.Corner(back, UDim.new(1, 0))
	local fill = Instance.new("Frame")
	fill.Size = UDim2.fromScale(1, 1)
	fill.BackgroundColor3 = Theme.Colors.Green
	fill.Parent = back
	Components.Corner(fill, UDim.new(1, 0))
	gui.Parent = anchor
	local bar = { Gui = gui, Fill = fill, HideAt = 0 }
	bars[model] = bar
	model.Destroying:Once(function()
		bars[model] = nil
	end)
	return bar
end

local function wobble(model: Model)
	local base = model:GetPivot()
	local driver = Instance.new("NumberValue")
	driver.Changed:Connect(function(alpha)
		if model.Parent then
			model:PivotTo(base * CFrame.Angles(math.sin(alpha * math.pi * 3) * 0.05 * (1 - alpha), 0, 0))
		end
	end)
	local tween = TweenService:Create(driver, TweenInfo.new(0.3), { Value = 1 })
	tween.Completed:Once(function()
		driver:Destroy()
		if model.Parent and model:GetAttribute("Depleted") ~= true then
			model:PivotTo(base)
		end
	end)
	tween:Play()
end

local function onHealthChanged(model: Model)
	local health = model:GetAttribute("Health")
	local maxHealth = model:GetAttribute("MaxHealth")
	if type(health) ~= "number" or type(maxHealth) ~= "number" or maxHealth <= 1 then
		return
	end
	local bar = barFor(model)
	if not bar then
		return
	end
	local alpha = math.clamp(health / maxHealth, 0, 1)
	bar.Gui.Enabled = health > 0 and health < maxHealth
	bar.Fill.BackgroundColor3 = Theme.Colors.Red:Lerp(Theme.Colors.Green, alpha)
	TweenService:Create(bar.Fill, TweenInfo.new(0.2), { Size = UDim2.fromScale(alpha, 1) }):Play()
	bar.HideAt = os.clock() + BAR_VISIBLE_TIME
	if health > 0 and health < maxHealth then
		wobble(model)
	end
end

local function watchNode(instance: Instance)
	if not instance:IsA("Model") then
		return
	end
	instance:GetAttributeChangedSignal("Health"):Connect(function()
		onHealthChanged(instance)
	end)
end

function GatherController.Start()
	ToolController.ToolImpact:Connect(onImpact)
	for _, node in CollectionService:GetTagged(NODE_TAG) do
		watchNode(node)
	end
	CollectionService:GetInstanceAddedSignal(NODE_TAG):Connect(watchNode)

	-- Hide idle health bars (one cheap loop, not per-node timers).
	task.spawn(function()
		while true do
			task.wait(0.5)
			local now = os.clock()
			for _, bar in bars do
				if bar.Gui.Enabled and now > bar.HideAt then
					bar.Gui.Enabled = false
				end
			end
		end
	end)
end

return GatherController
