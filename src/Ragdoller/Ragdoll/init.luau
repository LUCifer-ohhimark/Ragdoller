local Players = game:GetService("Players")
local RagdollState = require(script.RagdollState)
local RagdollData = require(script.Parent.RagdollData)
local Registry = require(script.Parent.RagdollRegistry)
local RagdollJoints = require(script.RagdollJoints)
local Types = require(script.Parent.Types)

local ragdoll = {}
ragdoll.__index = ragdoll

export type Ragdoll = typeof(setmetatable({} :: {
    Character: Model,
    Options: Types.RagdollOptions,
    Player: Player,
    Ragdoll: (self: {}) -> (),
    UnRagdoll: (self: {}) -> (),
    ToggleMotor6D: (self: {}, enabled: boolean) -> (),
    GetRagdollState: (self: {}) -> boolean,
    RagdollType: Types.RagdollType,
    RagdollAttachments: { Attachment },
    RagdollJoints: { any },
    RagdollColliders: { BasePart }
}, ragdoll))

local DEFAULT_OPTS = RagdollData.DefaultOpts
local DEFAULT_JOINT_PROPS = RagdollData.DefaultJointProperties

local function formatJointProperties(jointProperties: Types.JointProperties) : Types.JointProperties
    local _jointProperties = {}
    if not jointProperties then return DEFAULT_JOINT_PROPS end
    for prop, value in DEFAULT_JOINT_PROPS do
        if not jointProperties[prop] then
            _jointProperties[prop] = value
        end
    end
    for prop, value in jointProperties do
        if not _jointProperties[prop] then
            _jointProperties[prop] = jointProperties[prop]
        end
    end
    return _jointProperties
end

local function formatOpts(opts: { Types.RagdollOptions }?) : Types.RagdollOptions
    local _opts = {}
    if not opts then return DEFAULT_OPTS end
    for opt, value in DEFAULT_OPTS do
        if not opts[opt] then
            _opts[opt] = value
        end
    end

    for opt, value in opts do
        if not _opts[opt] then
            _opts[opt] = value
        end
    end

    return _opts
end

--[=[
    Creates ragdoll for character
--]=]
function ragdoll.new(character: Model, opts: { Types.RagdollOptions }?) : Ragdoll
    opts = formatOpts(opts)

    local self = setmetatable({
        Character = character,
        Options = opts,
        RagdollAttachments = {},
        RagdollJoints = {},
        RagdollColliders = {}
    }, ragdoll)

    self.Player = Players:GetPlayerFromCharacter(self.Character)
    self.Humanoid = self.Character:FindFirstChildOfClass('Humanoid')
    self.RootPart = self.Character:FindFirstChild("HumanoidRootPart")

    self:Setup()
    return self
end

function ragdoll.GetBallSocket(self, socketName: string)
    return table.unpack(self.Character:QueryDescendants(`BallSocketConstraint[Name = "{socketName}" ]`))
end

function ragdoll.GetHinge(self, hingeName: string)
    return table.unpack(self.Character:QueryDescendants(`HingeConstraint[Name = "{hingeName}" ]`))
end

function ragdoll.Setup(self)
    self.Humanoid.BreakJointsOnDeath = self.Options.BreakJointsOnDeath
    self.Humanoid.RequiresNeck = self.Options.RequiresNeck
    self.Humanoid:SetAttribute("IS_RAGDOLL", false)

    if self.Options.RagdollType then
        if typeof(self.Options.RagdollType) == "string" then
            self.RagdollType = Registry.RagdollTypes[self.Options.RagdollType]
        else
            self.RagdollType = self.Options.RagdollType
        end
    else
        self.RagdollType = Registry.RagdollTypes[self.Humanoid.RigType.Name]
    end

    Registry.Ragdolls[self.Character] = self

    self.Character.Destroying:Once(function()
        Registry.Ragdolls[self.Character] = nil
    end)

    for _, bodyPartName in self.RagdollType.BodyParts do
        local bodyPart: BasePart = self.Character:FindFirstChild(bodyPartName)
        local minSize = math.min(bodyPart.Size.X, bodyPart.Size.Y, bodyPart.Size.Z) * self.Options.ColliderSizeMultiplier
        local ragdollCollider = Instance.new("Part")
        ragdollCollider.Size = vector.create(minSize, minSize, minSize)
        ragdollCollider.Name = "RAGDOLL_COLLIDER"
        ragdollCollider.CanCollide = false
        ragdollCollider.CFrame = bodyPart.CFrame
        ragdollCollider.Transparency = 1
        ragdollCollider:AddTag("RAGDOLL_COLLIDER")

        local weld = Instance.new("WeldConstraint")
        weld.Name = "RAGDOLL_WELD"
        weld.Part0 = ragdollCollider
        weld.Part1 = bodyPart

        table.insert(self.RagdollColliders, ragdollCollider)

        weld.Parent = ragdollCollider
        ragdollCollider.Parent = bodyPart
    end

    for rigJointName: string, jointProperties: Types.JointProperties in self.RagdollType.RigJoints do
        jointProperties = formatJointProperties(jointProperties)
        local attachment0, attachment1, _part0, part1
        local ragdollJoint
        local rigJoint = table.unpack(self.Character:QueryDescendants(`Motor6D[Name = "{rigJointName}"]`)) or table.unpack(self.Character:QueryDescendants(`AnimationConstraint[Name = "{rigJointName}"]`))

        if not jointProperties.Name then
            local formattedName = rigJoint.Name:gsub(" ", "_") 
            if jointProperties.JointType:lower() == "hinge" then
                jointProperties.Name = `RAGDOLL_HINGE_{string.upper(formattedName)}`
            elseif jointProperties.JointType:lower() == "ballsocket" then
                jointProperties.Name = `RAGDOLL_BALL_SOCKET_{string.upper(formattedName)}`
            end
        end

        if rigJoint:IsA("AnimationConstraint") then
            attachment0 = rigJoint.Attachment0
            attachment1 = rigJoint.Attachment1
            ragdollJoint = self.GetBallSocket(self, jointProperties.Name)
            if ragdollJoint then
                ragdollJoint:AddTag("RAGDOLL_JOINT")
            end
        else
            attachment0, attachment1, _part0, part1 = RagdollJoints:MakeRagdollAttachments(rigJoint)
            table.insert(self.RagdollAttachments, attachment0)
            table.insert(self.RagdollAttachments, attachment1)
            ragdollJoint = self.GetBallSocket(self, jointProperties.Name) or self.GetHinge(self, jointProperties.Name)

            if ragdollJoint then
                ragdollJoint:AddTag("RAGDOLL_JOINT")
            else
                if jointProperties.JointType:lower() == "hinge" then
                    ragdollJoint = RagdollJoints:MakeHinge(attachment0, attachment1, jointProperties.Name, part1, jointProperties)
                    table.insert(self.RagdollJoints, ragdollJoint)
                elseif jointProperties.JointType:lower() == "ballsocket" then
                    ragdollJoint = RagdollJoints:MakeBallSocket(attachment0, attachment1, jointProperties.Name, part1, jointProperties)
                    table.insert(self.RagdollJoints, ragdollJoint)
                end
            end
        end
    end
end

function ragdoll.ToggleRigJoint(self, enabled: boolean)
    local reservedMotors6D = self.Character:QueryDescendants(
        `Motor6D[Name = Neck], Motor6D[Name = "{self.RagdollType.RootJoint}"], AnimationConstraint[Name = Neck], AnimationConstraint[Name = "{self.RagdollType.RootJoint}"]`
    )

    if not self.Options.RequiresNeck then
        table.remove(reservedMotors6D, table.find(reservedMotors6D, "Neck"))
    end

    if #self.Options.IgnoredMotors6D > 0 then
        local actualMotor6DTable = {}
        for i, motor6D in self.Options.IgnoredMotors6D do
            if typeof(motor6D) == "string" then
                local motors6D = self.Character:QueryDescendants(`Motor6D[Name = "{motor6D}"]`)
                assert(motors6D, `{motor6D} is not found`)
                for i, v in motors6D do
                    table.insert(actualMotor6DTable, v)
                end
            end
        end
        table.clear(self.Options.IgnoredMotors6D)
        self.Options.IgnoredMotors6D = actualMotor6DTable
    end
    
    if #self.Options.IgnoredRigJoints > 0 then
        local actualRigJointTable = {}
        for i, rigJoint in self.Options.IgnoredRigJoints do
            if typeof(rigJoint) == "string" then
                local rigJoints = self.Character:QueryDescendants(`Motor6D[Name = "{rigJoint}"], AnimationConstraint[Name = "{rigJoint}"]`)
                assert(rigJoints, `{rigJoint} is not found`)
                for i, v in rigJoints do
                    table.insert(actualRigJointTable, v)
                end
            end
        end
        table.clear(self.Options.IgnoredRigJoints)
        self.Options.IgnoredRigJoints = actualRigJointTable
    end

    for _, instance in self.Character:GetDescendants() do
        if instance:IsA("Motor6D") or instance:IsA("AnimationConstraint") then
            if table.find(reservedMotors6D, instance) or table.find(self.Options.IgnoredMotors6D, instance) or table.find(self.Options.IgnoredRigJoints, instance) or instance:HasTag("RAGDOLL_IGNORED") then
                continue
            end
            instance.Enabled = enabled
        end

        if instance:IsA("BasePart") and instance:HasTag("RAGDOLL_COLLIDER") then
            if table.find(self.Options.NoCollideBodyParts, instance.Parent.Name) or instance.Parent:HasTag("RAGDOLL_NO_COLLISION") then
                instance.CanCollide = false
            else
                instance.CanCollide = not enabled
            end
        end

        if (instance:IsA("BallSocketConstraint") or instance:IsA("HingeConstraint")) and instance:HasTag("RAGDOLL_JOINT") then
            instance.Enabled = not enabled
        end
    end
end

--[=[
    Enables ragdoll state for character
]=]
function ragdoll.Ragdoll(self)
    self.Humanoid.PlatformStand = true
    if self.Player then
        local RagdollRemote = script:FindFirstChild("RagdollRemote")
        RagdollRemote:FireAllClients(self.Humanoid, true)
        self.Humanoid.AutoRotate = false
    else
        self.RootPart:SetNetworkOwner(nil)
        RagdollState:EnableRagdollState(self.Humanoid)
    end
    ragdoll.ToggleRigJoint(self, false)
end

--[=[
    Disables ragdoll state for character
]=]
function ragdoll.UnRagdoll(self)
    self.Humanoid.PlatformStand = false
    if self.Player then
        local RagdollRemote = script:FindFirstChild("RagdollRemote")
        RagdollRemote:FireAllClients(self.Humanoid, false)
        self.Humanoid.AutoRotate = true
    else
        RagdollState:DisableRagdollState(self.Humanoid)
    end
    ragdoll.ToggleRigJoint(self, true)
end

--[=[
    Returns ragdoll state for character
]=]
function ragdoll.GetRagdollState(self) : boolean
    return self.Humanoid:GetAttribute("RAGDOLL_IS_RAGDOLLED")
end

return ragdoll
