function SynthesisCreate( keys )
    local caster = keys.caster
    local ability = keys.ability
    day = GameRules:IsDaytime()
    
    if day == true then
        ability:ApplyDataDrivenModifier(caster, caster, "modifier_synthesis_day", {})
    else
        ability:ApplyDataDrivenModifier(caster, caster, "modifier_synthesis_night", {})
    end
end

function SynthesisCheck( keys )
    local caster = keys.caster
    local ability = keys.ability
    local dayCheck = GameRules:IsDaytime()
    
    if day ~= dayCheck and dayCheck == false then
        day = GameRules:IsDaytime()
        ability:ApplyDataDrivenModifier(caster, caster, "modifier_synthesis_night", {})
    elseif day ~= dayCheck and dayCheck == true then
        day = GameRules:IsDaytime()
        ability:ApplyDataDrivenModifier(caster, caster, "modifier_synthesis_day", {})
    end

end

function SynthesisDay( keys )
    local caster = keys.caster
    local ability = keys.ability
    local interval = ability:GetLevelSpecialValueFor( "think_interval", ( ability:GetLevel() - 1 ) )
    local health = ability:GetLevelSpecialValueFor( "base_conversion_rate", ( ability:GetLevel() - 1 ) ) * interval
    local mana = ability:GetLevelSpecialValueFor( "health_to_mana", ( ability:GetLevel() - 1 ) ) 
    local restoreAmount = (mana/100) * health
    
    if caster:GetHealth() > health and caster:GetManaPercent() < 100 then
        caster:ModifyHealth( caster:GetHealth() - health, ability, false, 0 )
        caster:GiveMana( restoreAmount )
    elseif caster:GetHealth() > health then
    else
        ability:ToggleAbility()
    end
end

function SynthesisNight( keys )
    local caster = keys.caster
    local ability = keys.ability
    local interval = ability:GetLevelSpecialValueFor( "think_interval", ( ability:GetLevel() - 1 ) )
    local mana = ability:GetLevelSpecialValueFor( "base_conversion_rate", ( ability:GetLevel() - 1 ) ) * interval
    local health = ability:GetLevelSpecialValueFor( "mana_to_health", ( ability:GetLevel() - 1 ) )
    
    local healAmount = (health/100) * mana
    
    if caster:GetMana() >= mana and caster:GetHealthPercent() < 100 then
        caster:SpendMana( mana, ability )
        caster:Heal( healAmount, caster )
    elseif caster:GetHealthPercent() == 100 then
    else
        ability:ToggleAbility()
    end
end