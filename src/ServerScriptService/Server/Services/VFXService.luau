--[[
	SCRIPT NAME:  VFXService
	SCRIPT TYPE:  ModuleScript (server service)
	WHERE:        ServerScriptService/Server/Services/VFXService
	DEPENDENCIES: Shared.Net, Shared.Config.{VFXConfig, GameConfig}

	Server-side entry point for effects and camera feedback. Clients render
	them (VFXController / CameraController) with pooling and distance culling.
]]

local Players = game:GetService("Players")
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

export type Options = {
	Color: Color3?,
	Count: number?,
	Scale: number?,
	Target: Instance?,
	Style: string?, -- Jiggle: "Squash" | "Tilt" | "Pop" | "Hop"
	From: Vector3?,
}

-- Everyone nearby sees it (clients cull by VFXConfig.MaxDistance).
function VFXService.PlayAt(effectName: string, position: Vector3, options: Options?)
	if isKnown(effectName) then
		Net.FireAllClients("PlayVFX", effectName, position, options)
	end
end

-- Only one player sees it (personal feedback).
function VFXService.PlayFor(player: Player, effectName: string, position: Vector3, options: Options?)
	if isKnown(effectName) then
		Net.FireClient("PlayVFX", player, effectName, position, options)
	end
end

-- Cartoon squash / tilt / pop of a model, seen by everyone.
function VFXService.Jiggle(target: Instance?, style: string, from: Vector3?)
	if not target or not target.Parent then
		return
	end
	local position = if target:IsA("Model") then target:GetPivot().Position elseif target:IsA("BasePart") then target.Position else nil
	if position then
		VFXService.PlayAt("Jiggle", position, { Target = target, Style = style, From = from })
	end
end

-- style: nil (noise shake) | "Wobble" (bouncy cartoon wobble) | "Kick" (hit nod)
function VFXService.ShakeCamera(player: Player, intensity: number, duration: number?, style: string?)
	local capped = math.clamp(intensity, 0, GameConfig.Camera.MaxShakeIntensity)
	Net.FireClient("CameraShake", player, capped, duration or 0.3, style)
end

-- Wobbles the camera of everyone near a big impact (stronger up close).
function VFXService.WobbleNear(position: Vector3, radius: number, strength: number, duration: number?)
	for _, player in Players:GetPlayers() do
		local character = player.Character
		local root = character and character:FindFirstChild("HumanoidRootPart")
		if root and root:IsA("BasePart") then
			local distance = (root.Position - position).Magnitude
			if distance <= radius then
				local falloff = 1 - (distance / radius) * 0.7
				VFXService.ShakeCamera(player, strength * falloff, duration, "Wobble")
			end
		end
	end
end

return VFXService
