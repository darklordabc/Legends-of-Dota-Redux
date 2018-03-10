if spell_lab_survivor_critical == nil then
	spell_lab_survivor_critical = class({})
end

LinkLuaModifier("spell_lab_survivor_critical_modifier", "abilities/spell_lab/survivor/critical.lua", LUA_MODIFIER_MOTION_NONE)

function spell_lab_survivor_critical:GetIntrinsicModifierName() return "spell_lab_survivor_critical_modifier" end


if spell_lab_survivor_critical_modifier == nil then
	spell_lab_survivor_critical_modifier = require "abilities/spell_lab/survivor/base"
end

function spell_lab_survivor_critical_modifier:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
    MODIFIER_EVENT_ON_DEATH
	}
	return funcs
end

function spell_lab_survivor_critical_modifier:GetModifierPreAttack_CriticalStrike()
	if self:GetParent():PassivesDisabled() then return 0 end
	local chance = self:GetAbility():GetSpecialValueFor("chance")
	if (math.random(0,100) > chance) then return 0 end
  return self:GetStackCount()+100
end
