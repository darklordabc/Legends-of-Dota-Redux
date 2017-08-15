function brawler_detection( keys )
	local caster = keys.caster
	if caster:PassivesDisabled() then return end
	local ability = keys.ability
	local radius = ability:GetSpecialValueFor( "radius" )
	local modifierName = keys.modifier_name

	local units = FindUnitsInRadius( caster:GetTeamNumber(), caster:GetAbsOrigin(), caster, radius,
			DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, 0, 0, false )

	if #units ~= 0 and not caster:HasModifier( modifierName ) then
		ability:ApplyDataDrivenModifier( caster, caster, modifierName, {} )
	elseif #units == 0 and caster:HasModifier( modifierName ) then
		caster:RemoveModifierByName( modifierName )
	end
end
