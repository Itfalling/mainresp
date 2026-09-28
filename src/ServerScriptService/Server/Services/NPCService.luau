--[[
	SCRIPT NAME:  NPCService
	SCRIPT TYPE:  ModuleScript (server service)
	WHERE:        ServerScriptService/Server/Services/NPCService
	DEPENDENCIES: BuildService, InteractionService, AnimationService, ShopService, Shared.Net,
	              Shared.Config.GameConfig, Server.Util.Notify

	MIA THE MERCHANT — a real R15 character behind every market stall (she
	follows the stall when you move it).

	AVATAR: a standard R15 body from a HumanoidDescription (skin + outfit
	colours, the built-in default face) dressed with parts welded to her
	body: wavy brown hair with bangs and two braids, a straw sun hat with a
	red ribbon and a flower, a cream apron with a pocket, puffy sleeves, a
	skirt and boots. No uploaded assets are needed. A name tag and a speech
	bubble float above her.

	ANIMATIONS (keyframes in Shared/Animation/Keyframes, played on every
	client like the players' own):
	  MiaIdle     hands clasped, swaying and humming, looking around (loop)
	  MiaWave     big two-step wave on her toes when you walk up
	  MiaPresent  "Take a look!" — arms sweep over her goods (market opened)
	  MiaSold     three claps and a happy hop after you buy or sell
	  MiaTalk     chatty hand gestures while she gives you a tip
	She also turns her head and body towards the nearest player (LookAt
	attribute, animated smoothly on each client) and says things in her
	speech bubble.
]]

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Net = require(ReplicatedStorage.Shared.Net)
local GameConfig = require(ReplicatedStorage.Shared.Config.GameConfig)

local Services = script.Parent
local BuildService = require(Services.BuildService)
local InteractionService = require(Services.InteractionService)
local AnimationService = require(Services.AnimationService)
local ShopService = require(Services.ShopService)
local Notify = require(script.Parent.Parent.Util.Notify)

local MERCHANT_NAME = "Mia the Merchant"
local GREET_RANGE = 16
local LOOK_RANGE = 22
local GREET_COOLDOWN = 45
local REACT_RANGE = 30
local BUBBLE_TIME = 3.5

local SKIN = Color3.fromRGB(241, 194, 160)
local HAIR = Color3.fromRGB(112, 66, 40)
local TOP = Color3.fromRGB(236, 112, 100)
local PANTS = Color3.fromRGB(70, 82, 130)
local APRON = Color3.fromRGB(252, 246, 232)
local STRAW = Color3.fromRGB(236, 204, 128)
local RIBBON = Color3.fromRGB(214, 62, 80)
local BOOTS = Color3.fromRGB(118, 78, 48)

local TIPS = {
	"Welcome! Click my stall any time to buy and sell.",
	"Crops, fish, milk and eggs all sell here. Check the market demand bonus!",
	"Water your crops — they grow 50% faster.",
	"Build a Barn, then come back and I'll sell you a cow.",
	"Better tools gather faster. A Stone Axe chops trees in half the hits!",
	"Expand your island in any direction — new land grows new trees and rocks.",
	"Visit friends' islands from the 👥 menu. Their waters hold different fish!",
	"Hold seeds in your hand and click tilled soil to plant them.",
	"Hold Shift to sprint!",
}

local GREETINGS = { "Hi %s! 👋", "Welcome back, %s!", "Hello %s! Fresh goods today!", "Oh, hi %s! 🌼" }
local THANKS_SELL = { "Thank you! 💰", "Pleasure doing business!", "Ooh, lovely! 🧺", "Come back soon!" }
local THANKS_BUY = { "Enjoy! 😊", "Great choice!", "Thank you, %s! 💖", "Use it well!" }

type Merchant = {
	Model: Model,
	Site: any,
	Bubble: BillboardGui,
	BubbleText: TextLabel,
	BubbleToken: number,
	BusyUntil: number,
	Greeted: { [Player]: number },
}

local NPCService = {}

local merchants: { [string]: Merchant } = {} -- stall site UniqueId -> merchant
local tipIndex: { [Player]: number } = setmetatable({}, { __mode = "k" }) :: any
local random = Random.new()

---------------------------------------------------------------------------
-- Avatar
---------------------------------------------------------------------------

type Piece = {
	Size: Vector3,
	Offset: CFrame,
	Color: Color3,
	Material: Enum.Material?,
	Shape: string?, -- "Ball" | "Cylinder" | "Sphere" (mesh) | nil (block)
}

local function attach(bodyPart: BasePart, name: string, piece: Piece): Part
	local part = Instance.new("Part")
	part.Name = name
	part.Size = piece.Size
	part.Color = piece.Color
	part.Material = piece.Material or Enum.Material.SmoothPlastic
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.CanCollide = false
	part.CanQuery = true
	part.CanTouch = false
	part.Massless = true
	part.Anchored = false
	if piece.Shape == "Ball" then
		part.Shape = Enum.PartType.Ball
	elseif piece.Shape == "Cylinder" then
		part.Shape = Enum.PartType.Cylinder
	elseif piece.Shape == "Sphere" then
		local mesh = Instance.new("SpecialMesh")
		mesh.MeshType = Enum.MeshType.Sphere
		mesh.Parent = part
	end
	part.CFrame = bodyPart.CFrame * piece.Offset
	local weld = Instance.new("Weld")
	weld.Part0 = bodyPart
	weld.Part1 = part
	weld.C0 = piece.Offset
	weld.Parent = part
	part.Parent = bodyPart.Parent
	return part
end

local VERTICAL = CFrame.Angles(0, 0, math.rad(90)) -- cylinders stand upright

local function dress(model: Model)
	local head = model:FindFirstChild("Head") :: BasePart?
	local upperTorso = model:FindFirstChild("UpperTorso") :: BasePart?
	local lowerTorso = model:FindFirstChild("LowerTorso") :: BasePart?
	if not head or not upperTorso or not lowerTorso then
		return
	end
	local h = head.Size.Y
	-- Face: make sure she has one (the built-in default face).
	if not head:FindFirstChildOfClass("Decal") then
		local face = Instance.new("Decal")
		face.Name = "face"
		face.Face = Enum.NormalId.Front
		face.Texture = "rbxasset://textures/face.png"
		face.Parent = head
	end

	-- Hair: cap, bangs, long back, two braids with ribbon ties.
	attach(head, "HairCap", { Size = Vector3.new(h * 1.12, h * 0.8, h * 1.12), Offset = CFrame.new(0, h * 0.2, h * 0.04), Color = HAIR, Shape = "Sphere" })
	attach(head, "Bangs", { Size = Vector3.new(h * 0.95, h * 0.32, h * 0.42), Offset = CFrame.new(0, h * 0.36, -h * 0.34) * CFrame.Angles(math.rad(-15), 0, 0), Color = HAIR, Shape = "Sphere" })
	attach(head, "HairBack", { Size = Vector3.new(h * 1.05, h * 1.05, h * 0.45), Offset = CFrame.new(0, -h * 0.12, h * 0.4), Color = HAIR, Shape = "Sphere" })
	for index, side in { -1, 1 } do
		attach(head, "Braid" .. index, { Size = Vector3.new(h * 0.26, h * 0.95, h * 0.26), Offset = CFrame.new(side * h * 0.5, -h * 0.55, h * 0.18), Color = HAIR, Shape = "Sphere" })
		attach(head, "BraidTie" .. index, { Size = Vector3.new(h * 0.2, h * 0.2, h * 0.2), Offset = CFrame.new(side * h * 0.5, -h * 0.98, h * 0.18), Color = RIBBON, Shape = "Ball" })
	end

	-- Straw sun hat with a ribbon band and a flower.
	attach(head, "HatBrim", { Size = Vector3.new(0.14, h * 2.3, h * 2.3), Offset = CFrame.new(0, h * 0.5, 0.02) * VERTICAL * CFrame.Angles(math.rad(-6), 0, 0), Color = STRAW, Material = Enum.Material.Fabric, Shape = "Cylinder" })
	attach(head, "HatCrown", { Size = Vector3.new(h * 0.55, h * 1.12, h * 1.12), Offset = CFrame.new(0, h * 0.8, 0.02) * VERTICAL, Color = STRAW, Material = Enum.Material.Fabric, Shape = "Cylinder" })
	attach(head, "HatBand", { Size = Vector3.new(h * 0.18, h * 1.16, h * 1.16), Offset = CFrame.new(0, h * 0.62, 0.02) * VERTICAL, Color = RIBBON, Shape = "Cylinder" })
	attach(head, "HatFlower", { Size = Vector3.new(h * 0.3, h * 0.3, h * 0.3), Offset = CFrame.new(h * 0.56, h * 0.66, -h * 0.1), Color = Color3.fromRGB(255, 220, 90), Shape = "Ball" })
	attach(head, "HatFlowerPetals", { Size = Vector3.new(h * 0.48, h * 0.48, h * 0.12), Offset = CFrame.new(h * 0.58, h * 0.66, -h * 0.1) * CFrame.Angles(0, math.rad(90), 0), Color = Color3.fromRGB(255, 255, 255), Shape = "Sphere" })

	-- Apron over the top, waist tie, skirt, apron skirt with a pocket.
	local ut = upperTorso.Size
	local lt = lowerTorso.Size
	attach(upperTorso, "ApronBib", { Size = Vector3.new(ut.X * 0.62, ut.Y * 0.7, 0.08), Offset = CFrame.new(0, -ut.Y * 0.1, -ut.Z / 2 - 0.05), Color = APRON, Material = Enum.Material.Fabric })
	attach(lowerTorso, "Skirt", { Size = Vector3.new(lt.X * 1.28, lt.Y * 1.5, lt.Z * 1.35), Offset = CFrame.new(0, -lt.Y * 0.55, 0), Color = TOP, Material = Enum.Material.Fabric })
	attach(lowerTorso, "WaistTie", { Size = Vector3.new(lt.X * 1.32, 0.18, lt.Z * 1.4), Offset = CFrame.new(0, lt.Y * 0.2, 0), Color = APRON, Material = Enum.Material.Fabric })
	attach(lowerTorso, "ApronSkirt", { Size = Vector3.new(lt.X * 1.05, lt.Y * 1.45, 0.08), Offset = CFrame.new(0, -lt.Y * 0.5, -lt.Z * 0.68 - 0.05), Color = APRON, Material = Enum.Material.Fabric })
	attach(lowerTorso, "ApronPocket", { Size = Vector3.new(lt.X * 0.45, lt.Y * 0.45, 0.06), Offset = CFrame.new(0, -lt.Y * 0.55, -lt.Z * 0.68 - 0.11), Color = Color3.fromRGB(236, 222, 196), Material = Enum.Material.Fabric })

	-- Puffy sleeves and boots.
	for _, side in { "Left", "Right" } do
		local upperArm = model:FindFirstChild(side .. "UpperArm") :: BasePart?
		if upperArm then
			local a = upperArm.Size
			attach(upperArm, "Sleeve", { Size = Vector3.new(a.X * 1.35, a.Y * 0.55, a.Z * 1.35), Offset = CFrame.new(0, a.Y * 0.2, 0), Color = TOP, Material = Enum.Material.Fabric, Shape = "Sphere" })
		end
		local foot = model:FindFirstChild(side .. "Foot") :: BasePart?
		if foot then
			local f = foot.Size
			attach(foot, "Boot", { Size = Vector3.new(f.X * 1.15, f.Y * 1.35, f.Z * 1.12), Offset = CFrame.new(0, f.Y * 0.15, -f.Z * 0.03), Color = BOOTS, Material = Enum.Material.Leather })
		end
	end
end

local function makeGui(model: Model): (BillboardGui, TextLabel)
	local head = model:FindFirstChild("Head") :: BasePart
	-- Name tag.
	local tag = Instance.new("BillboardGui")
	tag.Name = "NameTag"
	tag.Size = UDim2.fromOffset(200, 34)
	tag.StudsOffset = Vector3.new(0, 3.1, 0)
	tag.MaxDistance = 70
	tag.Adornee = head
	local tagFrame = Instance.new("Frame")
	tagFrame.Size = UDim2.fromScale(1, 1)
	tagFrame.BackgroundColor3 = Color3.fromRGB(255, 196, 40)
	tagFrame.Parent = tag
	Instance.new("UICorner").Parent = tagFrame
	local tagStroke = Instance.new("UIStroke")
	tagStroke.Thickness = 2.5
	tagStroke.Color = Color3.fromRGB(62, 44, 30)
	tagStroke.Parent = tagFrame
	local tagText = Instance.new("TextLabel")
	tagText.Size = UDim2.fromScale(1, 1)
	tagText.BackgroundTransparency = 1
	tagText.Font = Enum.Font.FredokaOne
	tagText.TextScaled = true
	tagText.TextColor3 = Color3.new(1, 1, 1)
	tagText.Text = "🛒 " .. MERCHANT_NAME
	tagText.Parent = tagFrame
	local textStroke = Instance.new("UIStroke")
	textStroke.Thickness = 1.5
	textStroke.Color = Color3.fromRGB(62, 44, 30)
	textStroke.Parent = tagText
	tag.Parent = head

	-- Speech bubble (hidden until she talks).
	local bubble = Instance.new("BillboardGui")
	bubble.Name = "Speech"
	bubble.Size = UDim2.fromOffset(240, 60)
	bubble.StudsOffset = Vector3.new(0, 5, 0)
	bubble.MaxDistance = 50
	bubble.Adornee = head
	bubble.Enabled = false
	local frame = Instance.new("Frame")
	frame.Size = UDim2.fromScale(1, 1)
	frame.BackgroundColor3 = Color3.new(1, 1, 1)
	frame.Parent = bubble
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 16)
	corner.Parent = frame
	local stroke = Instance.new("UIStroke")
	stroke.Thickness = 3
	stroke.Color = Color3.fromRGB(62, 44, 30)
	stroke.Parent = frame
	local text = Instance.new("TextLabel")
	text.Size = UDim2.new(1, -16, 1, -8)
	text.Position = UDim2.fromOffset(8, 4)
	text.BackgroundTransparency = 1
	text.Font = Enum.Font.FredokaOne
	text.TextScaled = true
	text.TextColor3 = Color3.fromRGB(58, 40, 26)
	text.Text = ""
	text.Parent = frame
	bubble.Parent = head
	return bubble, text
end

local function buildMerchant(): Model?
	local description = Instance.new("HumanoidDescription")
	description.HeadColor = SKIN
	description.LeftArmColor = SKIN
	description.RightArmColor = SKIN
	description.TorsoColor = TOP
	description.LeftLegColor = PANTS
	description.RightLegColor = PANTS
	local ok, model = pcall(Players.CreateHumanoidModelFromDescription, Players, description, Enum.HumanoidRigType.R15)
	if not ok or not model then
		if GameConfig.Debug then
			warn("[NPCService] Could not create merchant rig: " .. tostring(model))
		end
		return nil
	end
	model.Name = MERCHANT_NAME
	local humanoid = model:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid.DisplayName = MERCHANT_NAME
		humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None -- our own name tag instead
	end
	local animate = model:FindFirstChild("Animate")
	if animate then
		animate:Destroy() -- every client animates her from keyframes
	end
	for _, descendant in model:GetDescendants() do
		if descendant:IsA("BasePart") then
			descendant.Anchored = descendant.Name == "HumanoidRootPart"
		end
	end
	local ok2, err = pcall(dress, model)
	if not ok2 then
		warn("[NPCService] Could not dress the merchant: " .. tostring(err))
	end
	return model
end

---------------------------------------------------------------------------
-- Behaviour
---------------------------------------------------------------------------

local function say(merchant: Merchant, text: string)
	merchant.BubbleToken += 1
	local token = merchant.BubbleToken
	merchant.BubbleText.Text = text
	merchant.Bubble.Enabled = true
	task.delay(BUBBLE_TIME, function()
		if merchant.BubbleToken == token and merchant.Bubble.Parent then
			merchant.Bubble.Enabled = false
		end
	end)
end

local function act(merchant: Merchant, animation: string, busy: number)
	merchant.BusyUntil = os.clock() + busy
	AnimationService.PlayAnimation(merchant.Model, animation)
end

local function pick(list: { string }, name: string?): string
	local line = list[random:NextInteger(1, #list)]
	return if string.find(line, "%%s") then line:format(name or "friend") else line
end

local function placeMerchant(site: any)
	local merchant = merchants[site.UniqueId]
	if merchant and merchant.Model.Parent then
		-- Behind the counter, facing the same way as the stall's front.
		merchant.Model:PivotTo(site.Model:GetPivot() * CFrame.new(0, 3.1, 0.3))
	end
end

local function merchantNear(position: Vector3, range: number): Merchant?
	local best, bestDistance = nil, range
	for _, merchant in merchants do
		if merchant.Model.Parent then
			local distance = (merchant.Model:GetPivot().Position - position).Magnitude
			if distance <= bestDistance then
				best, bestDistance = merchant, distance
			end
		end
	end
	return best
end

local function playerPosition(player: Player): Vector3?
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	return if root and root:IsA("BasePart") then root.Position else nil
end

local function spawnMerchant(site: any)
	if merchants[site.UniqueId] then
		return
	end
	local model = buildMerchant()
	if not model then
		return
	end
	local bubble, bubbleText = makeGui(model)
	local merchant: Merchant = {
		Model = model,
		Site = site,
		Bubble = bubble,
		BubbleText = bubbleText,
		BubbleToken = 0,
		BusyUntil = 0,
		Greeted = setmetatable({}, { __mode = "k" }) :: any,
	}
	merchants[site.UniqueId] = merchant
	model:SetAttribute("NPC", "Merchant")
	model:SetAttribute("IdleAnim", "MiaIdle")
	CollectionService:AddTag(model, "NPCRig")
	model.Parent = site.Island.Folders.Landmarks
	placeMerchant(site)
	InteractionService.Attach(model, "MerchantTalk", { Label = MERCHANT_NAME, OwnerUserId = site.OwnerUserId })
	site.Model.Destroying:Once(function()
		merchants[site.UniqueId] = nil
		model:Destroy()
	end)
end

-- Every half second: look at the nearest player, greet newcomers.
local function tick()
	local now = os.clock()
	for _, merchant in merchants do
		local model = merchant.Model
		if not model.Parent then
			continue
		end
		local origin = model:GetPivot().Position
		local nearest, nearestDistance = nil, LOOK_RANGE
		for _, player in Players:GetPlayers() do
			local position = playerPosition(player)
			if position then
				local distance = (position - origin).Magnitude
				if distance < nearestDistance then
					nearest, nearestDistance = player, distance
				end
			end
		end
		model:SetAttribute("LookAt", if nearest then nearest.UserId else 0)
		if nearest and nearestDistance <= GREET_RANGE and now >= merchant.BusyUntil then
			local last = merchant.Greeted[nearest]
			if not last or now - last > GREET_COOLDOWN then
				merchant.Greeted[nearest] = now
				act(merchant, "MiaWave", 1.6)
				say(merchant, pick(GREETINGS, nearest.DisplayName))
			end
		end
	end
end

function NPCService.Init()
	InteractionService.RegisterKind("MerchantTalk", {
		Permission = "Market",
		MaxDistance = 12,
		Cooldown = 1,
		Handler = function(player: Player, model: Instance)
			local index = (tipIndex[player] or 0) % #TIPS + 1
			tipIndex[player] = index
			Notify.Toast(player, MERCHANT_NAME .. ": " .. TIPS[index], "💬")
			Net.FireClient("OpenUI", player, { Screen = "Market", Tab = "Buy" })
			for _, merchant in merchants do
				if merchant.Model == model then
					act(merchant, "MiaTalk", 2)
					say(merchant, TIPS[index])
				end
			end
		end,
	})
end

function NPCService.Start()
	BuildService.SiteReady:Connect(function(site: any)
		if site.BuildingId == "MarketStall" then
			-- CreateHumanoidModelFromDescription can yield; don't hold up island loading.
			task.spawn(spawnMerchant, site)
		end
	end)
	BuildService.BuildingMoved:Connect(function(_player: Player, site: any)
		if site.BuildingId == "MarketStall" then
			placeMerchant(site)
		end
	end)

	-- Opening the market: "Take a look!"
	ShopService.MarketOpened:Connect(function(_player: Player, stall: Instance)
		local uniqueId = stall:GetAttribute("UniqueId")
		local merchant = if type(uniqueId) == "string" then merchants[uniqueId] else nil
		if merchant and os.clock() >= merchant.BusyUntil then
			act(merchant, "MiaPresent", 1.4)
			say(merchant, "Take a look! 🧺")
		end
	end)
	-- A sale or purchase: claps and a hop (once per burst of sales).
	local function celebrate(player: Player, line: string)
		local position = playerPosition(player)
		local merchant = position and merchantNear(position, REACT_RANGE)
		if merchant and os.clock() >= merchant.BusyUntil - 1 then
			act(merchant, "MiaSold", 1.5)
			say(merchant, line)
		end
	end
	ShopService.ItemsSold:Connect(function(player: Player)
		celebrate(player, pick(THANKS_SELL, player.DisplayName))
	end)
	ShopService.Purchased:Connect(function(player: Player)
		celebrate(player, pick(THANKS_BUY, player.DisplayName))
	end)

	task.spawn(function()
		while true do
			task.wait(0.5)
			local ok, err = pcall(tick)
			if not ok then
				warn("[NPCService] " .. tostring(err))
			end
		end
	end)
end

return NPCService
