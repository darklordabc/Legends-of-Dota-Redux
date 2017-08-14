--[[
	Author: kritth
	Date: 1.1.2015.
	Check number of units every interval
	Note: Might be possible to do entirely in datadriven, however, I seem to crash everytime I tried
	to do so, insteads, I just use simple script
  
  Reversed as Brawler by 01der
]]
function brawler_detection( keys )
	local caster = keys.caster
	local ability = keys.ability
	local radius = ability:GetLevelSpecialValueFor( "radius", ( ability:GetLevel() - 1 ) )
	local modifierName = "modifier_brawler_int_effect_datadriven"
	
	if caster:PassivesDisabled() then return end
	
	-- Count units in radius
	local units = FindUnitsInRadius( caster:GetTeamNumber(), caster:GetAbsOrigin(), caster, radius,
			DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, 0, 0, false )
	local count = 0
	for k, v in pairs( units ) do
		count = count + 1
	end
	
	-- If Passives are Disabled, set count to 0, which for this specific ability, will lead to it being disabled
	if caster:PassivesDisabled() then 
		count = 0
	end
	
	-- Apply and destroy
	if count ~= 0 and not caster:HasModifier( modifierName ) then
		ability:ApplyDataDrivenModifier( caster, caster, modifierName, {} )
	elseif count == 0 and caster:HasModifier( modifierName ) then
		caster:RemoveModifierByName( modifierName )
	end
end
