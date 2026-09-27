--[[
	SCRIPT NAME:  Components
	SCRIPT TYPE:  ModuleScript (client UI kit)
	WHERE:        StarterPlayerScripts/Client/UI/Components
	DEPENDENCIES: Client.UI.Theme

	Tiny UI kit so every screen looks consistent and nothing is rebuilt from
	scratch: Create(), rounded panels, chunky buttons with press bounce,
	currency pills, progress bars. Frames are created once and updated in
	place (spec §116).
]]

local TweenService = game:GetService("TweenService")

local Theme = require(script.Parent.Theme)

local Components = {}

local clickSound: (() -> ())? = nil

function Components.SetClickSound(callback: () -> ())
	clickSound = callback
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
	local scale = guiObject:FindFirstChild("BounceScale")
	if not scale then
		scale = Create("UIScale", { Name = "BounceScale", Parent = guiObject })
	end
	scale.Scale = 1 + (amount or 0.15)
	TweenService:Create(scale, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 }):Play()
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
}

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
	Components.Corner(button, Theme.SmallCorner)
	Components.Stroke(button)
	Components.TextStroke(button, Theme.Colors.Outline, 1.5)

	button.MouseEnter:Connect(function()
		button.BackgroundColor3 = color:Lerp(Color3.new(1, 1, 1), 0.15)
	end)
	button.MouseLeave:Connect(function()
		button.BackgroundColor3 = color
	end)
	button.Activated:Connect(function()
		Components.Bounce(button, 0.08)
		if clickSound then
			clickSound()
		end
		if props.OnClick then
			props.OnClick()
		end
	end)
	return button
end

-- Top-bar style pill: [icon] value. Returns (frame, valueLabel).
function Components.Pill(props: { Icon: string, Color: Color3, Width: number?, Parent: Instance?, LayoutOrder: number? }): (Frame, TextLabel)
	local frame = Create("Frame", {
		Size = UDim2.fromOffset(props.Width or 150, 44),
		BackgroundColor3 = Theme.Colors.Panel,
		LayoutOrder = props.LayoutOrder or 0,
		Parent = props.Parent,
	})
	Components.Corner(frame, UDim.new(1, 0))
	Components.Stroke(frame)

	local iconBubble = Create("Frame", {
		Size = UDim2.fromOffset(52, 52),
		Position = UDim2.new(0, -10, 0.5, 0),
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundColor3 = props.Color,
		Parent = frame,
	})
	Components.Corner(iconBubble, UDim.new(1, 0))
	Components.Stroke(iconBubble)
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

-- Rounded cream panel with a title and close button. Returns (panel, content, closeButton).
function Components.Panel(props: { Title: string, Size: UDim2, Parent: Instance?, OnClose: (() -> ())? }): (Frame, Frame, TextButton)
	local panel = Create("Frame", {
		Size = props.Size,
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Theme.Colors.Panel,
		Parent = props.Parent,
	})
	Components.Corner(panel)
	Components.Stroke(panel, Theme.Colors.Outline, 4)

	local header = Create("Frame", {
		Name = "Header",
		Size = UDim2.new(1, 0, 0, 54),
		BackgroundColor3 = Theme.Colors.Blue,
		Parent = panel,
	})
	Components.Corner(header)
	-- Square off the header's bottom corners.
	Create("Frame", {
		Size = UDim2.new(1, 0, 0, 16),
		Position = UDim2.new(0, 0, 1, -16),
		BackgroundColor3 = Theme.Colors.Blue,
		BorderSizePixel = 0,
		Parent = header,
	})
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
	Components.TextStroke(title)

	local closeButton = Components.Button({
		Name = "Close",
		Text = "✕",
		Color = Theme.Colors.Red,
		Size = UDim2.fromOffset(44, 44),
		Position = UDim2.new(1, -8, 0, 5),
		AnchorPoint = Vector2.new(1, 0),
		TextSize = Theme.TextSize.Large,
		Parent = header,
		OnClick = props.OnClose,
	})

	local content = Create("Frame", {
		Name = "Content",
		Size = UDim2.new(1, -24, 1, -70),
		Position = UDim2.fromOffset(12, 62),
		BackgroundTransparency = 1,
		Parent = panel,
	})
	return panel, content, closeButton
end

return Components
