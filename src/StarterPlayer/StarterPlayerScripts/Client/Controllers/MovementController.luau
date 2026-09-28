--[[
	SCRIPT NAME:  MovementController
	SCRIPT TYPE:  ModuleScript (client controller)
	WHERE:        StarterPlayerScripts/Client/Controllers/MovementController
	DEPENDENCIES: Shared.Config.GameConfig, InputController, CameraController, UIController

	SPRINT: hold Shift (or press the left stick on a gamepad) to run at
	GameConfig.Character.SprintSpeed. The run animation, dust puffs and a
	slightly wider camera kick in automatically. Your own client moves your
	character, so the speed is set here; the server's movement check
	(AntiExploitService) already allows for it. Menus and build mode stop
	sprinting.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local GameConfig = require(Shared.Config.GameConfig)

local InputController = require(script.Parent.InputController)
local CameraController = require(script.Parent.CameraController)
local UIController = require(script.Parent.UIController)

local MovementController = {}

local sprinting = false

function MovementController.IsSprinting(): boolean
	return sprinting
end

local function update()
	local character = Players.LocalPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return
	end
	local wants = InputController.IsHeld("Sprint")
		and not UIController.IsAnyModalOpen()
		and humanoid.MoveDirection.Magnitude > 0.1
	if wants ~= sprinting then
		sprinting = wants
		CameraController.SetSprint(sprinting)
	end
	local speed = if sprinting then GameConfig.Character.SprintSpeed else GameConfig.Character.WalkSpeed
	if humanoid.WalkSpeed ~= speed then
		humanoid.WalkSpeed = speed
	end
end

function MovementController.Start()
	RunService.RenderStepped:Connect(update)
end

return MovementController
