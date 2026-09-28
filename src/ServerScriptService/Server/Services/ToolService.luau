--[[
	SCRIPT NAME:  ToolService
	SCRIPT TYPE:  ModuleScript (server service)
	WHERE:        ServerScriptService/Server/Services/ToolService
	DEPENDENCIES: DataService, AntiExploitService, SoundService, Server.Tools.ToolModelFactory,
	              Shared.Config.ToolConfig, Shared.Util.{R15, Validate}, Shared.Net

	Tool framework (spec §18, §77, §78):
	  * ownership + hotbar live in the profile (Tools.Owned / Tools.Hotbar),
	  * equipping is SERVER-authoritative: the client asks, the server checks
	    ownership, builds the model and joins it to the R15 hand with a
	    Motor6D named "ToolGrip" (Part0 = RightHand, C0 = RightGripAttachment),
	    so the tool never floats and can be keyframed by real animations,
	  * the character gets attribute EquippedTool = toolId, which clients use
	    to play the matching hold/use animations from ToolConfig.

	Roblox's own Tool/Backpack system is intentionally NOT used: we need
	custom grips, custom hotbar UI and server-controlled tool stats.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Shared
local Net = require(Shared.Net)
local ToolConfig = require(Shared.Config.ToolConfig)
local R15 = require(Shared.Util.R15)
local Validate = require(Shared.Util.Validate)

local Services = script.Parent
local DataService = require(Services.DataService)
local AntiExploitService = require(Services.AntiExploitService)
local GameSoundService = require(Services.SoundService)
local ToolModelFactory = require(script.Parent.Parent.Tools.ToolModelFactory)

local ToolService = {}

local equippedModels: { [Player]: Model } = {}

function ToolService.HasTool(player: Player, toolId: string): boolean
	return DataService.Get(player, { "Tools", "Owned", toolId }) == true
end

function ToolService.GetEquippedId(player: Player): string?
	local equipped = DataService.Get(player, { "Tools", "Equipped" })
	if type(equipped) == "string" and equipped ~= "" then
		return equipped
	end
	return nil
end

function ToolService.GetEquipped(player: Player): any
	local toolId = ToolService.GetEquippedId(player)
	return toolId and ToolConfig.Get(toolId)
end

-- Best owned tool of a type (highest tier), used by gathering in Phase 2.
function ToolService.GetBestTool(player: Player, toolType: string): any
	local owned = DataService.Get(player, { "Tools", "Owned" })
	local best = nil
	if owned then
		for toolId in owned do
			local def = ToolConfig.Get(toolId)
			if def and def.Type == toolType and (best == nil or def.TierOrder > best.TierOrder) then
				best = def
			end
		end
	end
	return best
end

function ToolService.GrantTool(player: Player, toolId: string, reason: string): boolean
	if not ToolConfig.Get(toolId) then
		warn(("[ToolService] Unknown tool %s (%s)"):format(tostring(toolId), reason))
		return false
	end
	if not DataService.IsLoaded(player) or ToolService.HasTool(player, toolId) then
		return false
	end
	DataService.Set(player, { "Tools", "Owned", toolId }, true)
	local def = ToolConfig.Get(toolId)
	local hotbar = table.clone(DataService.Get(player, { "Tools", "Hotbar" }) or {})
	if not table.find(hotbar, toolId) then
		-- An upgrade replaces the weaker tool of the same type in its slot.
		local replaced = false
		for index, existingId in hotbar do
			local existing = ToolConfig.Get(existingId)
			if existing and existing.Type == def.Type and existing.TierOrder < def.TierOrder then
				hotbar[index] = toolId
				replaced = true
				if ToolService.GetEquippedId(player) == existingId then
					task.defer(ToolService.Equip, player, toolId)
				end
				break
			end
		end
		if not replaced and #hotbar < ToolConfig.HotbarSize then
			table.insert(hotbar, toolId)
		end
		DataService.Set(player, { "Tools", "Hotbar" }, hotbar)
	end
	return true
end

-- Equips the best owned tool of a type (used by prompt actions: "Chop Tree"
-- equips your axe). Returns the tool definition or nil if none is owned.
function ToolService.EquipBestOfType(player: Player, toolType: string): any
	local best = ToolService.GetBestTool(player, toolType)
	if not best then
		return nil
	end
	if ToolService.GetEquippedId(player) ~= best.Id then
		ToolService.Equip(player, best.Id)
	end
	return best
end

local function destroyModel(player: Player)
	local model = equippedModels[player]
	if model then
		equippedModels[player] = nil
		model:Destroy()
	end
end

local function attachModel(character: Model, toolDef: any): Model?
	local handName = toolDef.Grip.Hand
	local hand = R15.GetPart(character, handName)
	if not hand then
		return nil
	end
	local model = ToolModelFactory.Build(toolDef)
	local handle = model.PrimaryPart
	local grip = handle and handle:FindFirstChild("Grip")
	if not handle or not grip or not grip:IsA("Attachment") then
		model:Destroy()
		return nil
	end

	local gripAttachment = hand:FindFirstChild(R15.GripAttachments[handName] or "")
	local handGrip = if gripAttachment and gripAttachment:IsA("Attachment")
		then gripAttachment.CFrame
		else CFrame.new(0, -hand.Size.Y / 2, 0) * CFrame.Angles(-math.pi / 2, 0, 0)

	local motor = Instance.new("Motor6D")
	motor.Name = "ToolGrip"
	motor.Part0 = hand
	motor.Part1 = handle
	motor.C0 = handGrip * toolDef.Grip.Offset
	motor.C1 = grip.CFrame
	-- Move the whole model (PrimaryPart = Handle) next to the hand before joining it.
	model:PivotTo(hand.CFrame * motor.C0 * motor.C1:Inverse())
	model.Parent = character
	motor.Parent = hand
	return model
end

-- Server-side equip. toolId nil/"" unequips. Returns success.
function ToolService.Equip(player: Player, toolId: string?): boolean
	if not DataService.IsLoaded(player) then
		return false
	end
	local character = player.Character
	destroyModel(player)
	if character then
		for handName in R15.GripAttachments do
			local hand = R15.GetPart(character, handName)
			local stale = hand and hand:FindFirstChild("ToolGrip")
			if stale then
				stale:Destroy()
			end
		end
	end

	if toolId == nil or toolId == "" then
		DataService.Set(player, { "Tools", "Equipped" }, "")
		if character then
			character:SetAttribute("EquippedTool", nil)
		end
		return true
	end

	local toolDef = ToolConfig.Get(toolId)
	if not toolDef or not ToolService.HasTool(player, toolId) then
		return false
	end
	DataService.Set(player, { "Tools", "Equipped" }, toolId)
	if not DataService.Get(player, { "Flags", "FirstEquip" }) then
		DataService.Set(player, { "Flags", "FirstEquip" }, true)
	end

	if not character or not R15.IsAlive(character) then
		return true -- saved; the model is attached on next spawn
	end
	local model = attachModel(character, toolDef)
	if not model then
		warn("[ToolService] Could not attach " .. toolId .. " to " .. player.Name .. " (is the rig R15?)")
		return false
	end
	equippedModels[player] = model
	character:SetAttribute("EquippedTool", toolId)
	local root = R15.GetRootPart(character)
	if root then
		GameSoundService.PlayAt("ToolEquip", root.Position)
	end
	return true
end

-- Called by PlayerService after each (re)spawn.
function ToolService.OnCharacterSpawned(player: Player, _character: Model)
	local equipped = ToolService.GetEquippedId(player)
	if equipped then
		ToolService.Equip(player, equipped)
	end
end

function ToolService.OnPlayerRemoving(player: Player)
	destroyModel(player)
end

function ToolService.Init()
	Net.OnServerEvent("EquipToolRequest", function(player: Player, toolId: any)
		if toolId == nil or toolId == "" then
			ToolService.Equip(player, nil)
			return
		end
		if not Validate.Id(toolId) or not ToolConfig.Get(toolId) then
			AntiExploitService.Flag(player, "InvalidToolId", 2)
			return
		end
		if not ToolService.HasTool(player, toolId) then
			AntiExploitService.Flag(player, "EquipUnownedTool", 1)
			return
		end
		ToolService.Equip(player, toolId)
	end)
end

return ToolService
