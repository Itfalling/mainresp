--[[
	SCRIPT NAME:  InventoryService
	SCRIPT TYPE:  ModuleScript (server service)
	WHERE:        ServerScriptService/Server/Services/InventoryService
	DEPENDENCIES: DataService, Shared.Config.{ItemConfig, GameConfig}, Shared.Util.Validate,
	              Server.Util.Notify

	Authoritative backpack. Only accepts item ids registered in ItemConfig,
	enforces capacity and stack limits, and offers atomic multi-item removal
	(HasItems / RemoveItems) for building costs and recipes, so a failed
	purchase can never leave the inventory half-charged.

	Item gain feedback ("+3 Wood") is shown by the client when it sees the
	replicated count go up.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Shared
local ItemConfig = require(Shared.Config.ItemConfig)
local GameConfig = require(Shared.Config.GameConfig)
local Validate = require(Shared.Util.Validate)

local Services = script.Parent
local DataService = require(Services.DataService)
local Notify = require(script.Parent.Parent.Util.Notify)

local InventoryService = {}

-- Stats keys bumped when specific items are gained.
local ITEM_STATS: { [string]: string } = {
	Wood = "WoodCollected",
	Stone = "StoneCollected",
}

local function getItems(player: Player): { [string]: number }?
	return DataService.Get(player, { "Inventory", "Items" })
end

function InventoryService.GetCount(player: Player, itemId: string): number
	local items = getItems(player)
	return items and items[itemId] or 0
end

function InventoryService.GetUsed(player: Player): number
	local items = getItems(player)
	local used = 0
	if items then
		for _, count in items do
			used += count
		end
	end
	return used
end

function InventoryService.GetCapacity(player: Player): number
	return DataService.Get(player, { "Inventory", "Capacity" }) or GameConfig.Inventory.StartingCapacity
end

function InventoryService.GetFreeSpace(player: Player): number
	return math.max(0, InventoryService.GetCapacity(player) - InventoryService.GetUsed(player))
end

-- Adds up to `amount`. Returns how many were actually added (0 if full / invalid).
function InventoryService.AddItem(player: Player, itemId: string, amount: number, reason: string, options: { IgnoreCapacity: boolean? }?): number
	if not ItemConfig.Exists(itemId) then
		warn(("[Inventory] Unknown item '%s' (%s)"):format(tostring(itemId), reason))
		return 0
	end
	if not Validate.Integer(amount, 1, GameConfig.Inventory.MaxStack) then
		warn(("[Inventory] Invalid amount %s for %s (%s)"):format(tostring(amount), itemId, reason))
		return 0
	end
	if not DataService.IsLoaded(player) then
		return 0
	end

	local current = InventoryService.GetCount(player, itemId)
	local room = GameConfig.Inventory.MaxStack - current
	if not (options and options.IgnoreCapacity) then
		room = math.min(room, InventoryService.GetFreeSpace(player))
	end
	local added = math.clamp(amount, 0, room)
	if added <= 0 then
		Notify.Error(player, "Your backpack is full!")
		return 0
	end

	DataService.Set(player, { "Inventory", "Items", itemId }, current + added)
	local statKey = ITEM_STATS[itemId]
	if statKey then
		DataService.Increment(player, { "Stats", statKey }, added)
	end
	if added < amount then
		Notify.Error(player, "Backpack full — some items didn't fit.")
	end
	if GameConfig.Debug then
		print(("[Inventory] %s +%d %s (%s)"):format(player.Name, added, itemId, reason))
	end
	return added
end

function InventoryService.RemoveItem(player: Player, itemId: string, amount: number, reason: string): boolean
	if not ItemConfig.Exists(itemId) or not Validate.Integer(amount, 1, GameConfig.Inventory.MaxStack) then
		return false
	end
	local current = InventoryService.GetCount(player, itemId)
	if current < amount then
		return false
	end
	local remaining = current - amount
	DataService.Set(player, { "Inventory", "Items", itemId }, if remaining > 0 then remaining else nil)
	if GameConfig.Debug then
		print(("[Inventory] %s -%d %s (%s)"):format(player.Name, amount, itemId, reason))
	end
	return true
end

-- cost = { Wood = 10, Stone = 5 }
function InventoryService.HasItems(player: Player, cost: { [string]: number }): boolean
	for itemId, amount in cost do
		if InventoryService.GetCount(player, itemId) < amount then
			return false
		end
	end
	return true
end

-- All-or-nothing removal.
function InventoryService.RemoveItems(player: Player, cost: { [string]: number }, reason: string): boolean
	if not InventoryService.HasItems(player, cost) then
		return false
	end
	for itemId, amount in cost do
		InventoryService.RemoveItem(player, itemId, amount, reason)
	end
	return true
end

return InventoryService
