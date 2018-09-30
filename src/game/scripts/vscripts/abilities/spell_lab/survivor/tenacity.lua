if spell_lab_survivor_tenacity == nil then
	spell_lab_survivor_tenacity = class({})
end

if spell_lab_survivor_tenacity_op == nil then
  spell_lab_survivor_tenacity_op = class({})
end

LinkLuaModifier("spell_lab_survivor_tenacity_modifier", "abilities/spell_lab/survivor/tenacity.lua", LUA_MODIFIER_MOTION_NONE)

function spell_lab_survivor_tenacity:GetIntrinsicModifierName() return "spell_lab_survivor_tenacity_modifier" end

function spell_lab_survivor_tenacity_op:GetIntrinsicModifierName() return "spell_lab_survivor_tenacity_modifier" end


if spell_lab_survivor_tenacity_modifier == nil then
	spell_lab_survivor_tenacity_modifier = require "abilities/spell_lab/survivor/base"
end

function spell_lab_survivor_tenacity_modifier:DeclareFunctions()
	local funcs = {
		
    MODIFIER_EVENT_ON_DEATH
	}
	return funcs
end

function spell_lab_survivor_tenacity_modifier:GetTenacity()
if self:GetParent():PassivesDisabled() then return 0 end
return (100-math.pow(1-(0.01), self:GetStackCount()) * 100) 
end
