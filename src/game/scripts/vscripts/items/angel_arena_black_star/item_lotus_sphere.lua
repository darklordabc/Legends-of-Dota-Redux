LinkLuaModifier("modifier_item_lotus_sphere", "items/angel_arena_black_star/item_lotus_sphere.lua", LUA_MODIFIER_MOTION_NONE)

item_lotus_sphere = class({
	GetIntrinsicModifierName = function() return "modifier_item_lotus_sphere" end,
})

modifier_item_lotus_sphere = class({
	IsPurgable  = function() return false end,
	IsHidden    = function() return true end,
	GetAttacker = function() return MODIFIER_ATTRIBUTE_MULTIPLE end,
})

function modifier_item_lotus_sphere:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_MANA_REGEN_PERCENTAGE,
		MODIFIER_PROPERTY_MANA_BONUS,
		MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE,
		MODIFIER_PROPERTY_REFLECT_SPELL,
		MODIFIER_PROPERTY_ABSORB_SPELL,
	}
end

function modifier_item_lotus_sphere:GetModifierPreAttack_BonusDamage()
	return self:GetAbility():GetSpecialValueFor("bonus_damage")
end

function modifier_item_lotus_sphere:GetModifierBonusStats_Strength()
	return self:GetAbility():GetSpecialValueFor("bonus_all_stats")
end

function modifier_item_lotus_sphere:GetModifierBonusStats_Agility()
	return self:GetAbility():GetSpecialValueFor("bonus_all_stats")
end

function modifier_item_lotus_sphere:GetModifierBonusStats_Intellect()
	return self:GetAbility():GetSpecialValueFor("bonus_all_stats")
end

function modifier_item_lotus_sphere:GetModifierPhysicalArmorBonus()
	return self:GetAbility():GetSpecialValueFor("bonus_armor")
end

function modifier_item_lotus_sphere:GetModifierPercentageManaRegen()
	return self:GetAbility():GetSpecialValueFor("bonus_mana_regen_pct")
end

function modifier_item_lotus_sphere:GetModifierManaBonus()
	return self:GetAbility():GetSpecialValueFor("bonus_mana")
end

function modifier_item_lotus_sphere:GetModifierHealthRegenPercentage()
	return self:GetAbility():GetSpecialValueFor("bonus_hp_regen_pct")
end

if IsServer() then
	function modifier_item_lotus_sphere:OnDestroy()
		if IsValidEntity(self.reflect_stolen_ability) then
			self.reflect_stolen_ability:RemoveSelf()
		end
	end

	function modifier_item_lotus_sphere:GetReflectSpell(keys)
		local parent = self:GetParent()
		local originalAbility = keys.ability
		self.absorb_without_check = false
		if originalAbility:GetCaster():GetTeam() ~= parent:GetTeam() then
			if PreformAbilityPrecastActions(parent, self:GetAbility()) then
				ParticleManager:SetParticleControlEnt(ParticleManager:CreateParticle("particles/arena/items_fx/lotus_sphere.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent), 0, parent, PATTACH_POINT_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
				parent:EmitSound("Item.LotusOrb.Activate")
				self.absorb_without_check = true

				if IsValidEntity(self.reflect_stolen_ability) then
					self.reflect_stolen_ability:RemoveSelf()
				end
				local hCaster = self:GetParent()
				local hAbility = hCaster:AddAbility(originalAbility:GetAbilityName())
				if hAbility then
					hAbility:SetStolen(true)
					hAbility:SetHidden(true)
					hAbility:SetLevel(originalAbility:GetLevel())
					hCaster:SetCursorCastTarget(originalAbility:GetCaster())
					hAbility:OnSpellStart()
					hAbility:SetActivated(false)
					self.reflect_stolen_ability = hAbility
				end
			end
		end
	end

	function modifier_item_lotus_sphere:GetAbsorbSpell(keys)
		local parent = self:GetParent()
		if self.absorb_without_check then
			self.absorb_without_check = nil
			return 1
		end
		return false
	end
end
