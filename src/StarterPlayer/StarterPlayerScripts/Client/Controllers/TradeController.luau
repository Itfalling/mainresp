--[[
	SCRIPT NAME:  TradeController
	SCRIPT TYPE:  ModuleScript (client controller)
	WHERE:        StarterPlayerScripts/Client/Controllers/TradeController
	DEPENDENCIES: Shared.Net, Shared.Config.ItemConfig, Shared.Util.Format, Client.ClientState, UIController,
	              AudioController, Client.UI.{Components, Theme}

	Player-to-player TRADING, client side. It only ever SHOWS what the
	server's TradeService says (TradeEvent) and sends requests:

	  invite popup    "<name> wants to trade!"  ACCEPT / DECLINE
	  trade window    YOUR BACKPACK (click an item to offer one more)
	                  YOUR OFFER    (click an offered item to take one back,
	                                 type coins, then READY)
	                  THEIR OFFER   (live, with their ready tick)
	When both are ready a 3-second countdown runs; any change un-readies
	both players, so nobody can swap items at the last second.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Net = require(Shared:WaitForChild("Net"))
local ItemConfig = require(Shared.Config.ItemConfig)
local Format = require(Shared.Util.Format)

local Client = script.Parent.Parent
local ClientState = require(Client.ClientState)
local UIController = require(script.Parent.UIController)
local AudioController = require(script.Parent.AudioController)
local Components = require(Client.UI.Components)
local Theme = require(Client.UI.Theme)

local Create = Components.Create

local CELL = 74

local TradeController = {}

type Grid = { Frame: ScrollingFrame, Cells: { TextButton }, OnClick: ((string) -> ())? }

local window: Frame
local titleLabel: TextLabel
local backpack: Grid
local mine: Grid
local theirs: Grid
local coinsBox: TextBox
local theirCoins: TextLabel
local readyButton: TextButton
local theirReady: TextLabel
local status: TextLabel
local invitesFrame: Frame
local state: any = nil
local isOpen = false

---------------------------------------------------------------------------
-- Item grids
---------------------------------------------------------------------------

local function newGrid(parent: Instance, size: UDim2, position: UDim2): Grid
	local frame = Create("ScrollingFrame", {
		Size = size,
		Position = position,
		BackgroundColor3 = Theme.Colors.PanelDark,
		BackgroundTransparency = 0.55,
		BorderSizePixel = 0,
		ScrollBarThickness = 6,
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Parent = parent,
	}, {
		Create("UIGridLayout", { CellSize = UDim2.fromOffset(CELL, CELL), CellPadding = UDim2.fromOffset(6, 6), SortOrder = Enum.SortOrder.LayoutOrder }),
		Create("UIPadding", { PaddingTop = UDim.new(0, 6), PaddingLeft = UDim.new(0, 6) }),
	})
	Components.Corner(frame, Theme.SmallCorner)
	return { Frame = frame, Cells = {}, OnClick = nil }
end

-- Fills a grid with { itemId = count } (sorted by name). onClick(itemId) optional.
local function fillGrid(grid: Grid, items: { [string]: number }, onClick: ((string) -> ())?)
	local ids = {}
	for itemId, count in items do
		if count > 0 and ItemConfig.Get(itemId) then
			table.insert(ids, itemId)
		end
	end
	table.sort(ids, function(a, b)
		return (ItemConfig.Get(a) :: any).DisplayName < (ItemConfig.Get(b) :: any).DisplayName
	end)
	for index, itemId in ids do
		local cell = grid.Cells[index]
		if not cell then
			cell = Create("TextButton", { Size = UDim2.fromOffset(CELL, CELL), BackgroundColor3 = Theme.Colors.Panel, AutoButtonColor = true, Text = "", Parent = grid.Frame })
			Components.Corner(cell, Theme.SmallCorner)
			Components.Stroke(cell, Theme.Colors.Outline, 2)
			Components.Label({ Name = "Icon", Size = UDim2.new(1, 0, 0, 44), Position = UDim2.fromOffset(0, 4), TextSize = 32, Parent = cell })
			Components.Label({ Name = "Name", Size = UDim2.new(1, -6, 0, 14), Position = UDim2.new(0, 3, 1, -18), Font = Theme.Fonts.Bold, TextScaled = true, TextColor3 = Theme.Colors.TextMuted, Parent = cell })
			local count = Components.Label({ Name = "Count", Size = UDim2.fromOffset(50, 18), Position = UDim2.new(1, -4, 0, 2), AnchorPoint = Vector2.new(1, 0), Font = Theme.Fonts.Heavy, TextSize = 15, TextColor3 = Theme.Colors.TextLight, TextXAlignment = Enum.TextXAlignment.Right, Parent = cell })
			Components.TextStroke(count, Theme.Colors.Outline, 2)
			cell.Activated:Connect(function()
				local itemId = cell:GetAttribute("ItemId")
				local handler = grid.OnClick
				if type(itemId) == "string" and handler then
					AudioController.Play("UIClick")
					handler(itemId)
				end
			end)
			grid.Cells[index] = cell
		end
		local def = ItemConfig.Get(itemId) :: any
		cell.Visible = true
		cell.LayoutOrder = index
		cell:SetAttribute("ItemId", itemId)
		cell.AutoButtonColor = onClick ~= nil;
		(cell:FindFirstChild("Icon") :: TextLabel).Text = def.Icon;
		(cell:FindFirstChild("Name") :: TextLabel).Text = def.DisplayName;
		(cell:FindFirstChild("Count") :: TextLabel).Text = "x" .. Format.Abbreviate(items[itemId])
	end
	for index = #ids + 1, #grid.Cells do
		grid.Cells[index].Visible = false
	end
	grid.OnClick = onClick
end

---------------------------------------------------------------------------
-- Window
---------------------------------------------------------------------------

local function send(payload: { [string]: any })
	Net.FireServer("TradeRequest", payload)
end

local function myOffer(): { Items: { [string]: number }, Coins: number }
	return (state and state.You and state.You.Offer) or { Items = {}, Coins = 0 }
end

local function render()
	if not state then
		return
	end
	local offer = myOffer()
	local owned = ClientState.Get("Inventory", "Items") or {}
	local available = {}
	for itemId, count in owned do
		available[itemId] = count - (offer.Items[itemId] or 0)
	end
	fillGrid(backpack, available, function(itemId)
		send({ Op = "Offer", ItemId = itemId, Amount = (myOffer().Items[itemId] or 0) + 1 })
	end)
	fillGrid(mine, offer.Items, function(itemId)
		send({ Op = "Offer", ItemId = itemId, Amount = math.max(0, (myOffer().Items[itemId] or 0) - 1) })
	end)
	local them = state.Them or {}
	local theirOffer = them.Offer or { Items = {}, Coins = 0 }
	fillGrid(theirs, theirOffer.Items, nil)
	titleLabel.Text = "Trading with " .. tostring(them.Name or "?")
	if not coinsBox:IsFocused() then
		coinsBox.Text = tostring(offer.Coins or 0)
	end
	theirCoins.Text = "🪙 " .. Format.Commas(theirOffer.Coins or 0)
	local ready = state.You and state.You.Ready
	readyButton.Text = if ready then "✔ READY (click to unlock)" else "READY"
	Components.SetButtonColor(readyButton, if ready then Theme.Colors.Green else Theme.Colors.Blue)
	theirReady.Text = if them.Ready then "✔ " .. tostring(them.Name) .. " is ready" else "⏳ " .. tostring(them.Name) .. " is choosing…"
	theirReady.TextColor3 = if them.Ready then Theme.Colors.Green else Theme.Colors.TextMuted
end

local function tickStatus()
	if not state then
		return
	end
	if state.Phase == "Confirming" then
		local left = math.max(0, state.ConfirmAt - workspace:GetServerTimeNow())
		status.Text = ("🔒 Both ready — trading in %d…"):format(math.ceil(left))
		status.TextColor3 = Theme.Colors.Green
	else
		status.Text = "Any change un-readies both players. Check their offer before you press READY!"
		status.TextColor3 = Theme.Colors.TextMuted
	end
end

local function openWindow()
	if not isOpen then
		isOpen = true
		window.Visible = true
		UIController.SetModalOpen("Trade", true)
		Components.PopIn(window)
		AudioController.Play("UIOpen")
	end
end

local function closeWindow()
	state = nil
	if isOpen then
		isOpen = false
		window.Visible = false
		UIController.SetModalOpen("Trade", false)
	end
end

local function buildWindow()
	local content, closeButton
	window, content, closeButton = Components.Panel({ Title = "🤝 Trade", Size = UDim2.fromOffset(940, 560), Parent = UIController.GetModalLayer(), Color = Theme.Colors.Orange })
	window.Visible = false
	closeButton.Activated:Connect(function()
		send({ Op = "Cancel" })
	end)
	titleLabel = Components.Label({ Size = UDim2.new(1, 0, 0, 28), TextSize = Theme.TextSize.Large, Text = "", Parent = content })

	local function header(text: string, x: number)
		Components.Label({ Text = text, Size = UDim2.fromOffset(292, 24), Position = UDim2.fromOffset(x, 34), TextSize = Theme.TextSize.Medium, Parent = content })
	end
	header("🎒 Your backpack", 0)
	header("📦 You give", 306)
	header("🎁 You get", 612)
	backpack = newGrid(content, UDim2.fromOffset(292, 330), UDim2.fromOffset(0, 62))
	mine = newGrid(content, UDim2.fromOffset(292, 270), UDim2.fromOffset(306, 62))
	theirs = newGrid(content, UDim2.fromOffset(292, 270), UDim2.fromOffset(612, 62))

	Components.Label({ Text = "🪙", Size = UDim2.fromOffset(36, 44), Position = UDim2.fromOffset(306, 340), TextSize = 28, Parent = content })
	coinsBox = Create("TextBox", {
		Size = UDim2.fromOffset(250, 44),
		Position = UDim2.fromOffset(346, 340),
		BackgroundColor3 = Color3.new(1, 1, 1),
		Font = Theme.Fonts.Bold,
		TextSize = Theme.TextSize.Large,
		TextColor3 = Theme.Colors.Text,
		PlaceholderText = "0",
		ClearTextOnFocus = true,
		Text = "0",
		Parent = content,
	})
	Components.Corner(coinsBox, Theme.SmallCorner)
	Components.Stroke(coinsBox, Theme.Colors.Outline, 2)
	coinsBox.FocusLost:Connect(function()
		local amount = math.floor(tonumber(coinsBox.Text) or 0)
		local coins = ClientState.Get("Coins") or 0
		amount = math.clamp(amount, 0, coins)
		coinsBox.Text = tostring(amount)
		if amount ~= myOffer().Coins then
			send({ Op = "Coins", Amount = amount })
		end
	end)
	theirCoins = Components.Label({ Text = "🪙 0", Size = UDim2.fromOffset(292, 44), Position = UDim2.fromOffset(612, 340), TextSize = Theme.TextSize.Large, Parent = content })

	readyButton = Components.Button({ Text = "READY", Color = Theme.Colors.Blue, Size = UDim2.fromOffset(292, 56), Position = UDim2.fromOffset(306, 400), Parent = content, OnClick = function()
		local ready = state and state.You and state.You.Ready
		send({ Op = "Ready", Ready = not ready })
	end })
	theirReady = Components.Label({ Text = "", Size = UDim2.fromOffset(292, 56), Position = UDim2.fromOffset(612, 400), Font = Theme.Fonts.Bold, TextSize = Theme.TextSize.Medium, Parent = content })
	status = Components.Label({ Text = "", Size = UDim2.new(1, 0, 0, 26), Position = UDim2.new(0, 0, 1, -26), Font = Theme.Fonts.Bold, TextSize = Theme.TextSize.Small, TextColor3 = Theme.Colors.TextMuted, Parent = content })
	Components.Label({ Text = "Click an item to add it →", Size = UDim2.fromOffset(292, 30), Position = UDim2.fromOffset(0, 400), Font = Theme.Fonts.Bold, TextSize = Theme.TextSize.Small, TextColor3 = Theme.Colors.TextMuted, Parent = content })
end

---------------------------------------------------------------------------
-- Invites
---------------------------------------------------------------------------

local function showInvite(fromUserId: number, fromName: string, expires: number)
	local existing = invitesFrame:FindFirstChild(tostring(fromUserId))
	if existing then
		existing:Destroy()
	end
	local card = Create("Frame", { Name = tostring(fromUserId), Size = UDim2.fromOffset(420, 96), BackgroundColor3 = Theme.Colors.Panel, Parent = invitesFrame })
	Components.Corner(card)
	Components.Stroke(card, Theme.Colors.Outline, 3)
	Components.Gradient(card, Color3.new(1, 1, 1), Theme.Colors.PanelAlt)
	Components.Label({ Text = "🤝 " .. fromName .. " wants to trade!", Size = UDim2.new(1, -16, 0, 34), Position = UDim2.fromOffset(8, 4), TextSize = Theme.TextSize.Medium, TextScaled = true, Parent = card })
	local function respond(accept: boolean)
		send({ Op = "Respond", UserId = fromUserId, Accept = accept })
		card:Destroy()
	end
	Components.Button({ Text = "ACCEPT", Color = Theme.Colors.Green, Size = UDim2.new(0.5, -12, 0, 44), Position = UDim2.fromOffset(8, 44), TextSize = Theme.TextSize.Small, Parent = card, OnClick = function()
		respond(true)
	end })
	Components.Button({ Text = "DECLINE", Color = Theme.Colors.Red, Size = UDim2.new(0.5, -12, 0, 44), Position = UDim2.new(0.5, 4, 0, 44), TextSize = Theme.TextSize.Small, Parent = card, OnClick = function()
		respond(false)
	end })
	Components.PopIn(card)
	AudioController.Play("TradeInvite")
	task.delay(expires, function()
		if card.Parent then
			card:Destroy()
		end
	end)
end

---------------------------------------------------------------------------
-- Public
---------------------------------------------------------------------------

function TradeController.Invite(userId: number)
	send({ Op = "Invite", UserId = userId })
end

function TradeController.IsTrading(): boolean
	return state ~= nil
end

function TradeController.Init()
	buildWindow()
	invitesFrame = Create("Frame", {
		Name = "TradeInvites",
		Size = UDim2.fromOffset(420, 320),
		Position = UDim2.new(0.5, 0, 0, 130),
		AnchorPoint = Vector2.new(0.5, 0),
		BackgroundTransparency = 1,
		Parent = UIController.GetOverlay(),
	}, {
		Create("UIListLayout", { Padding = UDim.new(0, 8), HorizontalAlignment = Enum.HorizontalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder }),
	})
end

function TradeController.Start()
	Net.OnClientEvent("TradeEvent", function(payload: any)
		if type(payload) ~= "table" then
			return
		end
		if payload.Op == "Invite" and type(payload.FromUserId) == "number" then
			showInvite(payload.FromUserId, tostring(payload.FromName), tonumber(payload.Expires) or 30)
		elseif payload.Op == "State" then
			state = payload
			local inviteCard = invitesFrame:FindFirstChild(tostring(payload.Them and payload.Them.UserId))
			if inviteCard then
				inviteCard:Destroy()
			end
			openWindow()
			render()
			tickStatus()
		elseif payload.Op == "Closed" then
			closeWindow()
			if type(payload.Reason) == "string" then
				UIController.Notify("Error", payload.Reason, "🤝")
			end
		end
	end)
	ClientState.Observe("Inventory", function()
		if isOpen then
			render()
		end
	end)
	Players.PlayerRemoving:Connect(function(leaving)
		local card = invitesFrame:FindFirstChild(tostring(leaving.UserId))
		if card then
			card:Destroy()
		end
	end)
	task.spawn(function()
		while true do
			task.wait(0.2)
			if isOpen then
				tickStatus()
			end
		end
	end)
end

return TradeController
