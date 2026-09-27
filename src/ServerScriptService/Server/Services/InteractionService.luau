--[[
	SCRIPT NAME:  InteractionService
	SCRIPT TYPE:  ModuleScript (server service)
	WHERE:        ServerScriptService/Server/Services/InteractionService
	DEPENDENCIES: AntiExploitService, Shared.Util.{R15, RateLimiter}, Server.Util.Notify

	ONE reusable interaction system for trees, rocks, crops, animals, shops,
	chests, signs... (spec §49/§50). Built on ProximityPrompt, which gives:
	  * "[E] Chop Tree" on keyboard, a tap button on mobile, gamepad support,
	  * a server-side Triggered event (the client cannot fake distance).

	Each interactable has a KIND registered once by the owning service:

		InteractionService.RegisterKind("StarterChest", {
			ActionText = "Open",
			ObjectText = "Starter Chest",
			Permission = "Owner",      -- "Owner" | "Visitor" | any island permission key
			HoldDuration = 0,
			MaxDistance = 10,
			Cooldown = 0.5,
			Handler = function(player, object, prompt) ... end,
		})
		InteractionService.Attach(chestModel, "StarterChest", { OwnerUserId = 123 })

	Server checks on every trigger: rate limit, object still registered, player
	alive, distance, per-player cooldown, island permission (via the resolver
	IslandService installs), then the handler runs inside pcall.

	Prompts with Permission "Owner" are tagged "OwnerOnlyPrompt" so the client
	hides them from visitors (cosmetic only — the server still validates).
]]

local CollectionService = game:GetService("CollectionService")
local ProximityPromptService = game:GetService("ProximityPromptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Shared
local R15 = require(Shared.Util.R15)
local RateLimiter = require(Shared.Util.RateLimiter)

local Services = script.Parent
local AntiExploitService = require(Services.AntiExploitService)
local Notify = require(script.Parent.Parent.Util.Notify)

export type KindDef = {
	ActionText: string,
	ObjectText: string?,
	Permission: string?,
	HoldDuration: number?,
	MaxDistance: number?,
	Cooldown: number?,
	Handler: (player: Player, object: Instance, prompt: ProximityPrompt) -> (),
}

type Entry = {
	Object: Instance,
	Kind: string,
	Prompt: ProximityPrompt,
	Permission: string,
	OwnerUserId: number?,
	Cooldown: number,
	LastUse: { [Player]: number },
}

local DISTANCE_TOLERANCE = 6
local OWNER_ONLY_TAG = "OwnerOnlyPrompt"

local InteractionService = {}

local kinds: { [string]: KindDef } = {}
local entriesByPrompt: { [ProximityPrompt]: Entry } = {}
local entriesByObject: { [Instance]: Entry } = {}
local limiter = RateLimiter.new(6, 10)

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

local function getPromptParent(object: Instance): Instance?
	if object:IsA("BasePart") or object:IsA("Attachment") then
		return object
	end
	if object:IsA("Model") then
		local anchor = object:FindFirstChild("PromptAnchor", true)
		if anchor and (anchor:IsA("Attachment") or anchor:IsA("BasePart")) then
			return anchor
		end
		return object.PrimaryPart or object:FindFirstChildWhichIsA("BasePart", true)
	end
	return nil
end

local function getWorldPosition(instance: Instance): Vector3?
	if instance:IsA("Attachment") then
		return instance.WorldPosition
	elseif instance:IsA("BasePart") then
		return instance.Position
	end
	return nil
end

function InteractionService.Attach(object: Instance, kind: string, overrides: { [string]: any }?): ProximityPrompt?
	local def = kinds[kind]
	assert(def, "Unknown interaction kind: " .. kind)
	InteractionService.Detach(object)

	local parent = getPromptParent(object)
	if not parent then
		warn("[Interaction] No part to attach prompt to on " .. object:GetFullName())
		return nil
	end
	local options = overrides or {}

	local prompt = Instance.new("ProximityPrompt")
	prompt.Name = "InteractPrompt"
	prompt.ActionText = options.ActionText or def.ActionText
	prompt.ObjectText = options.ObjectText or def.ObjectText or ""
	prompt.HoldDuration = options.HoldDuration or def.HoldDuration or 0
	prompt.MaxActivationDistance = options.MaxDistance or def.MaxDistance or 10
	prompt.RequiresLineOfSight = false
	prompt.KeyboardKeyCode = Enum.KeyCode.E
	prompt.GamepadKeyCode = Enum.KeyCode.ButtonX
	prompt.Style = Enum.ProximityPromptStyle.Default
	prompt:SetAttribute("InteractKind", kind)

	local permission = options.Permission or def.Permission or "Owner"
	local ownerUserId = options.OwnerUserId
	if ownerUserId then
		prompt:SetAttribute("OwnerUserId", ownerUserId)
	end
	if permission == "Owner" then
		CollectionService:AddTag(prompt, OWNER_ONLY_TAG)
	end
	prompt.Parent = parent

	local entry: Entry = {
		Object = object,
		Kind = kind,
		Prompt = prompt,
		Permission = permission,
		OwnerUserId = ownerUserId,
		Cooldown = options.Cooldown or def.Cooldown or 0.4,
		LastUse = setmetatable({}, { __mode = "k" }) :: any,
	}
	entriesByPrompt[prompt] = entry
	entriesByObject[object] = entry

	object.Destroying:Once(function()
		InteractionService.Detach(object)
	end)
	return prompt
end

function InteractionService.Detach(object: Instance)
	local entry = entriesByObject[object]
	if not entry then
		return
	end
	entriesByObject[object] = nil
	entriesByPrompt[entry.Prompt] = nil
	entry.Prompt:Destroy()
end

-- Dynamic prompt text, e.g. "Harvest Wheat" -> "Water Wheat".
function InteractionService.SetText(object: Instance, actionText: string?, objectText: string?)
	local entry = entriesByObject[object]
	if not entry then
		return
	end
	if actionText then
		entry.Prompt.ActionText = actionText
	end
	if objectText then
		entry.Prompt.ObjectText = objectText
	end
end

function InteractionService.SetEnabled(object: Instance, enabled: boolean)
	local entry = entriesByObject[object]
	if entry then
		entry.Prompt.Enabled = enabled
	end
end

local function onTriggered(prompt: ProximityPrompt, player: Player)
	local entry = entriesByPrompt[prompt]
	if not entry then
		return
	end
	if not limiter:Check(player) then
		AntiExploitService.Flag(player, "InteractSpam", 1)
		return
	end
	if not prompt.Enabled then
		return
	end

	local character = player.Character
	local root = R15.GetRootPart(character)
	if not root or not R15.IsAlive(character) then
		return
	end
	local promptParent = prompt.Parent
	local position = promptParent and getWorldPosition(promptParent)
	if not position or (root.Position - position).Magnitude > prompt.MaxActivationDistance + DISTANCE_TOLERANCE then
		AntiExploitService.Flag(player, "InteractTooFar:" .. entry.Kind, 2)
		return
	end

	local now = os.clock()
	local last = entry.LastUse[player]
	if last and now - last < entry.Cooldown then
		return
	end
	entry.LastUse[player] = now

	if accessResolver and not accessResolver(player, entry.Object, entry.Permission, entry.OwnerUserId) then
		Notify.Error(player, "You can't do that on someone else's island.")
		return
	end

	local def = kinds[entry.Kind]
	local ok, err = pcall(def.Handler, player, entry.Object, prompt)
	if not ok then
		warn(("[Interaction] %s handler failed for %s: %s"):format(entry.Kind, player.Name, tostring(err)))
	end
end

function InteractionService.Start()
	ProximityPromptService.PromptTriggered:Connect(onTriggered)
end

return InteractionService
