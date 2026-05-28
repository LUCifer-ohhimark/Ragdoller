local bodyR6Properties = {
    UpperAngle = 90
}

local registry = {
    Ragdolls = {},
    RagdollTypes = {
        R6 = {
            Name = "R6",
            RigJoints = {
                Neck = {},
                ['Left Hip'] = bodyR6Properties,
                ['Right Hip'] = bodyR6Properties,
                ['Left Shoulder'] = bodyR6Properties,
                ['Right Shoulder'] = bodyR6Properties,
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
                'LeftHand',
                'RightHand',
            },
            RigJoints = {
                Neck = {
                    Name = "NeckBallSocket"
                },
                Waist = {
                    Name = "WaistBallSocket"
                },
                LeftHip = {
                    Name = "LeftHipBallSocket"
                },
                RightHip = {
                    Name = "RightHipBallSocket"
                },
                LeftKnee = {
                    Name = "LeftKneeBallSocket"
                },
                RightKnee = {
                    Name = "RightKneeBallSocket"
                },
                LeftAnkle = {
                    Name = "LeftAnkleBallSocket"
                },
                RightAnkle = {
                    Name = "RightAnkleBallSocket"
                },
                LeftShoulder = {
                    Name = "LeftShoulderBallSocket"
                },
                RightShoulder = {
                    Name = "RightShoulderBallSocket"
                },
                LeftElbow = {
                    Name = "LeftElbowBallSocket"
                },
                RightElbow = {
                    Name = "RightElbowBallSocket"
                },
                LeftWrist = {
                    Name = "LeftWristBallSocket"
                },
                RightWrist = {
                    Name = "RightWristBallSocket"
                },
            },
            RootJoint = "Root"
        },
        R15_Motor6D = {
            Name = "R15_Motor6D",
            BodyParts = {
                'UpperTorso',
                'Head',
                'LeftUpperLeg',
                'RightUpperLeg',
                'LeftFoot',
                'RightFoot',
                'LeftUpperArm',
                'RightUpperArm',
                'LeftHand',
                'RightHand',
            },
            RigJoints = {
                Neck = {},
                Waist = {},
                LeftHip = {},
                RightHip = {},
                LeftKnee = {},
                RightKnee = {},
                LeftAnkle = {},
                RightAnkle = {},
                LeftShoulder = {},
                RightShoulder = {},
                LeftElbow = {},
                RightElbow = {},
                LeftWrist = {},
                RightWrist = {},
            },
            RootJoint = "Root"
        }
    }
}
return registry
