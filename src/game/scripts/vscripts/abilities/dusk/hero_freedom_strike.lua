hero_freedom_strike = class({})

LinkLuaModifier("modifier_freedom_strike","abilities/dusk/hero_freedom_strike",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_freedom_strike_slow","abilities/dusk/hero_freedom_strike",LUA_MODIFIER_MOTION_NONE)

function hero_freedom_strike:GetCooldown(level)
	local base_cooldown = self.BaseClass.GetCooldown(self, level)
	return base_cooldown
end

function hero_freedom_strike:OnAbilityPhaseStart()
	self:GetCaster():EmitSound("Hero_EarthSpirit.PreAttack")
	return true
end

function hero_freedom_strike:OnSpellStart()
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_freedom_strike", {Duration=1})
end

modifier_freedom_strike = class({})

function modifier_freedom_strike:OnCreated(kv)
	if IsServer() then
		local caster = self:GetParent()
		local p = self:GetParent()
		local facing = caster:GetForwardVector()
		local distance = self:GetAbility():GetSpecialValueFor("charge")

		local damage = self:GetAbility():GetSpecialValueFor("damage")

		local duration = self:GetAbility():GetSpecialValueFor("duration")

		local radius = self:GetAbility():GetSpecialValueFor("radius")

		Physics:Unit(p)
		p:SetPhysicsFriction(0)
		p:PreventDI(true)
		-- To allow going through walls / cliffs add the following:
		p:FollowNavMesh(false)
		p:SetAutoUnstuck(false)
		p:SetNavCollisionType(PHYSICS_NAV_NOTHING)

		p:SetPhysicsVelocity(facing * distance * (1/0.4))
		p:AddPhysicsVelocity(Vector(0,0,distance*1.4))

		p:SetPhysicsAcceleration(Vector(0,0,-(distance*10)))

		Timers:CreateTimer(0.4,function()
			p:SetPhysicsVelocity(Vector(0,0,0))
			--    FindClearSpaceForUnit(p,p:GetAbsOrigin(),true)
			p:PreventDI(false)
		end
		)
		Timers:CreateTimer(0.43,function()
			local enemy = FindUnitsInRadius( p:GetTeamNumber(),
	                              p:GetCenter(),
	                              nil,
	                                radius,
	                                DOTA_UNIT_TARGET_TEAM_ENEMY,
	                                DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_CREEP,
	                                DOTA_UNIT_TARGET_FLAG_NONE,
	                                FIND_CLOSEST,
	                                false)

			local part = ParticleManager:CreateParticle("particles/units/heroes/hero_brewmaster/brewmaster_thunder_clap.vpcf", PATTACH_ABSORIGIN_FOLLOW, p) --[[Returns:int
			Creates a new particle effect
			]]
			ParticleManager:SetParticleControl(part, 1, Vector(radius,0,0)) --[[Returns:void
			Set the control point data for a control on a particle effect
			]]
			p:EmitSound("Hero_Brewmaster.ThunderClap")
			for k,v in pairs(enemy) do
				InflictDamage(v,p,self:GetAbility(),damage,DAMAGE_TYPE_MAGICAL)
				v:AddNewModifier(caster, self:GetAbility(), "modifier_freedom_strike_slow", {Duration=duration}) --[[Returns:void
				No Description Set
				]]
			end
			FindClearSpaceForUnit(p,p:GetAbsOrigin(),true)

			self:Destroy()
		end
		)
	end
end

function modifier_freedom_strike:CheckState()
	local state = {
		[MODIFIER_STATE_COMMAND_RESTRICTED] = true
	}
	return state
end

modifier_freedom_strike_slow = class({})

function modifier_freedom_strike_slow:DeclareFunctions()
	local func = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
	}
	return func
end

function modifier_freedom_strike_slow:GetModifierMoveSpeedBonus_Percentage()
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