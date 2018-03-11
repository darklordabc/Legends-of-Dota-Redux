function Cold( event )
	local caster = event.caster
	local ability = event.ability
	local target = event.target
	local dmg = ability:GetLevelSpecialValueFor("damage", ability:GetLevel() - 1 )
	local more_dmg = dmg + ability:GetLevelSpecialValueFor("add_damage", ability:GetLevel() - 1 )

	if target:HasModifier("modifier_frost_lord_frost_breath") then
		ApplyDamage({ victim = target, attacker = caster, damage = more_dmg, damage_type = DAMAGE_TYPE_MAGICAL, ability = ability })
	else
		ApplyDamage({ victim = target, attacker = caster, damage = dmg, damage_type = DAMAGE_TYPE_MAGICAL, ability = ability })
	end	
end