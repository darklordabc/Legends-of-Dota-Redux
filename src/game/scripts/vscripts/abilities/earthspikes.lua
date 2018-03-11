function DealPercentDamage( keys )
	local damage_int_pct_add = 1
	if keys.caster:IsRealHero() then
		damage_int_pct_add = keys.caster:GetIntellect()
		damage_int_pct_add = damage_int_pct_add / 16 / 100 + 1
	end 

	ApplyDamage({
		victim = keys.target,
		attacker = keys.caster,
		damage = keys.target:GetHealth() * keys.damage_pct / damage_int_pct_add / 100,
		damage_type = DAMAGE_TYPE_MAGICAL,
		abilityReturn = keys.ability,
	})
end