--[[
	SCRIPT NAME:  InputController
	SCRIPT TYPE:  ModuleScript (client controller)
	WHERE:        StarterPlayerScripts/Client/Controllers/InputController
	DEPENDENCIES: Shared.Config.InputConfig, Shared.Util.Signal

	Turns raw input into named ACTIONS (see InputConfig). Keyboard, mouse and
	gamepad are mapped here; touch UI buttons call InputController.Trigger().
	Gameplay controllers only ever listen with InputController.On(action, fn),
	which is what makes every feature work on desktop, mobile and console.

	Also tracks the active device ("KeyboardMouse" | "Touch" | "Gamepad") so
	the UI can show touch buttons only when needed.
]]

local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local InputConfig = require(Shared:WaitForChild("Config"):WaitForChild("InputConfig"))
local Signal = require(Shared:WaitForChild("Util"):WaitForChild("Signal"))

local InputController = {}

InputController.DeviceChanged = Signal.new() -- (deviceType)

local actionSignals: { [string]: any } = {}
local held: { [string]: number } = {} -- action -> number of inputs holding it
local bindings: { [any]: { string } } = {} -- KeyCode/UserInputType -> actions
local device = "KeyboardMouse"
local blocked: { [string]: number } = {} -- action -> block count

local function signalFor(action: string)
	local signal = actionSignals[action]
	if not signal then
		assert(InputConfig.Actions[action], "Unknown input action " .. action)
		signal = Signal.new()
		actionSignals[action] = signal
	end
	return signal
end

local function bind(input: any, action: string)
	local list = bindings[input]
	if not list then
		list = {}
		bindings[input] = list
	end
	table.insert(list, action)
end

local function classify(inputType: Enum.UserInputType): string?
	if inputType == Enum.UserInputType.Touch then
		return "Touch"
	elseif string.find(inputType.Name, "Gamepad") then
		return "Gamepad"
	elseif inputType == Enum.UserInputType.Keyboard or string.find(inputType.Name, "Mouse") then
		return "KeyboardMouse"
	end
	return nil
end

local function setDevice(newDevice: string)
	if newDevice ~= device then
		device = newDevice
		InputController.DeviceChanged:Fire(device)
	end
end

function InputController.On(action: string, callback: () -> ())
	return signalFor(action):Connect(callback)
end

function InputController.Trigger(action: string)
	if (blocked[action] or 0) > 0 then
		return
	end
	signalFor(action):Fire()
end

-- Temporarily block an action (e.g. UseTool while a menu is open). Returns an unblock function.
function InputController.Block(action: string): () -> ()
	blocked[action] = (blocked[action] or 0) + 1
	local released = false
	return function()
		if not released then
			released = true
			blocked[action] = math.max(0, (blocked[action] or 1) - 1)
		end
	end
end

-- True while an input bound to the action is held down (used by the fishing reel).
function InputController.IsHeld(action: string): boolean
	return (held[action] or 0) > 0
end

-- Touch buttons report press/release through this.
function InputController.SetHeld(action: string, isHeld: boolean)
	held[action] = math.max(0, (held[action] or 0) + (if isHeld then 1 else -1))
	if not isHeld and held[action] == 0 then
		held[action] = nil
	end
end

function InputController.GetDevice(): string
	return device
end

function InputController.IsTouch(): boolean
	return device == "Touch"
end

function InputController.Init()
	for action, def in InputConfig.Actions do
		signalFor(action)
		for _, input in def.Inputs do
			bind(input, action)
		end
		for _, input in def.Gamepad do
			bind(input, action)
		end
	end

	if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
		device = "Touch"
	elseif UserInputService.GamepadEnabled and not UserInputService.KeyboardEnabled then
		device = "Gamepad"
	end
end

function InputController.Start()
	UserInputService.LastInputTypeChanged:Connect(function(inputType)
		local newDevice = classify(inputType)
		if newDevice then
			setDevice(newDevice)
		end
	end)

	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then
			return -- typing in chat, clicking a GUI button, a text box...
		end
		-- Keys/buttons bind by KeyCode; mouse buttons bind by UserInputType.
		local actions = bindings[input.KeyCode] or bindings[input.UserInputType]
		if actions then
			for _, action in actions do
				InputController.SetHeld(action, true)
				InputController.Trigger(action)
			end
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		local actions = bindings[input.KeyCode] or bindings[input.UserInputType]
		if actions then
			for _, action in actions do
				if (held[action] or 0) > 0 then
					InputController.SetHeld(action, false)
				end
			end
		end
	end)
end

return InputController
