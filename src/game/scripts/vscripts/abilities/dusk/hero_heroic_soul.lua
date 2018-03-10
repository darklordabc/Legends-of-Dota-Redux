hero_heroic_soul = class({})

LinkLuaModifier("modifier_heroic_soul","abilities/dusk/hero_heroic_soul",LUA_MODIFIER_MOTION_NONE)

function hero_heroic_soul:OnSpellStart()
	if IsServer() then
		local duration = self:GetSpecialValueFor("duration")
		self:GetCaster():EmitSound("Hero_Sven.GodsStrength")
		ParticleManager:CreateParticle("particles/units/heroes/hero_sven/sven_spell_gods_strength.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster()) 
		self:GetCaster():Purge(false, true, false, true, false)

		self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_heroic_soul", {Duration=duration}) --[[Returns:void
		No Description Set
		]]
	end
end

modifier_heroic_soul = class({})

function modifier_heroic_soul:DeclareFunctions()
	local func = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE
	}
	return func
end

function modifier_heroic_soul:GetStatusEffectName()
	return "particles/status_fx/status_effect_gods_strength.vpcf"
end

function modifier_heroic_soul:GetModifierMoveSpeedBonus_Percentage()
	return self:GetAbility():GetSpecialValueFor("bonus_movespeed")
end

function modifier_heroic_soul:GetModifierPreAttack_BonusDamage()
	return self:GetAbility():GetSpecialValueFor("bonus_damage")
end

function modifier_heroic_soul:GetModifierIncomingDamage_Percentage()
	if self:GetElapsedTime() < self:GetAbility():GetSpecialValueFor("damage_reduction_duration") then
		return -self:GetAbility():GetSpecialValueFor("damage_reduction")
	end
end