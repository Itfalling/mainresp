--[[
	SCRIPT NAME:  CropModels
	SCRIPT TYPE:  ModuleScript (server)
	WHERE:        ServerScriptService/Server/Island/CropModels
	DEPENDENCIES: Shared.Config.CropConfig

	Procedural crop visuals for each growth stage (1 Seed .. 6 Harvestable),
	by crop Shape (Grain, Root, Tall, Bush). Models are small and only rebuilt
	when a tile's stage changes.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CropConfig = require(ReplicatedStorage.Shared.Config.CropConfig)

local CropModels = {}

local function part(model: Model, size: Vector3, cframe: CFrame, color: Color3, shape: Enum.PartType?, material: Enum.Material?)
	local newPart = Instance.new("Part")
	newPart.Anchored = true
	newPart.CanCollide = false
	newPart.CanQuery = false
	newPart.CanTouch = false
	newPart.CastShadow = false
	newPart.Shape = shape or Enum.PartType.Block
	newPart.Size = size
	newPart.CFrame = cframe
	newPart.Color = color
	newPart.Material = material or Enum.Material.SmoothPlastic
	newPart.TopSurface = Enum.SurfaceType.Smooth
	newPart.BottomSurface = Enum.SurfaceType.Smooth
	newPart.Parent = model
	return newPart
end

-- 3x3 grid of plants on a 4x4 tile.
local SPOTS = {
	Vector2.new(-1.1, -1.1), Vector2.new(0, -1.1), Vector2.new(1.1, -1.1),
	Vector2.new(-1.1, 0), Vector2.new(0, 0), Vector2.new(1.1, 0),
	Vector2.new(-1.1, 1.1), Vector2.new(0, 1.1), Vector2.new(1.1, 1.1),
}

-- `top` = CFrame of the tile's top surface centre.
function CropModels.Build(cropId: string, stage: number, top: CFrame): Model
	local crop = CropConfig.Crops[cropId]
	local model = Instance.new("Model")
	model.Name = "Crop"
	if not crop then
		return model
	end
	local stalk = crop.StalkColor
	local produce = crop.ProduceColor
	local growth = math.clamp((stage - 1) / 4, 0, 1) -- 0 at Seed, 1 at Mature
	local ready = stage >= #CropConfig.Stages

	for index, spot in SPOTS do
		local base = top * CFrame.new(spot.X, 0, spot.Y) * CFrame.Angles(0, index * 0.7, 0)
		if stage <= 1 then
			part(model, Vector3.new(0.35, 0.2, 0.35), base * CFrame.new(0, 0.1, 0), Color3.fromRGB(120, 85, 50), Enum.PartType.Ball)
		elseif crop.Shape == "Grain" then
			local height = 0.4 + growth * 2.4
			part(model, Vector3.new(0.12, height, 0.12), base * CFrame.new(0, height / 2, 0), if ready then Color3.fromRGB(215, 190, 90) else stalk)
			if stage >= 4 then
				part(model, Vector3.new(0.25, 0.7, 0.25), base * CFrame.new(0, height + 0.2, 0), if ready then produce else stalk:Lerp(produce, 0.3))
			end
		elseif crop.Shape == "Root" then
			local height = 0.3 + growth * 1.1
			for leaf = 1, 3 do
				part(model, Vector3.new(0.1, height, 0.35), base * CFrame.Angles(0, leaf * 2.1, math.rad(18)) * CFrame.new(0, height / 2, 0), stalk)
			end
			if ready then
				part(model, Vector3.new(0.45, 0.45, 0.45), base * CFrame.new(0, 0.1, 0), produce, Enum.PartType.Ball)
			end
		elseif crop.Shape == "Tall" then
			local height = 0.5 + growth * 3.6
			part(model, Vector3.new(0.18, height, 0.18), base * CFrame.new(0, height / 2, 0), stalk)
			if stage >= 3 then
				part(model, Vector3.new(0.9, 0.08, 0.3), base * CFrame.new(0.3, height * 0.6, 0) * CFrame.Angles(0, 0, math.rad(-25)), stalk)
			end
			if ready then
				part(model, Vector3.new(0.35, 0.9, 0.35), base * CFrame.new(0.15, height * 0.7, 0.1), produce)
			end
		else -- Bush
			local size = 0.3 + growth * 1.1
			part(model, Vector3.one * size, base * CFrame.new(0, size / 2, 0), stalk, Enum.PartType.Ball, Enum.Material.Grass)
			if ready then
				for berry = 1, 2 do
					part(model, Vector3.one * 0.35, base * CFrame.new(math.cos(berry * 2) * size * 0.4, size * 0.6, math.sin(berry * 2) * size * 0.4), produce, Enum.PartType.Ball)
				end
			end
		end
	end

	if ready then
		-- Gentle sparkle so ripe crops stand out (spec §150: subtle).
		local emitterPart = part(model, Vector3.new(3.6, 0.2, 3.6), top * CFrame.new(0, 1.5, 0), Color3.new(1, 1, 1))
		emitterPart.Transparency = 1
		local sparkle = Instance.new("ParticleEmitter")
		sparkle.Rate = 2
		sparkle.Lifetime = NumberRange.new(1, 1.5)
		sparkle.Speed = NumberRange.new(0.5, 1)
		sparkle.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.3), NumberSequenceKeypoint.new(1, 0) })
		sparkle.Color = ColorSequence.new(Color3.fromRGB(255, 240, 150))
		sparkle.LightEmission = 1
		sparkle.Parent = emitterPart
	end
	return model
end

return CropModels
