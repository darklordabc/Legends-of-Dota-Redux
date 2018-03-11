lysander_grapeshot = class({})

LinkLuaModifier("modifier_grapeshot_scepter","abilities/dusk/lysander_grapeshot",LUA_MODIFIER_MOTION_NONE)

function lysander_grapeshot:OnSpellStart()
	local c = self:GetCaster()
	local t = self:GetCursorTarget()

	if t:TriggerSpellAbsorb(self) then return end
	t:TriggerSpellReflect(self)

	if t then

		local base_dmg = self:GetSpecialValueFor("base_damage")

		local cdr_duration = self:GetSpecialValueFor("cdr_duration")

		local sound = "Hero_Kunkka.InverseBayonet"
		local sound2 = ""

		local particle = "particles/units/heroes/hero_lysander/grapeshot.vpcf"

		local mult = self:GetSpecialValueFor("multiplier")
		local stun = self:GetSpecialValueFor("stun")
		local stun_range = self:GetSpecialValueFor("range_ministun")

		local crit_mult = self:GetSpecialValueFor("crit_multiplier")

		local cc_mult = self:GetSpecialValueFor("captains_compass_increase")/100

		local r = RandomInt(1,100)
		local crit = self:GetSpecialValueFor("crit")

		local noStuns = self.noStuns or false

		if t:HasModifier("modifier_captains_compass") and noStuns ~= true then
			crit = 999 -- guaranteed crit
			stun = stun * (1+cc_mult)
			t:RemoveModifierByName("modifier_captains_compass") --[[Returns:void
			Removes a modifier
			]]
		end

		local isCrit = r <= crit

		t:EmitSound(sound)

		if isCrit then
			local cd_after = self:GetCooldownTimeRemaining()/2
			self:EndCooldown()
			self:StartCooldown(cd_after)
			self:RefundManaCost()
		end

		Timers:CreateTimer(0.2,function()

			if isCrit then
				mult = crit_mult
				sound2 = "Hero_Silencer.LastWord.Damage"
				particle = "particles/units/heroes/hero_lysander/grapeshot_crit.vpcf"
				if not noStuns then
					t:AddNewModifier(c, self, "modifier_stunned", {Duration=stun}) --[[Returns:void
					No Description Set
					]]
				end
			end

			local dmg = mult * (c:GetAverageTrueAttackDamage(c)+base_dmg)

			InflictDamage(t,c,self,dmg,DAMAGE_TYPE_PHYSICAL)

			if sound2 ~= "" then t:EmitSound(sound2) end

			local p = ParticleManager:CreateParticle(particle, PATTACH_CUSTOMORIGIN_FOLLOW, t) --[[Returns:int
			Creates a new particle effect
			]]
			ParticleManager:SetParticleControlEnt(p,0,t,PATTACH_POINT_FOLLOW,"attach_hitloc",t:GetCenter(),true)

			if not isCrit and c:GetRangeToUnit(t) < stun_range then
				if not noStuns then
					t:AddNewModifier(c, self, "modifier_stunned", {Duration=stun})
				end
			end

		end)

	end
end

function lysander_grapeshot:GetIntrinsicModifierName()
	return "modifier_grapeshot_scepter"
end

modifier_grapeshot_scepter = class({})

function modifier_grapeshot_scepter:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}
	return funcs
end

function modifier_grapeshot_scepter:OnAttackLanded(params)
	if IsServer() then
		local attacker = params.attacker

		if attacker:IsIllusion() then return end

		if not attacker == self:GetParent() then return end
		if not attacker:HasScepter() then return end

		local chance = self:GetAbility():GetSpecialValueFor("scepter_chance")
		local r = RandomInt(1,100)

		local hit = r <= chance

		local radius = self:GetAbility():GetSpecialValueFor("scepter_radius")

		if hit then
			local ab = self:GetAbility()

			local en = FindUnitsInRadius(self:GetParent():GetTeam(), self:GetParent():GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)

			--local en = FindEnemies(self:GetParent(),self:GetParent():GetAbsOrigin(),radius)

			local enl = #en

			local rr = RandomInt(1,enl)

			if IsValidEntity(en[rr]) then
				while enl > 1 and en[rr] == params.unit do
					rr = RandomInt(1,enl)
				end
				if en[rr]:IsAlive() then
					attacker:SetCursorCastTarget(en[rr]) --[[Returns:void
					No Description Set
					]]
					ab.noStuns = true
					ab:OnSpellStart()
					ab.noStuns = false
				end
			end
		end
	end
end

function modifier_grapeshot_scepter:AllowIllusionDuplicate()
	return false
end

function modifier_grapeshot_scepter:IsHidden()
	-- if IsServer() then
		if self:GetAbility():GetCaster():HasScepter() then
			return false
		end
		return true
	-- end
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
