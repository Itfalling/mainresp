--[[
	SCRIPT NAME:  InteractionController
	SCRIPT TYPE:  ModuleScript (client controller)
	WHERE:        StarterPlayerScripts/Client/Controllers/InteractionController
	DEPENDENCIES: Shared.Net, Shared.Config.{ResourceConfig, AnimalConfig, CropConfig, AnimationConfig},
	              Shared.Util.R15, InputController, UIController, ToolController, AnimationController,
	              AudioController, Client.UI.{Components, Theme}

	CLICK-TO-INTERACT. No prompts: hold a tool or item and click the thing.

	  HOVER    the object under your mouse (or the centre of the screen on a
	           gamepad) gets an OUTLINE and a small tooltip next to the cursor:
	             green  "🪓 Chop · Oak Tree"            you can do it now
	             yellow "Hold your 🪓 Axe (press 1)"     you need something
	             red    "Owner only"                    not allowed here
	  CLICK    (mouse / R2 / E / tap / USE button) on the hovered object:
	           too far? your character WALKS over and then does it.
	           Your animation starts instantly (predicted) and the request
	           goes to the server (InteractRequest), which checks everything
	           and plays it for everyone.
	  NOTHING  under the cursor with a tool in hand = a practice swing.

	Other controllers can claim clicks first with SetClickHandler (fishing:
	click the water to cast; build mode pauses everything).
	Objects are found by the "Interactable" tag the server puts on them.
]]

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Net = require(Shared:WaitForChild("Net"))
local ResourceConfig = require(Shared.Config.ResourceConfig)
local AnimalConfig = require(Shared.Config.AnimalConfig)
local CropConfig = require(Shared.Config.CropConfig)
local AnimationConfig = require(Shared.Config.AnimationConfig)
local R15 = require(Shared.Util.R15)

local Client = script.Parent.Parent
local InputController = require(script.Parent.InputController)
local UIController = require(script.Parent.UIController)
local ToolController = require(script.Parent.ToolController)
local AnimationController = require(script.Parent.AnimationController)
local AudioController = require(script.Parent.AudioController)
local Components = require(Client.UI.Components)
local Theme = require(Client.UI.Theme)

local Create = Components.Create
local player = Players.LocalPlayer

local TAG = "Interactable"
local RAY_LENGTH = 320
local WALK_TIMEOUT = 5
local VISITOR_PERMISSIONS = { Visitor = true, Fish = true, Market = true }
local SWING_TYPES = { Axe = true, Pickaxe = true, Hammer = true, Hoe = true, Shovel = true }
local TOOL_KEYS = { Axe = "🪓 Axe", Pickaxe = "⛏️ Pickaxe", Hammer = "🔨 Hammer", Hoe = "🌱 Hoe", Shovel = "🪏 Shovel", WateringCan = "🚿 Watering Can", FishingRod = "🎣 Fishing Rod", Bucket = "🪣 Bucket" }

local COLORS = {
	Ok = Color3.fromRGB(110, 240, 130),
	Need = Color3.fromRGB(255, 214, 90),
	Blocked = Color3.fromRGB(255, 100, 90),
	Neutral = Color3.fromRGB(255, 250, 230),
}

export type Target = { Object: Instance?, Position: Vector3, Water: boolean }
export type Hint = { Text: string, State: string, Anim: string?, Speed: number? }

local InteractionController = {}

local highlight: Highlight
local tooltip: Frame
local tooltipText: TextLabel
local tooltipSub: TextLabel
local reticle: Frame
local pauseCount = 0
local hover: Target? = nil
local hoverHint: Hint? = nil
local clickHandlers: { (Target?) -> boolean } = {}
local localBusyUntil = 0
local lastSwing = 0
local walkThread: thread? = nil

local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Exclude
rayParams.IgnoreWater = false

---------------------------------------------------------------------------
-- Helpers
---------------------------------------------------------------------------

local function rootPart(): BasePart?
	return R15.GetRootPart(player.Character)
end

local function interactableOf(instance: Instance?): Instance?
	local current = instance
	for _ = 1, 8 do
		if not current or current == workspace then
			return nil
		end
		if CollectionService:HasTag(current, TAG) then
			return current
		end
		current = current.Parent
	end
	return nil
end

local function boxOf(object: Instance): (CFrame?, Vector3?)
	if object:IsA("Model") then
		return object:GetBoundingBox()
	elseif object:IsA("BasePart") then
		return object.CFrame, object.Size
	end
	return nil, nil
end

local function distanceTo(object: Instance, point: Vector3): number
	local cframe, size = boxOf(object)
	if not cframe or not size then
		return math.huge
	end
	local relative = cframe:PointToObjectSpace(point)
	local half = size / 2
	local clamped = Vector3.new(math.clamp(relative.X, -half.X, half.X), math.clamp(relative.Y, -half.Y, half.Y), math.clamp(relative.Z, -half.Z, half.Z))
	return (relative - clamped).Magnitude
end

local function objectPosition(object: Instance): Vector3
	local cframe = boxOf(object)
	return if cframe then cframe.Position else Vector3.zero
end

local function islandOf(object: Instance): Instance?
	local islands = workspace:FindFirstChild("Islands")
	local current: Instance? = object
	while current and current ~= workspace do
		if current.Parent == islands then
			return current
		end
		current = current.Parent
	end
	return nil
end

-- Mirrors the server's permission rule, for the tooltip only (the server decides).
local function allowed(object: Instance): boolean
	local permission = object:GetAttribute("InteractPermission")
	if permission == nil or VISITOR_PERMISSIONS[permission] then
		return true
	end
	local owner = object:GetAttribute("OwnerUserId")
	if owner == nil or owner == player.UserId then
		return true
	end
	if permission == "Owner" then
		return false
	end
	local island = islandOf(object)
	local helpers = island and island:GetAttribute("Helpers")
	return type(helpers) == "string" and string.find("," .. helpers .. ",", "," .. player.UserId .. ",", 1, true) ~= nil
end

local function toolName(toolType: string): string
	return TOOL_KEYS[toolType] or toolType
end

---------------------------------------------------------------------------
-- What will a click do? (tooltip + predicted animation)
---------------------------------------------------------------------------

local HINTS: { [string]: (Instance, ToolController.Held?) -> Hint } = {}

HINTS.ResourceNode = function(object, held)
	local def = ResourceConfig.Nodes[object:GetAttribute("NodeType") or ""]
	local label = object:GetAttribute("InteractLabel") or "Resource"
	if not def then
		return { Text = label, State = "Neutral" }
	end
	if not def.ToolType then
		return { Text = ("✋ %s · %s"):format(def.Action, label), State = "Ok", Anim = def.Animation or "PickCrop" }
	end
	local tool = held and held.Kind == "Tool" and held.Def
	if not tool or tool.Type ~= def.ToolType then
		return { Text = ("Hold your %s to %s"):format(toolName(def.ToolType), string.lower(def.Action)), State = "Need" }
	end
	if tool.TierOrder < def.MinTier then
		return { Text = ("Needs a better %s"):format(def.ToolType), State = "Blocked" }
	end
	return { Text = ("%s %s · %s"):format(tool.Icon, def.Action, label), State = "Ok", Anim = tool.Animations.Use, Speed = tool.Speed }
end

HINTS.ConstructionSite = function(object, held)
	local tool = held and held.Kind == "Tool" and held.Def
	if tool and tool.Type == "Hammer" then
		return { Text = "🔨 Build · " .. tostring(object:GetAttribute("InteractLabel") or ""), State = "Ok", Anim = "HammerSwing", Speed = tool.Speed }
	end
	return { Text = "Hold your 🔨 Hammer to build", State = "Need" }
end

HINTS.FarmTile = function(object, held)
	local hint = object:GetAttribute("InteractHint")
	local tool = held and held.Kind == "Tool" and held.Def
	local cropId = object:GetAttribute("CropId")
	local crop = type(cropId) == "string" and CropConfig.Crops[cropId]
	if hint == "Till" then
		if tool and tool.Type == "Hoe" then
			return { Text = "🌱 Till soil", State = "Ok", Anim = tool.Animations.Use, Speed = tool.Speed }
		end
		return { Text = "Hold your 🌱 Hoe to till", State = "Need" }
	elseif hint == "Plant" then
		local seedCrop = held and held.Kind == "Item" and CropConfig.SeedToCrop[held.Id]
		if seedCrop then
			return { Text = ("%s Plant %s"):format(held and held.Def.Icon or "", CropConfig.Crops[seedCrop].DisplayName), State = "Ok", Anim = "PlantSeed" }
		end
		return { Text = "Hold a seed sack to plant", State = "Need" }
	elseif hint == "Harvest" then
		return { Text = ("✨ Harvest %s"):format(if crop then crop.DisplayName else ""), State = "Ok", Anim = "HarvestCrop" }
	elseif hint == "Water" then
		if tool and tool.Type == "WateringCan" then
			return { Text = "🚿 Water " .. (if crop then crop.DisplayName else "crop"), State = "Ok", Anim = "WaterPlant", Speed = tool.Speed }
		end
		return { Text = (if crop then crop.Icon .. " " .. crop.DisplayName else "Crop") .. " · hold 🚿 to water", State = "Neutral" }
	end
	return { Text = (if crop then crop.Icon .. " " .. crop.DisplayName else "Crop") .. " · growing", State = "Neutral" }
end

HINTS.Animal = function(object, held)
	local def = AnimalConfig.Animals[object:GetAttribute("AnimalId") or ""]
	if not def then
		return { Text = "Animal", State = "Neutral" }
	end
	local status = object:GetAttribute("Status")
	local tool = held and held.Kind == "Tool" and held.Def
	if status == "Ready" then
		if def.ProduceTool and not (tool and tool.Type == def.ProduceTool) then
			return { Text = ("Hold your %s to collect %s"):format(toolName(def.ProduceTool), def.Produce), State = "Need" }
		end
		return { Text = "✨ " .. def.ProduceVerb, State = "Ok", Anim = def.ProduceAnimation }
	end
	if status == "Hungry" then
		if held and held.Id == def.Food then
			return { Text = ("%s Feed %s"):format(held.Def.Icon, def.DisplayName), State = "Ok", Anim = "FeedAnimal" }
		end
		return { Text = ("Hungry! Hold %s to feed · click to pet"):format(def.Food), State = "Need", Anim = "PetAnimal" }
	end
	return { Text = "💕 Pet " .. def.DisplayName, State = "Ok", Anim = "PetAnimal" }
end

HINTS.Market = function()
	return { Text = "🛒 Open the market", State = "Ok" }
end

HINTS.MerchantTalk = function()
	return { Text = "💬 Talk to Mia", State = "Ok" }
end

HINTS.StarterChest = function()
	return { Text = "📦 Open your starter chest", State = "Ok", Anim = "OpenChest" }
end

HINTS.IslandSign = function(object)
	local owner = object:GetAttribute("OwnerUserId")
	return { Text = if owner == player.UserId then "✏️ Island settings" else "🏝️ Island info · ❤️ like", State = "Ok" }
end

local function hintFor(object: Instance): Hint
	if object:GetAttribute("InteractDisabled") then
		return { Text = "", State = "Hidden" }
	end
	if not allowed(object) then
		local permission = object:GetAttribute("InteractPermission")
		return { Text = if permission == "Owner" then "🔒 Owner only" else "🔒 Ask the owner to make you a helper", State = "Blocked" }
	end
	local kind = object:GetAttribute("Interact")
	local builder = type(kind) == "string" and HINTS[kind]
	if builder then
		return builder(object, ToolController.GetHeld())
	end
	return { Text = tostring(object:GetAttribute("InteractLabel") or ""), State = "Ok" }
end

---------------------------------------------------------------------------
-- Hover
---------------------------------------------------------------------------

local function screenRay(point: Vector2?): Ray?
	local camera = workspace.CurrentCamera
	if not camera then
		return nil
	end
	if point then
		return camera:ViewportPointToRay(point.X, point.Y)
	end
	if InputController.GetDevice() == "Gamepad" then
		local size = camera.ViewportSize
		return camera:ViewportPointToRay(size.X / 2, size.Y / 2)
	end
	local mouse = UserInputService:GetMouseLocation()
	return camera:ViewportPointToRay(mouse.X, mouse.Y)
end

local function castTarget(point: Vector2?): Target?
	local ray = screenRay(point)
	if not ray then
		return nil
	end
	local exclude: { Instance } = {}
	if player.Character then
		table.insert(exclude, player.Character)
	end
	for _, name in { "ClientEffects", "ClientAudio" } do
		local folder = workspace:FindFirstChild(name)
		if folder then
			table.insert(exclude, folder)
		end
	end
	local camera = workspace.CurrentCamera
	if camera then
		table.insert(exclude, camera)
	end
	rayParams.FilterDescendantsInstances = exclude
	local hit = workspace:Raycast(ray.Origin, ray.Direction * RAY_LENGTH, rayParams)
	if not hit then
		return nil
	end
	local object = interactableOf(hit.Instance)
	return { Object = object, Position = hit.Position, Water = hit.Material == Enum.Material.Water }
end

local function setHighlight(object: Instance?, color: Color3)
	if object and (object:IsA("Model") or object:IsA("BasePart")) then
		highlight.Adornee = object
		highlight.OutlineColor = color
		highlight.FillColor = color
		highlight.Enabled = true
	else
		highlight.Enabled = false
		highlight.Adornee = nil
	end
end

local function showTooltip(hint: Hint?, position: Vector2?)
	if not hint or hint.Text == "" or hint.State == "Hidden" then
		tooltip.Visible = false
		return
	end
	tooltipText.Text = hint.Text
	local color = COLORS[hint.State] or COLORS.Neutral
	tooltip.BackgroundColor3 = Theme.Colors.Glass
	local stroke = tooltip:FindFirstChildOfClass("UIStroke")
	if stroke then
		stroke.Color = color
	end
	tooltipText.TextColor3 = color
	local root = rootPart()
	local object = hover and hover.Object
	local range = object and tonumber(object:GetAttribute("InteractRange"))
	if object and root and range and distanceTo(object, root.Position) > range + 1 and hint.State == "Ok" then
		tooltipSub.Text = if InputController.IsTouch() then "tap to walk there" else "click to walk there"
	else
		tooltipSub.Text = ""
	end
	tooltipSub.Visible = tooltipSub.Text ~= ""
	tooltip.Size = UDim2.fromOffset(math.max(tooltipText.TextBounds.X, tooltipSub.TextBounds.X) + 26, if tooltipSub.Visible then 50 else 32)
	if position then
		tooltip.Position = UDim2.fromOffset(position.X + 20, position.Y + 16)
	end
	tooltip.Visible = true
end

local function updateHover()
	if pauseCount > 0 or UIController.IsAnyModalOpen() or InputController.IsTouch() then
		hover = nil
		hoverHint = nil
		setHighlight(nil, COLORS.Ok)
		showTooltip(nil, nil)
		reticle.Visible = false
		return
	end
	local gamepad = InputController.GetDevice() == "Gamepad"
	reticle.Visible = gamepad
	local target = castTarget(nil)
	hover = target
	local object = target and target.Object
	if object then
		local hint = hintFor(object)
		hoverHint = hint
		setHighlight(if hint.State == "Hidden" then nil else object, COLORS[hint.State] or COLORS.Neutral)
		local mouse = if gamepad
			then (workspace.CurrentCamera :: Camera).ViewportSize / 2
			else UserInputService:GetMouseLocation()
		showTooltip(hint, UIController.ViewportToDesign(mouse))
	else
		hoverHint = nil
		setHighlight(nil, COLORS.Ok)
		-- Holding a rod over water shows where you'd cast.
		local held = ToolController.GetHeld()
		if target and target.Water and held and held.Kind == "Tool" and held.Def.Type == "FishingRod" then
			local mouse = if gamepad then (workspace.CurrentCamera :: Camera).ViewportSize / 2 else UserInputService:GetMouseLocation()
			showTooltip({ Text = "🎣 Cast here", State = "Ok" }, UIController.ViewportToDesign(mouse))
		else
			showTooltip(nil, nil)
		end
	end
end

---------------------------------------------------------------------------
-- Clicking
---------------------------------------------------------------------------

local function faceTarget(position: Vector3)
	local root = rootPart()
	if not root then
		return
	end
	local flat = Vector3.new(position.X, root.Position.Y, position.Z)
	if (flat - root.Position).Magnitude > 0.5 then
		root.CFrame = CFrame.lookAt(root.Position, flat)
	end
end

local function perform(object: Instance, hint: Hint)
	faceTarget(objectPosition(object))
	local now = os.clock()
	if hint.Anim and now >= localBusyUntil then
		local def = AnimationConfig.Get(hint.Anim)
		if def then
			local speed = hint.Speed or 1
			localBusyUntil = now + def.Length / speed * 0.85
			AnimationController.PlayLocal(hint.Anim, speed)
		end
	end
	Net.FireServer("InteractRequest", object)
end

local function cancelWalk()
	if walkThread then
		pcall(task.cancel, walkThread)
		walkThread = nil
	end
end

-- Walks up to an object, then interacts (unless you move away / it disappears).
local function walkThenPerform(object: Instance, hint: Hint)
	cancelWalk()
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local root = rootPart()
	if not humanoid or not root then
		return
	end
	local range = tonumber(object:GetAttribute("InteractRange")) or 8
	walkThread = task.spawn(function()
		local started = os.clock()
		while os.clock() - started < WALK_TIMEOUT do
			if not object.Parent or not root.Parent then
				break
			end
			local distance = distanceTo(object, root.Position)
			if distance <= range - 0.5 then
				humanoid:Move(Vector3.zero)
				perform(object, hintFor(object))
				break
			end
			local goal = objectPosition(object)
			humanoid:MoveTo(Vector3.new(goal.X, root.Position.Y, goal.Z))
			task.wait(0.1)
		end
		walkThread = nil
	end)
end

local function practiceSwing()
	local held = ToolController.GetHeld()
	local tool = held and held.Kind == "Tool" and held.Def
	if not tool or not SWING_TYPES[tool.Type] then
		return
	end
	local now = os.clock()
	if now - lastSwing < tool.UseCooldown or now < localBusyUntil then
		return
	end
	lastSwing = now
	local def = AnimationConfig.Get(tool.Animations.Use)
	if def then
		localBusyUntil = now + def.Length / tool.Speed * 0.7
		AnimationController.PlayLocal(tool.Animations.Use, tool.Speed)
		Net.FireServer("SwingRequest")
	end
end

-- Nearest interactable in front of you (touch USE button / keyboard E with no hover).
local function autoTarget(): Instance?
	local root = rootPart()
	if not root then
		return nil
	end
	local best, bestScore = nil, math.huge
	for _, object in CollectionService:GetTagged(TAG) do
		if not object:GetAttribute("InteractDisabled") then
			local position = objectPosition(object)
			local offset = Vector3.new(position.X - root.Position.X, 0, position.Z - root.Position.Z)
			local distance = distanceTo(object, root.Position)
			local range = tonumber(object:GetAttribute("InteractRange")) or 8
			local facing = if offset.Magnitude > 0.1 then root.CFrame.LookVector:Dot(offset.Unit) else 1
			if distance <= range and facing > -0.3 then
				local score = distance - facing * 4
				if score < bestScore then
					best, bestScore = object, score
				end
			end
		end
	end
	return best
end

local function click(target: Target?)
	if pauseCount > 0 or UIController.IsAnyModalOpen() then
		return
	end
	for _, handler in clickHandlers do
		if handler(target) then
			return
		end
	end
	local object = target and target.Object
	if not object then
		practiceSwing()
		return
	end
	local hint = hintFor(object)
	if hint.State == "Hidden" then
		return
	end
	if hint.State == "Blocked" or (hint.State == "Need" and not hint.Anim) then
		AudioController.Play("UIError")
		UIController.Notify("Error", hint.Text)
		return
	end
	local root = rootPart()
	local range = tonumber(object:GetAttribute("InteractRange")) or 8
	if root and distanceTo(object, root.Position) > range then
		walkThenPerform(object, hint)
		return
	end
	cancelWalk()
	perform(object, hint)
end

---------------------------------------------------------------------------
-- Public API
---------------------------------------------------------------------------

-- Pause all interaction (menus, build mode). Returns a resume function.
function InteractionController.PausePrompts(): () -> ()
	pauseCount += 1
	local resumed = false
	return function()
		if resumed then
			return
		end
		resumed = true
		pauseCount = math.max(0, pauseCount - 1)
	end
end

function InteractionController.IsPaused(): boolean
	return pauseCount > 0
end

-- handler(target) returns true if it consumed the click. Checked in order added.
function InteractionController.SetClickHandler(handler: (Target?) -> boolean)
	table.insert(clickHandlers, handler)
end

function InteractionController.GetHover(): Target?
	return hover
end

-- A target at a screen point (touch taps).
function InteractionController.TargetAt(point: Vector2): Target?
	return castTarget(point)
end

function InteractionController.Init()
	highlight = Instance.new("Highlight")
	highlight.Name = "InteractHighlight"
	highlight.FillTransparency = 0.86
	highlight.OutlineTransparency = 0
	highlight.DepthMode = Enum.HighlightDepthMode.Occluded
	highlight.Enabled = false
	highlight.Parent = workspace.CurrentCamera

	local overlay = UIController.GetOverlay()
	tooltip = Create("Frame", {
		Name = "HoverTooltip",
		Size = UDim2.fromOffset(200, 32),
		BackgroundColor3 = Theme.Colors.Glass,
		BackgroundTransparency = 0.18,
		Visible = false,
		ZIndex = 50,
		Parent = overlay,
	})
	Components.Corner(tooltip, UDim.new(0, 10))
	Components.Stroke(tooltip, COLORS.Ok, 2)
	tooltipText = Components.Label({
		Size = UDim2.new(1, -18, 0, 26),
		Position = UDim2.fromOffset(9, 3),
		Font = Theme.Fonts.Heavy,
		TextSize = 17,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextWrapped = false,
		TextColor3 = COLORS.Ok,
		Text = "",
		ZIndex = 51,
		Parent = tooltip,
	})
	tooltipSub = Components.Label({
		Size = UDim2.new(1, -18, 0, 16),
		Position = UDim2.fromOffset(9, 28),
		Font = Theme.Fonts.Bold,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextWrapped = false,
		TextColor3 = Color3.fromRGB(210, 210, 220),
		Text = "",
		ZIndex = 51,
		Parent = tooltip,
	})
	reticle = Create("Frame", {
		Name = "Reticle",
		Size = UDim2.fromOffset(10, 10),
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BackgroundTransparency = 0.2,
		Visible = false,
		ZIndex = 50,
		Parent = overlay,
	})
	Components.Corner(reticle, UDim.new(1, 0))
	Components.Stroke(reticle, Theme.Colors.Outline, 2)
end

function InteractionController.Start()
	RunService.RenderStepped:Connect(updateHover)

	InputController.On("UseTool", function()
		if InputController.IsTouch() then
			-- Touch USE button: act on what's in front of you.
			local object = autoTarget()
			click(if object then { Object = object, Position = objectPosition(object), Water = false } else nil)
		else
			click(hover or castTarget(nil))
		end
	end)
	InputController.On("Interact", function()
		local target = hover
		if not (target and target.Object) then
			local object = autoTarget()
			target = if object then { Object = object, Position = objectPosition(object), Water = false } else nil
		end
		if target and target.Object then
			click(target)
		end
	end)
	UserInputService.TouchTapInWorld:Connect(function(position, processedByUI)
		if processedByUI or pauseCount > 0 or UIController.IsAnyModalOpen() then
			return
		end
		local target = castTarget(position)
		if target and target.Object then
			local hint = hintFor(target.Object)
			setHighlight(target.Object, COLORS[hint.State] or COLORS.Neutral)
			task.delay(0.6, function()
				if highlight.Adornee == target.Object then
					setHighlight(nil, COLORS.Ok)
				end
			end)
		end
		click(target)
	end)
	-- Moving yourself cancels an auto-walk.
	UserInputService.InputBegan:Connect(function(input, processed)
		if not processed and (input.KeyCode == Enum.KeyCode.W or input.KeyCode == Enum.KeyCode.A or input.KeyCode == Enum.KeyCode.S or input.KeyCode == Enum.KeyCode.D) then
			cancelWalk()
		end
	end)
end

return InteractionController
