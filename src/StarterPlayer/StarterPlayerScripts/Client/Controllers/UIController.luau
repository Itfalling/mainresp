--[[
	SCRIPT NAME:  UIController
	SCRIPT TYPE:  ModuleScript (client controller)
	WHERE:        StarterPlayerScripts/Client/Controllers/UIController
	DEPENDENCIES: Client.ClientState, AudioController, CameraController, Client.UI.{HUD, Notifications, Components, Theme},
	              Shared.Net, Shared.Config.ProgressionConfig, Shared.Config.ItemConfig, Shared.Util.Format

	Owns the ScreenGui, UI scaling, the HUD layout, notifications and modal
	windows. Every UI in the game is created through here once and updated in
	place when replicated state changes (spec §82, §116).

	WINDOWS: while any window is open the world behind it is dimmed and
	softly blurred (click the dim area to close windows — it sends the
	Cancel action). Build mode and the island creator have their own look.

	Automatic reward feedback (spec §68): whenever the replicated Coins value
	rises, the counter animates, bounces and a "+N 🪙" floats up with a coin
	sound; whenever an item count rises, "+N Wood" floats above the hotbar.
	No system has to remember to send its own popup.
]]

local GuiService = game:GetService("GuiService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Net = require(Shared:WaitForChild("Net"))
local ProgressionConfig = require(Shared.Config.ProgressionConfig)
local ItemConfig = require(Shared.Config.ItemConfig)
local Format = require(Shared.Util.Format)

local Client = script.Parent.Parent
local ClientState = require(Client.ClientState)
local AudioController = require(script.Parent.AudioController)
local InputController = require(script.Parent.InputController)
local CameraController = require(script.Parent.CameraController)
local Theme = require(Client.UI.Theme)
local Components = require(Client.UI.Components)
local HUD = require(Client.UI.HUD)
local Notifications = require(Client.UI.Notifications)

local UIController = {}

local screen: ScreenGui
local uiScale: UIScale
local hud: HUD.HUDRefs
local notifications: any
local modalLayer: Frame
local overlayLayer: Frame
local openModals: { [string]: boolean } = {}
local lastItems: { [string]: number }? = nil
local backdrop: TextButton
local blur: BlurEffect
local dimmed = false
local lastLevel: number? = nil

-- Screens with their own full-screen look (no dim / blur behind them).
local NO_BACKDROP = { Build = true, IslandCreator = true }

local function updateScale()
	local camera = workspace.CurrentCamera
	if not camera then
		return
	end
	local viewport = camera.ViewportSize
	local scale = math.min(viewport.X / Theme.DesignSize.X, viewport.Y / Theme.DesignSize.Y)
	uiScale.Scale = math.clamp(scale, 0.55, 1.35)
end

local function animateCounter(label: TextLabel, from: number, to: number)
	local value = Instance.new("NumberValue")
	value.Value = from
	value.Changed:Connect(function(current)
		label.Text = Format.Abbreviate(math.floor(current + 0.5))
	end)
	local tween = TweenService:Create(value, TweenInfo.new(0.6, Enum.EasingStyle.Quad), { Value = to })
	tween.Completed:Once(function()
		label.Text = Format.Abbreviate(to)
		value:Destroy()
	end)
	tween:Play()
end

local function pillFloatPosition(pill: Frame): UDim2
	-- Floats appear just under a top-bar pill (positions are in design space).
	local absolute = pill.AbsolutePosition + pill.AbsoluteSize / 2
	local scale = uiScale.Scale
	local screenOffset = screen.AbsolutePosition
	return UDim2.fromOffset((absolute.X - screenOffset.X) / scale, (absolute.Y - screenOffset.Y) / scale + 50)
end

local function watchCurrency(key: string, label: TextLabel, pill: Frame, color: Color3, icon: string)
	local last: number? = nil
	ClientState.Observe(key, function(value)
		if type(value) ~= "number" then
			return
		end
		if last == nil then
			label.Text = Format.Abbreviate(value)
		elseif value ~= last then
			animateCounter(label, last, value)
			local delta = value - last
			Components.Bounce(pill, 0.12)
			if delta > 0 then
				notifications:Float(("+%s %s"):format(Format.Abbreviate(delta), icon), color, pillFloatPosition(pill))
				AudioController.Play("CoinGain")
			else
				notifications:Float(("-%s %s"):format(Format.Abbreviate(-delta), icon), Theme.Colors.Red, pillFloatPosition(pill))
				AudioController.Play("CoinSpend")
			end
		end
		last = value
	end)
end

local function refreshPlayerCard()
	local level = ClientState.Get("Level") or 1
	local xp = ClientState.Get("XP") or 0
	local needed = ProgressionConfig.PlayerXPForLevel(level)
	hud.PlayerLevel.Text = tostring(level)
	hud.PlayerXP.SetProgress(xp / math.max(1, needed), true)
	hud.PlayerXPText.Text = ("%s / %s XP"):format(Format.Abbreviate(xp), Format.Abbreviate(needed))
	if lastLevel and level > lastLevel then
		Components.Bounce(hud.PlayerLevelBadge, 0.5)
	end
	lastLevel = level
end

local function refreshBackdrop()
	local wanted = false
	for name in openModals do
		if not NO_BACKDROP[name] then
			wanted = true
		end
	end
	if wanted == dimmed then
		return
	end
	dimmed = wanted
	backdrop.Visible = true
	local info = TweenInfo.new(0.25, Enum.EasingStyle.Quad)
	local fade = TweenService:Create(backdrop, info, { BackgroundTransparency = if wanted then 0.55 else 1 })
	fade:Play()
	TweenService:Create(blur, info, { Size = if wanted then 12 else 0 }):Play()
	if not wanted then
		fade.Completed:Once(function()
			if not dimmed then
				backdrop.Visible = false
			end
		end)
	end
end

local function watchItems()
	ClientState.Observe("Inventory", function(inventory)
		if type(inventory) ~= "table" or type(inventory.Items) ~= "table" then
			return
		end
		local items = inventory.Items
		if lastItems then
			local offset = 0
			for itemId, count in items do
				local previous = lastItems[itemId] or 0
				if count > previous then
					local def = ItemConfig.Get(itemId)
					if def then
						notifications:Float(
							("+%d %s %s"):format(count - previous, def.Icon, def.DisplayName),
							Theme.Colors.TextLight,
							UDim2.new(0.5, 0, 1, -150 - offset),
							50
						)
						offset += 34
					end
				end
			end
			if offset > 0 then
				AudioController.Play("ItemGain")
			end
		end
		lastItems = table.clone(items)
	end)
end

-- Public API ---------------------------------------------------------------

function UIController.GetScreen(): ScreenGui
	return screen
end

function UIController.GetSlot(name: string): Frame
	local slot = hud.Slots[name]
	assert(slot, "Unknown HUD slot " .. name)
	return slot
end

function UIController.GetModalLayer(): Frame
	return modalLayer
end

-- Converts a viewport point (UserInputService:GetMouseLocation) to design-space offsets.
function UIController.ViewportToDesign(point: Vector2): Vector2
	local inset = GuiService:GetGuiInset()
	local scale = if uiScale then uiScale.Scale else 1
	return (point - inset - screen.AbsolutePosition) / scale
end

function UIController.GetOverlay(): Frame
	return overlayLayer
end

function UIController.Notify(kind: string, text: string, icon: string?)
	notifications:Toast(kind, text, icon)
	AudioController.Play(if kind == "Error" then "UIError" else "UINotify")
end

function UIController.Banner(title: string, subtitle: string?, style: string?)
	notifications:Banner(title, subtitle, style)
	CameraController.Punch(3)
end

function UIController.Float(text: string, color: Color3, position: UDim2)
	notifications:Float(text, color, position)
end

-- Modal bookkeeping so gameplay can ask "is a menu open?"
function UIController.SetModalOpen(name: string, open: boolean)
	if open then
		openModals[name] = true
	else
		openModals[name] = nil
	end
	AudioController.Play(if open then "UIOpen" else "UIClose")
	refreshBackdrop()
end

function UIController.IsAnyModalOpen(): boolean
	return next(openModals) ~= nil
end

function UIController.Init()
	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	screen = Components.Create("ScreenGui", {
		Name = "IslandUI",
		ResetOnSpawn = false,
		IgnoreGuiInset = false,
		ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		Parent = playerGui,
	})
	-- Everything is authored at Theme.DesignSize and scaled to the device.
	local designRoot = Components.Create("Frame", {
		Name = "DesignRoot",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Parent = screen,
	})
	uiScale = Components.Create("UIScale", { Parent = designRoot })
	updateScale()
	-- With UIScale the root must be sized in design units.
	local function resizeRoot()
		updateScale()
		designRoot.Size = UDim2.fromOffset(screen.AbsoluteSize.X / uiScale.Scale, screen.AbsoluteSize.Y / uiScale.Scale)
	end
	screen:GetPropertyChangedSignal("AbsoluteSize"):Connect(resizeRoot)
	resizeRoot()

	hud = HUD.Create(designRoot)
	modalLayer = Components.Create("Frame", {
		Name = "Modals",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		ZIndex = 10,
		Parent = designRoot,
	})
	-- Dim layer behind windows (under every window in the modal layer).
	backdrop = Components.Create("TextButton", {
		Name = "Backdrop",
		Size = UDim2.new(1, 400, 1, 400),
		Position = UDim2.fromOffset(-200, -200),
		BackgroundColor3 = Color3.fromRGB(12, 16, 30),
		BackgroundTransparency = 1,
		AutoButtonColor = false,
		Text = "",
		Visible = false,
		ZIndex = 0,
		Parent = modalLayer,
	})
	backdrop.Activated:Connect(function()
		InputController.Trigger("Cancel")
	end)
	blur = Instance.new("BlurEffect")
	blur.Name = "UIBlur"
	blur.Size = 0
	blur.Parent = Lighting
	hud.PlayerName.Text = Players.LocalPlayer.DisplayName
	task.spawn(function()
		local ok, image = pcall(Players.GetUserThumbnailAsync, Players, Players.LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
		if ok then
			hud.PlayerAvatar.Image = image
		end
	end)
	local overlay = Components.Create("Frame", {
		Name = "Overlay",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		ZIndex = 20,
		Parent = designRoot,
	})
	overlayLayer = overlay
	notifications = Notifications.new(overlay)
	Components.SetClickSound(function()
		AudioController.Play("UIClick")
	end)
	Components.SetHoverSound(function()
		AudioController.Play("UIHover")
	end)
end

-- If the server failed to boot, say so on screen instead of showing an empty world.
local function watchServerHealth()
	local shown = ""
	local function showBootErrors()
		local errors = ReplicatedStorage:GetAttribute("ServerBootErrors")
		if type(errors) == "string" and errors ~= "" and errors ~= shown then
			shown = errors
			local firstLine = string.split(errors, "\n")[1]
			UIController.Notify("Error", "Server error: " .. string.sub(firstLine, 1, 120))
			UIController.Banner("SERVER ERROR", "Open View → Output in Studio and send the red text", "Error")
		end
	end
	showBootErrors()
	ReplicatedStorage:GetAttributeChangedSignal("ServerBootErrors"):Connect(showBootErrors)

	task.delay(20, function()
		if not ClientState.IsReady() then
			UIController.Notify("Error", "Still waiting for the server to load your island…")
			UIController.Banner("LOADING TROUBLE", "Open View → Output in Studio and check for red errors", "Error")
		end
	end)
end

function UIController.Start()
	watchServerHealth()
	watchCurrency("Coins", hud.CoinsLabel, hud.CoinsPill, Theme.Colors.Coins, "🪙")
	watchCurrency("Gems", hud.GemsLabel, hud.GemsPill, Theme.Colors.Gems, "💎")
	ClientState.Observe("Level", refreshPlayerCard)
	ClientState.Observe("XP", refreshPlayerCard)
	watchItems()

	Net.OnClientEvent("Notify", function(payload: any)
		if type(payload) ~= "table" or type(payload.Text) ~= "string" then
			return
		end
		if payload.Kind == "Banner" then
			UIController.Banner(payload.Text, payload.Subtitle, payload.Style)
		else
			UIController.Notify(payload.Kind or "Toast", payload.Text, payload.Icon)
		end
	end)
end

return UIController
