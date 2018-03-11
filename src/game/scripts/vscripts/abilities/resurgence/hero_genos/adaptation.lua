LinkLuaModifier("modifier_adaptation_counter", "heroes/hero_genos/modifiers/modifier_adaptation_counter.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_bioweapon_adaptations", "heroes/hero_genos/modifiers/modifier_bioweapon_adaptations.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_flight_instinct_adaptations", "heroes/hero_genos/modifiers/modifier_flight_instinct_adaptations.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_aquired_immunity_adaptations", "heroes/hero_genos/modifiers/modifier_aquired_immunity_adaptations.lua", LUA_MODIFIER_MOTION_NONE)

--[[Author: TheGreatGimmick
    Date: April 8, 2017
    ]]

--Initialize modifiers and their stacks  
function InitializeModifiers( event )
	local caster = event.caster

    local check = caster:FindModifierByName("modifier_adaptation_counter")
    if not check then
        print('')
        print('Initializing Modifiers')

        local ability = event.ability

        local q = caster:FindAbilityByName("genos_bioweapon")
        local w = caster:FindAbilityByName("genos_flight_instinct")
        local e = caster:FindAbilityByName("genos_aquired_immunity")  

        --initialize modifiers
     
        local modifierName = "modifier_adaptation_counter"
        caster:AddNewModifier(caster, ability, modifierName, {})

        caster.bioweapon_adaptations = 0
        modifierName = "modifier_bioweapon_adaptations"
        caster:SetModifierStackCount(modifierName, q, 0 )
        caster:AddNewModifier(caster, q, modifierName, {})
        caster:SetModifierStackCount( modifierName, q, caster.bioweapon_adaptations)

        caster.flight_instinct_adaptations = 0
        modifierName = "modifier_flight_instinct_adaptations"
        caster:SetModifierStackCount(modifierName, w, 0 )
        caster:AddNewModifier(caster, w, modifierName, {})
        caster:SetModifierStackCount( modifierName, w, caster.flight_instinct_adaptations)

        caster.aquired_immunity_adaptations = 0
        modifierName = "modifier_aquired_immunity_adaptations"
        caster:SetModifierStackCount(modifierName, e, 0 )
        caster:AddNewModifier(caster, e, modifierName, {})
        caster:SetModifierStackCount( modifierName, e, caster.aquired_immunity_adaptations)
    end
end

--adapt an ability if able, otherwise reset cooldown 
function Adapt( event )
    print('')
    print('Attempting to adapt')
	local caster = event.caster
    local ability = event.ability
    local adapt_ability = caster:FindModifierByName("modifier_adaptation_counter"):RequestAdaptation()

    if adapt_ability ~= -1 then
        print(adapt_ability:GetName())
    else
        print("-1")
    end

    local q = caster:FindAbilityByName("genos_bioweapon")
    local w = caster:FindAbilityByName("genos_flight_instinct")
    local e = caster:FindAbilityByName("genos_aquired_immunity")

    local refresh = 1

    if adapt_ability == q then
    	refresh = 0
    	caster.bioweapon_adaptations = caster.bioweapon_adaptations + 1
    	local modifierName = "modifier_bioweapon_adaptations"
    	caster:RemoveModifierByName( modifierName )
        caster:AddNewModifier(caster, q, modifierName, {} )
        caster:SetModifierStackCount(modifierName, q, caster.bioweapon_adaptations )
        print('Bioweapon Adapted')
    end

    if adapt_ability == w then
    	refresh = 0
    	caster.flight_instinct_adaptations = caster.flight_instinct_adaptations + 1
    	local modifierName = "modifier_flight_instinct_adaptations"
    	caster:RemoveModifierByName( modifierName )
        caster:AddNewModifier(caster, w, modifierName, {} )
        caster:SetModifierStackCount(modifierName, w, caster.flight_instinct_adaptations )
        print('Flight Instinct Adapted')
    end

    if adapt_ability == e then
    	refresh = 0
    	caster.aquired_immunity_adaptations = caster.aquired_immunity_adaptations + 1
    	local modifierName = "modifier_aquired_immunity_adaptations"
    	caster:RemoveModifierByName( modifierName )
        caster:AddNewModifier(caster, e, modifierName, {} )
        caster:SetModifierStackCount(modifierName, e, caster.aquired_immunity_adaptations )
        print('Aquired Immunity Adapted')
    end

    if refresh == 1 then
    	ability:EndCooldown()
    else
        local modifierName = "modifier_adaptation_counter"
        caster:RemoveModifierByName( modifierName )
        caster:AddNewModifier(caster, ability, modifierName, {})
    end

end


