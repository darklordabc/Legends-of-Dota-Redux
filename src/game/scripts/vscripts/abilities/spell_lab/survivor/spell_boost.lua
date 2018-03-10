if spell_lab_survivor_spell_boost == nil then
	spell_lab_survivor_spell_boost = class({})
end

if spell_lab_survivor_spell_boost_op == nil then
  spell_lab_survivor_spell_boost_op = class({})
end

LinkLuaModifier("spell_lab_survivor_spell_boost_modifier", "abilities/spell_lab/survivor/spell_boost.lua", LUA_MODIFIER_MOTION_NONE)

function spell_lab_survivor_spell_boost:GetIntrinsicModifierName() return "spell_lab_survivor_spell_boost_modifier" end

function spell_lab_survivor_spell_boost_op:GetIntrinsicModifierName() return "spell_lab_survivor_spell_boost_modifier" end


if spell_lab_survivor_spell_boost_modifier == nil then
	spell_lab_survivor_spell_boost_modifier = require "abilities/spell_lab/survivor/base"
end

function spell_lab_survivor_spell_boost_modifier:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
    MODIFIER_EVENT_ON_DEATH
	}
	return funcs
end

function spell_lab_survivor_spell_boost_modifier:GetModifierSpellAmplify_Percentage()
if self:GetParent():PassivesDisabled() then return 0 end
return self:GetStackCount()
end
