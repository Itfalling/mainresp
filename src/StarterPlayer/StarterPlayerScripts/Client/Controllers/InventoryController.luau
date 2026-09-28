--[[
	SCRIPT NAME:  InventoryController
	SCRIPT TYPE:  ModuleScript (client controller)
	WHERE:        StarterPlayerScripts/Client/Controllers/InventoryController
	DEPENDENCIES: Client.ClientState, InputController, UIController, ToolController,
	              InteractionController, Client.UI.{InventoryPanel, Components, Theme}

	Opens/closes the backpack (I / G / gamepad Y / 🎒 button) and keeps it in
	sync with replicated Inventory + Tools state. While open, tool use and
	world prompts are paused so clicks don't leak into the world.
]]

local Client = script.Parent.Parent
local ClientState = require(Client.ClientState)
local InputController = require(script.Parent.InputController)
local UIController = require(script.Parent.UIController)
local ToolController = require(script.Parent.ToolController)
local InteractionController = require(script.Parent.InteractionController)
local InventoryPanel = require(Client.UI.InventoryPanel)
local Components = require(Client.UI.Components)
local Theme = require(Client.UI.Theme)

local InventoryController = {}

local panel: any
local releaseBlocks: { () -> () } = {}

local function buildState()
	local inventory = ClientState.Get("Inventory") or {}
	local tools = ClientState.Get("Tools") or {}
	local items = inventory.Items or {}
	local used = 0
	for _, count in items do
		used += count
	end
	return {
		Items = items,
		Capacity = inventory.Capacity or 0,
		Used = used,
		OwnedTools = tools.Owned or {},
		Equipped = tools.Equipped or "",
	}
end

function InventoryController.IsOpen(): boolean
	return panel ~= nil and panel:IsOpen()
end

function InventoryController.Open()
	if InventoryController.IsOpen() then
		return
	end
	panel:SetState(buildState())
	panel:Open()
	UIController.SetModalOpen("Inventory", true)
	table.insert(releaseBlocks, InputController.Block("UseTool"))
	table.insert(releaseBlocks, InteractionController.PausePrompts())
end

function InventoryController.Close()
	if not InventoryController.IsOpen() then
		return
	end
	panel:Close()
	UIController.SetModalOpen("Inventory", false)
	for _, release in releaseBlocks do
		release()
	end
	table.clear(releaseBlocks)
end

function InventoryController.Toggle()
	if InventoryController.IsOpen() then
		InventoryController.Close()
	else
		InventoryController.Open()
	end
end

function InventoryController.Init()
	panel = InventoryPanel.new(UIController.GetModalLayer(), {
		OnClose = InventoryController.Close,
		OnEquip = function(toolId: string?)
			ToolController.RequestEquip(toolId)
		end,
	})

	Components.IconButton({
		Icon = "🎒",
		Caption = "Bag",
		Color = Theme.Colors.Blue,
		Parent = UIController.GetSlot("Left"),
		LayoutOrder = 1,
		OnClick = InventoryController.Toggle,
	})
end

function InventoryController.Start()
	InputController.On("ToggleInventory", InventoryController.Toggle)
	InputController.On("Cancel", InventoryController.Close)
	local function refresh()
		panel:SetState(buildState())
	end
	ClientState.Observe("Inventory", refresh)
	ClientState.Observe("Tools", refresh)
end

return InventoryController
