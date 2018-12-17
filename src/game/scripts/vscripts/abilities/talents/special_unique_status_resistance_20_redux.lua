
-- Lua Library Imports
modifier_special_unique_status_resistance_20_redux = modifier_special_unique_status_resistance_20_redux or {}
modifier_special_unique_status_resistance_20_redux.__index = modifier_special_unique_status_resistance_20_redux
function modifier_special_unique_status_resistance_20_redux.new(construct, ...)
    local self = setmetatable({}, modifier_special_unique_status_resistance_20_redux)
    if construct and modifier_special_unique_status_resistance_20_redux.constructor then modifier_special_unique_status_resistance_20_redux.constructor(self, ...) end
    return self
end
function modifier_special_unique_status_resistance_20_redux.constructor(self)
end
function modifier_special_unique_status_resistance_20_redux.IsPermanent(self)
    return true
end
function modifier_special_unique_status_resistance_20_redux.IsHidden(self)
    return true
end
function modifier_special_unique_status_resistance_20_redux.DeclareFunctions(self)
    return {MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING}
end
function modifier_special_unique_status_resistance_20_redux.GetModifierStatusResistanceStacking(self)
    return 20
end
