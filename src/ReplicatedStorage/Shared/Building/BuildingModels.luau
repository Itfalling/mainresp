--[[
	SCRIPT NAME:  BuildingModels
	SCRIPT TYPE:  ModuleScript (shared)
	WHERE:        ReplicatedStorage/Shared/Building/BuildingModels
	DEPENDENCIES: Shared.Config.BuildingConfig

	Procedural, low-poly models for every building in BuildingConfig. Shared so
	the client's ghost preview and the server's real building are identical.

	Every part carries a "Stage" attribute (0 = always present). Construction
	reveals stages one hammer hit at a time (spec §11: foundation → walls →
	roof → details), via BuildingModels.SetStage().

	Model contract:
	  * PrimaryPart "Base": invisible footprint-sized plate used for overlap
	    checks and selection.
	  * WorldPivot = base centre on the ground, front facing -Z.
	To use real art instead, put a Model with the building id in
	ServerStorage/Buildings (see docs/ASSETS.md); tag its parts with Stage.
]]

local TweenService = game:GetService("TweenService")

local BuildingConfig = require(script.Parent.Parent.Config.BuildingConfig)

local BuildingModels = {}

local C = {
	Wood = Color3.fromRGB(170, 120, 72),
	WoodDark = Color3.fromRGB(112, 76, 46),
	Plaster = Color3.fromRGB(246, 234, 204),
	Stone = Color3.fromRGB(160, 158, 150),
	StoneDark = Color3.fromRGB(120, 118, 112),
	RoofRed = Color3.fromRGB(190, 78, 58),
	RoofBrown = Color3.fromRGB(120, 72, 52),
	RoofBlue = Color3.fromRGB(70, 110, 170),
	BarnRed = Color3.fromRGB(178, 58, 46),
	White = Color3.fromRGB(245, 245, 240),
	Glass = Color3.fromRGB(155, 215, 245),
	Leaf = Color3.fromRGB(80, 170, 70),
	Soil = Color3.fromRGB(105, 72, 45),
	Water = Color3.fromRGB(70, 160, 220),
	Warm = Color3.fromRGB(255, 200, 120),
}

type PartProps = {
	Name: string?,
	Size: Vector3,
	CFrame: CFrame,
	Color: Color3,
	Material: Enum.Material?,
	Shape: Enum.PartType?,
	Wedge: boolean?,
	CanCollide: boolean?,
	Transparency: number?,
}

local function part(model: Model, stage: number, props: PartProps): BasePart
	local newPart: BasePart
	if props.Wedge then
		newPart = Instance.new("WedgePart")
	else
		local block = Instance.new("Part")
		block.Shape = props.Shape or Enum.PartType.Block
		newPart = block
	end
	newPart.Name = props.Name or "Piece"
	newPart.Anchored = true
	newPart.Size = props.Size
	newPart.CFrame = props.CFrame
	newPart.Color = props.Color
	newPart.Material = props.Material or Enum.Material.SmoothPlastic
	newPart.TopSurface = Enum.SurfaceType.Smooth
	newPart.BottomSurface = Enum.SurfaceType.Smooth
	local canCollide = if props.CanCollide == nil then true else props.CanCollide
	newPart.CanCollide = canCollide
	newPart.Transparency = props.Transparency or 0
	newPart:SetAttribute("Stage", stage)
	newPart:SetAttribute("BaseTransparency", newPart.Transparency)
	newPart:SetAttribute("BaseCanCollide", canCollide)
	newPart.Parent = model
	return newPart
end

local function cylinderY(height: number, diameter: number): (Vector3, CFrame)
	-- Roblox cylinders run along X; rotate so they stand up.
	return Vector3.new(height, diameter, diameter), CFrame.Angles(0, 0, math.rad(90))
end

-- Gable roof: two sloped wedges + two triangular gable ends.
local function gableRoof(model: Model, stageRoofA: number, stageRoofB: number, width: number, depth: number, baseY: number, rise: number, zOffset: number, color: Color3, gableColor: Color3)
	local halfDepth = depth / 2 + 0.8
	part(model, stageRoofA, {
		Name = "RoofFront",
		Wedge = true,
		Size = Vector3.new(width + 1.6, rise, halfDepth),
		CFrame = CFrame.new(0, baseY + rise / 2, zOffset - halfDepth / 2),
		Color = color,
		Material = Enum.Material.SmoothPlastic,
	})
	part(model, stageRoofB, {
		Name = "RoofBack",
		Wedge = true,
		Size = Vector3.new(width + 1.6, rise, halfDepth),
		CFrame = CFrame.new(0, baseY + rise / 2, zOffset + halfDepth / 2) * CFrame.Angles(0, math.pi, 0),
		Color = color,
		Material = Enum.Material.SmoothPlastic,
	})
	local gableWidth = (width - 0.6) / 2
	for _, z in { zOffset - (depth / 2 - 0.3), zOffset + (depth / 2 - 0.3) } do
		part(model, stageRoofB, {
			Name = "GableL",
			Wedge = true,
			Size = Vector3.new(0.6, rise, gableWidth),
			CFrame = CFrame.new(-gableWidth / 2, baseY + rise / 2, z) * CFrame.Angles(0, math.rad(90), 0),
			Color = gableColor,
		})
		part(model, stageRoofB, {
			Name = "GableR",
			Wedge = true,
			Size = Vector3.new(0.6, rise, gableWidth),
			CFrame = CFrame.new(gableWidth / 2, baseY + rise / 2, z) * CFrame.Angles(0, math.rad(-90), 0),
			Color = gableColor,
		})
	end
	part(model, stageRoofB, {
		Name = "Ridge",
		Size = Vector3.new(width + 1.8, 0.5, 0.6),
		CFrame = CFrame.new(0, baseY + rise, zOffset),
		Color = C.WoodDark,
		Material = Enum.Material.Wood,
	})
end

type HouseParams = {
	Width: number,
	Depth: number,
	WallHeight: number,
	RoofRise: number,
	WallColor: Color3,
	WallMaterial: Enum.Material,
	RoofColor: Color3,
	Steps: number,
	ZOffset: number?,
}

-- Walls with a door (front, -Z) and windows; 10 build groups mapped onto Steps.
local function house(model: Model, p: HouseParams)
	local function stage(group: number): number
		return math.max(1, math.ceil(group * p.Steps / 10))
	end
	local w, d, h = p.Width, p.Depth, p.WallHeight
	local z0 = p.ZOffset or 0
	local floorY = 0.6

	-- 1 foundation
	part(model, stage(1), { Name = "Foundation", Size = Vector3.new(w + 0.4, 1.6, d + 0.4), CFrame = CFrame.new(0, -0.5, z0), Color = C.Stone, Material = Enum.Material.Cobblestone })
	-- 2 floor + corner posts
	part(model, stage(2), { Name = "Floor", Size = Vector3.new(w - 0.2, 0.3, d - 0.2), CFrame = CFrame.new(0, 0.45, z0), Color = C.Wood, Material = Enum.Material.WoodPlanks })
	for _, x in { -(w / 2 - 0.45), w / 2 - 0.45 } do
		for _, z in { -(d / 2 - 0.45), d / 2 - 0.45 } do
			part(model, stage(2), { Name = "Post", Size = Vector3.new(0.9, h, 0.9), CFrame = CFrame.new(x, floorY + h / 2, z0 + z), Color = C.WoodDark, Material = Enum.Material.Wood })
		end
	end
	-- 3 back wall
	part(model, stage(3), { Name = "WallBack", Size = Vector3.new(w - 1.2, h, 0.6), CFrame = CFrame.new(0, floorY + h / 2, z0 + d / 2 - 0.3), Color = p.WallColor, Material = p.WallMaterial })
	-- 4 left wall + window
	part(model, stage(4), { Name = "WallLeft", Size = Vector3.new(0.6, h, d - 1.2), CFrame = CFrame.new(-(w / 2 - 0.3), floorY + h / 2, z0), Color = p.WallColor, Material = p.WallMaterial })
	part(model, stage(4), { Name = "WindowL", Size = Vector3.new(0.7, 2, 2.4), CFrame = CFrame.new(-(w / 2 - 0.3), floorY + h * 0.55, z0), Color = C.Glass, Material = Enum.Material.Glass, Transparency = 0.2 })
	-- 5 right wall + window
	part(model, stage(5), { Name = "WallRight", Size = Vector3.new(0.6, h, d - 1.2), CFrame = CFrame.new(w / 2 - 0.3, floorY + h / 2, z0), Color = p.WallColor, Material = p.WallMaterial })
	part(model, stage(5), { Name = "WindowR", Size = Vector3.new(0.7, 2, 2.4), CFrame = CFrame.new(w / 2 - 0.3, floorY + h * 0.55, z0), Color = C.Glass, Material = Enum.Material.Glass, Transparency = 0.2 })
	-- 6 front wall around the door
	local span = (w - 1.2) / 2
	local segment = span - 1.2
	for _, side in { -1, 1 } do
		part(model, stage(6), { Name = "WallFront", Size = Vector3.new(segment, h, 0.6), CFrame = CFrame.new(side * (1.2 + segment / 2), floorY + h / 2, z0 - (d / 2 - 0.3)), Color = p.WallColor, Material = p.WallMaterial })
		part(model, stage(6), { Name = "WindowF", Size = Vector3.new(math.min(2, segment - 0.8), 1.8, 0.7), CFrame = CFrame.new(side * (1.2 + segment / 2), floorY + h * 0.55, z0 - (d / 2 - 0.3)), Color = C.Glass, Material = Enum.Material.Glass, Transparency = 0.2 })
	end
	part(model, stage(6), { Name = "Lintel", Size = Vector3.new(2.4, h - 4.6, 0.6), CFrame = CFrame.new(0, floorY + 4.6 + (h - 4.6) / 2, z0 - (d / 2 - 0.3)), Color = p.WallColor, Material = p.WallMaterial })
	-- 7-8 roof
	gableRoof(model, stage(7), stage(8), w, d, floorY + h, p.RoofRise, z0, p.RoofColor, p.WallColor)
	-- 9 chimney
	part(model, stage(9), { Name = "Chimney", Size = Vector3.new(1.4, p.RoofRise + 2.4, 1.4), CFrame = CFrame.new(w / 4, floorY + h + (p.RoofRise + 2.4) / 2, z0 + d / 4), Color = C.StoneDark, Material = Enum.Material.Brick })
	-- 10 door + step + flower boxes
	part(model, stage(10), { Name = "Door", Size = Vector3.new(2.2, 4.4, 0.3), CFrame = CFrame.new(0, floorY + 2.2, z0 - (d / 2 - 0.05)), Color = C.WoodDark, Material = Enum.Material.Wood })
	part(model, stage(10), { Name = "Knob", Shape = Enum.PartType.Ball, Size = Vector3.new(0.3, 0.3, 0.3), CFrame = CFrame.new(0.7, floorY + 2.2, z0 - (d / 2 + 0.15)), Color = Color3.fromRGB(240, 200, 80), CanCollide = false })
	part(model, stage(10), { Name = "Step", Size = Vector3.new(3.2, 0.5, 1.4), CFrame = CFrame.new(0, 0.25, z0 - (d / 2 + 0.6)), Color = C.Stone, Material = Enum.Material.Slate })
	for _, side in { -1, 1 } do
		part(model, stage(10), { Name = "FlowerBox", Size = Vector3.new(math.min(2.2, segment - 0.6), 0.5, 0.6), CFrame = CFrame.new(side * (1.2 + segment / 2), floorY + h * 0.55 - 1.2, z0 - (d / 2 + 0.3)), Color = C.Wood, Material = Enum.Material.Wood, CanCollide = false })
		part(model, stage(10), { Name = "Flowers", Size = Vector3.new(math.min(2, segment - 0.8), 0.5, 0.4), CFrame = CFrame.new(side * (1.2 + segment / 2), floorY + h * 0.55 - 0.8, z0 - (d / 2 + 0.3)), Color = Color3.fromRGB(255, 120, 150), CanCollide = false })
	end
end

local function fenceLine(model: Model, stage: number, from: Vector3, to: Vector3, height: number, gap: number?)
	local direction = to - from
	local length = direction.Magnitude
	local unit = direction.Unit
	local center = (from + to) / 2
	local look = CFrame.lookAt(center, center + unit)
	if gap and gap > 0 then
		-- Two rail segments leaving a gate gap in the middle.
		local segment = (length - gap) / 2
		for _, sign in { -1, 1 } do
			local segmentCenter = center + unit * sign * (gap / 2 + segment / 2)
			local segmentLook = CFrame.lookAt(segmentCenter, segmentCenter + unit)
			for _, y in { height * 0.4, height * 0.8 } do
				part(model, stage, { Name = "Rail", Size = Vector3.new(0.25, 0.3, segment), CFrame = segmentLook + Vector3.new(0, y, 0), Color = C.Wood, Material = Enum.Material.Wood })
			end
		end
	else
		for _, y in { height * 0.4, height * 0.8 } do
			part(model, stage, { Name = "Rail", Size = Vector3.new(0.25, 0.3, length), CFrame = look + Vector3.new(0, y, 0), Color = C.Wood, Material = Enum.Material.Wood })
		end
	end
	local posts = math.max(2, math.floor(length / 3.2) + 1)
	for index = 0, posts - 1 do
		local point = from + unit * (length * index / (posts - 1))
		local inGap = gap and gap > 0 and (point - center).Magnitude < gap / 2
		if not inGap then
			part(model, stage, { Name = "Post", Size = Vector3.new(0.4, height, 0.4), CFrame = CFrame.new(point + Vector3.new(0, height / 2, 0)), Color = C.WoodDark, Material = Enum.Material.Wood })
		end
	end
end

local BUILDERS: { [string]: (Model, any) -> () } = {}

BUILDERS.SmallCottage = function(model, def)
	house(model, { Width = 10, Depth = 10, WallHeight = 7, RoofRise = 4, WallColor = C.Plaster, WallMaterial = Enum.Material.SmoothPlastic, RoofColor = C.RoofRed, Steps = def.Steps })
end

BUILDERS.WoodenCabin = function(model, def)
	house(model, { Width = 14, Depth = 12, WallHeight = 7.5, RoofRise = 4.5, WallColor = Color3.fromRGB(150, 100, 60), WallMaterial = Enum.Material.WoodPlanks, RoofColor = C.RoofBrown, Steps = def.Steps })
end

BUILDERS.StoneHouse = function(model, def)
	house(model, { Width = 14, Depth = 14, WallHeight = 8.5, RoofRise = 5, WallColor = C.Stone, WallMaterial = Enum.Material.Cobblestone, RoofColor = C.RoofBlue, Steps = def.Steps })
end

BUILDERS.Barn = function(model, def)
	local s = function(group: number): number
		return math.max(1, math.ceil(group * def.Steps / 7))
	end
	local w, d, h, z0 = 14, 12, 8, -5
	part(model, s(1), { Name = "Foundation", Size = Vector3.new(w + 0.4, 1.6, d + 0.4), CFrame = CFrame.new(0, -0.5, z0), Color = C.Stone, Material = Enum.Material.Cobblestone })
	part(model, s(1), { Name = "Floor", Size = Vector3.new(w - 0.2, 0.3, d - 0.2), CFrame = CFrame.new(0, 0.45, z0), Color = C.Wood, Material = Enum.Material.WoodPlanks })
	for _, x in { -(w / 2 - 0.45), w / 2 - 0.45 } do
		for _, z in { -(d / 2 - 0.45), d / 2 - 0.45 } do
			part(model, s(2), { Name = "Post", Size = Vector3.new(0.9, h, 0.9), CFrame = CFrame.new(x, 0.6 + h / 2, z0 + z), Color = C.White })
		end
	end
	part(model, s(2), { Name = "WallBack", Size = Vector3.new(w - 1.2, h, 0.6), CFrame = CFrame.new(0, 0.6 + h / 2, z0 + d / 2 - 0.3), Color = C.BarnRed, Material = Enum.Material.WoodPlanks })
	for _, side in { -1, 1 } do
		part(model, s(3), { Name = "WallSide", Size = Vector3.new(0.6, h, d - 1.2), CFrame = CFrame.new(side * (w / 2 - 0.3), 0.6 + h / 2, z0), Color = C.BarnRed, Material = Enum.Material.WoodPlanks })
	end
	local doorWidth = 4.4
	local segment = (w - 1.2 - doorWidth) / 2
	for _, side in { -1, 1 } do
		part(model, s(4), { Name = "WallFront", Size = Vector3.new(segment, h, 0.6), CFrame = CFrame.new(side * (doorWidth / 2 + segment / 2), 0.6 + h / 2, z0 - (d / 2 - 0.3)), Color = C.BarnRed, Material = Enum.Material.WoodPlanks })
	end
	part(model, s(4), { Name = "Lintel", Size = Vector3.new(doorWidth, h - 6, 0.6), CFrame = CFrame.new(0, 0.6 + 6 + (h - 6) / 2, z0 - (d / 2 - 0.3)), Color = C.BarnRed, Material = Enum.Material.WoodPlanks })
	gableRoof(model, s(5), s(6), w, d, 0.6 + h, 5, z0, C.RoofBrown, C.BarnRed)
	-- Open barn doors with the classic white X.
	for _, side in { -1, 1 } do
		local doorCFrame = CFrame.new(side * (doorWidth / 2 + 1.1), 0.6 + 3, z0 - (d / 2 + 0.2))
		part(model, s(6), { Name = "Door", Size = Vector3.new(2.2, 6, 0.3), CFrame = doorCFrame, Color = C.BarnRed, Material = Enum.Material.WoodPlanks })
		part(model, s(6), { Name = "DoorX1", Size = Vector3.new(0.3, 6.4, 0.2), CFrame = doorCFrame * CFrame.new(0, 0, -0.2) * CFrame.Angles(0, 0, math.rad(20)), Color = C.White, CanCollide = false })
		part(model, s(6), { Name = "DoorX2", Size = Vector3.new(0.3, 6.4, 0.2), CFrame = doorCFrame * CFrame.new(0, 0, -0.2) * CFrame.Angles(0, 0, math.rad(-20)), Color = C.White, CanCollide = false })
	end
	-- 7: fenced pen in front (z 1..11) with a trough and hay.
	fenceLine(model, s(7), Vector3.new(-6.6, 0, 1.2), Vector3.new(-6.6, 0, 10.6), 3)
	fenceLine(model, s(7), Vector3.new(6.6, 0, 1.2), Vector3.new(6.6, 0, 10.6), 3)
	fenceLine(model, s(7), Vector3.new(-6.6, 0, 10.6), Vector3.new(6.6, 0, 10.6), 3, 3)
	part(model, s(7), { Name = "Trough", Size = Vector3.new(4, 1, 1.2), CFrame = CFrame.new(-4, 0.5, 2.4), Color = C.WoodDark, Material = Enum.Material.Wood })
	part(model, s(7), { Name = "Hay", Size = Vector3.new(2, 1.4, 1.4), CFrame = CFrame.new(4.5, 0.7, 2.4), Color = Color3.fromRGB(225, 195, 90), Material = Enum.Material.Grass })
end

BUILDERS.ChickenCoop = function(model, def)
	local s = function(group: number): number
		return math.max(1, math.ceil(group * def.Steps / 5))
	end
	local w, d, h, z0, lift = 8, 6, 4, -2.6, 1.4
	for _, x in { -(w / 2 - 0.4), w / 2 - 0.4 } do
		for _, z in { -(d / 2 - 0.4), d / 2 - 0.4 } do
			part(model, s(1), { Name = "Stilt", Size = Vector3.new(0.6, lift, 0.6), CFrame = CFrame.new(x, lift / 2, z0 + z), Color = C.WoodDark, Material = Enum.Material.Wood })
		end
	end
	part(model, s(1), { Name = "Floor", Size = Vector3.new(w, 0.3, d), CFrame = CFrame.new(0, lift, z0), Color = C.Wood, Material = Enum.Material.WoodPlanks })
	part(model, s(2), { Name = "WallBack", Size = Vector3.new(w, h, 0.4), CFrame = CFrame.new(0, lift + h / 2, z0 + d / 2 - 0.2), Color = Color3.fromRGB(240, 210, 150), Material = Enum.Material.WoodPlanks })
	for _, side in { -1, 1 } do
		part(model, s(2), { Name = "WallSide", Size = Vector3.new(0.4, h, d - 0.8), CFrame = CFrame.new(side * (w / 2 - 0.2), lift + h / 2, z0), Color = Color3.fromRGB(240, 210, 150), Material = Enum.Material.WoodPlanks })
		part(model, s(2), { Name = "WallFront", Size = Vector3.new(w / 2 - 0.8, h, 0.4), CFrame = CFrame.new(side * (w / 4 + 0.4), lift + h / 2, z0 - (d / 2 - 0.2)), Color = Color3.fromRGB(240, 210, 150), Material = Enum.Material.WoodPlanks })
	end
	gableRoof(model, s(3), s(3), w, d, lift + h, 2.5, z0, C.RoofRed, Color3.fromRGB(240, 210, 150))
	part(model, s(4), { Name = "Ramp", Size = Vector3.new(1.4, 0.2, 1.6), CFrame = CFrame.new(0, lift / 2, z0 - d / 2 - 0.7) * CFrame.Angles(math.rad(-35), 0, 0), Color = C.Wood, Material = Enum.Material.WoodPlanks })
	part(model, s(4), { Name = "Nest", Size = Vector3.new(1.6, 0.6, 1.2), CFrame = CFrame.new(w / 2 + 0.6, lift + 1, z0), Color = Color3.fromRGB(225, 195, 90), Material = Enum.Material.Grass, CanCollide = false })
	fenceLine(model, s(5), Vector3.new(-4.6, 0, 0.6), Vector3.new(-4.6, 0, 6.6), 2)
	fenceLine(model, s(5), Vector3.new(4.6, 0, 0.6), Vector3.new(4.6, 0, 6.6), 2)
	fenceLine(model, s(5), Vector3.new(-4.6, 0, 6.6), Vector3.new(4.6, 0, 6.6), 2, 2)
end

BUILDERS.StorageChest = function(model, _def)
	part(model, 1, { Name = "Body", Size = Vector3.new(3.4, 2.2, 2.6), CFrame = CFrame.new(0, 1.1, 0), Color = Color3.fromRGB(150, 95, 52), Material = Enum.Material.Wood })
	part(model, 1, { Name = "BandL", Size = Vector3.new(0.3, 2.25, 2.65), CFrame = CFrame.new(-1.2, 1.1, 0), Color = Color3.fromRGB(90, 90, 95), Material = Enum.Material.Metal })
	part(model, 1, { Name = "BandR", Size = Vector3.new(0.3, 2.25, 2.65), CFrame = CFrame.new(1.2, 1.1, 0), Color = Color3.fromRGB(90, 90, 95), Material = Enum.Material.Metal })
	part(model, 2, { Name = "Lid", Size = Vector3.new(3.5, 0.9, 2.7), CFrame = CFrame.new(0, 2.65, 0), Color = Color3.fromRGB(150, 95, 52), Material = Enum.Material.Wood })
	part(model, 2, { Name = "Lock", Size = Vector3.new(0.5, 0.6, 0.2), CFrame = CFrame.new(0, 2.2, -1.35), Color = Color3.fromRGB(255, 200, 60), Material = Enum.Material.Metal, CanCollide = false })
end

BUILDERS.Well = function(model, _def)
	local ringSize, ringRotation = cylinderY(2.6, 5)
	part(model, 1, { Name = "Ring", Shape = Enum.PartType.Cylinder, Size = ringSize, CFrame = CFrame.new(0, 1.3, 0) * ringRotation, Color = C.Stone, Material = Enum.Material.Cobblestone })
	local waterSize, waterRotation = cylinderY(0.2, 4)
	part(model, 1, { Name = "Water", Shape = Enum.PartType.Cylinder, Size = waterSize, CFrame = CFrame.new(0, 2.5, 0) * waterRotation, Color = C.Water, Material = Enum.Material.Glass, CanCollide = false, Transparency = 0.3 })
	for _, x in { -2.2, 2.2 } do
		part(model, 2, { Name = "Post", Size = Vector3.new(0.5, 5, 0.5), CFrame = CFrame.new(x, 2.5 + 2.4, 0), Color = C.WoodDark, Material = Enum.Material.Wood })
	end
	part(model, 2, { Name = "Crossbar", Size = Vector3.new(4.9, 0.4, 0.4), CFrame = CFrame.new(0, 6.6, 0), Color = C.WoodDark, Material = Enum.Material.Wood })
	gableRoof(model, 3, 3, 4.8, 3.2, 7.2, 1.6, 0, C.RoofRed, C.WoodDark)
	part(model, 3, { Name = "Bucket", Size = Vector3.new(0.8, 0.8, 0.8), CFrame = CFrame.new(0, 5, 0), Color = C.WoodDark, Material = Enum.Material.Wood, CanCollide = false })
end

BUILDERS.WoodenFence = function(model, _def)
	fenceLine(model, 1, Vector3.new(-1.8, 0, 0), Vector3.new(1.8, 0, 0), 3.2)
end

BUILDERS.StonePath = function(model, _def)
	local shades = { Color3.fromRGB(175, 172, 165), Color3.fromRGB(155, 152, 146), Color3.fromRGB(185, 180, 170), Color3.fromRGB(165, 160, 150) }
	local index = 0
	for _, x in { -0.95, 0.95 } do
		for _, z in { -0.95, 0.95 } do
			index += 1
			part(model, 1, { Name = "Stone", Size = Vector3.new(1.8, 0.3, 1.8), CFrame = CFrame.new(x, 0.15, z) * CFrame.Angles(0, math.rad(index * 7), 0), Color = shades[index], Material = Enum.Material.Slate })
		end
	end
end

BUILDERS.Bench = function(model, _def)
	part(model, 1, { Name = "Seat", Size = Vector3.new(5.6, 0.4, 1.6), CFrame = CFrame.new(0, 1.5, 0), Color = C.Wood, Material = Enum.Material.WoodPlanks })
	part(model, 1, { Name = "Back", Size = Vector3.new(5.6, 1.4, 0.3), CFrame = CFrame.new(0, 2.5, 0.7), Color = C.Wood, Material = Enum.Material.WoodPlanks })
	for _, x in { -2.4, 2.4 } do
		for _, z in { -0.55, 0.55 } do
			part(model, 1, { Name = "Leg", Size = Vector3.new(0.4, 1.3, 0.4), CFrame = CFrame.new(x, 0.65, z), Color = C.WoodDark, Material = Enum.Material.Wood })
		end
	end
end

BUILDERS.FlowerBed = function(model, _def)
	part(model, 1, { Name = "Soil", Size = Vector3.new(3.4, 0.5, 3.4), CFrame = CFrame.new(0, 0.25, 0), Color = C.Soil, Material = Enum.Material.Ground })
	for _, spec in { { 0, -1.8, 4, 0.4 }, { 0, 1.8, 4, 0.4 }, { -1.8, 0, 0.4, 3.2 }, { 1.8, 0, 0.4, 3.2 } } do
		part(model, 1, { Name = "Border", Size = Vector3.new(spec[3], 0.7, spec[4]), CFrame = CFrame.new(spec[1], 0.35, spec[2]), Color = C.Wood, Material = Enum.Material.Wood })
	end
	local colors = { Color3.fromRGB(255, 105, 130), Color3.fromRGB(255, 212, 80), Color3.fromRGB(185, 125, 255), Color3.fromRGB(255, 255, 255) }
	local index = 0
	for _, x in { -1, 0, 1 } do
		for _, z in { -1, 0, 1 } do
			index += 1
			part(model, 1, { Name = "Stem", Size = Vector3.new(0.15, 1, 0.15), CFrame = CFrame.new(x, 1, z), Color = C.Leaf, CanCollide = false })
			part(model, 1, { Name = "Bloom", Shape = Enum.PartType.Ball, Size = Vector3.new(0.7, 0.7, 0.7), CFrame = CFrame.new(x, 1.55, z), Color = colors[index % #colors + 1], CanCollide = false })
		end
	end
end

BUILDERS.Lantern = function(model, _def)
	part(model, 1, { Name = "Foot", Size = Vector3.new(1.4, 0.4, 1.4), CFrame = CFrame.new(0, 0.2, 0), Color = C.StoneDark, Material = Enum.Material.Slate })
	part(model, 1, { Name = "Pole", Size = Vector3.new(0.4, 6, 0.4), CFrame = CFrame.new(0, 3.2, 0), Color = Color3.fromRGB(60, 60, 65), Material = Enum.Material.Metal })
	local lamp = part(model, 1, { Name = "Lamp", Size = Vector3.new(1, 1.3, 1), CFrame = CFrame.new(0, 6.6, 0), Color = C.Warm, Material = Enum.Material.Neon, CanCollide = false })
	part(model, 1, { Name = "Cap", Size = Vector3.new(1.4, 0.3, 1.4), CFrame = CFrame.new(0, 7.4, 0), Color = Color3.fromRGB(60, 60, 65), Material = Enum.Material.Metal })
	local light = Instance.new("PointLight")
	light.Range = 18
	light.Brightness = 1.4
	light.Color = C.Warm
	light.Parent = lamp
end

BUILDERS.Campfire = function(model, _def)
	for index = 1, 8 do
		local angle = index / 8 * math.pi * 2
		part(model, 1, { Name = "Stone", Size = Vector3.new(0.9, 0.7, 0.9), CFrame = CFrame.new(math.cos(angle) * 1.5, 0.35, math.sin(angle) * 1.5) * CFrame.Angles(0, angle, 0), Color = C.StoneDark, Material = Enum.Material.Slate })
	end
	for index = 1, 3 do
		local angle = index / 3 * math.pi
		part(model, 2, { Name = "Log", Shape = Enum.PartType.Cylinder, Size = Vector3.new(2.4, 0.5, 0.5), CFrame = CFrame.new(0, 0.45, 0) * CFrame.Angles(0, angle, math.rad(10)), Color = C.WoodDark, Material = Enum.Material.Wood })
	end
	local core = part(model, 2, { Name = "FireCore", Size = Vector3.new(0.6, 0.6, 0.6), CFrame = CFrame.new(0, 0.8, 0), Color = Color3.fromRGB(255, 150, 50), Material = Enum.Material.Neon, CanCollide = false, Transparency = 0.4 })
	local fire = Instance.new("Fire")
	fire.Size = 3
	fire.Heat = 5
	fire.Parent = core
	local light = Instance.new("PointLight")
	light.Range = 14
	light.Brightness = 1.6
	light.Color = Color3.fromRGB(255, 160, 80)
	light.Parent = core
end

-- Builds the model at the origin (base centre on the ground, front = -Z).
function BuildingModels.Build(buildingId: string): Model
	local def = BuildingConfig.Get(buildingId)
	assert(def, "Unknown building " .. tostring(buildingId))
	local model = Instance.new("Model")
	model.Name = buildingId
	local base = part(model, 0, {
		Name = "Base",
		Size = Vector3.new(def.Footprint.X, 0.2, def.Footprint.Y),
		CFrame = CFrame.new(0, 0.1, 0),
		Color = Color3.new(1, 1, 1),
		CanCollide = false,
		Transparency = 1,
	})
	local builder = BUILDERS[buildingId]
	if builder then
		builder(model, def)
	end
	model.PrimaryPart = base
	model.WorldPivot = CFrame.new()
	return model
end

-- Shows parts whose Stage <= stage. animate = fade newly revealed parts in.
function BuildingModels.SetStage(model: Model, stage: number, animate: boolean?)
	for _, descendant in model:GetDescendants() do
		if descendant:IsA("BasePart") then
			local partStage = descendant:GetAttribute("Stage")
			if type(partStage) == "number" and partStage > 0 then
				local visible = partStage <= stage
				local baseTransparency = descendant:GetAttribute("BaseTransparency")
				local target = if visible then (if type(baseTransparency) == "number" then baseTransparency else 0) else 1
				local baseCollide = descendant:GetAttribute("BaseCanCollide")
				descendant.CanCollide = visible and baseCollide ~= false
				if animate and visible and descendant.Transparency >= 0.99 and target < 0.99 then
					TweenService:Create(descendant, TweenInfo.new(0.35, Enum.EasingStyle.Quad), { Transparency = target }):Play()
				else
					descendant.Transparency = target
				end
				for _, child in descendant:GetChildren() do
					if child:IsA("Light") or child:IsA("Fire") or child:IsA("ParticleEmitter") then
						child.Enabled = visible
					end
				end
			end
		end
	end
end

-- Turns a model into a see-through, non-colliding placement preview.
function BuildingModels.MakeGhost(model: Model)
	for _, descendant in model:GetDescendants() do
		if descendant:IsA("BasePart") then
			local baseTransparency = descendant:GetAttribute("BaseTransparency")
			descendant.Transparency = if type(baseTransparency) == "number" and baseTransparency >= 0.99 then 1 else 0.45
			descendant.CanCollide = false
			descendant.CanQuery = false
			descendant.CanTouch = false
			descendant.CastShadow = false
			descendant.Anchored = true
		elseif descendant:IsA("Light") or descendant:IsA("Fire") or descendant:IsA("ParticleEmitter") then
			descendant.Enabled = false
		end
	end
end

-- Number of hammer hits to finish this building.
function BuildingModels.GetSteps(buildingId: string): number
	local def = BuildingConfig.Get(buildingId)
	return if def then def.Steps else 1
end

return BuildingModels
