modifier_movespeed_cap = class({})

function modifier_movespeed_cap:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_MAX,
        MODIFIER_PROPERTY_MOVESPEED_LIMIT,
    }

    return funcs
end

function modifier_movespeed_cap:GetModifierMoveSpeed_Max( params )
    return 5000
end

function modifier_movespeed_cap:GetModifierMoveSpeed_Limit( params )
    return 5000
end

function modifier_movespeed_cap:IsPurgable()
    return false
end

function modifier_movespeed_cap:IsHidden()
    return true
end
