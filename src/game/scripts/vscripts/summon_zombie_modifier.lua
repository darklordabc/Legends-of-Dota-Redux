summon_zombie_modifier = class ({})

--------------------------------------------------------------------------------

function summon_zombie_modifier:IsHidden()
    return true
end

function summon_zombie_modifier:OnCreated()	
    local ability = self:GetAbility()
    local caster = self:GetCaster()

    self.spawn_delay = 4
    self.max_spawned = -1
    self.num_to_spawn = 1
    self.caster = self:GetCaster()

    self.caster.numSpawned = 0
    self.level = 0

    self:StartIntervalThink(self.spawn_delay)
end

--------------------------------------------------------------------------------

function summon_zombie_modifier:OnIntervalThink()
    if IsServer() then
        local caster = self:GetCaster()
        local ability = self:GetAbility()
        local center = caster:GetAbsOrigin()

        if not caster:IsAlive() then
            self:Destroy()
            return
        end

        self.level = self:GetCaster():GetLevel()

        for i=1,self.num_to_spawn do
			if self:GetCaster():IsIllusion() == false then
				self:AttemptToSpawnZombie()
				--EmitSoundOn( "Hero_Undying.Tombstone", self:GetCaster() )
			end
        end
    end
end

--------------------------------------------------------------------------------

function summon_zombie_modifier:AttemptToSpawnZombie()
    self.caster.numSpawned = self.caster.numSpawned + 1
	local caster = self:GetCaster()

    if self.caster.numSpawned > self.max_spawned then
    if util:isPlayerBot(caster:GetPlayerID()) and math.random(1,15) == 1 then
            local zombie = CreateUnitByName("custom_creature_zombie_large", self:GetCaster():GetAbsOrigin(), true, nil, nil, self:GetCaster():GetTeamNumber())
            zombie:AddNewModifier(zombie, nil, "modifier_phased", {Duration = Duration})
            zombie.spawner = self.caster
            zombie:CreatureLevelUp(self.level)
        else
            local zombie = CreateUnitByName("custom_creature_zombie", self:GetCaster():GetAbsOrigin(), true, nil, nil, self:GetCaster():GetTeamNumber())
            zombie:AddNewModifier(zombie, nil, "modifier_phased", {Duration = Duration})
            zombie.spawner = self.caster
            zombie:CreatureLevelUp(self.level)
        end

    end
end