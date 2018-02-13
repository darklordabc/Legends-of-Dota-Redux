erra_grave_guard = class({})

LinkLuaModifier("modifier_grave_guard","abilities/dusk/erra_grave_guard",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_grave_guard_recovery","abilities/dusk/erra_grave_guard",LUA_MODIFIER_MOTION_NONE)

LinkLuaModifier("modifier_grave_guard_aura","abilities/dusk/erra_grave_guard",LUA_MODIFIER_MOTION_NONE)

function erra_grave_guard:GetIntrinsicModifierName()

	return "modifier_grave_guard_aura"
end

modifier_grave_guard = class({})

function modifier_grave_guard:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_TAKEDAMAGE
	}
	return funcs
end

if IsServer() then

	function modifier_grave_guard:OnTakeDamage(params)
		local threshold = self:GetAbility():GetSpecialValueFor("threshold")

		local caster = self:GetParent()

		if params.unit ~= caster then return end

		local hp = caster:GetHealthPercent()

		local duration = self:GetAbility():GetSpecialValueFor("duration")

		if not caster:IsRealHero() then return end

		local cast_me = self:GetAbility():IsCooldownReady() and self:GetAbility():IsOwnersManaEnough()

		local mana_cost = self:GetAbility():GetManaCost(self:GetAbility():GetLevel())

		local cooldown = self:GetAbility():GetCooldown(self:GetAbility():GetLevel()-1)

		if hp < threshold then

			if cast_me then
				local duration = self:GetAbility():GetSpecialValueFor("duration")

				if mana_cost > 0 then
					caster:SpendMana(mana_cost, self:GetAbility())
				end

				caster:AddNewModifier(caster, self:GetAbility(), "modifier_grave_guard_recovery", {Duration=duration}) --[[Returns:void
				No Description Set
				]]
				caster:EmitSound("Erra.GraveGuard")

				self:GetAbility():StartCooldown(cooldown)
			end

		end
	end

end

modifier_grave_guard_aura = class({})

function modifier_grave_guard_aura:IsAura()
	return true
end

function modifier_grave_guard_aura:GetAuraRadius()
	return 1
end

function modifier_grave_guard_aura:GetAuraSearchFlags()
	return 0
end

function modifier_grave_guard_aura:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_grave_guard_aura:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO
end

function modifier_grave_guard_aura:GetModifierAura()
	return "modifier_grave_guard"
end

function modifier_grave_guard_aura:IsHidden()
	return true
end

modifier_grave_guard_recovery = class({})

function modifier_grave_guard_recovery:GetEffectName()
	return "particles/units/heroes/hero_erra/grave_guard_unit.vpcf"
end

function modifier_grave_guard_recovery:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT
	}
	return funcs
end

function modifier_grave_guard_recovery:GetModifierConstantHealthRegen()
	return self:GetAbility():GetSpecialValueFor("hp_recovery")
end

function modifier_grave_guard_recovery:GetModifierConstantManaRegen()
	return self:GetAbility():GetSpecialValueFor("mp_recovery")
end