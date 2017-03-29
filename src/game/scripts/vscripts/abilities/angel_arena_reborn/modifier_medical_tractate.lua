modifier_medical_tractate = class({})


function modifier_medical_tractate:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_HEALTH_BONUS,
		MODIFIER_PROPERTY_MANA_BONUS,
	}
 
	return funcs
end

function modifier_medical_tractate:GetAttributes()
	local attrs = {
			MODIFIER_ATTRIBUTE_PERMANENT,
		}

	return attrs
end

function modifier_medical_tractate:IsHidden()
	return true
end

function modifier_medical_tractate:IsPurgable()
	return false
end

function modifier_medical_tractate:GetModifierHealthBonus(params)
	if not self:GetCaster() then return 0 end
	self:GetCaster().medical_tractates = self:GetCaster().medical_tractates or 0

	return self.health_bonus*self:GetCaster().medical_tractates
end

function modifier_medical_tractate:OnCreated(event)
	self.health_bonus = 40
	self.mana_bonus = 20

	SendOverheadEventMessage(nil, OVERHEAD_ALERT_MAGICAL_BLOCK, self:GetCaster(), self:GetCaster().medical_tractates, nil)
end

function modifier_medical_tractate:GetModifierManaBonus(event)
	if not self:GetCaster() then return 0 end
	self:GetCaster().medical_tractates = self:GetCaster().medical_tractates or 0
	
	return self.mana_bonus*self:GetCaster().medical_tractates
end
