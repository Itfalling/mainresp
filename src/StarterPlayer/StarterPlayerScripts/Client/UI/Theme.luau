--[[
	SCRIPT NAME:  Theme
	SCRIPT TYPE:  ModuleScript (client UI)
	WHERE:        StarterPlayerScripts/Client/UI/Theme
	DEPENDENCIES: none

	The single source of UI colours, fonts and sizes. A warm, friendly island
	look: creamy panels with soft drop shadows, chunky rounded buttons with a
	light-to-dark gradient, bright accent colours and crisp Builder Sans text
	(Fredoka One for titles).
]]

local Theme = {}

Theme.Colors = {
	Panel = Color3.fromRGB(255, 251, 242),
	PanelAlt = Color3.fromRGB(246, 238, 222),
	PanelDark = Color3.fromRGB(226, 212, 186),
	Header = Color3.fromRGB(52, 150, 230),
	HeaderDark = Color3.fromRGB(36, 112, 196),
	Outline = Color3.fromRGB(62, 44, 30),
	Text = Color3.fromRGB(58, 40, 26),
	TextMuted = Color3.fromRGB(138, 112, 88),
	TextLight = Color3.fromRGB(255, 255, 255),
	Coins = Color3.fromRGB(255, 196, 40),
	Gems = Color3.fromRGB(80, 200, 255),
	Level = Color3.fromRGB(110, 205, 85),
	Blue = Color3.fromRGB(64, 156, 255),
	Green = Color3.fromRGB(76, 196, 96),
	Red = Color3.fromRGB(236, 86, 86),
	Orange = Color3.fromRGB(255, 150, 60),
	Purple = Color3.fromRGB(160, 110, 250),
	Pink = Color3.fromRGB(255, 120, 170),
	Teal = Color3.fromRGB(46, 190, 180),
	Shadow = Color3.fromRGB(0, 0, 0),
	Glass = Color3.fromRGB(20, 26, 40),
}

Theme.Fonts = {
	Title = Enum.Font.FredokaOne,
	Body = Enum.Font.BuilderSansMedium,
	Bold = Enum.Font.BuilderSansBold,
	Heavy = Enum.Font.BuilderSansExtraBold,
}

Theme.Corner = UDim.new(0, 16)
Theme.SmallCorner = UDim.new(0, 11)
Theme.StrokeThickness = 3

Theme.TextSize = {
	Huge = 44,
	Title = 26,
	Large = 22,
	Medium = 18,
	Small = 15,
	Tiny = 12,
}

-- Design resolution: the whole UI is built at this size and scaled by UIScale.
Theme.DesignSize = Vector2.new(1280, 720)

-- Brighter / darker versions of a colour (for gradients and hover states).
function Theme.Lighten(color: Color3, amount: number): Color3
	return color:Lerp(Color3.new(1, 1, 1), amount)
end

function Theme.Darken(color: Color3, amount: number): Color3
	return color:Lerp(Color3.new(0, 0, 0), amount)
end

return Theme
