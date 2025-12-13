local module = {}

function module:EnableRagdollState(humanoid)
    humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, false)
    humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
    humanoid:ChangeState(Enum.HumanoidStateType.PlatformStanding)
    humanoid.PlatformStand = true
end

function module:DisableRagdollState(humanoid)
    humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, true)
    humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
    humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
    humanoid.PlatformStand = false
end

return module
