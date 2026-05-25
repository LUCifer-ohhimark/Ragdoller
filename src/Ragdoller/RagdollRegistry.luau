local registry = {
    Ragdolls = {},
    RagdollTypes = {
        R6 = {
            Name = "R6",
            Motors6D = {
                'Neck',
                'Left Hip',
                'Right Hip',
                'Left Shoulder',
                'Right Shoulder'
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
                'Neck',
                'Waist',
                'LeftHip',
                'RightHip',
                'LeftKnee',
                'RightKnee',
                'LeftAnkle',
                'RightAnkle',
                'LeftShoulder',
                'RightShoulder',
                'LeftElbow',
                'RightElbow',
                'LeftWrist',
                'RightWrist',
            },
            RootJoint = "Root"
        }
    }
}
return registry
