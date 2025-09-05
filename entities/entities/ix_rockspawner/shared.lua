AddCSLuaFile()

--[[
    Rock Spawner Configuration
    Edit these values to customize the entity behavior.
--]]
local CONFIG = {
    -- Admin-only spawning (true/false)
    AdminOnly = true,
    -- Rock health (how much damage required to break)
    RockHealth = 100,
    -- Time (in seconds) before the rock model appears after spawning
    RockSpawnTime = 6,
    -- List of possible rock models
    RockModels = {
        "models/props_wasteland/rockgranite03c.mdl",
        "models/props_wasteland/rockgranite03b.mdl",
        "models/props_wasteland/rockgranite03a.mdl",
        "models/props_wasteland/rockgranite02c.mdl",
        "models/props_wasteland/rockgranite02b.mdl",
        "models/props_wasteland/rockgranite02a.mdl"
    },
    -- Items to drop and their probabilities (total should be 100)
    Items = {
        {id = "coal", probability = 50},
        {id = "copper", probability = 15},
        {id = "iron", probability = 15},
        {id = "silver", probability = 10},
        {id = "gold", probability = 5}
    },
    -- Sound to play when the rock is broken
    BreakSound = "physics/concrete/boulder_impact_hard4.wav",
    -- A weapon that can destroy stone
    RockWeapon = "weapon_crowbar"
}

sound.Add({
    name = "rock_has_broken",
    channel = CHAN_STATIC,
    volume = 1.0,
    level = 80,
    pitch = {95, 110},
    sound = CONFIG.BreakSound
})

local function IsPositionClear(pos)
    local trace = {
        start = pos,
        endpos = pos + Vector(0, 0, 10),
        mask = MASK_SOLID_BRUSHONLY
    }
    local tr = util.TraceLine(trace)
    return not tr.Hit
end

local function SpawnRandomItem(position)
    local totalProbability = 0
    for _, item in ipairs(CONFIG.Items) do
        totalProbability = totalProbability + item.probability
    end
    local randomNumber = math.random(1, totalProbability)
    local currentProbability = 0
    local selectedItem
    for _, item in ipairs(CONFIG.Items) do
        currentProbability = currentProbability + item.probability
        if randomNumber <= currentProbability then
            selectedItem = item.id
            break
        end
    end
    if selectedItem and util.IsInWorld(position) and IsPositionClear(position) then
        ix.item.Spawn(selectedItem, position)
        print("[Rock Spawner] Item spawned: " .. selectedItem)
    else
        print("[Rock Spawner] Invalid spawn position!")
    end
end

ENT.Type = "anim"
ENT.Category = "Helix"
ENT.Spawnable = true
ENT.AdminOnly = CONFIG.AdminOnly
ENT.PrintName = "Rock Spawner"
ENT.Author = "Borsh"
ENT.Purpose = "Spawns rocks that can be broken with a crowbar to obtain resources."

function ENT:Initialize()
    self.TotalDamage = 0
    self.RockIsSpawn = false
    self.RockSpawnTime = CONFIG.RockSpawnTime
    self.RockHealth = CONFIG.RockHealth

    self:SetModel("models/props_junk/rock001a.mdl")
    self:SetMoveType(MOVETYPE_NONE)
    self:SetSolid(SOLID_VPHYSICS)

    if SERVER then
        self:SetUseType(SIMPLE_USE)
        self:SetupRockModelTimer()
    end

    local phys = self:GetPhysicsObject()
    if IsValid(phys) then
        phys:EnableMotion(false)
    end
end

function ENT:SetupRockModelTimer()
    timer.Create("RockModelChange" .. self:EntIndex(), self.RockSpawnTime, 1, function()
        if IsValid(self) and not self.RockIsSpawn then
            self:SetModel(table.Random(CONFIG.RockModels))
            self.RockIsSpawn = true
        end
    end)
end

function ENT:OnTakeDamage(dmginfo)
    if not SERVER then return end

    local attacker = dmginfo:GetAttacker()
    if not IsValid(attacker) or not attacker:IsPlayer() then return end

    local weapon = attacker:GetActiveWeapon()
    if not IsValid(weapon) or weapon:GetClass() ~= CONFIG.RockWeapon or not self.RockIsSpawn then return end

    self.TotalDamage = self.TotalDamage + dmginfo:GetDamage()
    if self.TotalDamage >= self.RockHealth then
        timer.Remove("RockModelChange" .. self:EntIndex())
        self:SetModel("models/props_junk/rock001a.mdl")
        self.RockIsSpawn = false
        self.TotalDamage = 0
        self:EmitSound("rock_has_broken")
        attacker:Notify("The rock was broken!")

        local spawnPos = self:GetPos() + Vector(0, 0, 25)
        SpawnRandomItem(spawnPos)

        self:SetupRockModelTimer()
    end
end

function ENT:OnRemove()
    timer.Remove("RockModelChange" .. self:EntIndex())
end
