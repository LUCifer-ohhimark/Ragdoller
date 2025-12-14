local RagdollClass = script.Parent
local RagdollState = require(RagdollClass.RagdollState)

local RagdollRemote = RagdollClass:FindFirstChild("RagdollRemote") :: RemoteEvent
RagdollRemote.OnClientEvent:Connect(function(humanoid: Humanoid, isRagdoll: boolean)
    if isRagdoll then
        RagdollState:EnableRagdollState(humanoid)
    else
        RagdollState:DisableRagdollState(humanoid)
    end
end)
