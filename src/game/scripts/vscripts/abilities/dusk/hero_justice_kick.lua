hero_justice_kick = class({})

LinkLuaModifier("modifier_justice_kick","abilities/dusk/hero_justice_kick",LUA_MODIFIER_MOTION_NONE)

function hero_justice_kick:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local mod = "modifier_justice_kick"

	local damage = self:GetSpecialValueFor("damage")
	local duration = self:GetSpecialValueFor("duration")

	target:EmitSound("Hero.JusticeKick")
	ParticleManager:CreateParticle("particles/units/heroes/hero_hero/hero_justice_kick.vpcf", PATTACH_ROOTBONE_FOLLOW, target)

	InflictDamage(target,caster,self,damage,DAMAGE_TYPE_MAGICAL)

	target:AddNewModifier(caster, self, mod, {Duration=duration})
end

modifier_justice_kick = class({})

function modifier_justice_kick:DeclareFunctions()
	local func = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		--MODIFIER_PROPERTY_OVERRIDE_ANIMATION
	}

	return func
end

function modifier_justice_kick:GetModifierMoveSpeedBonus_Percentage()
	return -self:GetAbility():GetSpecialValueFor("slow")
end

function modifier_justice_kick:GetOverrideAnimation()
	return ACT_DOTA_FLAIL
end

function modifier_justice_kick:OnCreated(kv)
	if IsServer() then
		local caster = self:GetAbility():GetCaster()
		local p = self:GetParent()
		local facing = caster:GetForwardVector()
		local distance = self:GetAbility():GetSpecialValueFor("distance")

		Physics:Unit(p)
		p:SetPhysicsFriction(0)
		p:PreventDI(true)
		-- To allow going through walls / cliffs add the following:
		p:FollowNavMesh(false)
		p:SetAutoUnstuck(false)
		p:SetNavCollisionType(PHYSICS_NAV_NOTHING)

		p:SetPhysicsVelocity(facing * distance * (1/0.4))
		p:AddPhysicsVelocity(Vector(0,0,distance*2))

		p:SetPhysicsAcceleration(Vector(0,0,-(distance*10)))

		Timers:CreateTimer(0.4,function()
			p:SetPhysicsVelocity(Vector(0,0,0))
			--    FindClearSpaceForUnit(p,p:GetAbsOrigin(),true)
			p:PreventDI(false)
		end
		)
		Timers:CreateTimer(0.43,function()
			FindClearSpaceForUnit(p,p:GetAbsOrigin(),true)
			self:Destroy()
		end
		)
	end
end

function modifier_justice_kick:CheckState()
	local state = {
		--[MODIFIER_STATE_STUNNED] = true
	}
	return state
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