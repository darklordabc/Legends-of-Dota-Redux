if spell_lab_survivor_evasion == nil then
	spell_lab_survivor_evasion = class({})
end

LinkLuaModifier("spell_lab_survivor_evasion_modifier", "abilities/spell_lab/survivor/evasion.lua", LUA_MODIFIER_MOTION_NONE)

function spell_lab_survivor_evasion:GetIntrinsicModifierName() return "spell_lab_survivor_evasion_modifier" end


if spell_lab_survivor_evasion_modifier == nil then
	spell_lab_survivor_evasion_modifier = require "abilities/spell_lab/survivor/base"
end

function spell_lab_survivor_evasion_modifier:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_EVASION_CONSTANT,
    MODIFIER_EVENT_ON_DEATH
	}
	return funcs
end

function spell_lab_survivor_evasion_modifier:GetModifierEvasion_Constant()
if self:GetParent():PassivesDisabled() then return 0 end
	local value = (100-math.pow(1-(0.01), self:GetStackCount()) * 100) 
  	return value

end
