modifier_creep_power = class({})
 
function modifier_creep_power:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE
	}
	return funcs
end

function modifier_creep_power:OnIntervalThink()
	local parent = self:GetParent()
    local ability = self:GetAbility()

    if ability then
		self.level = self:GetStackCount()
		self.hp_scaling = self.level * ability:GetSpecialValueFor("health_per_level")
		self.damage_scaling = self.level * ability:GetSpecialValueFor("damage_per_level")
		self.bounty_scaling = self.level * (ability:GetSpecialValueFor("coef") / 100)
		--self.resist_scaling = self.level * ability:GetSpecialValueFor("resist_per_level")

		if IsServer() then
			--parent:SetBaseMagicalResistanceValue(math.ceil(parent:GetBaseMagicalResistanceValue() + self.resist_scaling))

			parent:SetMinimumGoldBounty(parent:GetMinimumGoldBounty() + (parent:GetMinimumGoldBounty() * self.bounty_scaling))
			parent:SetMaximumGoldBounty(parent:GetMaximumGoldBounty() + (parent:GetMaximumGoldBounty() * self.bounty_scaling))

			parent:SetModelScale(parent:GetModelScale() + (parent:GetModelScale() * 0.02 * math.min(12, self.level)))

			parent:AddNewModifier(self:GetCaster(), ability, "modifier_creep_power_hp", {duration = self:GetDuration()})
			
			--parent:AddAbility("lod_creep_power_hp")
			--for i=1,math.floor(self.level/3) do
			--	parent:FindAbilityByName("lod_creep_power_hp"):UpgradeAbility(false)
			--end

			self:StartIntervalThink(-1)
		end
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

function modifier_creep_power:GetModifierPreAttack_BonusDamage(params)
	return self.damage_scaling
end


modifier_creep_power_hp = {
	IsHidden = function() return true end,
	IsPurgable = function() return false end,
	OnRefresh = function(self, kv) self:OnCreated(kv) end,
	OnCreated = function(self, kv)
		if not IsServer() then return end
		self.hp = self.hp or self:GetParent():GetMaxHealth()
		local level = self:GetParent():GetModifierStackCount("modifier_creep_power", self:GetCaster()) or 0
		--"bonus_hp" "20 50 80 110 140 170 200 230 260 290 320 350 380 410 440 470 500 530 560 590"
		local bonus = (level>3 and 20 or 0) + 30 * (level/3)
		if self:GetParent().SetMaxHealth then
			self:GetParent():SetMaxHealth(self.hp + self.hp * bonus * 0.01)
		end
		if self:GetParent().SetBaseMaxHealth then
			self:GetParent():SetBaseMaxHealth(self.hp + self.hp * bonus * 0.01)
		end
		if self:GetParent().SetHealth then
			self:GetParent():SetHealth(self.hp + self.hp * bonus * 0.01)
		end
	end,
	OnDestroy = function(self)
		if self:GetParent().SetMaxHealth then
			self:GetParent():SetMaxHealth(self.hp)
		end
		if self:GetParent().SetBaseMaxHealth then
			self:GetParent():SetBaseMaxHealth(self.hp)
		end
	end,
}