--[[
	SCRIPT NAME:  TradeService
	SCRIPT TYPE:  ModuleScript (server service)
	WHERE:        ServerScriptService/Server/Services/TradeService
	DEPENDENCIES: DataService, InventoryService, EconomyService, AntiExploitService, SoundService,
	              Shared.Net, Shared.Config.{ItemConfig, GameConfig}, Shared.Util.Validate, Server.Util.Notify

	Safe player-to-player TRADING (items + coins).

	  TradeRequest{Op="Invite", UserId}              send an invite (expires in 30s)
	  TradeRequest{Op="Respond", UserId, Accept}     accept / decline an invite
	  TradeRequest{Op="Offer", ItemId, Amount}       set how many of an item you offer (0 removes)
	  TradeRequest{Op="Coins", Amount}               set your coin offer
	  TradeRequest{Op="Ready", Ready}                lock in / unlock
	  TradeRequest{Op="Cancel"}

	SCAM PROTECTION
	  * ANY change to either offer un-readies BOTH players,
	  * when both are ready a 3-second countdown runs (TradeEvent shows it);
	    any change cancels the countdown,
	  * at the end the server RE-CHECKS that both players still have every
	    item and coin, and that both backpacks have room, then removes
	    everything first and only then hands it over (atomic, all-or-nothing),
	  * leaving the game, dying or disconnecting cancels the trade.
	The client only ever shows the state the server sends (TradeEvent).
]]

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Shared
local Net = require(Shared.Net)
local ItemConfig = require(Shared.Config.ItemConfig)
local Validate = require(Shared.Util.Validate)

local Services = script.Parent
local DataService = require(Services.DataService)
local InventoryService = require(Services.InventoryService)
local EconomyService = require(Services.EconomyService)
local AntiExploitService = require(Services.AntiExploitService)
local GameSoundService = require(Services.SoundService)
local Notify = require(script.Parent.Parent.Util.Notify)

local INVITE_TIMEOUT = 30
local CONFIRM_SECONDS = 3
local MAX_ITEM_TYPES = 12

type Offer = { Items: { [string]: number }, Coins: number }
type Session = {
	Id: string,
	Players: { Player },
	Offers: { [Player]: Offer },
	Ready: { [Player]: boolean },
	Phase: string, -- "Open" | "Confirming" | "Done"
	ConfirmAt: number,
	Countdown: thread?,
}

local TradeService = {}

local sessions: { [Player]: Session } = {}
local invites: { [Player]: { [Player]: number } } = {} -- target -> { inviter -> time }

local function other(session: Session, player: Player): Player
	return if session.Players[1] == player then session.Players[2] else session.Players[1]
end

local function offerPayload(offer: Offer)
	return { Items = table.clone(offer.Items), Coins = offer.Coins }
end

local function pushState(session: Session)
	for _, player in session.Players do
		local them = other(session, player)
		Net.FireClient("TradeEvent", player, {
			Op = "State",
			Id = session.Id,
			Phase = session.Phase,
			ConfirmAt = session.ConfirmAt,
			You = { Offer = offerPayload(session.Offers[player]), Ready = session.Ready[player] == true },
			Them = { Offer = offerPayload(session.Offers[them]), Ready = session.Ready[them] == true, Name = them.DisplayName, UserId = them.UserId },
		})
	end
end

local function close(session: Session, reason: string?)
	if session.Phase == "Done" then
		return
	end
	session.Phase = "Done"
	if session.Countdown then
		pcall(task.cancel, session.Countdown)
		session.Countdown = nil
	end
	for _, player in session.Players do
		if sessions[player] == session then
			sessions[player] = nil
		end
		if player.Parent then
			Net.FireClient("TradeEvent", player, { Op = "Closed", Reason = reason })
		end
	end
end

local function totalCount(items: { [string]: number }): number
	local total = 0
	for _, count in items do
		total += count
	end
	return total
end

local function stillHas(player: Player, offer: Offer): boolean
	if not EconomyService.CanAfford(player, offer.Coins) then
		return false
	end
	return InventoryService.HasItems(player, offer.Items)
end

-- The actual swap. Everything is checked first, then removed, then granted.
local function execute(session: Session)
	local a, b = session.Players[1], session.Players[2]
	local offerA, offerB = session.Offers[a], session.Offers[b]
	if not a.Parent or not b.Parent then
		close(session, "The other player left.")
		return
	end
	if not stillHas(a, offerA) or not stillHas(b, offerB) then
		close(session, "Someone no longer has what they offered — trade cancelled.")
		return
	end
	local netA = totalCount(offerB.Items) - totalCount(offerA.Items)
	local netB = totalCount(offerA.Items) - totalCount(offerB.Items)
	if netA > InventoryService.GetFreeSpace(a) or netB > InventoryService.GetFreeSpace(b) then
		close(session, "A backpack is too full for this trade.")
		return
	end

	-- Take everything first (all-or-nothing).
	if offerA.Coins > 0 and not EconomyService.SpendCoins(a, offerA.Coins, "Trade") then
		close(session, "Trade failed.")
		return
	end
	if offerB.Coins > 0 and not EconomyService.SpendCoins(b, offerB.Coins, "Trade") then
		if offerA.Coins > 0 then
			EconomyService.AddCoins(a, offerA.Coins, "TradeRefund")
		end
		close(session, "Trade failed.")
		return
	end
	if not InventoryService.RemoveItems(a, offerA.Items, "Trade") then
		EconomyService.AddCoins(a, offerA.Coins, "TradeRefund")
		EconomyService.AddCoins(b, offerB.Coins, "TradeRefund")
		close(session, "Trade failed.")
		return
	end
	if not InventoryService.RemoveItems(b, offerB.Items, "Trade") then
		for itemId, amount in offerA.Items do
			InventoryService.AddItem(a, itemId, amount, "TradeRefund", { IgnoreCapacity = true })
		end
		EconomyService.AddCoins(a, offerA.Coins, "TradeRefund")
		EconomyService.AddCoins(b, offerB.Coins, "TradeRefund")
		close(session, "Trade failed.")
		return
	end

	-- Hand it over.
	for itemId, amount in offerA.Items do
		InventoryService.AddItem(b, itemId, amount, "Trade", { IgnoreCapacity = true })
	end
	for itemId, amount in offerB.Items do
		InventoryService.AddItem(a, itemId, amount, "Trade", { IgnoreCapacity = true })
	end
	if offerA.Coins > 0 then
		EconomyService.AddCoins(b, offerA.Coins, "Trade")
	end
	if offerB.Coins > 0 then
		EconomyService.AddCoins(a, offerB.Coins, "Trade")
	end
	for _, player in session.Players do
		DataService.Increment(player, { "Social", "TradesCompleted" }, 1)
		GameSoundService.PlayFor(player, "QuestComplete")
		Notify.Banner(player, "TRADE COMPLETE!", "Traded with " .. other(session, player).DisplayName, "Reward")
	end
	print(("[TradeService] %s <-> %s: %s | %s"):format(a.Name, b.Name, HttpService:JSONEncode(offerA), HttpService:JSONEncode(offerB)))
	close(session, nil)
end

local function unready(session: Session)
	table.clear(session.Ready)
	session.Phase = "Open"
	session.ConfirmAt = 0
	if session.Countdown then
		pcall(task.cancel, session.Countdown)
		session.Countdown = nil
	end
end

local function finishCountdown(session: Session)
	session.Countdown = nil
	if session.Phase == "Confirming" then
		execute(session)
	end
end

local function checkBothReady(session: Session)
	local a, b = session.Players[1], session.Players[2]
	if session.Ready[a] and session.Ready[b] and session.Phase == "Open" then
		session.Phase = "Confirming"
		session.ConfirmAt = workspace:GetServerTimeNow() + CONFIRM_SECONDS
		session.Countdown = task.delay(CONFIRM_SECONDS, finishCountdown, session)
	end
end

local function startSession(a: Player, b: Player)
	local session: Session = {
		Id = HttpService:GenerateGUID(false),
		Players = { a, b },
		Offers = { [a] = { Items = {}, Coins = 0 }, [b] = { Items = {}, Coins = 0 } },
		Ready = {},
		Phase = "Open",
		ConfirmAt = 0,
		Countdown = nil,
	}
	sessions[a] = session
	sessions[b] = session
	pushState(session)
end

local function onInvite(player: Player, userId: any)
	if not Validate.Integer(userId, 1, 1e12) or userId == player.UserId then
		return
	end
	local target = Players:GetPlayerByUserId(userId)
	if not target or not DataService.IsLoaded(target) then
		Notify.Error(player, "That player isn't available.")
		return
	end
	if sessions[player] or sessions[target] then
		Notify.Error(player, "One of you is already trading.")
		return
	end
	local pending = invites[target]
	if not pending then
		pending = {}
		invites[target] = pending
	end
	if pending[player] and os.clock() - pending[player] < 5 then
		return
	end
	pending[player] = os.clock()
	Net.FireClient("TradeEvent", target, { Op = "Invite", FromUserId = player.UserId, FromName = player.DisplayName, Expires = INVITE_TIMEOUT })
	Notify.Toast(player, "Trade request sent to " .. target.DisplayName .. ".", "🤝")
end

local function onRespond(player: Player, userId: any, accept: any)
	if not Validate.Integer(userId, 1, 1e12) then
		return
	end
	local inviter = Players:GetPlayerByUserId(userId)
	local pending = invites[player]
	local sentAt = inviter and pending and pending[inviter]
	if not inviter or not sentAt then
		return
	end
	pending[inviter] = nil
	if accept ~= true then
		Notify.Toast(inviter, player.DisplayName .. " declined your trade.", "🤝")
		return
	end
	if os.clock() - sentAt > INVITE_TIMEOUT then
		Notify.Error(player, "That trade request expired.")
		return
	end
	if sessions[player] or sessions[inviter] then
		Notify.Error(player, "One of you is already trading.")
		return
	end
	startSession(inviter, player)
end

local function onOffer(player: Player, session: Session, itemId: any, amount: any)
	if not ItemConfig.Exists(itemId) or not Validate.Integer(amount, 0, 1e6) then
		AntiExploitService.Flag(player, "BadTradeOffer", 2)
		return
	end
	local offer = session.Offers[player]
	if amount == 0 then
		offer.Items[itemId] = nil
	else
		local owned = InventoryService.GetCount(player, itemId)
		if owned <= 0 then
			return
		end
		local distinct = 0
		for id in offer.Items do
			if id ~= itemId then
				distinct += 1
			end
		end
		if distinct >= MAX_ITEM_TYPES then
			Notify.Error(player, ("You can offer up to %d different items."):format(MAX_ITEM_TYPES))
			return
		end
		offer.Items[itemId] = math.min(amount, owned)
	end
	unready(session)
	pushState(session)
end

local function onCoins(player: Player, session: Session, amount: any)
	if not Validate.Integer(amount, 0, 1e12) then
		AntiExploitService.Flag(player, "BadTradeCoins", 2)
		return
	end
	local coins = DataService.Get(player, { "Coins" }) or 0
	session.Offers[player].Coins = math.min(amount, coins)
	unready(session)
	pushState(session)
end

local function onRequest(player: Player, payload: any)
	if type(payload) ~= "table" then
		AntiExploitService.Flag(player, "BadTradeRequest", 2)
		return
	end
	local op = payload.Op
	if op == "Invite" then
		onInvite(player, payload.UserId)
		return
	elseif op == "Respond" then
		onRespond(player, payload.UserId, payload.Accept)
		return
	end
	local session = sessions[player]
	if not session or session.Phase == "Done" then
		return
	end
	if op == "Offer" then
		onOffer(player, session, payload.ItemId, payload.Amount)
	elseif op == "Coins" then
		onCoins(player, session, payload.Amount)
	elseif op == "Ready" then
		if payload.Ready == true then
			session.Ready[player] = true
			checkBothReady(session)
		else
			unready(session)
		end
		pushState(session)
	elseif op == "Cancel" then
		close(session, player.DisplayName .. " cancelled the trade.")
	end
end

function TradeService.IsTrading(player: Player): boolean
	return sessions[player] ~= nil
end

function TradeService.Init()
	Net.OnServerEvent("TradeRequest", onRequest)
end

function TradeService.Start()
	Players.PlayerRemoving:Connect(function(player)
		invites[player] = nil
		for _, pending in invites do
			pending[player] = nil
		end
		local session = sessions[player]
		if session then
			close(session, player.DisplayName .. " left the game.")
		end
	end)
end

return TradeService
