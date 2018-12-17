
-- Lua Library Imports
LinkLuaModifier("modifier_slardar_bash_redux","abilities/void_time_lock.lua",LUA_MODIFIER_MOTION_NONE);
void_time_lock_redux = void_time_lock_redux or {}
void_time_lock_redux.__index = void_time_lock_redux
function void_time_lock_redux.new(construct, ...)
    local self = setmetatable({}, void_time_lock_redux)
    if construct and void_time_lock_redux.constructor then void_time_lock_redux.constructor(self, ...) end
    return self
end
function void_time_lock_redux.constructor(self)
end
function void_time_lock_redux.IsPassive(self)
    return true
end
function void_time_lock_redux.GetIntrinsicModifierName(self)
    return "modifier_void_time_lock_redux"
end
modifier_void_time_lock_redux = modifier_void_time_lock_redux or {}
modifier_void_time_lock_redux.__index = modifier_void_time_lock_redux
function modifier_void_time_lock_redux.new(construct, ...)
    local self = setmetatable({}, modifier_void_time_lock_redux)
    if construct and modifier_void_time_lock_redux.constructor then modifier_void_time_lock_redux.constructor(self, ...) end
    return self
end
function modifier_void_time_lock_redux.constructor(self)
end
function modifier_void_time_lock_redux.IsPermanent(self)
    return true
end
function modifier_void_time_lock_redux.IsHidden(self)
    return true
end
function modifier_void_time_lock_redux.DeclareFunctions(self)
    return {MODIFIER_EVENT_ON_ATTACK_LANDED}
end
function modifier_void_time_lock_redux.OnAttackLanded(self,params)
    if params.attacker==self:GetParent() then
        local chance = self:GetAbility():GetSpecialValueFor("chance_pct");
        if self:GetParent():IsRangedAttacker() then
            chance = self:GetAbility():GetSpecialValueFor("chance_pct_ranged");
        end
        local bonus_damage = self:GetAbility():GetSpecialValueFor("bonus_damage");
        local talent = self:GetParent():FindAbilityByName("special_bonus_unique_faceless_void_3");
        bonus_damage = (bonus_damage+talent:GetSpecialValueFor("value"));
        if RollPercentage(chance) then
            local dTable = {victim = params.target,attacker = self:GetParent(),damage_type = DAMAGE_TYPE_MAGICAL,damage = bonus_damage};
            ApplyDamage(dTable);
        end
        params.target:AddNewModifier(self:GetCaster(),self:GetAbility(),"modifier_faceless_void_timelock_freeze",{duration = self:GetAbility():GetSpecialValueFor("duration")});
        local second_strike_delay = self:GetAbility():GetSpecialValueFor("second_strike_delay");
        Timers:CreateTimer(second_strike_delay,function()
            self:GetParent():PerformAttack(params.target,true,true,true,true,true,true,true);
        end
);
    end
end
