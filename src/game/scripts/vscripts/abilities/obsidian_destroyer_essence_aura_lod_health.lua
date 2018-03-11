local toIgnore = util:getToggleIgnores()

function RestoreMana(keys)
    local abName = keys.event_ability:GetAbilityName()
    if toIgnore[abName] then return true end

    -- Grab ability
    local target = keys.unit
    local ability = keys.ability
	local caster = keys.caster
	
	if caster:PassivesDisabled() then return end
	
    -- Validate level
    local abLevel = ability:GetLevel()
    if abLevel <= 0 then return end

    -- Calculate how much mana to restore
    local restorePercentage = ability:GetLevelSpecialValueFor("restore_amount", abLevel -1)
    local restoreAmount = target:GetMaxHealth() * restorePercentage / 100
    local newHealth = target:GetHealth() + restoreAmount

    -- Enforce max mana
    if newHealth > target:GetMaxHealth() then
        newHealth = target:GetMaxHealth()
    end

    -- Set the mana
    target:SetHealth(newHealth)

    -- Fire effects
    local prt = ParticleManager:CreateParticle('particles/items2_fx/urn_of_shadows_heal_c.vpcf', PATTACH_ABSORIGIN_FOLLOW, target)
    ParticleManager:ReleaseParticleIndex(prt)

    -- Fire sound
    EmitSoundOn('Hero_ObsidianDestroyer.EssenceAura', target)
end
