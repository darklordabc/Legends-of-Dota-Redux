
-- Lua Library Imports
LinkLuaModifier("modifier_spiritbreaker_greater_bash_redux","abilities/spirit_breaker_greater_bash_redux.lua",LUA_MODIFIER_MOTION_NONE);
spirit_breaker_greater_bash_redux = spirit_breaker_greater_bash_redux or {}
spirit_breaker_greater_bash_redux.__index = spirit_breaker_greater_bash_redux
function spirit_breaker_greater_bash_redux.new(construct, ...)
    local self = setmetatable({}, spirit_breaker_greater_bash_redux)
    if construct and spirit_breaker_greater_bash_redux.constructor then spirit_breaker_greater_bash_redux.constructor(self, ...) end
    return self
end
function spirit_breaker_greater_bash_redux.constructor(self)
end
function spirit_breaker_greater_bash_redux.IsPassive(self)
    return true
end
function spirit_breaker_greater_bash_redux.GetIntrinsicModifierName(self)
    return "modifier_spiritbreaker_greater_bash_redux"
end
modifier_spiritbreaker_greater_bash_redux = modifier_spiritbreaker_greater_bash_redux or {}
modifier_spiritbreaker_greater_bash_redux.__index = modifier_spiritbreaker_greater_bash_redux
function modifier_spiritbreaker_greater_bash_redux.new(construct, ...)
    local self = setmetatable({}, modifier_spiritbreaker_greater_bash_redux)
    if construct and modifier_spiritbreaker_greater_bash_redux.constructor then modifier_spiritbreaker_greater_bash_redux.constructor(self, ...) end
    return self
end
function modifier_spiritbreaker_greater_bash_redux.constructor(self)
end
function modifier_spiritbreaker_greater_bash_redux.IsPermanent(self)
    return true
end
function modifier_spiritbreaker_greater_bash_redux.IsHidden(self)
    return false
end
function modifier_spiritbreaker_greater_bash_redux.DeclareFunctions(self)
    return {MODIFIER_EVENT_ON_ATTACK_LANDED}
end
function modifier_spiritbreaker_greater_bash_redux.OnAttackLanded(self,params)
    if (params.attacker==self:GetParent()) and (not params.target:IsBuilding()) then
        local chance = self:GetAbility():GetSpecialValueFor("chance_pct");
        if self:GetParent():IsRangedAttacker() then
            chance = self:GetAbility():GetSpecialValueFor("chance_pct_ranged");
            local talent = self:GetParent():FindAbilityByName("special_bonus_unique_spirit_breaker_1");
            if talent then
                chance = (chance+(talent:GetSpecialValueFor("value")/2));
            end
        else
            local talent = self:GetParent():FindAbilityByName("special_bonus_unique_spirit_breaker_1");
            if talent then
                chance = (chance+talent:GetSpecialValueFor("value"));
            end
        end
        local damage = self:GetAbility():GetSpecialValueFor("damage");
        local talent = self:GetParent():FindAbilityByName("special_bonus_unique_spirit_breaker_3");
        if talent then
            damage = (damage+talent:GetSpecialValueFor("value"));
        end
        if RollPercentage(chance) then
            local dTable = {victim = params.target,attacker = self:GetParent(),damage_type = DAMAGE_TYPE_MAGICAL,damage = (self:GetParent():GetIdealSpeed()*damage)*0.01};
            ApplyDamage(dTable);
            local v = self:GetParent():GetAbsOrigin();
            local knockbackTable = {should_stun = true,knockback_duration = self:GetAbility():GetSpecialValueFor("knockback_duration"),duration = self:GetAbility():GetSpecialValueFor("duration"),knockback_distance = self:GetAbility():GetSpecialValueFor("knockback_distance"),knockback_height = 0,center_x = v.x,center_y = v.y,center_z = GetGroundHeight(v,nil)};
            params.target:AddNewModifier(self:GetCaster(),self:GetAbility(),"modifier_knockback",knockbackTable);
            local second_strike_delay = self:GetAbility():GetSpecialValueFor("second_strike_delay");
            Timers:CreateTimer(second_strike_delay,function()
                self:GetParent():PerformAttack(params.target,true,true,true,true,true,true,true);
            end
);
            local p = ParticleManager:CreateParticle("particles/units/heroes/hero_spirit_breaker/spirit_breaker_greater_bash.vpcf",PATTACH_ABSORIGIN_FOLLOW,params.target);
            ParticleManager:SetParticleControl(p,0,params.target:GetAbsOrigin());
            ParticleManager:ReleaseParticleIndex(p);
            self:GetParent():EmitSound("Hero_Spirit_Breaker.GreaterBash");
            self:GetParent():AddNewModifier(self:GetParent(),self:GetAbility(),"modifier_spirit_breaker_greater_bash_speed",{duration = self:GetAbility():GetSpecialValueFor("movespeed_duration")});
        end
    end
end
