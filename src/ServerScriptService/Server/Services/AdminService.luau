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
	  /unlockarea <player|me> <areaId>     (charges nothing; bypasses requirements)
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
local IslandConfig = require(Shared.Config.IslandConfig)

local Services = script.Parent
local DataService = require(Services.DataService)
local EconomyService = require(Services.EconomyService)
local InventoryService = require(Services.InventoryService)
local ProgressionService = require(Services.ProgressionService)
local IslandService = require(Services.IslandService)
local ToolService = require(Services.ToolService)
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
	unlockarea = function(admin, args)
		local target, areaId = findPlayer(admin, args[1]), args[2]
		if not target or not areaId or not IslandConfig.Areas[areaId] then
			return "Usage: /unlockarea <player|me> <areaId>"
		end
		local unlock = IslandConfig.Areas[areaId].Unlock
		-- Grant exactly what the unlock needs, then go through the real unlock path.
		if unlock then
			ProgressionService.SetIslandLevel(target, math.max(DataService.Get(target, { "Island", "Level" }) or 1, unlock.IslandLevel or 1))
			if unlock.RequiresArea then
				DataService.Set(target, { "Island", "UnlockedAreas", unlock.RequiresArea }, true)
			end
			if (unlock.Coins or 0) > 0 then
				EconomyService.AddCoins(target, unlock.Coins, "Admin:unlockarea")
			end
		end
		local ok, message = IslandService.TryUnlockArea(target, areaId)
		return if ok then "Unlocked " .. areaId else tostring(message)
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
