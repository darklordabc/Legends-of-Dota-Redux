if spell_lab_souls_magic_resistance == nil then
	spell_lab_souls_magic_resistance = class({})
end

LinkLuaModifier("spell_lab_souls_magic_resistance_modifier", "abilities/spell_lab/souls/magic_resistance.lua", LUA_MODIFIER_MOTION_NONE)

function spell_lab_souls_magic_resistance:GetIntrinsicModifierName() return "spell_lab_souls_magic_resistance_modifier" end


if spell_lab_souls_magic_resistance_modifier == nil then
	spell_lab_souls_magic_resistance_modifier = require "abilities/spell_lab/souls/base"
end

function spell_lab_souls_magic_resistance_modifier:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
    MODIFIER_EVENT_ON_DEATH
	}
	return funcs
end

function spell_lab_souls_magic_resistance_modifier:GetModifierMagicalResistanceBonus()
	return self:GetSoulsBonus() * self:GetAbility():GetSpecialValueFor("per_soul")
end

function spell_lab_souls_magic_resistance_modifier:GetColour ()
	return {139,255,219}
end
