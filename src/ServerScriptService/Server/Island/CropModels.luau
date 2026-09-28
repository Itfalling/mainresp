--[[
	SCRIPT NAME:  CropModels
	SCRIPT TYPE:  ModuleScript (server)
	WHERE:        ServerScriptService/Server/Island/CropModels
	DEPENDENCIES: Shared.Config.CropConfig

	Procedural crop visuals for each growth stage (1 Seed .. 6 Harvestable),
	by crop Shape: Grain (wheat heads with whiskers), Root (feathery tops, the
	root shoulder shows when ripe), Tall (corn with broad leaves and husked
	cobs), Bush (shaded leafy bush with shiny fruit). Soft, rounded,
	cartoon-realistic. Models are small and only rebuilt when a tile's stage
	changes.
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

	local function sphere(size: Vector3, cframe: CFrame, color: Color3): BasePart
		local piece = part(model, size, cframe, color)
		local mesh = Instance.new("SpecialMesh")
		mesh.MeshType = Enum.MeshType.Sphere
		mesh.Parent = piece
		return piece
	end
	local leafDark = stalk:Lerp(Color3.new(0, 0, 0), 0.18)

	for index, spot in SPOTS do
		local base = top * CFrame.new(spot.X, 0, spot.Y) * CFrame.Angles(0, index * 0.7, 0)
		if stage <= 1 then
			-- A little mound of soil with a seed peeking out.
			sphere(Vector3.new(0.55, 0.22, 0.55), base * CFrame.new(0, 0.05, 0), Color3.fromRGB(112, 80, 50))
			part(model, Vector3.new(0.16, 0.12, 0.16), base * CFrame.new(0, 0.14, 0), Color3.fromRGB(226, 196, 120), Enum.PartType.Ball)
		elseif crop.Shape == "Grain" then
			-- Wheat: slender stalks, blade leaves, a plump golden head with whiskers.
			local height = 0.4 + growth * 2.4
			local stemColor = if ready then Color3.fromRGB(222, 196, 100) else stalk
			part(model, Vector3.new(0.1, height, 0.1), base * CFrame.new(0, height / 2, 0), stemColor, Enum.PartType.Block)
			for leaf = 1, 2 do
				sphere(Vector3.new(0.14, height * 0.45, 0.3), base * CFrame.Angles(0, leaf * math.pi, math.rad(28)) * CFrame.new(0, height * 0.25, 0), if ready then stemColor:Lerp(Color3.new(0, 0, 0), 0.1) else leafDark)
			end
			if stage >= 4 then
				local headColor = if ready then produce else stalk:Lerp(produce, 0.35)
				sphere(Vector3.new(0.28, 0.8, 0.28), base * CFrame.new(0, height + 0.3, 0), headColor)
				for awn = 1, 3 do
					part(model, Vector3.new(0.03, 0.5, 0.03), base * CFrame.new(0, height + 0.62, 0) * CFrame.Angles(math.rad(12), awn * 2.1, 0) * CFrame.new(0, 0.25, 0), headColor:Lerp(Color3.new(1, 1, 1), 0.2))
				end
			end
		elseif crop.Shape == "Root" then
			-- Carrot-style: a fan of feathery leaves; the root shoulder shows when ripe.
			local height = 0.3 + growth * 1.2
			for leaf = 1, 4 do
				sphere(Vector3.new(0.22, height, 0.4), base * CFrame.Angles(0, leaf * 1.57, math.rad(22)) * CFrame.new(0, height / 2, 0), if leaf % 2 == 0 then stalk else leafDark)
			end
			if ready then
				sphere(Vector3.new(0.55, 0.5, 0.55), base * CFrame.new(0, 0.1, 0), produce)
				sphere(Vector3.new(0.3, 0.14, 0.3), base * CFrame.new(-0.08, 0.3, -0.08), produce:Lerp(Color3.new(1, 1, 1), 0.3))
			end
		elseif crop.Shape == "Tall" then
			-- Corn-style: a tall stalk with broad drooping leaves and husked cobs.
			local height = 0.5 + growth * 3.6
			local stalkSize, upright = Vector3.new(height, 0.2, 0.2), CFrame.Angles(0, 0, math.rad(90))
			local stem = part(model, stalkSize, base * CFrame.new(0, height / 2, 0) * upright, stalk, Enum.PartType.Cylinder)
			stem.Size = stalkSize
			if stage >= 3 then
				for leaf = 1, 3 do
					local y = height * (0.3 + leaf * 0.18)
					sphere(Vector3.new(0.12, 0.3, 1.3), base * CFrame.new(0, y, 0) * CFrame.Angles(math.rad(-30), leaf * 2.2, 0) * CFrame.new(0, 0, -0.55), if leaf % 2 == 0 then stalk else leafDark)
				end
				sphere(Vector3.new(0.22, 0.5, 0.22), base * CFrame.new(0, height + 0.2, 0), Color3.fromRGB(226, 200, 120))
			end
			if ready then
				local cob = base * CFrame.new(0.18, height * 0.62, 0.1) * CFrame.Angles(0, 0, math.rad(-18))
				sphere(Vector3.new(0.38, 0.95, 0.38), cob, produce)
				sphere(Vector3.new(0.3, 0.8, 0.44), cob * CFrame.new(0.08, -0.12, 0), stalk:Lerp(Color3.fromRGB(255, 255, 200), 0.2))
			end
		else -- Bush
			-- Tomato-style: shaded leafy bush with shiny round fruit.
			local size = 0.3 + growth * 1.1
			sphere(Vector3.new(size * 1.1, size * 0.8, size * 1.1), base * CFrame.new(0, size * 0.35, 0), leafDark)
			sphere(Vector3.new(size * 0.8, size * 0.65, size * 0.8), base * CFrame.new(0, size * 0.62, 0), stalk)
			sphere(Vector3.new(size * 0.45, size * 0.3, size * 0.45), base * CFrame.new(-size * 0.1, size * 0.88, -size * 0.1), stalk:Lerp(Color3.fromRGB(255, 255, 200), 0.2))
			if ready then
				for berry = 1, 3 do
					local offset = CFrame.new(math.cos(berry * 2.1) * size * 0.45, size * 0.5, math.sin(berry * 2.1) * size * 0.45)
					local fruit = part(model, Vector3.one * 0.38, base * offset, produce, Enum.PartType.Ball)
					fruit.Reflectance = 0.08
					part(model, Vector3.new(0.12, 0.06, 0.12), base * offset * CFrame.new(0, 0.19, 0), leafDark)
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
