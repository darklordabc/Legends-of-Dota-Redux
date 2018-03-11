modifier_brewmaster_ferocity_lua_agi = class({})

function modifier_brewmaster_ferocity_lua_agi:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS
	}
 
	return funcs
end

function modifier_brewmaster_ferocity_lua_agi:GetModifierBonusStats_Agility()
	return self:GetStackCount()
end

function modifier_brewmaster_ferocity_lua_agi:IsHidden()
	--print(self:GetStackCount())
	if self:GetStackCount() == 0 then
		return true
	end
	return false
end

function modifier_brewmaster_ferocity_lua_agi:OnCreated(event)
	self.radius = self:GetAbility():GetSpecialValueFor("radius")
	self.bonus_agility = 0
	if IsServer() then
		self:OnIntervalThink()
		self:StartIntervalThink( 0.2 )
	end
end

function modifier_brewmaster_ferocity_lua_agi:IsPurgable()
	return false
end

function modifier_brewmaster_ferocity_lua_agi:RemoveOnDeath()
	return false
end

function modifier_brewmaster_ferocity_lua_agi:OnIntervalThink(event)
	if IsServer() and self:GetParent():IsAlive() then
		if self:GetParent():PassivesDisabled() then
			self:SetStackCount(0)
			return
		end
		local previous_bonus_agility = self.bonus_agility

		local units = FindUnitsInRadius(self:GetParent():GetTeam(), 
										self:GetParent():GetAbsOrigin(), 
										nil, self:GetAbility():GetSpecialValueFor("radius"), 
										DOTA_UNIT_TARGET_TEAM_BOTH, 
										DOTA_UNIT_TARGET_CREEP + DOTA_UNIT_TARGET_HERO, 
										DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 
										FIND_ANY_ORDER, 
										false)

		self.bonus_agility_per_unit = self:GetAbility():GetSpecialValueFor("bonus_agility")
		self.bonus_agility = self.bonus_agility_per_unit * (#units-1) -- отнимаем 1 чтобы исключить самого героя	

		self:SetStackCount(self.bonus_agility)

		return 0.2
	end
end