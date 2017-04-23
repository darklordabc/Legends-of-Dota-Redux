modifier_hidden_invis = class({})

function modifier_hidden_invis:IsHidden()
	return true
end

function modifier_hidden_invis:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_INVISIBILITY_LEVEL
	}

	return funcs
end

--------------------------------------------------------------------------------

function modifier_hidden_invis:GetModifierInvisibilityLevel( params )
	return 0.45
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
