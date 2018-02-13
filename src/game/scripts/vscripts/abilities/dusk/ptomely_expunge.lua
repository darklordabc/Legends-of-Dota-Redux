ptomely_expunge = class({})

LinkLuaModifier("modifier_expunge","abilities/dusk/ptomely_expunge",LUA_MODIFIER_MOTION_NONE)

function ptomely_expunge:OnSpellStart()
	local caster = self:GetCaster()

	local target = self:GetCursorTarget()
	local duration = self:GetSpecialValueFor("duration")

	if target:TriggerSpellAbsorb(self) then return end

	target:AddNewModifier(caster, self, "modifier_expunge", {Duration=duration})
end

modifier_expunge = class({})

function modifier_expunge:DeclareFunctions()
	local func = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
	}
	return func
end

function modifier_expunge:GetModifierMoveSpeedBonus_Percentage()
	return -self:GetAbility():GetSpecialValueFor("slow")
end

function modifier_expunge:OnCreated(kv)
	if IsServer() then
		self:StartIntervalThink(0.1)

		self.mana_drain_amount = 0

		local caster = self:GetAbility():GetCaster()
		local target = self:GetParent()

		local radius = self:GetAbility():GetSpecialValueFor("radius")

		local mana = self:GetParent():GetMana()
		local drain = self:GetAbility():GetSpecialValueFor("mana_drain") / 100
		local base_drain = self:GetAbility():GetSpecialValueFor("base_drain")

		drain = mana * drain + base_drain

		if drain > mana then drain = mana end

		self.mana_drain_amount = drain

		local particle_name = "particles/units/heroes/hero_ptomely/expunge.vpcf"
		local particle_trail = "particles/units/heroes/hero_ptomely/expunge_drain.vpcf"

		local unit = CreateModifierThinker( caster,
		self,
		"modifier_truesight",{Duration=self:GetDuration()+0.2}, target:GetAbsOrigin(), caster:GetTeamNumber(), false )

		local p = ParticleManager:CreateParticle(particle_name, PATTACH_ABSORIGIN_FOLLOW, unit) --[[Returns:int
		Creates a new particle effect
		]]

		unit:EmitSound("Ptomely.ExpungeCharge")

		ParticleManager:SetParticleControl(p, 1, unit:GetAbsOrigin()+Vector(0,0,350)) --[[Returns:void
		Set the control point data for a control on a particle effect
		]]

		ParticleManager:SetParticleControl(p, 2, Vector(radius,0,0)) --[[Returns:void
		Set the control point data for a control on a particle effect
		]]

		local p2 = ParticleManager:CreateParticle(particle_trail, PATTACH_ABSORIGIN_FOLLOW, target) --[[Returns:int
		Creates a new particle effect
		]]

		ParticleManager:SetParticleControl(p2, 1, unit:GetAbsOrigin()+Vector(0,0,350)) --[[Returns:void
		Set the control point data for a control on a particle effect
		]]

		Timers:CreateTimer(self:GetDuration()-0.1,function()
			local enemy_found = FindUnitsInRadius( caster:GetTeamNumber(),
                          unit:GetCenter(),
                          nil,
                            radius,
                            DOTA_UNIT_TARGET_TEAM_ENEMY,
                            DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_CREEP,
                            DOTA_UNIT_TARGET_FLAG_NONE,
                            FIND_CLOSEST,
                            false)

			local ally_found = FindUnitsInRadius( caster:GetTeamNumber(),
                          unit:GetCenter(),
                          nil,
                            radius,
                            DOTA_UNIT_TARGET_TEAM_FRIENDLY,
                            DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_CREEP,
                            DOTA_UNIT_TARGET_FLAG_NONE,
                            FIND_CLOSEST,
                            false)

			ScreenShake(unit:GetAbsOrigin(), 1200, 170, 0.4, 1200, 0, true)

			self:GetParent():EmitSound("Ptomely.ExpungeBoom")

			ParticleManager:DestroyParticle(p,false)
			ParticleManager:DestroyParticle(p2,false)

			for k,v in pairs(enemy_found) do
				InflictDamage(v,caster,self:GetAbility(),drain,DAMAGE_TYPE_MAGICAL)
			end

			for k,v in pairs(ally_found) do
				v:GiveMana(drain/2)
			end
		end)
	end
end

function modifier_expunge:OnIntervalThink()
	if IsServer() then
		local duration = self:GetDuration()
		local interval = 0.1

		local total_ticks = duration / interval

		if self.mana_drain_amount then
			local drain_per_tick = self.mana_drain_amount / total_ticks

			self:GetParent():ReduceMana(drain_per_tick)
		end
	end
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