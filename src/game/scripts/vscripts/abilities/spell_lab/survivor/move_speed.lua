if spell_lab_survivor_move_speed == nil then
	spell_lab_survivor_move_speed = class({})
end

LinkLuaModifier("spell_lab_survivor_move_speed_modifier", "abilities/spell_lab/survivor/move_speed.lua", LUA_MODIFIER_MOTION_NONE)

function spell_lab_survivor_move_speed:GetIntrinsicModifierName() return "spell_lab_survivor_move_speed_modifier" end


if spell_lab_survivor_move_speed_modifier == nil then
	spell_lab_survivor_move_speed_modifier = require "abilities/spell_lab/survivor/base"
end

function spell_lab_survivor_move_speed_modifier:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
    MODIFIER_EVENT_ON_DEATH
	}
	return funcs
end

function spell_lab_survivor_move_speed_modifier:GetModifierMoveSpeedBonus_Constant()
if self:GetParent():PassivesDisabled() then return 0 end
return self:GetStackCount()
end
