
-- Lua Library Imports
function __TS__ArrayIndexOf(arr,searchElement,fromIndex)
    local len = #arr;
    if len==0 then
        return -1
    end
    local n = 0;
    if fromIndex then
        n = fromIndex;
    end
    if n>=len then
        return -1
    end
    local k = nil;
    if n>=0 then
        k = n;
    else
        k = (len+n);
        if k<0 then
            k = 0;
        end
    end
    local i = k
    while(i<len) do
        do
            if arr[(i)+1]==searchElement then
                return i
            end
        end
        i = (i+1)
    end
    return -1
end

function __TS__ArrayPush(arr,...)
    local items = { ... }
    for _, item in ipairs(items) do
        do
            arr[(#arr)+1] = item;
        end
    end
    return #arr
end

ranged_punch = ranged_punch or {}
ranged_punch.__index = ranged_punch
function ranged_punch.new(construct, ...)
    local self = setmetatable({}, ranged_punch)
    if construct and ranged_punch.constructor then ranged_punch.constructor(self, ...) end
    return self
end
function ranged_punch.constructor(self)
end
function ranged_punch.OnSpellStart(self)
    local caster = self:GetCaster();
    local origin = caster:GetAbsOrigin();
    local point = self:GetCursorPosition();
    local direction = (point-origin):Normalized();
    direction[3] = 0;
    self.direction = direction;
    self.targets = {};
    self.range = 1000;
    self.returning = false;
    local projectileTable = {Ability = self,EffectName = "",vSpawnOrigin = origin,fDistance = self.range,fStartRadius = 100,fEndRadius = 100,Source = caster,vVelocity = direction*self:GetSpecialValueFor("projectile_speed"),iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_BOTH,iUnitTargetType = DOTA_UNIT_TARGET_BASIC+DOTA_UNIT_TARGET_HERO};
    self.projectile = ProjectileManager:CreateLinearProjectile(projectileTable);
    self.end_position = (caster:GetAbsOrigin()+(direction*self.range));
    self.particle = ParticleManager:CreateParticle("particles/abilities/punch/ranged_punch.vpcf",PATTACH_CUSTOMORIGIN,nil);
    ParticleManager:SetParticleAlwaysSimulate(self.particle);
    ParticleManager:SetParticleControlEnt(self.particle,0,caster,PATTACH_POINT_FOLLOW,"attach_weapon_chain_rt",origin,true);
    ParticleManager:SetParticleControl(self.particle,1,self.end_position);
    ParticleManager:SetParticleControl(self.particle,2,Vector(self:GetSpecialValueFor("projectile_speed"),0,0));
    ParticleManager:SetParticleControl(self.particle,3,Vector(5,0,0));
    ParticleManager:SetParticleControl(self.particle,4,Vector(1,0,0));
    ParticleManager:SetParticleControl(self.particle,5,Vector(0,0,0));
    ParticleManager:SetParticleControlEnt(self.particle,7,caster,PATTACH_CUSTOMORIGIN,nil,origin,true);
end
function ranged_punch.OnProjectileHit(self,target,location)
    local caster = self:GetCaster();
    if (not target) and (not self.returning) then
        local origin = caster:GetAbsOrigin();
        local point = self:GetCursorPosition();
        local direction = (origin-location):Normalized();
        direction[3] = 0;
        self.direction = direction;
        self.returning = true;
        local projectileTable = {Ability = self,EffectName = "",vSpawnOrigin = location,fDistance = (origin-location):Length2D(),fStartRadius = 100,fEndRadius = 100,Source = caster,vVelocity = direction*self:GetSpecialValueFor("projectile_speed"),iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_BOTH,iUnitTargetType = DOTA_UNIT_TARGET_BASIC+DOTA_UNIT_TARGET_HERO};
        self.projectile = ProjectileManager:CreateLinearProjectile(projectileTable);
        ParticleManager:SetParticleControlEnt(self.particle,1,self:GetCaster(),PATTACH_POINT_FOLLOW,"attach_weapon_chain_rt",self:GetCaster():GetAbsOrigin(),true);
    else
        if (not target) then
            ParticleManager:DestroyParticle(self.particle,true);
            ParticleManager:ReleaseParticleIndex(self.particle);
        else
            if __TS__ArrayIndexOf(self.targets, target)==-1 then
                local normal = (target:GetAbsOrigin()-location):Normalized();
                local dot = normal:Dot(self.direction);
                __TS__ArrayPush(self.targets, target);
                if dot>0 then
                    local knockbackDistance = self:GetSpecialValueFor("knockback_distance");
                    if target:GetTeamNumber()~=caster:GetTeamNumber() then
                        local damageTable = {ability = self,victim = target,attacker = caster,damage = self:GetSpecialValueFor("punch_damage"),damage_type = DAMAGE_TYPE_MAGICAL};
                        ApplyDamage(damageTable);
                        local talent = caster:FindAbilityByName("special_bonus_unique_ranged_punch_0");
                        if talent and (talent:GetLevel()>0) then
                            knockbackDistance = (knockbackDistance*talent:GetSpecialValueFor("value"));
                        end
                    end
                    local knockbackTable = {should_stun = false,knockback_duration = 0.5,duration = 0.5,knockback_distance = 400,knockback_height = 0,center_x = location.x,center_y = location.y,center_z = GetGroundHeight(location,nil)};
                    target:AddNewModifier(caster,self,"modifier_knockback",knockbackTable);
                end
            end
        end
    end
    return false
end
