
-- Lua Library Imports
LinkLuaModifier("modifier_pangolier_luckyshot_redux_passive","abilities/pangolier_lucky_shot_redux.lua",LUA_MODIFIER_MOTION_NONE);
pangolier_lucky_shot_redux = pangolier_lucky_shot_redux or {}
pangolier_lucky_shot_redux.__index = pangolier_lucky_shot_redux
function pangolier_lucky_shot_redux.new(construct, ...)
    local self = setmetatable({}, pangolier_lucky_shot_redux)
    if construct and pangolier_lucky_shot_redux.constructor then pangolier_lucky_shot_redux.constructor(self, ...) end
    return self
end
function pangolier_lucky_shot_redux.constructor(self)
end
function pangolier_lucky_shot_redux.GetIntrinsicModifierName(self)
    return "modifier_pangolier_luckyshot_redux_passive"
end
modifier_pangolier_luckyshot_redux_passive = modifier_pangolier_luckyshot_redux_passive or {}
modifier_pangolier_luckyshot_redux_passive.__index = modifier_pangolier_luckyshot_redux_passive
function modifier_pangolier_luckyshot_redux_passive.new(construct, ...)
    local self = setmetatable({}, modifier_pangolier_luckyshot_redux_passive)
    if construct and modifier_pangolier_luckyshot_redux_passive.constructor then modifier_pangolier_luckyshot_redux_passive.constructor(self, ...) end
    return self
end
function modifier_pangolier_luckyshot_redux_passive.constructor(self)
end
function modifier_pangolier_luckyshot_redux_passive.IsPermanent(self)
    return true
end
function modifier_pangolier_luckyshot_redux_passive.IsHidden(self)
    return true
end
function modifier_pangolier_luckyshot_redux_passive.DeclareFunctions(self)
    return {MODIFIER_EVENT_ON_ATTACK_LANDED}
end
function modifier_pangolier_luckyshot_redux_passive.OnAttackLanded(self,params)
    if params.attacker==self:GetParent() then
        local chance = self:GetAbility():GetSpecialValueFor("chance_pct");
        if self:GetParent():IsRangedAttacker() then
            chance = self:GetAbility():GetSpecialValueFor("chance_pct_ranged");
        end
        if RollPercentage(chance) then
            if RollPercentage(50) then
                params.target:AddNewModifier(params.attacker,self:GetAbility(),"modifier_pangolier_luckyshot_disarm",{duration = self:GetAbility():GetSpecialValueFor("duration")});
            else
                params.target:AddNewModifier(params.attacker,self:GetAbility(),"modifier_pangolier_luckyshot_silence",{duration = self:GetAbility():GetSpecialValueFor("duration")});
            end
            local p = ParticleManager:CreateParticle("particles/units/heroes/hero_pangolier/pangolier_luckyshot_disarm_cast.vpcf",PATTACH_ABSORIGIN_FOLLOW,params.attacker);
            ParticleManager:SetParticleControlEnt(p,1,params.target,PATTACH_ABSORIGIN_FOLLOW,"follow_hitloc",params.target:GetAbsOrigin(),false);
            ParticleManager:ReleaseParticleIndex(p);
            params.attacker:EmitSound("Hero_Pangolier.LuckyShot.Proc");
        end
    end
end
