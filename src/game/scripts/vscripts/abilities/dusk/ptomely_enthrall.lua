ptomely_enthrall = class({})

LinkLuaModifier("modifier_enthrall","abilities/dusk/ptomely_enthrall",LUA_MODIFIER_MOTION_NONE)

function ptomely_enthrall:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local duration = self:GetSpecialValueFor("duration")

	target:AddNewModifier(caster, self, "modifier_enthrall", {Duration=duration})
end

modifier_enthrall = class({})

function modifier_enthrall:DeclareFunctions()
	local func = {
		MODIFIER_EVENT_ON_TAKEDAMAGE,
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS
	}
	return func
end

function modifier_enthrall:GetEffectName()
	return "particles/units/heroes/hero_ptomely/enthrall.vpcf"
end

function modifier_enthrall:OnTakeDamage(params)
	if IsServer() then
		local target = params.unit or params.target
		local attacker = params.attacker
		local original_damage = params.original_damage
		local damage_type = params.damage_type

		-- self.last_original_damage = original_damage

		-- self.ignore_damage = false

		-- if not self.ignore_damage then
		-- 	self:GetAbility():InflictDamage(target,attacker,original_damage,DAMAGE_TYPE_MAGICAL)
		-- end

		-- self.ignore_damage = true
	end
end

function modifier_enthrall:GetModifierMagicalResistanceBonus()
	return -self:GetAbility():GetSpecialValueFor("magic_resistance_reduction")
end