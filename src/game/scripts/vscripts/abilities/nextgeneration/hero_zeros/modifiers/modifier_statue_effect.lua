if modifier_statue_effect == nil then
	modifier_statue_effect = class({})
end

function modifier_statue_effect:DeclareFunctions()
	return 
	{ 
		MODIFIER_PROPERTY_BOUNTY_CREEP_MULTIPLIER,
	}
end

function modifier_statue_effect:GetAttributes() 
    return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

function modifier_statue_effect:IsHidden()
    return false
end

function modifier_statue_effect:GetModifierBountyCreepMultiplier()
	return -90
end

function modifier_statue_effect:GetEffectName()
    return "particles/econ/courier/courier_golden_doomling/courier_golden_doomling_bloom_ambient.vpcf"
end

function modifier_statue_effect:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end
