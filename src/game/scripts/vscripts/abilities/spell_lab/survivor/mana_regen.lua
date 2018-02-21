if spell_lab_survivor_mana_regen == nil then
	spell_lab_survivor_mana_regen = class({})
end

LinkLuaModifier("spell_lab_survivor_mana_regen_modifier", "abilities/spell_lab/survivor/mana_regen.lua", LUA_MODIFIER_MOTION_NONE)

function spell_lab_survivor_mana_regen:GetIntrinsicModifierName() return "spell_lab_survivor_mana_regen_modifier" end


if spell_lab_survivor_mana_regen_modifier == nil then
	spell_lab_survivor_mana_regen_modifier = require "abilities/spell_lab/survivor/base"
end

function spell_lab_survivor_mana_regen_modifier:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
    MODIFIER_EVENT_ON_DEATH
	}
	return funcs
end

function spell_lab_survivor_mana_regen_modifier:GetModifierConstantManaRegen()
if self:GetParent():PassivesDisabled() then return 0 end
return self:GetStackCount()
end
