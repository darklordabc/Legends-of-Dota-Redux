
-- Lua Library Imports
LinkLuaModifier("modifier_slardar_bash_redux","abilities/slardar_bash_redux.lua",LUA_MODIFIER_MOTION_NONE);
LinkLuaModifier("modifier_slardar_bash_counter_redux","abilities/slardar_bash_redux.lua",LUA_MODIFIER_MOTION_NONE);
slardar_bash_redux = slardar_bash_redux or {}
slardar_bash_redux.__index = slardar_bash_redux
function slardar_bash_redux.new(construct, ...)
    local self = setmetatable({}, slardar_bash_redux)
    if construct and slardar_bash_redux.constructor then slardar_bash_redux.constructor(self, ...) end
    return self
end
function slardar_bash_redux.constructor(self)
end
function slardar_bash_redux.IsPassive(self)
    return true
end
function slardar_bash_redux.GetIntrinsicModifierName(self)
    return "modifier_slardar_bash_redux"
end
modifier_slardar_bash_redux = modifier_slardar_bash_redux or {}
modifier_slardar_bash_redux.__index = modifier_slardar_bash_redux
function modifier_slardar_bash_redux.new(construct, ...)
    local self = setmetatable({}, modifier_slardar_bash_redux)
    if construct and modifier_slardar_bash_redux.constructor then modifier_slardar_bash_redux.constructor(self, ...) end
    return self
end
function modifier_slardar_bash_redux.constructor(self)
end
function modifier_slardar_bash_redux.IsPermanent(self)
    return true
end
function modifier_slardar_bash_redux.IsHidden(self)
    return true
end
function modifier_slardar_bash_redux.DeclareFunctions(self)
    return {MODIFIER_EVENT_ON_ATTACK_LANDED,MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_PHYSICAL}
end
function modifier_slardar_bash_redux.OnAttackLanded(self,params)
    if (params.attacker==self:GetParent()) and (not params.target:IsBuilding()) then
        local modifier = params.target:FindModifierByNameAndCaster("modifier_slardar_bash_counter_redux",self:GetParent());
        if modifier then
            modifier:IncrementStackCount();
            if (self:GetParent():IsRangedAttacker() and (modifier:GetStackCount()==self:GetAbility():GetSpecialValueFor("attack_count_ranged"))) or ((not self:GetParent():IsRangedAttacker()) and (modifier:GetStackCount()==self:GetAbility():GetSpecialValueFor("attack_count"))) then
                modifier:SetStackCount(0);
                params.target:AddNewModifier(self:GetParent(),self:GetAbility(),"modifier_slardar_bash",{duration = self:GetAbility():GetSpecialValueFor("duration")});
                EmitSoundOn("Hero_Slardar.Bash",params.target);
            end
        else
            params.target:AddNewModifier(self:GetParent(),self:GetAbility(),"modifier_slardar_bash_counter_redux",{});
        end
    end
end
function modifier_slardar_bash_redux.GetModifierProcAttack_BonusDamage_Physical(self,params)
    if IsClient() then
        return 0
    end
    local modifier = params.target:FindModifierByNameAndCaster("modifier_slardar_bash_counter_redux",self:GetParent());
    if (not modifier) then
        return 0
    end
    if params.attacker==self:GetParent() then
        if (self:GetParent():IsRangedAttacker() and (modifier:GetStackCount()==(self:GetAbility():GetSpecialValueFor("attack_count_ranged")-1))) or ((not self:GetParent():IsRangedAttacker()) and (modifier:GetStackCount()==(self:GetAbility():GetSpecialValueFor("attack_count")-1))) then
            local bonus = self:GetAbility():GetSpecialValueFor("bonus_damage");
            local talent = self:GetParent():FindAbilityByName("special_bonus_unique_slardar_2");
            bonus = (bonus+talent:GetSpecialValueFor("value"));
            return bonus
        end
    end
end
