--!nocheck
-- Swing tool, holder side (LocalScript inside the Tool).
-- Click while holding the tool: plays the swing right away and tells the
-- server, which makes everyone else see it too (see SwingReplicate).

local Players = game:GetService("Players")

local tool = script.Parent
local remote = tool:WaitForChild("SwingEvent")
local Swing = require(tool:WaitForChild("SwingAnim"))

local last = -math.huge

tool.Activated:Connect(function()
	local character = Players.LocalPlayer.Character
	if tool.Parent ~= character or os.clock() - last < Swing.DURATION - 0.05 then
		return
	end
	last = os.clock()
	Swing.play(character, tool)
	remote:FireServer()
end)

tool.Unequipped:Connect(function()
	Swing.stop()
end)
