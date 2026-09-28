--[[
	SCRIPT NAME:  Notifications
	SCRIPT TYPE:  ModuleScript (client UI)
	WHERE:        StarterPlayerScripts/Client/UI/Notifications
	DEPENDENCIES: Client.UI.{Theme, Components}

	"Did that work?" feedback (spec §151/§152), cartoon style:
	  Toast   glossy pill with an icon bubble; pops in, fades out (max 4)
	  Banner  big title on a ribbon that bounces + wobbles in (queued)
	  Float   pooled floating text ("+25 🪙", "+3 Wood") that pops, tilts,
	          rises and fades
]]

local TweenService = game:GetService("TweenService")

local Theme = require(script.Parent.Theme)
local Components = require(script.Parent.Components)

local Create = Components.Create

local MAX_TOASTS = 4
local TOAST_TIME = 3
local BANNER_TIME = 2.6
local FLOAT_POOL = 12

local TOAST_STYLES = {
	Toast = { Background = Theme.Colors.Panel, Text = Theme.Colors.Text, Bubble = Theme.Colors.Blue, Icon = "💬" },
	Success = { Background = Theme.Colors.Green, Text = Theme.Colors.TextLight, Bubble = Theme.Colors.Panel, Icon = "✔" },
	Error = { Background = Theme.Colors.Red, Text = Theme.Colors.TextLight, Bubble = Theme.Colors.Panel, Icon = "✖" },
}

local BANNER_COLORS = {
	LevelUp = Theme.Colors.Level,
	IslandLevelUp = Theme.Colors.Coins,
	AreaUnlock = Theme.Colors.Blue,
	Reward = Theme.Colors.Orange,
	Build = Theme.Colors.Green,
	Error = Theme.Colors.Red,
}

local Notifications = {}
Notifications.__index = Notifications

function Notifications.new(parent: Instance)
	local self = setmetatable({}, Notifications)

	self.ToastContainer = Create("Frame", {
		Name = "Toasts",
		Size = UDim2.fromOffset(460, 220),
		Position = UDim2.new(0.5, 0, 0, 78),
		AnchorPoint = Vector2.new(0.5, 0),
		BackgroundTransparency = 1,
		Parent = parent,
	}, {
		Create("UIListLayout", {
			Padding = UDim.new(0, 6),
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
	})

	self.Banner = Create("CanvasGroup", {
		Name = "Banner",
		Size = UDim2.fromOffset(760, 140),
		Position = UDim2.fromScale(0.5, 0.3),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		GroupTransparency = 1,
		Visible = false,
		Parent = parent,
	})
	self.BannerScale = Create("UIScale", { Parent = self.Banner })
	-- Ribbon behind the title (colour follows the banner style).
	self.BannerRibbon = Create("Frame", {
		Name = "Ribbon",
		Size = UDim2.new(0.86, 0, 0, 74),
		Position = UDim2.new(0.5, 0, 0, 6),
		AnchorPoint = Vector2.new(0.5, 0),
		BackgroundColor3 = Theme.Colors.Coins,
		Parent = self.Banner,
	})
	Components.Corner(self.BannerRibbon, UDim.new(0, 22))
	Components.Stroke(self.BannerRibbon, Theme.Colors.Outline, 4)
	Components.Gloss(self.BannerRibbon)
	for index, side in { -1, 1 } do
		Components.Label({
			Name = "Star" .. index,
			Text = "✦",
			Size = UDim2.fromOffset(60, 60),
			Position = UDim2.new(0.5 + side * 0.47, 0, 0, 13),
			AnchorPoint = Vector2.new(0.5, 0),
			TextSize = 48,
			TextColor3 = Color3.fromRGB(255, 245, 170),
			Parent = self.Banner,
		})
	end
	self.BannerTitle = Components.Label({
		Name = "Title",
		Size = UDim2.new(1, 0, 0, 80),
		Position = UDim2.fromOffset(0, 2),
		TextSize = Theme.TextSize.Huge + 8,
		TextColor3 = Theme.Colors.TextLight,
		TextWrapped = false,
		Parent = self.Banner,
	})
	Components.TextStroke(self.BannerTitle, Theme.Colors.Outline, 4)
	self.BannerSubtitle = Components.Label({
		Name = "Subtitle",
		Size = UDim2.new(1, 0, 0, 50),
		Position = UDim2.fromOffset(0, 86),
		TextSize = Theme.TextSize.Large + 2,
		TextColor3 = Theme.Colors.TextLight,
		Parent = self.Banner,
	})
	Components.TextStroke(self.BannerSubtitle, Theme.Colors.Outline, 2.5)
	self.BannerQueue = {}
	self.BannerBusy = false

	self.FloatLayer = Create("Frame", {
		Name = "Floats",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Parent = parent,
	})
	self.Floats = {}
	for index = 1, FLOAT_POOL do
		local label = Components.Label({
			Name = "Float" .. index,
			Size = UDim2.fromOffset(260, 40),
			AnchorPoint = Vector2.new(0.5, 0.5),
			TextSize = Theme.TextSize.Large + 6,
			TextWrapped = false,
			Visible = false,
			Parent = self.FloatLayer,
		})
		Components.TextStroke(label, Theme.Colors.Outline, 3)
		Create("UIScale", { Name = "PopScale", Parent = label })
		table.insert(self.Floats, label)
	end
	self.NextFloat = 1
	self.ToastCount = 0

	return self
end

function Notifications:Toast(kind: string, text: string, icon: string?)
	local style = TOAST_STYLES[kind] or TOAST_STYLES.Toast
	local toasts = self.ToastContainer:GetChildren()
	local existing = {}
	for _, child in toasts do
		if child:IsA("CanvasGroup") then
			table.insert(existing, child)
		end
	end
	if #existing >= MAX_TOASTS then
		table.sort(existing, function(a, b)
			return a.LayoutOrder < b.LayoutOrder
		end)
		existing[1]:Destroy()
	end

	self.ToastCount += 1
	local toast = Create("CanvasGroup", {
		Size = UDim2.fromOffset(450, 48),
		BackgroundColor3 = style.Background,
		GroupTransparency = 1,
		LayoutOrder = self.ToastCount,
		Parent = self.ToastContainer,
	})
	Components.Corner(toast, UDim.new(1, 0))
	Components.Stroke(toast, Theme.Colors.Outline, 3)
	Components.Gloss(toast, 0.5)
	local bubble = Create("Frame", {
		Size = UDim2.fromOffset(38, 38),
		Position = UDim2.new(0, 5, 0.5, 0),
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundColor3 = style.Bubble,
		Parent = toast,
	})
	Components.Corner(bubble, UDim.new(1, 0))
	Components.Gloss(bubble, 0.6)
	Components.Label({
		Text = icon or style.Icon,
		Size = UDim2.fromScale(1, 1),
		TextSize = 22,
		TextColor3 = if style.Bubble == Theme.Colors.Panel then style.Background else Theme.Colors.TextLight,
		Parent = bubble,
	})
	local label = Components.Label({
		Text = text,
		Size = UDim2.new(1, -62, 1, 0),
		Position = UDim2.fromOffset(50, 0),
		TextColor3 = style.Text,
		TextSize = Theme.TextSize.Medium,
		TextScaled = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = toast,
	})
	Create("UITextSizeConstraint", { MaxTextSize = Theme.TextSize.Medium + 1, Parent = label })

	Components.PopIn(toast)
	TweenService:Create(toast, TweenInfo.new(0.18), { GroupTransparency = 0 }):Play()
	task.delay(TOAST_TIME, function()
		if toast.Parent then
			local fade = TweenService:Create(toast, TweenInfo.new(0.35), { GroupTransparency = 1 })
			fade:Play()
			fade.Completed:Wait()
			toast:Destroy()
		end
	end)
end

function Notifications:_showNextBanner()
	local nextBanner = table.remove(self.BannerQueue, 1)
	if not nextBanner then
		self.BannerBusy = false
		return
	end
	self.BannerBusy = true
	self.BannerTitle.Text = nextBanner.Title
	self.BannerRibbon.BackgroundColor3 = BANNER_COLORS[nextBanner.Style] or Theme.Colors.Coins
	self.BannerSubtitle.Text = nextBanner.Subtitle or ""
	self.Banner.Visible = true
	self.Banner.GroupTransparency = 1
	self.BannerScale.Scale = 0.4
	self.Banner.Rotation = -8
	TweenService:Create(self.Banner, TweenInfo.new(0.2), { GroupTransparency = 0 }):Play()
	TweenService:Create(self.BannerScale, TweenInfo.new(0.55, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 }):Play()
	TweenService:Create(self.Banner, TweenInfo.new(0.9, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), { Rotation = 0 }):Play()
	task.delay(BANNER_TIME, function()
		local fade = TweenService:Create(self.Banner, TweenInfo.new(0.35), { GroupTransparency = 1 })
		fade:Play()
		fade.Completed:Wait()
		self.Banner.Visible = false
		self:_showNextBanner()
	end)
end

function Notifications:Banner(title: string, subtitle: string?, style: string?)
	table.insert(self.BannerQueue, { Title = title, Subtitle = subtitle, Style = style })
	if not self.BannerBusy then
		self:_showNextBanner()
	end
end

-- Floating text at a screen position (UDim2 inside the float layer).
function Notifications:Float(text: string, color: Color3, position: UDim2, rise: number?)
	local label = self.Floats[self.NextFloat]
	self.NextFloat = self.NextFloat % FLOAT_POOL + 1
	label.Text = text
	label.TextColor3 = color
	label.Position = position
	label.TextTransparency = 0
	label.Visible = true
	local stroke = label:FindFirstChildOfClass("UIStroke")
	if stroke then
		stroke.Transparency = 0
	end
	local target = position - UDim2.fromOffset(0, rise or 60)
	local info = TweenInfo.new(1.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	-- Pop in big with a little tilt, then rise and fade.
	local pop = label:FindFirstChild("PopScale")
	if pop and pop:IsA("UIScale") then
		pop.Scale = 1.6
		TweenService:Create(pop, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 }):Play()
	end
	label.Rotation = math.random(-10, 10)
	TweenService:Create(label, TweenInfo.new(0.5, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), { Rotation = 0 }):Play()
	TweenService:Create(label, info, { Position = target, TextTransparency = 1 }):Play()
	if stroke then
		TweenService:Create(stroke, info, { Transparency = 1 }):Play()
	end
end

return Notifications
