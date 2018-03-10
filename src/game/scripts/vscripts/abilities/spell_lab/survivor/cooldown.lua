if spell_lab_survivor_cooldown == nil then
	spell_lab_survivor_cooldown = class({})
end

if spell_lab_survivor_cooldown_op == nil then
  spell_lab_survivor_cooldown_op = class({})
end

LinkLuaModifier("spell_lab_survivor_cooldown_modifier", "abilities/spell_lab/survivor/cooldown.lua", LUA_MODIFIER_MOTION_NONE)

function spell_lab_survivor_cooldown:GetIntrinsicModifierName() return "spell_lab_survivor_cooldown_modifier" end

function spell_lab_survivor_cooldown_op:GetIntrinsicModifierName() return "spell_lab_survivor_cooldown_modifier" end


if spell_lab_survivor_cooldown_modifier == nil then
	spell_lab_survivor_cooldown_modifier = require "abilities/spell_lab/survivor/base"
end

function spell_lab_survivor_cooldown_modifier:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE,
    MODIFIER_EVENT_ON_DEATH
	}
	return funcs
end

function spell_lab_survivor_cooldown_modifier:GetModifierPercentageCooldown()
if self:GetParent():PassivesDisabled() then return 0 end
return self:GetStackCount()
end
