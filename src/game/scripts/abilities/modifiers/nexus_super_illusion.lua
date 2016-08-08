if nexus_super_illusion == nil then
	nexus_super_illusion = class({})
end

function nexus_super_illusion:DeclareFunctions()
	return 
	{ 
	MODIFIER_PROPERTY_SUPER_ILLUSION,
	MODIFIER_PROPERTY_ILLUSION_LABEL, 
	--MODIFIER_PROPERTY_IS_ILLUSION,
	}
end

function nexus_super_illusion:GetAttributes()
    return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end
function nexus_super_illusion:IsHidden()
    return true
end

--[[function nexus_super_illusion:GetIsIllusion()
	return true
end]]

function nexus_super_illusion:GetModifierSuperIllusion()
	return true
end

function nexus_super_illusion:GetModifierIllusionLabel()
	return true
end
function nexus_super_illusion:CheckState()
 	return 
 	{ 
 	[MODIFIER_STATE_INVISIBLE] = true,
 	[MODIFIER_STATE_UNSELECTABLE] = true,
 	[MODIFIER_STATE_TRUESIGHT_IMMUNE] = true,
 	[MODIFIER_STATE_DISARMED] = true,
 	[MODIFIER_STATE_INVULNERABLE] = true,
 	[MODIFIER_STATE_MAGIC_IMMUNE] = true,
 	[MODIFIER_STATE_PASSIVES_DISABLED] = true,
 	[MODIFIER_STATE_ATTACK_IMMUNE] = true,
 	[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
 	[MODIFIER_STATE_FLYING] = true,
 	[MODIFIER_STATE_ROOTED] = true,
 	[MODIFIER_STATE_NO_HEALTH_BAR] = true,
 	[MODIFIER_STATE_NOT_ON_MINIMAP] = true,
 	} 
end
