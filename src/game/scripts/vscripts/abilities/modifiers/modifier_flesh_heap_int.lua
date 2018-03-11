modifier_flesh_heap_int = class({})



--------------------------------------------------------------------------------

function modifier_flesh_heap_int:IsHidden()
    if self:GetAbility():GetLevel() == 0 then
        return true
    end
    return false
end

--------------------------------------------------------------------------------

function modifier_flesh_heap_int:RemoveOnDeath()
    return false
end

--------------------------------------------------------------------------------
function modifier_flesh_heap_int:IsPurgable()
    return false
end

--------------------------------------------------------------------------------

function modifier_flesh_heap_int:OnCreated( kv )
	if not self:GetAbility() then
		self:GetParent():RemoveModifierByName("modifier_flesh_heap_int")
		self:GetParent():CalculateStatBonus()
		return
	end
	self.fleshHeapIntelligenceBuffAmount = self:GetAbility():GetSpecialValueFor( "flesh_heap_intelligence_buff_amount" ) or 0
	if IsServer() then
		self:SetStackCount( self:GetAbility():GetFleshHeapKills() )
		self:GetParent():CalculateStatBonus()
	end
end

--------------------------------------------------------------------------------

function modifier_flesh_heap_int:OnRefresh( kv )
	if not self:GetAbility() then
		self:GetParent():RemoveModifierByName("modifier_flesh_heap_int")
		self:GetParent():CalculateStatBonus()
		return
	end
	self.fleshHeapIntelligenceBuffAmount = self:GetAbility():GetSpecialValueFor( "flesh_heap_intelligence_buff_amount" ) or 0
	if IsServer() then
		self:SetStackCount( self:GetAbility():GetFleshHeapKills())
		self:GetParent():CalculateStatBonus()
	end
end

--------------------------------------------------------------------------------

function modifier_flesh_heap_int:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS
	}

	return funcs
end

--------------------------------------------------------------------------------


function modifier_flesh_heap_int:GetModifierBonusStats_Intellect( params )
	return self:GetStackCount() * self.fleshHeapIntelligenceBuffAmount
end
