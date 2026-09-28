--[[
	SCRIPT NAME:  PlayersController
	SCRIPT TYPE:  ModuleScript (client controller)
	WHERE:        StarterPlayerScripts/Client/Controllers/PlayersController
	DEPENDENCIES: Shared.Net, Shared.Config.IslandConfig, Shared.Util.Format, UIController, InputController,
	              AudioController, TradeController, Client.UI.{Components, Theme}

	The 👥 PLAYERS window (P key / left menu): everyone in this server with
	their island (name, theme, level, likes) and:
	  VISIT  teleports you to their island (the server checks their visitor
	         setting: Everyone / Friends / Nobody)
	  TRADE  sends a trade invite (TradeController shows the trade window)
	plus a 🏠 GO HOME button while you're visiting someone.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Net = require(Shared:WaitForChild("Net"))
local IslandConfig = require(Shared.Config.IslandConfig)
local Format = require(Shared.Util.Format)

local Client = script.Parent.Parent
local UIController = require(script.Parent.UIController)
local InputController = require(script.Parent.InputController)
local AudioController = require(script.Parent.AudioController)
local TradeController = require(script.Parent.TradeController)
local Components = require(Client.UI.Components)
local Theme = require(Client.UI.Theme)

local Create = Components.Create
local player = Players.LocalPlayer

local PlayersController = {}

local window: Frame
local list: ScrollingFrame
local homeButton: TextButton
local emptyLabel: TextLabel
local rows: { [number]: Frame } = {}
local open = false

local function islandModel(userId: number): Model?
	local folder = workspace:FindFirstChild("Islands")
	local model = folder and folder:FindFirstChild("Island_" .. userId)
	return if model and model:IsA("Model") then model else nil
end

local function makeRow(other: Player): Frame
	local row = Create("Frame", { Name = other.Name, Size = UDim2.new(1, -10, 0, 78), BackgroundColor3 = Theme.Colors.PanelAlt, Parent = list })
	Components.Corner(row, Theme.SmallCorner)
	Components.Stroke(row, Theme.Colors.Outline, 2)
	local avatar = Create("ImageLabel", {
		Name = "Avatar",
		Size = UDim2.fromOffset(62, 62),
		Position = UDim2.fromOffset(8, 8),
		BackgroundColor3 = Theme.Colors.PanelDark,
		Image = "",
		Parent = row,
	})
	Components.Corner(avatar, UDim.new(1, 0))
	Components.Stroke(avatar, Theme.Colors.Outline, 2)
	task.spawn(function()
		local ok, image = pcall(Players.GetUserThumbnailAsync, Players, other.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
		if ok and avatar.Parent then
			avatar.Image = image
		end
	end)
	Components.Label({ Name = "PlayerName", Size = UDim2.new(1, -300, 0, 26), Position = UDim2.fromOffset(80, 10), TextXAlignment = Enum.TextXAlignment.Left, TextSize = Theme.TextSize.Medium, TextScaled = true, Text = other.DisplayName, Parent = row })
	Components.Label({ Name = "Island", Size = UDim2.new(1, -300, 0, 34), Position = UDim2.fromOffset(80, 36), TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, Font = Theme.Fonts.Bold, TextSize = Theme.TextSize.Small, TextColor3 = Theme.Colors.TextMuted, Text = "", Parent = row })
	local userId = other.UserId
	Components.Button({ Name = "Visit", Text = "🏝️ VISIT", Color = Theme.Colors.Teal, Size = UDim2.fromOffset(104, 44), Position = UDim2.new(1, -228, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5), TextSize = Theme.TextSize.Small, Parent = row, OnClick = function()
		Net.FireServer("VisitRequest", userId)
		PlayersController.Close()
	end })
	Components.Button({ Name = "Trade", Text = "🤝 TRADE", Color = Theme.Colors.Orange, Size = UDim2.fromOffset(104, 44), Position = UDim2.new(1, -116, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5), TextSize = Theme.TextSize.Small, Parent = row, OnClick = function()
		TradeController.Invite(userId)
		PlayersController.Close()
	end })
	return row
end

local function refresh()
	if not open then
		return
	end
	local seen = {}
	local order = 0
	for _, other in Players:GetPlayers() do
		if other == player then
			continue
		end
		order += 1
		seen[other.UserId] = true
		local row = rows[other.UserId] or makeRow(other)
		rows[other.UserId] = row
		row.LayoutOrder = order
		local model = islandModel(other.UserId)
		local info = row:FindFirstChild("Island") :: TextLabel
		if model then
			local theme = IslandConfig.Themes[model:GetAttribute("Theme")] or IslandConfig.Themes[IslandConfig.DefaultTheme]
			local mode = tostring(model:GetAttribute("VisitorMode") or "Everyone")
			info.Text = ("%s %s · Lv %s · ❤️ %s%s"):format(
				theme.Icon,
				tostring(model:GetAttribute("IslandName") or "Island"),
				tostring(model:GetAttribute("IslandLevel") or 1),
				Format.Abbreviate(tonumber(model:GetAttribute("Likes")) or 0),
				if mode == "Everyone" then "" elseif mode == "Friends" then " · 💛 friends only" else " · 🔒 closed"
			)
		else
			info.Text = "Still creating their island…"
		end
	end
	for userId, row in rows do
		if not seen[userId] then
			row:Destroy()
			rows[userId] = nil
		end
	end
	emptyLabel.Visible = order == 0
	local location = player:GetAttribute("OnIsland")
	homeButton.Visible = type(location) == "number" and location ~= 0 and location ~= player.UserId
end

function PlayersController.Open()
	if open or UIController.IsAnyModalOpen() then
		return
	end
	open = true
	window.Visible = true
	UIController.SetModalOpen("Players", true)
	Components.PopIn(window)
	AudioController.Play("UIOpen")
	refresh()
end

function PlayersController.Close()
	if not open then
		return
	end
	open = false
	window.Visible = false
	UIController.SetModalOpen("Players", false)
	AudioController.Play("UIClose")
end

function PlayersController.Toggle()
	if open then
		PlayersController.Close()
	else
		PlayersController.Open()
	end
end

function PlayersController.Init()
	local content, closeButton
	window, content, closeButton = Components.Panel({ Title = "👥 Players & Islands", Size = UDim2.fromOffset(600, 500), Parent = UIController.GetModalLayer(), Color = Theme.Colors.Purple })
	window.Visible = false
	closeButton.Activated:Connect(PlayersController.Close)

	homeButton = Components.Button({ Text = "🏠 GO HOME", Color = Theme.Colors.Green, Size = UDim2.new(1, 0, 0, 44), Parent = content, OnClick = function()
		Net.FireServer("VisitRequest", 0)
		PlayersController.Close()
	end })
	homeButton.Visible = false
	list = Create("ScrollingFrame", {
		Size = UDim2.new(1, 0, 1, -52),
		Position = UDim2.fromOffset(0, 52),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 6,
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Parent = content,
	}, {
		Create("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder }),
		Create("UIPadding", { PaddingTop = UDim.new(0, 4), PaddingLeft = UDim.new(0, 4) }),
	})
	emptyLabel = Components.Label({
		Text = "You're the only one here right now.\nInvite friends to visit your island!",
		Size = UDim2.new(1, -10, 0, 80),
		Font = Theme.Fonts.Bold,
		TextSize = Theme.TextSize.Medium,
		TextColor3 = Theme.Colors.TextMuted,
		LayoutOrder = 0,
		Parent = list,
	})

	Components.IconButton({
		Icon = "👥",
		Caption = "Players",
		Color = Theme.Colors.Purple,
		Parent = UIController.GetSlot("Left"),
		LayoutOrder = 3,
		OnClick = PlayersController.Toggle,
	})
end

function PlayersController.Start()
	InputController.On("PlayersMenu", PlayersController.Toggle)
	InputController.On("Cancel", PlayersController.Close)
	Players.PlayerAdded:Connect(refresh)
	Players.PlayerRemoving:Connect(function()
		task.defer(refresh)
	end)
	player:GetAttributeChangedSignal("OnIsland"):Connect(refresh)
	task.spawn(function()
		while true do
			task.wait(2)
			refresh()
		end
	end)
end

return PlayersController
