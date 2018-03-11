modifier_butcher_zombie = class ({})

function modifier_butcher_zombie:IsHidden()
	return false
end

function modifier_butcher_zombie:IsPurgable()
	return false
end

function modifier_butcher_zombie:DestroyOnExpire()
	return false
end

function modifier_butcher_zombie:RemoveOnDeath()
	return false
end

function modifier_butcher_zombie:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_DEATH,
	}
 
	return funcs
end

function modifier_butcher_zombie:OnDeath(params)
	if string.find(params.unit:GetUnitName(),"butcher_zombie") and params.unit:GetOwner() == self:GetCaster() then
		self:SetStackCount(self:GetStackCount()-1)
	end
end



