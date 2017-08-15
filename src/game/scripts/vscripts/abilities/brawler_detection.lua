function brawler_detection( keys )
	local caster = keys.caster
	local modifierName = keys.modifier_name
	if caster:PassivesDisabled() then
		if caster:HasModifier( modifierName ) then
			caster:RemoveModifierByName( modifierName )
		end
		return
	end
	local ability = keys.ability
	local radius = ability:GetSpecialValueFor( "radius" )

	local units = FindUnitsInRadius( caster:GetTeamNumber(), caster:GetAbsOrigin(), caster, radius,
			DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, 0, 0, false )

	if #units ~= 0 and not caster:HasModifier( modifierName ) then
		ability:ApplyDataDrivenModifier( caster, caster, modifierName, {} )
	elseif #units == 0 and caster:HasModifier( modifierName ) then
		caster:RemoveModifierByName( modifierName )
	end
end
