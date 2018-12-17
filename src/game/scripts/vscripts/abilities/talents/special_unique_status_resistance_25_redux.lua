
-- Lua Library Imports
modifier_special_unique_status_resistance_25_redux = modifier_special_unique_status_resistance_25_redux or {}
modifier_special_unique_status_resistance_25_redux.__index = modifier_special_unique_status_resistance_25_redux
function modifier_special_unique_status_resistance_25_redux.new(construct, ...)
    local self = setmetatable({}, modifier_special_unique_status_resistance_25_redux)
    if construct and modifier_special_unique_status_resistance_25_redux.constructor then modifier_special_unique_status_resistance_25_redux.constructor(self, ...) end
    return self
end
function modifier_special_unique_status_resistance_25_redux.constructor(self)
end
function modifier_special_unique_status_resistance_25_redux.IsPermanent(self)
    return true
end
function modifier_special_unique_status_resistance_25_redux.IsHidden(self)
    return true
end
function modifier_special_unique_status_resistance_25_redux.DeclareFunctions(self)
    return {MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING}
end
function modifier_special_unique_status_resistance_25_redux.GetModifierStatusResistanceStacking(self)
    return 20
end
