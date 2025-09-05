AddCSLuaFile()

ENT.Type = "anim"
ENT.Category = "Helix"
ENT.Spawnable = true
ENT.AdminOnly = true
ENT.PrintName = "Rock Spawner"
ENT.Author = "Borsh"
ENT.Purpose = ""

local items = {
    {id = "coal", probability = 50},
    {id = "copper", probability = 15},
    {id = "iron", probability = 15},
    {id = "silver", probability = 10},
    {id = "gold", probability = 5}
}

sound.Add( {
	name = "rock_hasb_broken",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 80,
	pitch = {95, 110},
	sound = "physics/concrete/boulder_impact_hard4.wav"
} )

local rockModels = {
    "models/props_wasteland/rockgranite03c.mdl",
    "models/props_wasteland/rockgranite03b.mdl",
    "models/props_wasteland/rockgranite03a.mdl",
    "models/props_wasteland/rockgranite02c.mdl",
    "models/props_wasteland/rockgranite02b.mdl",
    "models/props_wasteland/rockgranite02a.mdl"
}

local function SpawnRandomItem(position)
    local totalProbability = 0
    for _, item in ipairs(items) do
        totalProbability = totalProbability + item.probability
    end

    local randomNumber = math.random(totalProbability)
    local currentProbability = 0
    local selectedItem

    for _, item in ipairs(items) do
        currentProbability = currentProbability + item.probability
        if randomNumber <= currentProbability then
            selectedItem = item.id
            break
        end
    end

    ix.item.Spawn(selectedItem, position)
end

function ENT:Initialize()
    self.TotalDamage = 0
    self.RockIsSpawn = false
    self.RockSpawnTime = 120
    self.RockHealth = 1250

	self:SetModel("models/props_junk/rock001a.mdl")
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_VPHYSICS)

	if SERVER then
		self:SetUseType(SIMPLE_USE)

        timer.Create("RockModelChange" .. self:EntIndex(), self.RockSpawnTime, 1, function()
            if IsValid(self) and not self.RockIsSpawn then
                timer.Remove("RockModelChange" .. self:EntIndex())
                self:SetModel(table.Random(rockModels))
                self.RockIsSpawn = true
            end
        end)
	end

	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:EnableMotion(false)
	end
end

function ENT:OnTakeDamage(dmginfo)
    -- print(dmginfo:GetAttacker():GetActiveWeapon():GetClass())
    -- print(dmginfo:GetDamage())
    -- print(self.RockIsSpawn)
    -- print(self.TotalDamage)
    -- print(dmginfo:GetDamageType())

    if dmginfo:GetDamageType() == DMG_SLASH and dmginfo:GetAttacker():GetActiveWeapon():GetClass() == "tfa_nmrih_pickaxe" and self.RockIsSpawn then
        self.TotalDamage = self.TotalDamage + dmginfo:GetDamage()
        -- print(self.TotalDamage)

        if self.TotalDamage >= self.RockHealth then
            timer.Remove("RockModelChange" .. self:EntIndex())
            self:SetModel("models/props_junk/rock001a.mdl")
            self.RockIsSpawn = false
            self.TotalDamage = 0
            self:EmitSound("rock_hasb_broken")
            dmginfo:GetAttacker():Notify("The rock was broken")
            SpawnRandomItem(Vector(self:GetPos().x, self:GetPos().y, self:GetPos().z + 25))

            timer.Create("RockModelChange" .. self:EntIndex(), self.RockSpawnTime, 1, function()
                if IsValid(self) and not self.RockIsSpawn then
                    timer.Remove("RockModelChange" .. self:EntIndex())
                    self:SetModel(table.Random(rockModels))
                    self.RockIsSpawn = true
                end
            end)
        end
    end
end

function ENT:OnRemove()
    timer.Remove("RockModelChange" .. self:EntIndex())
end
