--[[	Author: D2imba
		Date: 23.05.2015	]]
require('lib/util_imba')

function PurificationDeath( keys )
    local caster = keys.caster
    local ability = keys.ability
    local ability_level = ability:GetLevel() - 1

    if not caster:IsRealHero() then return nil end
    
    -- If fatal damage was not dealt, do nothing
    if caster:GetHealth() >= 2 or not ability:IsCooldownReady() then
        return nil
    else
        caster:SetHealth(2)
    end

    -- Effects
    local cast_sound = keys.cast_sound
    local aoe_particle = keys.aoe_particle
    local cast_particle = keys.cast_particle
    local hit_particle = keys.hit_particle

    -- Parameters
    local heal_base = ability:GetLevelSpecialValueFor("heal_base", ability_level)
    local heal_pct = ability:GetLevelSpecialValueFor("heal_pct", ability_level) * 0.01
    local damage_factor = ability:GetLevelSpecialValueFor("damage_factor", ability_level) * 0.01
    local radius = ability:GetLevelSpecialValueFor("radius", ability_level)
    local passive_modifier = keys.passive_modifier
    
    local caster_pos = caster:GetAbsOrigin()
    local passive_cooldown = ability:GetTrueCooldown()

    -- Increase healing based on the caster's health
    local heal = heal_base + caster:GetMaxHealth() * heal_pct

    -- Heal the caster
    caster:Heal(heal, caster)
    SendOverheadEventMessage(nil, OVERHEAD_ALERT_HEAL, caster, heal, nil)

    -- Play cast sound and particles
    EmitSoundOn("Hero_Omniknight.Purification", caster)
    local aoe_pfx = ParticleManager:CreateParticle(aoe_particle, PATTACH_ABSORIGIN_FOLLOW, caster)
    ParticleManager:SetParticleControl(aoe_pfx, 0, caster_pos)
    ParticleManager:SetParticleControl(aoe_pfx, 1, Vector(radius, 1, 1))
    ParticleManager:ReleaseParticleIndex(aoe_pfx)
    local caster_pfx = ParticleManager:CreateParticle(cast_particle, PATTACH_ABSORIGIN_FOLLOW, caster)
    ParticleManager:SetParticleControlEnt(caster_pfx, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
    ParticleManager:SetParticleControl(caster_pfx, 1, caster_pos)
    ParticleManager:ReleaseParticleIndex(caster_pfx)

    -- Calculate damage
    local damage = heal * damage_factor

    -- Damage nearby enemies
    local enemies = FindUnitsInRadius(caster:GetTeamNumber(), caster_pos, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)
    for _,enemy in pairs(enemies) do
        ApplyDamage({attacker = caster, victim = enemy, ability = ability, damage = damage, damage_type = DAMAGE_TYPE_PURE})

        -- Play particle    
        local hit_pfx = ParticleManager:CreateParticle(hit_particle, PATTACH_ABSORIGIN_FOLLOW, enemy)
        ParticleManager:SetParticleControlEnt(hit_pfx, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster_pos, true)
        ParticleManager:SetParticleControlEnt(hit_pfx, 1, enemy, PATTACH_POINT_FOLLOW, "attach_hitloc", enemy:GetAbsOrigin(), true)
        ParticleManager:SetParticleControl(hit_pfx, 3, Vector(radius, 0, 0))
        ParticleManager:ReleaseParticleIndex(hit_pfx)
    end

    -- Put ability on cooldown
    ability:StartCooldown(passive_cooldown)
end

function DisplayManager(keys)
    local caster = keys.caster
    local ability = keys.ability
    
    if caster:HasModifier("modifier_phoenix_supernova_hiding") then
        ability:StartCooldown(2)
    end

    if keys.caster:HasModifier(keys.modifier_display) and not keys.ability:IsCooldownReady() then
        keys.caster:RemoveModifierByName(keys.modifier_display)
    elseif not keys.caster:HasModifier(keys.modifier_display) and keys.ability:IsCooldownReady() then
        keys.ability:ApplyDataDrivenModifier(keys.caster, keys.caster, keys.modifier_display, {})
    end
end

function DegenAura( keys )
    local caster = keys.caster
    local target = keys.target
    local ability = keys.ability
    local ability_level = ability:GetLevel() - 1
    local modifier_stacks = keys.modifier_stacks
	
	if caster:PassivesDisabled() then return end
    -- Parameters
    local stack_reduction_pct = ability:GetLevelSpecialValueFor("stack_reduction_pct", ability_level)
    
    -- Refreshes the debuff and adds stacks
    AddStacks(ability, caster, target, modifier_stacks, stack_reduction_pct, true)
end
