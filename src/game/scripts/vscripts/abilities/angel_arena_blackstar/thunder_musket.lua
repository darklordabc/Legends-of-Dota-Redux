aabs_thunder_musket = {}

function aabs_thunder_musket:GetIntrinsicModifierName()
	return "modifier_aabs_thunder_musket"
end


modifier_aabs_thunder_musket = {
	IsHidden = function() return self.range and self.range == 0 or true end,
	IsPurgeable = function() return false end,
	RemoveOnDeath = function() return false end,

	DeclareFunctions = function() return {MODIFIER_PROPERTY_ATTACK_RANGE_BONUS, MODIFIER_EVENT_ON_ATTACK_LANDED,} end,
	GetModifierAttackRangeBonus = function(self) return self.range end,

	OnCreated = function(self) self:StartIntervalThink(FrameTime()) end,
	OnIntervalThink = function(self)
		if not IsServer() then return end

		if self:GetParent():PassivesDisabled() then
			self.range = 0
			return
		end
		if self:GetAbility() then
			self.range = self:GetAbility():IsCooldownReady() and self:GetAbility():GetSpecialValueFor("thunderstruck_bonus_attack_range") or 0
		else
			self:Destroy()
			return
		end
	end,

	OnAttackLanded = function(self, keys)
		if not IsServer() or keys.attacker ~= self:GetParent() or self:GetParent():PassivesDisabled() then return end

		if self:GetAbility() then
			if self:GetAbility():IsCooldownReady() then
				self:GetAbility():UseResources(false, false, true)

				ApplyDamage({
					attacker = self:GetParent(),
					victim = keys.victim,
					ability = self:GetAbility(),
					damage = self:GetAbility():GetSpecialValueFor("thunderstruck_magical_damage"),
					damage_type = self:GetAbility():GetAbilityDamageType()
				})

				keys.victim:EmitSound("Hero_Zuus.ArcLightning.Target")
				local p = ParticleManager:CreateParticle("particles/econ/items/antimage/antimage_weapon_basher_ti5/antimage_manavoid_lightning_ti_5.vpcf", PATTACH_ABSORIGIN_FOLLOW, keys.victim)
				ParticleManager:ReleaseParticleIndex(p)
			end
		else
			self:Destroy()
			return
		end
	end,
}