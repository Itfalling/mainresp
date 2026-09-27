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
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Shared
local Net = require(Shared.Net)
local AnimationPlayer = require(Shared.Animation.AnimationPlayer)
local AnimationConfig = require(Shared.Config.AnimationConfig)
local AssetId = require(Shared.Util.AssetId)

local AnimationService = {}

local players: { [Model]: any } = {}

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
