
-- Lua Library Imports
function __TS__Ternary(condition,cb1,cb2)
    if condition then
        return cb1()
    else
        return cb2()
    end
end

modifier_flying_with_slow = modifier_flying_with_slow or {}
modifier_flying_with_slow.__index = modifier_flying_with_slow
function modifier_flying_with_slow.new(construct, ...)
    local self = setmetatable({}, modifier_flying_with_slow)
    if construct and modifier_flying_with_slow.constructor then modifier_flying_with_slow.constructor(self, ...) end
    return self
end
function modifier_flying_with_slow.constructor(self)
end
function modifier_flying_with_slow.IsPermanent(self)
    return true
end
function modifier_flying_with_slow.CheckState(self)
    return {[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = (not (self:GetAbility() and self:GetParent():PassivesDisabled()))}
end
function modifier_flying_with_slow.DeclareFunctions(self)
    return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,MODIFIER_PROPERTY_VISUAL_Z_DELTA}
end
function modifier_flying_with_slow.OnCreated(self)
    if IsServer() then
        self:SetStackCount(0);
        self:StartIntervalThink(FrameTime());
    else
        self.z = 0;
    end
end
function modifier_flying_with_slow.OnIntervalThink(self)
    local unit = self:GetParent();
    if GridNav:IsBlocked(unit:GetAbsOrigin()) then
        self:SetStackCount(0);
    else
        self:SetStackCount(1);
    end
end
function modifier_flying_with_slow.GetModifierMoveSpeedBonus_Percentage(self)
    local unit = self:GetParent();
    if (not self:GetAbility()) and unit:PassivesDisabled() then
        return 0
    end
    if self:GetStackCount()==0 then
        local ms = __TS__Ternary(self:GetAbility(), function() return -self:GetAbility():GetSpecialValueFor("flying_movespeed_slow_pct") end, function() return -50 end);
        return ms
    end
    return 0
end
function modifier_flying_with_slow.GetVisualZDelta(self)
    local unit = self:GetParent();
    if (not self:GetAbility()) and unit:PassivesDisabled() then
        self.z = (self.z-15);
        return self.z
    end
    if self:GetStackCount()==0 then
        self.z = math.min(250,self.z+15);
        return self.z
    end
    self.z = math.max(0,self.z-15);
    return self.z
end
