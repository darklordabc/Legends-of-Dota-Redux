modifier_movespeed_cap_900 = class({})

function modifier_movespeed_cap_900:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE_MAX,
        MODIFIER_PROPERTY_MOVESPEED_LIMIT,
    }

    return funcs
end

function modifier_movespeed_cap_900:GetModifierMoveSpeed_AbsoluteMax( params )
    return 900
end

function modifier_movespeed_cap_900:GetModifierMoveSpeed_Limit( params )
    return 900
end

function modifier_movespeed_cap_900:IsPurgable()
    return false
end

function modifier_movespeed_cap_900:IsHidden()
    return true
end

function modifier_movespeed_cap_900:OnCreated()
	if IsServer() then
		self:GetParent():AddNewModifier(self:GetParent(), nil, "modifier_bloodseeker_thirst", {})
	end
end