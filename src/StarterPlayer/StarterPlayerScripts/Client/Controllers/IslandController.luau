--[[
	SCRIPT NAME:  IslandController
	SCRIPT TYPE:  ModuleScript (client controller)
	WHERE:        StarterPlayerScripts/Client/Controllers/IslandController
	DEPENDENCIES: Shared.Net, Shared.Config.{IslandConfig, ProgressionConfig}, Shared.Util.Format,
	              Client.ClientState, UIController, InputController, Client.UI.{Components, Theme}

	The right-hand ISLAND PANEL, answering the core-loop questions at a glance
	(spec "MOST IMPORTANT REQUIREMENT"):
	  * which island this is and how developed it is (name, level, XP),
	  * WHAT TO DO NEXT (a guide tip driven by progress flags),
	  * WHAT TO UNLOCK NEXT (next expansion + live ✔/✖ requirement checklist
	    and an Unlock button that asks the server).
	Also shows the "Welcome to <island>" banner when the player arrives.
	Phase 10's QuestController will add quest rows to this same panel.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Net = require(Shared:WaitForChild("Net"))
local IslandConfig = require(Shared.Config.IslandConfig)
local ProgressionConfig = require(Shared.Config.ProgressionConfig)
local Format = require(Shared.Util.Format)

local Client = script.Parent.Parent
local ClientState = require(Client.ClientState)
local UIController = require(script.Parent.UIController)
local InputController = require(script.Parent.InputController)
local Components = require(Client.UI.Components)
local Theme = require(Client.UI.Theme)

local Create = Components.Create

local IslandController = {}

type Refs = {
	Card: Frame,
	Body: Frame,
	Name: TextLabel,
	Title: TextLabel,
	XPBar: Components.ProgressBar,
	XPText: TextLabel,
	AreaName: TextLabel,
	Requirements: { TextLabel },
	UnlockButton: TextButton,
	Tip: TextLabel,
	Toggle: TextButton,
}

local refs: Refs
local nextAreaId: string? = nil
local collapsed = false
local welcomed = false

local function nextLockedArea(unlocked: { [string]: boolean }): string?
	for _, areaId in IslandConfig.AreaOrder do
		if not unlocked[areaId] and IslandConfig.Areas[areaId].Unlock then
			return areaId
		end
	end
	return nil
end

local function requirementRows(areaId: string): { { Met: boolean, Text: string } }
	local unlock = IslandConfig.Areas[areaId].Unlock
	local coins = ClientState.Get("Coins") or 0
	local level = ClientState.Get("Island", "Level") or 1
	local unlocked = ClientState.Get("Island", "UnlockedAreas") or {}
	local rows = {
		{ Met = coins >= (unlock.Coins or 0), Text = ("%s / %s 🪙"):format(Format.Abbreviate(coins), Format.Abbreviate(unlock.Coins or 0)) },
		{ Met = level >= (unlock.IslandLevel or 1), Text = ("Island Level %d"):format(unlock.IslandLevel or 1) },
	}
	if unlock.RequiresArea then
		table.insert(rows, {
			Met = unlocked[unlock.RequiresArea] == true,
			Text = "Unlock " .. IslandConfig.Areas[unlock.RequiresArea].DisplayName,
		})
	end
	return rows
end

local function currentTip(canUnlock: boolean): string
	local flags = ClientState.Get("Flags") or {}
	if not flags.StarterChestClaimed then
		return "📦 Open your Starter Chest near the spawn!"
	end
	if not flags.FirstEquip then
		if InputController.IsTouch() then
			return "🪓 Tap a tool in your hotbar to equip it."
		end
		return "🪓 Press 1, 2 or 3 to equip a tool."
	end
	if canUnlock and nextAreaId then
		return "🔓 You can unlock " .. IslandConfig.Areas[nextAreaId].DisplayName .. "!"
	end
	return "🎒 Check your backpack, then save coins for the next area."
end

local function refresh()
	if not ClientState.IsReady() then
		return
	end
	local island = ClientState.Get("Island") or {}
	local level = island.Level or 1
	local xp = island.XP or 0
	local needed = ProgressionConfig.IslandXPForLevel(level)
	refs.Name.Text = island.Name or "My Island"
	refs.Title.Text = ("%s · Lv %d"):format(ProgressionConfig.GetIslandTitle(level), level)
	refs.XPBar.SetProgress(xp / needed, true)
	refs.XPText.Text = ("%s / %s XP"):format(Format.Commas(xp), Format.Commas(needed))

	nextAreaId = nextLockedArea(island.UnlockedAreas or {})
	local canUnlock = false
	if nextAreaId then
		local rows = requirementRows(nextAreaId)
		canUnlock = true
		refs.AreaName.Text = "🔒 " .. IslandConfig.Areas[nextAreaId].DisplayName
		for index, label in refs.Requirements do
			local row = rows[index]
			label.Visible = row ~= nil
			if row then
				label.Text = (if row.Met then "✔ " else "✖ ") .. row.Text
				label.TextColor3 = if row.Met then Theme.Colors.Green else Theme.Colors.Red
				canUnlock = canUnlock and row.Met
			end
		end
		refs.UnlockButton.Visible = true
		refs.UnlockButton.BackgroundColor3 = if canUnlock then Theme.Colors.Green else Theme.Colors.PanelDark
		refs.UnlockButton.Text = if canUnlock then "UNLOCK!" else "LOCKED"
	else
		refs.AreaName.Text = "🌟 Every area unlocked!"
		for _, label in refs.Requirements do
			label.Visible = false
		end
		refs.UnlockButton.Visible = false
	end
	refs.Tip.Text = currentTip(canUnlock)
end

local function buildPanel(parent: Frame): Refs
	local card = Create("Frame", {
		Name = "IslandPanel",
		Size = UDim2.new(1, 0, 0, 340),
		BackgroundColor3 = Theme.Colors.Panel,
		Parent = parent,
	})
	Components.Corner(card)
	Components.Stroke(card)

	local header = Create("Frame", {
		Name = "Header",
		Size = UDim2.new(1, 0, 0, 40),
		BackgroundColor3 = Theme.Colors.Level,
		Parent = card,
	})
	Components.Corner(header)
	local headerLabel = Components.Label({
		Text = "🏝️ MY ISLAND",
		Size = UDim2.new(1, -50, 1, 0),
		Position = UDim2.fromOffset(12, 0),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = Theme.Colors.TextLight,
		TextSize = Theme.TextSize.Medium,
		Parent = header,
	})
	Components.TextStroke(headerLabel)
	local toggle = Create("TextButton", {
		Name = "Toggle",
		Size = UDim2.fromOffset(32, 32),
		Position = UDim2.new(1, -4, 0.5, 0),
		AnchorPoint = Vector2.new(1, 0.5),
		BackgroundColor3 = Theme.Colors.Panel,
		Text = "–",
		Font = Theme.Fonts.Title,
		TextSize = Theme.TextSize.Large,
		TextColor3 = Theme.Colors.Text,
		Parent = header,
	})
	Components.Corner(toggle, UDim.new(1, 0))
	Components.Stroke(toggle, Theme.Colors.Outline, 2)

	local body = Create("Frame", {
		Name = "Body",
		Size = UDim2.new(1, -20, 1, -50),
		Position = UDim2.fromOffset(10, 46),
		BackgroundTransparency = 1,
		Parent = card,
	})

	local name = Components.Label({ Size = UDim2.new(1, 0, 0, 26), TextSize = Theme.TextSize.Medium, TextScaled = true, Text = "", Parent = body })
	local title = Components.Label({
		Size = UDim2.new(1, 0, 0, 18),
		Position = UDim2.fromOffset(0, 26),
		TextSize = Theme.TextSize.Small,
		TextColor3 = Theme.Colors.TextMuted,
		Text = "",
		Parent = body,
	})
	local xpBar = Components.ProgressBar({ Size = UDim2.new(1, 0, 0, 12), Position = UDim2.fromOffset(0, 50), Color = Theme.Colors.Level, Parent = body })
	local xpText = Components.Label({
		Size = UDim2.new(1, 0, 0, 16),
		Position = UDim2.fromOffset(0, 64),
		Font = Theme.Fonts.Bold,
		TextSize = 12,
		TextColor3 = Theme.Colors.TextMuted,
		Text = "",
		Parent = body,
	})

	Create("Frame", { Size = UDim2.new(1, 0, 0, 2), Position = UDim2.fromOffset(0, 86), BackgroundColor3 = Theme.Colors.PanelDark, BorderSizePixel = 0, Parent = body })
	Components.Label({
		Size = UDim2.new(1, 0, 0, 16),
		Position = UDim2.fromOffset(0, 92),
		Font = Theme.Fonts.Bold,
		TextSize = 12,
		TextColor3 = Theme.Colors.TextMuted,
		Text = "NEXT AREA",
		Parent = body,
	})
	local areaName = Components.Label({ Size = UDim2.new(1, 0, 0, 24), Position = UDim2.fromOffset(0, 108), TextSize = Theme.TextSize.Medium, Text = "", Parent = body })
	local requirements = {}
	for index = 1, 3 do
		table.insert(requirements, Components.Label({
			Size = UDim2.new(1, 0, 0, 18),
			Position = UDim2.fromOffset(0, 132 + (index - 1) * 20),
			Font = Theme.Fonts.Bold,
			TextSize = Theme.TextSize.Small,
			TextXAlignment = Enum.TextXAlignment.Left,
			Text = "",
			Parent = body,
		}))
	end
	local unlockButton = Components.Button({
		Name = "Unlock",
		Text = "LOCKED",
		Color = Theme.Colors.PanelDark,
		Size = UDim2.new(1, 0, 0, 38),
		Position = UDim2.fromOffset(0, 196),
		Parent = body,
		OnClick = function()
			if nextAreaId then
				Net.FireServer("UnlockAreaRequest", nextAreaId)
			end
		end,
	})
	local tip = Components.Label({
		Size = UDim2.new(1, 0, 0, 44),
		Position = UDim2.fromOffset(0, 240),
		Font = Theme.Fonts.Bold,
		TextSize = Theme.TextSize.Small,
		TextColor3 = Theme.Colors.Text,
		Text = "",
		Parent = body,
	})

	return {
		Card = card,
		Body = body,
		Name = name,
		Title = title,
		XPBar = xpBar,
		XPText = xpText,
		AreaName = areaName,
		Requirements = requirements,
		UnlockButton = unlockButton,
		Tip = tip,
		Toggle = toggle,
	}
end

local function setCollapsed(value: boolean)
	collapsed = value
	refs.Body.Visible = not collapsed
	refs.Card.Size = if collapsed then UDim2.new(1, 0, 0, 40) else UDim2.new(1, 0, 0, 340)
	refs.Toggle.Text = if collapsed then "+" else "–"
end

function IslandController.Init()
	refs = buildPanel(UIController.GetSlot("Right"))
	refs.Toggle.Activated:Connect(function()
		setCollapsed(not collapsed)
	end)
	-- Phones have little room: start collapsed on touch devices.
	if InputController.IsTouch() then
		setCollapsed(true)
	end
end

function IslandController.Start()
	for _, key in { "Island", "Coins", "Flags", "Tools" } do
		ClientState.Observe(key, refresh)
	end
	InputController.DeviceChanged:Connect(refresh)

	ClientState.Observe("Island", function(island)
		if welcomed or type(island) ~= "table" or not island.Name or island.Name == "" then
			return
		end
		welcomed = true
		task.delay(1, function()
			UIController.Banner("Welcome to " .. island.Name .. "!", "Your island adventure begins", "Reward")
		end)
	end)
end

return IslandController
