local RagdollClass = require(script.Ragdoll)
local ragdoller = {}

function ragdoller:CreateRagdoll(character, opts: {any}?) : RagdollClass.Ragdoll
    local ragdoll = RagdollClass.new(character, opts)
    return ragdoll
end

function ragdoller:GetRagdoll(character: Model) : RagdollClass.Ragdoll
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local RagdollCallback: BindableFunction = humanoid:FindFirstChild("RAGDOLL_CALLBACK")
    local ragdoll = RagdollCallback:Invoke()
    assert(ragdoll, `Ragdoll of {character} is nil`)
    return ragdoll
end

function ragdoller:ToggleRagdoll(character: Model, enabled: boolean)
    local ragdoll = ragdoller:GetRagdoll(character)
    if enabled then RagdollClass.Ragdoll(ragdoll) else RagdollClass.UnRagdoll(ragdoll) end
end

return ragdoller
