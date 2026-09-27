--[[
	SCRIPT NAME:  Hotbar
	SCRIPT TYPE:  ModuleScript (client UI)
	WHERE:        StarterPlayerScripts/Client/UI/Hotbar
	DEPENDENCIES: Client.UI.{Theme, Components}, Shared.Config.{ToolConfig, RarityConfig}

	The bottom tool hotbar. Slots are created ONCE and updated in place.
	Big (72px design size) touch-friendly buttons with a key-number badge.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local ToolConfig = require(Shared.Config.ToolConfig)

local Theme = require(script.Parent.Theme)
local Components = require(script.Parent.Components)

local Create = Components.Create

local SLOT_SIZE = 72

local TIER_COLORS = {
	Wooden = Color3.fromRGB(190, 140, 90),
	Stone = Color3.fromRGB(160, 160, 165),
	Iron = Color3.fromRGB(215, 220, 230),
	Gold = Color3.fromRGB(255, 205, 60),
	Crystal = Color3.fromRGB(120, 225, 255),
	Mythic = Color3.fromRGB(200, 100, 255),
}

type Slot = { Button: TextButton, Icon: TextLabel, Name: TextLabel, Stroke: UIStroke, Strip: Frame, ToolId: string? }

local Hotbar = {}
Hotbar.__index = Hotbar

function Hotbar.new(parent: Instance, onSelect: (index: number) -> ())
	local self = setmetatable({}, Hotbar)
	self.Frame = Create("Frame", {
		Name = "Hotbar",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Parent = parent,
	}, {
		Create("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Bottom,
			Padding = UDim.new(0, 10),
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
	})
	self.Slots = {} :: { Slot }

	for index = 1, ToolConfig.HotbarSize do
		local button = Create("TextButton", {
			Name = "Slot" .. index,
			Size = UDim2.fromOffset(SLOT_SIZE, SLOT_SIZE),
			BackgroundColor3 = Theme.Colors.Panel,
			AutoButtonColor = false,
			Text = "",
			LayoutOrder = index,
			Parent = self.Frame,
		})
		Components.Corner(button, Theme.SmallCorner)
		local stroke = Components.Stroke(button)
		local strip = Create("Frame", {
			Name = "TierStrip",
			Size = UDim2.new(1, -12, 0, 5),
			Position = UDim2.new(0.5, 0, 1, -8),
			AnchorPoint = Vector2.new(0.5, 0),
			BackgroundColor3 = Theme.Colors.PanelDark,
			BorderSizePixel = 0,
			Parent = button,
		})
		Components.Corner(strip, UDim.new(1, 0))
		local icon = Components.Label({
			Name = "Icon",
			Size = UDim2.new(1, 0, 0, 44),
			Position = UDim2.fromOffset(0, 4),
			TextSize = 34,
			Text = "",
			Parent = button,
		})
		local name = Components.Label({
			Name = "ToolName",
			Size = UDim2.new(1, -6, 0, 14),
			Position = UDim2.new(0, 3, 1, -24),
			TextSize = 12,
			Font = Theme.Fonts.Bold,
			TextColor3 = Theme.Colors.TextMuted,
			TextScaled = true,
			Text = "",
			Parent = button,
		})
		local badge = Components.Label({
			Name = "Key",
			Size = UDim2.fromOffset(20, 20),
			Position = UDim2.fromOffset(4, 2),
			TextSize = 14,
			Text = tostring(index),
			TextColor3 = Theme.Colors.TextMuted,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = button,
		})
		badge.ZIndex = 2
		button.Activated:Connect(function()
			onSelect(index)
		end)
		table.insert(self.Slots, { Button = button, Icon = icon, Name = name, Stroke = stroke, Strip = strip, ToolId = nil })
	end
	return self
end

function Hotbar:SetTools(toolIds: { string })
	for index, slot in self.Slots do
		local toolId = toolIds[index]
		local def = toolId and ToolConfig.Get(toolId)
		slot.ToolId = if def then toolId else nil
		slot.Icon.Text = if def then def.Icon else ""
		slot.Name.Text = if def then def.DisplayName else ""
		slot.Strip.BackgroundColor3 = if def then (TIER_COLORS[def.Tier] or Theme.Colors.PanelDark) else Theme.Colors.PanelDark
		slot.Button.BackgroundTransparency = if def then 0 else 0.35
	end
end

function Hotbar:SetEquipped(toolId: string?)
	for _, slot in self.Slots do
		local equipped = toolId ~= nil and slot.ToolId == toolId
		slot.Stroke.Color = if equipped then Theme.Colors.Coins else Theme.Colors.Outline
		slot.Stroke.Thickness = if equipped then 5 else Theme.StrokeThickness
		slot.Button.BackgroundColor3 = if equipped then Color3.fromRGB(255, 240, 190) else Theme.Colors.Panel
		if equipped then
			Components.Bounce(slot.Button, 0.1)
		end
	end
end

function Hotbar:GetToolAt(index: number): string?
	local slot = self.Slots[index]
	return slot and slot.ToolId
end

return Hotbar
