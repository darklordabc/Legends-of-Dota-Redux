
-- Lua Library Imports
modifier_no_healthbar_mutator = modifier_no_healthbar_mutator or {}
modifier_no_healthbar_mutator.__index = modifier_no_healthbar_mutator
function modifier_no_healthbar_mutator.new(construct, ...)
    local self = setmetatable({}, modifier_no_healthbar_mutator)
    if construct and modifier_no_healthbar_mutator.constructor then modifier_no_healthbar_mutator.constructor(self, ...) end
    return self
end
function modifier_no_healthbar_mutator.constructor(self)
end
function modifier_no_healthbar_mutator.IsPermanent(self)
    return true
end
function modifier_no_healthbar_mutator.IsHidden(self)
    return true
end
function modifier_no_healthbar_mutator.CheckState(self)
    return {[MODIFIER_STATE_NO_HEALTH_BAR] = true}
end
