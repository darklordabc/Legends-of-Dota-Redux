require('lib/physics')
function EvasiveRollInitiate( keys )
	local caster = keys.caster
	local ability = keys.ability
	local leap_speed = caster:GetMoveSpeedModifier(caster:GetBaseMoveSpeed()) + ability:GetLevelSpecialValueFor("bonus_speed", (ability:GetLevel() - 1))
	local casterAngles = caster:GetAngles()

	-- Clears any current command
	caster:Stop()
	local start_position = GetGroundPosition(caster:GetAbsOrigin() , caster)

	-- Physics
	local direction = caster:GetForwardVector()
	local velocity = leap_speed * 3.0
	local end_time = 0.6
	local time_elapsed = 0
	local time = 0.3
	local jump = 48
	local flip = 360 

	Physics:Unit(caster)

	caster:PreventDI(true)
	caster:SetAutoUnstuck(false)
	caster:SetNavCollisionType(PHYSICS_NAV_NOTHING)
	caster:FollowNavMesh(false)
	caster:SetPhysicsVelocity(-direction * velocity)
	
	-- Dodge projectiles


	-- Move the unit
	Timers:CreateTimer(0, function()
		local ground_position = GetGroundPosition(caster:GetAbsOrigin() , caster)
		time_elapsed = time_elapsed + 0.03
		local yaw = casterAngles.x - ((time_elapsed * 3) * flip)
		caster:SetAngles(yaw, casterAngles.y, casterAngles.z ) 
		if flip > 0 then flip = flip - 9 else flip = 0 end

		if time_elapsed < 0.3 then
			caster:SetAbsOrigin(caster:GetAbsOrigin() + Vector(0,0,jump))
			ProjectileManager:ProjectileDodge(caster)
			jump = jump - 2.4
		else
			caster:SetAbsOrigin(caster:GetAbsOrigin() - Vector(0,0,jump)) -- Going down
			jump = jump * 1.06
		end
		
		
		if caster:GetAbsOrigin().z - ground_position.z <= 0 then
			caster:SetAbsOrigin(GetGroundPosition(caster:GetAbsOrigin() , caster))

		end
		if time_elapsed > end_time and caster:GetAbsOrigin().z - ground_position.z <= 0 then 
			caster:SetAbsOrigin(GetGroundPosition(caster:GetAbsOrigin() , caster))
			caster:SetAngles(0, casterAngles.y, casterAngles.z )
			caster:SetPhysicsAcceleration(Vector(0,0,0))
			caster:SetPhysicsVelocity(Vector(0,0,0))
			caster:OnPhysicsFrame(nil)
			caster:PreventDI(false)
			caster:SetNavCollisionType(PHYSICS_NAV_SLIDE)
			caster:SetAutoUnstuck(true)
			caster:FollowNavMesh(true)
			caster:SetPhysicsFriction(.05)
			GridNav:DestroyTreesAroundPoint(caster:GetAbsOrigin(), 150, false)
			return nil
		end

		return 0.03
	end)
end