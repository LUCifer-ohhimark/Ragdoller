local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Registry = require(script.RagdollRegistry)
local RagdollClass = require(script.Ragdoll)
local RagdollState = require(script.Ragdoll.RagdollState)
local Types = require(script.Types)

local RagdollRemote = script.Ragdoll.RagdollRemote

local module = {}

if RunService:IsClient() then
    error("Ragdoller must be required in Server context, stupid.")
end

--[=[
    Creates Ragdoll for character with return
]=]
function module:CreateRagdoll(character: Model, opts: Types.RagdollOptions?) : RagdollClass.Ragdoll
    local ragdoll = RagdollClass.new(character, opts)
    return ragdoll
end

--[=[
    Clears character from Ragdoller's stuff
]=]
function module:ClearRagdoll(character: Model)
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local ragdoll = module:GetRagdoll(character)
    if ragdoll then
        ragdoll:UnRagdoll()
        for i, attachment: Attachment in ragdoll.RagdollAttachments do
            attachment:Destroy()
        end
        for i, joint: Instance in ragdoll.RagdollJoints do
            joint:Destroy()
        end
        for i, collider: BasePart in ragdoll.RagdollColliders do
            collider:Destroy()
        end
    elseif Players:GetPlayerFromCharacter(character) then
        RagdollRemote:FireAllClients(humanoid, false)
    else
        RagdollState:DisableRagdollState(humanoid)
    end
    for i, descendant in character:GetDescendants() do
        if descendant:HasTag("RAGDOLL_JOINT") then
            descendant:RemoveTag("RAGDOLL_JOINT")
        end
    end
    humanoid:SetAttribute("RAGDOLL_IS_RAGDOLLED", nil)
end

--[=[
    Creates a Ragdoll clone for character
]=]
function module:CreateRagdollClone(character: Model, parent: Instance, opts: Types.RagdollOptions?, cframe: CFrame?, timeout: number?)
    if not character.Archivable then
        character.Archivable = true
    end

    if not cframe then cframe = character:GetPivot() end
    local clone = character:Clone()

    if Players:GetPlayerFromCharacter(character) then
        character.Archivable = false
    end

    module:ClearRagdoll(clone)
    
    clone.Name = `{character.Name}_RAGDOLL`
    clone:PivotTo(cframe)

    clone.Parent = parent or workspace

    local cloneRagdoll = module:CreateRagdoll(clone, opts)
    module:ToggleRagdoll(clone, true)

    if timeout then
        task.delay(timeout, function()
            clone:Destroy()
        end)
    end

    return clone, cloneRagdoll
end

--[=[
    Creates a certain Ragdoll Type
]=]
function module:CreateRagdollType(
    name: string,
    rigJoints: { string | {Types.JointProperties} },
    bodyParts: { string },
    rootJoint: string
) : Types.RagdollType

    local _rigJoints = {}
    for index, value in rigJoints do
        if typeof(value) == "string" then
            _rigJoints[value] = {}
        end
    end
    
    Registry.RagdollTypes[name] = {
        Name = name,
        RigJoints = _rigJoints,
        BodyParts = bodyParts,
        RootJoint = rootJoint
    }
    return Registry.RagdollTypes[name]
end

--[=[
    Returns Ragdoll of character
]=]
function module:GetRagdoll(character: Model) : RagdollClass.Ragdoll
    local ragdoll = Registry.Ragdolls[character]
    return ragdoll
end

--[=[
    Returns Ragdoll Type of character
]=]
function module:GetRagdollType(character: Model) : Types.RagdollType
    local ragdollType = module:GetRagdoll(character).RagdollType
    return ragdollType
end

--[=[
    Returns Registry of Ragdoller
]=]
function module:GetRagdollRegistry() : {any}
    return Registry
end

--[=[
    Toggles ragdoll state of character
]=]
function module:ToggleRagdoll(character: Model, enabled: boolean)
    local ragdoll = module:GetRagdoll(character)
    if enabled then RagdollClass.Ragdoll(ragdoll) else RagdollClass.UnRagdoll(ragdoll) end
end

--[=[
    Toggles ragdoll state of character. Deprecated, but still can be used
]=]
function module:toggleRagdollCharacter(character: Model, enabled: boolean)
    module:ToggleRagdoll(character, enabled)
end

return module
