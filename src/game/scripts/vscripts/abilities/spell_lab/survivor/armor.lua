if spell_lab_survivor_armor == nil then
	spell_lab_survivor_armor = class({})
end

LinkLuaModifier("spell_lab_survivor_armor_modifier", "abilities/spell_lab/survivor/armor.lua", LUA_MODIFIER_MOTION_NONE)

function spell_lab_survivor_armor:GetIntrinsicModifierName() return "spell_lab_survivor_armor_modifier" end


if spell_lab_survivor_armor_modifier == nil then
	spell_lab_survivor_armor_modifier = require "abilities/spell_lab/survivor/base"
end

function spell_lab_survivor_armor_modifier:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
    MODIFIER_EVENT_ON_DEATH
	}
	return funcs
end

function spell_lab_survivor_armor_modifier:GetModifierPhysicalArmorBonus()
if self:GetParent():PassivesDisabled() then return 0 end
return self:GetStackCount()
end
