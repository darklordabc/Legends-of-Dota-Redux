function grapeshot_aghanims(keys)
	local caster = keys.caster

	if caster:HasScepter() and not caster:HasModifier("modifier_grapeshot_aghanims_crit_timer") and not caster:HasModifier("modifier_grapeshot_aghanims_crit") then
		keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_grapeshot_aghanims_crit_timer", {}) --[[Returns:void
		No Description Set
		]]
	end
end

function grapeshot(keys)
	local caster = keys.caster
	local target = keys.target
	local cpos = caster:GetCenter()
	local tpos = target:GetCenter()

	local stun = keys.stun
	local range_ministun = keys.range_ministun
	local mult = keys.mult

	local crit = keys.crit
	local crit_mult = keys.crit_mult
	local crit_stun = keys.crit_stun

	local ad = caster:GetAverageTrueAttackDamage(caster)

	local bd = keys.base_dmg

	local guaranteed_crit = caster:HasModifier("modifier_grapeshot_aghanims_crit")

	local r = RandomInt(0,100)

	if caster:HasScepter() then
		r = 999
		crit_stun = crit_stun*2
	end

	if CheckClass(target,"npc_dota_building") then
		r = 999
		guaranteed_crit = false
		mult = mult*0.5
	end

	if guaranteed_crit then
		r = 0
		caster:RemoveModifierByName("modifier_grapeshot_aghanims_crit") --[[Returns:void
		Removes a modifier
		]]
	end

	if caster.has_fired then -- prevent aoe grapeshots from critting
		r = 999
		stun = stun*0.5
	end

	print("CRIT: "..r.." with guaranteed crit as "..tostring(guaranteed_crit).." and multiplying damage by "..crit_mult.." ("..crit_mult*ad..") and stunning for "..crit_stun)

	caster:EmitSound("Hero_Kunkka.InverseBayonet")

	if caster:HasScepter() and not caster.has_fired then
		
		local enemy = FindUnitsInRadius( caster:GetTeamNumber(),
                          target:GetCenter(),
                          nil,
		                    800,
		                    DOTA_UNIT_TARGET_TEAM_ENEMY,
		                    DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_CREEP,
		                    DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
		                    FIND_CLOSEST,
		                    false)
		for k,v in pairs(enemy) do
			if v ~= target then
				caster.has_fired = true
				caster:SetCursorCastTarget(v) --[[Returns:void
				No Description Set
				]]
				keys.ability:OnSpellStart()
				caster.has_fired = false
			end
		end
	end

	Timers:CreateTimer(0.2,function()

	if r > crit then
		local p = ParticleManager:CreateParticle("particles/units/heroes/hero_lysander/grapeshot.vpcf", PATTACH_POINT_FOLLOW, target) --[[Returns:int
		Creates a new particle effect
		]]
		ParticleManager:SetParticleControl(p, 0, tpos) --[[Returns:void
		Set the control point data for a control on a particle effect
		]]
		ParticleManager:SetParticleControl(p, 1, cpos) --[[Returns:void
		Set the control point data for a control on a particle effect
		]]

		if caster:GetRangeToUnit(target) <= range_ministun then
			if target:IsHero() then
				target:AddNewModifier(caster, nil, "modifier_stunned", {Duration=stun}) --[[Returns:void
				No Description Set
				]]
				ScreenShake(caster:GetCenter(), 100, 4, 0.4, 600, 0, true)
			end
			if target:IsCreep() then
				if target:GetName() == "npc_dota_roshan" then
					target:AddNewModifier(caster, nil, "modifier_stunned", {Duration=stun*2}) --[[Returns:void
					No Description Set
					]]
				else
					target:AddNewModifier(caster, nil, "modifier_stunned", {Duration=stun*3}) --[[Returns:void
					No Description Set
					]]
				end
				ScreenShake(caster:GetCenter(), 100, 4, 0.4, 600, 0, true)
			end
		end
		DealDamage(target,caster,ad*mult+bd,DAMAGE_TYPE_PHYSICAL)
	else
		target:EmitSound("Hero_Silencer.LastWord.Damage")
		local p = ParticleManager:CreateParticle("particles/units/heroes/hero_lysander/grapeshot_crit.vpcf", PATTACH_POINT_FOLLOW, target) --[[Returns:int
		Creates a new particle effect
		]]
		ParticleManager:SetParticleControl(p, 0, tpos) --[[Returns:void
		Set the control point data for a control on a particle effect
		]]
		ParticleManager:SetParticleControl(p, 1, cpos) --[[Returns:void
		Set the control point data for a control on a particle effect
		]]
		if target:IsHero() then
			target:AddNewModifier(caster, nil, "modifier_stunned", {Duration=crit_stun}) --[[Returns:void
			No Description Set
			]]
			ScreenShake(caster:GetCenter(), 100, 4, 0.4, 600, 0, true)
		end
		if target:IsCreep() then
			if target:GetName() == "npc_dota_roshan" then
				target:AddNewModifier(caster, nil, "modifier_stunned", {Duration=crit_stun*2}) --[[Returns:void
				No Description Set
				]]
			else
				target:AddNewModifier(caster, nil, "modifier_stunned", {Duration=crit_stun*3}) --[[Returns:void
				No Description Set
				]]
			end
			ScreenShake(caster:GetCenter(), 100, 4, 0.4, 600, 0, true)
		end
		DealDamage(target,caster,ad*crit_mult+bd,DAMAGE_TYPE_PHYSICAL)
		keys.ability:EndCooldown()
	end
	end)
end

function captains_compass(keys)
	local caster = keys.caster
	local target = keys.target

	caster.compass_target = target

	caster:EmitSound("Hero_KeeperOfTheLight.ChakraMagic.Target")
end

function captains_compass_check_distance(keys)
	local caster = keys.caster
	local target = caster.compass_target

	if caster.lastcheck == nil then caster.lastcheck = caster:GetRangeToUnit(target) return end

	if caster:GetRangeToUnit(target) < caster.lastcheck then
		keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_lysander_captains_compass_speed", {}) --[[Returns:void
		No Description Set
		]]
	else
		caster:RemoveModifierByName("modifier_lysander_captains_compass_speed")
		caster:RemoveModifierByName("modifier_bloodseeker_thirst")
	end

	caster.lastcheck = caster:GetRangeToUnit(target)
end

function captains_compasscleanup(keys)
	local caster = keys.caster
	caster.compass_target = nil
	caster:RemoveModifierByName("modifier_lysander_captains_compass_speed")
	caster:RemoveModifierByName("modifier_lysander_captains_compass_user")
end

function adventurous_gale(keys)
	local caster = keys.caster

	local direction = caster:GetForwardVector()

	local distance = keys.distance

	local target_point = direction*distance

	local friendlyteam = caster:GetTeamNumber()

	local enemyteam = caster:GetOpposingTeamNumber()

	for i=1,10 do
		local n = FastDummy(caster:GetAbsOrigin()+direction*distance/i,caster:GetTeam(),8,250)
		keys.ability:ApplyDataDrivenModifier(caster, n, "modifier_lysander_adventurous_gale_speed_trail_aura", {}) --[[Returns:void
		No Description Set
		]]
		keys.ability:ApplyDataDrivenModifier(caster, n, "modifier_lysander_adventurous_gale_speed_trail_aura_enemy", {}) --[[Returns:void
		No Description Set
		]]
	end

	local p = ParticleManager:CreateParticleForTeam("particles/units/heroes/hero_lysander/mystical_wave.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster, friendlyteam) --[[Returns:int
	Creates a new particle effect
	]]

	ParticleManager:SetParticleControl(p, 0, Vector(0,0,0)) --[[Returns:void
	Set the control point data for a control on a particle effect
	]]

	ParticleManager:SetParticleControl(p, 1, target_point) --[[Returns:void
	Set the control point data for a control on a particle effect
	]]

	local caster_dupe = FastDummy(caster:GetAbsOrigin(),caster:GetOpposingTeamNumber(),8,0)
	Physics:Unit(caster_dupe)
  	caster_dupe:SetPhysicsFriction(0)
	caster_dupe:PreventDI(true)
	  -- To allow going through walls / cliffs add the following:
	caster_dupe:FollowNavMesh(false)
	caster_dupe:SetAutoUnstuck(false)
	caster_dupe:SetNavCollisionType(PHYSICS_NAV_NOTHING)
	  
	caster_dupe:SetPhysicsVelocity(direction * distance / 2.5)
	  -- caster:AddPhysicsVelocity(Vector(0,0,distance/8))
	  
	caster_dupe:SetPhysicsAcceleration(Vector(0,0,-(distance*2)))
  

	local p3 = ParticleManager:CreateParticleForTeam("particles/units/heroes/hero_lysander/mystical_wave.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster_dupe, enemyteam) --[[Returns:int
	Creates a new particle effect
	]]

	ParticleManager:SetParticleControl(p3, 0, Vector(0,0,0)) --[[Returns:void
	Set the control point data for a control on a particle effect
	]]

	ParticleManager:SetParticleControl(p3, 1, target_point) --[[Returns:void
	Set the control point data for a control on a particle effect
	]]

	caster:EmitSound("Ability.pre.Torrent")
	Timers:CreateTimer(2.2,function() caster:EmitSound("Ability.Torrent") end)

	caster.aw_direction = direction
	caster.aw_distance = distance

	Physics:Unit(caster)
  	caster:SetPhysicsFriction(0)
	caster:PreventDI(true)
	  -- To allow going through walls / cliffs add the following:
	caster:FollowNavMesh(false)
	caster:SetAutoUnstuck(false)
	caster:SetNavCollisionType(PHYSICS_NAV_NOTHING)
	  
	caster:SetPhysicsVelocity(direction * distance / 2.5)
	  -- caster:AddPhysicsVelocity(Vector(0,0,distance/8))
	  
	caster:SetPhysicsAcceleration(Vector(0,0,-(distance*2)))
  
  Timers:CreateTimer(2.3,function()
    caster:SetPhysicsVelocity(Vector(0,0,0))
--    FindClearSpaceForUnit(caster,caster:GetAbsOrigin(),true)
    caster:PreventDI(false)
    local p2 = ParticleManager:CreateParticle("particles/units/heroes/hero_kunkka/kunkka_boat_splash_end_gurgle.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster) --[[Returns:int
	Creates a new particle effect
	]]
  end
  )
  Timers:CreateTimer(2.31,function()
    FindClearSpaceForUnit(caster,caster:GetAbsOrigin(),false)
    ParticleManager:DestroyParticle(p,false)
    ParticleManager:DestroyParticle(p3,false)
  end
  )
end

function adventurous_gale_transfer_momentum(keys)
	local caster = keys.caster
	local target = keys.target

	local direction = caster.aw_direction
	local distance = caster.aw_distance

	Physics:Unit(target)
  	target:SetPhysicsFriction(0)
	target:PreventDI(false)
	  -- To allow going through walls / cliffs add the following:
	target:FollowNavMesh(false)
	target:SetAutoUnstuck(false)
	target:SetNavCollisionType(PHYSICS_NAV_NOTHING)
	  
	target:SetPhysicsVelocity(direction * distance / 2.5)
	  -- caster:AddPhysicsVelocity(Vector(0,0,distance/8))
	  
	target:SetPhysicsAcceleration(Vector(0,0,-(distance*2)))
end

function adventurous_gale_stop_momentum(keys)
	local caster = keys.caster
	local target = keys.target

	target:SetPhysicsVelocity(Vector(0,0,0))
	FindClearSpaceForUnit(target,target:GetAbsOrigin(),false)
end

function phantom_fleet_start(keys)
	local caster = keys.caster
	local pos = caster:GetCursorPosition()
	local direction = (pos - caster:GetAbsOrigin()):Normalized()
	local qdirection = VectorToAngles(direction)
	local start_pos = caster:GetAbsOrigin() + direction*-1200
	local start_pos_2 = caster:GetAbsOrigin() + direction*-1600+(Vector(0,700,0)*direction)
	local start_pos_3 = caster:GetAbsOrigin() + direction*-1600+(Vector(0,-700,0)*direction)

	local duration = keys.duration

	local damage = keys.damage
	local speed = keys.speed
	local min_int = keys.minimum_interval
	local max_int = keys.maximum_interval
	local int = keys.interval

	local unit = FastDummy(start_pos,caster:GetTeam(),duration+2,800)
	-- local unit2 = FastDummy(start_pos_2,caster:GetTeam(),duration+2,800)
	-- local unit3 = FastDummy(start_pos_3,caster:GetTeam(),duration+2,800)
	--caster:EmitSound("Ability.Ghostship.bell")
	unit:EmitSound("Ability.Ghostship")

	keys.ability:ApplyDataDrivenModifier(caster, unit, "modifier_lysander_phantom_fleet_aura", {Duration=duration}) --[[Returns:void
	No Description Set
	]]
	local p_main = ParticleManager:CreateParticle("particles/units/heroes/hero_lysander/phantom_fleet_ship_main.vpcf", PATTACH_ABSORIGIN_FOLLOW, unit) --[[Returns:int
	Creates a new particle effect
	]]

	ParticleManager:SetParticleControl(p_main, 0, unit:GetAbsOrigin()) --[[Returns:void
	Set the control point data for a control on a particle effect
	]]
	ParticleManager:SetParticleControl(p_main, 1, unit:GetAbsOrigin()+direction*speed*duration*3) --[[Returns:void
	Set the control point data for a control on a particle effect
	]]

	-- local p_side1 = ParticleManager:CreateParticle("particles/units/heroes/hero_lysander/phantom_fleet_ship_main.vpcf", PATTACH_ABSORIGIN_FOLLOW, unit2) --[[Returns:int
	-- Creates a new particle effect
	-- ]]

	-- ParticleManager:SetParticleControl(p_side1, 0, unit2:GetAbsOrigin()) --[[Returns:void
	-- Set the control point data for a control on a particle effect
	-- ]]
	-- ParticleManager:SetParticleControl(p_side1, 1, unit2:GetAbsOrigin()+direction*speed*duration*3) --[[Returns:void
	-- Set the control point data for a control on a particle effect
	-- ]]

	-- local p_side2 = ParticleManager:CreateParticle("particles/units/heroes/hero_lysander/phantom_fleet_ship_main.vpcf", PATTACH_ABSORIGIN_FOLLOW, unit3) --[[Returns:int
	-- Creates a new particle effect
	-- ]]

	-- ParticleManager:SetParticleControl(p_side2, 0, unit3:GetAbsOrigin()) --[[Returns:void
	-- Set the control point data for a control on a particle effect
	-- ]]
	-- ParticleManager:SetParticleControl(p_side2, 1, unit3:GetAbsOrigin()+direction*speed*duration*3) --[[Returns:void
	-- Set the control point data for a control on a particle effect
	-- ]]


	Physics:Unit(unit)
  	unit:SetPhysicsFriction(0)
	unit:PreventDI(true)
	  -- To allow going through walls / cliffs add the following:
	unit:FollowNavMesh(false)
	unit:SetAutoUnstuck(false)
	unit:SetNavCollisionType(PHYSICS_NAV_NOTHING)
	  
	unit:SetPhysicsVelocity(direction * speed)
	  -- caster:AddPhysicsVelocity(Vector(0,0,distance/8))

	unit:SetPhysicsAcceleration(Vector(0,0,-speed*4))

	-- Physics:Unit(unit2)
 --  	unit2:SetPhysicsFriction(0)
	-- unit2:PreventDI(true)
	--   -- To allow going through walls / cliffs add the following:
	-- unit2:FollowNavMesh(false)
	-- unit2:SetAutoUnstuck(false)
	-- unit2:SetNavCollisionType(PHYSICS_NAV_NOTHING)
	  
	-- unit2:SetPhysicsVelocity(direction * speed)
	--   -- caster:AddPhysicsVelocity(Vector(0,0,distance/8))

	-- unit2:SetPhysicsAcceleration(Vector(0,0,-speed*4))

	-- Physics:Unit(unit3)
 --  	unit3:SetPhysicsFriction(0)
	-- unit3:PreventDI(true)
	--   -- To allow going through walls / cliffs add the following:
	-- unit3:FollowNavMesh(false)
	-- unit3:SetAutoUnstuck(false)
	-- unit3:SetNavCollisionType(PHYSICS_NAV_NOTHING)
	  
	-- unit3:SetPhysicsVelocity(direction * speed)
	--   -- caster:AddPhysicsVelocity(Vector(0,0,distance/8))

	-- unit3:SetPhysicsAcceleration(Vector(0,0,-speed*4))

	Timers:CreateTimer("fleet_timer",{
		endTime = 1.5,
		callback = function()
		local direction = RotatePosition(Vector(0,0,0), QAngle(0,RandomInt(-8,8),0), direction)
	local info = 
	  {
	  Ability = keys.ability,
	  EffectName = "particles/units/heroes/hero_lysander/phantom_fleet_cannoball.vpcf",
	  vSpawnOrigin = unit:GetAbsOrigin()+Vector(0,0,100)+direction*350+(Vector(0,0,0)*direction),
	  fDistance = speed*duration*1,
	  fStartRadius = 100,
	  fEndRadius = 100,
	  Source = caster,
	  bHasFrontalCone = false,
	  bReplaceExisting = false,
	  iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
	  iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
	  iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_BUILDING,
	  fExpireTime = GameRules:GetGameTime() + 10.0,
	  vVelocity = (direction) * 1500,
	  bProvidesVision = true,
	  iVisionRadius = 600,
	  iVisionTeamNumber = caster:GetTeamNumber()
	  }
	  ProjectileManager:CreateLinearProjectile(info)
	  unit:EmitSound("Hero_Gyrocopter.HomingMissile.Destroy")
	  ScreenShake(unit:GetCenter(), 100, 4, 0.4, 1200, 0, true)
	-- local info = 
	--   {
	--   Ability = keys.ability,
	--   EffectName = "particles/units/heroes/hero_lysander/phantom_fleet_cannoball.vpcf",
	--   vSpawnOrigin = unit2:GetAbsOrigin()+Vector(0,0,100)+(Vector(0,245,0)*direction),
	--   fDistance = speed*duration*0.8,
	--   fStartRadius = 150,
	--   fEndRadius = 150,
	--   Source = caster,
	--   bHasFrontalCone = false,
	--   bReplaceExisting = false,
	--   iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
	--   iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
	--   iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
	--   fExpireTime = GameRules:GetGameTime() + 10.0,
	--   vVelocity = direction * 1500,
	--   bProvidesVision = true,
	--   iVisionRadius = 600,
	--   iVisionTeamNumber = caster:GetTeamNumber()
	--   }
	--   local projectile = ProjectileManager:CreateLinearProjectile(info)
	--   ScreenShake(unit2:GetCenter(), 100, 4, 0.4, 1200, 0, true)
	-- local info = 
	--   {
	--   Ability = keys.ability,
	--   EffectName = "particles/units/heroes/hero_lysander/phantom_fleet_cannoball.vpcf",
	--   vSpawnOrigin = unit3:GetAbsOrigin()+Vector(0,0,100)+(Vector(0,245,0)*direction),
	--   fDistance = speed*duration*0.8,
	--   fStartRadius = 150,
	--   fEndRadius = 150,
	--   Source = caster,
	--   bHasFrontalCone = false,
	--   bReplaceExisting = false,
	--   iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
	--   iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
	--   iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
	--   fExpireTime = GameRules:GetGameTime() + 10.0,
	--   vVelocity = direction * 1500,
	--   bProvidesVision = true,
	--   iVisionRadius = 600,
	--   iVisionTeamNumber = caster:GetTeamNumber()
	--   }
	--   local projectile = ProjectileManager:CreateLinearProjectile(info)
	--   ScreenShake(unit3:GetCenter(), 100, 4, 0.4, 1200, 0, true)
	  return 1
	end})

	Timers:CreateTimer("fleet_timer2",{
		endTime = 1,
		callback = function()
		local direction = RotatePosition(Vector(0,0,0), QAngle(0,RandomInt(-8,8),0), direction)
	local info = 
	  {
	  Ability = keys.ability,
	  EffectName = "particles/units/heroes/hero_lysander/phantom_fleet_cannoball.vpcf",
	  vSpawnOrigin = unit:GetAbsOrigin()+Vector(0,0,100)+direction*350+(Vector(0,0,0)*direction),
	  fDistance = speed*duration*1,
	  fStartRadius = 100,
	  fEndRadius = 100,
	  Source = caster,
	  bHasFrontalCone = false,
	  bReplaceExisting = false,
	  iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
	  iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
	  iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_BUILDING,
	  fExpireTime = GameRules:GetGameTime() + 10.0,
	  vVelocity = (direction) * 1500,
	  bProvidesVision = true,
	  iVisionRadius = 600,
	  iVisionTeamNumber = caster:GetTeamNumber()
	  }
	  ProjectileManager:CreateLinearProjectile(info)
	  unit:EmitSound("Hero_Gyrocopter.HomingMissile.Destroy")
	  ScreenShake(unit:GetCenter(), 100, 4, 0.4, 1200, 0, true)
	-- local info = 
	--   {
	--   Ability = keys.ability,
	--   EffectName = "particles/units/heroes/hero_lysander/phantom_fleet_cannoball.vpcf",
	--   vSpawnOrigin = unit2:GetAbsOrigin()+Vector(0,0,100)+(Vector(0,-245,0)*direction),
	--   fDistance = speed*duration*0.8,
	--   fStartRadius = 150,
	--   fEndRadius = 150,
	--   Source = caster,
	--   bHasFrontalCone = false,
	--   bReplaceExisting = false,
	--   iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
	--   iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
	--   iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
	--   fExpireTime = GameRules:GetGameTime() + 10.0,
	--   vVelocity = direction * 1500,
	--   bProvidesVision = true,
	--   iVisionRadius = 600,
	--   iVisionTeamNumber = caster:GetTeamNumber()
	--   }
	--   local projectile = ProjectileManager:CreateLinearProjectile(info)
	--   ScreenShake(unit2:GetCenter(), 100, 4, 0.4, 1200, 0, true)
	-- local info = 
	--   {
	--   Ability = keys.ability,
	--   EffectName = "particles/units/heroes/hero_lysander/phantom_fleet_cannoball.vpcf",
	--   vSpawnOrigin = unit3:GetAbsOrigin()+Vector(0,0,100)+(Vector(0,-245,0)*direction),
	--   fDistance = speed*duration*0.8,
	--   fStartRadius = 150,
	--   fEndRadius = 150,
	--   Source = caster,
	--   bHasFrontalCone = false,
	--   bReplaceExisting = false,
	--   iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
	--   iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
	--   iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
	--   fExpireTime = GameRules:GetGameTime() + 10.0,
	--   vVelocity = direction * 1500,
	--   bProvidesVision = true,
	--   iVisionRadius = 600,
	--   iVisionTeamNumber = caster:GetTeamNumber()
	--   }
	--   local projectile = ProjectileManager:CreateLinearProjectile(info)
	-- ScreenShake(unit3:GetCenter(), 100, 4, 0.4, 1200, 0, true)
	  return 1
	end})

	Timers:CreateTimer(duration,function()
		ParticleManager:DestroyParticle(p_main,false)
		ParticleManager:DestroyParticle(p_side1,false)
		ParticleManager:DestroyParticle(p_side2,false)
		Timers:RemoveTimer("fleet_timer")
		Timers:RemoveTimer("fleet_timer2")
	end)
end

function phantom_fleet_hit_unit(keys)
	local caster = keys.caster
	local target = keys.target
	local damage = keys.damage
	local stun = keys.stun

	if CheckClass(target,"npc_dota_building") then
		damage = damage/4
		stun = 0
	end

	DealDamage(target,caster,damage,DAMAGE_TYPE_PHYSICAL)
	if stun > 0 then
		target:AddNewModifier(caster, nil, "modifier_stunned", {Duration=stun}) --[[Returns:void
		No Description Set
		]]
	end
end
