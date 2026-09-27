--[[
	SCRIPT NAME:  InputConfig
	SCRIPT TYPE:  ModuleScript (shared config)
	WHERE:        ReplicatedStorage/Shared/Config/InputConfig
	DEPENDENCIES: Shared.Util.TableUtil

	Maps abstract ACTIONS to physical inputs for keyboard/mouse and gamepad.
	Touch devices trigger the same actions through on-screen buttons that call
	InputController.Trigger(actionName). Gameplay code only ever listens to
	actions, never to raw keys — that is what keeps mobile/console support free.

	Note: the ProximityPrompt interact key is E (Roblox default). Build mode
	(Phase 3) disables prompts while active so Q/E can rotate.
]]

local TableUtil = require(script.Parent.Parent.Util.TableUtil)

local InputConfig = {
	Actions = {
		UseTool = {
			Inputs = { Enum.UserInputType.MouseButton1 },
			Gamepad = { Enum.KeyCode.ButtonR2 },
		},
		ToggleInventory = {
			Inputs = { Enum.KeyCode.B, Enum.KeyCode.I },
			Gamepad = { Enum.KeyCode.ButtonY },
		},
		Cancel = {
			Inputs = { Enum.KeyCode.X },
			Gamepad = { Enum.KeyCode.ButtonB },
		},
		HotbarNext = { Inputs = {}, Gamepad = { Enum.KeyCode.ButtonR1 } },
		HotbarPrevious = { Inputs = {}, Gamepad = { Enum.KeyCode.ButtonL1 } },
		Hotbar1 = { Inputs = { Enum.KeyCode.One }, Gamepad = {} },
		Hotbar2 = { Inputs = { Enum.KeyCode.Two }, Gamepad = {} },
		Hotbar3 = { Inputs = { Enum.KeyCode.Three }, Gamepad = {} },
		Hotbar4 = { Inputs = { Enum.KeyCode.Four }, Gamepad = {} },
		Hotbar5 = { Inputs = { Enum.KeyCode.Five }, Gamepad = {} },
		Hotbar6 = { Inputs = { Enum.KeyCode.Six }, Gamepad = {} },
		-- Reserved for Build Mode (Phase 3); declared now so names never change.
		RotateBuild = { Inputs = { Enum.KeyCode.R }, Gamepad = { Enum.KeyCode.ButtonX } },
		RotateBuildLeft = { Inputs = { Enum.KeyCode.Q }, Gamepad = {} },
		RotateBuildRight = { Inputs = { Enum.KeyCode.E }, Gamepad = {} },
	},

	-- Minimum on-screen button size for touch (Roblox recommends >= 44px).
	MinTouchButtonSize = 64,
}

return TableUtil.DeepFreeze(InputConfig)
