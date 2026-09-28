--[[
	SCRIPT NAME:  QuestController
	SCRIPT TYPE:  ModuleScript (client controller)
	WHERE:        StarterPlayerScripts/Client/Controllers/QuestController
	DEPENDENCIES: Shared.Config.QuestConfig, Shared.Util.Format, Client.ClientState,
	              UIController, InputController, AudioController, Client.UI.{Components, Theme}

	The QUEST CARD on the right of the HUD (spec §43, §118-§119): the
	current tutorial quest, every task with ✔ / progress counts, a 💡 hint
	for the next unfinished task and the reward. It is the game's answer to
	"what do I do next?" at every moment of the first session.

	Read-only: progress arrives through replicated state (Quests.*), which
	the server only changes from real gameplay events.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local QuestConfig = require(Shared.Config.QuestConfig)
local Format = require(Shared.Util.Format)

local Client = script.Parent.Parent
local ClientState = require(Client.ClientState)
local UIController = require(script.Parent.UIController)
local InputController = require(script.Parent.InputController)
local AudioController = require(script.Parent.AudioController)
local Components = require(Client.UI.Components)
local Theme = require(Client.UI.Theme)

local Create = Components.Create

local MAX_TASKS = 6
local ROW_HEIGHT = 20
local HEADER_HEIGHT = 40

local QuestController = {}

type Refs = {
	Card: Frame,
	Body: Frame,
	Toggle: TextButton,
	QuestName: TextLabel,
	Rows: { TextLabel },
	Counts: { TextLabel },
	Hint: TextLabel,
	Reward: TextLabel,
}

local refs: Refs
local collapsed = false
local bodyHeight = 0
local lastDone: { [string]: boolean } = {}
local lastQuestId: string? = nil

local function hintFor(quest: any, progress: { [string]: number }): string
	local flags = ClientState.Get("Flags") or {}
	if not flags.StarterChestClaimed then
		return "📦 Open your Starter Chest near the spawn!"
	end
	if not flags.FirstEquip then
		return if InputController.IsTouch() then "🪓 Tap a tool in your hotbar to equip it." else "🪓 Press 1-6 to equip a tool, then click to use it."
	end
	for _, questTask in quest.Tasks do
		if (progress[questTask.Id] or 0) < questTask.Amount then
			return "💡 " .. questTask.Hint
		end
	end
	return "🎉 Quest complete!"
end

local function rewardText(reward: any): string
	local parts = {}
	if reward.Coins then
		table.insert(parts, Format.Commas(reward.Coins) .. " 🪙")
	end
	if reward.IslandXP then
		table.insert(parts, Format.Commas(reward.IslandXP) .. " Island XP")
	end
	if reward.XP then
		table.insert(parts, Format.Commas(reward.XP) .. " XP")
	end
	return "🎁 " .. table.concat(parts, " · ")
end

local function layout(taskCount: number)
	-- name 22 + rows + hint 36 + reward 16 + gaps
	bodyHeight = 26 + taskCount * ROW_HEIGHT + 6 + 36 + 18
	refs.Hint.Position = UDim2.fromOffset(0, 26 + taskCount * ROW_HEIGHT + 4)
	refs.Reward.Position = UDim2.fromOffset(0, 26 + taskCount * ROW_HEIGHT + 42)
	refs.Card.Size = UDim2.new(1, 0, 0, if collapsed then HEADER_HEIGHT else HEADER_HEIGHT + 8 + bodyHeight)
end

local function refresh()
	if not ClientState.IsReady() then
		return
	end
	local quests = ClientState.Get("Quests") or {}
	local questId = quests.Current
	local quest = type(questId) == "string" and QuestConfig.Quests[questId] or nil
	local progress = quests.Progress or {}

	if not quest then
		refs.QuestName.Text = "🎉 ALL QUESTS DONE!"
		for index = 1, MAX_TASKS do
			refs.Rows[index].Visible = false
			refs.Counts[index].Visible = false
		end
		refs.Hint.Text = "Keep growing your island — more adventures coming soon."
		refs.Reward.Text = ""
		layout(0)
		return
	end

	if questId ~= lastQuestId then
		lastQuestId = questId
		table.clear(lastDone)
		Components.Bounce(refs.Card, 0.06)
	end
	refs.QuestName.Text = quest.DisplayName
	for index = 1, MAX_TASKS do
		local questTask = quest.Tasks[index]
		local row, count = refs.Rows[index], refs.Counts[index]
		row.Visible = questTask ~= nil
		count.Visible = questTask ~= nil
		if questTask then
			local value = math.min(progress[questTask.Id] or 0, questTask.Amount)
			local done = value >= questTask.Amount
			row.Text = (if done then "✔ " else "• ") .. questTask.Text
			row.TextColor3 = if done then Theme.Colors.Green else Theme.Colors.Text
			count.Text = if done then "" else ("%d/%d"):format(value, questTask.Amount)
			if done and lastDone[questTask.Id] == false then
				-- Just finished this task: a little pop + sound.
				Components.Bounce(row, 0.25)
				AudioController.Play("ItemGain")
			end
			lastDone[questTask.Id] = done
		end
	end
	refs.Hint.Text = hintFor(quest, progress)
	refs.Reward.Text = rewardText(quest.Reward)
	layout(#quest.Tasks)
end

local function buildCard(parent: Frame): Refs
	local card = Create("Frame", {
		Name = "QuestCard",
		Size = UDim2.new(1, 0, 0, 250),
		BackgroundColor3 = Theme.Colors.Panel,
		LayoutOrder = 2,
		Parent = parent,
	})
	Components.Corner(card)
	Components.Stroke(card)

	local header = Create("Frame", { Name = "Header", Size = UDim2.new(1, 0, 0, HEADER_HEIGHT), BackgroundColor3 = Theme.Colors.Purple, Parent = card })
	Components.Corner(header)
	local headerLabel = Components.Label({
		Text = "📜 QUEST",
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

	local body = Create("Frame", { Name = "Body", Size = UDim2.new(1, -20, 1, -(HEADER_HEIGHT + 8)), Position = UDim2.fromOffset(10, HEADER_HEIGHT + 4), BackgroundTransparency = 1, Parent = card })
	local questName = Components.Label({ Size = UDim2.new(1, 0, 0, 22), TextSize = Theme.TextSize.Medium, TextScaled = true, Text = "", Parent = body })
	local rows, counts = {}, {}
	for index = 1, MAX_TASKS do
		local y = 26 + (index - 1) * ROW_HEIGHT
		table.insert(rows, Components.Label({
			Size = UDim2.new(1, -50, 0, ROW_HEIGHT - 2),
			Position = UDim2.fromOffset(0, y),
			Font = Theme.Fonts.Bold,
			TextSize = 13,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			TextWrapped = false,
			Text = "",
			Parent = body,
		}))
		table.insert(counts, Components.Label({
			Size = UDim2.new(0, 50, 0, ROW_HEIGHT - 2),
			Position = UDim2.new(1, -50, 0, y),
			Font = Theme.Fonts.Bold,
			TextSize = 13,
			TextXAlignment = Enum.TextXAlignment.Right,
			TextColor3 = Theme.Colors.TextMuted,
			Text = "",
			Parent = body,
		}))
	end
	local hint = Components.Label({
		Size = UDim2.new(1, 0, 0, 34),
		BackgroundTransparency = 0,
		BackgroundColor3 = Color3.fromRGB(255, 240, 200),
		Font = Theme.Fonts.Bold,
		TextSize = 13,
		Text = "",
		Parent = body,
	})
	Components.Corner(hint, Theme.SmallCorner)
	local reward = Components.Label({ Size = UDim2.new(1, 0, 0, 16), Font = Theme.Fonts.Bold, TextSize = 12, TextColor3 = Theme.Colors.TextMuted, Text = "", Parent = body })

	return { Card = card, Body = body, Toggle = toggle, QuestName = questName, Rows = rows, Counts = counts, Hint = hint, Reward = reward }
end

local function setCollapsed(value: boolean)
	collapsed = value
	refs.Body.Visible = not collapsed
	refs.Toggle.Text = if collapsed then "+" else "–"
	refs.Card.Size = UDim2.new(1, 0, 0, if collapsed then HEADER_HEIGHT else HEADER_HEIGHT + 8 + bodyHeight)
end

function QuestController.Init()
	refs = buildCard(UIController.GetSlot("Right"))
	refs.Toggle.Activated:Connect(function()
		setCollapsed(not collapsed)
	end)
	layout(MAX_TASKS)
end

function QuestController.Start()
	for _, key in { "Quests", "Flags" } do
		ClientState.Observe(key, refresh)
	end
	InputController.DeviceChanged:Connect(refresh)
end

return QuestController
