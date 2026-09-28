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

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Shared
local EconomyConfig = require(Shared.Config.EconomyConfig)
local ItemConfig = require(Shared.Config.ItemConfig)
local GameConfig = require(Shared.Config.GameConfig)
local Validate = require(Shared.Util.Validate)

local Services = script.Parent
local DataService = require(Services.DataService)
local AntiExploitService = require(Services.AntiExploitService)
local Notify = require(script.Parent.Parent.Util.Notify)

local EconomyService = {}

-- itemId -> bonus (0.25 = +25%). Replicated via ReplicatedStorage attributes
-- "MarketDemand" (JSON) and "MarketDemandEndsAt" so the Sell UI shows it.
local demand: { [string]: number } = {}

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

function EconomyService.GetDemandBonus(itemId: string): number
	return demand[itemId] or 0
end

-- The ONE sell-price formula: item SellValue x global multiplier x demand.
function EconomyService.GetSellPrice(itemId: string): number
	local def = ItemConfig.Get(itemId)
	if not def or def.SellValue <= 0 then
		return 0
	end
	local price = def.SellValue * EconomyConfig.GlobalSellMultiplier * (1 + EconomyService.GetDemandBonus(itemId))
	return math.max(1, math.floor(price))
end

local function rollDemand()
	local candidates = {}
	for itemId, def in ItemConfig.Items do
		if EconomyConfig.DemandCategories[def.Category] then
			table.insert(candidates, itemId)
		end
	end
	table.sort(candidates)
	table.clear(demand)
	local random = Random.new()
	local announced = {}
	local encoded = {}
	for _ = 1, math.min(EconomyConfig.DemandItemCount, #candidates) do
		local itemId = table.remove(candidates, random:NextInteger(1, #candidates))
		local bonus = math.floor(random:NextNumber(EconomyConfig.DemandBonus.Min, EconomyConfig.DemandBonus.Max) * 20 + 0.5) / 20
		demand[itemId] = bonus
		table.insert(encoded, { Item = itemId, Bonus = bonus })
		table.insert(announced, ("%s +%d%%"):format(ItemConfig.Items[itemId].DisplayName, math.floor(bonus * 100 + 0.5)))
	end
	ReplicatedStorage:SetAttribute("MarketDemand", HttpService:JSONEncode(encoded))
	ReplicatedStorage:SetAttribute("MarketDemandEndsAt", os.time() + EconomyConfig.DemandInterval)
	for _, player in Players:GetPlayers() do
		Notify.Toast(player, "Market demand: " .. table.concat(announced, ", "), "📈")
	end
end

function EconomyService.Start()
	rollDemand()
	task.spawn(function()
		while true do
			task.wait(EconomyConfig.DemandInterval)
			rollDemand()
		end
	end)
end

return EconomyService
