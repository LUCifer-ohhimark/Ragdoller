local types = {}

export type RagdollType = {
    Name: string,
    Motors6D: {any},
    BodyParts: {string},
    RootJoint: string
}

export type JointProperties = {
    TwistAngles: {number},
    UpperAngle: number,
    MaxFrictionTorque: number,
    Restitution: number,
    JointType: string,
    Name: string,
    LowerAngle: number,
    LimitsEnabled: boolean,
    TwistLimitsEnabled: boolean,
}

export type RagdollOptions = {
    RequiresNeck: boolean,
    BreakJointsOnDeath: boolean,
    ColliderSizeMultiplier: number,
    IgnoredRigJoints: { Motor6D | AnimationConstraint },
    IgnoredMotors6D: { Motor6D },
    NoCollideBodyParts: { BasePart | MeshPart },
    RagdollType: RagdollType,
}

return types

