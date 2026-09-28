--[[
	SCRIPT NAME:  PlayerService
	SCRIPT TYPE:  ModuleScript (server service)
	WHERE:        ServerScriptService/Server/Services/PlayerService
	DEPENDENCIES: DataService, IslandService, ToolService, AnimationService, AntiExploitService,
	              Shared.Config.GameConfig, Shared.Util.R15
	REQUIRED OBJECTS: Players.CharacterAutoLoads = false (set in default.project.json and here)

	Orchestrates the player lifecycle in a fixed, safe order:

	JOIN:   load profile -> (new players: Island Creator) -> assign island -> leaderstats
	        -> spawn R15 character on the island
	SPAWN:  enforce R15 -> move to island spawn -> movement anim overrides -> re-equip tool
	DEATH:  respawn on own island after RespawnDelay
	LEAVE:  unequip -> final save + lock release -> island cleanup (AFTER the save)

	R15 (spec §3): Game Settings > Avatar should be set to R15. If a non-R15
	character still appears and GameConfig.Character.ForceR15 is on, it is
	rebuilt as R15 from the player's HumanoidDescription.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

local Shared = ReplicatedStorage.Shared
local GameConfig = require(Shared.Config.GameConfig)
local Net = require(Shared.Net)
local R15 = require(Shared.Util.R15)
local Signal = require(Shared.Util.Signal)
local Validate = require(Shared.Util.Validate)

local Services = script.Parent
local DataService = require(Services.DataService)
local IslandService = require(Services.IslandService)
local ToolService = require(Services.ToolService)
local AnimationService = require(Services.AnimationService)
local AntiExploitService = require(Services.AntiExploitService)

local CharacterConfig = GameConfig.Character

local PlayerService = {}

PlayerService.CharacterSpawned = Signal.new() -- (player, character) after placement on the island

local respawning: { [Player]: boolean } = {}
local convertingToR15: { [Player]: boolean } = {}

local function setupLeaderstats(player: Player)
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	local coins = Instance.new("IntValue")
	coins.Name = "Coins"
	coins.Value = DataService.Get(player, { "Coins" }) or 0
	coins.Parent = leaderstats
	local islandLevel = Instance.new("IntValue")
	islandLevel.Name = "Island Lv"
	islandLevel.Value = DataService.Get(player, { "Island", "Level" }) or 1
	islandLevel.Parent = leaderstats
	leaderstats.Parent = player
end

local function updateLeaderstats(player: Player, path: { string }, value: any)
	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats or type(value) ~= "number" then
		return
	end
	local statName = nil
	if path[1] == "Coins" and #path == 1 then
		statName = "Coins"
	elseif path[1] == "Island" and path[2] == "Level" then
		statName = "Island Lv"
	end
	local stat = statName and leaderstats:FindFirstChild(statName)
	if stat and stat:IsA("IntValue") then
		stat.Value = math.min(value, 2 ^ 31 - 1)
	end
end

-- Rebuilds a non-R15 character as R15 from the player's avatar description.
local function convertToR15(player: Player, oldCharacter: Model): boolean
	if convertingToR15[player] then
		return false
	end
	convertingToR15[player] = true

	local description: HumanoidDescription? = nil
	if player.UserId > 0 then
		local ok, result = pcall(Players.GetHumanoidDescriptionFromUserId, Players, player.UserId)
		if ok then
			description = result
		end
	end
	local ok, model = pcall(Players.CreateHumanoidModelFromDescription, Players, description or Instance.new("HumanoidDescription"), Enum.HumanoidRigType.R15)
	if not ok or not model then
		warn("[PlayerService] Could not build an R15 character for " .. player.Name .. ": " .. tostring(model))
		convertingToR15[player] = false
		return false
	end

	model.Name = player.Name
	if not model:FindFirstChild("Animate") then
		local template = StarterPlayer:FindFirstChild("StarterCharacterScripts")
		local animate = template and template:FindFirstChild("Animate")
		if animate then
			animate:Clone().Parent = model
		else
			warn("[PlayerService] R15 character has no Animate script. Set Game Settings > Avatar to R15.")
		end
	end
	model:PivotTo(oldCharacter:GetPivot())
	player.Character = model
	model.Parent = workspace
	oldCharacter:Destroy()
	convertingToR15[player] = false
	return true
end

-- Prefer the modern LoadCharacterAsync; if it's missing or errors, use LoadCharacter.
local function loadCharacter(player: Player): (boolean, any)
	local ok, err = pcall(function()
		(player :: any):LoadCharacterAsync()
	end)
	if ok then
		return true, nil
	end
	local fallbackOk, fallbackErr = pcall(function()
		(player :: any):LoadCharacter()
	end)
	if fallbackOk then
		return true, nil
	end
	return false, tostring(err) .. " | " .. tostring(fallbackErr)
end

local function spawnCharacter(player: Player)
	if player.Parent == nil or respawning[player] then
		return
	end
	respawning[player] = true
	local spawnCFrame = IslandService.GetSpawnCFrame(player)
	if spawnCFrame then
		pcall(player.RequestStreamAroundAsync, player, spawnCFrame.Position, 5)
	end
	local ok, err = loadCharacter(player)
	respawning[player] = false
	if not ok then
		warn("[PlayerService] LoadCharacter failed for " .. player.Name .. ": " .. tostring(err))
	end
end

local function onCharacterAdded(player: Player, character: Model)
	local humanoid = character:WaitForChild("Humanoid", 10)
	local root = character:WaitForChild("HumanoidRootPart", 10)
	if not humanoid or not root or not humanoid:IsA("Humanoid") then
		warn("[PlayerService] Character for " .. player.Name .. " is missing Humanoid/HumanoidRootPart")
		return
	end

	if CharacterConfig.RequireR15 and not R15.IsR15(character) then
		warn(("[PlayerService] %s spawned with a non-R15 rig. Set Game Settings > Avatar > Avatar Type to R15."):format(player.Name))
		if CharacterConfig.ForceR15 and convertToR15(player, character) then
			return -- CharacterAdded fires again for the new R15 model
		end
	end

	humanoid.WalkSpeed = CharacterConfig.WalkSpeed
	humanoid.UseJumpPower = false
	humanoid.JumpHeight = CharacterConfig.JumpHeight

	local spawnCFrame = IslandService.GetSpawnCFrame(player)
	if spawnCFrame then
		AntiExploitService.AllowTeleport(player)
		character:PivotTo(spawnCFrame)
	end

	AnimationService.ApplyMovementOverrides(character)
	ToolService.OnCharacterSpawned(player, character)
	PlayerService.CharacterSpawned:Fire(player, character)

	humanoid.Died:Once(function()
		task.delay(CharacterConfig.RespawnDelay, function()
			if player.Parent and player.Character == character then
				spawnCharacter(player)
			end
		end)
	end)
end

local function onPlayerAdded(player: Player)
	player.CharacterAdded:Connect(function(character)
		onCharacterAdded(player, character)
	end)

	local data = DataService.LoadProfile(player)
	if not data or player.Parent == nil then
		return
	end
	-- New players design their island first (client shows the Island Creator).
	if not IslandService.WaitForCreation(player) then
		return
	end

	local built, islandOrError = pcall(IslandService.AssignIsland, player)
	if not built then
		warn("[PlayerService] Island build failed for " .. player.Name .. ": " .. tostring(islandOrError))
		if player.Parent then
			player:Kick("Your island failed to build. Error: " .. tostring(islandOrError))
		end
		return
	end
	local island = islandOrError
	if not island then
		if player.Parent then
			player:Kick("This server has no free islands right now. Please join another server.")
		end
		return
	end

	setupLeaderstats(player)
	spawnCharacter(player)
end

local function onPlayerRemoving(player: Player)
	ToolService.OnPlayerRemoving(player)
	DataService.ReleaseProfile(player) -- yields until the final save completes
	IslandService.ReleaseIsland(player) -- only after the island's data is safe
	respawning[player] = nil
	convertingToR15[player] = nil
end

local EMOTES = { Wave = true, Cheer = true, Point = true, Dance = true }

function PlayerService.Init()
	Players.CharacterAutoLoads = false

	Net.OnServerEvent("EmoteRequest", function(player: Player, name: any)
		local character = player.Character
		if type(name) == "string" and EMOTES[name] and character and R15.IsAlive(character) and not AnimationService.IsBusy(player) then
			AnimationService.PlayAnimation(character, name)
		end
	end)
	Net.OnServerEvent("SettingsRequest", function(player: Player, payload: any)
		if type(payload) ~= "table" then
			return
		end
		for key, value in payload do
			if (key == "MusicVolume" or key == "SfxVolume") and Validate.Number(value, 0, 1) then
				DataService.Set(player, { "Settings", key }, value)
			elseif key == "CameraShake" and type(value) == "boolean" then
				DataService.Set(player, { "Settings", key }, value)
			end
		end
	end)
end

function PlayerService.Start()
	DataService.Changed:Connect(updateLeaderstats)

	Players.PlayerAdded:Connect(onPlayerAdded)
	Players.PlayerRemoving:Connect(onPlayerRemoving)
	for _, player in Players:GetPlayers() do
		task.spawn(onPlayerAdded, player)
	end

	-- Play time statistic.
	task.spawn(function()
		while true do
			task.wait(60)
			for _, player in Players:GetPlayers() do
				if DataService.IsLoaded(player) then
					DataService.Increment(player, { "Stats", "PlayTime" }, 60)
				end
			end
		end
	end)
end

return PlayerService
