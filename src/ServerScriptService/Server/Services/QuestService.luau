--[[
	SCRIPT NAME:  QuestService
	SCRIPT TYPE:  ModuleScript (server service)
	WHERE:        ServerScriptService/Server/Services/QuestService
	DEPENDENCIES: DataService, EconomyService, InventoryService, ProgressionService, IslandService,
	              BuildService, FarmService, FishingService, AnimalService, ShopService,
	              SoundService, VFXService, Shared.Config.QuestConfig

	Progression quests = the tutorial (spec §43, §118, §119). The chain in
	QuestConfig walks a new player through the whole core loop:
	gather → build → farm → fish → sell → animals → expand.

	Progress is ONLY recorded from server-side signals (an item was really
	gathered, a building really completed...). Clients can't report progress.
	State-based tasks (own a building, island level, unlocked area) are also
	synced when a quest starts so nothing already done has to be redone.

	Saved: Quests.Current, Quests.Progress[taskId], Quests.Completed[questId].
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Shared
local QuestConfig = require(Shared.Config.QuestConfig)
local Format = require(Shared.Util.Format)
local R15 = require(Shared.Util.R15)

local Services = script.Parent
local DataService = require(Services.DataService)
local EconomyService = require(Services.EconomyService)
local InventoryService = require(Services.InventoryService)
local ProgressionService = require(Services.ProgressionService)
local IslandService = require(Services.IslandService)
local BuildService = require(Services.BuildService)
local FarmService = require(Services.FarmService)
local FishingService = require(Services.FishingService)
local AnimalService = require(Services.AnimalService)
local ShopService = require(Services.ShopService)
local GameSoundService = require(Services.SoundService)
local VFXService = require(Services.VFXService)
local Notify = require(script.Parent.Parent.Util.Notify)

local QuestService = {}

local function currentQuest(player: Player): any
	local questId = DataService.Get(player, { "Quests", "Current" })
	return if type(questId) == "string" then QuestConfig.Quests[questId] else nil
end

local function progressOf(player: Player, taskId: string): number
	return DataService.Get(player, { "Quests", "Progress", taskId }) or 0
end

local function isComplete(player: Player, quest: any): boolean
	for _, questTask in quest.Tasks do
		if progressOf(player, questTask.Id) < questTask.Amount then
			return false
		end
	end
	return true
end

local startQuest: (Player, string?) -> ()

local function completeQuest(player: Player, quest: any)
	DataService.Set(player, { "Quests", "Completed", quest.Id }, true)
	DataService.Increment(player, { "Stats", "QuestsCompleted" }, 1)
	local reward = quest.Reward
	if reward.Coins then
		EconomyService.AddCoins(player, reward.Coins, "Quest:" .. quest.Id)
	end
	if reward.XP then
		ProgressionService.AddPlayerXP(player, reward.XP, "Quest:" .. quest.Id)
	end
	if reward.IslandXP then
		ProgressionService.AddIslandXP(player, reward.IslandXP, "Quest:" .. quest.Id)
	end
	for itemId, amount in reward.Items or {} do
		InventoryService.AddItem(player, itemId, amount, "Quest:" .. quest.Id, { IgnoreCapacity = true })
	end
	Notify.Banner(player, "QUEST COMPLETE!", ("%s — +%s 🪙"):format(quest.DisplayName, Format.Commas(reward.Coins or 0)), "Reward")
	GameSoundService.PlayFor(player, "QuestComplete")
	local root = R15.GetRootPart(player.Character)
	if root then
		VFXService.PlayAt("Sparkle", root.Position + Vector3.new(0, 2, 0))
	end
	startQuest(player, QuestConfig.NextQuest(quest.Id))
end

local function setProgress(player: Player, quest: any, questTask: any, value: number)
	local clamped = math.clamp(math.floor(value), 0, questTask.Amount)
	if clamped == progressOf(player, questTask.Id) then
		return
	end
	DataService.Set(player, { "Quests", "Progress", questTask.Id }, clamped)
	if clamped >= questTask.Amount then
		Notify.Success(player, "✔ " .. questTask.Text, "📜")
	end
	if isComplete(player, quest) then
		completeQuest(player, quest)
	end
end

-- Records an event. targets = every id this event matches (e.g. {"Barn", "Farm"}).
function QuestService.Record(player: Player, event: string, targets: { string }?, amount: number?)
	local quest = currentQuest(player)
	if not quest then
		return
	end
	for _, questTask in quest.Tasks do
		if questTask.Event == event and (questTask.Target == nil or (targets ~= nil and table.find(targets, questTask.Target) ~= nil)) then
			if event == "IslandLevel" then
				setProgress(player, quest, questTask, math.max(progressOf(player, questTask.Id), amount or 0))
			else
				setProgress(player, quest, questTask, progressOf(player, questTask.Id) + (amount or 1))
			end
			quest = currentQuest(player)
			if not quest then
				return
			end
		end
	end
end

-- Credits things the player has already done (buildings, level, areas).
local function syncState(player: Player)
	local quest = currentQuest(player)
	if not quest then
		return
	end
	for _, questTask in quest.Tasks do
		local value: number? = nil
		if questTask.Event == "IslandLevel" then
			value = DataService.Get(player, { "Island", "Level" }) or 1
		elseif questTask.Event == "UnlockArea" and questTask.Target then
			value = if IslandService.IsAreaUnlocked(player, questTask.Target) then 1 else 0
		elseif questTask.Event == "BuildComplete" and questTask.Target then
			value = BuildService.CountComplete(player, questTask.Target, nil) + BuildService.CountComplete(player, nil, questTask.Target)
		end
		if value and value > progressOf(player, questTask.Id) then
			setProgress(player, quest, questTask, value)
			if currentQuest(player) ~= quest then
				return
			end
		end
	end
end

startQuest = function(player: Player, questId: string?)
	DataService.Set(player, { "Quests", "Progress" }, {})
	DataService.Set(player, { "Quests", "Current" }, questId or "")
	if not questId then
		Notify.Banner(player, "ALL QUESTS DONE!", "Keep growing your island — more quests coming soon.", "Reward")
		return
	end
	local quest = QuestConfig.Quests[questId]
	task.delay(3, function()
		if player.Parent and DataService.Get(player, { "Quests", "Current" }) == questId then
			Notify.Toast(player, "New quest: " .. quest.DisplayName, "📜")
		end
	end)
	syncState(player)
end

function QuestService.Start()
	InventoryService.ItemAdded:Connect(function(player: Player, itemId: string, amount: number, reason: string)
		if string.sub(reason, 1, 7) == "Gather:" then
			QuestService.Record(player, "CollectItem", { itemId }, amount)
		end
	end)
	BuildService.BuildingCompleted:Connect(function(player: Player, buildingId: string, def: any)
		QuestService.Record(player, "BuildComplete", { buildingId, def.Category }, 1)
	end)
	FarmService.CropPlanted:Connect(function(player: Player, cropId: string)
		QuestService.Record(player, "PlantCrop", { cropId }, 1)
	end)
	FarmService.CropHarvested:Connect(function(player: Player, cropId: string, amount: number)
		QuestService.Record(player, "HarvestCrop", { cropId }, amount)
	end)
	FishingService.FishCaught:Connect(function(player: Player, fishId: string)
		QuestService.Record(player, "CatchFish", { fishId }, 1)
	end)
	ShopService.ItemsSold:Connect(function(player: Player, itemId: string, quantity: number)
		QuestService.Record(player, "SellItem", { itemId }, quantity)
	end)
	ShopService.Purchased:Connect(function(player: Player, shopItemId: string, def: any)
		if def.Grant.Tool then
			QuestService.Record(player, "BuyTool", { shopItemId, def.Grant.Tool }, 1)
		end
	end)
	AnimalService.AnimalAdded:Connect(function(player: Player, animalId: string)
		QuestService.Record(player, "BuyAnimal", { animalId }, 1)
	end)
	AnimalService.AnimalFed:Connect(function(player: Player, animalId: string)
		QuestService.Record(player, "FeedAnimal", { animalId }, 1)
	end)
	AnimalService.ProduceCollected:Connect(function(player: Player, animalId: string, itemId: string, amount: number)
		QuestService.Record(player, "CollectProduce", { itemId, animalId }, amount)
	end)
	IslandService.AreaUnlocked:Connect(function(player: Player, areaId: string)
		QuestService.Record(player, "UnlockArea", { areaId }, 1)
	end)
	ProgressionService.IslandLevelUp:Connect(function(player: Player, level: number)
		QuestService.Record(player, "IslandLevel", nil, level)
	end)
	IslandService.IslandAssigned:Connect(function(player: Player)
		-- Wait for buildings to load before crediting state-based tasks.
		task.delay(1, function()
			if player.Parent then
				syncState(player)
			end
		end)
	end)
end

return QuestService
