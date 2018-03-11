modifier_siege_mode_no_movement = class({})

function modifier_siege_mode_no_movement:DeclareFunctions()
	local funcs = 
	{
		--MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE,
		MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE_MIN,
		--MODIFIER_PROPERTY_MOVESPEED_BASE_OVERRIDE
	}
	return funcs
end

--[[function modifier_siege_mode_no_movement:GetModifierMoveSpeed_Absolute (params)
	return 0
end]]

function modifier_siege_mode_no_movement:GetModifierMoveSpeed_AbsoluteMin (params)
	return 0
end
--[[
function modifier_siege_mode_no_movement:GetModifierMoveSpeedOverride (params)
	return 0
end
]]
