
-- Lua Library Imports
modifier_special_unique_status_resistance_15_redux = modifier_special_unique_status_resistance_15_redux or {}
modifier_special_unique_status_resistance_15_redux.__index = modifier_special_unique_status_resistance_15_redux
function modifier_special_unique_status_resistance_15_redux.new(construct, ...)
    local self = setmetatable({}, modifier_special_unique_status_resistance_15_redux)
    if construct and modifier_special_unique_status_resistance_15_redux.constructor then modifier_special_unique_status_resistance_15_redux.constructor(self, ...) end
    return self
end
function modifier_special_unique_status_resistance_15_redux.constructor(self)
end
function modifier_special_unique_status_resistance_15_redux.IsPermanent(self)
    return true
end
function modifier_special_unique_status_resistance_15_redux.IsHidden(self)
    return true
end
function modifier_special_unique_status_resistance_15_redux.DeclareFunctions(self)
    return {MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING}
end
function modifier_special_unique_status_resistance_15_redux.GetModifierStatusResistanceStacking(self)
    return 20
end
