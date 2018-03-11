require('lib/physics')
lysander_phantom_fleet = class({})

LinkLuaModifier("modifier_phantom_fleet_slow","abilities/dusk/lysander_phantom_fleet",LUA_MODIFIER_MOTION_NONE)

if IsServer() then
	function lysander_phantom_fleet:OnSpellStart()
		local caster = self:GetCaster()
		local pos = self:GetCursorPosition()

		self.ship_number = self.ship_number or 0

		self.ship_number = self.ship_number+1

		local ship_number = self.ship_number

		local direction = (pos - caster:GetAbsOrigin()):Normalized()

		local start_pos = caster:GetAbsOrigin() + direction*-1200

		local duration = self:GetSpecialValueFor("duration")

		local damage = self:GetSpecialValueFor("damage")
		local speed = self:GetSpecialValueFor("speed")
		local min_int = self:GetSpecialValueFor("minimum_interval")
		local max_int = self:GetSpecialValueFor("maximum_interval")
		local int = self:GetSpecialValueFor("interval")

		local unit = FastDummy(start_pos,caster:GetTeam(),duration+2,800)
		unit:EmitSound("Ability.Ghostship")

		unit:AddNewModifier(caster, self, "modifier_phantom_fleet_slow", {Duration=duration}) --[[Returns:void
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

		Timers:CreateTimer("fleet_timer_ship"..ship_number,{
			endTime = 1.5,
			callback = function()
			local direction = RotatePosition(Vector(0,0,0), QAngle(0,RandomInt(-8,8),0), direction)
			direction.z = 0
		local info = 
		  {
		  Ability = self,
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
		  return 1
		end})

		Timers:CreateTimer("fleet_timer2_ship"..ship_number,{
			endTime = 1,
			callback = function()
			local direction = RotatePosition(Vector(0,0,0), QAngle(0,RandomInt(-8,8),0), direction)
			direction.z = 0
		local info = 
		  {
		  Ability = self,
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
		  return 1
		end})

		Timers:CreateTimer(duration,function()
			ParticleManager:DestroyParticle(p_main,false)
			-- ParticleManager:DestroyParticle(p_side1,false)
			-- ParticleManager:DestroyParticle(p_side2,false)
			Timers:RemoveTimer("fleet_timer_ship"..ship_number)
			Timers:RemoveTimer("fleet_timer2_ship"..ship_number)
			self.ship_number = nil
		end)
	end

	function lysander_phantom_fleet:OnProjectileHit(hTarget, vLocation)
		if hTarget then
			local stun = self:GetSpecialValueFor("ministun")
			local damage = self:GetSpecialValueFor("damage")
			hTarget:AddNewModifier(self:GetCaster(), self, "modifier_stunned", {Duration=stun}) --[[Returns:void
			No Description Set
			]]
			InflictDamage(hTarget,self:GetCaster(),self,damage,DAMAGE_TYPE_PHYSICAL)
		end
	end
end

modifier_phantom_fleet_slow = class({})

function modifier_phantom_fleet_slow:IsAura()
	return true
end

function modifier_phantom_fleet_slow:GetAuraDuration()
	return 0.5
end

function modifier_phantom_fleet_slow:GetAuraRadius()
	return 400
end

function modifier_phantom_fleet_slow:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_phantom_fleet_slow:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_CREEP
end

function modifier_phantom_fleet_slow:GetModifierAura()
	return "modifier_phantom_fleet_slow_buff"
end

modifier_phantom_fleet_slow_buff = class({})

function modifier_phantom_fleet_slow_buff:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
	}
	return funcs
end

function modifier_phantom_fleet_slow_buff:GetModifierMoveSpeedBonus_Percentage()
	return -self:GetSpecialValueFor("slow")
end

function InflictDamage(target,attacker,ability,damage,damage_type,flags)
	local flags = flags or 0
	ApplyDamage({
	    victim = target,
	    attacker = attacker,
	    damage = damage,
	    damage_type = damage_type,
	    damage_flags = flags,
	    ability = ability
  	})
end

function FastDummy(target, team, duration, vision)
  duration = duration or 0.03
  vision = vision or  250
  local dummy = CreateUnitByName("npc_dummy_unit", target, false, nil, nil, team)
  if dummy ~= nil then
    dummy:SetAbsOrigin(target)
    dummy:SetDayTimeVisionRange(vision)
    dummy:SetNightTimeVisionRange(vision)
    dummy:AddNewModifier(dummy, nil, "modifier_phased", { duration = 9999})
    dummy:AddNewModifier(dummy, nil, "modifier_invulnerable", { duration = 9999})
    dummy:AddNewModifier(dummy, nil, "modifier_kill", {duration = duration+0.03})
      Timers:CreateTimer(duration,function()
        if not dummy:IsNull() then
          dummy:ForceKill(true)
          --dummy:Destroy()
          UTIL_Remove(dummy)
        end
      end)
  end
  return dummy
end
