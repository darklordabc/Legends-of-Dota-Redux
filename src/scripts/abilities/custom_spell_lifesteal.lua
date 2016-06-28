custom_spell_lifesteal = class({})

LinkLuaModifier( "modifier_custom_spell_lifesteal_applier", "scripts/vscripts/../abilities/modifiers/modifier_custom_spell_lifesteal_applier.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_custom_spell_lifesteal_buff", "scripts/vscripts/../abilities/modifiers/modifier_custom_spell_lifesteal_buff.lua" ,LUA_MODIFIER_MOTION_NONE )


function custom_spell_lifesteal:GetIntrinsicModifierName()
	return "modifier_custom_spell_lifesteal_applier"
end
