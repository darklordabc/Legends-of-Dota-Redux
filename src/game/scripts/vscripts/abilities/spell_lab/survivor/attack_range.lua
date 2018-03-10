if spell_lab_survivor_attack_range == nil then
	spell_lab_survivor_attack_range = class({})
end

LinkLuaModifier("spell_lab_survivor_attack_range_modifier", "abilities/spell_lab/survivor/attack_range.lua", LUA_MODIFIER_MOTION_NONE)

function spell_lab_survivor_attack_range:GetIntrinsicModifierName() return "spell_lab_survivor_attack_range_modifier" end


if spell_lab_survivor_attack_range_modifier == nil then
	spell_lab_survivor_attack_range_modifier = require "abilities/spell_lab/survivor/base"
end

function spell_lab_survivor_attack_range_modifier:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
    MODIFIER_EVENT_ON_DEATH
	}
	return funcs
end

function spell_lab_survivor_attack_range_modifier:GetModifierAttackRangeBonus()
if self:GetParent():PassivesDisabled() then return 0 end
return self:GetStackCount()
end
