local module = {}

function module:EnableRagdollState(humanoid)
    humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
    humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, false)
    humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
    humanoid:ChangeState(Enum.HumanoidStateType.PlatformStanding)
end

function module:DisableRagdollState(humanoid)
    humanoid.PlatformStand = false
    humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
    humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, true)
    humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
    humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
end

return module
