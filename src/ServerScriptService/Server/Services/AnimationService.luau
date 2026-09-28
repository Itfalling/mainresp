--[[
	SCRIPT NAME:  AnimationService
	SCRIPT TYPE:  ModuleScript (server service)
	WHERE:        ServerScriptService/Server/Services/AnimationService
	DEPENDENCIES: Shared.Net, Shared.Animation.AnimationPlayer, Shared.Config.AnimationConfig,
	              Shared.Util.AssetId

	Server half of the centralized animation system (spec §71).
	  * Player characters: the OWNING CLIENT plays animations (responsive, and
	    Animator replication shows them to everyone). The server sends an
	    AnimationCommand to that client.
	  * NPCs / animals (server-owned rigs): played directly here through the
	    same shared AnimationPlayer.
	  * Movement animation overrides: real ids placed in
	    AnimationConfig.Movement are written into each character's default
	    Animate script on spawn.

	API (spec §71):
		PlayAnimation(rig, name, options?) -> handle | nil (nil for player rigs)
		StopAnimation(rig, name, fade?)
		StopAllAnimations(rig, fade?)
		GetAnimation(rig, name) -> handle
		SetAnimationSpeed(rig, name, speed)
		IsPlaying(rig, name) -> boolean   (server rigs only)

	SERVER-DRIVEN ACTIONS (spec §173: interaction + animation + marker together):
		PerformAction(player, animationName, markerName, onMarker, options?) -> boolean
	The owning client plays the animation (its MarkerEffects give the sound /
	VFX at the marker) and the server applies the gameplay result at the SAME
	marker time taken from AnimationConfig. A per-player busy lock stops
	actions overlapping or being spammed.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Shared
local Net = require(Shared.Net)
local AnimationPlayer = require(Shared.Animation.AnimationPlayer)
local AnimationConfig = require(Shared.Config.AnimationConfig)
local AssetId = require(Shared.Util.AssetId)
local R15 = require(Shared.Util.R15)

local AnimationService = {}

local players: { [Model]: any } = {}
local busyUntil: { [Player]: number } = {}

local function getPlayerForRig(rig: Model): Player?
	return Players:GetPlayerFromCharacter(rig)
end

local function getPlayer(rig: Model)
	local animationPlayer = players[rig]
	if not animationPlayer then
		animationPlayer = AnimationPlayer.new(rig)
		players[rig] = animationPlayer
		rig.Destroying:Once(function()
			local existing = players[rig]
			if existing then
				existing:Destroy()
				players[rig] = nil
			end
		end)
	end
	return animationPlayer
end

function AnimationService.PlayAnimation(rig: Model, name: string, options: { Speed: number? }?): any
	local owner = getPlayerForRig(rig)
	if owner then
		Net.FireClient("AnimationCommand", owner, { Op = "Play", Name = name, Speed = options and options.Speed })
		return nil
	end
	return getPlayer(rig):Play(name, options)
end

function AnimationService.StopAnimation(rig: Model, name: string, fadeTime: number?)
	local owner = getPlayerForRig(rig)
	if owner then
		Net.FireClient("AnimationCommand", owner, { Op = "Stop", Name = name, Fade = fadeTime })
		return
	end
	local animationPlayer = players[rig]
	if animationPlayer then
		animationPlayer:Stop(name, fadeTime)
	end
end

function AnimationService.StopAllAnimations(rig: Model, fadeTime: number?)
	local owner = getPlayerForRig(rig)
	if owner then
		Net.FireClient("AnimationCommand", owner, { Op = "StopAll", Fade = fadeTime })
		return
	end
	local animationPlayer = players[rig]
	if animationPlayer then
		animationPlayer:StopAll(fadeTime)
	end
end

function AnimationService.GetAnimation(rig: Model, name: string): any
	local animationPlayer = players[rig]
	return animationPlayer and animationPlayer:GetHandle(name)
end

function AnimationService.SetAnimationSpeed(rig: Model, name: string, speed: number)
	local owner = getPlayerForRig(rig)
	if owner then
		Net.FireClient("AnimationCommand", owner, { Op = "Speed", Name = name, Speed = speed })
		return
	end
	local animationPlayer = players[rig]
	if animationPlayer then
		animationPlayer:SetSpeed(name, speed)
	end
end

function AnimationService.IsPlaying(rig: Model, name: string): boolean
	local animationPlayer = players[rig]
	return animationPlayer ~= nil and animationPlayer:IsPlaying(name)
end

function AnimationService.IsBusy(player: Player): boolean
	return (busyUntil[player] or 0) > os.clock()
end

export type ActionOptions = {
	Speed: number?,
	LockFraction: number?, -- share of the animation length the player stays busy (default 0.85)
}

-- Plays an action animation on the player's client and runs onMarker on the
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
