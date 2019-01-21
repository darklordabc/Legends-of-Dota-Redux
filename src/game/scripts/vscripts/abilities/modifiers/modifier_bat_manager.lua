
-- Lua Library Imports
modifier_bat_manager = modifier_bat_manager or {}
modifier_bat_manager.__index = modifier_bat_manager
function modifier_bat_manager.new(construct, ...)
    local self = setmetatable({}, modifier_bat_manager)
    if construct and modifier_bat_manager.constructor then modifier_bat_manager.constructor(self, ...) end
    return self
end
function modifier_bat_manager.constructor(self)
end
function modifier_bat_manager.IsHidden(self)
    return true
end
function modifier_bat_manager.IsPermanent(self)
    return true
end
function modifier_bat_manager.GetPriority(self)
    return MODIFIER_PRIORITY_SUPER_ULTRA
end
function modifier_bat_manager.DeclareFunctions(self)
    return {MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT}
end
function modifier_bat_manager.OnCreated(self)
    if IsServer() then
        self:StartIntervalThink(1);
    end
end
function modifier_bat_manager.OnIntervalThink(self)
    self:SetStackCount(self:GetParent():GetBaseBAT()*100);
end
function modifier_bat_manager.GetModifierBaseAttackTimeConstant(self)
    if IsServer() then
    end
    return self:GetStackCount()/100
end
