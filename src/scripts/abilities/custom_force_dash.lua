function ForceDash(keys)
	local caster = keys.caster

	local ability = keys.ability
	local modifier = keys.modifier
	-- Distance calculations
	local distance = ability:GetLevelSpecialValueFor("distance", (ability:GetLevel() - 1))
	local direction = caster:GetForwardVector()
	local duration = ability:GetLevelSpecialValueFor("duration", (ability:GetLevel() - 1))
	local speed = distance/duration

	-- Saving the data in the ability
	ability.distance = distance
	ability.speed = speed * 1/30 -- 1/30 is how often the motion controller ticks
	ability.direction = direction
	ability.traveled_distance = 0
	
	ability:ApplyDataDrivenModifier(caster, caster, modifier, {duration = duration})
end

function ForceMotion( keys )
	local caster = keys.target
	local ability = keys.ability
	-- Move the caster while the distance traveled is less than the original distance upon cast
	if ability.traveled_distance < ability.distance then
		caster:SetAbsOrigin(caster:GetAbsOrigin() + ability.direction * ability.speed)
		ability.traveled_distance = ability.traveled_distance + ability.speed
	else
		-- Remove the motion controller once the distance has been traveled
		caster:InterruptMotionControllers(false)
		caster:RemoveModifierByName("modifier_force_dash")
	end
end