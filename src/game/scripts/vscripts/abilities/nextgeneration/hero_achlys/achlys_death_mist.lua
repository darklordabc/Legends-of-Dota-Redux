function InitDeathMist(keys)
	local caster = keys.caster
    local ability = keys.ability
	
	ability.manaBurned = caster:GetMana() * ability:GetSpecialValueFor("self_burn") / 100
	ability.healthBurned = caster:GetHealth() * ability:GetSpecialValueFor("self_damage") / 100

	ApplyDamage({victim = caster, attacker = caster, damage = ability.healthBurned, damage_type = ability:GetAbilityDamageType(), ability = ability})
	caster:SetMana(caster:GetMana() - ability.manaBurned)
end

function DeathMistTick(keys)
	local caster = keys.caster
    local ability = keys.ability
	local target = keys.target
	local tickrate = ability:GetSpecialValueFor("tick_rate")
	local duration = ability:GetSpecialValueFor("damage_duration")
	local manaburn = ability.manaBurned * tickrate / duration
	local damage = ability.healthBurned * tickrate / duration
	
	target:SetMana(target:GetMana() - manaburn)
	ApplyDamage({victim = target, attacker = caster, damage = damage, damage_type = ability:GetAbilityDamageType(), ability = ability})
end

function StartMist(keys)
	local caster = keys.caster
    local ability = keys.ability
	
	local radius = ability:GetCastRange()
	
	local waveIndex = ParticleManager:CreateParticle( "particles/achlys_death_mist_main_shockwave.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster )
		ParticleManager:SetParticleControl( waveIndex, 0, caster:GetOrigin() )
		ParticleManager:SetParticleControl( waveIndex, 2, Vector( 1, 1, 1 ) )
		ParticleManager:SetParticleControl( waveIndex, 3, caster:GetOrigin() )
	local nFXIndex = ParticleManager:CreateParticle( "particles/achlys_death_mist_main_radius.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster )
		ParticleManager:SetParticleControl( nFXIndex, 1, Vector( radius, 1, 1 ) )
		caster:FindModifierByName("modifier_achlys_death_mist_fx"):AddParticle( nFXIndex, false, false, -1, false, false )
		caster:FindModifierByName("modifier_achlys_death_mist_fx"):AddParticle( waveIndex, false, false, -1, false, false )
end