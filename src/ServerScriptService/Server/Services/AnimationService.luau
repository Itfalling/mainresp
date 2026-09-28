--[[
	SCRIPT NAME:  AnimationService
	SCRIPT TYPE:  ModuleScript (server service)
	WHERE:        ServerScriptService/Server/Services/AnimationService
	DEPENDENCIES: Shared.Config.AnimationConfig, Shared.Util.{AssetId, R15}

	Server half of the animation system. Animations are REPLICATED STATE,
	not remote calls: the server stamps attributes on the rig and every
	client renders them (Client/Controllers/AnimationController), so all
	players see each other chop, hammer, fish, milk and celebrate.

		ActionAnim = "Name;ServerStartTime;Speed;Seq"   one-shot or looped action
		HoldPose   = "Axe" | "Rod" | "Item" | ...        what the hands are holding

	The keyframes themselves live in Shared/Animation/Keyframes (real R15
	joint keyframes, played on Motor6D.Transform). If you upload a real
	animation and paste its id into AnimationConfig, clients play that
	instead — nothing here changes.

	SERVER-DRIVEN ACTIONS (interaction + animation + marker together):
		PerformAction(player, animationName, markerName, onMarker, options?) -> boolean
	The gameplay result is applied at the SAME marker time the animation
	uses (from AnimationConfig). A per-player busy lock stops actions from
	overlapping or being spammed.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Shared
local AnimationConfig = require(Shared.Config.AnimationConfig)
local AssetId = require(Shared.Util.AssetId)
local R15 = require(Shared.Util.R15)

local AnimationService = {}

local busyUntil: { [Player]: number } = {}
local sequence = 0

local function currentName(rig: Instance): string?
	local value = rig:GetAttribute("ActionAnim")
	if type(value) ~= "string" or value == "" then
		return nil
	end
	return string.match(value, "^([^;]+);")
end

function AnimationService.PlayAnimation(rig: Model, name: string, options: { Speed: number? }?): boolean
	local def = AnimationConfig.Get(name)
	if not def then
		warn("[AnimationService] Unknown animation " .. tostring(name))
		return false
	end
	sequence += 1
	local speed = math.clamp((options and options.Speed) or 1, 0.1, 5)
	rig:SetAttribute("ActionAnim", ("%s;%.3f;%.2f;%d"):format(name, workspace:GetServerTimeNow(), speed, sequence))
	return true
end

function AnimationService.StopAnimation(rig: Model, name: string, _fadeTime: number?)
	if currentName(rig) == name then
		rig:SetAttribute("ActionAnim", "")
	end
end

function AnimationService.StopAllAnimations(rig: Model, _fadeTime: number?)
	rig:SetAttribute("ActionAnim", "")
end

function AnimationService.IsPlaying(rig: Model, name: string): boolean
	return currentName(rig) == name
end

-- What the character's hands hold (drives the hold pose on every client).
function AnimationService.SetHoldPose(rig: Model, pose: string?)
	rig:SetAttribute("HoldPose", pose)
end

function AnimationService.IsBusy(player: Player): boolean
	return (busyUntil[player] or 0) > os.clock()
end

export type ActionOptions = {
	Speed: number?,
	LockFraction: number?, -- share of the animation length the player stays busy (default 0.85)
}

-- Plays an action animation (seen by everyone) and runs onMarker on the
-- server at the configured marker time. Returns false if the player is busy.
function AnimationService.PerformAction(player: Player, animationName: string, markerName: string?, onMarker: () -> (), options: ActionOptions?): boolean
	if AnimationService.IsBusy(player) then
		return false
	end
	local def = AnimationConfig.Get(animationName)
	if not def then
		warn("[AnimationService] Unknown action animation " .. tostring(animationName))
		return false
	end
	local speed = math.max((options and options.Speed) or 1, 0.1)
	local lockFraction = (options and options.LockFraction) or 0.85
	local markerTime = (markerName and def.Markers[markerName]) or def.Length * 0.5
	busyUntil[player] = os.clock() + def.Length / speed * lockFraction

	local character = player.Character
	if character then
		AnimationService.PlayAnimation(character, animationName, { Speed = speed })
	end
	task.delay(markerTime / speed, function()
		if player.Parent and player.Character == character and R15.IsAlive(character) then
			local ok, err = pcall(onMarker)
			if not ok then
				warn(("[AnimationService] Action %s failed: %s"):format(animationName, tostring(err)))
			end
		end
	end)
	return true
end

Players.PlayerRemoving:Connect(function(player)
	busyUntil[player] = nil
end)

-- Writes real Movement ids into the default Animate script (idle/walk/run...).
-- Placeholder ids are skipped, so Roblox's default R15 animations stay active.
function AnimationService.ApplyMovementOverrides(character: Model)
	local animate = character:FindFirstChild("Animate")
	if not animate then
		return
	end
	for _, def in AnimationConfig.Categories.Movement do
		local slot = def.AnimateSlot
		if slot and not AssetId.IsPlaceholder(def.Id) then
			local folder = animate:FindFirstChild(slot[1])
			local animation = folder and folder:FindFirstChild(slot[2])
			if animation and animation:IsA("Animation") then
				animation.AnimationId = def.Id
			end
		end
	end
end

return AnimationService
