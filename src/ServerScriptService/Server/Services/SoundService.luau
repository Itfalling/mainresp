--[[
	SCRIPT NAME:  SoundService  (game service wrapper — not Roblox's SoundService)
	SCRIPT TYPE:  ModuleScript (server service)
	WHERE:        ServerScriptService/Server/Services/SoundService
	DEPENDENCIES: Shared.Net, Shared.Config.SoundConfig

	Server-side entry point for gameplay sounds. The server decides WHAT
	happened; clients (AudioController) do the actual playback so sounds are
	pooled and never replicate as Instances.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Shared
local Net = require(Shared.Net)
local SoundConfig = require(Shared.Config.SoundConfig)

local HEARING_RANGE = 150

local GameSoundService = {}

local function isKnown(soundName: string): boolean
	if SoundConfig.Sounds[soundName] then
		return true
	end
	warn("[SoundService] Unknown sound '" .. tostring(soundName) .. "'")
	return false
end

-- 2D sound for one player (UI-style).
function GameSoundService.PlayFor(player: Player, soundName: string)
	if isKnown(soundName) then
		Net.FireClient("PlaySound", player, soundName, nil)
	end
end

-- 3D sound heard by everyone near `position`.
function GameSoundService.PlayAt(soundName: string, position: Vector3)
	if not isKnown(soundName) then
		return
	end
	for _, player in Players:GetPlayers() do
		local character = player.Character
		local root = character and character:FindFirstChild("HumanoidRootPart")
		if root and root:IsA("BasePart") and (root.Position - position).Magnitude <= HEARING_RANGE then
			Net.FireClient("PlaySound", player, soundName, position)
		end
	end
end

return GameSoundService
