modifier_lust_for_life = class({})

function modifier_lust_for_life:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS
	}
	return funcs
end

function modifier_lust_for_life:IsHidden()
	--print(self:GetStackCount())
	if self:GetStackCount() == 0 then
		return true
	end
	return false
end

if IsServer() then
    function modifier_lust_for_life:OnCreated()
        self:StartIntervalThink(1.0)
        self:OnIntervalThink()
    end

    function modifier_lust_for_life:OnIntervalThink(event)
		local caster = self:GetParent()
		local ability = self:GetAbility()
		local perChunk = self:GetAbility():GetSpecialValueFor("tolltip")
		print(caster:GetIntellect())
		while(caster:HasModifier("modifier_lust_for_life_health_regen")) do
			caster:RemoveModifierByName("modifier_lust_for_life_health_regen")
		end
		local modifierCount = 0
		if caster:GetIntellect() ~= 0 then
			modifierCount = math.ceil((100 - caster:GetHealthPercent())/perChunk)
		end
		
		self:SetStackCount(modifierCount)
	end
end

function modifier_lust_for_life:GetModifierHealthRegenPercentage()
	return self:GetAbility():GetSpecialValueFor("health_regen_percent") * self:GetStackCount()
end

function modifier_lust_for_life:GetModifierBonusStats_Intellect()
	return self:GetAbility():GetSpecialValueFor("intellect_sacrifice")
end

