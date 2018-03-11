if spell_lab_survivor_cleave == nil then
	spell_lab_survivor_cleave = class({})
end

LinkLuaModifier("spell_lab_survivor_cleave_modifier", "abilities/spell_lab/survivor/cleave.lua", LUA_MODIFIER_MOTION_NONE)

function spell_lab_survivor_cleave:GetIntrinsicModifierName() return "spell_lab_survivor_cleave_modifier" end


if spell_lab_survivor_cleave_modifier == nil then
	spell_lab_survivor_cleave_modifier = require "abilities/spell_lab/survivor/base"
end

function spell_lab_survivor_cleave_modifier:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK,
    MODIFIER_EVENT_ON_DEATH
	}
	return funcs
end

function spell_lab_survivor_cleave_modifier:OnAttack(keys)
	if IsServer() then
		local hAbility = self:GetAbility()
		if self:GetParent():PassivesDisabled() then return end
		if hAbility:GetLevel() < 1 then return end
		if keys.attacker == self:GetParent() and not self:GetParent():IsIllusion() then
 	 			--local range = hAbility:GetSpecialValueFor("range")
				--DoCleaveAttack(self:GetParent(), keys.unit, hAbility, self:GetStackCount(), range, range, range, "effectName")
		end
	end
end
