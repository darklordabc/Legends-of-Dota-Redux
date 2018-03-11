if spell_lab_souls_armor == nil then
	spell_lab_souls_armor = class({})
end

LinkLuaModifier("spell_lab_souls_armor_modifier", "abilities/spell_lab/souls/armor.lua", LUA_MODIFIER_MOTION_NONE)

function spell_lab_souls_armor:GetIntrinsicModifierName() return "spell_lab_souls_armor_modifier" end


if spell_lab_souls_armor_modifier == nil then
	spell_lab_souls_armor_modifier = require "abilities/spell_lab/souls/base"
end

function spell_lab_souls_armor_modifier:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
    MODIFIER_EVENT_ON_DEATH
	}
	return funcs
end

function spell_lab_souls_armor_modifier:GetModifierPhysicalArmorBonus()
	return self:GetSoulsBonus() * self:GetAbility():GetSpecialValueFor("per_soul")
end

function spell_lab_souls_armor_modifier:GetColour ()
	return {158,211,159}
end
