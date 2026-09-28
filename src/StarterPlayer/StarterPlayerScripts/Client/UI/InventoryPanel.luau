--[[
	SCRIPT NAME:  InventoryPanel
	SCRIPT TYPE:  ModuleScript (client UI)
	WHERE:        StarterPlayerScripts/Client/UI/InventoryPanel
	DEPENDENCIES: Client.UI.{Theme, Components}, Shared.Config.{ItemConfig, ToolConfig, RarityConfig},
	              Shared.Util.Format

	The backpack window (spec §66/§67): category tabs, search, sort, a pooled
	item grid and a details pane (rarity, value, description; Equip for tools).
	Cards are pooled and reused — the grid never rebuilds from scratch.
	Sell buttons arrive with the market in Phase 7.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local ItemConfig = require(Shared.Config.ItemConfig)
local ToolConfig = require(Shared.Config.ToolConfig)
local RarityConfig = require(Shared.Config.RarityConfig)
local Format = require(Shared.Util.Format)

local Theme = require(script.Parent.Theme)
local Components = require(script.Parent.Components)

local Create = Components.Create

local SORT_MODES = { "Name", "Amount", "Value" }

type Entry = {
	Id: string,
	Kind: string, -- "Item" | "Tool"
	Name: string,
	Icon: string,
	Rarity: string,
	Category: string,
	Count: number,
	Value: number,
	Description: string,
	ToolDef: any?,
}

type Card = { Button: TextButton, Icon: TextLabel, Name: TextLabel, Count: TextLabel, Stroke: UIStroke }

local InventoryPanel = {}
InventoryPanel.__index = InventoryPanel

export type Callbacks = {
	OnClose: () -> (),
	OnEquip: (toolId: string?) -> (),
}

function InventoryPanel.new(parent: Instance, callbacks: Callbacks)
	local self = setmetatable({}, InventoryPanel)
	self.Callbacks = callbacks
	self.Category = "All"
	self.SortIndex = 1
	self.Search = ""
	self.SelectedId = nil :: string?
	self.Entries = {} :: { Entry }
	self.Cards = {} :: { Card }
	self.State = { Items = {}, Capacity = 0, OwnedTools = {}, Equipped = "" }

	local panel, content = Components.Panel({
		Title = "🎒 BACKPACK",
		Size = UDim2.fromOffset(760, 470),
		Parent = parent,
		OnClose = callbacks.OnClose,
	})
	panel.Visible = false
	self.Panel = panel

	self.CapacityLabel = Components.Label({
		Size = UDim2.fromOffset(160, 54),
		Position = UDim2.new(1, -70, 0, 0),
		AnchorPoint = Vector2.new(1, 0),
		TextSize = Theme.TextSize.Medium,
		TextColor3 = Theme.Colors.TextLight,
		TextXAlignment = Enum.TextXAlignment.Right,
		Text = "0 / 0",
		Parent = panel:FindFirstChild("Header"),
	})
	Components.TextStroke(self.CapacityLabel)

	-- Tabs (left column)
	local tabs = Create("ScrollingFrame", {
		Name = "Tabs",
		Size = UDim2.new(0, 130, 1, 0),
		BackgroundTransparency = 1,
		ScrollBarThickness = 4,
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		BorderSizePixel = 0,
		Parent = content,
	}, {
		Create("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }),
	})
	self.TabButtons = {}
	for index, category in ItemConfig.Categories do
		local button = Components.Button({
			Name = category.Id,
			Text = category.Icon .. " " .. category.DisplayName,
			Color = Theme.Colors.PanelAlt,
			TextColor = Theme.Colors.Text,
			Size = UDim2.new(1, -8, 0, 40),
			TextSize = Theme.TextSize.Small,
			Parent = tabs,
			OnClick = function()
				self.Category = category.Id
				self:Render()
			end,
		})
		button.LayoutOrder = index
		-- Dark text on light tabs doesn't need the white-text outline.
		for _, child in button:GetChildren() do
			if child:IsA("UIStroke") and child.ApplyStrokeMode == Enum.ApplyStrokeMode.Contextual then
				child:Destroy()
			end
		end
		self.TabButtons[category.Id] = button
	end

	-- Search + sort row
	local middle = Create("Frame", {
		Name = "Middle",
		Size = UDim2.new(1, -350, 1, 0),
		Position = UDim2.fromOffset(140, 0),
		BackgroundTransparency = 1,
		Parent = content,
	})
	local searchBox = Create("TextBox", {
		Name = "Search",
		Size = UDim2.new(1, -120, 0, 38),
		BackgroundColor3 = Color3.new(1, 1, 1),
		PlaceholderText = "🔍 Search...",
		PlaceholderColor3 = Theme.Colors.TextMuted,
		Text = "",
		ClearTextOnFocus = false,
		Font = Theme.Fonts.Body,
		TextSize = Theme.TextSize.Medium,
		TextColor3 = Theme.Colors.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = middle,
	})
	Components.Corner(searchBox, Theme.SmallCorner)
	Components.Stroke(searchBox, Theme.Colors.Outline, 2)
	Components.Padding(searchBox, 8)
	searchBox:GetPropertyChangedSignal("Text"):Connect(function()
		self.Search = string.lower(searchBox.Text)
		self:Render()
	end)

	self.SortButton = Components.Button({
		Name = "Sort",
		Text = "Sort: Name",
		Color = Theme.Colors.Blue,
		Size = UDim2.fromOffset(110, 38),
		Position = UDim2.new(1, 0, 0, 0),
		AnchorPoint = Vector2.new(1, 0),
		TextSize = Theme.TextSize.Small,
		Parent = middle,
		OnClick = function()
			self.SortIndex = self.SortIndex % #SORT_MODES + 1
			self.SortButton.Text = "Sort: " .. SORT_MODES[self.SortIndex]
			self:Render()
		end,
	})

	self.Grid = Create("ScrollingFrame", {
		Name = "Grid",
		Size = UDim2.new(1, 0, 1, -48),
		Position = UDim2.fromOffset(0, 48),
		BackgroundColor3 = Theme.Colors.PanelAlt,
		ScrollBarThickness = 6,
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		BorderSizePixel = 0,
		Parent = middle,
	}, {
		Create("UIGridLayout", {
			CellSize = UDim2.fromOffset(84, 96),
			CellPadding = UDim2.fromOffset(8, 8),
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
	})
	Components.Corner(self.Grid, Theme.SmallCorner)
	Components.Padding(self.Grid, 8)

	self.EmptyLabel = Components.Label({
		Size = UDim2.new(1, -20, 0, 80),
		Position = UDim2.new(0.5, 0, 0.45, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		TextColor3 = Theme.Colors.TextMuted,
		Text = "Nothing here yet!\nGather resources to fill your backpack.",
		Visible = false,
		Parent = middle,
	})

	-- Details (right column)
	local details = Create("Frame", {
		Name = "Details",
		Size = UDim2.new(0, 200, 1, 0),
		Position = UDim2.new(1, 0, 0, 0),
		AnchorPoint = Vector2.new(1, 0),
		BackgroundColor3 = Theme.Colors.PanelAlt,
		Parent = content,
	})
	Components.Corner(details, Theme.SmallCorner)
	Components.Padding(details, 10)
	self.DetailIcon = Components.Label({ Size = UDim2.new(1, 0, 0, 70), TextSize = 58, Text = "", Parent = details })
	self.DetailName = Components.Label({ Size = UDim2.new(1, 0, 0, 30), Position = UDim2.fromOffset(0, 72), TextSize = Theme.TextSize.Large, Text = "Select an item", Parent = details })
	self.DetailRarity = Components.Label({ Size = UDim2.new(1, 0, 0, 20), Position = UDim2.fromOffset(0, 102), TextSize = Theme.TextSize.Small, Text = "", Parent = details })
	self.DetailStats = Components.Label({
		Size = UDim2.new(1, 0, 0, 60),
		Position = UDim2.fromOffset(0, 126),
		Font = Theme.Fonts.Bold,
		TextSize = Theme.TextSize.Small,
		TextColor3 = Theme.Colors.Text,
		Text = "",
		TextYAlignment = Enum.TextYAlignment.Top,
		Parent = details,
	})
	self.DetailDescription = Components.Label({
		Size = UDim2.new(1, 0, 0, 110),
		Position = UDim2.fromOffset(0, 190),
		Font = Theme.Fonts.Body,
		TextSize = Theme.TextSize.Small,
		TextColor3 = Theme.Colors.TextMuted,
		Text = "",
		TextYAlignment = Enum.TextYAlignment.Top,
		Parent = details,
	})
	self.EquipButton = Components.Button({
		Name = "Equip",
		Text = "EQUIP",
		Color = Theme.Colors.Green,
		Size = UDim2.new(1, 0, 0, 44),
		Position = UDim2.new(0, 0, 1, 0),
		AnchorPoint = Vector2.new(0, 1),
		Parent = details,
		OnClick = function()
			local entry = self:_selectedEntry()
			if entry and entry.Kind == "Tool" then
				local equipped = self.State.Equipped == entry.Id
				self.Callbacks.OnEquip(if equipped then nil else entry.Id)
			end
		end,
	})
	self.EquipButton.Visible = false

	return self
end

function InventoryPanel:_selectedEntry(): Entry?
	for _, entry in self.Entries do
		if entry.Id == self.SelectedId then
			return entry
		end
	end
	return nil
end

function InventoryPanel:_buildEntries()
	local entries = {}
	for itemId, count in self.State.Items do
		local def = ItemConfig.Get(itemId)
		if def and count > 0 then
			table.insert(entries, {
				Id = itemId,
				Kind = "Item",
				Name = def.DisplayName,
				Icon = def.Icon,
				Rarity = def.Rarity,
				Category = def.Category,
				Count = count,
				Value = def.SellValue,
				Description = def.Description,
			})
		end
	end
	for toolId in self.State.OwnedTools do
		local def = ToolConfig.Get(toolId)
		if def then
			table.insert(entries, {
				Id = toolId,
				Kind = "Tool",
				Name = def.DisplayName,
				Icon = def.Icon,
				Rarity = "Common",
				Category = "Tools",
				Count = 1,
				Value = def.Price,
				Description = def.Description,
				ToolDef = def,
			})
		end
	end
	self.Entries = entries
end

function InventoryPanel:_getCard(index: number): Card
	local card = self.Cards[index]
	if card then
		return card
	end
	local button = Create("TextButton", {
		Name = "Card",
		BackgroundColor3 = Theme.Colors.Panel,
		AutoButtonColor = false,
		Text = "",
		Parent = self.Grid,
	})
	Components.Corner(button, Theme.SmallCorner)
	local stroke = Components.Stroke(button, Theme.Colors.Outline, 2.5)
	local icon = Components.Label({ Size = UDim2.new(1, 0, 0, 50), Position = UDim2.fromOffset(0, 4), TextSize = 38, Parent = button })
	local name = Components.Label({
		Size = UDim2.new(1, -6, 0, 18),
		Position = UDim2.new(0, 3, 1, -22),
		Font = Theme.Fonts.Bold,
		TextSize = 12,
		TextScaled = true,
		Parent = button,
	})
	local count = Components.Label({
		Size = UDim2.fromOffset(60, 18),
		Position = UDim2.new(1, -4, 0, 2),
		AnchorPoint = Vector2.new(1, 0),
		TextSize = 15,
		TextXAlignment = Enum.TextXAlignment.Right,
		Parent = button,
	})
	local newCard: Card = { Button = button, Icon = icon, Name = name, Count = count, Stroke = stroke }
	button.Activated:Connect(function()
		local entryId = button:GetAttribute("EntryId")
		if type(entryId) == "string" then
			self.SelectedId = entryId
			self:_renderDetails()
			self:_renderSelection()
		end
	end)
	self.Cards[index] = newCard
	return newCard
end

function InventoryPanel:_visibleEntries(): { Entry }
	local visible = {}
	for _, entry in self.Entries do
		local inCategory = self.Category == "All" or entry.Category == self.Category
		local matches = self.Search == "" or string.find(string.lower(entry.Name), self.Search, 1, true) ~= nil
		if inCategory and matches then
			table.insert(visible, entry)
		end
	end
	local mode = SORT_MODES[self.SortIndex]
	table.sort(visible, function(a, b)
		if mode == "Amount" and a.Count ~= b.Count then
			return a.Count > b.Count
		elseif mode == "Value" and a.Value ~= b.Value then
			return a.Value > b.Value
		end
		return a.Name < b.Name
	end)
	return visible
end

function InventoryPanel:_renderSelection()
	for _, card in self.Cards do
		local selected = card.Button.Visible and card.Button:GetAttribute("EntryId") == self.SelectedId
		card.Stroke.Thickness = if selected then 4.5 else 2.5
		card.Button.BackgroundColor3 = if selected then Color3.fromRGB(255, 240, 190) else Theme.Colors.Panel
	end
end

function InventoryPanel:_renderDetails()
	local entry = self:_selectedEntry()
	if not entry then
		self.DetailIcon.Text = ""
		self.DetailName.Text = "Select an item"
		self.DetailRarity.Text = ""
		self.DetailStats.Text = ""
		self.DetailDescription.Text = ""
		self.EquipButton.Visible = false
		return
	end
	local rarity = RarityConfig.Get(entry.Rarity)
	self.DetailIcon.Text = entry.Icon
	self.DetailName.Text = entry.Name
	self.DetailRarity.Text = rarity.DisplayName
	self.DetailRarity.TextColor3 = rarity.Color
	self.DetailDescription.Text = entry.Description
	if entry.Kind == "Tool" and entry.ToolDef then
		local def = entry.ToolDef
		self.DetailStats.Text = ("Power %d · Speed x%.2f\nBonus %d%%"):format(def.Power, def.Speed, math.floor(def.ResourceBonus * 100))
		local equipped = self.State.Equipped == entry.Id
		self.EquipButton.Visible = true
		self.EquipButton.Text = if equipped then "UNEQUIP" else "EQUIP"
	else
		self.DetailStats.Text = ("Amount: %s\nSells for: %s 🪙 each"):format(Format.Commas(entry.Count), Format.Commas(entry.Value))
		-- Seeds and crops can be held: plant by clicking soil, feed animals.
		local holdable = ItemConfig.IsHoldable(entry.Id)
		local held = self.State.Equipped == entry.Id
		self.EquipButton.Visible = holdable
		self.EquipButton.Text = if held then "PUT AWAY" else "✋ HOLD"
	end
end

function InventoryPanel:Render()
	for id, button in self.TabButtons do
		button.BackgroundColor3 = if id == self.Category then Theme.Colors.Coins else Theme.Colors.PanelAlt
	end
	self.CapacityLabel.Text = ("%s / %s"):format(Format.Commas(self.State.Used or 0), Format.Commas(self.State.Capacity or 0))

	local visible = self:_visibleEntries()
	for index, entry in visible do
		local card = self:_getCard(index)
		local rarity = RarityConfig.Get(entry.Rarity)
		card.Button.Visible = true
		card.Button.LayoutOrder = index
		card.Button:SetAttribute("EntryId", entry.Id)
		card.Icon.Text = entry.Icon
		card.Name.Text = entry.Name
		card.Name.TextColor3 = rarity.Color:Lerp(Theme.Colors.Text, 0.45)
		card.Count.Text = if entry.Kind == "Tool" then (if self.State.Equipped == entry.Id then "✔" else "") else "x" .. Format.Abbreviate(entry.Count)
	end
	for index = #visible + 1, #self.Cards do
		self.Cards[index].Button.Visible = false
	end
	self.EmptyLabel.Visible = #visible == 0
	self:_renderSelection()
	self:_renderDetails()
end

-- state = { Items, Capacity, Used, OwnedTools, Equipped }
function InventoryPanel:SetState(state: { [string]: any })
	self.State = state
	self:_buildEntries()
	if self.Panel.Visible then
		self:Render()
	end
end

function InventoryPanel:Open()
	self.Panel.Visible = true
	self:Render()
	Components.Bounce(self.Panel, 0.06)
end

function InventoryPanel:Close()
	self.Panel.Visible = false
end

function InventoryPanel:IsOpen(): boolean
	return self.Panel.Visible
end

return InventoryPanel
