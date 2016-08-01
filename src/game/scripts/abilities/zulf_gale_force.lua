function ApplyDamageAgility( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local damageType = ability:GetAbilityDamageType()
	local agility_multiplier = ability:GetLevelSpecialValueFor("damage_per_agility", ability:GetLevel() - 1)
	local damage = (caster:GetAgility() * agility_multiplier) / 5
	
	ApplyDamage({ victim = target, attacker = caster, ability = ability, damage = damage, damage_type = damageType })
end