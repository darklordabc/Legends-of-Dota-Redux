LinkLuaModifier("modifier_mana_laser", "abilities/mana_laser.lua", LUA_MODIFIER_MOTION_NONE)
--if IsServer() then PrecacheItemByNameAsync("particles/other/tinker_laser.vpcf", function() end) end

mana_laser = {}
mana_laser.__index = mana_laser
function mana_laser.new(construct, ...)
    local instance = setmetatable({}, mana_laser)
    if construct and mana_laser.constructor then mana_laser.constructor(instance, ...) end
    return instance
end
function mana_laser.GetIntrinsicModifierName(self)
    return "modifier_mana_laser"
end
function mana_laser.GetCastRange(self)
    if IsClient() then
        return self.GetSpecialValueFor(self,"search_radius")
    end
end
function mana_laser.GetGoldCost(self)
    return self.GetSpecialValueFor(self,"gold_cost")
end
function mana_laser.OnSpellStart(self)
    local caster = self.GetCaster(self)
    local modifier = caster.SetModifierStackCount(caster,"modifier_mana_laser",caster,caster.GetModifierStackCount(caster,"modifier_mana_laser",caster)+1)
end
function mana_laser.OnProjectileHit_ExtraData(self,target,location,data)
    if target then
        if data.nProjectileNumber == 1 then
            self["targets"] = {}
        end
        --self["targets"] = self[targets] or {}
        table.insert(self["targets"],target)
        local max_bounces = self:GetSpecialValueFor("max_bounces")
        local caster = self.GetCaster(self)
        caster.EmitSound(caster,"Hero_Tinker.LaserImpact")
        ApplyDamage({
            damage=(1-((1/max_bounces) * (data.nProjectileNumber-1)))*(self.GetSpecialValueFor(self,"laser_damage")*caster.GetMana(caster))/caster.GetMaxMana(caster),
            ability=self,
            victim=target,
            attacker=caster,
            damage_type=DAMAGE_TYPE_MAGICAL
        })
        if caster:HasScepter() and data.nProjectileNumber < 4 then
            local range = self.GetSpecialValueFor(self,"search_radius")
            local units = FindUnitsInRadius(caster.GetTeamNumber(caster),target.GetAbsOrigin(caster),nil,range,DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC,DOTA_UNIT_TARGET_FLAG_NONE,FIND_ANY_ORDER,false)
            for _,unit in pairs(units) do
                --local unit = units[i+1]
                if not self["targets"][unit] then
                    local projectile_speed = 3000
                    if unit.IsHero(unit) then
                        projectile_speed=(caster.GetRangeToUnit(caster,unit)*2)
                    end
                    caster:EmitSoundParams("Hero_Tinker.Laser",1,0.25,1)
                    ProjectileManager.CreateTrackingProjectile(ProjectileManager,{Target=unit,vSourceLoc=unit:GetAbsOrigin(),Source=unit,Ability=self,EffectName="particles/other/tinker_laser.vpcf",bDodgeable=true,iMoveSpeed=projectile_speed,ExtraData = {nProjectileNumber = data.nProjectileNumber+1}})
                    break
                end
            end
        end
    end
    return true
end
modifier_mana_laser = {}
modifier_mana_laser.__index = modifier_mana_laser
function modifier_mana_laser.new(construct, ...)
    local instance = setmetatable({}, modifier_mana_laser)
    if construct and modifier_mana_laser.constructor then modifier_mana_laser.constructor(instance, ...) end
    return instance
end
function modifier_mana_laser.OnCreated(self)
    if IsServer() then
        self.SetStackCount(self,0)
        self.ability=self.GetAbility(self)
        self.StartIntervalThink(self,FrameTime())
    end
end
function modifier_mana_laser.OnIntervalThink(self)
    local caster = self.GetCaster(self)
    if (not caster:IsAlive()) or (caster:PassivesDisabled()) or (not caster:IsRealHero()) then return end

    if self.ability.IsCooldownReady(self.ability) then
        local range = self.ability.GetSpecialValueFor(self.ability,"search_radius")
        local units = FindUnitsInRadius(caster.GetTeamNumber(caster),caster.GetAbsOrigin(caster),nil,range,DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC,DOTA_UNIT_TARGET_FLAG_NONE,FIND_ANY_ORDER,false)
        for _,unit in pairs(units) do
            --local unit = units[i+1]
            if caster:CanEntityBeSeenByMyTeam(unit) then
                local projectile_speed = 3000
                if unit.IsHero(unit) then
                    projectile_speed=(caster.GetRangeToUnit(caster,unit)*2)
                end
                caster:EmitSoundParams("Hero_Tinker.Laser",1,0.25,1)
                ProjectileManager.CreateTrackingProjectile(ProjectileManager,{Target=unit,Source=caster,Ability=self.ability,EffectName="particles/other/tinker_laser.vpcf",bDodgeable=true,iMoveSpeed=projectile_speed,ExtraData = {nProjectileNumber = 1}})
                self.ability.StartCooldown(self.ability,self.ability.GetCooldown(self.ability,-1))
                local cd = self.ability.GetCooldownTimeRemaining(self.ability)
                self.ability.EndCooldown(self.ability)
                self.ability.StartCooldown(self.ability,cd/(self.GetStackCount(self)+1))
                break
            end
        end
    end
end
