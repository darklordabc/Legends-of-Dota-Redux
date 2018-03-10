if spell_lab_survivor_attack_speed == nil then
	spell_lab_survivor_attack_speed = class({})
end

LinkLuaModifier("spell_lab_survivor_attack_speed_modifier", "abilities/spell_lab/survivor/attack_speed.lua", LUA_MODIFIER_MOTION_NONE)

function spell_lab_survivor_attack_speed:GetIntrinsicModifierName() return "spell_lab_survivor_attack_speed_modifier" end


if spell_lab_survivor_attack_speed_modifier == nil then
	spell_lab_survivor_attack_speed_modifier = require "abilities/spell_lab/survivor/base"
end

function spell_lab_survivor_attack_speed_modifier:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
    MODIFIER_EVENT_ON_DEATH
	}
	return funcs
end

function spell_lab_survivor_attack_speed_modifier:GetModifierAttackSpeedBonus_Constant()
if self:GetParent():PassivesDisabled() then return 0 end
return self:GetStackCount()
end
