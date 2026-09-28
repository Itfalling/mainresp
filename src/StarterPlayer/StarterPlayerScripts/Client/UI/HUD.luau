--[[
	SCRIPT NAME:  HUD
	SCRIPT TYPE:  ModuleScript (client UI)
	WHERE:        StarterPlayerScripts/Client/UI/HUD
	DEPENDENCIES: Client.UI.{Theme, Components}

	Builds the main HUD layout once (spec §83):
		Top     island level, coins, gems
		Right   slot for the island/quest panel (IslandController)
		Bottom  slot for the tool hotbar (ToolController)
		Left    slot for the menu buttons (Bag, Build, Players, Emotes, Settings)
	Controllers fill the slots; UIController updates the values.
]]

local Theme = require(script.Parent.Theme)
local Components = require(script.Parent.Components)

local Create = Components.Create

local HUD = {}

export type HUDRefs = {
	Root: Frame,
	TopBar: Frame,
	IslandPill: Frame,
	IslandLabel: TextLabel,
	IslandXP: Components.ProgressBar,
	CoinsPill: Frame,
	CoinsLabel: TextLabel,
	GemsPill: Frame,
	GemsLabel: TextLabel,
	Slots: { [string]: Frame },
}

function HUD.Create(parent: Instance): HUDRefs
	local root = Create("Frame", {
		Name = "HUD",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Parent = parent,
	})

	local topBar = Create("Frame", {
		Name = "TopBar",
		Size = UDim2.fromOffset(620, 60),
		Position = UDim2.new(0.5, 0, 0, 10),
		AnchorPoint = Vector2.new(0.5, 0),
		BackgroundTransparency = 1,
		Parent = root,
	}, {
		Create("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			Padding = UDim.new(0, 30),
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
	})

	local islandPill, islandLabel = Components.Pill({ Icon = "🏝️", Color = Theme.Colors.Level, Width = 170, Parent = topBar, LayoutOrder = 1 })
	islandLabel.Size = UDim2.new(1, -56, 0, 28)
	islandLabel.Position = UDim2.fromOffset(46, 2)
	islandLabel.TextSize = Theme.TextSize.Medium
	local islandXP = Components.ProgressBar({
		Size = UDim2.new(1, -60, 0, 8),
		Position = UDim2.fromOffset(46, 30),
		Color = Theme.Colors.Level,
		Parent = islandPill,
	})

	local coinsPill, coinsLabel = Components.Pill({ Icon = "🪙", Color = Theme.Colors.Coins, Width = 170, Parent = topBar, LayoutOrder = 2 })
	local gemsPill, gemsLabel = Components.Pill({ Icon = "💎", Color = Theme.Colors.Gems, Width = 130, Parent = topBar, LayoutOrder = 3 })

	local slots = {
		Right = Create("Frame", {
			Name = "RightSlot",
			Size = UDim2.fromOffset(250, 540),
			Position = UDim2.new(1, -12, 0, 80),
			AnchorPoint = Vector2.new(1, 0),
			BackgroundTransparency = 1,
			Parent = root,
		}, {
			Create("UIListLayout", {
				Padding = UDim.new(0, 10),
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),
		}),
		Bottom = Create("Frame", {
			Name = "BottomSlot",
			Size = UDim2.fromOffset(720, 96),
			Position = UDim2.new(0.5, 0, 1, -12),
			AnchorPoint = Vector2.new(0.5, 1),
			BackgroundTransparency = 1,
			Parent = root,
		}),
		Left = Create("Frame", {
			Name = "LeftSlot",
			Size = UDim2.fromOffset(84, 480),
			Position = UDim2.new(0, 14, 0.5, 10),
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundTransparency = 1,
			Parent = root,
		}, {
			Create("UIListLayout", {
				Padding = UDim.new(0, 24),
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),
		}),
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
		IslandPill = islandPill,
		IslandLabel = islandLabel,
		IslandXP = islandXP,
		CoinsPill = coinsPill,
		CoinsLabel = coinsLabel,
		GemsPill = gemsPill,
		GemsLabel = gemsLabel,
		Slots = slots,
	}
end

return HUD
