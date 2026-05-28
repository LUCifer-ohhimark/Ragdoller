local RagdollClass = script.Parent
local Types = require(RagdollClass.Parent.Types)
local module = {}

function module:MakeRagdollAttachments(rigJoint: Motor6D, attachmentName: string?)
    local part0 = rigJoint.Part0 :: BasePart
    local part1 = rigJoint.Part1 :: BasePart
    local formattedName = part1.Name:gsub(" ", "_")

    local attachment0 = Instance.new("Attachment")
    attachment0.CFrame = rigJoint.C0
    attachment0.Name = attachmentName or `RAGDOLL_ATTACHMENT_{string.upper(formattedName)}`

    local attachment1 = Instance.new("Attachment")
    attachment1.CFrame = rigJoint.C1
    attachment1.Name = attachmentName or `RAGDOLL_ATTACHMENT_{string.upper(formattedName)}`

    attachment0.Parent = part0
    attachment1.Parent = part1

    return attachment0, attachment1, part0, part1
end

function module:MakeHinge
(
    attachment0: Attachment,
    attachment1: Attachment,
    hingeName: string,
    partParent: MeshPart | BasePart,
    jointProperties: Types.JointProperties
) : HingeConstraint

    local ragdollHinge = Instance.new("HingeConstraint")
    ragdollHinge.Name = hingeName
    ragdollHinge.Attachment0 = attachment0
    ragdollHinge.Attachment1 = attachment1
    ragdollHinge:AddTag("RAGDOLL_JOINT")

    ragdollHinge.LimitsEnabled = jointProperties.LimitsEnabled
    ragdollHinge.UpperAngle = jointProperties.UpperAngle
    ragdollHinge.LowerAngle = jointProperties.LowerAngle
    ragdollHinge.Restitution = jointProperties.Restitution
    ragdollHinge.Parent = partParent

    return ragdollHinge
end

function module:MakeBallSocket(
    attachment0: Attachment,
    attachment1: Attachment,
    socketName: string,
    partParent: MeshPart | BasePart,
    jointProperties: Types.JointProperties
) : BallSocketConstraint

    local ragdollBallSocket = Instance.new("BallSocketConstraint")
    ragdollBallSocket.Name = socketName
    ragdollBallSocket.Attachment0 = attachment0
    ragdollBallSocket.Attachment1 = attachment1
    ragdollBallSocket:AddTag("RAGDOLL_JOINT")

    ragdollBallSocket.LimitsEnabled = jointProperties.LimitsEnabled
    ragdollBallSocket.TwistLimitsEnabled = jointProperties.TwistLimitsEnabled
    ragdollBallSocket.TwistUpperAngle = jointProperties.TwistAngles[2]
    ragdollBallSocket.TwistLowerAngle = jointProperties.TwistAngles[1]
    ragdollBallSocket.UpperAngle = jointProperties.UpperAngle
    ragdollBallSocket.Restitution = jointProperties.Restitution
    ragdollBallSocket.MaxFrictionTorque = jointProperties.MaxFrictionTorque

    ragdollBallSocket.Parent = partParent

    return ragdollBallSocket
end

return module
