--[[
	SCRIPT NAME:  AudioController
	SCRIPT TYPE:  ModuleScript (client controller)
	WHERE:        StarterPlayerScripts/Client/Controllers/AudioController
	DEPENDENCIES: Shared.Net, Shared.Config.{SoundConfig, GameConfig}, Shared.Util.AssetId, Client.ClientState

	Plays every sound from SoundConfig through small pools (2D + 3D), applying
	category volume, the player's SFX volume setting and a little random pitch.
	Also keeps the background MUSIC and the sea AMBIENCE looping, following
	the player's Music volume setting (Settings window).
	Entries without a verified source are skipped silently (logged once when
	Debug is on).
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RobloxSoundService = game:GetService("SoundService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Net = require(Shared:WaitForChild("Net"))
local SoundConfig = require(Shared.Config.SoundConfig)
local GameConfig = require(Shared.Config.GameConfig)
local AssetId = require(Shared.Util.AssetId)
local ClientState = require(script.Parent.Parent.ClientState)

local POOL_SIZE_2D = 8
local POOL_SIZE_3D = 12

local AudioController = {}

local pool2D: { Sound } = {}
local pool3D: { { Part: Part, Sound: Sound } } = {}
local next2D, next3D = 1, 1
local warned: { [string]: boolean } = {}
local random = Random.new()
local loops: { [string]: Sound } = {}

local function resolve(name: string): any
	local def = SoundConfig.Sounds[name]
	if not def then
		if not warned[name] then
			warned[name] = true
			warn("[Audio] Unknown sound '" .. tostring(name) .. "'")
		end
		return nil
	end
	if AssetId.IsPlaceholder(def.Id) then
		if GameConfig.Debug and not warned[name] then
			warned[name] = true
			print("[Audio] '" .. name .. "' still uses a placeholder id — skipped")
		end
		return nil
	end
	return def
end

local function volumeFor(def: any): number
	local category = SoundConfig.Categories[def.Category] or 1
	local key = if def.Category == "Music" then "MusicVolume" else "SfxVolume"
	local setting = ClientState.Get("Settings", key)
	return def.Volume * category * (if type(setting) == "number" then setting else (if key == "MusicVolume" then 0.5 else 0.8))
end

local function configure(sound: Sound, def: any)
	sound.SoundId = def.Id
	sound.Volume = volumeFor(def)
	sound.PlaybackSpeed = def.PlaybackSpeed * (1 + random:NextNumber(-def.PitchVariation, def.PitchVariation))
	sound.Looped = def.Looped == true
	sound.RollOffMaxDistance = def.RollOffMaxDistance
end

-- 2D sound (UI, personal rewards).
function AudioController.Play(name: string)
	local def = resolve(name)
	if not def then
		return
	end
	local sound = pool2D[next2D]
	next2D = next2D % POOL_SIZE_2D + 1
	sound:Stop()
	configure(sound, def)
	sound:Play()
end

-- 3D sound at a world position.
function AudioController.PlayAt(name: string, position: Vector3)
	local def = resolve(name)
	if not def then
		return
	end
	local emitter = pool3D[next3D]
	next3D = next3D % POOL_SIZE_3D + 1
	emitter.Sound:Stop()
	emitter.Part.CFrame = CFrame.new(position)
	configure(emitter.Sound, def)
	emitter.Sound:Play()
end

-- Starts (or re-levels) a looping 2D track such as the music or ambience.
function AudioController.SetLoop(name: string, playing: boolean)
	local def = resolve(name)
	local sound = loops[name]
	if not def then
		return
	end
	if not sound then
		sound = Instance.new("Sound")
		sound.Name = "Loop_" .. name
		sound.SoundId = def.Id
		sound.Looped = true
		sound.PlaybackSpeed = def.PlaybackSpeed
		sound.Parent = RobloxSoundService
		loops[name] = sound
	end
	sound.Volume = volumeFor(def)
	if playing and not sound.IsPlaying then
		sound:Play()
	elseif not playing and sound.IsPlaying then
		sound:Stop()
	end
end

local function refreshLoops()
	for name, sound in loops do
		local def = resolve(name)
		if def then
			sound.Volume = volumeFor(def)
		end
	end
end

function AudioController.Init()
	for index = 1, POOL_SIZE_2D do
		local sound = Instance.new("Sound")
		sound.Name = "UISound" .. index
		sound.Parent = RobloxSoundService
		pool2D[index] = sound
	end

	local folder = Instance.new("Folder")
	folder.Name = "ClientAudio"
	folder.Parent = workspace
	for index = 1, POOL_SIZE_3D do
		local part = Instance.new("Part")
		part.Name = "AudioEmitter"
		part.Anchored = true
		part.CanCollide = false
		part.CanQuery = false
		part.CanTouch = false
		part.Transparency = 1
		part.Size = Vector3.one
		part.Parent = folder
		local sound = Instance.new("Sound")
		sound.Parent = part
		pool3D[index] = { Part = part, Sound = sound }
	end
end

function AudioController.Start()
	ClientState.Observe("Settings", refreshLoops)
	task.defer(function()
		AudioController.SetLoop("MusicMain", true)
		AudioController.SetLoop("AmbienceOcean", true)
	end)
	Net.OnClientEvent("PlaySound", function(name: string, position: Vector3?)
		if typeof(position) == "Vector3" then
			AudioController.PlayAt(name, position)
		else
			AudioController.Play(name)
		end
	end)
end

return AudioController
