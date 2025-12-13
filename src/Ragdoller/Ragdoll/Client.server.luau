local RagdollClass = script.Parent
local Ragdoller = RagdollClass.Parent
local RagdollState = require(RagdollClass.RagdollState)

repeat task.wait(0.1) until Ragdoller:FindFirstChild("RagdollRemote")

local RagdollRemote = Ragdoller:FindFirstChild("RagdollRemote") :: RemoteEvent

RagdollRemote.OnClientEvent:Connect(function(humanoid: Humanoid, isRagdoll: boolean)
    if isRagdoll then
        RagdollState:EnableRagdollState(humanoid)
    else
        RagdollState:DisableRagdollState(humanoid)
    end
end)
