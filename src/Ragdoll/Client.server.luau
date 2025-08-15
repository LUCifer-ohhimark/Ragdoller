local RagdollM = script.Parent
local ragdollCloneRE = RagdollM.RagdollCloneRE
local ragdollRE = RagdollM.RagdollRE

local camera = workspace.CurrentCamera :: Camera

ragdollCloneRE.OnClientEvent:Connect(function(humanoid: Humanoid)
    camera.CameraSubject = humanoid
    humanoid:ChangeState(Enum.HumanoidStateType.PlatformStanding)
    humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, false)
    humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
end)

ragdollRE.OnClientEvent:Connect(function(humanoid: Humanoid, enabled: boolean)
    if not enabled then
        humanoid:ChangeState(Enum.HumanoidStateType.PlatformStanding)
    else
        humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
    end
    humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, enabled)
    humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, enabled)
end)

while task.wait(.5) do
    local player = game.Players.LocalPlayer
    local char = player.Character or player.CharacterAdded:Wait()
    local humanoid = char:WaitForChild("Humanoid")

    print(humanoid:GetStateEnabled(Enum.HumanoidStateType.GettingUp))
end