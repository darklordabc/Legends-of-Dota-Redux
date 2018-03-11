if spell_lab_souls_cooldown == nil then
	spell_lab_souls_cooldown = class({})
end

LinkLuaModifier("spell_lab_souls_cooldown_modifier", "abilities/spell_lab/souls/cooldown.lua", LUA_MODIFIER_MOTION_NONE)

function spell_lab_souls_cooldown:GetIntrinsicModifierName() return "spell_lab_souls_cooldown_modifier" end


if spell_lab_souls_cooldown_modifier == nil then
	spell_lab_souls_cooldown_modifier = require "abilities/spell_lab/souls/base"
end

function spell_lab_souls_cooldown_modifier:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE,
    MODIFIER_EVENT_ON_DEATH
	}
	return funcs
end

function spell_lab_souls_cooldown_modifier:GetModifierPercentageCooldown()
	return self:GetSoulsBonus() * self:GetAbility():GetSpecialValueFor("per_soul")
end

function spell_lab_souls_cooldown_modifier:GetColour ()
	return {0,244,184}
end
