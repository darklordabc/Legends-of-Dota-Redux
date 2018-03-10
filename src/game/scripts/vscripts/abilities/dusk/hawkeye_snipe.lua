hawkeye_snipe = class({})

LinkLuaModifier("modifier_snipe_caster","abilities/dusk/hawkeye_snipe",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_snipe_vision","abilities/dusk/hawkeye_snipe",LUA_MODIFIER_MOTION_NONE)

function hawkeye_snipe:OnSpellStart()
	local c = self:GetCaster()

	local duration = self:GetSpecialValueFor("duration")

	c:EmitSound("Ability.AssassinateLoad")

	c:AddNewModifier(c, self, "modifier_snipe_caster", {Duration=duration}) --[[Returns:void
	No Description Set
	]]
end

modifier_snipe_caster = class({})

function modifier_snipe_caster:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE
	}
	return funcs
end

function modifier_snipe_caster:OnCreated(kv)
	local attacks = self:GetAbility():GetSpecialValueFor("attacks")
	self:SetStackCount(attacks)
end

function modifier_snipe_caster:OnAttackLanded(params)
	if IsServer() then
		if params.attacker == self:GetParent() then
			params.target:AddNewModifier(params.attacker, self:GetAbility(), "modifier_snipe_vision", {Duration=1.75}) --[[Returns:void
			No Description Set
			]]

			if self:GetStackCount() <= 0 then
				self:Destroy()
			end
		end
	end
end

function modifier_snipe_caster:GetModifierAttackRangeBonus()
	return self:GetAbility():GetSpecialValueFor("attack_range_bonus")
end

function modifier_snipe_caster:GetModifierPreAttack_BonusDamage()
	return self:GetAbility():GetSpecialValueFor("damage_bonus")
end

function modifier_snipe_caster:GetModifierMoveSpeed_Absolute()
	return self:GetAbility():GetSpecialValueFor("movespeed")
end

function modifier_snipe_caster:CheckState()
	local state = {
		[MODIFIER_STATE_CANNOT_MISS] = true
	}
	return state
end

function modifier_snipe_caster:GetEffectName()
	return "particles/units/heroes/hero_sniper/sniper_crosshair.vpcf"
end

function modifier_snipe_caster:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

function modifier_snipe_caster:IsHidden()
	return false
end

modifier_snipe_vision = class({})

function modifier_snipe_vision:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PROVIDES_FOW_POSITION
	}
	return funcs
end

function modifier_snipe_vision:GetModifierProvidesFOWVision()
	return 1
end