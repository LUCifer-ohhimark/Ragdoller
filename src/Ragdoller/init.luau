local RunService = game:GetService("RunService")
local Registry = require(script.RagdollRegistry)
local RagdollClass = require(script.Ragdoll)
local module = {}

if RunService:IsClient() then
    error("Ragdoller must be required in Server context, stupid.")
end

function module:CreateRagdoll(character, opts: {any}?) : RagdollClass.Ragdoll
    local ragdoll = RagdollClass.new(character, opts)
    return ragdoll
end

function module:GetRagdoll(character: Model) : RagdollClass.Ragdoll
    local ragdoll = Registry[character]
    assert(ragdoll, `Ragdoll of {character} is nil`)
    return ragdoll
end

function module:ToggleRagdoll(character: Model, enabled: boolean)
    local ragdoll = module:GetRagdoll(character)
    if enabled then RagdollClass.Ragdoll(ragdoll) else RagdollClass.UnRagdoll(ragdoll) end
end

if not script:FindFirstChild("RagdollRemote") then
    local remote = Instance.new("RemoteEvent")
    remote.Name = "RagdollRemote"
    remote.Parent = script
end

return module
