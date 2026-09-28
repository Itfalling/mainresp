--[[
	SCRIPT NAME:  ToolService
	SCRIPT TYPE:  ModuleScript (server service)
	WHERE:        ServerScriptService/Server/Services/ToolService
	DEPENDENCIES: DataService, InventoryService, AnimationService, AntiExploitService, SoundService,
	              Server.Tools.ToolModelFactory, Shared.Config.{ToolConfig, ItemConfig, CropConfig},
	              Shared.Util.{R15, Validate}, Shared.Net

	What's in your HANDS. The hotbar holds tools AND holdable items (seed
	sacks, crops to feed animals). Equipping is server-authoritative:
	  * the client asks (EquipToolRequest(id)), the server checks you own the
	    tool / have at least one of the item,
	  * builds the model and joins it to the R15 RightHand with a Motor6D
	    named "ToolGrip", so it never floats and follows every animation,
	  * sets character attributes: Held (id), HeldKind ("Tool" | "Item") and
	    HoldPose (the keyframed hold pose every client plays).

	Interaction handlers ask GetHeld(player) — never the client — what the
	player is holding. Items auto-join the hotbar when first gathered/bought
	and leave it when you run out.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Shared
local Net = require(Shared.Net)
local ToolConfig = require(Shared.Config.ToolConfig)
local ItemConfig = require(Shared.Config.ItemConfig)
local CropConfig = require(Shared.Config.CropConfig)
local R15 = require(Shared.Util.R15)
local Validate = require(Shared.Util.Validate)

local Services = script.Parent
local DataService = require(Services.DataService)
local InventoryService = require(Services.InventoryService)
local AnimationService = require(Services.AnimationService)
local AntiExploitService = require(Services.AntiExploitService)
local GameSoundService = require(Services.SoundService)
local ToolModelFactory = require(script.Parent.Parent.Tools.ToolModelFactory)

export type Held = { Kind: string, Id: string, Def: any }

local ToolService = {}

local equippedModels: { [Player]: Model } = {}

-- Hold pose per tool type (keyframed in Shared/Animation/Keyframes).
local HOLD_POSES = {
	Axe = "HoldAxe",
	Pickaxe = "HoldPickaxe",
	Hammer = "HoldHammer",
	Shovel = "HoldShovel",
	Hoe = "HoldHoe",
	WateringCan = "HoldCan",
	FishingRod = "HoldRod",
	Bucket = "HoldBucket",
	Shears = "HoldTool",
}

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

-- The TOOL in hand (nil if holding an item or nothing).
function ToolService.GetEquipped(player: Player): any
	local id = ToolService.GetEquippedId(player)
	return id and ToolConfig.Get(id)
end

-- Whatever is in hand: { Kind = "Tool" | "Item", Id, Def } or nil.
function ToolService.GetHeld(player: Player): Held?
	local id = ToolService.GetEquippedId(player)
	if not id then
		return nil
	end
	local tool = ToolConfig.Get(id)
	if tool then
		return { Kind = "Tool", Id = id, Def = tool }
	end
	local item = ItemConfig.Get(id)
	if item and InventoryService.GetCount(player, id) > 0 then
		return { Kind = "Item", Id = id, Def = item }
	end
	return nil
end

-- Held tool of this type, or nil.
function ToolService.GetHeldTool(player: Player, toolType: string): any
	local tool = ToolService.GetEquipped(player)
	if tool and tool.Type == toolType then
		return tool
	end
	return nil
end

-- Best owned tool of a type (highest tier).
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

local function getHotbar(player: Player): { string }
	return table.clone(DataService.Get(player, { "Tools", "Hotbar" }) or {})
end

local function setHotbar(player: Player, hotbar: { string })
	DataService.Set(player, { "Tools", "Hotbar" }, hotbar)
end

-- Puts an item on the hotbar if there's room (or replaces the last item slot).
function ToolService.AddToHotbar(player: Player, id: string, force: boolean?): boolean
	local hotbar = getHotbar(player)
	if table.find(hotbar, id) then
		return true
	end
	if #hotbar < ToolConfig.HotbarSize then
		table.insert(hotbar, id)
		setHotbar(player, hotbar)
		return true
	end
	if force then
		for index = #hotbar, 1, -1 do
			if not ToolConfig.Get(hotbar[index]) then
				hotbar[index] = id
				setHotbar(player, hotbar)
				return true
			end
		end
	end
	return false
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
	local hotbar = getHotbar(player)
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
		if not replaced then
			if #hotbar < ToolConfig.HotbarSize then
				table.insert(hotbar, toolId)
			else
				-- Tools take priority over items on a full hotbar.
				for index = #hotbar, 1, -1 do
					if not ToolConfig.Get(hotbar[index]) then
						hotbar[index] = toolId
						break
					end
				end
			end
		end
		setHotbar(player, hotbar)
	end
	return true
end

local function destroyModel(player: Player)
	local model = equippedModels[player]
	if model then
		equippedModels[player] = nil
		model:Destroy()
	end
end

local function attachModel(character: Model, model: Model, gripOffset: CFrame?): Model?
	local hand = R15.GetPart(character, "RightHand")
	if not hand then
		model:Destroy()
		return nil
	end
	local handle = model.PrimaryPart
	local grip = handle and handle:FindFirstChild("Grip")
	if not handle or not grip or not grip:IsA("Attachment") then
		model:Destroy()
		return nil
	end
	local gripAttachment = hand:FindFirstChild(R15.GripAttachments.RightHand or "")
	local handGrip = if gripAttachment and gripAttachment:IsA("Attachment")
		then gripAttachment.CFrame
		else CFrame.new(0, -hand.Size.Y / 2, 0) * CFrame.Angles(-math.pi / 2, 0, 0)

	local motor = Instance.new("Motor6D")
	motor.Name = "ToolGrip"
	motor.Part0 = hand
	motor.Part1 = handle
	motor.C0 = handGrip * (gripOffset or CFrame.new())
	motor.C1 = grip.CFrame
	model:PivotTo(hand.CFrame * motor.C0 * motor.C1:Inverse())
	model.Parent = character
	motor.Parent = hand
	return model
end

local function clearCharacter(character: Model?)
	if not character then
		return
	end
	for handName in R15.GripAttachments do
		local hand = R15.GetPart(character, handName)
		local stale = hand and hand:FindFirstChild("ToolGrip")
		if stale then
			stale:Destroy()
		end
	end
	character:SetAttribute("Held", nil)
	character:SetAttribute("HeldKind", nil)
	character:SetAttribute("EquippedTool", nil)
	AnimationService.SetHoldPose(character, nil)
end

local function itemColor(itemId: string): Color3
	local cropId = CropConfig.SeedToCrop[itemId] or itemId
	local crop = CropConfig.Crops[cropId]
	if crop then
		return crop.ProduceColor
	end
	return Color3.fromRGB(220, 200, 120)
end

-- Server-side equip of a tool OR a holdable item. nil/"" empties your hands.
function ToolService.Equip(player: Player, id: string?): boolean
	if not DataService.IsLoaded(player) then
		return false
	end
	local character = player.Character
	destroyModel(player)
	clearCharacter(character)

	if id == nil or id == "" then
		DataService.Set(player, { "Tools", "Equipped" }, "")
		return true
	end

	local toolDef = ToolConfig.Get(id)
	local itemDef = if toolDef then nil else ItemConfig.Get(id)
	if toolDef then
		if not ToolService.HasTool(player, id) then
			return false
		end
	elseif not itemDef or not ItemConfig.IsHoldable(id) or InventoryService.GetCount(player, id) <= 0 then
		return false
	end

	DataService.Set(player, { "Tools", "Equipped" }, id)
	if not DataService.Get(player, { "Flags", "FirstEquip" }) then
		DataService.Set(player, { "Flags", "FirstEquip" }, true)
	end
	if itemDef then
		ToolService.AddToHotbar(player, id, true)
	end

	if not character or not R15.IsAlive(character) then
		return true -- saved; the model is attached on next spawn
	end
	local model = if toolDef
		then attachModel(character, ToolModelFactory.Build(toolDef), toolDef.Grip.Offset)
		else attachModel(character, ToolModelFactory.BuildItem(id, (itemDef :: any).Category, itemColor(id)), nil)
	if not model then
		warn("[ToolService] Could not attach " .. id .. " to " .. player.Name .. " (is the rig R15?)")
		return false
	end
	equippedModels[player] = model
	character:SetAttribute("Held", id)
	character:SetAttribute("HeldKind", if toolDef then "Tool" else "Item")
	if toolDef then
		character:SetAttribute("EquippedTool", id)
	end
	AnimationService.SetHoldPose(character, if toolDef then (HOLD_POSES[toolDef.Type] or "HoldTool") else "HoldItem")
	local root = R15.GetRootPart(character)
	if root then
		GameSoundService.PlayAt("ToolEquip", root.Position)
	end
	return true
end

-- Makes sure the player holds a tool of this type (used by build-mode helpers).
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

local function onHotbarRequest(player: Player, payload: any)
	if type(payload) ~= "table" or payload.Op ~= "Set" then
		return
	end
	local slot, id = payload.Slot, payload.Id
	if not Validate.Integer(slot, 1, ToolConfig.HotbarSize) or type(id) ~= "string" then
		AntiExploitService.Flag(player, "BadHotbar", 2)
		return
	end
	local hotbar = getHotbar(player)
	if id == "" then
		if hotbar[slot] then
			table.remove(hotbar, slot)
			setHotbar(player, hotbar)
		end
		return
	end
	local valid = if ToolConfig.Get(id) then ToolService.HasTool(player, id) else ItemConfig.IsHoldable(id) and InventoryService.GetCount(player, id) > 0
	if not valid then
		return
	end
	local existing = table.find(hotbar, id)
	if existing then
		hotbar[existing], hotbar[math.min(slot, #hotbar)] = hotbar[math.min(slot, #hotbar)], hotbar[existing]
	elseif slot <= #hotbar then
		hotbar[slot] = id
	else
		table.insert(hotbar, id)
	end
	setHotbar(player, hotbar)
end

function ToolService.Init()
	Net.OnServerEvent("EquipToolRequest", function(player: Player, id: any)
		if id == nil or id == "" then
			ToolService.Equip(player, nil)
			return
		end
		if not Validate.Id(id) or (not ToolConfig.Get(id) and not ItemConfig.Exists(id)) then
			AntiExploitService.Flag(player, "InvalidToolId", 2)
			return
		end
		ToolService.Equip(player, id)
	end)
	Net.OnServerEvent("HotbarRequest", onHotbarRequest)
	-- Cosmetic swing at nothing: everyone sees the animation, nothing is hit.
	Net.OnServerEvent("SwingRequest", function(player: Player, variant: any)
		local tool = ToolService.GetEquipped(player)
		if not tool or tool.Type == "FishingRod" or AnimationService.IsBusy(player) then
			return
		end
		AnimationService.SetVariantHint(player, variant)
		AnimationService.PerformAction(player, tool.Animations.Use, nil, function() end, { Speed = tool.Speed, LockFraction = 0.7 })
	end)
end

function ToolService.Start()
	-- New holdable items join the hotbar automatically.
	InventoryService.ItemAdded:Connect(function(player: Player, itemId: string)
		if ItemConfig.IsHoldable(itemId) then
			ToolService.AddToHotbar(player, itemId, false)
		end
	end)
	-- Running out of an item takes it out of your hands and off the hotbar.
	DataService.Changed:Connect(function(player: Player, path: { string }, value: any)
		if path[1] ~= "Inventory" or path[2] ~= "Items" or path[3] == nil then
			return
		end
		local itemId = path[3]
		if (value == nil or value == 0) and not ToolConfig.Get(itemId) then
			local hotbar = getHotbar(player)
			local index = table.find(hotbar, itemId)
			if index then
				table.remove(hotbar, index)
				setHotbar(player, hotbar)
			end
			if ToolService.GetEquippedId(player) == itemId then
				ToolService.Equip(player, nil)
			end
		end
	end)
end

return ToolService
