local waistR15Properties = {
    UpperAngle = 5
}

local neckR15Properties = {
    UpperAngle = 15
}

local wristR15Properties = {
    UpperAngle = 0,
    TwistAngles = {0, 0}
}

local kneeR15Properties = {
    UpperAngle = 0,
    TwistAngles = {-75, 0}
}

local ankleR15Properties = {
    UpperAngle = 15,
    TwistAngles = {-45, 15}
}

local registry = {
    Ragdolls = {},
    RagdollTypes = {
        R6 = {
            Name = "R6",
            Motors6D = {
                Neck = {},
                ['Left Hip'] = { UpperAngle = 90 },
                ['Right Hip'] = { UpperAngle = 90 },
                ['Left Shoulder'] = { UpperAngle = 90 },
                ['Right Shoulder'] = { UpperAngle = 90 }
            },
            BodyParts = {
                'Torso',
                'Head',
                'Left Leg',
                'Right Leg',
                'Left Arm',
                'Right Arm'
            },
            RootJoint = "RootJoint"
        },
        R15 = {
            Name = "R15",
            BodyParts = {
                'UpperTorso',
                'Head',
                'LeftUpperLeg',
                'RightUpperLeg',
                'LeftFoot',
                'RightFoot',
                'LeftUpperArm',
                'RightUpperArm',
                'LeftLowerArm',
                'RightLowerArm',
                'LeftHand',
                'RightHand'
            },
            Motors6D = {
                Neck = neckR15Properties,
                Waist = waistR15Properties,
                LeftHip = {},
                RightHip = {},
                LeftKnee = kneeR15Properties,
                RightKnee = kneeR15Properties,
                LeftAnkle = ankleR15Properties,
                RightAnkle = ankleR15Properties,
                LeftShoulder = {},
                RightShoulder = {},
                LeftElbow = {},
                RightElbow = {},
                LeftWrist = wristR15Properties,
                RightWrist = wristR15Properties,
            },
            RootJoint = "Root"
        }
    }
}
return registry
