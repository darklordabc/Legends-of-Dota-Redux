function checkHealth( event )
    local caster = event.caster
    local ability = event.ability
    local cooldown = ability:GetCooldown(ability:GetLevel() - 1)
    local stacks = ability:GetLevelSpecialValueFor( "stacks", ability:GetLevel() - 1 )

    if caster:GetHealth() == 1 then
        ability:ApplyDataDrivenModifier(caster, caster, "modifier_hylonome_laceration_buff", {})
        caster:RemoveModifierByName("modifier_hylonome_check_health")

        ability:StartCooldown(cooldown)
        ability:ApplyDataDrivenModifier(caster, caster, "modifier_hylonome_laceration_cooldown", {})
        ability:ApplyDataDrivenModifier(caster, caster, "modifier_hylonome_laceration_stack", {})
        caster:SetModifierStackCount("modifier_hylonome_laceration_stack", ability, stacks)
    end
end

function removeStack(keys)
    local caster = keys.caster
    local ability = keys. ability
    local modifier = "modifier_hylonome_laceration_stack"
    local stacks = caster:GetModifierStackCount(modifier, ability)
    
    -- Ensures the caster is affected by the modifier
    if caster:HasModifier(modifier) then
        caster:SetModifierStackCount(modifier, ability, stacks - 1)
        stacks = caster:GetModifierStackCount(modifier, ability)

        -- If all stacks are gone, we remove the modifier
        if stacks == 0 then
            caster:RemoveModifierByName("modifier_hylonome_laceration_buff")
        end
    end
end

function reapplyAbility( event )
    local caster = event.caster
    local ability = event.ability
    ability:ApplyDataDrivenModifier(caster, caster, "modifier_hylonome_check_health", {})
end