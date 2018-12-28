
-- Lua Library Imports
LinkLuaModifier("modifier_void_time_lock_redux","abilities/void_time_lock_redux.lua",LUA_MODIFIER_MOTION_NONE);
faceless_void_time_lock_redux = faceless_void_time_lock_redux or {}
faceless_void_time_lock_redux.__index = faceless_void_time_lock_redux
function faceless_void_time_lock_redux.new(construct, ...)
    local self = setmetatable({}, faceless_void_time_lock_redux)
    if construct and faceless_void_time_lock_redux.constructor then faceless_void_time_lock_redux.constructor(self, ...) end
    return self
end
function faceless_void_time_lock_redux.constructor(self)
end
function faceless_void_time_lock_redux.IsPassive(self)
    return true
end
function faceless_void_time_lock_redux.GetIntrinsicModifierName(self)
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
    if (params.attacker==self:GetParent()) and (not params.target:IsBuilding()) then
        local chance = self:GetAbility():GetSpecialValueFor("chance_pct");
        if self:GetParent():IsRangedAttacker() then
            chance = self:GetAbility():GetSpecialValueFor("chance_pct_ranged");
        end
        print(chance);
        local bonus_damage = self:GetAbility():GetSpecialValueFor("bonus_damage");
        local talent = self:GetParent():FindAbilityByName("special_bonus_unique_faceless_void_3");
        bonus_damage = (bonus_damage+talent:GetSpecialValueFor("value"));
        if RollPercentage(chance) then
            local dTable = {victim = params.target,attacker = self:GetParent(),damage_type = DAMAGE_TYPE_MAGICAL,damage = bonus_damage};
            ApplyDamage(dTable);
            params.target:AddNewModifier(self:GetCaster(),self:GetAbility(),"modifier_faceless_void_timelock_freeze",{duration = self:GetAbility():GetSpecialValueFor("duration")});
            local second_strike_delay = self:GetAbility():GetSpecialValueFor("second_strike_delay");
            Timers:CreateTimer(second_strike_delay,function()
                self:GetParent():PerformAttack(params.target,true,true,true,true,true,true,true);
            end
);
            local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_faceless_void/faceless_void_backtrack02.vpcf",PATTACH_ABSORIGIN,self:GetParent());
            ParticleManager:ReleaseParticleIndex(particle);
            self:GetParent():EmitSound("Hero_FacelessVoid.TimeLockImpact");
        end
    end
end
