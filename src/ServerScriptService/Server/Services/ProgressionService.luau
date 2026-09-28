--[[
	SCRIPT NAME:  ProgressionService
	SCRIPT TYPE:  ModuleScript (server service)
	WHERE:        ServerScriptService/Server/Services/ProgressionService
	DEPENDENCIES: DataService, SoundService, VFXService, Shared.Config.ProgressionConfig,
	              Server.Util.Notify

	Player XP/level and Island XP/level. XP is only ever awarded by SOURCE id
	(ProgressionConfig.Sources) — the amount is decided here, never by a
	client (spec §42). Phase 11 extends this with achievements/titles.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Shared
local ProgressionConfig = require(Shared.Config.ProgressionConfig)
local GameConfig = require(Shared.Config.GameConfig)
local Signal = require(Shared.Util.Signal)

local Services = script.Parent
local DataService = require(Services.DataService)
local GameSoundService = require(Services.SoundService)
local VFXService = require(Services.VFXService)
local Notify = require(script.Parent.Parent.Util.Notify)

local ProgressionService = {}

ProgressionService.PlayerLevelUp = Signal.new() -- (player, newLevel)
ProgressionService.IslandLevelUp = Signal.new() -- (player, newLevel)

local function characterPosition(player: Player): Vector3?
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if root and root:IsA("BasePart") then
		return root.Position - Vector3.new(0, 2.5, 0)
	end
	return nil
end

local function applyXP(player: Player, xpPath: { string }, levelPath: { string }, amount: number, maxLevel: number, xpForLevel: (number) -> number): number?
	local xp = DataService.Get(player, xpPath)
	local level = DataService.Get(player, levelPath)
	if type(xp) ~= "number" or type(level) ~= "number" then
		return nil
	end
	xp += amount
	local startLevel = level
	while level < maxLevel and xp >= xpForLevel(level) do
		xp -= xpForLevel(level)
		level += 1
	end
	if level >= maxLevel then
		xp = 0
	end
	DataService.Set(player, xpPath, xp)
	if level ~= startLevel then
		DataService.Set(player, levelPath, level)
		return level
	end
	return nil
end

function ProgressionService.AddPlayerXP(player: Player, amount: number, reason: string)
	if amount <= 0 then
		return
	end
	local newLevel = applyXP(player, { "XP" }, { "Level" }, math.floor(amount), ProgressionConfig.Player.MaxLevel, ProgressionConfig.PlayerXPForLevel)
	if newLevel then
		Notify.Banner(player, "LEVEL UP!", ("You reached level %d"):format(newLevel), "LevelUp")
		GameSoundService.PlayFor(player, "LevelUp")
		local position = characterPosition(player)
		if position then
			VFXService.PlayAt("LevelUp", position)
			VFXService.PlayAt("Confetti", position + Vector3.new(0, 4, 0))
		end
		ProgressionService.PlayerLevelUp:Fire(player, newLevel)
	end
	if GameConfig.Debug then
		print(("[Progression] %s +%d player XP (%s)"):format(player.Name, amount, reason))
	end
end

function ProgressionService.AddIslandXP(player: Player, amount: number, reason: string)
	if amount <= 0 then
		return
	end
	local newLevel = applyXP(
		player,
		{ "Island", "XP" },
		{ "Island", "Level" },
		math.floor(amount),
		ProgressionConfig.Island.MaxLevel,
		ProgressionConfig.IslandXPForLevel
	)
	if newLevel then
		Notify.Banner(player, "ISLAND LEVEL UP!", ("Island Level %d — %s"):format(newLevel, ProgressionConfig.GetIslandTitle(newLevel)), "IslandLevelUp")
		GameSoundService.PlayFor(player, "IslandLevelUp")
		local position = characterPosition(player)
		if position then
			VFXService.PlayAt("IslandLevelUp", position)
		end
		ProgressionService.IslandLevelUp:Fire(player, newLevel)
	end
	if GameConfig.Debug then
		print(("[Progression] %s +%d island XP (%s)"):format(player.Name, amount, reason))
	end
end

-- Award XP for a configured source, e.g. Award(player, "StarterChest").
function ProgressionService.Award(player: Player, sourceId: string, multiplier: number?)
	local source = ProgressionConfig.Sources[sourceId]
	if not source then
		warn("[Progression] Unknown XP source " .. tostring(sourceId))
		return
	end
	local scale = multiplier or 1
	if source.Player then
		ProgressionService.AddPlayerXP(player, source.Player * scale, sourceId)
	end
	if source.Island then
		ProgressionService.AddIslandXP(player, source.Island * scale, sourceId)
	end
end

-- Admin/debug helper.
function ProgressionService.SetIslandLevel(player: Player, level: number)
	local clamped = math.clamp(math.floor(level), 1, ProgressionConfig.Island.MaxLevel)
	DataService.Set(player, { "Island", "XP" }, 0)
	DataService.Set(player, { "Island", "Level" }, clamped)
end

return ProgressionService
