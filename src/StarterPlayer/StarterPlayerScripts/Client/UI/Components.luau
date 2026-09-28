--[[
	SCRIPT NAME:  Components
	SCRIPT TYPE:  ModuleScript (client UI kit)
	WHERE:        StarterPlayerScripts/Client/UI/Components
	DEPENDENCIES: Client.UI.Theme

	Tiny UI kit so every screen looks consistent and nothing is rebuilt from
	scratch: Create(), rounded panels with drop shadows and glossy headers,
	chunky cartoon buttons (glossy gradient + 3D bevel + springy hover grow /
	press squash + click sound), currency pills, progress bars, tab rows.
	Frames are created once and updated in place (spec §116).
]]

local TweenService = game:GetService("TweenService")

local Theme = require(script.Parent.Theme)

local Components = {}

local clickSound: (() -> ())? = nil
local hoverSound: (() -> ())? = nil

function Components.SetClickSound(callback: () -> ())
	clickSound = callback
end

function Components.SetHoverSound(callback: () -> ())
	hoverSound = callback
end

-- Create("Frame", { Size = ..., Parent = ... }, { children })
function Components.Create(className: string, props: { [string]: any }?, children: { Instance }?): any
	local instance = Instance.new(className)
	local parent = nil
	if props then
		for key, value in props do
			if key == "Parent" then
				parent = value
			else
				(instance :: any)[key] = value
			end
		end
	end
	if children then
		for _, child in children do
			child.Parent = instance
		end
	end
	if parent then
		instance.Parent = parent
	end
	return instance
end

local Create = Components.Create

function Components.Corner(parent: Instance, radius: UDim?): UICorner
	return Create("UICorner", { CornerRadius = radius or Theme.Corner, Parent = parent })
end

function Components.Stroke(parent: Instance, color: Color3?, thickness: number?): UIStroke
	return Create("UIStroke", {
		Color = color or Theme.Colors.Outline,
		Thickness = thickness or Theme.StrokeThickness,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Parent = parent,
	})
end

function Components.TextStroke(parent: Instance, color: Color3?, thickness: number?): UIStroke
	return Create("UIStroke", {
		Color = color or Theme.Colors.Outline,
		Thickness = thickness or 2,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual,
		Parent = parent,
	})
end

-- Vertical gradient from `top` to `bottom` (multiplies the object's colour).
function Components.Gradient(parent: Instance, top: Color3, bottom: Color3): UIGradient
	return Create("UIGradient", {
		Rotation = 90,
		Color = ColorSequence.new(top, bottom),
		Parent = parent,
	})
end

-- Cartoon "gloss": bright top half with a soft horizon line (multiplies the colour).
function Components.Gloss(parent: Instance, strength: number?): UIGradient
	local s = strength or 1
	local function shade(value: number): Color3
		local v = 1 - (1 - value) * s
		return Color3.new(v, v, v)
	end
	return Create("UIGradient", {
		Rotation = 90,
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, shade(1)),
			ColorSequenceKeypoint.new(0.46, shade(0.94)),
			ColorSequenceKeypoint.new(0.54, shade(0.82)),
			ColorSequenceKeypoint.new(1, shade(0.74)),
		}),
		Parent = parent,
	})
end

-- Springy scale helper (one UIScale per object, shared with Bounce / PopIn).
local function scaleOf(guiObject: GuiObject): UIScale
	local scale = guiObject:FindFirstChild("BounceScale")
	if not scale then
		scale = Create("UIScale", { Name = "BounceScale", Parent = guiObject })
	end
	return scale :: UIScale
end

function Components.SpringScale(guiObject: GuiObject, target: number, time: number?)
	TweenService:Create(scaleOf(guiObject), TweenInfo.new(time or 0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = target }):Play()
end

function Components.Padding(parent: Instance, pixels: number)
	return Create("UIPadding", {
		PaddingTop = UDim.new(0, pixels),
		PaddingBottom = UDim.new(0, pixels),
		PaddingLeft = UDim.new(0, pixels),
		PaddingRight = UDim.new(0, pixels),
		Parent = parent,
	})
end

function Components.Label(props: { [string]: any }): TextLabel
	local defaults = {
		BackgroundTransparency = 1,
		Font = Theme.Fonts.Title,
		TextColor3 = Theme.Colors.Text,
		TextSize = Theme.TextSize.Medium,
		TextWrapped = true,
	}
	for key, value in props do
		defaults[key] = value
	end
	return Create("TextLabel", defaults)
end

-- Quick "pop" on any GuiObject (uses/creates a UIScale child).
function Components.Bounce(guiObject: GuiObject, amount: number?)
	local scale = scaleOf(guiObject)
	scale.Scale = 1 + (amount or 0.15)
	TweenService:Create(scale, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 }):Play()
end

-- Fade + scale a window in (and optionally out).
function Components.PopIn(guiObject: GuiObject)
	local scale = scaleOf(guiObject)
	scale.Scale = 0.7
	TweenService:Create(scale, TweenInfo.new(0.38, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 }):Play()
	if guiObject:IsA("GuiObject") then
		guiObject.Rotation = -3
		TweenService:Create(guiObject, TweenInfo.new(0.45, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), { Rotation = 0 }):Play()
	end
end

export type ButtonProps = {
	Text: string,
	Color: Color3?,
	TextColor: Color3?,
	Size: UDim2?,
	Position: UDim2?,
	AnchorPoint: Vector2?,
	TextSize: number?,
	Parent: Instance?,
	Name: string?,
	OnClick: (() -> ())?,
	Flat: boolean?, -- no bevel / text outline (tabs, list rows)
}

-- Sets a button's base colour (keeps the gradient + bevel consistent).
function Components.SetButtonColor(button: GuiButton, color: Color3)
	button.BackgroundColor3 = color
	button:SetAttribute("BaseColor", color)
	local bevel = button:FindFirstChild("Bevel")
	if bevel and bevel:IsA("Frame") then
		bevel.BackgroundColor3 = Theme.Darken(color, 0.28)
	end
end

function Components.Button(props: ButtonProps): TextButton
	local color = props.Color or Theme.Colors.Green
	local button = Create("TextButton", {
		Name = props.Name or "Button",
		Size = props.Size or UDim2.fromOffset(160, 48),
		Position = props.Position or UDim2.new(),
		AnchorPoint = props.AnchorPoint or Vector2.zero,
		BackgroundColor3 = color,
		AutoButtonColor = false,
		Text = props.Text,
		Font = Theme.Fonts.Title,
		TextSize = props.TextSize or Theme.TextSize.Medium,
		TextColor3 = props.TextColor or Theme.Colors.TextLight,
		Parent = props.Parent,
	})
	button:SetAttribute("BaseColor", color)
	Components.Corner(button, Theme.SmallCorner)
	Components.Stroke(button, Theme.Colors.Outline, if props.Flat then 2 else 3)
	Components.Gloss(button, if props.Flat then 0.5 else 1)
	if not props.Flat then
		Components.TextStroke(button, Theme.Colors.Outline, 1.6)
		-- Darker bevel along the bottom edge gives the "chunky" 3D look.
		local bevel = Create("Frame", {
			Name = "Bevel",
			Size = UDim2.new(1, 0, 0, 6),
			Position = UDim2.new(0, 0, 1, -6),
			BackgroundColor3 = Theme.Darken(color, 0.28),
			BorderSizePixel = 0,
			Parent = button,
		})
		Components.Corner(bevel, Theme.SmallCorner)
	end

	local function base(): Color3
		local value = button:GetAttribute("BaseColor")
		return if typeof(value) == "Color3" then value else color
	end
	-- Cartoon feel: grow on hover, squash on press, spring back on release.
	local hovered = false
	button.MouseEnter:Connect(function()
		hovered = true
		button.BackgroundColor3 = Theme.Lighten(base(), 0.14)
		Components.SpringScale(button, 1.06)
		if hoverSound and button.Active then
			hoverSound()
		end
	end)
	button.MouseLeave:Connect(function()
		hovered = false
		button.BackgroundColor3 = base()
		Components.SpringScale(button, 1)
	end)
	button.MouseButton1Down:Connect(function()
		button.BackgroundColor3 = Theme.Darken(base(), 0.08)
		Components.SpringScale(button, 0.92, 0.08)
	end)
	button.MouseButton1Up:Connect(function()
		button.BackgroundColor3 = if hovered then Theme.Lighten(base(), 0.14) else base()
		Components.SpringScale(button, if hovered then 1.06 else 1, 0.3)
	end)
	button.Activated:Connect(function()
		if not hovered then
			Components.Bounce(button, 0.1)
		end
		if clickSound then
			clickSound()
		end
		if props.OnClick then
			props.OnClick()
		end
	end)
	return button
end

-- Round icon button (HUD menu): big emoji + small caption under it.
function Components.IconButton(props: { Icon: string, Caption: string, Color: Color3, Parent: Instance, LayoutOrder: number?, OnClick: () -> () }): TextButton
	local button = Components.Button({
		Name = props.Caption .. "Button",
		Text = props.Icon,
		Color = props.Color,
		Size = UDim2.fromOffset(70, 70),
		TextSize = 36,
		Parent = props.Parent,
		OnClick = props.OnClick,
	})
	button.LayoutOrder = props.LayoutOrder or 0
	Components.Corner(button, UDim.new(0, 22))
	local bevel = button:FindFirstChild("Bevel")
	if bevel then
		Components.Corner(bevel, UDim.new(0, 22))
	end
	local caption = Components.Label({
		Name = "Caption",
		Text = props.Caption,
		Size = UDim2.new(1, 12, 0, 18),
		Position = UDim2.new(0.5, 0, 1, 2),
		AnchorPoint = Vector2.new(0.5, 0),
		TextSize = 14,
		TextColor3 = Theme.Colors.TextLight,
		Parent = button,
	})
	Components.TextStroke(caption, Theme.Colors.Outline, 2)
	return button
end

-- Top-bar style pill: [icon] value. Returns (frame, valueLabel).
function Components.Pill(props: { Icon: string, Color: Color3, Width: number?, Parent: Instance?, LayoutOrder: number? }): (Frame, TextLabel)
	local frame = Create("Frame", {
		Size = UDim2.fromOffset(props.Width or 150, 48),
		BackgroundColor3 = Theme.Colors.Panel,
		LayoutOrder = props.LayoutOrder or 0,
		Parent = props.Parent,
	})
	Components.Corner(frame, UDim.new(1, 0))
	Components.Stroke(frame)
	Components.Gloss(frame, 0.45)

	local iconBubble = Create("Frame", {
		Size = UDim2.fromOffset(52, 52),
		Position = UDim2.new(0, -10, 0.5, 0),
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundColor3 = props.Color,
		Parent = frame,
	})
	Components.Corner(iconBubble, UDim.new(1, 0))
	Components.Stroke(iconBubble)
	Components.Gloss(iconBubble)
	-- The icon gently rocks back and forth (cartoon idle).
	iconBubble.Rotation = -6
	TweenService:Create(iconBubble, TweenInfo.new(1.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), { Rotation = 6 }):Play()
	Components.Label({
		Text = props.Icon,
		Size = UDim2.fromScale(1, 1),
		TextSize = 28,
		Parent = iconBubble,
	})

	local value = Components.Label({
		Name = "Value",
		Text = "0",
		Size = UDim2.new(1, -52, 1, 0),
		Position = UDim2.fromOffset(46, 0),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextSize = Theme.TextSize.Large,
		TextWrapped = false,
		Parent = frame,
	})
	return frame, value
end

export type ProgressBar = { Frame: Frame, Fill: Frame, SetProgress: (alpha: number, animate: boolean?) -> () }

function Components.ProgressBar(props: { Size: UDim2, Position: UDim2?, Color: Color3, Parent: Instance? }): ProgressBar
	local frame = Create("Frame", {
		Size = props.Size,
		Position = props.Position or UDim2.new(),
		BackgroundColor3 = Theme.Colors.PanelDark,
		ClipsDescendants = true,
		Parent = props.Parent,
	})
	Components.Corner(frame, UDim.new(1, 0))
	Components.Stroke(frame, Theme.Colors.Outline, 2)
	local fill = Create("Frame", {
		Size = UDim2.fromScale(0, 1),
		BackgroundColor3 = props.Color,
		Parent = frame,
	})
	Components.Corner(fill, UDim.new(1, 0))
	Components.Gloss(fill)

	local function setProgress(alpha: number, animate: boolean?)
		local target = UDim2.fromScale(math.clamp(alpha, 0, 1), 1)
		if animate then
			TweenService:Create(fill, TweenInfo.new(0.4, Enum.EasingStyle.Quad), { Size = target }):Play()
		else
			fill.Size = target
		end
	end
	return { Frame = frame, Fill = fill, SetProgress = setProgress }
end

-- Rounded cream window with a drop shadow, gradient header and close button.
-- Returns (window, content, closeButton). `window` is a transparent container
-- (shadow + body) so it can be shown / hidden / bounced as one piece.
function Components.Panel(props: { Title: string, Size: UDim2, Parent: Instance?, OnClose: (() -> ())?, Color: Color3? }): (Frame, Frame, TextButton)
	local headerColor = props.Color or Theme.Colors.Header
	local window = Create("Frame", {
		Size = props.Size,
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Parent = props.Parent,
	})
	local shadow = Create("Frame", {
		Name = "Shadow",
		Size = UDim2.new(1, 8, 1, 8),
		Position = UDim2.fromOffset(-2, 6),
		BackgroundColor3 = Theme.Colors.Shadow,
		BackgroundTransparency = 0.72,
		Parent = window,
	})
	Components.Corner(shadow, UDim.new(0, 22))
	local body = Create("Frame", {
		Name = "Body",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Theme.Colors.Panel,
		Parent = window,
	})
	Components.Corner(body)
	Components.Stroke(body, Theme.Colors.Outline, 4)
	Components.Gradient(body, Color3.new(1, 1, 1), Color3.fromRGB(242, 234, 218))

	local header = Create("Frame", {
		Name = "Header",
		Size = UDim2.new(1, 0, 0, 56),
		BackgroundColor3 = headerColor,
		Parent = body,
	})
	Components.Corner(header)
	Components.Gloss(header)
	-- Square off the header's bottom corners.
	local squareOff = Create("Frame", {
		Size = UDim2.new(1, 0, 0, 16),
		Position = UDim2.new(0, 0, 1, -16),
		BackgroundColor3 = headerColor,
		BorderSizePixel = 0,
		Parent = header,
	})
	Components.Gradient(squareOff, Color3.fromRGB(199, 199, 199), Color3.fromRGB(189, 189, 189))
	local title = Components.Label({
		Name = "Title",
		Text = props.Title,
		Size = UDim2.new(1, -140, 1, 0),
		Position = UDim2.fromOffset(20, 0),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextSize = Theme.TextSize.Title,
		TextColor3 = Theme.Colors.TextLight,
		Parent = header,
	})
	Components.TextStroke(title, Theme.Colors.Outline, 2.5)

	local closeButton = Components.Button({
		Name = "Close",
		Text = "✕",
		Color = Theme.Colors.Red,
		Size = UDim2.fromOffset(44, 44),
		Position = UDim2.new(1, -8, 0, 6),
		AnchorPoint = Vector2.new(1, 0),
		TextSize = Theme.TextSize.Large,
		Parent = header,
		OnClick = props.OnClose,
	})

	local content = Create("Frame", {
		Name = "Content",
		Size = UDim2.new(1, -24, 1, -72),
		Position = UDim2.fromOffset(12, 64),
		BackgroundTransparency = 1,
		Parent = body,
	})
	return window, content, closeButton
end

-- A row of tab buttons. onSelect(id) is called on click; returns { [id] = button } and a setter.
function Components.Tabs(parent: Instance, tabs: { { Id: string, Text: string } }, width: number, onSelect: (string) -> ()): ({ [string]: TextButton }, (string) -> ())
	local row = Create("Frame", { Name = "Tabs", Size = UDim2.new(1, 0, 0, 40), BackgroundTransparency = 1, Parent = parent }, {
		Create("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder }),
	})
	local buttons = {}
	for index, tab in tabs do
		local button = Components.Button({
			Name = tab.Id,
			Text = tab.Text,
			Color = Theme.Colors.PanelAlt,
			TextColor = Theme.Colors.Text,
			Size = UDim2.fromOffset(width, 38),
			TextSize = Theme.TextSize.Small,
			Parent = row,
			Flat = true,
			OnClick = function()
				onSelect(tab.Id)
			end,
		})
		button.LayoutOrder = index
		buttons[tab.Id] = button
	end
	local function setSelected(id: string)
		for tabId, button in buttons do
			local selected = tabId == id
			Components.SetButtonColor(button, if selected then Theme.Colors.Coins else Theme.Colors.PanelAlt)
		end
	end
	return buttons, setSelected
end

return Components
