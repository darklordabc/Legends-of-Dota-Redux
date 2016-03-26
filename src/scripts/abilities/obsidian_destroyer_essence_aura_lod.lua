local toIgnore = {}

-- Generate list of abilities to ignore
(function()
    local abs = LoadKeyValues('scripts/npc/npc_abilities.txt')
    local absCustom = LoadKeyValues('scripts/npc/npc_abilities_custom.txt')

    for k,v in pairs(absCustom) do
        abs[k] = v
    end

    for abilityName,data in pairs(abs) do
        if type(data) == 'table' then
            if data.AbilityBehavior and string.match(data.AbilityBehavior, 'DOTA_ABILITY_BEHAVIOR_TOGGLE') then
                toIgnore[abilityName] = true
            end
        end
    end

    -- No items
    local items = LoadKeyValues('scripts/npc/items.txt')
    for abilityName,data in pairs(items) do
        toIgnore[abilityName] = true
    end
end)()

function RestoreMana(keys)
    local abName = keys.event_ability:GetClassname()
    if toIgnore[abName] then return true end

    -- Grab ability
    local target = keys.unit
    local ability = keys.ability

    -- Validate level
    local abLevel = ability:GetLevel()
    if abLevel <= 0 then return end

    -- Calculate how much mana to restore
    local restorePercentage = ability:GetLevelSpecialValueFor("restore_amount", abLevel -1)
    local restoreAmount = target:GetMaxMana() * restorePercentage / 100
    local newMana = target:GetMana() + restoreAmount

    -- Enforce max mana
    if newMana > target:GetMaxMana() then
        newMana = target:GetMaxMana()
    end

    -- Set the mana
    target:SetMana(newMana)

    -- Fire effects
    local prt = ParticleManager:CreateParticle('particles/units/heroes/hero_obsidian_destroyer/obsidian_destroyer_essence_effect.vpcf', PATTACH_ABSORIGIN_FOLLOW, target)
    ParticleManager:ReleaseParticleIndex(prt)

    -- Fire sound
    EmitSoundOn('Hero_ObsidianDestroyer.EssenceAura', target)
end