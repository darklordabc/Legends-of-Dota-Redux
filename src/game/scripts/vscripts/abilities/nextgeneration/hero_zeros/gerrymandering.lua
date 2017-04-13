function GerrymanderInitiate( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target

	if target:TriggerSpellAbsorb(ability) then
		target:RemoveModifierByName("modifier_gerrymander_debuff")
		RemoveLinkens(target)
		return
	end
end

function GerrymanderBuff( keys )
	local caster = keys.caster
	local target = keys.unit
	local ability = keys.ability
	local damage = keys.Damage

	local bonusEffect = ability:GetLevelSpecialValueFor("bonus_effect", ability:GetLevel() - 1) / 100
	local delay = ability:GetLevelSpecialValueFor("delay", ability:GetLevel() - 1)

	local heal = damage * bonusEffect

	Timers:CreateTimer( delay, function () 
		if target:HasModifier("modifier_gerrymander_buff") then 
			local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_skeletonking/wraith_king_vampiric_aura_lifesteal.vpcf", PATTACH_ABSORIGIN, target)
			ParticleManager:SetParticleControl(particle, 0, target:GetAbsOrigin())
		    ParticleManager:SetParticleControl(particle, 1, target:GetAbsOrigin())
		    ParticleManager:SetParticleControl(particle, 2, target:GetAbsOrigin())
			target:Heal(heal, caster)
		end
		return nil
	end)
end

function GerrymanderDebuff( keys )
	local caster = keys.caster
	local target = keys.unit
	local attacker = keys.attacker
	local ability = keys.ability

	local damage = keys.Damage

	local bonusEffect = ability:GetLevelSpecialValueFor("bonus_effect", ability:GetLevel() - 1) / 100
	local delay = ability:GetLevelSpecialValueFor("delay", ability:GetLevel() - 1)

	local heal = damage * bonusEffect

	Timers:CreateTimer( delay, function () 
		if attacker:HasModifier("modifier_gerrymander_debuff") then 
			local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_skeletonking/wraith_king_vampiric_aura_lifesteal.vpcf", PATTACH_ABSORIGIN, target)
			ParticleManager:SetParticleControl(particle, 0, target:GetAbsOrigin())
		    ParticleManager:SetParticleControl(particle, 1, target:GetAbsOrigin())
		    ParticleManager:SetParticleControl(particle, 2, target:GetAbsOrigin())
			target:Heal(heal, caster)
		end
		return nil
	end)
end