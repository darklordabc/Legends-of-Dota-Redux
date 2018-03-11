if spell_lab_survivor_life_steal == nil then
	spell_lab_survivor_life_steal = class({})
end

LinkLuaModifier("spell_lab_survivor_life_steal_modifier", "abilities/spell_lab/survivor/life_steal.lua", LUA_MODIFIER_MOTION_NONE)

function spell_lab_survivor_life_steal:GetIntrinsicModifierName() return "spell_lab_survivor_life_steal_modifier" end


if spell_lab_survivor_life_steal_modifier == nil then
	spell_lab_survivor_life_steal_modifier = require "abilities/spell_lab/survivor/base"
end

function spell_lab_survivor_life_steal_modifier:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_TAKEDAMAGE,
    MODIFIER_EVENT_ON_DEATH
	}
	return funcs
end

function spell_lab_survivor_life_steal_modifier:OnTakeDamage(keys)
	if IsServer() then
		if keys.damage_type ~= DAMAGE_TYPE_PHYSICAL then return end
		local hAbility = self:GetAbility()
		if self:GetParent():PassivesDisabled() then return end
		if hAbility:GetLevel() < 1 then return end
		if keys.attacker == self:GetParent() and not self:GetParent():IsIllusion() then
			local heal = self:GetStackCount()*0.01*keys.damage
			keys.attacker:Heal(heal, hAbility)
			local lifePfx = ParticleManager:CreateParticle("particles/generic_gameplay/generic_lifesteal.vpcf", PATTACH_OVERHEAD_FOLLOW, caster)
			ParticleManager:ReleaseParticleIndex(lifePfx)
		end
	end
end
