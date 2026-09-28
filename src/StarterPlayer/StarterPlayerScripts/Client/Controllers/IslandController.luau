--[[
	SCRIPT NAME:  IslandController
	SCRIPT TYPE:  ModuleScript (client controller)
	WHERE:        StarterPlayerScripts/Client/Controllers/IslandController
	DEPENDENCIES: Shared.Net, Shared.Config.{IslandConfig, ProgressionConfig}, Shared.Util.{IslandGen, Format},
	              Client.ClientState, UIController, InputController, BuildController,
	              Client.UI.{Components, Theme}

	The right-hand ISLAND CARD plus the island windows.

	  At home     island name + theme, level / XP, land used (chunks / max),
	              the next chunk's price and two buttons:
	                🗺️ EXPAND   opens build mode on the Expand tab
	                ⚙️ ISLAND   opens the settings window
	  Visiting    "Visiting <owner>'s island", its level and likes, and
	                ❤️ LIKE     once a day per island
	                🏠 HOME     teleports you back

	SETTINGS window (also opened by clicking your island sign)
	  rename · who may visit (Everyone / Friends / Nobody) · helpers (players
	  in this server you trust to gather, farm and build on your island).
	INFO window (clicking someone else's sign) shows their island + LIKE.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Net = require(Shared:WaitForChild("Net"))
local IslandConfig = require(Shared.Config.IslandConfig)
local ProgressionConfig = require(Shared.Config.ProgressionConfig)
local IslandGen = require(Shared.Util.IslandGen)
local Format = require(Shared.Util.Format)

local Client = script.Parent.Parent
local ClientState = require(Client.ClientState)
local UIController = require(script.Parent.UIController)
local InputController = require(script.Parent.InputController)
local BuildController = require(script.Parent.BuildController)
local Components = require(Client.UI.Components)
local Theme = require(Client.UI.Theme)

local Create = Components.Create
local player = Players.LocalPlayer

local PANEL_HEIGHT = 238

local IslandController = {}

type Refs = {
	Card: Frame,
	Header: Frame,
	HeaderLabel: TextLabel,
	Body: Frame,
	Name: TextLabel,
	Title: TextLabel,
	XPBar: Components.ProgressBar,
	XPText: TextLabel,
	Land: TextLabel,
	LandBar: Components.ProgressBar,
	LeftButton: TextButton,
	RightButton: TextButton,
	Toggle: TextButton,
}

local refs: Refs
local collapsed = false
local welcomed = false
local visitingUserId: number? = nil

-- Settings window
local settingsWindow: Frame
local nameBox: TextBox
local visitorButtons: { [string]: TextButton } = {}
local helperList: ScrollingFrame
local helperRows: { [number]: Frame } = {}

-- Info window
local infoWindow: Frame
local infoRefs: { Title: TextLabel, Body: TextLabel, Like: TextButton, OwnerUserId: number }

local function islandModel(userId: number): Model?
	local folder = workspace:FindFirstChild("Islands")
	local model = folder and folder:FindFirstChild("Island_" .. userId)
	return if model and model:IsA("Model") then model else nil
end

local function themeOf(themeId: any): any
	return IslandConfig.Themes[themeId] or IslandConfig.Themes[IslandConfig.DefaultTheme]
end

---------------------------------------------------------------------------
-- Card
---------------------------------------------------------------------------

local function refreshHome()
	local island = ClientState.Get("Island") or {}
	local level = island.Level or 1
	local xp = island.XP or 0
	local needed = ProgressionConfig.IslandXPForLevel(level)
	local theme = themeOf(island.Theme)
	refs.HeaderLabel.Text = theme.Icon .. " MY ISLAND"
	refs.Header.BackgroundColor3 = theme.Color
	refs.Name.Text = island.Name or "My Island"
	refs.Title.Text = ("%s · %s · Lv %d"):format(theme.DisplayName, ProgressionConfig.GetIslandTitle(level), level)
	refs.XPBar.Frame.Visible = true
	refs.XPText.Visible = true
	refs.XPBar.SetProgress(xp / needed, true)
	refs.XPText.Text = ("%s / %s XP"):format(Format.Commas(xp), Format.Commas(needed))
	local count = IslandGen.CountChunks(island.Chunks or {})
	local maxChunks = IslandGen.MaxChunks(level)
	local cost = IslandGen.ExpansionCost(count)
	refs.LandBar.Frame.Visible = true
	refs.LandBar.SetProgress(count / math.max(1, maxChunks), true)
	if count >= maxChunks then
		refs.Land.Text = ("🗺️ Land %d / %d · level up for more"):format(count, maxChunks)
	else
		refs.Land.Text = ("🗺️ Land %d / %d · next %s 🪙"):format(count, maxChunks, Format.Abbreviate(cost))
	end
	refs.LeftButton.Text = "🗺️ EXPAND"
	Components.SetButtonColor(refs.LeftButton, if (ClientState.Get("Coins") or 0) >= cost and count < maxChunks then Theme.Colors.Green else Theme.Colors.Teal)
	refs.RightButton.Text = "⚙️ ISLAND"
	Components.SetButtonColor(refs.RightButton, Theme.Colors.Blue)
end

local function refreshVisiting(userId: number)
	local model = islandModel(userId)
	local owner = Players:GetPlayerByUserId(userId)
	local ownerName = (model and model:GetAttribute("OwnerName")) or (owner and owner.DisplayName) or "Someone"
	local theme = themeOf(model and model:GetAttribute("Theme"))
	refs.HeaderLabel.Text = "👋 VISITING"
	refs.Header.BackgroundColor3 = theme.Color
	refs.Name.Text = tostring((model and model:GetAttribute("IslandName")) or (ownerName .. "'s Island"))
	refs.Title.Text = ("%s's %s island · Lv %s"):format(ownerName, theme.DisplayName, tostring(model and model:GetAttribute("IslandLevel") or 1))
	refs.XPBar.Frame.Visible = false
	refs.XPText.Visible = true
	refs.XPText.Text = ("❤️ %s likes · 🗺️ %s chunks"):format(Format.Abbreviate(tonumber(model and model:GetAttribute("Likes")) or 0), tostring(model and model:GetAttribute("Chunks") or "?"))
	local helpers = string.split(tostring(model and model:GetAttribute("Helpers") or ""), ",")
	local helping = table.find(helpers, tostring(player.UserId)) ~= nil
	refs.LandBar.Frame.Visible = false
	refs.Land.Text = if helping then "🤝 You're a helper here!" else "Look around, fish and shop!"
	refs.LeftButton.Text = "❤️ LIKE"
	Components.SetButtonColor(refs.LeftButton, Theme.Colors.Pink)
	refs.RightButton.Text = "🏠 HOME"
	Components.SetButtonColor(refs.RightButton, Theme.Colors.Green)
end

local function refresh()
	if not ClientState.IsReady() or not refs then
		return
	end
	if visitingUserId then
		refreshVisiting(visitingUserId)
	else
		refreshHome()
	end
end

local function buildCard(parent: Frame): Refs
	local card = Create("Frame", {
		Name = "IslandPanel",
		Size = UDim2.new(1, 0, 0, PANEL_HEIGHT),
		BackgroundColor3 = Theme.Colors.Panel,
		LayoutOrder = 1,
		Parent = parent,
	})
	Components.Corner(card)
	Components.Stroke(card)
	Components.Gradient(card, Color3.new(1, 1, 1), Theme.Colors.PanelAlt)

	local header = Create("Frame", { Name = "Header", Size = UDim2.new(1, 0, 0, 40), BackgroundColor3 = Theme.Colors.Level, Parent = card })
	Components.Corner(header)
	Components.Gradient(header, Color3.new(1, 1, 1), Color3.fromRGB(200, 200, 200))
	local headerLabel = Components.Label({
		Text = "🏝️ MY ISLAND",
		Size = UDim2.new(1, -50, 1, 0),
		Position = UDim2.fromOffset(12, 0),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = Theme.Colors.TextLight,
		TextSize = Theme.TextSize.Medium,
		Parent = header,
	})
	Components.TextStroke(headerLabel)
	local toggle = Components.Button({
		Name = "Toggle",
		Text = "–",
		Color = Theme.Colors.Panel,
		TextColor = Theme.Colors.Text,
		Size = UDim2.fromOffset(30, 30),
		Position = UDim2.new(1, -5, 0.5, 0),
		AnchorPoint = Vector2.new(1, 0.5),
		TextSize = Theme.TextSize.Large,
		Parent = header,
		Flat = true,
	})
	Components.Corner(toggle, UDim.new(1, 0))

	local body = Create("Frame", { Name = "Body", Size = UDim2.new(1, -20, 1, -50), Position = UDim2.fromOffset(10, 46), BackgroundTransparency = 1, Parent = card })
	local name = Components.Label({ Size = UDim2.new(1, 0, 0, 26), TextScaled = true, Text = "", Parent = body })
	local title = Components.Label({ Size = UDim2.new(1, 0, 0, 18), Position = UDim2.fromOffset(0, 26), Font = Theme.Fonts.Bold, TextSize = Theme.TextSize.Small, TextColor3 = Theme.Colors.TextMuted, TextScaled = true, Text = "", Parent = body })
	local xpBar = Components.ProgressBar({ Size = UDim2.new(1, 0, 0, 12), Position = UDim2.fromOffset(0, 50), Color = Theme.Colors.Level, Parent = body })
	local xpText = Components.Label({ Size = UDim2.new(1, 0, 0, 16), Position = UDim2.fromOffset(0, 64), Font = Theme.Fonts.Bold, TextSize = 12, TextColor3 = Theme.Colors.TextMuted, Text = "", Parent = body })
	Create("Frame", { Size = UDim2.new(1, 0, 0, 2), Position = UDim2.fromOffset(0, 86), BackgroundColor3 = Theme.Colors.PanelDark, BorderSizePixel = 0, Parent = body })
	local land = Components.Label({ Size = UDim2.new(1, 0, 0, 20), Position = UDim2.fromOffset(0, 92), Font = Theme.Fonts.Bold, TextSize = Theme.TextSize.Small, TextScaled = true, Text = "", Parent = body })
	local landBar = Components.ProgressBar({ Size = UDim2.new(1, 0, 0, 10), Position = UDim2.fromOffset(0, 116), Color = Theme.Colors.Teal, Parent = body })

	local leftButton = Components.Button({ Text = "🗺️ EXPAND", Color = Theme.Colors.Teal, Size = UDim2.new(0.5, -4, 0, 42), Position = UDim2.fromOffset(0, 136), TextSize = Theme.TextSize.Small, Parent = body, OnClick = function()
		if visitingUserId then
			Net.FireServer("LikeRequest", visitingUserId)
		else
			BuildController.Open("Expand")
		end
	end })
	local rightButton = Components.Button({ Text = "⚙️ ISLAND", Color = Theme.Colors.Blue, Size = UDim2.new(0.5, -4, 0, 42), Position = UDim2.new(0.5, 4, 0, 136), TextSize = Theme.TextSize.Small, Parent = body, OnClick = function()
		if visitingUserId then
			Net.FireServer("VisitRequest", 0)
		else
			IslandController.OpenSettings()
		end
	end })

	return {
		Card = card,
		Header = header,
		HeaderLabel = headerLabel,
		Body = body,
		Name = name,
		Title = title,
		XPBar = xpBar,
		XPText = xpText,
		Land = land,
		LandBar = landBar,
		LeftButton = leftButton,
		RightButton = rightButton,
		Toggle = toggle,
	}
end

local function setCollapsed(value: boolean)
	collapsed = value
	refs.Body.Visible = not collapsed
	refs.Card.Size = if collapsed then UDim2.new(1, 0, 0, 40) else UDim2.new(1, 0, 0, PANEL_HEIGHT)
	refs.Toggle.Text = if collapsed then "+" else "–"
end

---------------------------------------------------------------------------
-- Settings window
---------------------------------------------------------------------------

local function closeWindow(window: Frame, modal: string)
	if window.Visible then
		window.Visible = false
		UIController.SetModalOpen(modal, false)
	end
end

local function refreshSettings()
	if not settingsWindow or not settingsWindow.Visible then
		return
	end
	local island = ClientState.Get("Island") or {}
	local access = island.Access or {}
	local mode = access.Visitors or "Everyone"
	for id, button in visitorButtons do
		Components.SetButtonColor(button, if id == mode then Theme.Colors.Coins else Theme.Colors.PanelAlt)
	end
	if not nameBox:IsFocused() then
		nameBox.Text = island.Name or ""
	end
	local helpers = access.Helpers or {}
	local seen = {}
	local order = 0
	for _, other in Players:GetPlayers() do
		if other == player then
			continue
		end
		order += 1
		seen[other.UserId] = true
		local row = helperRows[other.UserId]
		if not row then
			row = Create("Frame", { Size = UDim2.new(1, -8, 0, 44), BackgroundColor3 = Theme.Colors.PanelAlt, Parent = helperList })
			Components.Corner(row, Theme.SmallCorner)
			Components.Stroke(row, Theme.Colors.Outline, 2)
			Components.Label({ Name = "PlayerName", Size = UDim2.new(1, -140, 1, 0), Position = UDim2.fromOffset(12, 0), TextXAlignment = Enum.TextXAlignment.Left, TextSize = Theme.TextSize.Medium, Text = other.DisplayName, Parent = row })
			local userId = other.UserId
			local toggleButton = Components.Button({ Name = "HelperToggle", Text = "", Size = UDim2.fromOffset(120, 34), Position = UDim2.new(1, -6, 0.5, 0), AnchorPoint = Vector2.new(1, 0.5), TextSize = Theme.TextSize.Small, Parent = row, Flat = true, OnClick = function()
				local current = ((ClientState.Get("Island", "Access") or {}).Helpers or {})[tostring(userId)] == true
				Net.FireServer("IslandSettingsRequest", { Helper = userId, Allowed = not current })
			end })
			toggleButton:SetAttribute("UserId", userId)
			helperRows[other.UserId] = row
		end
		row.LayoutOrder = order
		local isHelper = helpers[tostring(other.UserId)] == true
		local toggleButton = row:FindFirstChild("HelperToggle") :: TextButton
		toggleButton.Text = if isHelper then "🤝 HELPER" else "+ MAKE HELPER"
		Components.SetButtonColor(toggleButton, if isHelper then Theme.Colors.Green else Theme.Colors.Blue)
	end
	for userId, row in helperRows do
		if not seen[userId] then
			row:Destroy()
			helperRows[userId] = nil
		end
	end
	local empty = helperList:FindFirstChild("Empty") :: TextLabel?
	if empty then
		empty.Visible = order == 0
	end
end

local function buildSettings()
	local window, content, closeButton = Components.Panel({ Title = "⚙️ Island Settings", Size = UDim2.fromOffset(520, 520), Parent = UIController.GetModalLayer(), Color = Theme.Colors.Teal })
	window.Visible = false
	settingsWindow = window
	closeButton.Activated:Connect(function()
		closeWindow(window, "IslandSettings")
	end)

	Components.Label({ Text = "Island name", Size = UDim2.new(1, 0, 0, 22), TextXAlignment = Enum.TextXAlignment.Left, TextSize = Theme.TextSize.Medium, Parent = content })
	nameBox = Create("TextBox", {
		Size = UDim2.new(1, -130, 0, 42),
		Position = UDim2.fromOffset(0, 26),
		BackgroundColor3 = Color3.new(1, 1, 1),
		Font = Theme.Fonts.Bold,
		TextSize = Theme.TextSize.Medium,
		TextColor3 = Theme.Colors.Text,
		PlaceholderText = "Name your island…",
		ClearTextOnFocus = false,
		Text = "",
		Parent = content,
	})
	Components.Corner(nameBox, Theme.SmallCorner)
	Components.Stroke(nameBox, Theme.Colors.Outline, 2)
	nameBox:GetPropertyChangedSignal("Text"):Connect(function()
		if #nameBox.Text > IslandConfig.NameMaxLength then
			nameBox.Text = string.sub(nameBox.Text, 1, IslandConfig.NameMaxLength)
		end
	end)
	Components.Button({ Text = "RENAME", Color = Theme.Colors.Green, Size = UDim2.fromOffset(120, 42), Position = UDim2.new(1, 0, 0, 26), AnchorPoint = Vector2.new(1, 0), TextSize = Theme.TextSize.Small, Parent = content, OnClick = function()
		Net.FireServer("RenameIslandRequest", nameBox.Text)
	end })

	Components.Label({ Text = "Who can visit?", Size = UDim2.new(1, 0, 0, 22), Position = UDim2.fromOffset(0, 84), TextXAlignment = Enum.TextXAlignment.Left, TextSize = Theme.TextSize.Medium, Parent = content })
	local icons = { Everyone = "🌍", Friends = "💛", Nobody = "🔒" }
	for index, mode in IslandConfig.VisitorModes do
		visitorButtons[mode] = Components.Button({
			Text = (icons[mode] or "") .. " " .. mode,
			Color = Theme.Colors.PanelAlt,
			TextColor = Theme.Colors.Text,
			Size = UDim2.new(1 / 3, -6, 0, 40),
			Position = UDim2.new((index - 1) / 3, 3, 0, 110),
			TextSize = Theme.TextSize.Small,
			Parent = content,
			Flat = true,
			OnClick = function()
				Net.FireServer("IslandSettingsRequest", { Visitors = mode })
			end,
		})
	end

	Components.Label({ Text = "Helpers (can gather, farm, feed & hammer on your island)", Size = UDim2.new(1, 0, 0, 22), Position = UDim2.fromOffset(0, 166), TextXAlignment = Enum.TextXAlignment.Left, Font = Theme.Fonts.Bold, TextSize = Theme.TextSize.Small, TextColor3 = Theme.Colors.TextMuted, Parent = content })
	helperList = Create("ScrollingFrame", {
		Size = UDim2.new(1, 0, 1, -196),
		Position = UDim2.fromOffset(0, 194),
		BackgroundColor3 = Theme.Colors.PanelDark,
		BackgroundTransparency = 0.6,
		BorderSizePixel = 0,
		ScrollBarThickness = 6,
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Parent = content,
	}, {
		Create("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }),
		Create("UIPadding", { PaddingTop = UDim.new(0, 6), PaddingLeft = UDim.new(0, 6) }),
	})
	Components.Corner(helperList, Theme.SmallCorner)
	Components.Label({ Name = "Empty", Text = "Nobody else is in this server right now.", Size = UDim2.new(1, -8, 0, 40), Font = Theme.Fonts.Bold, TextSize = Theme.TextSize.Small, TextColor3 = Theme.Colors.TextMuted, Parent = helperList })
end

function IslandController.OpenSettings()
	if UIController.IsAnyModalOpen() or visitingUserId then
		return
	end
	settingsWindow.Visible = true
	UIController.SetModalOpen("IslandSettings", true)
	Components.PopIn(settingsWindow)
	refreshSettings()
end

---------------------------------------------------------------------------
-- Info window (someone else's island)
---------------------------------------------------------------------------

local function buildInfo()
	local window, content, closeButton = Components.Panel({ Title = "🏝️ Island", Size = UDim2.fromOffset(420, 300), Parent = UIController.GetModalLayer(), Color = Theme.Colors.Pink })
	window.Visible = false
	infoWindow = window
	closeButton.Activated:Connect(function()
		closeWindow(window, "IslandInfo")
	end)
	local title = Components.Label({ Size = UDim2.new(1, 0, 0, 34), TextSize = Theme.TextSize.Title, TextScaled = true, Text = "", Parent = content })
	local body = Components.Label({ Size = UDim2.new(1, 0, 0, 100), Position = UDim2.fromOffset(0, 40), Font = Theme.Fonts.Bold, TextSize = Theme.TextSize.Medium, TextColor3 = Theme.Colors.TextMuted, TextYAlignment = Enum.TextYAlignment.Top, Text = "", Parent = content })
	local like = Components.Button({ Text = "❤️ LIKE THIS ISLAND", Color = Theme.Colors.Pink, Size = UDim2.new(1, 0, 0, 50), Position = UDim2.new(0, 0, 1, -54), Parent = content, OnClick = function()
		Net.FireServer("LikeRequest", infoRefs.OwnerUserId)
		closeWindow(infoWindow, "IslandInfo")
	end })
	infoRefs = { Title = title, Body = body, Like = like, OwnerUserId = 0 }
end

local function openInfo(payload: any)
	if UIController.IsAnyModalOpen() or type(payload.OwnerUserId) ~= "number" then
		return
	end
	local theme = themeOf(payload.Theme)
	infoRefs.OwnerUserId = payload.OwnerUserId
	infoRefs.Title.Text = tostring(payload.Name or "Island")
	infoRefs.Body.Text = ("Owner: %s\n%s %s island · Level %s\n🗺️ %s land chunks · ❤️ %s likes"):format(
		tostring(payload.OwnerName),
		theme.Icon,
		theme.DisplayName,
		tostring(payload.Level),
		tostring(payload.Chunks),
		Format.Abbreviate(tonumber(payload.Likes) or 0)
	)
	infoWindow.Visible = true
	UIController.SetModalOpen("IslandInfo", true)
	Components.PopIn(infoWindow)
end

---------------------------------------------------------------------------
-- Visiting
---------------------------------------------------------------------------

local function onLocationChanged()
	local value = player:GetAttribute("OnIsland")
	local previous = visitingUserId
	visitingUserId = if type(value) == "number" and value ~= 0 and value ~= player.UserId then value else nil
	if visitingUserId and visitingUserId ~= previous then
		closeWindow(settingsWindow, "IslandSettings")
		local model = islandModel(visitingUserId)
		local name = model and model:GetAttribute("IslandName")
		UIController.Banner("Welcome to " .. tostring(name or "their island") .. "!", "Be nice — click things to look around", "Reward")
	end
	refresh()
end

function IslandController.IsVisiting(): number?
	return visitingUserId
end

function IslandController.Init()
	refs = buildCard(UIController.GetSlot("Right"))
	refs.Toggle.Activated:Connect(function()
		setCollapsed(not collapsed)
	end)
	-- Phones have little room: start collapsed on touch devices.
	if InputController.IsTouch() then
		setCollapsed(true)
	end
	buildSettings()
	buildInfo()
end

function IslandController.Start()
	for _, key in { "Island", "Coins" } do
		ClientState.Observe(key, refresh)
	end
	ClientState.Observe("Island", refreshSettings)
	Players.PlayerAdded:Connect(refreshSettings)
	Players.PlayerRemoving:Connect(function()
		task.defer(refreshSettings)
	end)
	player:GetAttributeChangedSignal("OnIsland"):Connect(onLocationChanged)
	onLocationChanged()
	-- The visited island's attributes (likes, level) change live.
	task.spawn(function()
		while true do
			task.wait(2)
			if visitingUserId then
				refresh()
			end
		end
	end)

	Net.OnClientEvent("OpenUI", function(payload: any)
		if type(payload) ~= "table" then
			return
		end
		if payload.Screen == "IslandSettings" then
			IslandController.OpenSettings()
		elseif payload.Screen == "IslandInfo" then
			openInfo(payload)
		end
	end)
	InputController.On("Cancel", function()
		closeWindow(settingsWindow, "IslandSettings")
		closeWindow(infoWindow, "IslandInfo")
	end)

	ClientState.Observe("Island", function(island)
		if welcomed or type(island) ~= "table" or island.Created ~= true or not island.Name or island.Name == "" then
			return
		end
		welcomed = true
		task.delay(1.5, function()
			UIController.Banner("Welcome to " .. island.Name .. "!", "Your island adventure begins", "Reward")
		end)
	end)
end

return IslandController
