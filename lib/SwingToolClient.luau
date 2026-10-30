--!nocheck
-- Swing tool, holder side (LocalScript inside the Tool).
-- Click / tap while holding the tool: plays the swing right away and tells the
-- server, which makes everyone else see it too (see SwingReplicate).
-- Listens to Tool.Activated AND the raw mouse/touch press, so a click always
-- counts even if Activated doesn't fire for some reason.

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local tool = script.Parent
local remote = tool:WaitForChild("SwingEvent")
local Swing = require(tool:WaitForChild("SwingAnim"))

local last = -math.huge

local function swing()
	local character = Players.LocalPlayer.Character
	if not character or tool.Parent ~= character then
		return
	end
	if os.clock() - last < Swing.DURATION - 0.05 then
		return
	end
	last = os.clock()
	Swing.play(character, tool)
	remote:FireServer()
end

tool.Activated:Connect(swing)

UserInputService.InputBegan:Connect(function(input, processed)
	if processed then
		return -- clicked a button / typing in chat
	end
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		swing()
	end
end)

tool.Equipped:Connect(function()
	print("[Wooden Axe] equipped - click to swing")
end)

tool.Unequipped:Connect(function()
	Swing.stop()
end)
