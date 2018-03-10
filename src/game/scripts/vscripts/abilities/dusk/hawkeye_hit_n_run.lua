hawkeye_hit_n_run = class({})

LinkLuaModifier("modifier_hit_n_run_thinker","abilities/dusk/hawkeye_hit_n_run",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_hit_n_run_slow","abilities/dusk/hawkeye_hit_n_run",LUA_MODIFIER_MOTION_NONE)

function hawkeye_hit_n_run:OnSpellStart()
	if IsServer() then
		local c = self:GetCaster()
		local facing = c:GetForwardVector()
		local distance = self:GetSpecialValueFor("distance")
		local duration = self:GetSpecialValueFor("duration")
		local damage = self:GetAbilityDamage()
		local radius = self:GetSpecialValueFor("radius")

		ProjectileManager:ProjectileDodge(c)

		local en = FindEnemies(c,c:GetAbsOrigin(),radius)

		for k,v in pairs(en) do
			InflictDamage(v,c,self,damage,DAMAGE_TYPE_MAGICAL)
		end

		local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_centaur/centaur_warstomp.vpcf", PATTACH_CUSTOMORIGIN, c)
	    ParticleManager:SetParticleControl(particle, 0, c:GetAbsOrigin())
	    ParticleManager:SetParticleControl(particle, 1, Vector(225,225,225))

	    local thinker = CreateModifierThinker( c, self, "modifier_hit_n_run_thinker", {Duration=duration+0.95}, c:GetAbsOrigin(), c:GetTeamNumber(), false)

	    Physics:Unit(c)
		  c:SetPhysicsFriction(0)
		  c:PreventDI(true)
		  -- To allow going through walls / cliffs add the following:
		  c:FollowNavMesh(false)
		  c:SetAutoUnstuck(false)
		  c:SetNavCollisionType(PHYSICS_NAV_NOTHING)
		  
		  c:SetPhysicsVelocity(facing * distance * 2)
		  c:AddPhysicsVelocity(Vector(0,0,distance*2))
		  
		  c:SetPhysicsAcceleration(Vector(0,0,-(distance*10)))
		  
		  Timers:CreateTimer(0.5,function()
		    c:SetPhysicsVelocity(Vector(0,0,0))
		--    FindClearSpaceForUnit(c,c:GetAbsOrigin(),true)
		    c:PreventDI(false)
		  end
		  )
		  Timers:CreateTimer(0.6,function()
		    FindClearSpaceForUnit(c,c:GetAbsOrigin(),true)
		  end
		  )
	end
end

modifier_hit_n_run_thinker = class({})

if IsServer() then

	function modifier_hit_n_run_thinker:OnCreated()
		local radius = self:GetAbility():GetSpecialValueFor("radius")
		-- self:GetParent():EmitSound("Hero_Sniper.ShrapnelShatter")
		-- local p = ParticleManager:CreateParticle("particles/units/heroes/hero_sniper/sniper_shrapnel.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent()) --[[Returns:int
		-- Creates a new particle effect
		-- ]]
		-- ParticleManager:SetParticleControl(p, 1, Vector(radius,0,0)) --[[Returns:void
		-- Set the control point data for a control on a particle effect
		-- ]]
		self:StartIntervalThink(1.0)
	end

	function modifier_hit_n_run_thinker:OnIntervalThink()
		local c = self:GetAbility():GetCaster()
		local radius = self:GetAbility():GetSpecialValueFor("radius")
		local damage = self:GetAbility():GetSpecialValueFor("damage")
		local en = FindEnemies(c,self:GetParent():GetAbsOrigin(),radius)
		local duration = self:GetAbility():GetSpecialValueFor("slow_duration")

		local p = ParticleManager:CreateParticle("particles/units/heroes/hero_hawkeye/hit_n_run.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent()) --[[Returns:int
		Creates a new particle effect
		]]
		ParticleManager:SetParticleControl(p, 1, Vector(radius,0,0)) --[[Returns:void
		Set the control point data for a control on a particle effect
		]]

		Timers:CreateTimer(0.8,function()
			ParticleManager:DestroyParticle(p,false)
		end)

		for k,v in pairs(en) do
			InflictDamage(v,c,self:GetAbility(),damage,DAMAGE_TYPE_MAGICAL)
			v:AddNewModifier(c, self:GetAbility(), "modifier_hit_n_run_slow", {Duration=duration}) --[[Returns:void
			No Description Set
			]]
		end
	end

end

modifier_hit_n_run_slow = class({})

function modifier_hit_n_run_slow:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
	}
	return funcs
end

function modifier_hit_n_run_slow:GetModifierMoveSpeedBonus_Percentage()
	return self:GetAbility():GetSpecialValueFor("slow")
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

function FindEnemies(caster,point,radius,targets,flags)
  local targets = targets or DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_CREEP
  local flags = flags or DOTA_UNIT_TARGET_FLAG_NONE
  return FindUnitsInRadius( caster:GetTeamNumber(),
                            point,
                            nil,
                            radius,
                            DOTA_UNIT_TARGET_TEAM_ENEMY,
                            targets,
                            flags,
                            FIND_CLOSEST,
                            false)
end