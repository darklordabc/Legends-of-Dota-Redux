if spell_lab_survivor_damage_boost == nil then
	spell_lab_survivor_damage_boost = class({})
end

LinkLuaModifier("spell_lab_survivor_damage_boost_modifier", "abilities/spell_lab/survivor/damage_boost.lua", LUA_MODIFIER_MOTION_NONE)

function spell_lab_survivor_damage_boost:GetIntrinsicModifierName() return "spell_lab_survivor_damage_boost_modifier" end


if spell_lab_survivor_damage_boost_modifier == nil then
	spell_lab_survivor_damage_boost_modifier = require "abilities/spell_lab/survivor/base"
end

function spell_lab_survivor_damage_boost_modifier:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE,
    MODIFIER_EVENT_ON_DEATH
	}
	return funcs
end

function spell_lab_survivor_damage_boost_modifier:GetModifierBaseAttack_BonusDamage()
return self:GetSurvivorBonus()
end
