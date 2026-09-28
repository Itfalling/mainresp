--[[
	SCRIPT NAME:  ToolController
	SCRIPT TYPE:  ModuleScript (client controller)
	WHERE:        StarterPlayerScripts/Client/Controllers/ToolController
	DEPENDENCIES: Shared.Net, Shared.Config.{ToolConfig, ItemConfig}, Client.ClientState, InputController,
	              AnimationController, UIController, Client.UI.{Hotbar, Components, Theme}

	What's in your hands, client side:
	  * renders the hotbar (tools + holdable items with counts) from
	    replicated Tools / Inventory state,
	  * number keys 1-9 / taps / gamepad bumpers REQUEST equips (the server
	    decides, attaches the model and sets the hold pose everyone sees),
	    0 / ` empties your hands,
	  * GetHeld() tells InteractionController what you hold (from the
	    character's Held / HeldKind attributes the server sets),
	  * shows a big USE button on touch devices while something is held.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Net = require(Shared:WaitForChild("Net"))
local ToolConfig = require(Shared.Config.ToolConfig)
local ItemConfig = require(Shared.Config.ItemConfig)
local Signal = require(Shared.Util.Signal)

local Client = script.Parent.Parent
local ClientState = require(Client.ClientState)
local InputController = require(script.Parent.InputController)
local AnimationController = require(script.Parent.AnimationController)
local UIController = require(script.Parent.UIController)
local Hotbar = require(Client.UI.Hotbar)
local Components = require(Client.UI.Components)
local Theme = require(Client.UI.Theme)

local EQUIP_DEBOUNCE = 0.12

local ToolController = {}

export type Held = { Kind: string, Id: string, Def: any }

ToolController.EquippedChanged = Signal.new() -- (held: Held?)

local hotbar: any
local useButton: TextButton
local heldId: string? = nil
local lastEquipRequest = 0
local characterConnection: RBXScriptConnection? = nil

function ToolController.GetHeld(): Held?
	if not heldId then
		return nil
	end
	local tool = ToolConfig.Get(heldId)
	if tool then
		return { Kind = "Tool", Id = heldId, Def = tool }
	end
	local item = ItemConfig.Get(heldId)
	if item then
		return { Kind = "Item", Id = heldId, Def = item }
	end
	return nil
end

-- The held TOOL definition (nil for items / empty hands).
function ToolController.GetEquipped(): any
	return heldId and ToolConfig.Get(heldId)
end

function ToolController.RequestEquip(id: string?)
	local now = os.clock()
	if now - lastEquipRequest < EQUIP_DEBOUNCE then
		return
	end
	lastEquipRequest = now
	Net.FireServer("EquipToolRequest", id or "")
end

local function selectSlot(index: number)
	local id = hotbar:GetToolAt(index)
	if not id then
		return
	end
	ToolController.RequestEquip(if id == heldId then nil else id)
end

local function cycle(direction: number)
	local ids = ClientState.Get("Tools", "Hotbar") or {}
	if #ids == 0 then
		return
	end
	local currentIndex = if heldId then table.find(ids, heldId) else nil
	local nextIndex = if currentIndex then (currentIndex - 1 + direction) % #ids + 1 else 1
	ToolController.RequestEquip(ids[nextIndex])
end

local function onHeldChanged(id: string?)
	if id == "" then
		id = nil
	end
	heldId = id
	hotbar:SetEquipped(id)
	local held = ToolController.GetHeld()
	useButton.Visible = held ~= nil and InputController.IsTouch()
	if held then
		useButton.Text = held.Def.Icon .. "\nUSE"
	end
	ToolController.EquippedChanged:Fire(held)
end

local function watchCharacter(character: Model)
	if characterConnection then
		characterConnection:Disconnect()
	end
	characterConnection = character:GetAttributeChangedSignal("Held"):Connect(function()
		onHeldChanged(character:GetAttribute("Held") :: string?)
	end)
	onHeldChanged(character:GetAttribute("Held") :: string?)
end

local function refreshHotbar()
	local tools = ClientState.Get("Tools")
	local items = ClientState.Get("Inventory", "Items") or {}
	if type(tools) == "table" then
		hotbar:SetTools(tools.Hotbar or {}, items)
		hotbar:SetEquipped(heldId)
	end
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
	local bevel = useButton:FindFirstChild("Bevel")
	if bevel then
		bevel:Destroy()
	end
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
	ClientState.Observe("Tools", refreshHotbar)
	ClientState.Observe("Inventory", function(inventory)
		if type(inventory) == "table" then
			hotbar:SetCounts(inventory.Items or {})
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
	InputController.On("Unequip", function()
		ToolController.RequestEquip(nil)
	end)
	InputController.DeviceChanged:Connect(function()
		useButton.Visible = heldId ~= nil and InputController.IsTouch()
	end)

	AnimationController.CharacterReady:Connect(watchCharacter)
	local character = Players.LocalPlayer.Character
	if character then
		watchCharacter(character)
	end
end

return ToolController
