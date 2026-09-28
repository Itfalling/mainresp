--[[
	SCRIPT NAME:  ToolController
	SCRIPT TYPE:  ModuleScript (client controller)
	WHERE:        StarterPlayerScripts/Client/Controllers/ToolController
	DEPENDENCIES: Shared.Net, Shared.Config.ToolConfig, Client.ClientState, InputController,
	              AnimationController, UIController, Client.UI.{Hotbar, Components, Theme}

	Client side of the tool framework:
	  * renders the hotbar from replicated Tools state,
	  * number keys / taps / gamepad bumpers REQUEST equips (server decides),
	  * reacts to the character's EquippedTool attribute (set by the server)
	    by playing the tool's hold animation,
	  * UseTool plays the tool's Use animation; the FIRST gameplay marker of
	    that animation fires ToolController.ToolImpact — Phase 2's gathering
	    hooks in there (spec §173: interaction + animation + marker together),
	  * shows a big USE button on touch devices while a tool is equipped.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Net = require(Shared:WaitForChild("Net"))
local ToolConfig = require(Shared.Config.ToolConfig)
local AnimationConfig = require(Shared.Config.AnimationConfig)
local Signal = require(Shared.Util.Signal)

local Client = script.Parent.Parent
local ClientState = require(Client.ClientState)
local InputController = require(script.Parent.InputController)
local AnimationController = require(script.Parent.AnimationController)
local UIController = require(script.Parent.UIController)
local Hotbar = require(Client.UI.Hotbar)
local Components = require(Client.UI.Components)
local Theme = require(Client.UI.Theme)

local EQUIP_DEBOUNCE = 0.15

local ToolController = {}

ToolController.EquippedChanged = Signal.new() -- (toolDef | nil)
ToolController.ToolImpact = Signal.new() -- (toolDef, markerName) the moment a swing connects

local hotbar: any
local useButton: TextButton
local equippedId: string? = nil
local holdAnimation: string? = nil
local lastEquipRequest = 0
local nextUseTime = 0
local characterConnection: RBXScriptConnection? = nil
-- toolType -> handler(def) returning true if it handled USE (e.g. fishing rod casts instead of swinging)
local useOverrides: { [string]: (any) -> boolean } = {}

-- Lets a higher-level controller take over USE for one tool type.
function ToolController.SetUseOverride(toolType: string, handler: (any) -> boolean)
	useOverrides[toolType] = handler
end

function ToolController.GetEquipped(): any
	return equippedId and ToolConfig.Get(equippedId)
end

function ToolController.RequestEquip(toolId: string?)
	local now = os.clock()
	if now - lastEquipRequest < EQUIP_DEBOUNCE then
		return
	end
	lastEquipRequest = now
	Net.FireServer("EquipToolRequest", toolId or "")
end

local function selectSlot(index: number)
	local toolId = hotbar:GetToolAt(index)
	if not toolId then
		return
	end
	ToolController.RequestEquip(if toolId == equippedId then nil else toolId)
end

local function cycle(direction: number)
	local hotbarIds = ClientState.Get("Tools", "Hotbar") or {}
	if #hotbarIds == 0 then
		return
	end
	local currentIndex = if equippedId then table.find(hotbarIds, equippedId) else nil
	local nextIndex = if currentIndex then (currentIndex - 1 + direction) % #hotbarIds + 1 else 1
	ToolController.RequestEquip(hotbarIds[nextIndex])
end

local function onEquippedChanged(toolId: string?)
	if toolId == "" then
		toolId = nil
	end
	equippedId = toolId
	if holdAnimation then
		AnimationController.StopAnimation(holdAnimation, 0.2)
		holdAnimation = nil
	end
	local def = toolId and ToolConfig.Get(toolId)
	if def and def.Animations.Idle then
		holdAnimation = def.Animations.Idle
		AnimationController.PlayAnimation(def.Animations.Idle)
	end
	hotbar:SetEquipped(toolId)
	useButton.Visible = def ~= nil and InputController.IsTouch()
	if def then
		useButton.Text = def.Icon .. "\nUSE"
	end
	ToolController.EquippedChanged:Fire(def)
end

local function useTool()
	if UIController.IsAnyModalOpen() then
		return
	end
	local def = ToolController.GetEquipped()
	if not def then
		return
	end
	local override = useOverrides[def.Type]
	if override and override(def) then
		return
	end
	local now = os.clock()
	if now < nextUseTime then
		return
	end
	nextUseTime = now + def.UseCooldown

	local animationName = def.Animations.Use
	local animationDef = animationName and AnimationConfig.Get(animationName)
	if not animationDef then
		return
	end
	local handle = AnimationController.PlayAnimation(animationName, { Speed = def.Speed })
	if not handle then
		return
	end
	-- The first configured marker is the gameplay moment (Hit / Dig / Till / HammerHit...).
	local impactFired = false
	for markerName in animationDef.Markers do
		handle:OnMarker(markerName, function()
			if not impactFired then
				impactFired = true
				ToolController.ToolImpact:Fire(def, markerName)
			end
		end)
	end
end

local function watchCharacter(character: Model)
	if characterConnection then
		characterConnection:Disconnect()
	end
	characterConnection = character:GetAttributeChangedSignal("EquippedTool"):Connect(function()
		onEquippedChanged(character:GetAttribute("EquippedTool") :: string?)
	end)
	-- Wait for the AnimationPlayer so the hold pose can play.
	task.defer(function()
		onEquippedChanged(character:GetAttribute("EquippedTool") :: string?)
	end)
end

function ToolController.Init()
	hotbar = Hotbar.new(UIController.GetSlot("Bottom"), selectSlot)
	useButton = Components.Button({
		Name = "UseButton",
		Text = "USE",
		Color = Theme.Colors.Orange,
		Size = UDim2.fromOffset(110, 110),
		TextSize = Theme.TextSize.Large,
		Parent = UIController.GetSlot("Touch"),
		OnClick = function()
			InputController.Trigger("UseTool")
		end,
	})
	Components.Corner(useButton, UDim.new(1, 0))
	useButton.Visible = false
	-- Hold support (the fishing reel is "hold to pull").
	useButton.MouseButton1Down:Connect(function()
		InputController.SetHeld("UseTool", true)
	end)
	useButton.MouseButton1Up:Connect(function()
		if InputController.IsHeld("UseTool") then
			InputController.SetHeld("UseTool", false)
		end
	end)
	useButton.MouseLeave:Connect(function()
		if InputController.IsHeld("UseTool") then
			InputController.SetHeld("UseTool", false)
		end
	end)
end

function ToolController.Start()
	ClientState.Observe("Tools", function(tools)
		if type(tools) == "table" then
			hotbar:SetTools(tools.Hotbar or {})
			hotbar:SetEquipped(equippedId)
		end
	end)

	for index = 1, ToolConfig.HotbarSize do
		InputController.On("Hotbar" .. index, function()
			selectSlot(index)
		end)
	end
	InputController.On("HotbarNext", function()
		cycle(1)
	end)
	InputController.On("HotbarPrevious", function()
		cycle(-1)
	end)
	InputController.On("UseTool", useTool)
	InputController.DeviceChanged:Connect(function()
		useButton.Visible = equippedId ~= nil and InputController.IsTouch()
	end)

	AnimationController.CharacterReady:Connect(watchCharacter)
	local character = Players.LocalPlayer.Character
	if character then
		watchCharacter(character)
	end
end

return ToolController
