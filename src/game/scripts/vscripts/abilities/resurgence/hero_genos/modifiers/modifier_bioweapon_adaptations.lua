--[[Author: TheGreatGimmick
    Date: April 8, 2017
    Modifier dislays transfigure charges]]

modifier_bioweapon_adaptations = class({})


function modifier_bioweapon_adaptations:DeclareFunctions()
	local funcs = {
	   MODIFIER_PROPERTY_STATS_INTELLECT_BONUS 
	}

	return funcs
end

function modifier_bioweapon_adaptations:GetModifierBonusStats_Intellect()
	return 15*(self:GetStackCount())
end

function modifier_bioweapon_adaptations:IsHidden() 
	return false
end

function modifier_bioweapon_adaptations:IsPermanent() 
	return true
end