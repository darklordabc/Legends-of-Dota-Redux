octarine_vampirism_lod = class({})

LinkLuaModifier( "modifier_octarine_vampirism_lod_applier", "abilities/modifiers/modifier_octarine_vampirism_lod_applier.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_octarine_vampirism_lod_buff", "abilities/modifiers/modifier_octarine_vampirism_lod_buff.lua" ,LUA_MODIFIER_MOTION_NONE )


function octarine_vampirism_lod:GetIntrinsicModifierName()
    return "modifier_octarine_vampirism_lod_applier"
end
