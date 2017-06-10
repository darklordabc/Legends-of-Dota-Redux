--[[Author: TheGreatGimmick
    Date: April 8, 2017
    Modifier dislays transfigure charges]]

modifier_flight_instinct_adaptations = class({})


function modifier_flight_instinct_adaptations:DeclareFunctions()
	local funcs = {
	     MODIFIER_PROPERTY_STATS_AGILITY_BONUS 
	}

	return funcs
end

function modifier_flight_instinct_adaptations:GetModifierBonusStats_Agility()
	return 15*(self:GetStackCount())
end

function modifier_flight_instinct_adaptations:IsHidden() 
	return false
end

function modifier_flight_instinct_adaptations:IsPermanent() 
	return true
end