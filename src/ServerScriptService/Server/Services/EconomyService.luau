--[[
	SCRIPT NAME:  EconomyService
	SCRIPT TYPE:  ModuleScript (server service)
	WHERE:        ServerScriptService/Server/Services/EconomyService
	DEPENDENCIES: DataService, AntiExploitService, Shared.Config.EconomyConfig,
	              Shared.Util.Validate

	THE ONLY system that changes Coins or Gems (spec §165). Every change
	carries a `reason` string for logs/debugging. Amounts always come from
	server config — a client can never name an amount.

	Coin gain feedback (floating "+N", counter bounce, coin sound) is driven
	on the client by watching the replicated Coins value, so every source of
	income gets consistent feedback automatically.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Shared
local EconomyConfig = require(Shared.Config.EconomyConfig)
local GameConfig = require(Shared.Config.GameConfig)
local Validate = require(Shared.Util.Validate)

local Services = script.Parent
local DataService = require(Services.DataService)
local AntiExploitService = require(Services.AntiExploitService)

local EconomyService = {}

local function log(player: Player, currency: string, delta: number, reason: string)
	if GameConfig.Debug then
		print(("[Economy] %s %s%d %s (%s)"):format(player.Name, if delta >= 0 then "+" else "", delta, currency, reason))
	end
end

local function add(player: Player, currency: string, amount: number, reason: string): boolean
	local currencyDef = EconomyConfig.Currencies[currency]
	assert(currencyDef, "Unknown currency " .. currency)
	if not Validate.Integer(amount, 1, currencyDef.Max) then
		warn(("[Economy] Rejected invalid %s amount %s (%s)"):format(currency, tostring(amount), reason))
		return false
	end
	local current = DataService.Get(player, { currency })
	if type(current) ~= "number" then
		return false
	end
	local newValue = math.min(current + amount, currencyDef.Max)
	local gained = newValue - current
	if gained <= 0 then
		return false
	end
	DataService.Set(player, { currency }, newValue)
	if currency == "Coins" then
		DataService.Increment(player, { "Stats", "CoinsEarned" }, gained)
	end
	AntiExploitService.RecordCurrencyChange(player, currency, gained, reason)
	log(player, currency, gained, reason)
	return true
end

local function spend(player: Player, currency: string, amount: number, reason: string): boolean
	local currencyDef = EconomyConfig.Currencies[currency]
	assert(currencyDef, "Unknown currency " .. currency)
	if not Validate.Integer(amount, 0, currencyDef.Max) then
		warn(("[Economy] Rejected invalid spend %s (%s)"):format(tostring(amount), reason))
		return false
	end
	if amount == 0 then
		return true
	end
	local current = DataService.Get(player, { currency })
	if type(current) ~= "number" or current < amount then
		return false
	end
	DataService.Set(player, { currency }, current - amount)
	log(player, currency, -amount, reason)
	return true
end

function EconomyService.GetCoins(player: Player): number
	return DataService.Get(player, { "Coins" }) or 0
end

function EconomyService.GetGems(player: Player): number
	return DataService.Get(player, { "Gems" }) or 0
end

function EconomyService.CanAfford(player: Player, coins: number): boolean
	return EconomyService.GetCoins(player) >= coins
end

function EconomyService.AddCoins(player: Player, amount: number, reason: string): boolean
	return add(player, "Coins", amount, reason)
end

-- Returns false (and changes nothing) if the player can't afford it.
function EconomyService.SpendCoins(player: Player, amount: number, reason: string): boolean
	return spend(player, "Coins", amount, reason)
end

function EconomyService.AddGems(player: Player, amount: number, reason: string): boolean
	return add(player, "Gems", amount, reason)
end

function EconomyService.SpendGems(player: Player, amount: number, reason: string): boolean
	return spend(player, "Gems", amount, reason)
end

return EconomyService
