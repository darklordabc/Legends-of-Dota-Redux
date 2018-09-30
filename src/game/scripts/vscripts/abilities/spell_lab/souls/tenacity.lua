if spell_lab_souls_tenacity == nil then
	spell_lab_souls_tenacity = class({})
end

LinkLuaModifier("spell_lab_souls_tenacity_modifier", "abilities/spell_lab/souls/tenacity.lua", LUA_MODIFIER_MOTION_NONE)

function spell_lab_souls_tenacity:GetIntrinsicModifierName() return "spell_lab_souls_tenacity_modifier" end


if spell_lab_souls_tenacity_modifier == nil then
	spell_lab_souls_tenacity_modifier = require "abilities/spell_lab/souls/base"
end

function spell_lab_souls_tenacity_modifier:DeclareFunctions()
	local funcs = {
    MODIFIER_EVENT_ON_DEATH
	}
	return funcs
end

function spell_lab_souls_tenacity_modifier:GetTenacity()
	return (100-math.pow(1-(0.01*self:GetAbility():GetSpecialValueFor("per_soul")), self:GetSoulsBonus()) * 100) 
end

function spell_lab_souls_tenacity_modifier:GetColour ()
	return {222,12,184}
end
