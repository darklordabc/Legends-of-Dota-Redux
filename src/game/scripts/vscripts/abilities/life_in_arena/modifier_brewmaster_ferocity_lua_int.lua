modifier_brewmaster_ferocity_lua_int = class({})

function modifier_brewmaster_ferocity_lua_int:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS
	}
 
	return funcs
end

function modifier_brewmaster_ferocity_lua_int:GetModifierBonusStats_Intellect()
	return self:GetStackCount()
end

function modifier_brewmaster_ferocity_lua_int:IsHidden()
	--print(self:GetStackCount())
	if self:GetStackCount() == 0 then
		return true
	end
	return false
end

function modifier_brewmaster_ferocity_lua_int:OnCreated(event)
	self.radius = self:GetAbility():GetSpecialValueFor("radius")
	self.bonus_intelligence = 0
	if IsServer() then
		self:OnIntervalThink()
		self:StartIntervalThink( 0.2 )
	end
end

function modifier_brewmaster_ferocity_lua_int:IsPurgable()
	return false
end

function modifier_brewmaster_ferocity_lua_int:RemoveOnDeath()
	return false
end

function modifier_brewmaster_ferocity_lua_int:OnIntervalThink(event)
	if IsServer() and self:GetParent():IsAlive() then
		if self:GetParent():PassivesDisabled() then
			self:SetStackCount(0)
			return
		end
		
		local previous_bonus_intelligence = self.bonus_intelligence

		local units = FindUnitsInRadius(self:GetParent():GetTeam(), 
										self:GetParent():GetAbsOrigin(), 
										nil, self:GetAbility():GetSpecialValueFor("radius"), 
										DOTA_UNIT_TARGET_TEAM_BOTH, 
										DOTA_UNIT_TARGET_CREEP + DOTA_UNIT_TARGET_HERO, 
										DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 
										FIND_ANY_ORDER, 
										false)

		self.bonus_intelligence_per_unit = self:GetAbility():GetSpecialValueFor("bonus_intelligence")
		self.bonus_intelligence = self.bonus_intelligence_per_unit * (#units-1) -- отнимаем 1 чтобы исключить самого героя	

		self:SetStackCount(self.bonus_intelligence)

		return 0.2
	end
end