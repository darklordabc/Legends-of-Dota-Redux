if eat_tree_eldri_mod == nil then
	eat_tree_eldri_mod = class({})
end

function eat_tree_eldri_mod:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_TOOLTIP,
		MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE
	}
	return funcs
end

function eat_tree_eldri_mod:OnCreated(kv)
	if IsServer() then
		self:SetStackCount(kv.stack)
	end
end

function eat_tree_eldri_mod:OnRefresh(kv)
	if IsServer() then
		local nMax = 100
		local nStacks = self:GetStackCount()
		if nStacks <  nMax then
			self:SetStackCount(nStacks + kv.stack)
		end
	end
end

function eat_tree_eldri_mod:IsHidden()
	return false
end

function eat_tree_eldri_mod:IsPurgable() 
	return true
end

function eat_tree_eldri_mod:GetModifierPreAttack_BonusDamage()
	return self:GetStackCount() * self:GetAbility():GetSpecialValueFor("bonus")
end

function eat_tree_eldri_mod:OnTooltip()
	return self:GetStackCount() * self:GetAbility():GetSpecialValueFor("bonus")
end

function eat_tree_eldri_mod:GetModifierHealthRegenPercentage()
	return self:GetStackCount() * self:GetAbility():GetSpecialValueFor("regen")
end

function eat_tree_eldri_mod:GetEffectName()
	return "particles/eldri_power.vpcf"
end

function eat_tree_eldri_mod:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end