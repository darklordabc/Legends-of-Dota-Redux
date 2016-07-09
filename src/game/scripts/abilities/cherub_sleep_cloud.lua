function SleepDamageCheck( keys )
    local caster = keys.caster
    local target = keys.unit
    local ability = keys.ability
    local threshold = ability:GetLevelSpecialValueFor("damage_to_wake", (ability:GetLevel() - 1))
    local damage = keys.DamageTaken
    if totalDamage == nil then totalDamage = 0 end
    
    totalDamage = totalDamage + damage
    if totalDamage >= threshold then
        target:RemoveModifierByName("modifier_sleep_cloud_aura")
        target:RemoveModifierByName("modifier_sleep_cloud_effect")
        totalDamage = 0
    end
end

function SleepDamageRemove( keys )
    local caster = keys.caster
    local target = keys.unit
    totalDamage = 0
end

function SleepAuraCheck( keys )
    if not keys.target:HasModifier("modifier_sleep_cloud_aura") then
        keys.target:RemoveModifierByName("modifier_sleep_cloud_effect")
    end
end