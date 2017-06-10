LinkLuaModifier("modifier_darwin_buff", "abilities/resurgence/hero_genos/modifiers/modifier_darwin_buff.lua", LUA_MODIFIER_MOTION_NONE)

--[[Author: TheGreatGimmick
    Date: May 16, 2017
    ]] 

--Initialize modifiers and their stacks  
function UpdateDarwin( event )
	local caster = event.caster
    local ability = event.ability

    if not caster.last_death_time then
        caster.last_death_time = GameRules:GetGameTime()
    end

    local thirst = caster:FindModifierByName("modifier_bloodseeker_thirst")
    if not thrist then
        caster:AddNewModifier(caster, ability, "modifier_bloodseeker_thirst", {})
    end

    caster:RemoveModifierByName("modifier_darwin_buff")
    caster:AddNewModifier(caster, ability, "modifier_darwin_buff", {})
end

function Extinction( event )
    local caster = event.caster
    caster.last_death_time = GameRules:GetGameTime()
end