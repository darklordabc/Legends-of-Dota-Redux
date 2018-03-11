modifier_ancient_priestess_ritual_protection = class({})

function modifier_ancient_priestess_ritual_protection:GetEffectName()
	return "particles/lotus_orb_shell_custom.vpcf"
end

function modifier_ancient_priestess_ritual_protection:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_ancient_priestess_ritual_protection:IsBuff()
	return true 
end

function modifier_ancient_priestess_ritual_protection:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_TOOLTIP,
	}
 
	return funcs
end

function modifier_ancient_priestess_ritual_protection:OnTooltip(params)
	return self:GetStackCount()
end

function modifier_ancient_priestess_ritual_protection:GetBlockDamage(attack_damage)
	local parent = self:GetParent()

	local damage_block

	if self.damage_absorb > attack_damage then 
		damage_block = attack_damage
		self.damage_absorb = self.damage_absorb - damage_block

		self:SetStackCount(self.damage_absorb)
	else 
		damage_block = self.damage_absorb 
		self:Destroy()
	end
	
	return damage_block
end

function modifier_ancient_priestess_ritual_protection:OnCreated(kv)
	if IsServer() then
		self.damage_absorb = self:GetAbility():GetSpecialValueFor("damage_absorb")
		self:SetStackCount(self.damage_absorb)
	end
end