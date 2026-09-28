--[[
	SCRIPT NAME:  ShopController
	SCRIPT TYPE:  ModuleScript (client controller)
	WHERE:        StarterPlayerScripts/Client/Controllers/ShopController
	DEPENDENCIES: Shared.Net, Shared.Config.{ShopConfig, ItemConfig, EconomyConfig},
	              Shared.Util.{Format, R15}, Client.ClientState, UIController, InputController,
	              InteractionController, Client.UI.{Components, Theme}

	The ISLAND MARKET window (spec §33, §64-§65, §88-§89). Opened by the
	market stall's prompts ([E] Sell / [F] Shop → OpenUI{Screen="Market"}).

	SELL tab   today's demand bonus, one big "SELL ALL PRODUCE" button, and
	           every sellable item you own with Sell 1 / Sell All.
	BUY tab    Seeds · Animals · Tools · Upgrades from ShopConfig, showing
	           ✔ affordable / 🔒 level / OWNED / MAX states.

	Prices shown are an ESTIMATE using the same formula as the server
	(SellValue x GlobalSellMultiplier x demand). The server recomputes every
	price itself and re-checks distance, stock and funds — the client only
	sends SellItemRequest(itemId, qty) / PurchaseRequest(shopItemId, qty).
]]

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Net = require(Shared:WaitForChild("Net"))
local ShopConfig = require(Shared.Config.ShopConfig)
local ItemConfig = require(Shared.Config.ItemConfig)
local EconomyConfig = require(Shared.Config.EconomyConfig)
local Format = require(Shared.Util.Format)
local R15 = require(Shared.Util.R15)

local Client = script.Parent.Parent
local ClientState = require(Client.ClientState)
local UIController = require(script.Parent.UIController)
local InputController = require(script.Parent.InputController)
local InteractionController = require(script.Parent.InteractionController)
local Components = require(Client.UI.Components)
local Theme = require(Client.UI.Theme)

local Create = Components.Create
local player = Players.LocalPlayer

local SELL_ALL = "__ALL__"
local WALK_AWAY_DISTANCE = ShopConfig.MarketRange + 8

local ShopController = {}

type Refs = {
	Panel: Frame,
	SellTab: TextButton,
	BuyTab: TextButton,
	SellPage: Frame,
	BuyPage: Frame,
	Demand: TextLabel,
	SellAll: TextButton,
	SellList: ScrollingFrame,
	SellEmpty: TextLabel,
	CategoryButtons: { [string]: TextButton },
	BuyList: ScrollingFrame,
}

local refs: Refs
local open = false
local tab = "Sell"
local buyCategory = "Seeds"
local releases: { () -> () } = {}
local sellRows: { Frame } = {}
local buyCards: { Frame } = {}

---------------------------------------------------------------------------
-- Pricing / demand (display only)
---------------------------------------------------------------------------

local function demandTable(): { [string]: number }
	local raw = ReplicatedStorage:GetAttribute("MarketDemand")
	local result = {}
	if type(raw) ~= "string" or raw == "" then
		return result
	end
	local ok, decoded = pcall(HttpService.JSONDecode, HttpService, raw)
	if ok and type(decoded) == "table" then
		for _, entry in decoded do
			if type(entry) == "table" and type(entry.Item) == "string" and type(entry.Bonus) == "number" then
				result[entry.Item] = entry.Bonus
			end
		end
	end
	return result
end

local function priceOf(itemId: string, demand: { [string]: number }): number
	local def = ItemConfig.Get(itemId)
	if not def or def.SellValue <= 0 then
		return 0
	end
	return math.max(1, math.floor(def.SellValue * EconomyConfig.GlobalSellMultiplier * (1 + (demand[itemId] or 0))))
end

local function demandText(demand: { [string]: number }): string
	local parts = {}
	for itemId, bonus in demand do
		local def = ItemConfig.Get(itemId)
		if def then
			table.insert(parts, ("%s %s +%d%%"):format(def.Icon, def.DisplayName, math.floor(bonus * 100 + 0.5)))
		end
	end
	table.sort(parts)
	if #parts == 0 then
		return "📈 No special demand right now."
	end
	local endsAt = ReplicatedStorage:GetAttribute("MarketDemandEndsAt")
	local remaining = if type(endsAt) == "number" then math.max(0, endsAt - workspace:GetServerTimeNow()) else 0
	return ("📈 In demand: %s   ·   changes in %s"):format(table.concat(parts, "  ·  "), Format.Duration(math.ceil(remaining)))
end

---------------------------------------------------------------------------
-- Small UI helpers
---------------------------------------------------------------------------

local function plainButton(props: Components.ButtonProps): TextButton
	local button = Components.Button(props)
	for _, child in button:GetChildren() do
		if child:IsA("UIStroke") and child.ApplyStrokeMode == Enum.ApplyStrokeMode.Contextual then
			child:Destroy()
		end
	end
	return button
end

local function setButtonEnabled(button: TextButton, enabled: boolean, color: Color3)
	button.Active = enabled
	button.AutoButtonColor = false
	button.BackgroundColor3 = if enabled then color else Theme.Colors.PanelDark
	button.TextColor3 = if enabled then Theme.Colors.TextLight else Theme.Colors.TextMuted
end

---------------------------------------------------------------------------
-- SELL page
---------------------------------------------------------------------------

local function sellRow(index: number): Frame
	local row = sellRows[index]
	if row then
		return row
	end
	row = Create("Frame", { Name = "Row", Size = UDim2.new(1, -10, 0, 58), BackgroundColor3 = Theme.Colors.PanelAlt, Parent = refs.SellList })
	Components.Corner(row, Theme.SmallCorner)
	Components.Stroke(row, Theme.Colors.Outline, 2)
	Components.Label({ Name = "Icon", Size = UDim2.fromOffset(48, 48), Position = UDim2.fromOffset(6, 5), TextSize = 34, Text = "", Parent = row })
	Components.Label({ Name = "Title", Size = UDim2.new(0.45, -60, 0, 26), Position = UDim2.fromOffset(60, 4), TextXAlignment = Enum.TextXAlignment.Left, TextSize = Theme.TextSize.Medium, Text = "", Parent = row })
	Components.Label({ Name = "Count", Size = UDim2.new(0.45, -60, 0, 20), Position = UDim2.fromOffset(60, 30), TextXAlignment = Enum.TextXAlignment.Left, Font = Theme.Fonts.Bold, TextSize = 13, TextColor3 = Theme.Colors.TextMuted, Text = "", Parent = row })
	Components.Label({ Name = "Price", Size = UDim2.new(0.25, 0, 1, 0), Position = UDim2.fromScale(0.42, 0), Font = Theme.Fonts.Bold, TextSize = Theme.TextSize.Small, Text = "", Parent = row })
	plainButton({
		Name = "SellOne",
		Text = "Sell 1",
		Color = Theme.Colors.Blue,
		Size = UDim2.new(0.15, 0, 0, 40),
		Position = UDim2.new(0.68, 0, 0.5, 0),
		AnchorPoint = Vector2.new(0, 0.5),
		TextSize = Theme.TextSize.Small,
		Parent = row,
		OnClick = function()
			local itemId = row:GetAttribute("ItemId")
			if type(itemId) == "string" then
				Net.FireServer("SellItemRequest", itemId, 1)
			end
		end,
	})
	plainButton({
		Name = "SellAll",
		Text = "Sell All",
		Color = Theme.Colors.Green,
		Size = UDim2.new(0.15, 0, 0, 40),
		Position = UDim2.new(1, -8, 0.5, 0),
		AnchorPoint = Vector2.new(1, 0.5),
		TextSize = Theme.TextSize.Small,
		Parent = row,
		OnClick = function()
			local itemId = row:GetAttribute("ItemId")
			if type(itemId) == "string" then
				Net.FireServer("SellItemRequest", itemId, "All")
			end
		end,
	})
	sellRows[index] = row
	return row
end

local function categoryOrder(): { [string]: number }
	local order = {}
	for index, category in ItemConfig.Categories do
		order[category.Id] = index
	end
	return order
end
local CATEGORY_ORDER = categoryOrder()

local function renderSell()
	local demand = demandTable()
	refs.Demand.Text = demandText(demand)
	local items = ClientState.Get("Inventory", "Items") or {}

	local owned = {}
	local sellAllTotal, sellAllCount = 0, 0
	for itemId, count in items do
		local def = ItemConfig.Get(itemId)
		if def and count > 0 and def.SellValue > 0 then
			table.insert(owned, def)
			if ShopConfig.SellAllCategories[def.Category] then
				sellAllTotal += priceOf(itemId, demand) * count
				sellAllCount += count
			end
		end
	end
	table.sort(owned, function(a, b)
		local orderA, orderB = CATEGORY_ORDER[a.Category] or 99, CATEGORY_ORDER[b.Category] or 99
		if orderA ~= orderB then
			return orderA < orderB
		end
		return a.DisplayName < b.DisplayName
	end)

	setButtonEnabled(refs.SellAll, sellAllCount > 0, Theme.Colors.Green)
	refs.SellAll.Text = if sellAllCount > 0
		then ("💰 SELL ALL PRODUCE  (%d items ≈ %s 🪙)"):format(sellAllCount, Format.Commas(sellAllTotal))
		else "💰 SELL ALL PRODUCE  (crops, fish, milk & eggs)"

	for index, def in owned do
		local row = sellRow(index)
		row.Visible = true
		row.LayoutOrder = index
		row:SetAttribute("ItemId", def.Id)
		local count = items[def.Id] or 0
		local price = priceOf(def.Id, demand)
		local bonus = demand[def.Id]
		;(row:FindFirstChild("Icon") :: TextLabel).Text = def.Icon
		;(row:FindFirstChild("Title") :: TextLabel).Text = def.DisplayName
		;(row:FindFirstChild("Count") :: TextLabel).Text = ("x%d owned"):format(count)
		local priceLabel = row:FindFirstChild("Price") :: TextLabel
		priceLabel.Text = if bonus
			then ("%s 🪙 each\n📈 +%d%%"):format(Format.Commas(price), math.floor(bonus * 100 + 0.5))
			else ("%s 🪙 each"):format(Format.Commas(price))
		priceLabel.TextColor3 = if bonus then Theme.Colors.Orange else Theme.Colors.Text
		row.BackgroundColor3 = if bonus then Color3.fromRGB(255, 238, 200) else Theme.Colors.PanelAlt
	end
	for index = #owned + 1, #sellRows do
		sellRows[index].Visible = false
	end
	refs.SellEmpty.Visible = #owned == 0
end

---------------------------------------------------------------------------
-- BUY page
---------------------------------------------------------------------------

local function buyCard(index: number): Frame
	local card = buyCards[index]
	if card then
		return card
	end
	card = Create("Frame", { Name = "Card", BackgroundColor3 = Theme.Colors.PanelAlt, Parent = refs.BuyList })
	Components.Corner(card, Theme.SmallCorner)
	Components.Stroke(card, Theme.Colors.Outline, 2)
	Components.Label({ Name = "Icon", Size = UDim2.fromOffset(52, 52), Position = UDim2.fromOffset(6, 6), TextSize = 38, Text = "", Parent = card })
	Components.Label({ Name = "Title", Size = UDim2.new(1, -66, 0, 24), Position = UDim2.fromOffset(60, 8), TextXAlignment = Enum.TextXAlignment.Left, TextSize = Theme.TextSize.Medium, TextScaled = true, Text = "", Parent = card })
	Components.Label({ Name = "Price", Size = UDim2.new(1, -66, 0, 22), Position = UDim2.fromOffset(60, 32), TextXAlignment = Enum.TextXAlignment.Left, Font = Theme.Fonts.Bold, TextSize = Theme.TextSize.Small, Text = "", Parent = card })
	Components.Label({
		Name = "Description",
		Size = UDim2.new(1, -14, 0, 48),
		Position = UDim2.fromOffset(7, 60),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		Font = Theme.Fonts.Body,
		TextSize = 12,
		TextColor3 = Theme.Colors.TextMuted,
		Text = "",
		Parent = card,
	})
	local function buy(quantity: number)
		local shopId = card:GetAttribute("ShopId")
		if type(shopId) == "string" and card:GetAttribute("CanBuy") == true then
			Net.FireServer("PurchaseRequest", shopId, quantity)
		elseif card:GetAttribute("Reason") then
			UIController.Notify("Error", tostring(card:GetAttribute("Reason")))
		end
	end
	plainButton({
		Name = "Buy",
		Text = "BUY",
		Color = Theme.Colors.Green,
		Size = UDim2.new(1, -14, 0, 36),
		Position = UDim2.new(0, 7, 1, -8),
		AnchorPoint = Vector2.new(0, 1),
		TextSize = Theme.TextSize.Small,
		Parent = card,
		OnClick = function()
			buy(1)
		end,
	})
	plainButton({
		Name = "BuyBulk",
		Text = "x5",
		Color = Theme.Colors.Blue,
		Size = UDim2.new(0.35, -8, 0, 36),
		Position = UDim2.new(1, -7, 1, -8),
		AnchorPoint = Vector2.new(1, 1),
		TextSize = Theme.TextSize.Small,
		Parent = card,
		OnClick = function()
			local bulk = card:GetAttribute("Bulk")
			if type(bulk) == "number" then
				buy(bulk)
			end
		end,
	})
	buyCards[index] = card
	return card
end

local function costText(def: any, quantity: number, coins: number, items: { [string]: number }): (string, boolean)
	local canAfford = coins >= def.Price * quantity
	local parts = { Format.Commas(def.Price * quantity) .. " 🪙" }
	for itemId, amount in def.Items or {} do
		local item = ItemConfig.Get(itemId)
		local need = amount * quantity
		canAfford = canAfford and (items[itemId] or 0) >= need
		table.insert(parts, ("%d %s"):format(need, if item then item.Icon else itemId))
	end
	return table.concat(parts, " + "), canAfford
end

local function renderBuy()
	for id, button in refs.CategoryButtons do
		button.BackgroundColor3 = if id == buyCategory then Theme.Colors.Coins else Theme.Colors.PanelAlt
	end
	local coins = ClientState.Get("Coins") or 0
	local items = ClientState.Get("Inventory", "Items") or {}
	local ownedTools = ClientState.Get("Tools", "Owned") or {}
	local upgrades = ClientState.Get("Island", "Upgrades") or {}
	local level = ClientState.Get("Island", "Level") or 1

	local defs = {}
	for _, def in ShopConfig.Items do
		if def.Category == buyCategory then
			table.insert(defs, def)
		end
	end
	table.sort(defs, function(a, b)
		return a.Order < b.Order
	end)

	for index, def in defs do
		local card = buyCard(index)
		card.Visible = true
		card.LayoutOrder = index
		card:SetAttribute("ShopId", def.Id)
		card:SetAttribute("Bulk", def.Bulk)
		local price, canAfford = costText(def, 1, coins, items)
		local reason: string? = nil
		local status: string? = nil
		if level < (def.UnlockLevel or 1) then
			reason = ("Unlocks at Island Level %d."):format(def.UnlockLevel)
			status = ("🔒 Level %d"):format(def.UnlockLevel)
		elseif def.Grant.Tool and ownedTools[def.Grant.Tool] then
			reason = "You already own that."
			status = "✔ OWNED"
		elseif def.Grant.Upgrade and def.MaxOwned and (upgrades[def.Grant.Upgrade] or 0) >= def.MaxOwned then
			reason = "Fully upgraded."
			status = "✔ MAX"
		elseif not canAfford then
			reason = "You can't afford that yet."
		end
		card:SetAttribute("CanBuy", reason == nil)
		card:SetAttribute("Reason", reason)

		;(card:FindFirstChild("Icon") :: TextLabel).Text = def.Icon
		;(card:FindFirstChild("Title") :: TextLabel).Text = def.DisplayName
		local priceLabel = card:FindFirstChild("Price") :: TextLabel
		priceLabel.Text = if def.Grant.Upgrade and def.MaxOwned
			then ("%s  ·  %d/%d"):format(price, upgrades[def.Grant.Upgrade] or 0, def.MaxOwned)
			else price
		priceLabel.TextColor3 = if canAfford then Theme.Colors.Green else Theme.Colors.Red
		;(card:FindFirstChild("Description") :: TextLabel).Text = def.Description or ""

		local buyButton = card:FindFirstChild("Buy") :: TextButton
		local bulkButton = card:FindFirstChild("BuyBulk") :: TextButton
		local hasBulk = type(def.Bulk) == "number"
		buyButton.Size = if hasBulk then UDim2.new(0.65, -10, 0, 36) else UDim2.new(1, -14, 0, 36)
		buyButton.Text = status or "BUY"
		setButtonEnabled(buyButton, reason == nil, Theme.Colors.Green)
		bulkButton.Visible = hasBulk and status == nil
		if hasBulk then
			local _, bulkAffordable = costText(def, def.Bulk, coins, items)
			bulkButton.Text = "x" .. def.Bulk
			setButtonEnabled(bulkButton, bulkAffordable and status == nil, Theme.Colors.Blue)
		end
		card.BackgroundColor3 = if status then Theme.Colors.PanelDark else Theme.Colors.PanelAlt
	end
	for index = #defs + 1, #buyCards do
		buyCards[index].Visible = false
	end
end

---------------------------------------------------------------------------
-- Window
---------------------------------------------------------------------------

local function render()
	if not open then
		return
	end
	refs.SellPage.Visible = tab == "Sell"
	refs.BuyPage.Visible = tab == "Buy"
	refs.SellTab.BackgroundColor3 = if tab == "Sell" then Theme.Colors.Green else Theme.Colors.PanelDark
	refs.BuyTab.BackgroundColor3 = if tab == "Buy" then Theme.Colors.Blue else Theme.Colors.PanelDark
	if tab == "Sell" then
		renderSell()
	else
		renderBuy()
	end
end

local function setTab(newTab: string)
	tab = newTab
	render()
end

function ShopController.IsOpen(): boolean
	return open
end

function ShopController.Close()
	if not open then
		return
	end
	open = false
	refs.Panel.Visible = false
	UIController.SetModalOpen("Market", false)
	for _, release in releases do
		release()
	end
	table.clear(releases)
end

function ShopController.Open(newTab: string?)
	if newTab == "Sell" or newTab == "Buy" then
		tab = newTab
	end
	if open then
		render()
		return
	end
	if UIController.IsAnyModalOpen() then
		return
	end
	open = true
	refs.Panel.Visible = true
	Components.Bounce(refs.Panel, 0.05)
	UIController.SetModalOpen("Market", true)
	table.insert(releases, InputController.Block("UseTool"))
	table.insert(releases, InteractionController.PausePrompts())
	render()
end

local function buildUI()
	local panel, content = Components.Panel({
		Title = "🛒 ISLAND MARKET",
		Size = UDim2.fromOffset(780, 520),
		Parent = UIController.GetModalLayer(),
		OnClose = ShopController.Close,
	})
	panel.Name = "Market"
	panel.Visible = false

	local sellTab = plainButton({ Name = "SellTab", Text = "💰 SELL", Color = Theme.Colors.Green, Size = UDim2.fromOffset(150, 42), Parent = content, OnClick = function()
		setTab("Sell")
	end })
	local buyTab = plainButton({ Name = "BuyTab", Text = "🛍️ BUY", Color = Theme.Colors.Blue, Size = UDim2.fromOffset(150, 42), Position = UDim2.fromOffset(160, 0), Parent = content, OnClick = function()
		setTab("Buy")
	end })

	-- SELL page ---------------------------------------------------------------
	local sellPage = Create("Frame", { Name = "SellPage", Size = UDim2.new(1, 0, 1, -52), Position = UDim2.fromOffset(0, 52), BackgroundTransparency = 1, Parent = content })
	local demand = Components.Label({
		Name = "Demand",
		Size = UDim2.new(1, 0, 0, 30),
		BackgroundTransparency = 0,
		BackgroundColor3 = Color3.fromRGB(255, 232, 180),
		Font = Theme.Fonts.Bold,
		TextSize = 14,
		TextColor3 = Theme.Colors.Text,
		TextScaled = true,
		Text = "",
		Parent = sellPage,
	})
	Components.Corner(demand, Theme.SmallCorner)
	Create("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10), PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 4), Parent = demand })
	local sellAll = plainButton({
		Name = "SellEverything",
		Text = "💰 SELL ALL PRODUCE",
		Color = Theme.Colors.Green,
		Size = UDim2.new(1, 0, 0, 50),
		Position = UDim2.fromOffset(0, 38),
		TextSize = Theme.TextSize.Medium,
		Parent = sellPage,
		OnClick = function()
			Net.FireServer("SellItemRequest", SELL_ALL, 1)
		end,
	})
	local sellList = Create("ScrollingFrame", {
		Name = "Items",
		Size = UDim2.new(1, 0, 1, -98),
		Position = UDim2.fromOffset(0, 98),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 6,
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Parent = sellPage,
	}, {
		Create("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }),
	})
	local sellEmpty = Components.Label({
		Size = UDim2.new(1, 0, 0, 60),
		Position = UDim2.fromOffset(0, 120),
		Font = Theme.Fonts.Bold,
		TextSize = Theme.TextSize.Medium,
		TextColor3 = Theme.Colors.TextMuted,
		Text = "Nothing to sell yet — harvest crops, catch fish or collect milk & eggs!",
		Visible = false,
		Parent = sellPage,
	})

	-- BUY page ----------------------------------------------------------------
	local buyPage = Create("Frame", { Name = "BuyPage", Size = UDim2.new(1, 0, 1, -52), Position = UDim2.fromOffset(0, 52), BackgroundTransparency = 1, Visible = false, Parent = content })
	local categoryRow = Create("Frame", { Size = UDim2.new(1, 0, 0, 38), BackgroundTransparency = 1, Parent = buyPage }, {
		Create("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder }),
	})
	local categoryButtons = {}
	for index, category in ShopConfig.Categories do
		local button = plainButton({
			Name = category.Id,
			Text = category.Icon .. " " .. category.DisplayName,
			Color = Theme.Colors.PanelAlt,
			TextColor = Theme.Colors.Text,
			Size = UDim2.fromOffset(140, 36),
			TextSize = Theme.TextSize.Small,
			Parent = categoryRow,
			OnClick = function()
				buyCategory = category.Id
				renderBuy()
			end,
		})
		button.LayoutOrder = index
		categoryButtons[category.Id] = button
	end
	local buyList = Create("ScrollingFrame", {
		Name = "Items",
		Size = UDim2.new(1, 0, 1, -46),
		Position = UDim2.fromOffset(0, 46),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 6,
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Parent = buyPage,
	}, {
		Create("UIGridLayout", { CellSize = UDim2.fromOffset(236, 158), CellPadding = UDim2.fromOffset(10, 10), SortOrder = Enum.SortOrder.LayoutOrder }),
		Create("UIPadding", { PaddingTop = UDim.new(0, 4), PaddingLeft = UDim.new(0, 4) }),
	})

	refs = {
		Panel = panel,
		SellTab = sellTab,
		BuyTab = buyTab,
		SellPage = sellPage,
		BuyPage = buyPage,
		Demand = demand,
		SellAll = sellAll,
		SellList = sellList,
		SellEmpty = sellEmpty,
		CategoryButtons = categoryButtons,
		BuyList = buyList,
	}
end

local function marketStallPosition(): Vector3?
	local islands = workspace:FindFirstChild("Islands")
	local island = islands and islands:FindFirstChild("Island_" .. player.UserId)
	local stall = island and island:FindFirstChild("MarketStall", true)
	return if stall and stall:IsA("Model") then stall:GetPivot().Position else nil
end

function ShopController.Init()
	buildUI()
end

function ShopController.Start()
	Net.OnClientEvent("OpenUI", function(payload: any)
		if type(payload) == "table" and payload.Screen == "Market" then
			ShopController.Open(payload.Tab)
		end
	end)
	InputController.On("Cancel", ShopController.Close)
	for _, key in { "Coins", "Inventory", "Tools", "Island" } do
		ClientState.Observe(key, render)
	end
	ReplicatedStorage:GetAttributeChangedSignal("MarketDemand"):Connect(render)

	-- Close when the player walks away; keep the demand timer ticking.
	task.spawn(function()
		while true do
			task.wait(1)
			if open then
				local root = R15.GetRootPart(player.Character)
				local stall = marketStallPosition()
				if root and stall and (root.Position - stall).Magnitude > WALK_AWAY_DISTANCE then
					ShopController.Close()
				elseif tab == "Sell" then
					refs.Demand.Text = demandText(demandTable())
				end
			end
		end
	end)
end

return ShopController
