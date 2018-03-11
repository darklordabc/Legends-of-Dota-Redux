LinkLuaModifier( "modifier_huskar_berserkers_blood_lod" , "abilities/modifiers/modifier_huskar_berserkers_blood_lod.lua" , LUA_MODIFIER_MOTION_NONE )

--[[
    Author: jhqz103
    Date: 17.10.2016
    Simply applies the lua modifier
--]]
function ApplyLuaModifier( keys )
    local caster = keys.caster
    local ability = keys.ability
    local modifiername = keys.ModifierName

    caster:AddNewModifier(caster, ability, modifiername, {})
end