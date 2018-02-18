if spell_lab_survivor_mana_burn == nil then
	spell_lab_survivor_mana_burn = class({})
end

LinkLuaModifier("spell_lab_survivor_mana_burn_modifier", "abilities/spell_lab/survivor/mana_burn.lua", LUA_MODIFIER_MOTION_NONE)

function spell_lab_survivor_mana_burn:GetIntrinsicModifierName() return "spell_lab_survivor_mana_burn_modifier" end


if spell_lab_survivor_mana_burn_modifier == nil then
	spell_lab_survivor_mana_burn_modifier = require "abilities/spell_lab/survivor/base"
end

function spell_lab_survivor_mana_burn_modifier:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
    MODIFIER_EVENT_ON_DEATH
	}
	return funcs
end

function spell_lab_survivor_mana_burn_modifier:OnAttackLanded(keys)
	if IsServer() then
		local hAbility = self:GetAbility()
		if self:GetParent():PassivesDisabled() then return 0 end
		if hAbility:GetLevel() < 1 then return end
		if keys.attacker == self:GetParent() then
			local mana = keys.target:GetMana()
			keys.target:ReduceMana(self:GetStackCount())
			mana = mana-keys.target:GetMana()

			if (mana > 1) then
				local damage = {
					victim = keys.target,
					attacker = keys.attacker,
					damage = mana*hAbility:GetSpecialValueFor("damage_pct")*0.01,
					damage_type = DAMAGE_TYPE_PHYSICAL,
					ability = hAbility
				}
				EmitSoundOnLocationWithCaster( keys.target:GetAbsOrigin(), "Hero_Antimage.ManaBreak", self:GetParent() )
				local nFXIndex = ParticleManager:CreateParticle("particles/generic_gameplay/generic_manaburn.vpcf", PATTACH_ROOTBONE_FOLLOW, keys.target)
				ParticleManager:ReleaseParticleIndex(nFXIndex)
				ApplyDamage(damage)
			end
		end
	end
end
