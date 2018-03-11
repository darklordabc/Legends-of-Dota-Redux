function StormDamage(keys)
	ApplyDamage({ 
		victim = keys.target, 
		attacker = keys.caster, 
		damage = keys.target:GetHealth() * keys.dmg_pct / 100,	
		damage_type = DAMAGE_TYPE_MAGICAL })
end