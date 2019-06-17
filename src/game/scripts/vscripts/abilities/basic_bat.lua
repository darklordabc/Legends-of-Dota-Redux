
-- Lua Library Imports
LinkLuaModifier("modifier_basic_bat","abilities/basic_bat.lua",LUA_MODIFIER_MOTION_NONE);
LinkLuaModifier("modifier_basic_bat_reduction","abilities/basic_bat.lua",LUA_MODIFIER_MOTION_NONE);
basic_bat = basic_bat or {}
basic_bat.__index = basic_bat
function basic_bat.new(construct, ...)
    local self = setmetatable({}, basic_bat)
    if construct and basic_bat.constructor then basic_bat.constructor(self, ...) end
    return self
end
function basic_bat.constructor(self)
end
function basic_bat.GetIntrinsicModifierName(self)
    return "modifier_basic_bat"
end
basic_bat_op = basic_bat_op or {}
basic_bat_op.__index = basic_bat_op
function basic_bat_op.new(construct, ...)
    local self = setmetatable({}, basic_bat_op)
    if construct and basic_bat_op.constructor then basic_bat_op.constructor(self, ...) end
    return self
end
function basic_bat_op.constructor(self)
end
function basic_bat_op.GetIntrinsicModifierName(self)
    return "modifier_basic_bat"
end
basic_bat_reduction = basic_bat_reduction or {}
basic_bat_reduction.__index = basic_bat_reduction
function basic_bat_reduction.new(construct, ...)
    local self = setmetatable({}, basic_bat_reduction)
    if construct and basic_bat_reduction.constructor then basic_bat_reduction.constructor(self, ...) end
    return self
end
function basic_bat_reduction.constructor(self)
end
function basic_bat_reduction.GetIntrinsicModifierName(self)
    return "modifier_basic_bat_reduction"
end
basic_bat_reduction_op = basic_bat_reduction_op or {}
basic_bat_reduction_op.__index = basic_bat_reduction_op
function basic_bat_reduction_op.new(construct, ...)
    local self = setmetatable({}, basic_bat_reduction_op)
    if construct and basic_bat_reduction_op.constructor then basic_bat_reduction_op.constructor(self, ...) end
    return self
end
function basic_bat_reduction_op.constructor(self)
end
function basic_bat_reduction_op.GetIntrinsicModifierName(self)
    return "modifier_basic_bat_reduction"
end
modifier_basic_bat = modifier_basic_bat or {}
modifier_basic_bat.__index = modifier_basic_bat
function modifier_basic_bat.new(construct, ...)
    local self = setmetatable({}, modifier_basic_bat)
    if construct and modifier_basic_bat.constructor then modifier_basic_bat.constructor(self, ...) end
    return self
end
function modifier_basic_bat.constructor(self)
end
function modifier_basic_bat.IsPermanent(self)
    return true
end
function modifier_basic_bat.IsHidden(self)
    return true
end
function modifier_basic_bat.DeclareFunctions(self)
    return {MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT}
end
function modifier_basic_bat.GetModifierBaseAttackTimeConstant(self)
    return self:GetAbility():GetSpecialValueFor("new_bat")
end
modifier_basic_bat_reduction = modifier_basic_bat_reduction or {}
modifier_basic_bat_reduction.__index = modifier_basic_bat_reduction
function modifier_basic_bat_reduction.new(construct, ...)
    local self = setmetatable({}, modifier_basic_bat_reduction)
    if construct and modifier_basic_bat_reduction.constructor then modifier_basic_bat_reduction.constructor(self, ...) end
    return self
end
function modifier_basic_bat_reduction.constructor(self)
end
function modifier_basic_bat_reduction.IsPermanent(self)
    return true
end
function modifier_basic_bat_reduction.IsHidden(self)
    return true
end
function modifier_basic_bat_reduction.OnCreated(self)
    if IsServer() then
        self:GetParent():AddNewModifier(self:GetParent(),nil,"modifier_bat_manager",{});
    end
end
function modifier_basic_bat_reduction.GetBATReductionConstant(self)
    return -self:GetAbility():GetSpecialValueFor("new_bat")
end
