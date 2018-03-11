if IsServer() then
	require('lib/timers')
end

--[[
	Author: Noya https://github.com/MNoya/DotaCraft/blob/master/game/dota_addons/dotacraft/scripts/vscripts/heroes/tinker/cluster_rockets.lua
	Date: 03.02.2015.
	Fires a tracking projectile to a random position in a radius of the area targeted previously. Area increases with engineering_upgrade levels
]]
function FireClusterRocket( event )
	-- Variables
	local caster = event.caster
	local ability = event.ability
	local point = ability.point
	local radius =  ability:GetLevelSpecialValueFor( "radius" , ability:GetLevel() - 1  )
	local projectile_count =  ability:GetLevelSpecialValueFor( "projectile_count" , ability:GetLevel() - 1  )
	local projectile_speed =  ability:GetLevelSpecialValueFor( "projectile_speed" , ability:GetLevel() - 1  )
	local particleName = "particles/units/heroes/hero_tinker/tinker_missile.vpcf"

	-- Create a dummy on the area to make the rocket track it
	local random_position = point + RandomVector(RandomInt(0,radius))
	local dummy = CreateUnitByName("dummy_unit_vulnerable", random_position, false, caster, caster, DOTA_UNIT_TARGET_TEAM_ENEMY)

	local projTable = {
		EffectName = particleName,
		Ability = ability,
		Target = dummy,
		Source = caster,
		bDodgeable = false,
		bProvidesVision = false,
		vSpawnOrigin = caster:GetAbsOrigin(),
		iMoveSpeed = projectile_speed,
		iVisionRadius = 0,
		iVisionTeamNumber = caster:GetTeamNumber(),
		iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1
	}
	ProjectileManager:CreateTrackingProjectile( projTable )

	Timers:CreateTimer(10,function() dummy:RemoveSelf() end)

end

-- Keep track of the targeted point to make the rockets
function StartClusterRockets( event )
	-- Variables
	local caster = event.caster
	local ability = event.ability
	ability.point = event.target_points[1]
end