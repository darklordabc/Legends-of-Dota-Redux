if berserker_mod == nil then
	berserker_mod = class({})
end

function berserker_mod:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_TAKEDAMAGE,
		MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT
	}
 
	return funcs
end

function berserker_mod:IsHidden()
	return ( self:GetStackCount() == 0 )
end

function berserker_mod:OnCreated()
	if IsServer() then
	end
end

function berserker_mod:OnIntervalThink()
	if IsServer() then
		self:SetStackCount(0)
		self:StartIntervalThink(-1) 
	end
end

function berserker_mod:OnTakeDamage(keys)
	if IsServer() then
		if keys.unit == self:GetParent()  then
			if self:GetParent():PassivesDisabled() then return end
			if self:GetStackCount() < self:GetAbility():GetSpecialValueFor("max") then
				self:IncrementStackCount()
			end
			self:SetDuration(self:GetAbility():GetSpecialValueFor("duration"), true) 
			self:StartIntervalThink(self:GetAbility():GetSpecialValueFor("duration")) 
		end
	end
end

function berserker_mod:GetModifierBaseAttack_BonusDamage()
	return self:GetStackCount() * self:GetAbility():GetSpecialValueFor("damage")
end

function berserker_mod:GetModifierAttackSpeedBonus_Constant()
	return self:GetStackCount() * self:GetAbility():GetSpecialValueFor("speed")
end

function berserker_mod:DestroyOnExpire()
	return false
end