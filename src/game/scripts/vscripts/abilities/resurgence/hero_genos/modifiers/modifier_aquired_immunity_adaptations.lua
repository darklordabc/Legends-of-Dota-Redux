--[[Author: TheGreatGimmick
    Date: April 8, 2017
    Modifier dislays transfigure charges]]

modifier_aquired_immunity_adaptations = class({})


function modifier_aquired_immunity_adaptations:DeclareFunctions()
	local funcs = {
	     MODIFIER_PROPERTY_STATS_STRENGTH_BONUS 
	}

	return funcs
end

function modifier_aquired_immunity_adaptations:GetModifierBonusStats_Strength()
	return 15*(self:GetStackCount())
end

function modifier_aquired_immunity_adaptations:IsHidden() 
	return false
end

function modifier_aquired_immunity_adaptations:IsPermanent() 
	return true
end