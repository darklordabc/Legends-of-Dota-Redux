modifier_brewmaster_ferocity_lua_all = class({})

function modifier_brewmaster_ferocity_lua_all:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS
	}
 
	return funcs
end

function modifier_brewmaster_ferocity_lua_all:GetModifierBonusStats_Intellect()
	return self:GetStackCount()
end

function modifier_brewmaster_ferocity_lua_all:GetModifierBonusStats_Agility()
	return self:GetStackCount()
end

function modifier_brewmaster_ferocity_lua_all:GetModifierBonusStats_Strength()
	return self:GetStackCount()
end

function modifier_brewmaster_ferocity_lua_all:IsHidden()
	--print(self:GetStackCount())
	if self:GetStackCount() == 0 then
		return true
	end
	return false
end

function modifier_brewmaster_ferocity_lua_all:OnCreated(event)
	self.radius = self:GetAbility():GetSpecialValueFor("radius")
	self.bonus_all = 0
	if IsServer() then
		self:OnIntervalThink()
		self:StartIntervalThink( 0.2 )
	end
end

function modifier_brewmaster_ferocity_lua_all:IsPurgable()
	return false
end

function modifier_brewmaster_ferocity_lua_all:RemoveOnDeath()
	return false
end

function modifier_brewmaster_ferocity_lua_all:OnIntervalThink(event)
	if IsServer() and self:GetParent():IsAlive() then
		if self:GetParent():PassivesDisabled() then
			self:SetStackCount(0)
			return
		end
		local previous_bonus_all = self.bonus_all

		local units = FindUnitsInRadius(self:GetParent():GetTeam(), 
										self:GetParent():GetAbsOrigin(), 
										nil, self:GetAbility():GetSpecialValueFor("radius"), 
										DOTA_UNIT_TARGET_TEAM_BOTH, 
										DOTA_UNIT_TARGET_CREEP + DOTA_UNIT_TARGET_HERO, 
										DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 
										FIND_ANY_ORDER, 
										false)

		self.bonus_all_per_unit = self:GetAbility():GetSpecialValueFor("bonus_all")
		self.bonus_all = self.bonus_all_per_unit * (#units-1) -- отнимаем 1 чтобы исключить самого героя	

		self:SetStackCount(self.bonus_all)

		return 0.2
	end
end