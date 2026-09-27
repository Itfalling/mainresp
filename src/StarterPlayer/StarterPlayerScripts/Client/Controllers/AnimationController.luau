--[[
	SCRIPT NAME:  AnimationController
	SCRIPT TYPE:  ModuleScript (client controller)
	WHERE:        StarterPlayerScripts/Client/Controllers/AnimationController
	DEPENDENCIES: Shared.Net, Shared.Animation.AnimationPlayer, Shared.Config.AnimationConfig,
	              AudioController, VFXController, CameraController, Shared.Util.R15

	Client half of the centralized animation system. Owns ONE AnimationPlayer
	for the local R15 character (recreated on respawn; tracks are cached, never
	reloaded per play). Local playback replicates to other players through the
	Animator, and gives instant response to input.

	MarkerEffects in AnimationConfig are applied here automatically, so sound,
	VFX and camera shake always line up with the animation marker that caused
	them (spec §13, §74). Gameplay code subscribes to the same markers.

	API (spec §71):
		PlayAnimation(name, options?) -> handle | nil
		StopAnimation(name, fade?)
		StopAllAnimations(fade?)
		GetAnimation(name) -> handle | nil
		SetAnimationSpeed(name, speed)
		IsPlaying(name) -> boolean
		MarkerReached  Signal(animationName, markerName, handle)
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Net = require(Shared:WaitForChild("Net"))
local AnimationPlayer = require(Shared.Animation.AnimationPlayer)
local AnimationConfig = require(Shared.Config.AnimationConfig)
local Signal = require(Shared.Util.Signal)
local R15 = require(Shared.Util.R15)

local Controllers = script.Parent
local AudioController = require(Controllers.AudioController)
local VFXController = require(Controllers.VFXController)
local CameraController = require(Controllers.CameraController)

local AnimationController = {}

AnimationController.MarkerReached = Signal.new()
AnimationController.CharacterReady = Signal.new() -- (character)

local current: any = nil
local character: Model? = nil

local function effectPosition(): Vector3?
	local root = R15.GetRootPart(character)
	if not root then
		return nil
	end
	-- Just in front of the character, near the ground — where tools make contact.
	return (root.CFrame * CFrame.new(0, -1.5, -3)).Position
end

local function onMarker(animationName: string, markerName: string, handle: any)
	local def = AnimationConfig.Get(animationName)
	local effects = def and def.MarkerEffects[markerName]
	if effects then
		local position = effectPosition()
		if position then
			if effects.Sound then
				AudioController.PlayAt(effects.Sound, position)
			end
			if effects.VFX then
				VFXController.Play(effects.VFX, position)
			end
		end
		if effects.Shake then
			CameraController.Shake(effects.Shake, 0.25)
		end
	end
	AnimationController.MarkerReached:Fire(animationName, markerName, handle)
end

local function setupCharacter(newCharacter: Model)
	if current then
		current:Destroy()
		current = nil
	end
	character = newCharacter
	local humanoid = newCharacter:WaitForChild("Humanoid", 10)
	if not humanoid then
		return
	end
	humanoid:WaitForChild("Animator", 10)
	if character ~= newCharacter then
		return -- respawned again while waiting
	end
	current = AnimationPlayer.new(newCharacter, { EnableFallback = true })
	current.MarkerReached:Connect(onMarker)

	-- Preload tool/building tracks that have real ids so the first swing has no hitch.
	local preload = {}
	for name in AnimationConfig.Categories.Tools do
		table.insert(preload, name)
	end
	for name in AnimationConfig.Categories.Building do
		table.insert(preload, name)
	end
	current:Preload(preload)
	AnimationController.CharacterReady:Fire(newCharacter)
end

function AnimationController.PlayAnimation(name: string, options: AnimationPlayer.PlayOptions?): any
	if not current then
		return nil
	end
	return current:Play(name, options)
end

function AnimationController.StopAnimation(name: string, fadeTime: number?)
	if current then
		current:Stop(name, fadeTime)
	end
end

function AnimationController.StopAllAnimations(fadeTime: number?)
	if current then
		current:StopAll(fadeTime)
	end
end

function AnimationController.GetAnimation(name: string): any
	return current and current:GetHandle(name)
end

function AnimationController.SetAnimationSpeed(name: string, speed: number)
	if current then
		current:SetSpeed(name, speed)
	end
end

function AnimationController.IsPlaying(name: string): boolean
	return current ~= nil and current:IsPlaying(name)
end

function AnimationController.Start()
	local player = Players.LocalPlayer
	player.CharacterAdded:Connect(setupCharacter)
	if player.Character then
		task.spawn(setupCharacter, player.Character)
	end

	Net.OnClientEvent("AnimationCommand", function(command: any)
		if type(command) ~= "table" then
			return
		end
		if command.Op == "Play" and type(command.Name) == "string" then
			AnimationController.PlayAnimation(command.Name, { Speed = command.Speed })
		elseif command.Op == "Stop" and type(command.Name) == "string" then
			AnimationController.StopAnimation(command.Name, command.Fade)
		elseif command.Op == "StopAll" then
			AnimationController.StopAllAnimations(command.Fade)
		elseif command.Op == "Speed" and type(command.Name) == "string" and type(command.Speed) == "number" then
			AnimationController.SetAnimationSpeed(command.Name, command.Speed)
		end
	end)
end

return AnimationController
