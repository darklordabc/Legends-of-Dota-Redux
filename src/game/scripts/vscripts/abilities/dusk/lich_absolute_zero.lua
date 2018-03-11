lich_absolute_zero = class({})

LinkLuaModifier("modifier_absolute_zero","abilities/dusk/lich_absolute_zero",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_absolute_zero_aura","abilities/dusk/lich_absolute_zero",LUA_MODIFIER_MOTION_NONE)

function lich_absolute_zero:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local duration = self:GetSpecialValueFor("duration")

	if target:TriggerSpellAbsorb(self) then return end

	ParticleManager:CreateParticle("particles/units/heroes/hero_lich/absolute_zero.vpcf", PATTACH_ABSORIGIN_FOLLOW, target) --[[Returns:int
	Creates a new particle effect
	]]
	target:EmitSound("Lich.AbsoluteZero")

	target:AddNewModifier(caster, self, "modifier_absolute_zero", {Duration=duration}) --[[Returns:void
	No Description Set
	]]
end

modifier_absolute_zero = class({})

function modifier_absolute_zero:DeclareFunctions()
	local func = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_CASTTIME_PERCENTAGE,
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION_RATE
	}
	return func
end

function modifier_absolute_zero:GetModifierMoveSpeedBonus_Percentage()
	return -self:GetAbility():GetSpecialValueFor("move_slow")
end

function modifier_absolute_zero:GetModifierAttackSpeedBonus_Constant()
	return -self:GetAbility():GetSpecialValueFor("attack_slow")
end

function modifier_absolute_zero:GetModifierPercentageCasttime()
	return -self:GetAbility():GetSpecialValueFor("cast_slow")
end

function modifier_absolute_zero:GetOverrideAnimationRate()
	return 2
end

function modifier_absolute_zero:IsAura()
	return true
end

function modifier_absolute_zero:GetAuraRadius()
	return self:GetAbility():GetSpecialValueFor("radius")
end

function modifier_absolute_zero:GetAuraSearchFlags()
	return self:GetAbility():GetAbilityTargetFlags()
end

function modifier_absolute_zero:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_absolute_zero:GetAuraSearchType()
	return self:GetAbility():GetAbilityTargetType()
end

function modifier_absolute_zero:GetModifierAura()
	return "modifier_absolute_zero_aura"
end

function modifier_absolute_zero:GetEffectName()
	return "particles/units/heroes/hero_lich/absolute_zero_unit.vpcf"
end

modifier_absolute_zero_aura = class({})

function modifier_absolute_zero_aura:DeclareFunctions()
	local func = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT
	}
	return func
end

function modifier_absolute_zero_aura:GetModifierMoveSpeedBonus_Percentage()
	return -self:GetAbility():GetSpecialValueFor("aura_move_slow")
end

function modifier_absolute_zero_aura:GetModifierAttackSpeedBonus_Constant()
	return -self:GetAbility():GetSpecialValueFor("aura_attack_slow")
end

function modifier_absolute_zero_aura:GetEffectName()
	return "particles/units/heroes/hero_lich/absolute_zero_unit.vpcf"
end