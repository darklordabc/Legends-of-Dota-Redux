function StrafeAttack(keys)
	local caster = keys.caster
	local radius = caster:GetAttackRange()
	if caster:IsRangedAttacker() == false then 
		radius = radius + 50
	end
	local counter = 1
	if caster:HasScepter() then
		counter = keys.ability:GetSpecialValueFor("targets_scepter")
	end
	local units = FindUnitsInRadius(caster:GetTeam(),
                                  caster:GetAbsOrigin(),
                                  nil,
                                  radius,
                                  DOTA_UNIT_TARGET_TEAM_ENEMY,
                                  DOTA_UNIT_TARGET_ALL,
                                  DOTA_UNIT_TARGET_FLAG_NO_INVIS + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE,
                                  FIND_ANY_ORDER,
                                  false)
	for _, unit in pairs( units ) do
		caster:StartGestureWithPlaybackRate(ACT_DOTA_ATTACK, 3)
		if counter > 0 then
			caster:PerformAttack(unit, true, true, true, false, true, false, true)
			counter = counter - 1
		end
	end
	
end
