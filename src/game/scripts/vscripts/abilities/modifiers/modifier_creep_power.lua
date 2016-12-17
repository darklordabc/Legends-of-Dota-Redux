modifier_creep_power = class({})
 
function modifier_creep_power:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_EXTRA_HEALTH_BONUS,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE
	}
	return funcs
end

function modifier_creep_power:OnIntervalThink()
	local parent = self:GetParent()
    local ability = self:GetAbility()

	self.level = self:GetStackCount()
	self.hp_scaling = self.level * ability:GetSpecialValueFor("health_per_level")
	self.damage_scaling = self.level * ability:GetSpecialValueFor("damage_per_level")
	self.bounty_scaling = self.level * (ability:GetSpecialValueFor("coef") / 100)
	self.resist_scaling = self.level * ability:GetSpecialValueFor("resist_per_level")

	if IsServer() then
		parent:SetBaseMagicalResistanceValue(math.ceil(parent:GetBaseMagicalResistanceValue() + self.resist_scaling))

		parent:SetMinimumGoldBounty(parent:GetMinimumGoldBounty() + (parent:GetMinimumGoldBounty() * self.bounty_scaling))
		parent:SetMaximumGoldBounty(parent:GetMaximumGoldBounty() + (parent:GetMaximumGoldBounty() * self.bounty_scaling))

		parent:SetModelScale(parent:GetModelScale() + (parent:GetModelScale() * 0.02 * math.min(12, self.level)))

		parent:AddAbility("lod_creep_power_hp")
		
		for i=1,math.floor(self.level/3) do
			parent:FindAbilityByName("lod_creep_power_hp"):UpgradeAbility(false)
		end

		self:StartIntervalThink(-1)
	end
end
 
function modifier_creep_power:IsHidden()
    return false
end

function modifier_creep_power:IsPurgable()
    return false
end
 
function modifier_creep_power:OnCreated()
	self:StartIntervalThink(0.03)
end
 
function modifier_creep_power:GetModifierExtraHealthBonus(params)
	return 0 --self.hp_scaling
end

function modifier_creep_power:GetModifierPreAttack_BonusDamage(params)
	return self.damage_scaling
end