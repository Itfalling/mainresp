--[[
	SCRIPT NAME:  Theme
	SCRIPT TYPE:  ModuleScript (client UI)
	WHERE:        StarterPlayerScripts/Client/UI/Theme
	DEPENDENCIES: none

	The single source of UI colours, fonts and sizes: bright, friendly,
	kid-readable (cream panels, chunky brown outlines, saturated accents).
]]

local Theme = {}

Theme.Colors = {
	Panel = Color3.fromRGB(255, 249, 236),
	PanelAlt = Color3.fromRGB(246, 233, 208),
	PanelDark = Color3.fromRGB(226, 208, 176),
	Outline = Color3.fromRGB(74, 52, 34),
	Text = Color3.fromRGB(66, 45, 28),
	TextMuted = Color3.fromRGB(140, 112, 85),
	TextLight = Color3.fromRGB(255, 255, 255),
	Coins = Color3.fromRGB(255, 196, 40),
	Gems = Color3.fromRGB(80, 200, 255),
	Level = Color3.fromRGB(110, 205, 85),
	Blue = Color3.fromRGB(70, 160, 255),
	Green = Color3.fromRGB(85, 195, 90),
	Red = Color3.fromRGB(235, 85, 85),
	Orange = Color3.fromRGB(255, 150, 60),
	Purple = Color3.fromRGB(165, 110, 255),
	Shadow = Color3.fromRGB(0, 0, 0),
}

Theme.Fonts = {
	Title = Enum.Font.FredokaOne,
	Body = Enum.Font.GothamMedium,
	Bold = Enum.Font.GothamBold,
}

Theme.Corner = UDim.new(0, 14)
Theme.SmallCorner = UDim.new(0, 10)
Theme.StrokeThickness = 3

Theme.TextSize = {
	Huge = 44,
	Title = 26,
	Large = 22,
	Medium = 18,
	Small = 15,
}

-- Design resolution: the whole UI is built at this size and scaled by UIScale.
Theme.DesignSize = Vector2.new(1280, 720)

return Theme
