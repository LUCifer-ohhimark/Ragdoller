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
    motors6D: {any},
    bodyParts: {string},
    rootJoint: string
) : {
        Name: string,
        Motors6D: {any},
        BodyParts: {string},
        RootJoint: string
    }

    for index, value in motors6D do
        if typeof(value) == "string" then
            table.remove(motors6D, index)
            motors6D[value] = {}
        end
    end

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

function module:GetRagdollType(character: Model) :
    { 
        Name: string,
        Motors6D: {any},
        BodyParts: {string}, 
        RootJoint: string 
    }
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
