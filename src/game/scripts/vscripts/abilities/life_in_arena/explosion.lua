if IsServer() then
	require('lib/timers')
end

function Explosion(event)
	local caster = event.caster
	local ability = event.ability
	local damage =  caster:GetMaxHealth() * ability:GetSpecialValueFor("hp_prc_dmg") * 0.01
	local radius = ability:GetSpecialValueFor("radius")

	Timers:CreateTimer(0.2,function()
		ApplyDamage({victim = caster, attacker = caster, damage = damage, damage_type = DAMAGE_TYPE_PURE, ability = ability})
	end)
	

	local targets = FindUnitsInRadius(caster:GetTeam() ,caster:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
	for _,unit in pairs(targets) do 
		if not unit:IsBuilding() then
			ApplyDamage({victim = unit, attacker = caster, damage = damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = ability})
			ability:ApplyDataDrivenModifier(caster,unit,"modifier_akron_explosion_burn", nil)
		end
	end
	ability:ApplyDataDrivenModifier(caster,caster,"modifier_akron_explosion_burn", nil)
	

end

