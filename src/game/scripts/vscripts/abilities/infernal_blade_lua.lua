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


modifier_infernal_blade = class({
	IsHidden = function(self) return false end,
	IsPurgable = function(self) return true end,
	OnRefresh = function(self, kv) return self:OnCreated() end,
	GetAttributes = function(self) return MODIFIER_ATTRIBUTE_MULTIPLE end,

	GetEffectName = function(self) return "particles/units/heroes/hero_doom_bringer/doom_infernal_blade_debuff.vpcf" end,
	GetEffectAttachType = function(self) return PATTACH_ABSORIGIN_FOLLOW end,
	
	OnCreated = function(self, kv)
		self.burn = self:GetAbility():GetTalentSpecialValueFor("max_pct_burn") * 0.01
		--self.burn = self:GetAbility():GetSpecialValueFor("max_pct_burn") * 0.01
		self.base = self:GetAbility():GetSpecialValueFor("base_dmg")
		self.tick = self:GetAbility():GetSpecialValueFor("interval")

		self:StartIntervalThink(self.tick)
	end,

	OnIntervalThink = function(self)
		if not IsServer() then return end
		local damage = self:GetCaster():GetMaxHealth() * self.burn + self.base
		ApplyDamage({victim = self:GetParent(), attacker = self:GetCaster(), ability = self, damage = damage, damage_type = self:GetAbility():GetAbilityDamageType()})
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
			if ability:IsFullyCastable() then
				--dont infernal roshan or buildings, and dont let illusions use it.
				if target:GetUnitName() == "npc_dota_roshan" or caster:IsIllusion() or target:IsBuilding() then print("invalid target") return end

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

		--multipurpose particle id ;)
		if self.p then
			target:AddNewModifier(caster, ability, "modifier_infernal_blade", {duration = self.duration})
			target:AddNewModifier(caster, ability, "modifier_infernal_blade_stun", {duration = self.stun})

			EmitSoundOn("Hero_DoomBringer.InfernalBlade.Target", target)
			ability:UseResources(true, false, true)

			ParticleManager:ReleaseParticleIndex(
				ParticleManager:CreateParticle("particles/units/heroes/hero_doom_bringer/doom_infernal_blade_impact.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
			)
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
