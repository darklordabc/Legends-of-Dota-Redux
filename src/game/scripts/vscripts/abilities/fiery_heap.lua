
-- Lua Library Imports
LinkLuaModifier("modifier_flesh_heap_fiery_soul","abilities/fiery_heap.lua",LUA_MODIFIER_MOTION_NONE);
pudge_flesh_heap_fiery_soul = pudge_flesh_heap_fiery_soul or {}
pudge_flesh_heap_fiery_soul.__index = pudge_flesh_heap_fiery_soul
function pudge_flesh_heap_fiery_soul.new(construct, ...)
    local self = setmetatable({}, pudge_flesh_heap_fiery_soul)
    if construct and pudge_flesh_heap_fiery_soul.constructor then pudge_flesh_heap_fiery_soul.constructor(self, ...) end
    return self
end
function pudge_flesh_heap_fiery_soul.constructor(self)
end
function pudge_flesh_heap_fiery_soul.GetIntrinsicModifierName(self)
    return "modifier_flesh_heap_fiery_soul"
end
modifier_flesh_heap_fiery_soul = modifier_flesh_heap_fiery_soul or {}
modifier_flesh_heap_fiery_soul.__index = modifier_flesh_heap_fiery_soul
function modifier_flesh_heap_fiery_soul.new(construct, ...)
    local self = setmetatable({}, modifier_flesh_heap_fiery_soul)
    if construct and modifier_flesh_heap_fiery_soul.constructor then modifier_flesh_heap_fiery_soul.constructor(self, ...) end
    return self
end
function modifier_flesh_heap_fiery_soul.constructor(self)
end
function modifier_flesh_heap_fiery_soul.IsHidden(self)
    return self:GetStackCount()==0
end
function modifier_flesh_heap_fiery_soul.IsDebuff(self)
    return false
end
function modifier_flesh_heap_fiery_soul.IsPermanent(self)
    return true
end
function modifier_flesh_heap_fiery_soul.DeclareFunctions(self)
    return {MODIFIER_EVENT_ON_DEATH,MODIFIER_EVENT_ON_TAKEDAMAGE,MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,MODIFIER_PROPERTY_HEALTH_BONUS,MODIFIER_PROPERTY_CAST_RANGE_BONUS_STACKING,MODIFIER_PROPERTY_MODEL_SCALE}
end
function modifier_flesh_heap_fiery_soul.OnDeath(self,params)
    local unit = params.unit;
    if (params.attacker==self:GetParent()) and unit:IsRealHero() then
        self:IncrementStackCount();
        local nFXIndex = ParticleManager:CreateParticle("particles/units/heroes/hero_pudge/pudge_fleshheap_count.vpcf",PATTACH_OVERHEAD_FOLLOW,self:GetCaster());
        ParticleManager:SetParticleControl(nFXIndex,1,Vector(1,0,0));
        ParticleManager:ReleaseParticleIndex(nFXIndex);
    else
        if unit==self:GetParent() then
            self:SetStackCount(self:GetStackCount()/2);
        end
    end
end
function modifier_flesh_heap_fiery_soul.OnTakeDamage(self,params)
    if (params.attacker==self:GetParent()) and (params.damage_category==DOTA_DAMAGE_CATEGORY_SPELL) then
        local healPercentage = self:GetAbility():GetSpecialValueFor("spell_lifesteal_bonus")*0.01;
        self:GetParent():Heal((healPercentage*self:GetStackCount())*params.damage,self:GetParent());
    end
end
function modifier_flesh_heap_fiery_soul.GetModifierAttackSpeedBonus_Constant(self)
    local value = self:GetAbility():GetSpecialValueFor("attack_speed_bonus");
    return value*self:GetStackCount()
end
function modifier_flesh_heap_fiery_soul.GetModifierMoveSpeedBonus_Constant(self)
    local value = self:GetAbility():GetSpecialValueFor("move_speed_bonus");
    return value*self:GetStackCount()
end
function modifier_flesh_heap_fiery_soul.GetModifierBonusStats_Intellect(self)
    local value = self:GetAbility():GetSpecialValueFor("int_bonus");
    return value*self:GetStackCount()
end
function modifier_flesh_heap_fiery_soul.GetModifierHealthBonus(self)
    local value = self:GetAbility():GetSpecialValueFor("health_bonus");
    return value*self:GetStackCount()
end
function modifier_flesh_heap_fiery_soul.GetModifierCastRangeBonusStacking(self)
    local value = self:GetAbility():GetSpecialValueFor("cast_range_bonus");
    return value*self:GetStackCount()
end
function modifier_flesh_heap_fiery_soul.GetModifierModelScale(self)
    local value = self:GetAbility():GetSpecialValueFor("model_scale_bonus");
    return value*self:GetStackCount()
end
