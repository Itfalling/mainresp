--[[
	SCRIPT NAME:  AdminService
	SCRIPT TYPE:  ModuleScript (server service)
	WHERE:        ServerScriptService/Server/Services/AdminService
	DEPENDENCIES: DataService, EconomyService, InventoryService, ProgressionService,
	              IslandService, ToolService, Shared.Config.GameConfig, Server.Util.Notify

	Secure chat commands (spec §139). Authorised = UserId in
	GameConfig.AdminUserIds, or anyone in Studio when AdminsInStudio = true.
	Commands are parsed on the SERVER — from server-created TextChatCommands
	(TextChatService) or Player.Chatted (legacy chat) — so nothing a client
	sends can run them. Every command goes through the normal services, so
	admin changes are validated, saved and replicated like any other change.

	  /givecoins <player|me> <amount>
	  /givegems <player|me> <amount>
	  /giveitem <player|me> <itemId> <amount>
	  /givetool <player|me> <toolId>
	  /givexp <player|me> <amount>
	  /giveislandxp <player|me> <amount>
	  /setislandlevel <player|me> <level>
	  /expand <player|me> <chunks>          (buys random adjacent land, coins provided)
	  /growcrops <player|me>              finish every planted crop
	  /finishbuilds <player|me>           complete every construction site
	  /spawnanimal <player|me> <Cow|Chicken>  (needs free housing, no charge)
	  /readyanimals <player|me>           make every animal's product ready
	  /save <player|me>
	  /resetdata <player|me>               (Studio only)
	  /debug [player|me]
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local TextChatService = game:GetService("TextChatService")

local Shared = ReplicatedStorage.Shared
local GameConfig = require(Shared.Config.GameConfig)
local IslandGen = require(Shared.Util.IslandGen)

local Services = script.Parent
local DataService = require(Services.DataService)
local EconomyService = require(Services.EconomyService)
local InventoryService = require(Services.InventoryService)
local ProgressionService = require(Services.ProgressionService)
local IslandService = require(Services.IslandService)
local ToolService = require(Services.ToolService)
local FarmService = require(Services.FarmService)
local BuildService = require(Services.BuildService)
local AnimalService = require(Services.AnimalService)
local Notify = require(script.Parent.Parent.Util.Notify)

local AdminService = {}

type Command = (admin: Player, args: { string }) -> string

local function isAdmin(player: Player): boolean
	if GameConfig.AdminsInStudio and RunService:IsStudio() then
		return true
	end
	return table.find(GameConfig.AdminUserIds, player.UserId) ~= nil
end

local function findPlayer(admin: Player, query: string?): Player?
	if not query or query == "" or string.lower(query) == "me" then
		return admin
	end
	local lowered = string.lower(query)
	for _, player in Players:GetPlayers() do
		if string.lower(player.Name) == lowered or string.lower(player.DisplayName) == lowered then
			return player
		end
	end
	for _, player in Players:GetPlayers() do
		if string.sub(string.lower(player.Name), 1, #lowered) == lowered then
			return player
		end
	end
	return nil
end

local function toInteger(text: string?): number?
	local value = tonumber(text)
	if value and value == value and math.abs(value) < 1e12 then
		return math.floor(value)
	end
	return nil
end

local COMMANDS: { [string]: Command } = {
	givecoins = function(admin, args)
		local target, amount = findPlayer(admin, args[1]), toInteger(args[2])
		if not target or not amount then
			return "Usage: /givecoins <player|me> <amount>"
		end
		return if EconomyService.AddCoins(target, amount, "Admin:" .. admin.Name) then "Gave coins" else "Failed"
	end,
	givegems = function(admin, args)
		local target, amount = findPlayer(admin, args[1]), toInteger(args[2])
		if not target or not amount then
			return "Usage: /givegems <player|me> <amount>"
		end
		return if EconomyService.AddGems(target, amount, "Admin:" .. admin.Name) then "Gave gems" else "Failed"
	end,
	giveitem = function(admin, args)
		local target, itemId, amount = findPlayer(admin, args[1]), args[2], toInteger(args[3] or "1")
		if not target or not itemId or not amount then
			return "Usage: /giveitem <player|me> <itemId> <amount>"
		end
		local added = InventoryService.AddItem(target, itemId, amount, "Admin:" .. admin.Name, { IgnoreCapacity = true })
		return ("Added %d %s"):format(added, itemId)
	end,
	givetool = function(admin, args)
		local target, toolId = findPlayer(admin, args[1]), args[2]
		if not target or not toolId then
			return "Usage: /givetool <player|me> <toolId>"
		end
		return if ToolService.GrantTool(target, toolId, "Admin:" .. admin.Name) then "Granted " .. toolId else "Unknown or already owned"
	end,
	givexp = function(admin, args)
		local target, amount = findPlayer(admin, args[1]), toInteger(args[2])
		if not target or not amount then
			return "Usage: /givexp <player|me> <amount>"
		end
		ProgressionService.AddPlayerXP(target, amount, "Admin")
		return "Gave XP"
	end,
	giveislandxp = function(admin, args)
		local target, amount = findPlayer(admin, args[1]), toInteger(args[2])
		if not target or not amount then
			return "Usage: /giveislandxp <player|me> <amount>"
		end
		ProgressionService.AddIslandXP(target, amount, "Admin")
		return "Gave island XP"
	end,
	setislandlevel = function(admin, args)
		local target, level = findPlayer(admin, args[1]), toInteger(args[2])
		if not target or not level then
			return "Usage: /setislandlevel <player|me> <level>"
		end
		ProgressionService.SetIslandLevel(target, level)
		return "Island level set"
	end,
	expand = function(admin, args)
		local target, count = findPlayer(admin, args[1]), toInteger(args[2] or "1")
		if not target or not count or count < 1 then
			return "Usage: /expand <player|me> <chunks>"
		end
		-- Buys random adjacent chunks through the real path (coins granted first).
		local done = 0
		for _ = 1, math.min(count, 50) do
			local chunks = DataService.Get(target, { "Island", "Chunks" }) or {}
			local candidates = IslandGen.ExpansionCandidates(chunks)
			if #candidates == 0 then
				break
			end
			local pick = candidates[math.random(1, #candidates)]
			local _, maxChunks, cost = IslandService.GetExpansionInfo(target)
			if IslandService.GetChunkCount(target) >= maxChunks then
				ProgressionService.SetIslandLevel(target, (DataService.Get(target, { "Island", "Level" }) or 1) + 1)
			end
			EconomyService.AddCoins(target, cost, "Admin:expand")
			local ok = IslandService.TryExpand(target, pick.X, pick.Z)
			if not ok then
				break
			end
			done += 1
			task.wait(0.8)
		end
		return ("Expanded %d chunk(s)"):format(done)
	end,
	growcrops = function(admin, args)
		local target = findPlayer(admin, args[1])
		if not target then
			return "Usage: /growcrops <player|me>"
		end
		FarmService.GrowAll(target)
		return "Crops grown"
	end,
	finishbuilds = function(admin, args)
		local target = findPlayer(admin, args[1])
		if not target then
			return "Usage: /finishbuilds <player|me>"
		end
		BuildService.FinishAll(target)
		return "Buildings finished"
	end,
	spawnanimal = function(admin, args)
		local target, animalId = findPlayer(admin, args[1]), args[2]
		if not target or not animalId then
			return "Usage: /spawnanimal <player|me> <Cow|Chicken>"
		end
		local ok, reason = AnimalService.AddAnimal(target, animalId)
		return if ok then "Spawned " .. animalId else tostring(reason)
	end,
	readyanimals = function(admin, args)
		local target = findPlayer(admin, args[1])
		if not target then
			return "Usage: /readyanimals <player|me>"
		end
		AnimalService.ReadyAll(target)
		return "Animals ready"
	end,
	save = function(admin, args)
		local target = findPlayer(admin, args[1])
		if not target then
			return "Usage: /save <player|me>"
		end
		return if DataService.SaveNow(target) then "Saved" else "Save failed (see output)"
	end,
	resetdata = function(admin, args)
		if not RunService:IsStudio() then
			return "resetdata is Studio-only"
		end
		local target = findPlayer(admin, args[1])
		if not target then
			return "Usage: /resetdata <player|me>"
		end
		DataService.ResetProfile(target)
		return "Profile reset — rejoin to rebuild the island"
	end,
	debug = function(admin, args)
		local target = findPlayer(admin, args[1])
		if not target then
			return "Player not found"
		end
		local island = IslandService.GetIsland(target)
		local data = DataService.GetData(target)
		local report = {
			Player = target.Name,
			IslandId = island and island.Id,
			Slot = island and island.SlotIndex,
			IslandLevel = data and data.Island.Level,
			Coins = data and data.Coins,
			Equipped = ToolService.GetEquippedId(target),
			Save = DataService.GetDebugState(target),
		}
		print("[Admin /debug]", HttpService:JSONEncode(report))
		return "Debug info printed to the server output"
	end,
}

local function onChatted(player: Player, message: string)
	if string.sub(message, 1, 1) ~= "/" then
		return
	end
	local parts = string.split(string.sub(message, 2), " ")
	local name = string.lower(table.remove(parts, 1) or "")
	local command = COMMANDS[name]
	if not command then
		return
	end
	if not isAdmin(player) then
		return
	end
	local ok, result = pcall(command, player, parts)
	if ok then
		Notify.Toast(player, "[Admin] " .. tostring(result), "🛠️")
	else
		warn("[AdminService] /" .. name .. " failed: " .. tostring(result))
		Notify.Error(player, "[Admin] Command failed")
	end
end

-- TextChatService: server-owned TextChatCommands fire Triggered on the server.
local function registerTextChatCommands()
	local folder = Instance.new("Folder")
	folder.Name = "IslandAdminCommands"
	for name in COMMANDS do
		local command = Instance.new("TextChatCommand")
		command.Name = name
		command.PrimaryAlias = "/" .. name
		command.AutocompleteVisible = false
		command.Triggered:Connect(function(source: TextSource, text: string)
			local player = Players:GetPlayerByUserId(source.UserId)
			if player then
				onChatted(player, text)
			end
		end)
		command.Parent = folder
	end
	folder.Parent = TextChatService
end

function AdminService.Start()
	if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
		registerTextChatCommands()
		return
	end
	local function hook(player: Player)
		player.Chatted:Connect(function(message)
			onChatted(player, message)
		end)
	end
	Players.PlayerAdded:Connect(hook)
	for _, player in Players:GetPlayers() do
		hook(player)
	end
end

return AdminService
