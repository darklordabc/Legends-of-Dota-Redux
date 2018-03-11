local toIgnore = util:getToggleIgnores()

function TryAftershock(keys)
    local abName = keys.event_ability:GetAbilityName()
    
    if toIgnore[abName] then return true end

    -- Calculate how much mana to restore
    local target = keys.unit
    local ability = keys.ability
	local caster = keys.caster
	
	if caster:PassivesDisabled() then return end 

    -- Ensure the cooldown is completed
    if not ability:IsCooldownReady() then return end

    -- Validate level
    local abLevel = ability:GetLevel()
    if abLevel <= 0 then return end

    -- Start the cooldown
    Timers:CreateTimer(function()
        local abCooldown = keys.event_ability:GetCooldownTimeRemaining()
        if abCooldown < 5 then
            ability:StartCooldown(5)
        end                                    
    end, DoUniqueString('cooldown'), 0.5)

    local abRange = ability:GetLevelSpecialValueFor('aftershock_range', abLevel - 1)
    local abDuration = ability:GetLevelSpecialValueFor('tooltip_duration', abLevel - 1)
    local abDamage = ability:GetAbilityDamage()

    -- Find the targets
    local units = FindUnitsInRadius(
        target:GetTeam(),
        target:GetOrigin(),
        nil,
        abRange,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP,
        DOTA_UNIT_TARGET_FLAG_NONE,
        FIND_ANY_ORDER,
        false
    )

    -- Loop over targets
	local abType = ability:GetAbilityDamageType()
	if not abType then abType = DAMAGE_TYPE_MAGICAL end
    for k,unit in pairs(units) do
        -- Apply stun
        unit:AddNewModifier(target, ability, 'modifier_stunned', {
            duration = abDuration
        })

        -- Apply damage
        ApplyDamage({
            victim = unit,
            attacker = target,
            damage = abDamage,
            damage_type = abType
        })
    end

    -- Fire effects
    local prt = ParticleManager:CreateParticle('particles/units/heroes/hero_earthshaker/earthshaker_aftershock.vpcf', PATTACH_ABSORIGIN_FOLLOW, target)
    ParticleManager:SetParticleControl(prt, 1, Vector(100, 0, 0))
    ParticleManager:ReleaseParticleIndex(prt)
end
