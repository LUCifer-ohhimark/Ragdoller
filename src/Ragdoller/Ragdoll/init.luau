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
    GetRagdollState: (self: {}) -> boolean
}, ragdoll))

local DEFAULT_OPTS = RagdollData.DefaultOpts

local function formatOpts(opts: {any}?)
    if not opts then return DEFAULT_OPTS end
    for opt, value in DEFAULT_OPTS do
        if opts[opt] == nil then opts[opt] = value end
    end

    return opts
end

function ragdoll.new(character: Model, opts: {any}?)
    opts = formatOpts(opts)

    local self = setmetatable({
        Character = character,
        Options = opts
    }, ragdoll)

    self.Player = Players:GetPlayerFromCharacter(self.Character)

    self.Humanoid = self.Character:FindFirstChildOfClass('Humanoid')

    self.RootPart = self.Character:FindFirstChild("HumanoidRootPart")
    self.Torso = self.Character:FindFirstChild("Torso")

    self:Setup()
    return self
end


function ragdoll.Setup(self)
    self.Humanoid.BreakJointsOnDeath = self.Options.BreakJointsOnDeath
    self.Humanoid.RequiresNeck = self.Options.RequiresNeck
    self.Humanoid:SetAttribute("IS_RAGDOLL", false)

    Registry[self.Character] = self

    self.Character.Destroying:Once(function()
        local id = table.find(Registry, self)
        table.remove(Registry, id)
    end)

    for _, v in RagdollData.BodyParts_R6 do
        local bodyPart: BasePart = self.Character:FindFirstChild(v)
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

    for _, v in RagdollData.Motors6D_R6 do
        local motor6D: Motor6D = self.Torso:FindFirstChild(v)
        local part1 = motor6D.Part1 :: BasePart

        local attachment0 = Instance.new("Attachment")
        attachment0.CFrame = motor6D.C0
        attachment0.Name = `RAGDOLL_ATTACHMENT_{string.upper(part1.Name:gsub(" ", "_"))}`

        local attachment1 = Instance.new("Attachment")
        attachment1.CFrame = motor6D.C1
        attachment1.Name = `RAGDOLL_ATTACHMENT_{string.upper(part1.Name:gsub(" ", "_"))}`

        local ragdollBallSocket = Instance.new("BallSocketConstraint")
        ragdollBallSocket.Name = "RAGDOLL_BALL_SOCKET"
        ragdollBallSocket.Attachment0 = attachment0
        ragdollBallSocket.Attachment1 = attachment1
        ragdollBallSocket:AddTag("RAGDOLL_BALL_SOCKET")

        ragdollBallSocket.LimitsEnabled = true
        ragdollBallSocket.TwistLimitsEnabled = true
        ragdollBallSocket.TwistUpperAngle = 45
        ragdollBallSocket.TwistLowerAngle = -45

        ragdollBallSocket.UpperAngle = part1 == self.Character:FindFirstChild("Head") and 45 or 90

        attachment0.Parent = self.RootPart
        attachment1.Parent = part1
        ragdollBallSocket.Parent = part1
    end
end

function ragdoll.ToggleMotor6D(self, enabled: boolean)
    local reservedMotors6D = {self.RootPart:FindFirstChild("RootJoint")}
    local neck: Motor6D = self.Torso:FindFirstChild("Neck")

    if self.Options.RequiresNeck then
        table.insert(reservedMotors6D, neck)
    else
        local id = table.find(reservedMotors6D, neck)
        if id then table.remove(reservedMotors6D, id) end
    end

    if #self.Options.IgnoredMotors6D > 0 then
        for i, motor6D in self.Options.IgnoredMotors6D do
            if typeof(motor6D) == "string" then
                local actualMotor6DTable = self.Character:QueryDescendants(`Motor6D[Name = {motor6D}]`)
                assert(actualMotor6DTable, `{motor6D} is not found`) 
                table.remove(self.Options.IgnoredMotors6D, i)
                table.insert(self.Options.IgnoredMotors6D, table.unpack(actualMotor6DTable))
            end
        end
    end

    local limbs = {
        self.Character["Left Arm"],
        self.Character["Right Arm"],
        self.Character["Left Leg"],
        self.Character["Right Leg"]
    }

    for _, instance in self.Character:GetDescendants() do
        if instance:IsA("Motor6D") then
            if table.find(reservedMotors6D, instance) or table.find(self.Options.IgnoredMotors6D, instance)
                or instance:HasTag("RAGDOLL_IGNORED") then
                continue 
            end
            instance.Enabled = enabled
        end

        if instance:IsA("BasePart") and instance:HasTag("RAGDOLL_COLLIDER") then
            if table.find(limbs, instance.Parent) and not self.Options.LimbsCollidersEnabled then
                instance.CanCollide = false
            else
                instance.CanCollide = not enabled
            end
        end

        if instance:IsA("BallSocketConstraint") and instance:HasTag("RAGDOLL_BALL_SOCKET") then
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

function ragdoll.GetRagdollState(self)
    return self.Humanoid:GetAttribute("IS_RAGDOLL")
end

return ragdoll
