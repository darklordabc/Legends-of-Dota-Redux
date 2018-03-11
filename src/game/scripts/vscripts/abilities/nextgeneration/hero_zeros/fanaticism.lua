function AllyDistanceCheck( keys )
	local caster = keys.caster
	local ability = keys.ability
	local radius = ability:GetLevelSpecialValueFor("break_radius", ability:GetLevel() - 1)
	local modifierName = "modifier_fanatic_buff"
	
	local heroes = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, 0, 0, false)

	if #heroes == 1 then
		ability:ApplyDataDrivenModifier(caster, caster, modifierName, {})
	else
		caster:RemoveModifierByName(modifierName)
	end
end