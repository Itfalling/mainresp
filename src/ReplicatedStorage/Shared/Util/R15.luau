--!strict
--[[
	SCRIPT NAME:  R15
	SCRIPT TYPE:  ModuleScript (shared utility)
	WHERE:        ReplicatedStorage/Shared/Util/R15
	DEPENDENCIES: none

	Single source of truth for R15 body-part and Motor6D names. Nothing in the
	project hard-codes R6 parts ("Torso", "Right Arm", ...). If you ever need
	R6 compatibility, add it HERE and nowhere else.
]]

local R15 = {}

R15.PartNames = table.freeze({
	"Head",
	"UpperTorso",
	"LowerTorso",
	"LeftUpperArm",
	"LeftLowerArm",
	"LeftHand",
	"RightUpperArm",
	"RightLowerArm",
	"RightHand",
	"LeftUpperLeg",
	"LeftLowerLeg",
	"LeftFoot",
	"RightUpperLeg",
	"RightLowerLeg",
	"RightFoot",
	"HumanoidRootPart",
})

-- Motor6D name -> the body part that parents it in a standard R15 rig.
R15.MotorParents = table.freeze({
	Root = "LowerTorso",
	Waist = "UpperTorso",
	Neck = "Head",
	LeftShoulder = "LeftUpperArm",
	LeftElbow = "LeftLowerArm",
	LeftWrist = "LeftHand",
	RightShoulder = "RightUpperArm",
	RightElbow = "RightLowerArm",
	RightWrist = "RightHand",
	LeftHip = "LeftUpperLeg",
	LeftKnee = "LeftLowerLeg",
	LeftAnkle = "LeftFoot",
	RightHip = "RightUpperLeg",
	RightKnee = "RightLowerLeg",
	RightAnkle = "RightFoot",
})

-- Attachments the tool system grips with.
R15.GripAttachments = table.freeze({
	RightHand = "RightGripAttachment",
	LeftHand = "LeftGripAttachment",
})

function R15.GetHumanoid(character: Model?): Humanoid?
	if not character then
		return nil
	end
	return character:FindFirstChildOfClass("Humanoid")
end

function R15.GetRootPart(character: Model?): BasePart?
	if not character then
		return nil
	end
	local root = character:FindFirstChild("HumanoidRootPart")
	if root and root:IsA("BasePart") then
		return root
	end
	return nil
end

function R15.GetPart(character: Model?, partName: string): BasePart?
	if not character then
		return nil
	end
	local part = character:FindFirstChild(partName)
	if part and part:IsA("BasePart") then
		return part
	end
	return nil
end

function R15.GetMotor(character: Model?, motorName: string): Motor6D?
	local parentName = R15.MotorParents[motorName]
	if not parentName then
		return nil
	end
	local parent = R15.GetPart(character, parentName)
	local motor = parent and parent:FindFirstChild(motorName)
	if motor and motor:IsA("Motor6D") then
		return motor
	end
	return nil
end

function R15.IsR15(character: Model?): boolean
	local humanoid = R15.GetHumanoid(character)
	if not humanoid or humanoid.RigType ~= Enum.HumanoidRigType.R15 then
		return false
	end
	return R15.GetPart(character, "UpperTorso") ~= nil and R15.GetPart(character, "RightHand") ~= nil
end

function R15.IsAlive(character: Model?): boolean
	local humanoid = R15.GetHumanoid(character)
	return humanoid ~= nil and humanoid.Health > 0 and R15.GetRootPart(character) ~= nil
end

return R15
