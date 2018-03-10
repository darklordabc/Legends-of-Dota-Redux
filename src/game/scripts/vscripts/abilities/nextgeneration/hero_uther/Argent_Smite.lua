LinkLuaModifier("modifier_argent_smite_passive", "abilities/nextgeneration/hero_uther/Argent_Smite.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_argent_smite_negate_damage", "abilities/nextgeneration/hero_uther/Argent_Smite.lua", LUA_MODIFIER_MOTION_NONE)

uther_Argent_Smite = class({})

function uther_Argent_Smite:OnToggle()
	if self:GetToggleState() then
		self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_argent_smite_passive", {})
	else
		local mod = self:GetCaster():FindModifierByNameAndCaster("modifier_argent_smite_passive", self:GetCaster())
		if mod then
			self:GetCaster():SetForceAttackTargetAlly(nil)
			mod:Destroy()
		end
	end
end

modifier_argent_smite_passive = class({
	IsHidden = function() return false end,
	IsPurgable = function() return false end,

	DeclareFunctions = function() return {MODIFIER_PROPERTY_ATTACK_RANGE_BONUS, MODIFIER_EVENT_ON_ORDER, MODIFIER_EVENT_ON_ATTACK_LANDED, MODIFIER_EVENT_ON_ATTACK_START} end,	
	GetModifierAttackRangeBonus = function(self) return self.range or 0 end,
	OnOrder = function(self, keys)
		if self:GetParent() == keys.unit then
			self.range = 0
			if keys.order_type == DOTA_UNIT_ORDER_ATTACK_TARGET then
				if keys.target:GetTeam() == self:GetParent():GetTeam() then
					if self:GetAbility():IsCooldownReady() then
						if (self:GetParent():GetAbsOrigin() - keys.target:GetAbsOrigin()):Length2D() <= 1000 then
							self:GetParent():SetForceAttackTargetAlly(keys.target)
							self.range = self:GetParent():IsRangedAttacker() and self:GetAbility():GetSpecialValueFor("Range_Bonus") or 300
						end
					end
				end
			end
		end
	end,

	OnAttackStart = function(self, keys)
		if self:GetParent() ~= keys.attacker then return end
		if self:GetParent():GetTeam() ~= keys.target:GetTeam() then return end

		self:GetParent():SetForceAttackTargetAlly(nil)
		self.range = 0
	end,

	OnAttackLanded = function(self, keys)
		if not IsServer() then return end
		if keys.attacker ~= self:GetParent() then return end
		if keys.target:GetTeam() ~= self:GetParent():GetTeam() then return end

		local factor = keys.target:IsBuilding() and self:GetAbility():GetSpecialValueFor("Tower_Heal_Factor") or self:GetAbility():GetSpecialValueFor("Heal_Factor")
		local heal = keys.attacker:GetAttackDamage() * factor

		keys.target:Heal(heal, self:GetParent())

		self:GetParent():SetForceAttackTargetAlly(nil)
		self.range = 0

		--make sure they are actually still alive when the projectile hits them
		if keys.target:IsAlive() and self:GetAbility():IsCooldownReady() then
			--attack damage hasnt yet been applied, give them a modifier that will negate the damage.
			keys.target:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_argent_smite_negate_damage", {duration = 1})

			--purge any effects applied by this attack
			keys.target:Purge(true, true, true, true, true)

			--soft dispel
			keys.target:Purge(false, true, false, false, false)

			EmitSoundOn("Hero_Omniknight.Purification", keys.target)

			local p = ParticleManager:CreateParticle("particles/uther/argent_smite.vpcf", PATTACH_ABSORIGIN_FOLLOW, keys.target)
			ParticleManager:SetParticleControl(p, 0, keys.target:GetAbsOrigin())
			ParticleManager:SetParticleControl(p, 1, Vector(150, 150, 150))
		end
	end,
})

modifier_argent_smite_negate_damage = class({
	IsHidden = function() return true end,
	IsPurgable = function() return false end,
	DeclareFunctions = function() return {MODIFIER_EVENT_ON_TAKEDAMAGE,} end,
	--really weird inconsistant damage. the actual damage dealt can be 1 damage off from keys.damage
	OnTakeDamage = function(self, keys)
		if self:GetParent() == keys.unit then
			if self:GetParent():GetTeam() == keys.attacker:GetTeam() then
				if keys.attacker:HasModifier("modifier_argent_smite_passive") then
					if self:GetAbility() and self:GetAbility():IsCooldownReady() then
						self:GetParent():SetHealth( math.ceil(self:GetParent():GetHealth()+keys.damage) )
						self:GetAbility():StartCooldown(self:GetParent():IsBuilding() and self:GetAbility():GetSpecialValueFor("Cooldown_Factor_Building") or self:GetAbility():GetSpecialValueFor("Cooldown_Factor"))
					end
				end
			end
		end
	end,
})



