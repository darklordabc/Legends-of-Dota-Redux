if vicissitude_super_illusion == nil then
	vicissitude_super_illusion = class({})
end

function vicissitude_super_illusion:DeclareFunctions()
	return 
	{ 
	MODIFIER_PROPERTY_SUPER_ILLUSION,
	MODIFIER_PROPERTY_ILLUSION_LABEL, 
	--MODIFIER_PROPERTY_IS_ILLUSION,
	}
end

function vicissitude_super_illusion:GetAttributes() 
    return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end
function vicissitude_super_illusion:IsHidden()
    return true
end

function vicissitude_super_illusion:GetModifierSuperIllusion()
	return true
end

function vicissitude_super_illusion:GetModifierIllusionLabel()
	return true
end
