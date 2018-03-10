if spell_lab_survivor_health_regen == nil then
	spell_lab_survivor_health_regen = class({})
end

LinkLuaModifier("spell_lab_survivor_health_regen_modifier", "abilities/spell_lab/survivor/health_regen.lua", LUA_MODIFIER_MOTION_NONE)

function spell_lab_survivor_health_regen:GetIntrinsicModifierName() return "spell_lab_survivor_health_regen_modifier" end


if spell_lab_survivor_health_regen_modifier == nil then
	spell_lab_survivor_health_regen_modifier = require "abilities/spell_lab/survivor/base"
end

function spell_lab_survivor_health_regen_modifier:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
    MODIFIER_EVENT_ON_DEATH
	}
	return funcs
end

function spell_lab_survivor_health_regen_modifier:GetModifierConstantHealthRegen()
return self:GetSurvivorBonus()
end
