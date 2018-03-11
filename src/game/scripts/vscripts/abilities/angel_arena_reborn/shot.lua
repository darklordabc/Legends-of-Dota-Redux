function DamageOfCurrentHealth(event)
	local caster 		= event.caster
	local target 		= event.target
	local damage_pct 	= event.DamagePercent or 0

	if not target or not damage_pct or not caster then return end

	if caster:IsIllusion() then return end
	
	if caster:PassivesDisabled() then return end
	
	
	local damage_int_pct_add = 1
	if caster:IsRealHero() then
		damage_int_pct_add = caster:GetIntellect()
		damage_int_pct_add = damage_int_pct_add / 16 / 100 + 1
	end 

	local damage_total 	= (target:GetHealth()*damage_pct / 100 ) / damage_int_pct_add

	ApplyDamage({ victim = target, attacker = caster, damage = damage_total, damage_type = DAMAGE_TYPE_MAGICAL }) 
end
