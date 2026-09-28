--[[
	SCRIPT NAME:  InteractionController
	SCRIPT TYPE:  ModuleScript (client controller)
	WHERE:        StarterPlayerScripts/Client/Controllers/InteractionController
	DEPENDENCIES: AudioController

	Client polish for the server's ProximityPrompt interactions:
	  * outlines the object whose prompt is showing (one pooled Highlight),
	  * hides owner-only prompts on islands you don't own (visual only — the
	    server still rejects the action),
	  * can pause all prompts while a menu or build mode is open,
	  * turns your character to FACE what you interact with, so chopping,
	    milking or planting animations line up with the target.
	Prompt text / keys / touch buttons come from the server's prompt itself.
]]

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ProximityPromptService = game:GetService("ProximityPromptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local R15 = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Util"):WaitForChild("R15"))

local AudioController = require(script.Parent.AudioController)

local OWNER_ONLY_TAG = "OwnerOnlyPrompt"

local InteractionController = {}

local highlight: Highlight
local shownPrompt: ProximityPrompt? = nil
local pauseCount = 0

local function adorneeFor(prompt: ProximityPrompt): Instance?
	local parent = prompt.Parent
	if not parent then
		return nil
	end
	-- Outline the whole object (tree, building, cow...) — but never the whole island.
	local model = parent:FindFirstAncestorOfClass("Model")
	local islands = workspace:FindFirstChild("Islands")
	if model and model.Parent ~= islands then
		return model
	end
	if parent:IsA("Attachment") then
		return parent.Parent
	end
	return parent
end

local function hideIfNotOwner(prompt: Instance)
	if not prompt:IsA("ProximityPrompt") then
		return
	end
	local ownerUserId = prompt:GetAttribute("OwnerUserId")
	if ownerUserId == nil or ownerUserId == Players.LocalPlayer.UserId then
		return
	end
	prompt.Enabled = false
	prompt:GetPropertyChangedSignal("Enabled"):Connect(function()
		if prompt.Enabled then
			prompt.Enabled = false
		end
	end)
end

local function targetPosition(prompt: ProximityPrompt): Vector3?
	local adornee = adorneeFor(prompt)
	if not adornee then
		return nil
	end
	if adornee:IsA("Model") then
		return adornee:GetPivot().Position
	elseif adornee:IsA("BasePart") then
		return adornee.Position
	elseif adornee:IsA("Attachment") then
		return adornee.WorldPosition
	end
	return nil
end

-- Snap the character's yaw toward the thing being used (the client owns its
-- character's physics, so this replicates; the server never trusts it).
local function faceTarget(prompt: ProximityPrompt)
	local character = Players.LocalPlayer.Character
	local root = R15.GetRootPart(character)
	local target = targetPosition(prompt)
	if not root or not target then
		return
	end
	local flat = Vector3.new(target.X, root.Position.Y, target.Z)
	if (flat - root.Position).Magnitude < 0.5 then
		return
	end
	root.CFrame = CFrame.lookAt(root.Position, flat)
end

-- Pause/resume every prompt locally (menus, build mode). Returns a resume function.
function InteractionController.PausePrompts(): () -> ()
	pauseCount += 1
	ProximityPromptService.Enabled = false
	local resumed = false
	return function()
		if resumed then
			return
		end
		resumed = true
		pauseCount = math.max(0, pauseCount - 1)
		ProximityPromptService.Enabled = pauseCount == 0
	end
end

function InteractionController.Init()
	highlight = Instance.new("Highlight")
	highlight.Name = "InteractHighlight"
	highlight.FillTransparency = 1
	highlight.OutlineColor = Color3.fromRGB(255, 245, 200)
	highlight.OutlineTransparency = 0.15
	highlight.DepthMode = Enum.HighlightDepthMode.Occluded
	highlight.Enabled = false
	-- Under the camera: local-only, and always inside Workspace so it renders.
	highlight.Parent = workspace.CurrentCamera
end

function InteractionController.Start()
	for _, prompt in CollectionService:GetTagged(OWNER_ONLY_TAG) do
		hideIfNotOwner(prompt)
	end
	CollectionService:GetInstanceAddedSignal(OWNER_ONLY_TAG):Connect(hideIfNotOwner)

	ProximityPromptService.PromptShown:Connect(function(prompt)
		shownPrompt = prompt
		highlight.Adornee = adorneeFor(prompt)
		highlight.Enabled = highlight.Adornee ~= nil
	end)
	ProximityPromptService.PromptHidden:Connect(function(prompt)
		if shownPrompt == prompt then
			shownPrompt = nil
			highlight.Enabled = false
			highlight.Adornee = nil
		end
	end)
	ProximityPromptService.PromptTriggered:Connect(function(prompt)
		AudioController.Play("UIClick")
		faceTarget(prompt)
	end)
end

return InteractionController
