--[[
	SCRIPT NAME:  ShopService
	SCRIPT TYPE:  ModuleScript (server service)
	WHERE:        ServerScriptService/Server/Services/ShopService
	DEPENDENCIES: DataService, IslandService, EconomyService, InventoryService, ToolService,
	              AnimalService, FarmService, ProgressionService, InteractionService,
	              AntiExploitService, VFXService, Shared.Net, Shared.Config.{ShopConfig, ItemConfig}

	The island MARKET (spec §33, §64, §88, §89, §145). CLICK any market stall
	(yours, or a friend's while visiting) to open the Market UI.

	SELL  SellItemRequest(itemId, quantity) — itemId "__ALL__" sells every
	      crop / fish / animal product. The server checks you're at your stall,
	      removes the items, computes the price (EconomyService.GetSellPrice,
	      which includes market demand) and pays you. Never trusts a price.
	BUY   PurchaseRequest(shopItemId, quantity) — seeds, animals (needs
	      housing), tool upgrades, farm/backpack upgrades. Everything is checked
	      BEFORE anything is charged.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Shared
local Net = require(Shared.Net)
local ShopConfig = require(Shared.Config.ShopConfig)
local ItemConfig = require(Shared.Config.ItemConfig)
local Validate = require(Shared.Util.Validate)
local Format = require(Shared.Util.Format)
local Signal = require(Shared.Util.Signal)
local R15 = require(Shared.Util.R15)

local Services = script.Parent
local DataService = require(Services.DataService)
local IslandService = require(Services.IslandService)
local BuildService = require(Services.BuildService)
local EconomyService = require(Services.EconomyService)
local InventoryService = require(Services.InventoryService)
local ToolService = require(Services.ToolService)
local AnimalService = require(Services.AnimalService)
local ProgressionService = require(Services.ProgressionService)
local InteractionService = require(Services.InteractionService)
local AntiExploitService = require(Services.AntiExploitService)
local VFXService = require(Services.VFXService)
local Notify = require(script.Parent.Parent.Util.Notify)

local SELL_ALL = "__ALL__"
local MAX_QUANTITY = 9999

local ShopService = {}

ShopService.ItemsSold = Signal.new() -- (player, itemId, quantity, coins)
ShopService.Purchased = Signal.new() -- (player, shopItemId, def)

-- The market stall the player stands next to (any island), or nil.
local function nearbyStall(player: Player): Model?
	local root = R15.GetRootPart(player.Character)
	if not root then
		return nil
	end
	for _, island in IslandService.GetIslands() do
		local site = BuildService.FindSite(island, "MarketStall")
		if site and (root.Position - site.Model:GetPivot().Position).Magnitude <= ShopConfig.MarketRange then
			return site.Model
		end
	end
	return nil
end

local function atMarket(player: Player): boolean
	return nearbyStall(player) ~= nil
end

---------------------------------------------------------------------------
-- Selling
---------------------------------------------------------------------------

local function sellOne(player: Player, itemId: string, quantity: number): (number, number)
	local owned = InventoryService.GetCount(player, itemId)
	local amount = math.min(owned, quantity)
	if amount <= 0 then
		return 0, 0
	end
	local price = EconomyService.GetSellPrice(itemId)
	if price <= 0 then
		return 0, 0
	end
	if not InventoryService.RemoveItem(player, itemId, amount, "Sell") then
		return 0, 0
	end
	local coins = price * amount
	EconomyService.AddCoins(player, coins, "Sell:" .. itemId)
	DataService.Increment(player, { "Stats", "ItemsSold" }, amount)
	ShopService.ItemsSold:Fire(player, itemId, amount, coins)
	return amount, coins
end

function ShopService.Sell(player: Player, itemId: any, quantity: any)
	if not atMarket(player) then
		Notify.Error(player, "Go to your market stall to sell.")
		return
	end
	local soldItems, soldCoins = 0, 0
	if itemId == SELL_ALL then
		local items = DataService.Get(player, { "Inventory", "Items" }) or {}
		for id, count in table.clone(items) do
			local def = ItemConfig.Get(id)
			if def and ShopConfig.SellAllCategories[def.Category] then
				local amount, coins = sellOne(player, id, count)
				soldItems += amount
				soldCoins += coins
			end
		end
	else
		if not Validate.Id(itemId) or not ItemConfig.Exists(itemId) then
			AntiExploitService.Flag(player, "SellUnknownItem", 2)
			return
		end
		local count = if quantity == "All" then MAX_QUANTITY else quantity
		if not Validate.Integer(count, 1, MAX_QUANTITY) then
			AntiExploitService.Flag(player, "SellBadQuantity", 2)
			return
		end
		soldItems, soldCoins = sellOne(player, itemId, count)
	end

	if soldItems <= 0 then
		Notify.Error(player, "Nothing to sell.")
		return
	end
	ProgressionService.Award(player, "SellItems")
	local stall = nearbyStall(player)
	if stall then
		VFXService.PlayAt("CoinBurst", stall:GetPivot().Position + Vector3.new(0, 4, 0))
	end
	Notify.Success(player, ("Sold %d item%s for %s 🪙"):format(soldItems, if soldItems == 1 then "" else "s", Format.Commas(soldCoins)), "💰")
end

---------------------------------------------------------------------------
-- Buying
---------------------------------------------------------------------------

local function upgradeCount(player: Player, upgradeId: string): number
	return DataService.Get(player, { "Island", "Upgrades", upgradeId }) or 0
end

-- Returns (ok, reason). Validates everything except the price.
local function canGrant(player: Player, def: any, quantity: number): (boolean, string?)
	local grant = def.Grant
	if grant.Tool then
		if ToolService.HasTool(player, grant.Tool) then
			return false, "You already own that."
		end
	elseif grant.Animal then
		return AnimalService.CanAdd(player, grant.Animal)
	elseif grant.Upgrade then
		if def.MaxOwned and upgradeCount(player, grant.Upgrade) >= def.MaxOwned then
			return false, "You already have the biggest upgrade."
		end
	elseif grant.Item then
		if InventoryService.GetFreeSpace(player) < grant.Amount * quantity then
			return false, "Your backpack is too full."
		end
	end
	return true, nil
end

local function grantItem(player: Player, def: any, quantity: number)
	local grant = def.Grant
	if grant.Item then
		InventoryService.AddItem(player, grant.Item, grant.Amount * quantity, "Purchase")
	elseif grant.Tool then
		ToolService.GrantTool(player, grant.Tool, "Purchase")
	elseif grant.Animal then
		AnimalService.AddAnimal(player, grant.Animal)
		-- The first cow comes with a bucket so milking works straight away.
		if grant.Animal == "Cow" and not ToolService.GetBestTool(player, "Bucket") then
			ToolService.GrantTool(player, "WoodenBucket", "CowBonus")
			Notify.Toast(player, "Free Wooden Bucket included for milking!", "🪣")
		end
	elseif grant.Upgrade == "Capacity" then
		InventoryService.AddCapacity(player, grant.Amount)
		DataService.Increment(player, { "Island", "Upgrades", "Capacity" }, 1)
	end
end

function ShopService.Purchase(player: Player, shopItemId: any, quantity: any)
	if not Validate.Id(shopItemId) then
		AntiExploitService.Flag(player, "BadPurchase", 2)
		return
	end
	local def = ShopConfig.Items[shopItemId]
	if not def then
		AntiExploitService.Flag(player, "BadPurchase", 2)
		return
	end
	local count = if def.Grant.Item then quantity else 1
	if not Validate.Integer(count, 1, 50) then
		AntiExploitService.Flag(player, "BadPurchaseQuantity", 2)
		return
	end
	if not atMarket(player) then
		Notify.Error(player, "Go to your market stall to shop.")
		return
	end
	local islandLevel = DataService.Get(player, { "Island", "Level" }) or 1
	if islandLevel < (def.UnlockLevel or 1) then
		Notify.Error(player, ("%s unlocks at Island Level %d."):format(def.DisplayName, def.UnlockLevel))
		return
	end
	local ok, reason = canGrant(player, def, count)
	if not ok then
		Notify.Error(player, reason or "You can't buy that right now.")
		return
	end

	local coins = def.Price * count
	local items = {}
	for itemId, amount in def.Items or {} do
		items[itemId] = amount * count
	end
	if not EconomyService.CanAfford(player, coins) then
		Notify.Error(player, ("You need %s 🪙."):format(Format.Commas(coins)))
		return
	end
	if not InventoryService.HasItems(player, items) then
		Notify.Error(player, "You don't have the materials for that.")
		return
	end
	if not EconomyService.SpendCoins(player, coins, "Buy:" .. shopItemId) then
		return
	end
	if not InventoryService.RemoveItems(player, items, "Buy:" .. shopItemId) then
		EconomyService.AddCoins(player, coins, "BuyRefund")
		return
	end

	grantItem(player, def, count)
	if not def.Grant.Animal then
		Notify.Success(player, ("Bought %s%s!"):format(if count > 1 then count .. "x " else "", def.DisplayName), def.Icon)
	end
	ShopService.Purchased:Fire(player, shopItemId, def)
end

---------------------------------------------------------------------------
-- Market stall (click to open)
---------------------------------------------------------------------------

function ShopService.Init()
	InteractionService.RegisterKind("Market", {
		Permission = "Market",
		MaxDistance = 10,
		Cooldown = 0.5,
		Handler = function(player: Player)
			Net.FireClient("OpenUI", player, { Screen = "Market", Tab = "Sell" })
		end,
	})
	Net.OnServerEvent("SellItemRequest", ShopService.Sell)
	Net.OnServerEvent("PurchaseRequest", ShopService.Purchase)
end

function ShopService.Start()
	BuildService.SiteReady:Connect(function(site: any)
		if site.BuildingId == "MarketStall" then
			InteractionService.Attach(site.Model, "Market", { OwnerUserId = site.OwnerUserId, Label = "Market Stall" })
		end
	end)
end

return ShopService
