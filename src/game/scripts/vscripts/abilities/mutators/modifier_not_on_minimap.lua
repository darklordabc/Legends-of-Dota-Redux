
-- Lua Library Imports
modifier_not_on_minimap_mutator = modifier_not_on_minimap_mutator or {}
modifier_not_on_minimap_mutator.__index = modifier_not_on_minimap_mutator
function modifier_not_on_minimap_mutator.new(construct, ...)
    local self = setmetatable({}, modifier_not_on_minimap_mutator)
    if construct and modifier_not_on_minimap_mutator.constructor then modifier_not_on_minimap_mutator.constructor(self, ...) end
    return self
end
function modifier_not_on_minimap_mutator.constructor(self)
end
function modifier_not_on_minimap_mutator.IsPermanent(self)
    return true
end
function modifier_not_on_minimap_mutator.IsHidden(self)
    return true
end
function modifier_not_on_minimap_mutator.CheckState(self)
    return {[MODIFIER_STATE_NOT_ON_MINIMAP] = true}
end
