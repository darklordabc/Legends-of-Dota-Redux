if spell_lab_survivor_magic_resistance == nil then
	spell_lab_survivor_magic_resistance = class({})
end

LinkLuaModifier("spell_lab_survivor_magic_resistance_modifier", "abilities/spell_lab/survivor/magic_resistance.lua", LUA_MODIFIER_MOTION_NONE)

function spell_lab_survivor_magic_resistance:GetIntrinsicModifierName() return "spell_lab_survivor_magic_resistance_modifier" end


if spell_lab_survivor_magic_resistance_modifier == nil then
	spell_lab_survivor_magic_resistance_modifier = require "abilities/spell_lab/survivor/base"
end

function spell_lab_survivor_magic_resistance_modifier:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
    MODIFIER_EVENT_ON_DEATH
	}
	return funcs
end

function spell_lab_survivor_magic_resistance_modifier:GetModifierMagicalResistanceBonus()
if self:GetParent():PassivesDisabled() then return 0 end
return self:GetStackCount()
end
