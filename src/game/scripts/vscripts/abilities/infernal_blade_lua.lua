LinkLuaModifier("modifier_infernal_blade", "abilities/infernal_blade_lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_infernal_blade_stun", "abilities/infernal_blade_lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_infernal_blade_caster", "abilities/infernal_blade_lua", LUA_MODIFIER_MOTION_NONE)
------------------------------------------------

infernal_blade_lua = class({})

function infernal_blade_lua:OnAbilityPhaseStart()
	if IsServer() then
		local target = self:GetCursorTarget()
		if target then
			self.overrideAutocast = true
			self:GetCaster():MoveToTargetToAttack(target)
		end
	end
end

function infernal_blade_lua:OnUpgrade()
	if self.mod then
		self.mod:ForceRefresh()
	else
		self.mod = self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_infernal_blade_caster", {})
	end	
end

--hardcoded cooldown decrease for doom perk, since this isnt a 'spell' and is never actually cast.
function infernal_blade_lua:GetCooldown( nLevel )
	local reduction = 0
	if self:GetCaster():HasModifier("modifier_npc_dota_hero_doom_bringer_perk") then
		reduction = self.BaseClass.GetCooldown(self, nLevel) * 0.25
	end
	return self.BaseClass.GetCooldown(self, nLevel) - reduction
end


modifier_infernal_blade = class({
	IsHidden = function(self) return false end,
	IsPurgable = function(self) return true end,
	OnRefresh = function(self, kv) return self:OnCreated() end,
	GetAttributes = function(self) return MODIFIER_ATTRIBUTE_MULTIPLE end,
	CheckState = function(self)
		if self.isAghnaimAbility == 1 then
			return { [MODIFIER_STATE_PASSIVES_DISABLED] = true, }
		else
			return {}
		end
	end,

	GetEffectName = function(self) return "particles/units/heroes/hero_doom_bringer/doom_infernal_blade_debuff.vpcf" end,
	GetEffectAttachType = function(self) return PATTACH_ABSORIGIN_FOLLOW end,

	OnCreated = function(self, kv)
		if IsServer() then
			--self.burnPct = self:GetAbility():GetTalentSpecialValueFor("max_pct_burn") * 0.01
			self.burnPct = self:GetAbility():GetSpecialValueFor("max_pct_burn")
			self.base = self:GetAbility():GetSpecialValueFor("base_dmg")
			self.tick = self:GetAbility():GetSpecialValueFor("interval")
			self.isAghnaimAbility = kv.isAghnaimAbility
			print(self.isAghnaimAbility)
			local talent = self:GetCaster():FindAbilityByName("special_bonus_unique_doom_1")
			if talent then
				if talent:GetLevel() > 0 then
					self.burnPct = self.burnPct + talent:GetSpecialValueFor("value")
				end
			end
			self.burnPct = self.burnPct * 0.01

			self:StartIntervalThink(self.tick)
		end
	end,

	OnIntervalThink = function(self)
		if not IsServer() then return end
		local dmg = self.base + (self:GetParent():GetMaxHealth() * self.burnPct)
		local postDmg = ApplyDamage({victim = self:GetParent(), attacker = self:GetCaster(), ability = self, damage = dmg, damage_type = self:GetAbility():GetAbilityDamageType()})

		SendOverheadEventMessage(nil, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE, self:GetParent(), postDmg, self:GetCaster())
	end,
})

modifier_infernal_blade_caster = class({
	IsHidden = function(self) return true end,
	IsPurgable = function(self) return false end,
	IsPermanent = function(self) return true end,
	RemoveOnDeath = function(self) return false end,
	OnRefresh = function(self, kv) return self:OnCreated() end,
	GetAttributes = function(self) return MODIFIER_ATTRIBUTE_PERMANENT + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE end,
	DeclareFunctions = function(self) return {MODIFIER_EVENT_ON_ORDER, MODIFIER_EVENT_ON_ATTACK_START, MODIFIER_EVENT_ON_ATTACK_LANDED,} end,

	OnCreated = function(self, kv)
		self.duration = self:GetAbility():GetSpecialValueFor("burn_duration")
		self.stun = self:GetAbility():GetSpecialValueFor("stun_duration")
	end,

	OnAttackStart = function(self, keys)
		if not IsServer() then return end
		if keys.attacker ~= self:GetParent() then return end

		local caster = self:GetCaster()
		local ability = self:GetAbility()
		local target = keys.target

		if ability:GetAutoCastState() or ability.overrideAutocast then
			if ability:GetManaCost(-1) <= caster:GetMana() and ability:IsCooldownReady() then
				--dont infernal roshan or buildings, and dont let illusions use it.
				if target:GetUnitName() == "npc_dota_roshan" or caster:IsIllusion() or target:IsBuilding() then return end

				self.p = ParticleManager:CreateParticle("particles/units/heroes/hero_doom_bringer/doom_infernal_blade.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
				ParticleManager:SetParticleControlEnt(self.p, 1, caster, PATTACH_POINT_FOLLOW, "attach_weapon_blur", caster:GetAbsOrigin(), true)
				EmitSoundOn("Hero_DoomBringer.InfernalBlade.PreAttack", caster)
			end
		end
	end,

	OnAttackLanded = function(self, keys)
		if not IsServer() then return end
		if keys.attacker ~= self:GetParent() then return end

		local caster = self:GetCaster()
		local ability = self:GetAbility()
		local target = keys.target
		
		if target:IsMagicImmune() or target:GetTeam() == caster:GetTeam() then return end

		if ability:GetAutoCastState() or ability.overrideAutocast then
			if ability:GetManaCost(-1) <= caster:GetMana() and ability:IsCooldownReady() then
				--dont infernal roshan or buildings, and dont let illusions use it.
				if target:GetUnitName() == "npc_dota_roshan" or caster:IsIllusion() or target:IsBuilding() then return end

				self.duration = self:GetAbility():GetSpecialValueFor("burn_duration")
				self.stun = self:GetAbility():GetSpecialValueFor("stun_duration")
				local isAghnaimAbility = false
				if self:GetCaster():HasScepter() then
					self.duration = self:GetAbility():GetSpecialValueFor("burn_duration_scepter")
					self.stun = self:GetAbility():GetSpecialValueFor("ministun_duration_scepter")
					isAghnaimAbility = true
				end
				target:AddNewModifier(caster, ability, "modifier_infernal_blade", {duration = self.duration, isAghnaimAbility = isAghnaimAbility})
				target:AddNewModifier(caster, ability, "modifier_infernal_blade_stun", {duration = self.stun})

				EmitSoundOn("Hero_DoomBringer.InfernalBlade.Target", target)
				ability:UseResources(true, false, true)

				ParticleManager:ReleaseParticleIndex(
					ParticleManager:CreateParticle("particles/units/heroes/hero_doom_bringer/doom_infernal_blade_impact.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
				)
			end
		end
	end,

	OnOrder = function(self, keys)
		if not IsServer() then return end
		if keys.unit ~= self:GetParent() then return end
		self:GetAbility().overrideAutocast = false
		if self.p then
			ParticleManager:DestroyParticle(self.p, false)
			ParticleManager:ReleaseParticleIndex(self.p)
			self.p = nil
		end
	end,
})

--seperate modifier for stun because the burn and stun have different purge properties
modifier_infernal_blade_stun = class({
	IsHidden = function(self) return true end,
	IsPurgable = function(self) return true end,
	IsStunDebuff = function(self) return true end,
	CheckState = function(self) return {[MODIFIER_STATE_STUNNED] = true,} end,
	GetOverrideAnimation = function(self) return ACT_DOTA_DISABLED end,
	GetEffectName = function(self) return "particles/generic_gameplay/generic_stunned.vpcf" end,
	GetEffectAttachType = function(self) return PATTACH_OVERHEAD_FOLLOW end,
})
