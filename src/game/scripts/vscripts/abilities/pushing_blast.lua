
-- Lua Library Imports
function __TS__ArrayForEach(arr,callbackFn)
    local i = 0
    while(i<#arr) do
        do
            callbackFn(arr[(i)+1],i,arr);
        end
        i = (i+1)
    end
end

LinkLuaModifier("modifier_pushing_blast_slow","abilities/pushing_blast.lua",LUA_MODIFIER_MOTION_NONE);
pushing_blast = pushing_blast or {}
pushing_blast.__index = pushing_blast
function pushing_blast.new(construct, ...)
    local self = setmetatable({}, pushing_blast)
    if construct and pushing_blast.constructor then pushing_blast.constructor(self, ...) end
    return self
end
function pushing_blast.constructor(self)
end
function pushing_blast.OnSpellStart(self)
    local caster = self:GetCaster();
    local point = caster:GetAbsOrigin();
    local p = ParticleManager:CreateParticle("particles/units/heroes/hero_keeper_of_the_light/keeper_of_the_light_blinding_light_aoe.vpcf",PATTACH_CUSTOMORIGIN,caster);
    ParticleManager:SetParticleControl(p,0,point);
    ParticleManager:SetParticleControl(p,1,point);
    ParticleManager:SetParticleControl(p,2,Vector(self:GetSpecialValueFor("radius"),0,0));
    local units = FindUnitsInRadius(caster:GetTeamNumber(),point,nil,self:GetSpecialValueFor("radius"),DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_BASIC+DOTA_UNIT_TARGET_HERO,DOTA_UNIT_TARGET_FLAG_NONE,FIND_ANY_ORDER,false);
    __TS__ArrayForEach(units, function(unit)
        unit:AddNewModifier(caster,self,"modifier_pushing_blast_slow",{duration = self:GetSpecialValueFor("duration")});
        local dist = (point-unit:GetAbsOrigin()):Length2D();
        local knockback = {should_stun = true,knockback_duration = 0.33,duration = 0.33,knockback_distance = self:GetSpecialValueFor("radius")-dist,knockback_height = 0,center_x = caster:GetAbsOrigin()[1],center_y = caster:GetAbsOrigin()[2],center_z = GetGroundHeight(caster:GetAbsOrigin(),nil)};
        unit:AddNewModifier(caster,self,"modifier_knockback",knockback);
        local dTable = {victim = unit,ability = self,attacker = caster,damage = self:GetSpecialValueFor("damage"),damage_type = DAMAGE_TYPE_MAGICAL};
        ApplyDamage(dTable);
    end
);
end
modifier_pushing_blast_slow = modifier_pushing_blast_slow or {}
modifier_pushing_blast_slow.__index = modifier_pushing_blast_slow
function modifier_pushing_blast_slow.new(construct, ...)
    local self = setmetatable({}, modifier_pushing_blast_slow)
    if construct and modifier_pushing_blast_slow.constructor then modifier_pushing_blast_slow.constructor(self, ...) end
    return self
end
function modifier_pushing_blast_slow.constructor(self)
end
function modifier_pushing_blast_slow.DeclareFunctions(self)
    return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE}
end
function modifier_pushing_blast_slow.GetModifierMoveSpeedBonus_Percentage(self)
    return -self:GetAbility():GetSpecialValueFor("ms_slow")
end
function modifier_pushing_blast_slow.GetModifierTotalDamageOutgoing_Percentage(self)
    if IsServer() then
        local caster = self:GetCaster();
        local talent = caster:FindAbilityByName("special_bonus_unique_pushing_blast_0");
        if talent and (talent:GetLevel()>0) then
            return talent:GetSpecialValueFor("value")
        end
    end
    return 0
end
