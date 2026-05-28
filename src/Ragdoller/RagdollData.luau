local ragdollData = {}

ragdollData.DefaultOpts = {
    RequiresNeck = true,
    BreakJointsOnDeath = false,
    ColliderSizeMultiplier = 0.5,
    IgnoredRigJoints = {},
    IgnoredMotors6D = {},
    NoCollideBodyParts = {},
}

ragdollData.DefaultJointProperties = {
    TwistLimitsEnabled = true,
    LimitsEnabled = true,
    TwistAngles =  {-45, 45},
    UpperAngle = 45,
    MaxFrictionTorque = 0,
    Restitution = 0,
    JointType = "BallSocket",
    LowerAngle = -45
}

return ragdollData
