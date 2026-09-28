--[[
	SCRIPT NAME:  FishingController
	SCRIPT TYPE:  ModuleScript (client controller)
	WHERE:        StarterPlayerScripts/Client/Controllers/FishingController
	DEPENDENCIES: Shared.Net, Shared.Config.{FishConfig, RarityConfig, IslandConfig}, Shared.Util.R15,
	              InputController, UIController, ToolController, InteractionController,
	              AudioController, VFXController, CameraController, Client.UI.{Components, Theme}

	Client side of fishing (spec §29-§32). Hold your rod and CLICK THE WATER
	(or R2 / the touch USE button) — that drives the whole thing:

	  Idle     click water → FishingRequest{Op="Cast", Target}
	  Waiting  bobber floats on the water, line drawn with a Beam
	  Bite     "!" + splash + sound → USE within the hook window
	  Reeling  MINIGAME: HOLD USE to lift the green zone, keep the fish inside
	           it until the bar fills. Let it escape and the bar drains.
	  Result   catch card (rarity colour, weight, NEW!) or the escape reason

	The client never knows WHICH fish bit — only its rarity and difficulty.
	It reports Success/Fail with the server's one-time token; the server
	rejects catches faster than FishConfig.MinReelTime and grants the fish.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Net = require(Shared:WaitForChild("Net"))
local FishConfig = require(Shared.Config.FishConfig)
local RarityConfig = require(Shared.Config.RarityConfig)
local IslandConfig = require(Shared.Config.IslandConfig)
local R15 = require(Shared.Util.R15)

local Client = script.Parent.Parent
local InputController = require(script.Parent.InputController)
local UIController = require(script.Parent.UIController)
local ToolController = require(script.Parent.ToolController)
local InteractionController = require(script.Parent.InteractionController)
local AudioController = require(script.Parent.AudioController)
local VFXController = require(script.Parent.VFXController)
local CameraController = require(script.Parent.CameraController)
local AnimationController = require(script.Parent.AnimationController)
local Components = require(Client.UI.Components)
local Theme = require(Client.UI.Theme)

local Create = Components.Create
local player = Players.LocalPlayer

local CAST_DISTANCE = 9
local CAST_TIMEOUT = 2.5 -- no Cast reply in this long → the server said no
local CAST_FLIGHT = 0.45
local START_GRACE = 0.9 -- seconds at the start of a reel where progress can't drain

local FishingController = {}

type Minigame = {
	Token: any,
	Difficulty: number,
	Rarity: string,
	ZoneSize: number,
	ZonePos: number,
	ZoneVel: number,
	FishPos: number,
	FishTarget: number,
	FishTimer: number,
	Progress: number,
	Elapsed: number,
	Finished: boolean,
}

local state: string = "Idle" -- Idle | Casting | Waiting | Bite | Hooking | Reeling
local castRequestedAt = 0
local random = Random.new()

local bobber: Model? = nil
local bobberBase: Vector3 = Vector3.zero
local castFrom: Vector3 = Vector3.zero
local castStartedAt = 0
local lineBeam: Beam? = nil
local rodAttachment: Attachment? = nil
local biteMark: BillboardGui? = nil
local renderConnection: RBXScriptConnection? = nil
local minigame: Minigame? = nil

type Refs = {
	Status: TextLabel,
	Reel: Frame,
	ReelTitle: TextLabel,
	Track: Frame,
	Zone: Frame,
	Fish: TextLabel,
	ProgressFill: Frame,
	ReelHint: TextLabel,
	Card: Frame,
	CardIcon: TextLabel,
	CardTitle: TextLabel,
	CardRarity: TextLabel,
	CardInfo: TextLabel,
	CardNew: TextLabel,
}
local refs: Refs
local cardToken = 0

---------------------------------------------------------------------------
-- World visuals (all local, under the camera)
---------------------------------------------------------------------------

local function useHint(): string
	local device = InputController.GetDevice()
	if device == "Touch" then
		return "USE"
	elseif device == "Gamepad" then
		return "R2"
	end
	return "CLICK"
end

local function waterHeightAt(position: Vector3): number
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Include
	params.FilterDescendantsInstances = { workspace.Terrain }
	params.IgnoreWater = false
	local hit = workspace:Raycast(position + Vector3.new(0, 20, 0), Vector3.new(0, -60, 0), params)
	return if hit then hit.Position.Y else IslandConfig.SeaLevel
end

local function rodTip(): Attachment?
	local character = player.Character
	if not character then
		return nil
	end
	if rodAttachment and rodAttachment.Parent and rodAttachment:IsDescendantOf(character) then
		return rodAttachment
	end
	local tip = character:FindFirstChild("Tip", true)
	local anchor: BasePart? = if tip and tip:IsA("BasePart") then tip else R15.GetPart(character, "RightHand")
	if not anchor then
		return nil
	end
	local attachment = Instance.new("Attachment")
	attachment.Name = "FishingLine"
	attachment.Position = if anchor.Name == "Tip" then Vector3.new(0, anchor.Size.Y / 2, 0) else Vector3.zero
	attachment.Parent = anchor
	rodAttachment = attachment
	return attachment
end

local function makeBobber(): Model
	local model = Instance.new("Model")
	model.Name = "Bobber"
	local ball = Instance.new("Part")
	ball.Name = "Float"
	ball.Shape = Enum.PartType.Ball
	ball.Size = Vector3.new(0.7, 0.7, 0.7)
	ball.Color = Color3.fromRGB(235, 60, 55)
	ball.Material = Enum.Material.SmoothPlastic
	ball.Anchored = true
	ball.CanCollide = false
	ball.CanQuery = false
	ball.CanTouch = false
	ball.Parent = model
	local cap = Instance.new("Part")
	cap.Name = "Cap"
	cap.Shape = Enum.PartType.Cylinder
	cap.Size = Vector3.new(0.12, 0.72, 0.72)
	cap.Color = Color3.fromRGB(250, 250, 250)
	cap.Material = Enum.Material.SmoothPlastic
	cap.Anchored = true
	cap.CanCollide = false
	cap.CanQuery = false
	cap.CanTouch = false
	cap.CFrame = CFrame.new(0, 0.12, 0) * CFrame.Angles(0, 0, math.rad(90))
	cap.Parent = model
	model.PrimaryPart = ball
	local attachment = Instance.new("Attachment")
	attachment.Name = "LineEnd"
	attachment.Parent = ball
	model.Parent = workspace.CurrentCamera
	return model
end

local function clearWorld()
	if renderConnection then
		renderConnection:Disconnect()
		renderConnection = nil
	end
	if lineBeam then
		lineBeam:Destroy()
		lineBeam = nil
	end
	if bobber then
		bobber:Destroy()
		bobber = nil
	end
	biteMark = nil
end

local function showBiteMark(show: boolean)
	if not bobber then
		return
	end
	if show and not biteMark then
		local gui = Create("BillboardGui", {
			Name = "BiteMark",
			Size = UDim2.fromOffset(60, 60),
			StudsOffset = Vector3.new(0, 2.2, 0),
			AlwaysOnTop = true,
			LightInfluence = 0,
			Parent = bobber.PrimaryPart,
		})
		local label = Components.Label({ Text = "!", Size = UDim2.fromScale(1, 1), TextSize = 54, TextColor3 = Theme.Colors.Red, Parent = gui })
		Components.TextStroke(label, Theme.Colors.TextLight, 3)
		Components.Bounce(label, 0.5)
		biteMark = gui
	elseif not show and biteMark then
		biteMark:Destroy()
		biteMark = nil
	end
end

local function renderWorld()
	if not bobber then
		return
	end
	local now = os.clock()
	local flight = math.clamp((now - castStartedAt) / CAST_FLIGHT, 0, 1)
	local position: Vector3
	if flight < 1 then
		-- Arc from the rod tip to the water.
		local flat = castFrom:Lerp(bobberBase, flight)
		position = flat + Vector3.new(0, math.sin(flight * math.pi) * 5, 0)
	elseif state == "Bite" then
		position = bobberBase + Vector3.new(math.sin(now * 40) * 0.08, -0.45 + math.sin(now * 25) * 0.12, 0)
	elseif state == "Hooking" or state == "Reeling" then
		position = bobberBase + Vector3.new(math.sin(now * 13) * 0.25, -0.3 + math.sin(now * 17) * 0.1, math.cos(now * 11) * 0.25)
	else
		position = bobberBase + Vector3.new(0, math.sin(now * 2.2) * 0.1, 0)
	end
	bobber:PivotTo(CFrame.new(position))

	local tip = rodTip()
	if tip and not lineBeam then
		local beam = Instance.new("Beam")
		beam.Name = "FishingLine"
		beam.Attachment0 = tip
		beam.Attachment1 = (bobber.PrimaryPart :: BasePart):FindFirstChild("LineEnd") :: Attachment
		beam.Width0 = 0.05
		beam.Width1 = 0.05
		beam.FaceCamera = true
		beam.Segments = 12
		beam.CurveSize0 = 0
		beam.CurveSize1 = -1.5
		beam.Color = ColorSequence.new(Color3.fromRGB(245, 245, 245))
		beam.LightInfluence = 0
		beam.Transparency = NumberSequence.new(0.15)
		beam.Parent = bobber
		lineBeam = beam
	elseif lineBeam and tip then
		lineBeam.Attachment0 = tip
	end
end

local function startBobber(spot: Vector3?)
	clearWorld()
	local root = R15.GetRootPart(player.Character)
	if not root then
		return
	end
	local look = root.CFrame.LookVector * Vector3.new(1, 0, 1)
	if look.Magnitude < 0.1 then
		look = Vector3.new(0, 0, -1)
	end
	local target = spot or (root.Position + look.Unit * CAST_DISTANCE)
	bobberBase = Vector3.new(target.X, waterHeightAt(target) + 0.15, target.Z)
	local tip = rodTip()
	castFrom = if tip then tip.WorldPosition else root.Position + Vector3.new(0, 2, 0)
	castStartedAt = os.clock()
	bobber = makeBobber()
	renderConnection = RunService.RenderStepped:Connect(renderWorld)
	task.delay(CAST_FLIGHT, function()
		if bobber and state ~= "Idle" then
			VFXController.Play("WaterSplash", bobberBase)
		end
	end)
end

---------------------------------------------------------------------------
-- UI
---------------------------------------------------------------------------

local function setStatus(text: string?, color: Color3?)
	refs.Status.Visible = text ~= nil
	if text then
		refs.Status.Text = text
		refs.Status.BackgroundColor3 = color or Theme.Colors.Outline
		Components.Bounce(refs.Status, 0.08)
	end
end

local function resetAll()
	state = "Idle"
	minigame = nil
	refs.Reel.Visible = false
	setStatus(nil)
	clearWorld()
end

local function cancelFishing()
	if state == "Idle" then
		return
	end
	Net.FireServer("FishingRequest", { Op = "Cancel" })
	resetAll()
end

local function showCatch(fishId: string, weight: number, isNew: boolean)
	local fish = FishConfig.Fish[fishId]
	if not fish then
		return
	end
	local rarity = RarityConfig.Get(fish.Rarity)
	cardToken += 1
	local token = cardToken
	refs.CardIcon.Text = "🐟"
	refs.CardIcon.TextColor3 = fish.Color
	refs.CardTitle.Text = fish.DisplayName
	refs.CardRarity.Text = string.upper(rarity.DisplayName)
	refs.CardRarity.TextColor3 = rarity.Color
	refs.CardInfo.Text = ("%.1f kg · sells for %d 🪙"):format(weight, fish.SellValue)
	refs.CardNew.Visible = isNew
	local stroke = refs.Card:FindFirstChildOfClass("UIStroke")
	if stroke then
		stroke.Color = rarity.Color
	end
	refs.Card.Visible = true
	Components.Bounce(refs.Card, 0.2)
	if rarity.Rank >= 4 then
		UIController.Banner(string.upper(rarity.DisplayName) .. " CATCH!", fish.DisplayName, "Reward")
	end
	task.delay(3.5, function()
		if cardToken == token then
			refs.Card.Visible = false
		end
	end)
end

local function buildUI()
	local layer = UIController.GetModalLayer()

	local status = Components.Label({
		Name = "FishingStatus",
		Size = UDim2.fromOffset(360, 40),
		Position = UDim2.new(0.5, 0, 1, -128),
		AnchorPoint = Vector2.new(0.5, 1),
		BackgroundTransparency = 0.1,
		BackgroundColor3 = Theme.Colors.Outline,
		TextColor3 = Theme.Colors.TextLight,
		TextSize = Theme.TextSize.Medium,
		Text = "",
		Visible = false,
		Parent = layer,
	})
	Components.Corner(status, UDim.new(1, 0))

	-- REEL MINIGAME -------------------------------------------------------
	local reel = Create("Frame", {
		Name = "ReelMinigame",
		Size = UDim2.fromOffset(190, 420),
		Position = UDim2.new(0.5, 150, 0.5, -10),
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundColor3 = Theme.Colors.Panel,
		Visible = false,
		Parent = layer,
	})
	Components.Corner(reel)
	Components.Stroke(reel, Theme.Colors.Outline, 4)
	local reelTitle = Components.Label({ Size = UDim2.new(1, -12, 0, 30), Position = UDim2.fromOffset(6, 6), TextSize = Theme.TextSize.Large, Text = "", Parent = reel })
	Components.TextStroke(reelTitle, Theme.Colors.Outline, 2)
	local track = Create("Frame", {
		Name = "Track",
		Size = UDim2.fromOffset(70, 320),
		Position = UDim2.fromOffset(30, 42),
		BackgroundColor3 = Color3.fromRGB(60, 140, 210),
		ClipsDescendants = true,
		Parent = reel,
	}, {
		Create("UIGradient", {
			Rotation = 90,
			Color = ColorSequence.new(Color3.fromRGB(120, 200, 255), Color3.fromRGB(30, 80, 160)),
		}),
	})
	Components.Corner(track, Theme.SmallCorner)
	Components.Stroke(track, Theme.Colors.Outline, 3)
	local zone = Create("Frame", {
		Name = "Zone",
		Size = UDim2.fromScale(1, 0.3),
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.fromScale(0, 1),
		BackgroundColor3 = Theme.Colors.Green,
		BackgroundTransparency = 0.25,
		Parent = track,
	})
	Components.Corner(zone, Theme.SmallCorner)
	Components.Stroke(zone, Theme.Colors.TextLight, 2)
	local fishIcon = Components.Label({
		Name = "Fish",
		Text = "🐟",
		Size = UDim2.fromOffset(44, 36),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		TextSize = 32,
		ZIndex = 3,
		Parent = track,
	})
	local progressBack = Create("Frame", {
		Name = "Progress",
		Size = UDim2.fromOffset(26, 320),
		Position = UDim2.fromOffset(122, 42),
		BackgroundColor3 = Theme.Colors.PanelDark,
		ClipsDescendants = true,
		Parent = reel,
	})
	Components.Corner(progressBack, UDim.new(1, 0))
	Components.Stroke(progressBack, Theme.Colors.Outline, 3)
	local progressFill = Create("Frame", {
		Name = "Fill",
		Size = UDim2.fromScale(1, 0.25),
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.fromScale(0, 1),
		BackgroundColor3 = Theme.Colors.Coins,
		Parent = progressBack,
	})
	Components.Corner(progressFill, UDim.new(1, 0))
	local reelHint = Components.Label({
		Size = UDim2.new(1, -12, 0, 44),
		Position = UDim2.fromOffset(6, 368),
		Font = Theme.Fonts.Bold,
		TextSize = 13,
		Text = "",
		Parent = reel,
	})

	-- CATCH CARD -----------------------------------------------------------
	local card = Create("Frame", {
		Name = "CatchCard",
		Size = UDim2.fromOffset(320, 150),
		Position = UDim2.new(0.5, 0, 0, 140),
		AnchorPoint = Vector2.new(0.5, 0),
		BackgroundColor3 = Theme.Colors.Panel,
		Visible = false,
		Parent = layer,
	})
	Components.Corner(card)
	Components.Stroke(card, Theme.Colors.Outline, 5)
	local cardIcon = Components.Label({ Size = UDim2.fromOffset(100, 100), Position = UDim2.fromOffset(12, 25), TextSize = 76, Text = "🐟", Parent = card })
	local cardRarity = Components.Label({ Size = UDim2.new(1, -130, 0, 22), Position = UDim2.fromOffset(118, 18), TextXAlignment = Enum.TextXAlignment.Left, TextSize = Theme.TextSize.Medium, Text = "", Parent = card })
	Components.TextStroke(cardRarity, Theme.Colors.Outline, 1.5)
	local cardTitle = Components.Label({ Size = UDim2.new(1, -130, 0, 34), Position = UDim2.fromOffset(118, 42), TextXAlignment = Enum.TextXAlignment.Left, TextSize = Theme.TextSize.Title, TextScaled = true, Text = "", Parent = card })
	local cardInfo = Components.Label({ Size = UDim2.new(1, -130, 0, 40), Position = UDim2.fromOffset(118, 80), TextXAlignment = Enum.TextXAlignment.Left, Font = Theme.Fonts.Bold, TextSize = Theme.TextSize.Small, TextColor3 = Theme.Colors.TextMuted, Text = "", Parent = card })
	local cardNew = Components.Label({
		Size = UDim2.fromOffset(70, 28),
		Position = UDim2.new(1, -10, 0, -12),
		AnchorPoint = Vector2.new(1, 0),
		BackgroundTransparency = 0,
		BackgroundColor3 = Theme.Colors.Red,
		TextColor3 = Theme.Colors.TextLight,
		TextSize = Theme.TextSize.Medium,
		Text = "NEW!",
		Visible = false,
		Parent = card,
	})
	Components.Corner(cardNew, UDim.new(1, 0))
	Components.Stroke(cardNew)
	Components.Label({ Text = "YOU CAUGHT", Size = UDim2.fromOffset(120, 16), Position = UDim2.fromOffset(12, 8), Font = Theme.Fonts.Bold, TextSize = 12, TextColor3 = Theme.Colors.TextMuted, Parent = card })

	refs = {
		Status = status,
		Reel = reel,
		ReelTitle = reelTitle,
		Track = track,
		Zone = zone,
		Fish = fishIcon,
		ProgressFill = progressFill,
		ReelHint = reelHint,
		Card = card,
		CardIcon = cardIcon,
		CardTitle = cardTitle,
		CardRarity = cardRarity,
		CardInfo = cardInfo,
		CardNew = cardNew,
	}
end

---------------------------------------------------------------------------
-- Reel minigame
---------------------------------------------------------------------------

local function finishReel(success: boolean)
	local current = minigame
	if not current or current.Finished then
		return
	end
	current.Finished = true
	Net.FireServer("FishingRequest", { Op = "Reel", Success = success, Token = current.Token })
	refs.Reel.Visible = false
	setStatus(if success then "🎣 Landing it..." else nil, Theme.Colors.Green)
end

local function stepMinigame(dt: number)
	local current = minigame
	if not current or current.Finished then
		return
	end
	dt = math.min(dt, 0.1)
	local tuning = FishConfig.Minigame
	current.Elapsed += dt

	-- Player zone: hold to lift, gravity pulls it down.
	local held = InputController.IsHeld("UseTool")
	current.ZoneVel = math.clamp(current.ZoneVel + (if held then tuning.Lift else -tuning.Gravity) * dt, -tuning.MaxSpeed, tuning.MaxSpeed)
	current.ZonePos += current.ZoneVel * dt
	local top = 1 - current.ZoneSize
	if current.ZonePos <= 0 then
		current.ZonePos = 0
		current.ZoneVel = math.max(0, current.ZoneVel)
	elseif current.ZonePos >= top then
		current.ZonePos = top
		current.ZoneVel = math.min(0, current.ZoneVel)
	end

	-- Fish: darts to a new target every so often; harder fish dart more.
	current.FishTimer -= dt
	if current.FishTimer <= 0 then
		current.FishTarget = random:NextNumber(0.04, 0.96)
		current.FishTimer = random:NextNumber(0.6, 1.6) / (0.6 + current.Difficulty * 0.25)
	end
	current.FishPos += (current.FishTarget - current.FishPos) * math.min(1, dt * (1.1 + current.Difficulty * 0.45))

	local inside = current.FishPos >= current.ZonePos and current.FishPos <= current.ZonePos + current.ZoneSize
	local gain = tuning.GainRate / (1 + current.Difficulty * tuning.DifficultyScale)
	if inside then
		current.Progress += gain * dt
	elseif current.Elapsed > START_GRACE then
		current.Progress -= tuning.LossRate * dt
	end

	refs.Zone.Size = UDim2.fromScale(1, current.ZoneSize)
	refs.Zone.Position = UDim2.fromScale(0, 1 - current.ZonePos)
	refs.Zone.BackgroundColor3 = if inside then Theme.Colors.Green else Theme.Colors.Orange
	refs.Fish.Position = UDim2.fromScale(0.5, 1 - current.FishPos)
	refs.ProgressFill.Size = UDim2.fromScale(1, math.clamp(current.Progress, 0, 1))

	if current.Progress >= 1 then
		finishReel(true)
	elseif current.Progress <= 0 then
		finishReel(false)
	end
end

local function startMinigame(rarityName: string, difficulty: number, token: any)
	local tuning = FishConfig.Minigame
	local rarity = RarityConfig.Get(rarityName)
	minigame = {
		Token = token,
		Difficulty = difficulty,
		Rarity = rarityName,
		ZoneSize = math.max(0.14, tuning.ZoneSize - 0.03 * difficulty),
		ZonePos = 0.35,
		ZoneVel = 0,
		FishPos = 0.5,
		FishTarget = 0.5,
		FishTimer = 0.6,
		Progress = tuning.StartProgress,
		Elapsed = 0,
		Finished = false,
	}
	refs.ReelTitle.Text = string.upper(rarity.DisplayName) .. "!"
	refs.ReelTitle.TextColor3 = rarity.Color
	refs.ProgressFill.BackgroundColor3 = rarity.Color
	refs.ReelHint.Text = ("HOLD %s to lift the zone.\nKeep the 🐟 inside!"):format(useHint())
	refs.Reel.Visible = true
	Components.Bounce(refs.Reel, 0.1)
	setStatus(nil)
end

---------------------------------------------------------------------------
-- Server events
---------------------------------------------------------------------------

local function onFishingEvent(payload: any)
	if type(payload) ~= "table" then
		return
	end
	local op = payload.Op
	if op == "Cast" then
		state = "Waiting"
		startBobber(if typeof(payload.Spot) == "Vector3" then payload.Spot else nil)
		AudioController.Play("FishingCast")
		local zone = if type(payload.ZoneName) == "string" then payload.ZoneName .. " · " else ""
		setStatus(("🎣 %sWaiting for a bite...  (X to stop)"):format(zone), Theme.Colors.Outline)
	elseif op == "Bite" then
		if state ~= "Waiting" then
			return
		end
		state = "Bite"
		showBiteMark(true)
		VFXController.Play("WaterSplash", bobberBase)
		AudioController.Play("FishBite")
		CameraController.Shake(0.25, 0.25)
		setStatus(("❗ BITE! %s NOW!"):format(useHint()), Theme.Colors.Red)
	elseif op == "Reel" then
		state = "Reeling"
		showBiteMark(false)
		AudioController.Play("Reel")
		startMinigame(tostring(payload.Rarity), tonumber(payload.Difficulty) or 1, payload.Token)
	elseif op == "Caught" then
		local fishId = payload.FishId
		local position = bobberBase
		resetAll()
		VFXController.Play("WaterSplash", position)
		if type(fishId) == "string" then
			showCatch(fishId, tonumber(payload.Weight) or 0, payload.New == true)
		end
	elseif op == "End" then
		resetAll()
		if type(payload.Reason) == "string" then
			UIController.Notify("Error", payload.Reason, "🎣")
		end
	end
end

-- No Cast reply → the server refused (no spot nearby, cooldown...): allow a new cast.
local function expireCast(requestedAt: number)
	if state == "Casting" and castRequestedAt == requestedAt then
		state = "Idle"
	end
end

local function holdingRod(): boolean
	local held = ToolController.GetHeld()
	return held ~= nil and held.Kind == "Tool" and held.Def.Type == "FishingRod"
end

-- A click while holding a rod: cast at the water you clicked, hook a bite,
-- or (while reeling) nothing. Returns true = click consumed.
local function onClick(target: any): boolean
	if state == "Idle" and not holdingRod() then
		return false
	end
	local now = os.clock()
	if state == "Idle" then
		if target and target.Object then
			return false -- the rod can still open the market, pet animals...
		end
		if not target or not target.Water then
			UIController.Notify("Error", "Click on the water to cast your line.", "🎣")
			return true
		end
		if now - castRequestedAt < FishConfig.CastCooldown then
			return true
		end
		castRequestedAt = now
		state = "Casting"
		AnimationController.PlayLocal("FishingCast", 1)
		Net.FireServer("FishingRequest", { Op = "Cast", Target = target.Position })
		task.delay(CAST_TIMEOUT, expireCast, now)
	elseif state == "Waiting" then
		-- Too early: the server scares the fish off and tells us why.
		Net.FireServer("FishingRequest", { Op = "Hook" })
	elseif state == "Bite" then
		state = "Hooking"
		showBiteMark(false)
		setStatus("🎣 Hooked!", Theme.Colors.Green)
		Net.FireServer("FishingRequest", { Op = "Hook" })
	end
	return true
end

function FishingController.IsFishing(): boolean
	return state ~= "Idle"
end

function FishingController.Init()
	buildUI()
end

function FishingController.Start()
	InteractionController.SetClickHandler(onClick)
	Net.OnClientEvent("FishingEvent", onFishingEvent)
	RunService.RenderStepped:Connect(stepMinigame)

	InputController.On("Cancel", cancelFishing)
	ToolController.EquippedChanged:Connect(function(held: any)
		local isRod = held ~= nil and held.Kind == "Tool" and held.Def.Type == "FishingRod"
		if not isRod and state ~= "Idle" and state ~= "Casting" then
			resetAll()
		end
	end)
	player.CharacterRemoving:Connect(function()
		rodAttachment = nil
		resetAll()
	end)
end

return FishingController
