if spell_lab_souls_evasion == nil then
	spell_lab_souls_evasion = class({})
end

LinkLuaModifier("spell_lab_souls_evasion_modifier", "abilities/spell_lab/souls/evasion.lua", LUA_MODIFIER_MOTION_NONE)

function spell_lab_souls_evasion:GetIntrinsicModifierName() return "spell_lab_souls_evasion_modifier" end


if spell_lab_souls_evasion_modifier == nil then
	spell_lab_souls_evasion_modifier = require "abilities/spell_lab/souls/base"
end

function spell_lab_souls_evasion_modifier:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_EVASION_CONSTANT,
    MODIFIER_EVENT_ON_DEATH
	}
	return funcs
end

function spell_lab_souls_evasion_modifier:GetModifierEvasion_Constant()
	local value = (100-math.pow(1-(0.01*self:GetAbility():GetSpecialValueFor("per_soul")), self:GetSoulsBonus()) * 100) 
	return value
end

function spell_lab_souls_evasion_modifier:GetColour ()
	return {139,255,219}
end
