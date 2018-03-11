if spell_lab_souls_int == nil then
	spell_lab_souls_int = class({})
end

LinkLuaModifier("spell_lab_souls_int_modifier", "abilities/spell_lab/souls/int.lua", LUA_MODIFIER_MOTION_NONE)

function spell_lab_souls_int:GetIntrinsicModifierName() return "spell_lab_souls_int_modifier" end


if spell_lab_souls_int_modifier == nil then
	spell_lab_souls_int_modifier = require "abilities/spell_lab/souls/base"
end

function spell_lab_souls_int_modifier:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
    MODIFIER_EVENT_ON_DEATH
	}
	return funcs
end

function spell_lab_souls_int_modifier:GetModifierBonusStats_Intellect()
	return self:GetSoulsBonus() * self:GetAbility():GetSpecialValueFor("per_soul")
end

function spell_lab_souls_int_modifier:GetColour ()
	return {50,50,255}
end
