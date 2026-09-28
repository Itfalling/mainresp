--[[
	SCRIPT NAME:  ToolModelFactory
	SCRIPT TYPE:  ModuleScript (server)
	WHERE:        ServerScriptService/Server/Tools/ToolModelFactory
	DEPENDENCIES: none (reads ToolConfig definitions passed in)
	REQUIRED OBJECTS: optional art in ServerStorage/Tools/<ToolId>

	Builds the physical tool model that ToolService welds into the R15 hand.

	CUSTOM ART: put a Model named exactly like the tool id (e.g. "WoodenAxe")
	in ServerStorage/Tools. It must contain:
	  * a BasePart named "Handle"
	  * an Attachment named "Grip" inside Handle, positioned where the palm
	    holds it. The Grip's +Y axis points along the tool (towards the head),
	    its -Z axis points where the blade/tip faces.
	If no art exists, a clean low-poly placeholder is generated from the
	tool's Shape + tier colours so the game is fully playable today.
]]

local ServerStorage = game:GetService("ServerStorage")

local HANDLE_COLOR = Color3.fromRGB(125, 85, 50)

type PartSpec = {
	Name: string,
	Size: Vector3,
	Offset: CFrame,
	Head: boolean?, -- uses the tier colour/material
	Color: Color3?,
	Material: Enum.Material?,
	Shape: Enum.PartType?,
}

type ShapeSpec = { HandleLength: number, HandleThickness: number, Parts: { PartSpec } }

-- Handle is centred at the origin with its long axis along +Y.
local SHAPES: { [string]: ShapeSpec } = {
	Axe = {
		HandleLength = 3.2,
		HandleThickness = 0.25,
		Parts = {
			{ Name = "Blade", Size = Vector3.new(0.2, 0.85, 1.1), Offset = CFrame.new(0, 1.2, -0.55), Head = true },
			{ Name = "Poll", Size = Vector3.new(0.3, 0.45, 0.35), Offset = CFrame.new(0, 1.2, 0.2), Head = true },
		},
	},
	Pickaxe = {
		HandleLength = 3.2,
		HandleThickness = 0.25,
		Parts = {
			{ Name = "Head", Size = Vector3.new(0.3, 0.3, 2.4), Offset = CFrame.new(0, 1.45, 0), Head = true },
			{ Name = "TipA", Size = Vector3.new(0.2, 0.2, 0.4), Offset = CFrame.new(0, 1.35, -1.3), Head = true },
			{ Name = "TipB", Size = Vector3.new(0.2, 0.2, 0.4), Offset = CFrame.new(0, 1.35, 1.3), Head = true },
		},
	},
	Hammer = {
		HandleLength = 2.4,
		HandleThickness = 0.25,
		Parts = {
			{ Name = "Head", Size = Vector3.new(0.6, 0.6, 1.3), Offset = CFrame.new(0, 1.1, 0), Head = true },
		},
	},
	Shovel = {
		HandleLength = 3.8,
		HandleThickness = 0.22,
		Parts = {
			{ Name = "Blade", Size = Vector3.new(0.12, 1.1, 0.9), Offset = CFrame.new(0, 2.3, 0), Head = true },
			{ Name = "Grip", Size = Vector3.new(0.25, 0.25, 0.7), Offset = CFrame.new(0, -1.9, 0) },
		},
	},
	Hoe = {
		HandleLength = 3.8,
		HandleThickness = 0.22,
		Parts = {
			{ Name = "Blade", Size = Vector3.new(0.15, 0.35, 0.9), Offset = CFrame.new(0, 1.85, -0.4), Head = true },
		},
	},
	WateringCan = {
		HandleLength = 0.9,
		HandleThickness = 0.2,
		Parts = {
			{ Name = "Body", Size = Vector3.new(0.9, 1, 1.2), Offset = CFrame.new(0, 0.6, -0.2), Head = true },
			{ Name = "Spout", Size = Vector3.new(0.15, 0.15, 1.1), Offset = CFrame.new(0, 0.9, -1.2) * CFrame.Angles(math.rad(25), 0, 0), Head = true },
		},
	},
	FishingRod = {
		HandleLength = 5.5,
		HandleThickness = 0.14,
		Parts = {
			{ Name = "Reel", Size = Vector3.new(0.35, 0.35, 0.35), Offset = CFrame.new(0, -1.9, 0.2), Head = true, Shape = Enum.PartType.Ball },
			{ Name = "Tip", Size = Vector3.new(0.1, 0.3, 0.1), Offset = CFrame.new(0, 2.85, 0), Color = Color3.fromRGB(230, 60, 60), Material = Enum.Material.SmoothPlastic },
		},
	},
	Bucket = {
		HandleLength = 0.8,
		HandleThickness = 0.12,
		Parts = {
			{ Name = "Pail", Size = Vector3.new(1.1, 1, 1.1), Offset = CFrame.new(0, -0.7, 0), Head = true },
		},
	},
	Shears = {
		HandleLength = 1,
		HandleThickness = 0.2,
		Parts = {
			{ Name = "BladeA", Size = Vector3.new(0.08, 1, 0.18), Offset = CFrame.new(0.06, 0.9, 0) * CFrame.Angles(0, 0, math.rad(6)), Head = true },
			{ Name = "BladeB", Size = Vector3.new(0.08, 1, 0.18), Offset = CFrame.new(-0.06, 0.9, 0) * CFrame.Angles(0, 0, math.rad(-6)), Head = true },
		},
	},
}

local ToolModelFactory = {}

local function preparePart(part: BasePart)
	part.Anchored = false
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.Massless = true
	part.CastShadow = true
end

local function fromCustomArt(toolId: string): Model?
	local folder = ServerStorage:FindFirstChild("Tools")
	local template = folder and folder:FindFirstChild(toolId)
	if not template or not template:IsA("Model") then
		return nil
	end
	local model = template:Clone()
	local handle = model:FindFirstChild("Handle")
	if not handle or not handle:IsA("BasePart") or not handle:FindFirstChild("Grip") then
		warn(("[Tools] ServerStorage.Tools.%s needs a Handle part with a Grip attachment; using placeholder"):format(toolId))
		model:Destroy()
		return nil
	end
	for _, descendant in model:GetDescendants() do
		if descendant:IsA("BasePart") then
			preparePart(descendant)
		end
	end
	model.PrimaryPart = handle
	return model
end

local function fromShape(toolDef: any): Model
	local shape = SHAPES[toolDef.Shape] or SHAPES.Hammer
	local model = Instance.new("Model")

	local handle = Instance.new("Part")
	handle.Name = "Handle"
	handle.Size = Vector3.new(shape.HandleThickness, shape.HandleLength, shape.HandleThickness)
	handle.Color = HANDLE_COLOR
	handle.Material = Enum.Material.Wood
	handle.TopSurface = Enum.SurfaceType.Smooth
	handle.BottomSurface = Enum.SurfaceType.Smooth
	preparePart(handle)
	handle.CFrame = CFrame.new()
	handle.Parent = model

	local grip = Instance.new("Attachment")
	grip.Name = "Grip"
	grip.Position = Vector3.new(0, -shape.HandleLength / 2 + 0.45, 0)
	grip.Parent = handle

	for _, spec in shape.Parts do
		local part = Instance.new("Part")
		part.Name = spec.Name
		part.Shape = spec.Shape or Enum.PartType.Block
		part.Size = spec.Size
		part.Color = if spec.Head then toolDef.HeadColor else (spec.Color or HANDLE_COLOR)
		part.Material = if spec.Head then toolDef.HeadMaterial else (spec.Material or Enum.Material.Wood)
		part.TopSurface = Enum.SurfaceType.Smooth
		part.BottomSurface = Enum.SurfaceType.Smooth
		preparePart(part)
		part.CFrame = handle.CFrame * spec.Offset
		-- Explicit C0 (not WeldConstraint) so the offset is exact no matter
		-- where the parts are when the model enters the workspace.
		local weld = Instance.new("Weld")
		weld.Part0 = handle
		weld.Part1 = part
		weld.C0 = spec.Offset
		weld.Parent = part
		part.Parent = model
	end

	model.PrimaryPart = handle
	return model
end

-- A small held item (seed sack, a carrot, a wheat bundle...) in the same
-- Handle + Grip format as tools, so ToolService attaches it identically.
function ToolModelFactory.BuildItem(itemId: string, category: string, color: Color3): Model
	local model = Instance.new("Model")
	model.Name = "EquippedTool"
	model:SetAttribute("ItemId", itemId)

	local handle = Instance.new("Part")
	handle.Name = "Handle"
	handle.Size = Vector3.new(0.3, 0.3, 0.3)
	handle.Transparency = 1
	preparePart(handle)
	handle.CFrame = CFrame.new()
	handle.Parent = model
	local grip = Instance.new("Attachment")
	grip.Name = "Grip"
	grip.Position = Vector3.new(0, -0.1, 0)
	grip.Parent = handle

	local function piece(name: string, size: Vector3, offset: CFrame, partColor: Color3, material: Enum.Material, sphere: boolean)
		local part = Instance.new("Part")
		part.Name = name
		part.Size = size
		part.Color = partColor
		part.Material = material
		preparePart(part)
		if sphere then
			local mesh = Instance.new("SpecialMesh")
			mesh.MeshType = Enum.MeshType.Sphere
			mesh.Parent = part
		end
		part.CFrame = handle.CFrame * offset
		local weld = Instance.new("Weld")
		weld.Part0 = handle
		weld.Part1 = part
		weld.C0 = offset
		weld.Parent = part
		part.Parent = model
	end

	if category == "Seeds" then
		-- Burlap sack with a coloured seed label.
		piece("Sack", Vector3.new(0.9, 1.1, 0.9), CFrame.new(0, 0.55, 0), Color3.fromRGB(196, 160, 110), Enum.Material.Fabric, true)
		piece("Tie", Vector3.new(0.35, 0.35, 0.35), CFrame.new(0, 1.15, 0), Color3.fromRGB(150, 110, 70), Enum.Material.Fabric, true)
		piece("Label", Vector3.new(0.45, 0.45, 0.1), CFrame.new(0, 0.55, -0.44), color, Enum.Material.SmoothPlastic, true)
	else
		-- Produce: a chunky piece of the crop in its colour.
		piece("Produce", Vector3.new(0.8, 1.1, 0.8), CFrame.new(0, 0.55, 0), color, Enum.Material.SmoothPlastic, true)
		piece("Leaf", Vector3.new(0.5, 0.3, 0.2), CFrame.new(0, 1.15, 0), Color3.fromRGB(80, 170, 60), Enum.Material.Grass, true)
	end
	model.PrimaryPart = handle
	return model
end

-- Returns a Model with PrimaryPart "Handle" containing a "Grip" Attachment.
function ToolModelFactory.Build(toolDef: any): Model
	local model = fromCustomArt(toolDef.Id) or fromShape(toolDef)
	model.Name = "EquippedTool"
	model:SetAttribute("ToolId", toolDef.Id)
	return model
end

return ToolModelFactory
