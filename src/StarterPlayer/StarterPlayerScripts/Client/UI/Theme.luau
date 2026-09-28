--[[
	SCRIPT NAME:  Theme
	SCRIPT TYPE:  ModuleScript (client UI)
	WHERE:        StarterPlayerScripts/Client/UI/Theme
	DEPENDENCIES: none

	The single source of UI colours, fonts and sizes ("Island Pop" style):
	warm cream paper panels with a chocolate outline, candy-bright accent
	colours with glossy highlights and a 3D lip, soft layered drop shadows,
	Fredoka One titles and Builder Sans text.
]]

local Theme = {}

Theme.Colors = {
	-- Paper
	Panel = Color3.fromRGB(255, 251, 240),
	PanelAlt = Color3.fromRGB(248, 239, 220),
	PanelDark = Color3.fromRGB(230, 214, 186),
	Inset = Color3.fromRGB(239, 227, 203), -- recessed wells (lists, grids)
	-- Chrome
	Header = Color3.fromRGB(58, 162, 242),
	HeaderDark = Color3.fromRGB(36, 116, 200),
	Outline = Color3.fromRGB(56, 38, 26),
	Text = Color3.fromRGB(62, 42, 28),
	TextMuted = Color3.fromRGB(140, 112, 86),
	TextLight = Color3.fromRGB(255, 255, 255),
	-- Accents
	Coins = Color3.fromRGB(255, 200, 40),
	Gems = Color3.fromRGB(86, 204, 255),
	Level = Color3.fromRGB(112, 210, 86),
	Blue = Color3.fromRGB(62, 164, 255),
	Green = Color3.fromRGB(86, 204, 96),
	Red = Color3.fromRGB(242, 86, 86),
	Orange = Color3.fromRGB(255, 156, 52),
	Purple = Color3.fromRGB(162, 112, 255),
	Pink = Color3.fromRGB(255, 118, 172),
	Teal = Color3.fromRGB(38, 196, 184),
	-- Effects
	Shadow = Color3.fromRGB(20, 12, 6),
	Glass = Color3.fromRGB(26, 32, 50),
}

Theme.Fonts = {
	Title = Enum.Font.FredokaOne,
	Body = Enum.Font.BuilderSansMedium,
	Bold = Enum.Font.BuilderSansBold,
	Heavy = Enum.Font.BuilderSansExtraBold,
}

Theme.Corner = UDim.new(0, 18)
Theme.SmallCorner = UDim.new(0, 12)
Theme.StrokeThickness = 3

Theme.TextSize = {
	Huge = 44,
	Title = 28,
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
