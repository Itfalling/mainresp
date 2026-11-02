--!nocheck
-- Space showcase: the Solar System floating over a dark observation deck at night.
--   lune run tools/build.luau SolarSystem
--   lune run tools/space.luau      -> out/SolarSystem.rbxl

local fs = require("@lune/fs")
local roblox = require("@lune/roblox")
local Instance, CFrame, Vector3, Color3, Enum = roblox.Instance, roblox.CFrame, roblox.Vector3, roblox.Color3, roblox.Enum

local function color(hex)
	hex = hex:gsub("#", "")
	return Color3.fromRGB(tonumber(hex:sub(1, 2), 16), tonumber(hex:sub(3, 4), 16), tonumber(hex:sub(5, 6), 16))
end

local game = Instance.new("DataModel")
local workspace = game:GetService("Workspace")
local lighting = game:GetService("Lighting")

local model = roblox.deserializeModel(fs.readFile("out/models/SolarSystem.rbxm"))[1]
model.Parent = workspace

-- observation deck: dark studded floor with a glowing ring under each orbit-ish radius
local deck = Instance.new("Model")
deck.Name = "ObservationDeck"
deck.Parent = workspace
local function part(size, cf, hex, mat, name)
	local p = Instance.new("Part")
	p.Name = name or "Deck"
	p.Anchored = true
	p.Size = size
	p.CFrame = cf
	p.Color = color(hex)
	p.Material = mat or Enum.Material.Plastic
	p.TopSurface = Enum.SurfaceType.Studs
	p.Parent = deck
	return p
end
part(Vector3.new(340, 2, 340), CFrame.new(0, -1, 0), "#1b1d3a", nil, "Floor")
for i, r in { 40, 80, 120, 160 } do
	for k = 0, 47 do
		local a = k / 48 * math.pi * 2
		part(Vector3.new(r * 0.12, 0.2, 0.6), CFrame.new(math.cos(a) * r, 0.1, math.sin(a) * r) * CFrame.Angles(0, -a + math.pi / 2, 0), i % 2 == 0 and "#3f4dc9" or "#6f5cff", Enum.Material.Neon, "Ring")
	end
end

local spawn = Instance.new("SpawnLocation")
spawn.Anchored = true
spawn.Size = Vector3.new(10, 1, 10)
spawn.CFrame = CFrame.new(0, 0.5, 150) * CFrame.Angles(0, 0, 0)
spawn.Color = color("#7ee0ff")
spawn.TopSurface = Enum.SurfaceType.Studs
spawn.Duration = 0
spawn.Parent = workspace

-- night sky: stars, no haze, strong bloom so the Sun and neon glow
lighting.ClockTime = 0
lighting.Brightness = 1
lighting.Ambient = color("#3a3f66")
lighting.OutdoorAmbient = color("#4a4f7a")
lighting.EnvironmentDiffuseScale = 0.4
lighting.GlobalShadows = true
pcall(function()
	lighting.Technology = Enum.Technology.Future
end)
local sky = Instance.new("Sky")
sky.StarCount = 5000
sky.MoonAngularSize = 0
sky.Parent = lighting
local bloom = Instance.new("BloomEffect")
bloom.Intensity = 0.9
bloom.Size = 30
bloom.Threshold = 1.2
bloom.Parent = lighting
local cc = Instance.new("ColorCorrectionEffect")
cc.Saturation = 0.15
cc.Contrast = 0.08
cc.Parent = lighting

fs.writeFile("out/SolarSystem.rbxl", roblox.serializePlace(game))
print("Wrote out/SolarSystem.rbxl")
