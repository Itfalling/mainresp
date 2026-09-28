--[[
	SCRIPT NAME:  HUD
	SCRIPT TYPE:  ModuleScript (client UI)
	WHERE:        StarterPlayerScripts/Client/UI/HUD
	DEPENDENCIES: Client.UI.{Theme, Components}

	Builds the main HUD layout once (spec §83), "Island Pop" style:
		Top-left  PLAYER CARD: round avatar with a level badge, your name and
		          an XP bar
		Top       coin + gem pills
		Right     slot for the island / quest cards (IslandController, QuestController)
		Left      frosted menu DOCK (Bag, Build, Players, Emotes, Settings)
		Bottom    frosted tray + slot for the hotbar (ToolController)
		Touch     touch-only action buttons
	Controllers fill the slots; UIController updates the values.
]]

local Theme = require(script.Parent.Theme)
local Components = require(script.Parent.Components)

local Create = Components.Create

local HUD = {}

export type HUDRefs = {
	Root: Frame,
	TopBar: Frame,
	PlayerCard: Frame,
	PlayerAvatar: ImageLabel,
	PlayerName: TextLabel,
	PlayerLevel: TextLabel,
	PlayerLevelBadge: Frame,
	PlayerXP: Components.ProgressBar,
	PlayerXPText: TextLabel,
	CoinsPill: Frame,
	CoinsLabel: TextLabel,
	GemsPill: Frame,
	GemsLabel: TextLabel,
	Slots: { [string]: Frame },
}

local function frosted(frame: Frame)
	frame.BackgroundColor3 = Theme.Colors.Glass
	frame.BackgroundTransparency = 0.45
	Components.Corner(frame, UDim.new(0, 24))
	local stroke = Components.Stroke(frame, Color3.new(1, 1, 1), 2)
	stroke.Transparency = 0.75
end

local function playerCard(root: Frame)
	local card = Create("Frame", {
		Name = "PlayerCard",
		Size = UDim2.fromOffset(262, 74),
		Position = UDim2.fromOffset(52, 14),
		BackgroundColor3 = Theme.Colors.Panel,
		Parent = root,
	})
	Components.Corner(card, UDim.new(0, 20))
	Components.Stroke(card, Theme.Colors.Outline, 3)
	Components.Gloss(card, 0.4)
	Components.Lip(card, Theme.Colors.PanelDark, 6)

	-- Round avatar overhanging the left edge.
	local avatarRing = Create("Frame", {
		Name = "AvatarRing",
		Size = UDim2.fromOffset(84, 84),
		Position = UDim2.new(0, -42, 0.5, 0),
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundColor3 = Theme.Colors.Level,
		ZIndex = 2,
		Parent = card,
	})
	Components.Corner(avatarRing, UDim.new(1, 0))
	Components.Stroke(avatarRing, Theme.Colors.Outline, 3)
	Components.Gloss(avatarRing)
	local avatar = Create("ImageLabel", {
		Name = "Avatar",
		Size = UDim2.new(1, -12, 1, -12),
		Position = UDim2.fromOffset(6, 6),
		BackgroundColor3 = Theme.Colors.PanelAlt,
		Image = "",
		ZIndex = 3,
		Parent = avatarRing,
	})
	Components.Corner(avatar, UDim.new(1, 0))

	-- Level badge on the avatar.
	local badge = Create("Frame", {
		Name = "LevelBadge",
		Size = UDim2.fromOffset(38, 38),
		Position = UDim2.new(1, 4, 1, 4),
		AnchorPoint = Vector2.new(1, 1),
		BackgroundColor3 = Theme.Colors.Coins,
		ZIndex = 4,
		Parent = avatarRing,
	})
	Components.Corner(badge, UDim.new(1, 0))
	Components.Stroke(badge, Theme.Colors.Outline, 3)
	Components.Gloss(badge)
	local level = Components.Label({
		Name = "Level",
		Text = "1",
		Size = UDim2.fromScale(1, 1),
		TextSize = 20,
		TextColor3 = Theme.Colors.TextLight,
		ZIndex = 5,
		Parent = badge,
	})
	Components.TextStroke(level, Theme.Colors.Outline, 2)

	local name = Components.Label({
		Name = "PlayerName",
		Text = "Player",
		Size = UDim2.new(1, -62, 0, 28),
		Position = UDim2.fromOffset(52, 7),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextSize = 21,
		TextWrapped = false,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = card,
	})
	local xp = Components.ProgressBar({
		Size = UDim2.new(1, -66, 0, 18),
		Position = UDim2.fromOffset(52, 40),
		Color = Theme.Colors.Level,
		Parent = card,
	})
	local xpText = Components.Label({
		Name = "XPText",
		Text = "",
		Size = UDim2.fromScale(1, 1),
		Font = Theme.Fonts.Heavy,
		TextSize = 12,
		TextColor3 = Theme.Colors.TextLight,
		ZIndex = 3,
		Parent = xp.Frame,
	})
	Components.TextStroke(xpText, Theme.Colors.Outline, 1.5)
	return card, avatar, name, level, badge, xp, xpText
end

function HUD.Create(parent: Instance): HUDRefs
	local root = Create("Frame", {
		Name = "HUD",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Parent = parent,
	})

	local card, avatar, name, level, badge, xp, xpText = playerCard(root)

	local topBar = Create("Frame", {
		Name = "TopBar",
		Size = UDim2.fromOffset(440, 60),
		Position = UDim2.new(0.5, 0, 0, 14),
		AnchorPoint = Vector2.new(0.5, 0),
		BackgroundTransparency = 1,
		Parent = root,
	}, {
		Create("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			Padding = UDim.new(0, 34),
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
	})
	local coinsPill, coinsLabel = Components.Pill({ Icon = "🪙", Color = Theme.Colors.Coins, Width = 200, Parent = topBar, LayoutOrder = 1 })
	local gemsPill, gemsLabel = Components.Pill({ Icon = "💎", Color = Theme.Colors.Gems, Width = 160, Parent = topBar, LayoutOrder = 2 })

	local dock = Create("Frame", {
		Name = "LeftSlot",
		Size = UDim2.fromOffset(92, 476),
		Position = UDim2.new(0, 12, 0.5, 30),
		AnchorPoint = Vector2.new(0, 0.5),
		Parent = root,
	}, {
		Create("UIListLayout", {
			Padding = UDim.new(0, 28),
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
		Create("UIPadding", { PaddingBottom = UDim.new(0, 16) }),
	})
	frosted(dock)

	local bottom = Create("Frame", {
		Name = "BottomSlot",
		Size = UDim2.fromOffset(720, 96),
		Position = UDim2.new(0.5, 0, 1, -12),
		AnchorPoint = Vector2.new(0.5, 1),
		BackgroundTransparency = 1,
		Parent = root,
	})
	local tray = Create("Frame", {
		Name = "Tray",
		Size = UDim2.new(1, 16, 0, 62),
		Position = UDim2.new(0.5, 0, 1, 6),
		AnchorPoint = Vector2.new(0.5, 1),
		ZIndex = 0,
		Parent = bottom,
	})
	frosted(tray)

	local slots = {
		Right = Create("Frame", {
			Name = "RightSlot",
			Size = UDim2.fromOffset(256, 560),
			Position = UDim2.new(1, -14, 0, 86),
			AnchorPoint = Vector2.new(1, 0),
			BackgroundTransparency = 1,
			Parent = root,
		}, {
			Create("UIListLayout", {
				Padding = UDim.new(0, 12),
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),
		}),
		Bottom = bottom,
		Left = dock,
		-- Touch-only action buttons (bottom-right, above the jump button).
		Touch = Create("Frame", {
			Name = "TouchSlot",
			Size = UDim2.fromOffset(120, 120),
			Position = UDim2.new(1, -30, 1, -200),
			AnchorPoint = Vector2.new(1, 1),
			BackgroundTransparency = 1,
			Parent = root,
		}),
	}

	return {
		Root = root,
		TopBar = topBar,
		PlayerCard = card,
		PlayerAvatar = avatar,
		PlayerName = name,
		PlayerLevel = level,
		PlayerLevelBadge = badge,
		PlayerXP = xp,
		PlayerXPText = xpText,
		CoinsPill = coinsPill,
		CoinsLabel = coinsLabel,
		GemsPill = gemsPill,
		GemsLabel = gemsLabel,
		Slots = slots,
	}
end

return HUD
