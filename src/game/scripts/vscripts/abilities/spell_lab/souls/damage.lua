if spell_lab_souls_damage == nil then
	spell_lab_souls_damage = class({})
end

LinkLuaModifier("spell_lab_souls_damage_modifier", "abilities/spell_lab/souls/damage.lua", LUA_MODIFIER_MOTION_NONE)

function spell_lab_souls_damage:GetIntrinsicModifierName() return "spell_lab_souls_damage_modifier" end


if spell_lab_souls_damage_modifier == nil then
	spell_lab_souls_damage_modifier = require "abilities/spell_lab/souls/base"
end

function spell_lab_souls_damage_modifier:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE,
    MODIFIER_EVENT_ON_DEATH
	}
	return funcs
end

function spell_lab_souls_damage_modifier:GetModifierBaseAttack_BonusDamage()
	return self:GetSoulsBonus() * self:GetAbility():GetSpecialValueFor("per_soul")
end

function spell_lab_souls_damage_modifier:GetColour ()
	return {255,150,0}
end
