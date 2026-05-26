local Players = game:GetService("Players")
local RagdollState = require(script.RagdollState)
local RagdollData = require(script.Parent.RagdollData)
local Registry = require(script.Parent.RagdollRegistry)
local ragdoll = {}
ragdoll.__index = ragdoll

export type Ragdoll = typeof(setmetatable({} :: {
    Character: Model,
    Options: {any},
    Player: Player,
    Ragdoll: (self: {}) -> (),
    UnRagdoll: (self: {}) -> (),
    ToggleMotor6D: (self: {}, enabled: boolean) -> (),
    GetRagdollState: (self: {}) -> boolean,
    RagdollType: nil
}, ragdoll))

local DEFAULT_OPTS = RagdollData.DefaultOpts

local function formatOpts(opts: {any}?) : {any}
    if not opts then return DEFAULT_OPTS end
    for opt, value in DEFAULT_OPTS do
        if opts[opt] == nil then opts[opt] = value end
    end
    return opts
end

function ragdoll.new(character: Model, opts: {any}?) : Ragdoll
    opts = formatOpts(opts)

    local self = setmetatable({
        Character = character,
        Options = opts
    }, ragdoll)

    self.Player = Players:GetPlayerFromCharacter(self.Character)
    self.Humanoid = self.Character:FindFirstChildOfClass('Humanoid')
    self.RootPart = self.Character:FindFirstChild("HumanoidRootPart")
    self.RagdollType = nil

    self:Setup()
    return self
end


function ragdoll.Setup(self)
    self.Humanoid.BreakJointsOnDeath = self.Options.BreakJointsOnDeath
    self.Humanoid.RequiresNeck = self.Options.RequiresNeck
    self.Humanoid:SetAttribute("IS_RAGDOLL", false)

    if self.Options.RagdollType then
        self.RagdollType = Registry.RagdollTypes[self.Options.RagdollType]
    else
        self.RagdollType = Registry.RagdollTypes[self.Humanoid.RigType.Name]
    end

    Registry.Ragdolls[self.Character] = self

    self.Character.Destroying:Once(function()
        local id = table.find(Registry.Ragdolls, self)
        table.remove(Registry.Ragdolls, id)
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

        weld.Parent = ragdollCollider
        ragdollCollider.Parent = bodyPart
    end

    for motor6DName: string, jointProperties: {
        TwistAngles: {number},
        UpperAngle: number,
        JointType: string,
        LowerAngle: number
    } in self.RagdollType.Motors6D do
        local motor6D = table.unpack(self.Character:QueryDescendants(`Motor6D[Name = "{motor6DName}"]`))
        assert(motor6D, `{motor6DName} is not found`)
        local part0 = motor6D.Part0 :: BasePart
        local part1 = motor6D.Part1 :: BasePart

        local attachment0 = Instance.new("Attachment")
        attachment0.CFrame = motor6D.C0
        attachment0.Name = `RAGDOLL_ATTACHMENT_{string.upper(part1.Name:gsub(" ", "_"))}`

        local attachment1 = Instance.new("Attachment")
        attachment1.CFrame = motor6D.C1
        attachment1.Name = `RAGDOLL_ATTACHMENT_{string.upper(part1.Name:gsub(" ", "_"))}`

        attachment0.Parent = part0
        attachment1.Parent = part1

        if (jointProperties and jointProperties ~= {}) and (jointProperties.JointType and jointProperties.JointType:lower() == "hinge") then
            local ragdollHinge = Instance.new("HingeConstraint")
            ragdollHinge.Name = "RAGDOLL_HINGE"
            ragdollHinge.Attachment0 = attachment0
            ragdollHinge.Attachment1 = attachment1
            ragdollHinge:AddTag("RAGDOLL_JOINT")
            if jointProperties.UpperAngle or jointProperties.LowerAngle then
                ragdollHinge.LimitsEnabled = true
            end
            ragdollHinge.UpperAngle = jointProperties.UpperAngle or 45
            ragdollHinge.LowerAngle = jointProperties.LowerAngle or -45
            ragdollHinge.Parent = part1
        else
            local ragdollBallSocket = Instance.new("BallSocketConstraint")
            ragdollBallSocket.Name = "RAGDOLL_BALL_SOCKET"
            ragdollBallSocket.Attachment0 = attachment0
            ragdollBallSocket.Attachment1 = attachment1
            ragdollBallSocket:AddTag("RAGDOLL_JOINT")

            ragdollBallSocket.LimitsEnabled = true
            ragdollBallSocket.TwistLimitsEnabled = true

            if jointProperties and jointProperties ~= {} then
                if jointProperties.UpperAngle or jointProperties.TwistAngles then
                    ragdollBallSocket.LimitsEnabled = true
                end
                if jointProperties.TwistAngles then
                    ragdollBallSocket.TwistLimitsEnabled = true
                    ragdollBallSocket.TwistUpperAngle = jointProperties.TwistAngles[2]
                    ragdollBallSocket.TwistLowerAngle = jointProperties.TwistAngles[1]
                end
                if jointProperties.UpperAngle then
                    ragdollBallSocket.UpperAngle = jointProperties.UpperAngle
                end
            end

            ragdollBallSocket.Parent = part1
        end
    end
end

function ragdoll.ToggleMotor6D(self, enabled: boolean)
    local reservedMotors6D = self.Character:QueryDescendants(`Motor6D[Name = Neck], Motor6D[Name = "{self.RagdollType.RootJoint}"]`)

    if not self.Options.RequiresNeck then
        table.remove(reservedMotors6D, table.find(reservedMotors6D, "Neck"))
    end

    if #self.Options.IgnoredMotors6D > 0 then
        for i, motor6D in self.Options.IgnoredMotors6D do
            if typeof(motor6D) == "string" then
                local actualMotor6DTable = self.Character:QueryDescendants(`Motor6D[Name = "{motor6D}"]`)
                assert(actualMotor6DTable, `{motor6D} is not found`)
                table.remove(self.Options.IgnoredMotors6D, i)
                table.insert(self.Options.IgnoredMotors6D, table.unpack(actualMotor6DTable))
            end
        end
    end

    for _, instance in self.Character:GetDescendants() do
        if instance:IsA("Motor6D") then
            if table.find(reservedMotors6D, instance) or table.find(self.Options.IgnoredMotors6D, instance)
                or instance:HasTag("RAGDOLL_IGNORED") then
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
    ragdoll.ToggleMotor6D(self, false)
end

function ragdoll.UnRagdoll(self)
    self.Humanoid.PlatformStand = false
    if self.Player then
        local RagdollRemote = script:FindFirstChild("RagdollRemote")
        RagdollRemote:FireAllClients(self.Humanoid, false)
        self.Humanoid.AutoRotate = true
    else
        RagdollState:DisableRagdollState(self.Humanoid)
    end
    ragdoll.ToggleMotor6D(self, true)
end

function ragdoll.GetRagdollState(self) : boolean
    return self.Humanoid:GetAttribute("IS_RAGDOLL")
end

return ragdoll
