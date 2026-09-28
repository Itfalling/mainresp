--[[
	SCRIPT NAME:  SocialController
	SCRIPT TYPE:  ModuleScript (client controller)
	WHERE:        StarterPlayerScripts/Client/Controllers/SocialController
	DEPENDENCIES: Shared.Net, Client.ClientState, UIController, InputController, AnimationController,
	              AudioController, Client.UI.{Components, Theme}

	Two small left-menu features:

	  😀 EMOTES (T)   a pop-up row: Wave · Cheer · Point · Dance. The server
	                  plays the emote on your character, so everyone nearby
	                  sees it (EmoteRequest). Your own client starts it at
	                  once for instant feedback.
	  ⚙️ SETTINGS     music volume, sound-effects volume, camera shake.
	                  Saved in your profile (SettingsRequest).
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Net = require(Shared:WaitForChild("Net"))

local Client = script.Parent.Parent
local ClientState = require(Client.ClientState)
local UIController = require(script.Parent.UIController)
local InputController = require(script.Parent.InputController)
local AnimationController = require(script.Parent.AnimationController)
local AudioController = require(script.Parent.AudioController)
local Components = require(Client.UI.Components)
local Theme = require(Client.UI.Theme)

local Create = Components.Create

local EMOTES = {
	{ Id = "Wave", Icon = "👋" },
	{ Id = "Cheer", Icon = "🙌" },
	{ Id = "Point", Icon = "👉" },
	{ Id = "Dance", Icon = "💃" },
}

local SocialController = {}

local emoteBar: Frame
local settingsWindow: Frame
local settingsOpen = false
local lastEmote = 0
type Slider = { Fill: Frame, Value: TextLabel, Key: string }
local sliders: { Slider } = {}
local shakeButton: TextButton

---------------------------------------------------------------------------
-- Emotes
---------------------------------------------------------------------------

local function playEmote(id: string)
	local now = os.clock()
	if now - lastEmote < 0.6 then
		return
	end
	lastEmote = now
	emoteBar.Visible = false
	AnimationController.PlayLocal(id, 1)
	Net.FireServer("EmoteRequest", id)
end

local function toggleEmotes()
	if UIController.IsAnyModalOpen() then
		return
	end
	emoteBar.Visible = not emoteBar.Visible
	if emoteBar.Visible then
		Components.PopIn(emoteBar)
	end
end

---------------------------------------------------------------------------
-- Settings
---------------------------------------------------------------------------

local function refreshSettings()
	local settings = ClientState.Get("Settings") or {}
	for _, slider in sliders do
		local value = settings[slider.Key]
		value = if type(value) == "number" then value else 0.5
		slider.Fill.Size = UDim2.fromScale(value, 1)
		slider.Value.Text = ("%d%%"):format(math.floor(value * 100 + 0.5))
	end
	local shake = settings.CameraShake ~= false
	shakeButton.Text = if shake then "📳 Camera shake: ON" else "📴 Camera shake: OFF"
	Components.SetButtonColor(shakeButton, if shake then Theme.Colors.Green else Theme.Colors.PanelDark)
end

local function step(key: string, delta: number)
	local current = ClientState.Get("Settings", key)
	current = if type(current) == "number" then current else 0.5
	local value = math.clamp(math.floor((current + delta) * 10 + 0.5) / 10, 0, 1)
	Net.FireServer("SettingsRequest", { [key] = value })
end

local function makeSlider(parent: Instance, y: number, label: string, key: string)
	Components.Label({ Text = label, Size = UDim2.new(1, 0, 0, 24), Position = UDim2.fromOffset(0, y), TextXAlignment = Enum.TextXAlignment.Left, TextSize = Theme.TextSize.Medium, Parent = parent })
	Components.Button({ Text = "−", Color = Theme.Colors.Red, Size = UDim2.fromOffset(44, 40), Position = UDim2.fromOffset(0, y + 28), TextSize = Theme.TextSize.Large, Parent = parent, OnClick = function()
		step(key, -0.1)
	end })
	local track = Create("Frame", { Size = UDim2.new(1, -170, 0, 22), Position = UDim2.fromOffset(54, y + 37), BackgroundColor3 = Theme.Colors.PanelDark, Parent = parent })
	Components.Corner(track, UDim.new(1, 0))
	Components.Stroke(track, Theme.Colors.Outline, 2)
	local fill = Create("Frame", { Size = UDim2.fromScale(0.5, 1), BackgroundColor3 = Theme.Colors.Blue, Parent = track })
	Components.Corner(fill, UDim.new(1, 0))
	Components.Button({ Text = "+", Color = Theme.Colors.Green, Size = UDim2.fromOffset(44, 40), Position = UDim2.new(1, -106, 0, y + 28), TextSize = Theme.TextSize.Large, Parent = parent, OnClick = function()
		step(key, 0.1)
	end })
	local value = Components.Label({ Text = "50%", Size = UDim2.fromOffset(56, 40), Position = UDim2.new(1, -56, 0, y + 28), TextSize = Theme.TextSize.Medium, Parent = parent })
	table.insert(sliders, { Fill = fill, Value = value, Key = key })
end

local function closeSettings()
	if settingsOpen then
		settingsOpen = false
		settingsWindow.Visible = false
		UIController.SetModalOpen("Settings", false)
	end
end

local function openSettings()
	if settingsOpen or UIController.IsAnyModalOpen() then
		return
	end
	settingsOpen = true
	settingsWindow.Visible = true
	UIController.SetModalOpen("Settings", true)
	Components.PopIn(settingsWindow)
	AudioController.Play("UIOpen")
	refreshSettings()
end

---------------------------------------------------------------------------

function SocialController.Init()
	emoteBar = Create("Frame", {
		Name = "EmoteBar",
		Size = UDim2.fromOffset(4 * 86 + 16, 96),
		Position = UDim2.new(0.5, 0, 1, -126),
		AnchorPoint = Vector2.new(0.5, 1),
		BackgroundColor3 = Theme.Colors.Panel,
		Visible = false,
		Parent = UIController.GetOverlay(),
	}, {
		Create("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Center, VerticalAlignment = Enum.VerticalAlignment.Center, Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }),
	})
	Components.Corner(emoteBar)
	Components.Stroke(emoteBar, Theme.Colors.Outline, 3)
	for index, emote in EMOTES do
		local button = Components.Button({
			Name = emote.Id,
			Text = emote.Icon .. "\n" .. emote.Id,
			Color = Theme.Colors.Pink,
			Size = UDim2.fromOffset(80, 80),
			TextSize = Theme.TextSize.Small,
			Parent = emoteBar,
			OnClick = function()
				playEmote(emote.Id)
			end,
		})
		button.LayoutOrder = index
	end

	local content, closeButton
	settingsWindow, content, closeButton = Components.Panel({ Title = "⚙️ Settings", Size = UDim2.fromOffset(460, 360), Parent = UIController.GetModalLayer(), Color = Theme.Colors.Blue })
	settingsWindow.Visible = false
	closeButton.Activated:Connect(closeSettings)
	makeSlider(content, 0, "🎵 Music", "MusicVolume")
	makeSlider(content, 84, "🔊 Sound effects", "SfxVolume")
	shakeButton = Components.Button({ Text = "", Color = Theme.Colors.Green, Size = UDim2.new(1, 0, 0, 48), Position = UDim2.fromOffset(0, 184), Parent = content, OnClick = function()
		Net.FireServer("SettingsRequest", { CameraShake = ClientState.Get("Settings", "CameraShake") == false })
	end })

	Components.IconButton({ Icon = "😀", Caption = "Emotes", Key = "T", Color = Theme.Colors.Pink, Parent = UIController.GetSlot("Left"), LayoutOrder = 4, OnClick = toggleEmotes })
	Components.IconButton({ Icon = "⚙️", Caption = "Settings", Color = Theme.Colors.Glass, Parent = UIController.GetSlot("Left"), LayoutOrder = 5, OnClick = openSettings })
end

function SocialController.Start()
	InputController.On("Emotes", toggleEmotes)
	InputController.On("Cancel", function()
		emoteBar.Visible = false
		closeSettings()
	end)
	ClientState.Observe("Settings", function()
		if settingsOpen then
			refreshSettings()
		end
	end)
end

return SocialController
