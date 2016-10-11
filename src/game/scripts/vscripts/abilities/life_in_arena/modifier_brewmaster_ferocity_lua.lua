modifier_brewmaster_ferocity_lua = class({})

function modifier_brewmaster_ferocity_lua:IsHidden()
	--print(self:GetStackCount())
	if self:GetStackCount() == 0 then
		return true
	end
	return false
end

function modifier_brewmaster_ferocity_lua:OnCreated(event)
	self.radius = self:GetAbility():GetSpecialValueFor("radius")
	self.bonus_strength = 0
	if IsServer() then
		self:OnIntervalThink()
		self:StartIntervalThink( 0.2 )
	end
end

function modifier_brewmaster_ferocity_lua:IsPurgable()
	return false
end

function modifier_brewmaster_ferocity_lua:RemoveOnDeath()
	return false
end

function modifier_brewmaster_ferocity_lua:OnIntervalThink(event)
	if IsServer() and self:GetParent():IsAlive() then
		local previous_bonus_strength = self.bonus_strength

		local units = FindUnitsInRadius(self:GetParent():GetTeam(), 
										self:GetParent():GetAbsOrigin(), 
										nil, self.radius, 
										DOTA_UNIT_TARGET_TEAM_BOTH, 
										DOTA_UNIT_TARGET_CREEP + DOTA_UNIT_TARGET_HERO, 
										DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 
										FIND_ANY_ORDER, 
										false)
	
		self.bonus_strength_per_unit = self:GetAbility():GetSpecialValueFor("bonus_strength")
		self.bonus_strength = self.bonus_strength_per_unit * (#units-1) -- отнимаем 1 чтобы исключить самого героя	
	
		self:GetParent():ModifyStrength(self.bonus_strength - previous_bonus_strength) 
		self:GetParent():CalculateStatBonus()

		self:SetStackCount(self.bonus_strength)
		--self:ForceRefresh()
	end

end