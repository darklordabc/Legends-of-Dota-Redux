function startd(event)
	local caster = event.caster
	local ability = event.ability
	local value_p = ability:GetSpecialValueFor("value_p")
	local radius = ability:GetSpecialValueFor("radius")
	--
	local agility = caster:GetAgility()
	local damage
	--print('		caster.count_ill',caster.count_ill)
	if not caster.count_ill or caster.count_ill == 0 then 
		damage = agility *1 *value_p
	else
		damage = agility *caster.count_ill *value_p
	end
	
	--print('		damage',damage)
	local targets = event.target_entities
	--local targets = FindUnitsInRadius(caster:GetTeam() ,caster:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
	for _,unit in pairs(targets) do 
		ApplyDamage({victim = unit, attacker = caster, damage = damage, damage_type = DAMAGE_TYPE_PHYSICAL, ability = ability})
		ParticleManager:CreateParticle("particles/units/heroes/hero_arc_warden/arc_warden_flux_cast.vpcf" , 1, unit)
	end
end


function remove_count(event)
	local caster = event.caster
	--
	--local target = event.target
	--local ability = event.ability
	--
	--if not caster.curr_agi then
	--	caster.curr_agi = 0
	--end
	--
	--if caster.count_ill then
	caster.count_ill = caster.count_ill -1
	--end
	
	
end