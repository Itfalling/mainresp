--[[
	SCRIPT NAME:  Hotbar
	SCRIPT TYPE:  ModuleScript (client UI)
	WHERE:        StarterPlayerScripts/Client/UI/Hotbar
	DEPENDENCIES: Client.UI.{Theme, Components}, Shared.Config.{ToolConfig, ItemConfig}, Shared.Util.Format

	The bottom hotbar: tools AND holdable items (seed sacks, crops to feed
	animals). Slots are created ONCE and updated in place. Big touch-friendly
	glossy buttons with a round key badge, a tier strip for tools and a count
	for items, each on a soft drop shadow. The slot in your hands LIFTS up,
	grows, glows gold and wiggles.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local ToolConfig = require(Shared.Config.ToolConfig)
local ItemConfig = require(Shared.Config.ItemConfig)
local Format = require(Shared.Util.Format)

local Theme = require(script.Parent.Theme)
local Components = require(script.Parent.Components)

local Create = Components.Create

local SLOT_SIZE = 68

local TIER_COLORS = {
	Wooden = Color3.fromRGB(196, 146, 94),
	Stone = Color3.fromRGB(160, 160, 168),
	Iron = Color3.fromRGB(218, 224, 234),
	Gold = Color3.fromRGB(255, 205, 60),
	Crystal = Color3.fromRGB(120, 225, 255),
	Mythic = Color3.fromRGB(200, 100, 255),
}

type Slot = { Button: TextButton, Glow: Frame, Icon: TextLabel, Name: TextLabel, Count: TextLabel, Stroke: UIStroke, Strip: Frame, Id: string?, Equipped: boolean }

local LIFT = 12
local REST_POSITION = UDim2.new(0.5, 0, 1, -6)
local LIFT_POSITION = UDim2.new(0.5, 0, 1, -6 - LIFT)

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
			Padding = UDim.new(0, 8),
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
	})
	self.Slots = {} :: { Slot }
	self.Counts = {} :: { [string]: number }

	for index = 1, ToolConfig.HotbarSize do
		-- Container keeps the list layout still while the button lifts.
		local holder = Create("Frame", {
			Name = "Slot" .. index,
			Size = UDim2.fromOffset(SLOT_SIZE + 4, SLOT_SIZE + LIFT + 12),
			BackgroundTransparency = 1,
			LayoutOrder = index,
			Parent = self.Frame,
		})
		local shadow = Create("Frame", {
			Name = "Shadow",
			Size = UDim2.fromOffset(SLOT_SIZE - 4, 12),
			Position = UDim2.new(0.5, 0, 1, -2),
			AnchorPoint = Vector2.new(0.5, 1),
			BackgroundColor3 = Color3.new(0, 0, 0),
			BackgroundTransparency = 0.72,
			Parent = holder,
		})
		Components.Corner(shadow, UDim.new(1, 0))
		local glow = Create("Frame", {
			Name = "Glow",
			Size = UDim2.fromOffset(SLOT_SIZE + 16, SLOT_SIZE + 16),
			Position = LIFT_POSITION + UDim2.fromOffset(0, 8),
			AnchorPoint = Vector2.new(0.5, 1),
			BackgroundColor3 = Theme.Colors.Coins,
			BackgroundTransparency = 1,
			Parent = holder,
		})
		Components.Corner(glow, UDim.new(0, 20))
		local button = Create("TextButton", {
			Name = "Button",
			Size = UDim2.fromOffset(SLOT_SIZE, SLOT_SIZE),
			Position = REST_POSITION,
			AnchorPoint = Vector2.new(0.5, 1),
			BackgroundColor3 = Theme.Colors.Panel,
			BackgroundTransparency = 0.05,
			AutoButtonColor = false,
			Text = "",
			Parent = holder,
		})
		Components.Corner(button, UDim.new(0, 16))
		local stroke = Components.Stroke(button)
		Components.Gloss(button, 0.55)
		local strip = Create("Frame", {
			Name = "TierStrip",
			Size = UDim2.new(1, -14, 0, 5),
			Position = UDim2.new(0.5, 0, 1, -8),
			AnchorPoint = Vector2.new(0.5, 0),
			BackgroundColor3 = Theme.Colors.PanelDark,
			BorderSizePixel = 0,
			Parent = button,
		})
		Components.Corner(strip, UDim.new(1, 0))
		local icon = Components.Label({
			Name = "Icon",
			Size = UDim2.new(1, 0, 0, 40),
			Position = UDim2.fromOffset(0, 5),
			TextSize = 32,
			Text = "",
			Parent = button,
		})
		local name = Components.Label({
			Name = "ItemName",
			Size = UDim2.new(1, -6, 0, 13),
			Position = UDim2.new(0, 3, 1, -23),
			Font = Theme.Fonts.Bold,
			TextColor3 = Theme.Colors.TextMuted,
			TextScaled = true,
			Text = "",
			Parent = button,
		})
		local count = Components.Label({
			Name = "Count",
			Size = UDim2.fromOffset(40, 18),
			Position = UDim2.new(1, -4, 0, 2),
			AnchorPoint = Vector2.new(1, 0),
			Font = Theme.Fonts.Heavy,
			TextSize = 15,
			TextColor3 = Theme.Colors.TextLight,
			TextXAlignment = Enum.TextXAlignment.Right,
			Text = "",
			ZIndex = 2,
			Parent = button,
		})
		Components.TextStroke(count, Theme.Colors.Outline, 2)
		local badge = Create("Frame", {
			Name = "KeyBadge",
			Size = UDim2.fromOffset(22, 22),
			Position = UDim2.fromOffset(-6, -6),
			BackgroundColor3 = Theme.Colors.Outline,
			ZIndex = 3,
			Parent = button,
		})
		Components.Corner(badge, UDim.new(1, 0))
		Components.Label({
			Name = "Key",
			Size = UDim2.fromScale(1, 1),
			Font = Theme.Fonts.Heavy,
			TextSize = 13,
			Text = tostring(index),
			TextColor3 = Theme.Colors.TextLight,
			ZIndex = 4,
			Parent = badge,
		})
		button.MouseEnter:Connect(function()
			Components.SpringScale(button, 1.08)
		end)
		button.MouseLeave:Connect(function()
			Components.SpringScale(button, 1)
		end)
		button.Activated:Connect(function()
			onSelect(index)
		end)
		table.insert(self.Slots, { Button = button, Glow = glow, Icon = icon, Name = name, Count = count, Stroke = stroke, Strip = strip, Id = nil, Equipped = false })
	end
	return self
end

local function describe(id: string?): (string, string, Color3?)
	if not id then
		return "", "", nil
	end
	local tool = ToolConfig.Get(id)
	if tool then
		return tool.Icon, tool.DisplayName, TIER_COLORS[tool.Tier]
	end
	local item = ItemConfig.Get(id)
	if item then
		return item.Icon, item.DisplayName, Theme.Colors.Green
	end
	return "", "", nil
end

function Hotbar:SetTools(ids: { string }, counts: { [string]: number }?)
	self.Counts = counts or self.Counts
	for index, slot in self.Slots do
		local id = ids[index]
		local icon, name, strip = describe(id)
		slot.Id = if icon ~= "" then id else nil
		slot.Icon.Text = icon
		slot.Name.Text = name
		slot.Strip.BackgroundColor3 = strip or Theme.Colors.PanelDark
		slot.Strip.Visible = strip ~= nil
		slot.Button.BackgroundTransparency = if slot.Id then 0.05 else 0.45
		local count = slot.Id and not ToolConfig.Get(slot.Id) and self.Counts[slot.Id]
		slot.Count.Text = if count then "x" .. Format.Abbreviate(count) else ""
	end
end

function Hotbar:SetCounts(counts: { [string]: number })
	self.Counts = counts
	for _, slot in self.Slots do
		local count = slot.Id and not ToolConfig.Get(slot.Id) and counts[slot.Id]
		slot.Count.Text = if count then "x" .. Format.Abbreviate(count) else ""
	end
end

function Hotbar:SetEquipped(id: string?)
	for _, slot in self.Slots do
		local equipped = id ~= nil and slot.Id == id
		slot.Stroke.Color = if equipped then Color3.fromRGB(255, 170, 30) else Theme.Colors.Outline
		slot.Stroke.Thickness = if equipped then 4 else Theme.StrokeThickness
		slot.Button.BackgroundColor3 = if equipped then Color3.fromRGB(255, 244, 200) else Theme.Colors.Panel
		if equipped ~= slot.Equipped then
			slot.Equipped = equipped
			local info = TweenInfo.new(0.32, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
			TweenService:Create(slot.Button, info, {
				Position = if equipped then LIFT_POSITION else REST_POSITION,
				Size = if equipped then UDim2.fromOffset(SLOT_SIZE + 6, SLOT_SIZE + 6) else UDim2.fromOffset(SLOT_SIZE, SLOT_SIZE),
			}):Play()
			TweenService:Create(slot.Glow, TweenInfo.new(0.25), { BackgroundTransparency = if equipped then 0.55 else 1 }):Play()
			if equipped then
				-- A happy little wiggle.
				slot.Button.Rotation = -10
				TweenService:Create(slot.Button, TweenInfo.new(0.6, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), { Rotation = 0 }):Play()
			end
		end
	end
end

function Hotbar:GetToolAt(index: number): string?
	local slot = self.Slots[index]
	return slot and slot.Id
end

return Hotbar
