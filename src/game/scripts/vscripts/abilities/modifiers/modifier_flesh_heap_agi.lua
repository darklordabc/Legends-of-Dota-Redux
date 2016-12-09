--Taken from the spelllibrary, credits go to valve

modifier_flesh_heap_agi = class({})


--------------------------------------------------------------------------------

function modifier_flesh_heap_agi:IsHidden()
    if self:GetAbility():GetLevel() == 0 then
        return true
    end
    return false
end

--------------------------------------------------------------------------------

function modifier_flesh_heap_agi:RemoveOnDeath()
    return false
end

--------------------------------------------------------------------------------

function modifier_flesh_heap_agi:IsPurgable()
    return false
end

--------------------------------------------------------------------------------

function modifier_flesh_heap_agi:OnCreated( kv )
	if not self:GetAbility() then
		self:GetParent():RemoveModifierByName("modifier_flesh_heap_agi")
		self:GetParent():CalculateStatBonus()
		return
	end
	self.fleshHeapAgilityBuffAmount = self:GetAbility():GetSpecialValueFor( "flesh_heap_agility_buff_amount" ) or 0
	if IsServer() then
		self:SetStackCount( self:GetAbility():GetFleshHeapKills() )
		self:GetParent():CalculateStatBonus()
	end
end

--------------------------------------------------------------------------------

function modifier_flesh_heap_agi:OnRefresh( kv )
	if not self:GetAbility() then
		self:GetParent():RemoveModifierByName("modifier_flesh_heap_agi")
		self:GetParent():CalculateStatBonus()
		return
	end
	self.fleshHeapAgilityBuffAmount = self:GetAbility():GetSpecialValueFor( "flesh_heap_agility_buff_amount" ) or 0
	if IsServer() then
		self:SetStackCount( self:GetAbility():GetFleshHeapKills() )
		self:GetParent():CalculateStatBonus()
	end
end

--------------------------------------------------------------------------------

function modifier_flesh_heap_agi:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS
	}

	return funcs
end

--------------------------------------------------------------------------------


function modifier_flesh_heap_agi:GetModifierBonusStats_Agility( params )
	return self:GetStackCount() * self.fleshHeapAgilityBuffAmount
end
