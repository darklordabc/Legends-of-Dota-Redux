function Ice(event)
	local caster = event.caster
	local target = event.target
	local ability = event.ability

	local damage = ability:GetSpecialValueFor("damage")
	local radius = ability:GetSpecialValueFor("damage_radius")

	local targets = FindUnitsInRadius(caster:GetTeam(), target:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
	
	for _,unit in pairs(targets) do 
			ApplyDamage({victim = unit, attacker = caster, damage = damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = ability})
			ability:ApplyDataDrivenModifier(caster, unit, "modifier_modifier_frost_lord_ice_damage", nil)
	end
end