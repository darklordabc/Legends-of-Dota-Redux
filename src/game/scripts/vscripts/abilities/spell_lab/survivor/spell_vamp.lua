if spell_lab_survivor_spell_vamp == nil then
	spell_lab_survivor_spell_vamp = class({})
end

LinkLuaModifier("spell_lab_survivor_spell_vamp_modifier", "abilities/spell_lab/survivor/spell_vamp.lua", LUA_MODIFIER_MOTION_NONE)

function spell_lab_survivor_spell_vamp:GetIntrinsicModifierName() return "spell_lab_survivor_spell_vamp_modifier" end


if spell_lab_survivor_spell_vamp_modifier == nil then
	spell_lab_survivor_spell_vamp_modifier = require "abilities/spell_lab/survivor/base"
end

function spell_lab_survivor_spell_vamp_modifier:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_TAKEDAMAGE,
    MODIFIER_EVENT_ON_DEATH
	}
	return funcs
end

function spell_lab_survivor_spell_vamp_modifier:OnTakeDamage(keys)
	if IsServer() then
		if keys.damage_type ~= DAMAGE_TYPE_MAGICAL then return end
		local hAbility = self:GetAbility()
		if self:GetParent():PassivesDisabled() then return end
		if hAbility:GetLevel() < 1 then return end
		if keys.attacker == self:GetParent() and not self:GetParent():IsIllusion() then
			local heal = self:GetStackCount()*0.01*keys.damage
			keys.attacker:Heal(heal, hAbility)
    	ParticleManager:CreateParticle("particles/items3_fx/octarine_core_lifesteal.vpcf", PATTACH_ABSORIGIN, self:GetCaster())
		end
	end
end
