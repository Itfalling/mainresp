--[[
	SCRIPT NAME:  InputConfig
	SCRIPT TYPE:  ModuleScript (shared config)
	WHERE:        ReplicatedStorage/Shared/Config/InputConfig
	DEPENDENCIES: Shared.Util.TableUtil

	Maps abstract ACTIONS to physical inputs for keyboard/mouse and gamepad.
	Touch devices trigger the same actions through on-screen buttons that call
	InputController.Trigger(actionName). Gameplay code only ever listens to
	actions, never to raw keys — that is what keeps mobile/console support free.

	There are no ProximityPrompts: you CLICK things (InteractionController).
	E / F / ButtonX use whatever you're looking at. Build mode blocks
	Interact while it is open so Q / E can rotate the preview.
]]

local TableUtil = require(script.Parent.Parent.Util.TableUtil)

local InputConfig = {
	Actions = {
		UseTool = {
			Inputs = { Enum.UserInputType.MouseButton1 },
			Gamepad = { Enum.KeyCode.ButtonR2 },
		},
		-- Interact with whatever you hover (same as clicking it).
		Interact = { Inputs = { Enum.KeyCode.E, Enum.KeyCode.F }, Gamepad = { Enum.KeyCode.ButtonX } },
		ToggleInventory = {
			Inputs = { Enum.KeyCode.I, Enum.KeyCode.G },
			Gamepad = { Enum.KeyCode.ButtonY },
		},
		ToggleBuild = {
			Inputs = { Enum.KeyCode.B },
			Gamepad = { Enum.KeyCode.DPadUp },
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
		Hotbar7 = { Inputs = { Enum.KeyCode.Seven }, Gamepad = {} },
		Hotbar8 = { Inputs = { Enum.KeyCode.Eight }, Gamepad = {} },
		Hotbar9 = { Inputs = { Enum.KeyCode.Nine }, Gamepad = {} },
		Unequip = { Inputs = { Enum.KeyCode.Zero, Enum.KeyCode.Backquote }, Gamepad = {} },
		Emotes = { Inputs = { Enum.KeyCode.T }, Gamepad = { Enum.KeyCode.DPadDown } },
		PlayersMenu = { Inputs = { Enum.KeyCode.P }, Gamepad = {} },
		-- Hold to sprint (run animation + wider view).
		Sprint = { Inputs = { Enum.KeyCode.LeftShift, Enum.KeyCode.RightShift }, Gamepad = { Enum.KeyCode.ButtonL3 } },
		-- Build mode
		BuildPlace = { Inputs = { Enum.UserInputType.MouseButton1 }, Gamepad = { Enum.KeyCode.ButtonR2 } },
		RotateBuild = { Inputs = { Enum.KeyCode.R }, Gamepad = { Enum.KeyCode.ButtonX } },
		RotateBuildLeft = { Inputs = { Enum.KeyCode.Q }, Gamepad = { Enum.KeyCode.DPadLeft } },
		RotateBuildRight = { Inputs = { Enum.KeyCode.E }, Gamepad = { Enum.KeyCode.DPadRight } },
	},

	-- Minimum on-screen button size for touch (Roblox recommends >= 44px).
	MinTouchButtonSize = 64,
}

return TableUtil.DeepFreeze(InputConfig)
