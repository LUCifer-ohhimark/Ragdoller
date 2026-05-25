local RunService = game:GetService("RunService")
local Registry = require(script.RagdollRegistry)
local RagdollClass = require(script.Ragdoll)
local module = {}

if RunService:IsClient() then
    error("Ragdoller must be required in Server context, stupid.")
end

function module:CreateRagdoll(character: Model, opts: {any}?) : RagdollClass.Ragdoll
    local ragdoll = RagdollClass.new(character, opts)
    return ragdoll
end

function module:CreateRagdollType(
    name: string,
    motors6D: {string},
    bodyParts: {string},
    rootTorso: string,
    rootJoint: string
) : {
        Name: string,
        Motors6D: {string},
        BodyParts: {string},
        RootTorso: string,
        Root: string,
        RootJoint: string
    }
    Registry.RagdollTypes[name] = {
        Name = name,
        Motors6D = motors6D,
        BodyParts = bodyParts,
    }
    return Registry.RagdollTypes[name]
end

function module:GetRagdoll(character: Model) : RagdollClass.Ragdoll
    local ragdoll = Registry.Ragdolls[character]
    assert(ragdoll, `Ragdoll of {character} is nil`)
    return ragdoll
end

function module:GetRagdollType(character: Model)
    local ragdollType = module:GetRagdoll(character).RagdollType
    return ragdollType
end

function module:GetRagdollRegistry() : {any}
    return Registry
end

function module:ToggleRagdoll(character: Model, enabled: boolean)
    local ragdoll = module:GetRagdoll(character)
    if enabled then RagdollClass.Ragdoll(ragdoll) else RagdollClass.UnRagdoll(ragdoll) end
end

function module:toggleRagdollCharacter(character: Model, enabled: boolean)
    module:ToggleRagdoll(character, enabled)
end

return module
