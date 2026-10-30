--!nocheck
-- Swing tool, everyone-else side (Script, RunContext = Client).
-- When the server bumps the tool's "SwingCount", every other player's client
-- plays the same swing on the holder's character.

local Players = game:GetService("Players")

local tool = script.Parent
local Swing = require(tool:WaitForChild("SwingAnim"))

tool:GetAttributeChangedSignal("SwingCount"):Connect(function()
	local character = tool.Parent
	local me = Players.LocalPlayer
	if not character or not character:FindFirstChildOfClass("Humanoid") then
		return
	end
	if me and me.Character == character then
		return -- the holder already played it locally
	end
	Swing.play(character, tool)
end)
