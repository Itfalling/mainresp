--[[
	SCRIPT NAME:  InteractionService
	SCRIPT TYPE:  ModuleScript (server service)
	WHERE:        ServerScriptService/Server/Services/InteractionService
	DEPENDENCIES: AntiExploitService, Shared.Net, Shared.Util.{R15, RateLimiter}, Server.Util.Notify

	ONE click-to-interact system for trees, rocks, soil, animals, the market,
	chests, signs, NPCs... No ProximityPrompts: you HOLD a tool or item and
	CLICK / TAP the thing (the client outlines what you hover).

	Each interactable has a KIND registered once by the owning service:

		InteractionService.RegisterKind("StarterChest", {
			Permission = "Owner",      -- island permission (see IslandService.CanAccess)
			MaxDistance = 12,          -- studs from the object's bounding box
			Cooldown = 0.5,
			Handler = function(player, object) ... end,
		})
		InteractionService.Attach(chestModel, "StarterChest", { OwnerUserId = 123, Label = "Starter Chest" })

	Attach tags the object "Interactable" and sets attributes the client reads
	for hover outlines + tooltips: Interact (kind), InteractLabel, InteractRange,
	InteractDisabled, OwnerUserId. Services update InteractHint / InteractLabel
	as state changes ("Ready to harvest!").

	Server checks on every click (InteractRequest(object, swingVariant?)): rate limit, object
	registered + enabled, player alive, distance to the object's bounding box,
	per-player cooldown, island permission, then the handler runs in pcall.
	Handlers decide what happens from what the player is HOLDING
	(ToolService.GetHeld) — the client never says what it holds.
]]

local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Shared
local Net = require(Shared.Net)
local R15 = require(Shared.Util.R15)
local RateLimiter = require(Shared.Util.RateLimiter)

local Services = script.Parent
local AntiExploitService = require(Services.AntiExploitService)
local AnimationService = require(Services.AnimationService)
local Notify = require(script.Parent.Parent.Util.Notify)

export type KindDef = {
	Permission: string?,
	MaxDistance: number?,
	Cooldown: number?,
	Handler: (player: Player, object: Instance) -> (),
}

type Entry = {
	Object: Instance,
	Kind: string,
	Permission: string,
	OwnerUserId: number?,
	Cooldown: number,
	MaxDistance: number,
	LastUse: { [Player]: number },
}

local TAG = "Interactable"
local DISTANCE_TOLERANCE = 5

local InteractionService = {}

local kinds: { [string]: KindDef } = {}
local entries: { [Instance]: Entry } = {}
local limiter = RateLimiter.new(8, 12)

-- (player, object, permission, ownerUserId) -> boolean. Installed by IslandService.
local accessResolver: ((Player, Instance, string, number?) -> boolean)? = nil

function InteractionService.SetAccessResolver(resolver: (Player, Instance, string, number?) -> boolean)
	accessResolver = resolver
end

function InteractionService.RegisterKind(kind: string, def: KindDef)
	assert(kinds[kind] == nil, "Interaction kind already registered: " .. kind)
	assert(type(def.Handler) == "function", "Interaction kind needs a Handler: " .. kind)
	kinds[kind] = def
end

function InteractionService.Attach(object: Instance, kind: string, options: { [string]: any }?)
	local def = kinds[kind]
	assert(def, "Unknown interaction kind: " .. kind)
	InteractionService.Detach(object)
	local opts = options or {}
	local permission = opts.Permission or def.Permission or "Owner"
	local entry: Entry = {
		Object = object,
		Kind = kind,
		Permission = permission,
		OwnerUserId = opts.OwnerUserId,
		Cooldown = opts.Cooldown or def.Cooldown or 0.35,
		MaxDistance = opts.MaxDistance or def.MaxDistance or 10,
		LastUse = setmetatable({}, { __mode = "k" }) :: any,
	}
	entries[object] = entry
	object:SetAttribute("Interact", kind)
	object:SetAttribute("InteractLabel", opts.Label or kind)
	object:SetAttribute("InteractRange", entry.MaxDistance)
	object:SetAttribute("InteractPermission", permission)
	object:SetAttribute("InteractDisabled", nil)
	if opts.OwnerUserId then
		object:SetAttribute("OwnerUserId", opts.OwnerUserId)
	end
	CollectionService:AddTag(object, TAG)
	object.Destroying:Once(function()
		entries[object] = nil
	end)
end

function InteractionService.Detach(object: Instance)
	if not entries[object] then
		return
	end
	entries[object] = nil
	CollectionService:RemoveTag(object, TAG)
	object:SetAttribute("Interact", nil)
	object:SetAttribute("InteractHint", nil)
end

-- Dynamic hover text: hint = what a click will do now, label = what it is.
function InteractionService.SetText(object: Instance, hint: string?, label: string?)
	if not entries[object] then
		return
	end
	if hint then
		object:SetAttribute("InteractHint", hint)
	end
	if label then
		object:SetAttribute("InteractLabel", label)
	end
end

function InteractionService.SetEnabled(object: Instance, enabled: boolean)
	if entries[object] then
		object:SetAttribute("InteractDisabled", if enabled then nil else true)
	end
end

function InteractionService.IsAttached(object: Instance): boolean
	return entries[object] ~= nil
end

-- Distance from a point to the object's bounding box (0 when inside).
local function distanceTo(object: Instance, point: Vector3): number?
	local cframe: CFrame, size: Vector3
	if object:IsA("Model") then
		cframe, size = object:GetBoundingBox()
	elseif object:IsA("BasePart") then
		cframe, size = object.CFrame, object.Size
	else
		return nil
	end
	local relative = cframe:PointToObjectSpace(point)
	local half = size / 2
	local clamped = Vector3.new(math.clamp(relative.X, -half.X, half.X), math.clamp(relative.Y, -half.Y, half.Y), math.clamp(relative.Z, -half.Z, half.Z))
	return (relative - clamped).Magnitude
end

function InteractionService.DistanceTo(object: Instance, point: Vector3): number
	return distanceTo(object, point) or math.huge
end

local function onRequest(player: Player, object: any, variant: any)
	if typeof(object) ~= "Instance" then
		AntiExploitService.Flag(player, "BadInteract", 2)
		return
	end
	local entry = entries[object]
	if not entry then
		return -- destroyed / not interactable (latency), not suspicious
	end
	if not limiter:Check(player) then
		AntiExploitService.Flag(player, "InteractSpam", 1)
		return
	end
	if object:GetAttribute("InteractDisabled") then
		return
	end
	local character = player.Character
	local root = R15.GetRootPart(character)
	if not root or not R15.IsAlive(character) then
		return
	end
	local distance = distanceTo(object, root.Position)
	if not distance or distance > entry.MaxDistance + DISTANCE_TOLERANCE then
		if distance and distance > entry.MaxDistance + 40 then
			AntiExploitService.Flag(player, "InteractTooFar:" .. entry.Kind, 1)
		end
		return
	end

	local now = os.clock()
	local last = entry.LastUse[player]
	if last and now - last < entry.Cooldown then
		return
	end
	entry.LastUse[player] = now

	if accessResolver and not accessResolver(player, entry.Object, entry.Permission, entry.OwnerUserId) then
		Notify.Error(player, "You can't do that on someone else's island (ask the owner to make you a helper).")
		return
	end

	-- Which of the tool's swings the client is already playing (cosmetic).
	AnimationService.SetVariantHint(player, variant)
	local def = kinds[entry.Kind]
	local ok, err = pcall(def.Handler, player, entry.Object)
	if not ok then
		warn(("[Interaction] %s handler failed for %s: %s"):format(entry.Kind, player.Name, tostring(err)))
	end
end

function InteractionService.Init()
	Net.OnServerEvent("InteractRequest", onRequest)
end

return InteractionService
