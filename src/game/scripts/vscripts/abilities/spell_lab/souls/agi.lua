if spell_lab_souls_agi == nil then
	spell_lab_souls_agi = class({})
end

LinkLuaModifier("spell_lab_souls_agi_modifier", "abilities/spell_lab/souls/agi.lua", LUA_MODIFIER_MOTION_NONE)

function spell_lab_souls_agi:GetIntrinsicModifierName() return "spell_lab_souls_agi_modifier" end


if spell_lab_souls_agi_modifier == nil then
	spell_lab_souls_agi_modifier = require "abilities/spell_lab/souls/base"
end

function spell_lab_souls_agi_modifier:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
    MODIFIER_EVENT_ON_DEATH
	}
	return funcs
end

function spell_lab_souls_agi_modifier:GetModifierBonusStats_Agility()
	return self:GetSoulsBonus() * self:GetAbility():GetSpecialValueFor("per_soul")
end

function spell_lab_souls_agi_modifier:GetColour ()
	return {50,255,50}
end
