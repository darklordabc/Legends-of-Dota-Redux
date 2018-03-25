hero_one_punch = class({})

LinkLuaModifier("modifier_one_punch","abilities/dusk/hero_one_punch",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_one_punch_air","abilities/dusk/hero_one_punch",LUA_MODIFIER_MOTION_NONE)

function hero_one_punch:OnAbilityPhaseStart()
	if self:GetCaster():IsDisarmed() then return false end
	return true
end

function hero_one_punch:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local delay = self:GetSpecialValueFor("landing_delay")

	caster:AddNewModifier(caster, self, "modifier_one_punch", {Duration=0.03})

	caster:PerformAttack(
					target,
					true,
					true,
					true,
					false,
					false,
					false,
					true
				)

	target:EmitSound("Hero_Tusk.WalrusPunch.Target")
	target:EmitSound("Hero_Tusk.WalrusPunch.Damage")

	ScreenShake(target:GetCenter(), 1200, 170, 0.3, 1200, 0, true)

	ParticleManager:CreateParticle("particles/units/heroes/hero_hero/hero_one_punch_mega_crit.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)

	Timers:CreateTimer(0.03,function()
		if target:IsAlive() then
			target:AddNewModifier(caster, self, "modifier_one_punch_air", {duration = delay+0.6})
		end
	end)

end

modifier_one_punch = class({})

function modifier_one_punch:DeclareFunctions()
	local func = {
		MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE
	}
	return func
end

function modifier_one_punch:GetModifierPreAttack_CriticalStrike()
	local crit = self:GetAbility():GetSpecialValueFor("crit")
	local scepter_crit = self:GetAbility():GetSpecialValueFor("scepter_crit")

	if self:GetParent():HasScepter() then crit = scepter_crit end

	return crit
end

function modifier_one_punch:CheckState()
	local state = {
		[MODIFIER_STATE_CANNOT_MISS] = true
	}
	return state
end

function modifier_one_punch:IsHidden()
	return true
end

modifier_one_punch_air = class({})

function modifier_one_punch_air:OnCreated(kv)
	if IsServer() then
		self:GetParent():AddNoDraw()

		local caster = self:GetAbility():GetCaster()
		local delay = self:GetAbility():GetSpecialValueFor("landing_delay")
		local radius = self:GetAbility():GetSpecialValueFor("landing_aoe")
		local damage = self:GetAbility():GetSpecialValueFor("landing_damage")

		local scepter_damage = ( self:GetAbility():GetSpecialValueFor("scepter_landing_damage") / 100 )
		local attack_damage = caster:GetAttackDamage()

		if caster:HasScepter() then
			damage = scepter_damage * attack_damage + damage
		end

		local stun = self:GetAbility():GetSpecialValueFor("landing_stun")

		local fx = CreateModifierThinker( caster, self, "modifier_truesight", {Duration=delay+1.25}, self:GetParent():GetAttachmentOrigin(DOTA_PROJECTILE_ATTACHMENT_HITLOCATION), caster:GetTeamNumber(), false )

		self:GetParent():AddNewModifier(caster, nil, "modifier_invulnerable", {Duration=delay+0.4}) --[[Returns:void
		No Description Set
		]]

		ParticleManager:CreateParticle("particles/units/heroes/hero_hero/one_punch_air.vpcf", PATTACH_ABSORIGIN_FOLLOW, fx)

		self:SetStackCount(1)

		Timers:CreateTimer(delay,function()

			local part = ParticleManager:CreateParticle("particles/units/heroes/hero_hero/one_punch_land.vpcf", PATTACH_ABSORIGIN_FOLLOW, fx)
			ParticleManager:SetParticleControl(part, 2, Vector(radius,0,0))

		end)

		Timers:CreateTimer(delay+0.5,function()
			fx:EmitSound("Hero_EarthSpirit.GeomagneticGrip.Stun")
			fx:EmitSound("Hero_Gyrocopter.CallDown.Damage")

			ScreenShake(fx:GetAbsOrigin(), 1200, 170, 0.3, 1200, 0, true)

			self:SetStackCount(0)

			local enemies = FindEnemies(caster,self:GetParent():GetAbsOrigin(),radius)

			for k,v in pairs(enemies) do
				InflictDamage(v,caster,self:GetAbility(),damage,DAMAGE_TYPE_MAGICAL)
				v:AddNewModifier(caster, self:GetAbility(), "modifier_stunned", {Duration=stun}) --[[Returns:void
				No Description Set
				]]
			end

			self:Destroy()
		end)
	end
end

function modifier_one_punch_air:OnDestroy()
	self:GetParent():RemoveNoDraw()
end

function modifier_one_punch_air:CheckState()
	local state = {
		[MODIFIER_STATE_UNSELECTABLE] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
		[MODIFIER_STATE_COMMAND_RESTRICTED] = true,
		[MODIFIER_STATE_STUNNED] = true
	}

	return state
end

function modifier_one_punch_air:GetAttributes()
	return MODIFIER_ATTRIBUTE_PERMANENT
end

function modifier_one_punch_air:IsHidden()
	return true
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
