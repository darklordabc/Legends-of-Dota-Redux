--[[Adapted for use in Genos's Locomotion ability
	5/12/17]]

LinkLuaModifier("modifier_locomotion_vision", "heroes/hero_genos/modifiers/modifier_locomotion_vision.lua", LUA_MODIFIER_MOTION_NONE)

--[[Author: Pizzalol
	Date: 26.09.2015.
	Clears current caster commands and disjoints projectiles while setting up everything required for movement]]
function Leap( event )
	local caster = event.caster
	local ability = event.ability
	local ability_level = ability:GetLevel() - 1
	local point = event.target_points[1]	

	caster:AddNewModifier(caster, ability, "modifier_locomotion_vision", {})

	-- Clears any current command and disjoints projectiles
	caster:Stop()
	ProjectileManager:ProjectileDodge(caster)

	--local max_distance = ability:GetLevelSpecialValueFor("distance", ability_level) + (caster:FindModifierByName("modifier_flight_instinct_adaptations"):GetStackCount())*200
	local max_distance = ability:GetLevelSpecialValueFor("distance", ability_level) + caster.flight_instinct_adaptations*200
	local start_location = caster:GetAbsOrigin()

	local target_distance = (point - start_location):Length2D()

	if target_distance > max_distance then
		ability.leap_distance = max_distance
	else
		ability.leap_distance = target_distance
	end


	-- Ability variables
	ability.leap_direction = -(start_location - point):Normalized() --caster:GetForwardVector() 
	print("")
	print(ability.leap_direction)
	ability.leap_speed = 66 + (2/3) --ability:GetLevelSpecialValueFor("leap_speed", ability_level) * 1/30
	ability.leap_traveled = 0
	ability.leap_z = 0
end

--[[Moves the caster on the horizontal axis until it has traveled the distance]]
function LeapHorizonal( keys )
	local caster = keys.target
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1

	if ability.leap_traveled < ability.leap_distance then
		caster:SetAbsOrigin(caster:GetAbsOrigin() + ability.leap_direction * ability.leap_speed)

		ability.leap_traveled = ability.leap_traveled + ability.leap_speed
	else
		caster:InterruptMotionControllers(true)
		caster:RemoveModifierByName("modifier_locomotion_vision")
	end
end

--[[Moves the caster on the vertical axis until movement is interrupted]]
function LeapVertical( keys )
	local caster = keys.target
	local ability = keys.ability

	-- For the first half of the distance the unit goes up and for the second half it goes down
	if ability.leap_traveled < ability.leap_distance/2 then
		-- Go up
		-- This is to memorize the z point when it comes to cliffs and such although the division of speed by 2 isnt necessary, its more of a cosmetic thing
		ability.leap_z = ability.leap_z + ability.leap_speed/2
		-- Set the new location to the current ground location + the memorized z point
		caster:SetAbsOrigin(GetGroundPosition(caster:GetAbsOrigin(), caster) + Vector(0,0,ability.leap_z))
	else
		-- Go down
		ability.leap_z = ability.leap_z - ability.leap_speed/2
		caster:SetAbsOrigin(GetGroundPosition(caster:GetAbsOrigin(), caster) + Vector(0,0,ability.leap_z))
	end
end