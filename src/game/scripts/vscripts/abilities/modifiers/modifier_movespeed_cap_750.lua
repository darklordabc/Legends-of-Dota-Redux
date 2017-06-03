modifier_movespeed_cap_750 = class({})

function modifier_movespeed_cap_750:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_MAX,
        MODIFIER_PROPERTY_MOVESPEED_LIMIT,
    }

    return funcs
end

function modifier_movespeed_cap_750:GetModifierMoveSpeed_Max( params )
    return 750
end

function modifier_movespeed_cap_750:GetModifierMoveSpeed_Limit( params )
    return 750
end

function modifier_movespeed_cap_750:IsPurgable()
    return false
end

function modifier_movespeed_cap_750:IsHidden()
    return true
end
