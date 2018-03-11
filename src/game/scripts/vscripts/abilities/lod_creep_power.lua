lod_creep_power = class({})

LinkLuaModifier( "modifier_creep_power", "abilities/modifiers/modifier_creep_power.lua" , LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_creep_power_hp", "abilities/modifiers/modifier_creep_power.lua" , LUA_MODIFIER_MOTION_NONE )

function lod_creep_power:GetIntrinsicModifierName()
    return "modifier_creep_power"
end
