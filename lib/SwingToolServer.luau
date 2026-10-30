--!nocheck
-- Server side of a swing tool: fits the grip to the character's hand on equip
-- and tells every client to play a swing (via the "SwingCount" attribute).

local tool = script.Parent
local remote = tool:WaitForChild("SwingEvent")

local COOLDOWN = 1.3
local GRIP_Y = tool:GetAttribute("GripY") or 0

-- handle axes in the hand's frame: blade (+X) faces where the fist faces down
-- the arm, the haft (+Y) comes out of the front of the fist
local HOLD = CFrame.fromMatrix(Vector3.zero, Vector3.new(0, -1, 0), Vector3.new(0, 0, -1), Vector3.new(1, 0, 0))

tool.Equipped:Connect(function()
	local character = tool.Parent
	local hand = character and (character:FindFirstChild("RightHand") or character:FindFirstChild("Right Arm"))
	local att = hand and hand:FindFirstChild("RightGripAttachment")
	if att then
		tool.Grip = CFrame.new(0, GRIP_Y, 0) * HOLD:Inverse() * att.CFrame.Rotation
	end
end)

local last = {}
remote.OnServerEvent:Connect(function(player)
	local character = player.Character
	if not character or tool.Parent ~= character then
		return
	end
	local now = os.clock()
	if last[player] and now - last[player] < COOLDOWN then
		return
	end
	last[player] = now
	tool:SetAttribute("SwingCount", (tool:GetAttribute("SwingCount") or 0) + 1)
end)
