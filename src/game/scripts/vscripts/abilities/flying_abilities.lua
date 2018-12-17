
-- Lua Library Imports
LinkLuaModifier("modifier_flying_with_slow","abilities/mutators/modifier_flying_with_slow.lua",LUA_MODIFIER_MOTION_NONE);
fly_redux = fly_redux or {}
fly_redux.__index = fly_redux
function fly_redux.new(construct, ...)
    local self = setmetatable({}, fly_redux)
    if construct and fly_redux.constructor then fly_redux.constructor(self, ...) end
    return self
end
function fly_redux.constructor(self)
end
function fly_redux.GetIntrinsicModifierName(self)
    return "modifier_flying_with_slow"
end
fly_redux_op = fly_redux_op or {}
fly_redux_op.__index = fly_redux_op
function fly_redux_op.new(construct, ...)
    local self = setmetatable({}, fly_redux_op)
    if construct and fly_redux_op.constructor then fly_redux_op.constructor(self, ...) end
    return self
end
function fly_redux_op.constructor(self)
end
function fly_redux_op.GetIntrinsicModifierName(self)
    return "modifier_flying_with_slow"
end
