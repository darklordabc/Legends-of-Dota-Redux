if spell_lab_souls_spell_boost == nil then
	spell_lab_souls_spell_boost = class({})
end

LinkLuaModifier("spell_lab_souls_spell_boost_modifier", "abilities/spell_lab/souls/spell_boost.lua", LUA_MODIFIER_MOTION_NONE)

function spell_lab_souls_spell_boost:GetIntrinsicModifierName() return "spell_lab_souls_spell_boost_modifier" end


if spell_lab_souls_spell_boost_modifier == nil then
	spell_lab_souls_spell_boost_modifier = require "abilities/spell_lab/souls/base"
end

function spell_lab_souls_spell_boost_modifier:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
    MODIFIER_EVENT_ON_DEATH
	}
	return funcs
end

function spell_lab_souls_spell_boost_modifier:GetModifierSpellAmplify_Percentage()
	return self:GetSoulsBonus() * self:GetAbility():GetSpecialValueFor("per_soul")
end

function spell_lab_souls_spell_boost_modifier:GetColour ()
	return {255,53,255}
end
