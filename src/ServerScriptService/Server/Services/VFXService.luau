--[[
	SCRIPT NAME:  VFXService
	SCRIPT TYPE:  ModuleScript (server service)
	WHERE:        ServerScriptService/Server/Services/VFXService
	DEPENDENCIES: Shared.Net, Shared.Config.{VFXConfig, GameConfig}

	Server-side entry point for effects and camera feedback. Clients render
	them (VFXController / CameraController) with pooling and distance culling.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Shared
local Net = require(Shared.Net)
local VFXConfig = require(Shared.Config.VFXConfig)
local GameConfig = require(Shared.Config.GameConfig)

local VFXService = {}

local function isKnown(effectName: string): boolean
	if VFXConfig.Effects[effectName] then
		return true
	end
	warn("[VFXService] Unknown effect '" .. tostring(effectName) .. "'")
	return false
end

-- Everyone nearby sees it (clients cull by VFXConfig.MaxDistance).
function VFXService.PlayAt(effectName: string, position: Vector3)
	if isKnown(effectName) then
		Net.FireAllClients("PlayVFX", effectName, position)
	end
end

-- Only one player sees it (personal feedback).
function VFXService.PlayFor(player: Player, effectName: string, position: Vector3)
	if isKnown(effectName) then
		Net.FireClient("PlayVFX", player, effectName, position)
	end
end

function VFXService.ShakeCamera(player: Player, intensity: number, duration: number?)
	local capped = math.clamp(intensity, 0, GameConfig.Camera.MaxShakeIntensity)
	Net.FireClient("CameraShake", player, capped, duration or 0.3)
end

return VFXService
