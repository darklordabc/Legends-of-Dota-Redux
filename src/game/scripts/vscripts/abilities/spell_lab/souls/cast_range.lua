if spell_lab_souls_cast_range == nil then
	spell_lab_souls_cast_range = class({})
end

LinkLuaModifier("spell_lab_souls_cast_range_modifier", "abilities/spell_lab/souls/cast_range.lua", LUA_MODIFIER_MOTION_NONE)

function spell_lab_souls_cast_range:GetIntrinsicModifierName() return "spell_lab_souls_cast_range_modifier" end


if spell_lab_souls_cast_range_modifier == nil then
	spell_lab_souls_cast_range_modifier = require "abilities/spell_lab/souls/base"
end

function spell_lab_souls_cast_range_modifier:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_CAST_RANGE_BONUS_STACKING,
    MODIFIER_EVENT_ON_DEATH
	}
	return funcs
end

function spell_lab_souls_cast_range_modifier:GetModifierCastRangeBonusStacking()
	return self:GetSoulsBonus() * self:GetAbility():GetSpecialValueFor("per_soul")
end

function spell_lab_souls_cast_range_modifier:GetColour ()
	return {242,254,20}
end
