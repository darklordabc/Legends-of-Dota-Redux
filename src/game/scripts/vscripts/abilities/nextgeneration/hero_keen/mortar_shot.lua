function CreateMarkers( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	
	local range = ability:GetLevelSpecialValueFor("range", ability:GetLevel() - 1)
	local shots = ability:GetLevelSpecialValueFor("shots", ability:GetLevel() - 1)
	local interval = ability:GetLevelSpecialValueFor("shot_interval", ability:GetLevel() - 1)
	
	local duration = ability:GetLevelSpecialValueFor("duration", ability:GetLevel() - 1)

	if caster:HasModifier("modifier_siege_mode") then
		range = caster:FindAbilityByName("keen_commander_siege_mode"):GetLevelSpecialValueFor("mortar_shot_range", ability:GetLevel() - 1)
		interval = interval / 2
		duration = duration / 2
 	end
	local range_interval = range / shots

	local time = 0
	local new_range = range + 200
	Timers:CreateTimer(0, function() 
		time = time + interval
		
		origin = caster:GetAbsOrigin()
		vector = caster:GetForwardVector()
		new_range = new_range - range_interval
		point = origin + vector * new_range

		local thinker = CreateModifierThinker(caster, ability, "modifier_mortar_shot_marker", {}, point, caster:GetTeamNumber(), false)
		local fire = caster:FindAbilityByName("keen_commander_mortar_shot_siege")
		ability:CreateVisibilityNode(point, 300, 3.0)
		caster:CastAbilityOnPosition(point, fire, caster:GetPlayerID())


		if time > duration then
			time = 0
			return nil
		else
			return interval
		end
	end)

end

