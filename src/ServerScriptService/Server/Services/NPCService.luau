--[[
	SCRIPT NAME:  NPCService
	SCRIPT TYPE:  ModuleScript (server service)
	WHERE:        ServerScriptService/Server/Services/NPCService
	DEPENDENCIES: IslandService, InteractionService, Server.Util.Notify

	Lightweight island NPCs (spec §51/§52). Phase 1 of NPCs: a friendly R15
	merchant behind every market stall who gives tips when you talk to her.
	Built from a HumanoidDescription (standard R15 rig), anchored, no AI loop.
	Quests, dialogue trees and wandering NPCs arrive in Phase 10.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Services = script.Parent
local IslandService = require(Services.IslandService)
local InteractionService = require(Services.InteractionService)
local Notify = require(script.Parent.Parent.Util.Notify)
local GameConfig = require(ReplicatedStorage.Shared.Config.GameConfig)

local MERCHANT_NAME = "Mia the Merchant"

local TIPS = {
	"Welcome! Press [E] at my counter to SELL, or [F] at the crate to SHOP.",
	"Crops, fish, milk and eggs all sell here. Check the market demand bonus!",
	"Water your crops — they grow 50% faster.",
	"Build a Barn, then come back and I'll sell you a cow.",
	"Better tools gather faster. A Stone Axe chops trees in half the hits!",
	"Unlocking new areas brings new resources and fishing spots.",
}

local NPCService = {}

local tipIndex: { [Player]: number } = setmetatable({}, { __mode = "k" }) :: any

local function buildMerchant(): Model?
	local description = Instance.new("HumanoidDescription")
	description.HeadColor = Color3.fromRGB(234, 184, 146)
	description.LeftArmColor = description.HeadColor
	description.RightArmColor = description.HeadColor
	description.LeftLegColor = Color3.fromRGB(80, 90, 140)
	description.RightLegColor = Color3.fromRGB(80, 90, 140)
	description.TorsoColor = Color3.fromRGB(90, 170, 110)
	local ok, model = pcall(Players.CreateHumanoidModelFromDescription, Players, description, Enum.HumanoidRigType.R15)
	if not ok or not model then
		if GameConfig.Debug then
			warn("[NPCService] Could not create merchant rig: " .. tostring(model))
		end
		return nil
	end
	model.Name = MERCHANT_NAME
	local humanoid = model:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid.DisplayName = MERCHANT_NAME
		humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.Viewer
	end
	local animate = model:FindFirstChild("Animate")
	if animate then
		animate:Destroy() -- server NPC: no LocalScript animation needed
	end
	for _, descendant in model:GetDescendants() do
		if descendant:IsA("BasePart") then
			descendant.Anchored = descendant.Name == "HumanoidRootPart"
		end
	end
	return model
end

local function spawnMerchant(island: any)
	local stall = island.MarketStall
	if not stall then
		return
	end
	local merchant = buildMerchant()
	if not merchant then
		return
	end
	-- Behind the counter, facing the same way as the stall's front.
	merchant:PivotTo(stall:GetPivot() * CFrame.new(0, 3, 1.6))
	merchant.Parent = island.Folders.Landmarks
	local root = merchant:FindFirstChild("HumanoidRootPart")
	if root then
		InteractionService.Attach(root, "MerchantTalk", { ObjectText = MERCHANT_NAME, OwnerUserId = island.OwnerUserId, KeyboardKeyCode = Enum.KeyCode.T })
	end
end

function NPCService.Init()
	InteractionService.RegisterKind("MerchantTalk", {
		ActionText = "Talk",
		ObjectText = MERCHANT_NAME,
		Permission = "Visitor",
		MaxDistance = 12,
		Cooldown = 1,
		Handler = function(player: Player)
			local index = (tipIndex[player] or 0) % #TIPS + 1
			tipIndex[player] = index
			Notify.Toast(player, MERCHANT_NAME .. ": " .. TIPS[index], "💬")
		end,
	})
end

function NPCService.Start()
	IslandService.IslandAssigned:Connect(function(_player: Player, island: any)
		-- CreateHumanoidModelFromDescription can yield; don't hold up island loading.
		task.spawn(spawnMerchant, island)
	end)
end

return NPCService
