--[[
	SCRIPT NAME:  NPCService
	SCRIPT TYPE:  ModuleScript (server service)
	WHERE:        ServerScriptService/Server/Services/NPCService
	DEPENDENCIES: BuildService, InteractionService, AnimationService, Shared.Net, Server.Util.Notify

	Lightweight island NPCs (spec §51/§52): a friendly R15 merchant behind
	every market stall (she follows the stall when you move it). Click her
	for a tip and the Buy tab. Built from a HumanoidDescription (standard R15
	rig), anchored root, tagged "NPCRig" so every client plays her idle
	breathing / look-around keyframes and her wave.
]]

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Net = require(ReplicatedStorage.Shared.Net)

local Services = script.Parent
local BuildService = require(Services.BuildService)
local InteractionService = require(Services.InteractionService)
local AnimationService = require(Services.AnimationService)
local Notify = require(script.Parent.Parent.Util.Notify)
local GameConfig = require(ReplicatedStorage.Shared.Config.GameConfig)

local MERCHANT_NAME = "Mia the Merchant"

local TIPS = {
	"Welcome! Click my stall any time to buy and sell.",
	"Crops, fish, milk and eggs all sell here. Check the market demand bonus!",
	"Water your crops — they grow 50% faster.",
	"Build a Barn, then come back and I'll sell you a cow.",
	"Better tools gather faster. A Stone Axe chops trees in half the hits!",
	"Expand your island in any direction — new land grows new trees and rocks.",
	"Visit friends' islands from the 🌍 menu. Their waters hold different fish!",
	"Hold seeds in your hand and click tilled soil to plant them.",
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

local merchants: { [string]: Model } = {} -- stall site UniqueId -> merchant

local function placeMerchant(site: any)
	local merchant = merchants[site.UniqueId]
	if merchant and merchant.Parent then
		-- Behind the counter, facing the same way as the stall's front.
		merchant:PivotTo(site.Model:GetPivot() * CFrame.new(0, 3.1, 0.3))
	end
end

local function spawnMerchant(site: any)
	if merchants[site.UniqueId] then
		return
	end
	local merchant = buildMerchant()
	if not merchant then
		return
	end
	merchants[site.UniqueId] = merchant
	merchant:SetAttribute("NPC", "Merchant")
	CollectionService:AddTag(merchant, "NPCRig")
	merchant.Parent = site.Island.Folders.Landmarks
	placeMerchant(site)
	InteractionService.Attach(merchant, "MerchantTalk", { Label = MERCHANT_NAME, OwnerUserId = site.OwnerUserId })
	site.Model.Destroying:Once(function()
		merchants[site.UniqueId] = nil
		merchant:Destroy()
	end)
end

function NPCService.Init()
	InteractionService.RegisterKind("MerchantTalk", {
		Permission = "Market",
		MaxDistance = 12,
		Cooldown = 1,
		Handler = function(player: Player, merchant: Instance)
			local index = (tipIndex[player] or 0) % #TIPS + 1
			tipIndex[player] = index
			Notify.Toast(player, MERCHANT_NAME .. ": " .. TIPS[index], "💬")
			Net.FireClient("OpenUI", player, { Screen = "Market", Tab = "Buy" })
			if merchant:IsA("Model") then
				AnimationService.PlayAnimation(merchant, "Wave")
			end
		end,
	})
end

function NPCService.Start()
	BuildService.SiteReady:Connect(function(site: any)
		if site.BuildingId == "MarketStall" then
			-- CreateHumanoidModelFromDescription can yield; don't hold up island loading.
			task.spawn(spawnMerchant, site)
		end
	end)
	BuildService.BuildingMoved:Connect(function(_player: Player, site: any)
		if site.BuildingId == "MarketStall" then
			placeMerchant(site)
		end
	end)
end

return NPCService
