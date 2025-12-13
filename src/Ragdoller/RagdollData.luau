local ragdollData = {}

ragdollData.BodyParts_R6 = {
    'Torso',
    'Head',
    'Left Leg',
    'Right Leg',
    'Left Arm',
    'Right Arm'
}

ragdollData.Motors6D_R6 = {
    'Neck',
    'Left Shoulder',
    'Right Shoulder',
    'Left Hip',
    'Right Hip'
}

ragdollData.DefaultOpts = {
    RequiresNeck = true,
    LimbsCollidersEnabled = true,
    ColliderSizeMultiplier = 0.5,
    IgnoredMotors6D = {}
}

return ragdollData
