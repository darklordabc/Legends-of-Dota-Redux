if spell_lab_souls_vision == nil then
	spell_lab_souls_vision = class({})
end

LinkLuaModifier("spell_lab_souls_vision_modifier", "abilities/spell_lab/souls/vision.lua", LUA_MODIFIER_MOTION_NONE)

function spell_lab_souls_vision:GetIntrinsicModifierName() return "spell_lab_souls_vision_modifier" end


if spell_lab_souls_vision_modifier == nil then
	spell_lab_souls_vision_modifier = require "abilities/spell_lab/souls/base"
end

function spell_lab_souls_vision_modifier:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_BONUS_DAY_VISION,
		MODIFIER_PROPERTY_BONUS_NIGHT_VISION,
    MODIFIER_EVENT_ON_DEATH
	}
	return funcs
end

function spell_lab_souls_vision_modifier:GetBonusDayVision()
	return self:GetSoulsBonus() * self:GetAbility():GetSpecialValueFor("per_soul")
end
function spell_lab_souls_vision_modifier:GetBonusNightVision()
	return self:GetSoulsBonus() * self:GetAbility():GetSpecialValueFor("per_soul")
end


function spell_lab_souls_vision_modifier:GetColour ()
	return {255,50,50}
end
