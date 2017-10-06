LinkLuaModifier("modifier_infernal_blade", "redux_testing/infernal_blade_lua.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_infernal_blade_stun", "redux_testing/infernal_blade_lua.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_infernal_blade_caster", "redux_testing/infernal_blade_lua.lua", LUA_MODIFIER_MOTION_NONE)
------------------------------------------------

infernal_blade_lua = class({})

function infernal_blade_lua:OnAbilityPhaseStart()
end

--manual cast currently bugged? 
--it appears to follow thru with the attack, but it never prints and the override boolean is never set to true.
function infernal_blade_lua:OnSpellStart()
	print("testtesttest -- running spell start")
	if IsServer() then
		local target = self:GetCursorTarget()
		if target then
			print("set true")
			self.overrideAutocast = true

			self:GetCaster():MoveToTargetToAttack(target)

			--manual cast will spend mana and cooldown before the attack is performed.
			--so we refund them here, and spend them later.
			self:RefundManaCost()
			self:EndCooldown()
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
		--self.burn = self:GetAbility():GetTalentSpecialValueFor("max_pct_burn") * 0.01
		self.burn = self:GetAbility():GetSpecialValueFor("max_pct_burn") * 0.01
		self.base = self:GetAbility():GetSpecialValueFor("base_dmg")
		self.tick = self:GetAbility():GetSpecialValueFor("interval")

		self:StartIntervalThink(self.tick)
	end,

	OnIntervalThink = function(self)
		if not IsServer() then return end
		local damage = self:GetCaster():GetHealth() * self.burn + self.base
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

		print("Pre:", ability:GetAutoCastState(), ability.overrideAutocast, ability:IsFullyCastable())
		if ability:GetAutoCastState() or ability.overrideAutocast then
			print("pass 1")
			if ability:IsFullyCastable() then
				print("pass 2")

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

		print("Post:", ability:GetAutoCastState(), ability.overrideAutocast, ability:IsFullyCastable())

		if ability:GetAutoCastState() or ability.overrideAutocast then
			print("pass 3")
			if ability:IsFullyCastable() then
				print("pass 4")
				--dont infernal roshan or buildings, and dont let illusions use it.
				if target:GetUnitName() == "npc_dota_roshan" or caster:IsIllusion() or target:IsBuilding() then print("invalid target") return end

				target:AddNewModifier(caster, ability, "modifier_infernal_blade", {duration = self.duration})
				target:AddNewModifier(caster, ability, "modifier_infernal_blade_stun", {duration = self.stun})

				ParticleManager:ReleaseParticleIndex(
					ParticleManager:CreateParticle("particles/units/heroes/hero_doom_bringer/doom_infernal_blade_impact.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
				)

				EmitSoundOn("Hero_DoomBringer.InfernalBlade.Target", target)

				print("use resources")
				ability:UseResources(true, false, true)
			end
		end
	end,

	OnOrder = function(self, keys)
		if not IsServer() then return end
		if keys.unit ~= self:GetParent() then return end
		print("set false")
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

	GetEffectName = function(self) return "particles/generic_gameplay/generic_stunned.vpcf" end,
	GetEffectAttachType = function(self) return PATTACH_OVERHEAD_FOLLOW end,
})