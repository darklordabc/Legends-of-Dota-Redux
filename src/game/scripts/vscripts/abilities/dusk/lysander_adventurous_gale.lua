lysander_adventurous_gale = class({})

LinkLuaModifier("modifier_adventurous_gale","abilities/dusk/lysander_adventurous_gale",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_adventurous_gale_movespeed","abilities/dusk/lysander_adventurous_gale",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_adventurous_gale_buff","abilities/dusk/lysander_adventurous_gale",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_adventurous_gale_push","abilities/dusk/lysander_adventurous_gale",LUA_MODIFIER_MOTION_NONE)

function lysander_adventurous_gale:OnSpellStart()
	if IsServer() then
		local caster = self:GetCaster()

		local direction = caster:GetForwardVector()

		local distance = self:GetSpecialValueFor("distance")

		local target_point = direction*distance

		local friendlyteam = caster:GetTeamNumber()

		local enemyteam = caster:GetOpposingTeamNumber()

		local duration = self:GetSpecialValueFor("duration")

		for i=1,10 do
			CreateModifierThinker( caster, self, "modifier_adventurous_gale_movespeed", {Duration=duration}, caster:GetAbsOrigin()+direction*distance/i, caster:GetTeamNumber(), false )
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

		caster:AddNewModifier(caster, self, "modifier_adventurous_gale", {Duration=2.5}) --[[Returns:void
		No Description Set
		]]
	  
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
end

modifier_adventurous_gale = class({})

function modifier_adventurous_gale:CheckState()
	local states = {
		[MODIFIER_STATE_ROOTED] = true
	}
	return states
end

function modifier_adventurous_gale:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_DISABLE_TURNING
	}
	return funcs
end

function modifier_adventurous_gale:GetModifierDisableTurning()
	return 1
end

function modifier_adventurous_gale:IsAura()
	return true
end

function modifier_adventurous_gale:GetAuraDuration()
	return 0.4
end

function modifier_adventurous_gale:GetAuraRadius()
	return 200
end

function modifier_adventurous_gale:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_adventurous_gale:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_CREEP
end

function modifier_adventurous_gale:GetModifierAura()
	return "modifier_adventurous_gale_push"
end

function modifier_adventurous_gale:OnDestroy()
end

function modifier_adventurous_gale:IsHidden()
	return true
end

function modifier_adventurous_gale:OnCreated()
	if IsServer() then
		self:StartIntervalThink(0.1)
	end
end

function modifier_adventurous_gale:OnIntervalThink()
	if IsServer() then
		GridNav:DestroyTreesAroundPoint(self:GetParent():GetAbsOrigin(),self:GetAbility():GetSpecialValueFor("radius"),true)
	end
end

modifier_adventurous_gale_movespeed = class({})

function modifier_adventurous_gale_movespeed:IsAura()
	return true
end

function modifier_adventurous_gale_movespeed:GetAuraDuration()
	return 0.25
end

function modifier_adventurous_gale_movespeed:GetAuraRadius()
	return self:GetAbility():GetSpecialValueFor("radius")
end

function modifier_adventurous_gale_movespeed:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_BOTH
end

function modifier_adventurous_gale_movespeed:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_CREEP
end

function modifier_adventurous_gale_movespeed:GetModifierAura()
	return "modifier_adventurous_gale_buff"
end

modifier_adventurous_gale_buff = class({})

function modifier_adventurous_gale_buff:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
	}
	return funcs
end

function modifier_adventurous_gale_buff:GetModifierMoveSpeedBonus_Percentage()
	local amt = self:GetAbility():GetSpecialValueFor("lingering_movespeed") --[[Returns:table
	No Description Set
	]]
	if IsServer() then
		local isenemy = 0

		if self:GetParent():GetTeam() == self:GetAbility():GetCaster():GetTeam() then
			isenemy = 0
		else
			isenemy = 1
		end

		self:SetStackCount(isenemy)
	end

	local mult = self:GetStackCount() == 0

	if mult then mult = 1 else mult = -1 end

	return mult * amt
end

function modifier_adventurous_gale_buff:IsDebuff()
		if self:GetParent():GetTeamNumber() == self:GetAbility():GetCaster():GetTeamNumber() then
			return false
		else
			return true
		end
end

modifier_adventurous_gale_push = class({})

function modifier_adventurous_gale_push:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
		MODIFIER_PROPERTY_DISABLE_TURNING
	}
	return funcs
end

function modifier_adventurous_gale_push:GetOverrideAnimation()
	return ACT_DOTA_FLAIL
end

function modifier_adventurous_gale_push:OnCreated()
	if IsServer() then
		local target = self:GetParent()
		local caster = self:GetAbility():GetCaster()

		self:StartIntervalThink(0.03)

		self.offset = caster:GetAbsOrigin() - self:GetParent():GetAbsOrigin()

		-- Physics:Unit(target)
	 --  	target:SetPhysicsFriction(0.00)
		-- target:PreventDI(false)
		--   -- To allow going through walls / cliffs add the following:
		-- target:FollowNavMesh(false)
		-- target:SetAutoUnstuck(false)
		-- target:SetNavCollisionType(PHYSICS_NAV_NOTHING)
		  
		-- target:SetPhysicsVelocity(direction * distance / 2.6)
		--   -- caster:AddPhysicsVelocity(Vector(0,0,distance/8))
		  
		-- target:SetPhysicsAcceleration(Vector(0,0,-(distance*2)))
	end
end

function modifier_adventurous_gale_push:OnIntervalThink()
	if IsServer() then
		local target = self:GetParent()
		local caster = self:GetAbility():GetCaster()

		-- local direction = caster.aw_direction
		-- local distance = caster.aw_distance

		offset = self.offset

		self:GetParent():SetAbsOrigin(caster:GetAbsOrigin()-offset)

		-- Physics:Unit(target)
	 --  	target:SetPhysicsFriction(0.00)
		-- target:PreventDI(false)
		--   -- To allow going through walls / cliffs add the following:
		-- target:FollowNavMesh(false)
		-- target:SetAutoUnstuck(false)
		-- target:SetNavCollisionType(PHYSICS_NAV_NOTHING)
		  
		-- target:SetPhysicsVelocity(direction * distance / 2.6)
		--   -- caster:AddPhysicsVelocity(Vector(0,0,distance/8))
		  
		-- target:SetPhysicsAcceleration(Vector(0,0,-(distance*2)))
	end
end

function modifier_adventurous_gale_push:IsHidden()
	return true
end

function modifier_adventurous_gale_push:OnDestroy()
	if IsServer() then

		local target = self:GetParent()

		-- target:SetPhysicsVelocity(Vector(0,0,0))
		FindClearSpaceForUnit(target,target:GetAbsOrigin(),false)

	end
end

function modifier_adventurous_gale_push:CheckState()
	local state = {
		[MODIFIER_STATE_DISARMED] = true,
		[MODIFIER_STATE_SILENCED] = true,
		[MODIFIER_STATE_ROOTED] = true
	}
	return state
end