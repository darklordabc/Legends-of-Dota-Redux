
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

LinkLuaModifier("modifier_crater_spell_manager","abilities/crater.lua",LUA_MODIFIER_MOTION_NONE);
LinkLuaModifier("modifier_crater_projectile","abilities/crater.lua",LUA_MODIFIER_MOTION_NONE);
LinkLuaModifier("modifier_crater_area_controller","abilities/crater.lua",LUA_MODIFIER_MOTION_NONE);
LinkLuaModifier("modifier_crater_area_control","abilities/crater.lua",LUA_MODIFIER_MOTION_NONE);
crater = crater or {}
crater.__index = crater
function crater.new(construct, ...)
    local self = setmetatable({}, crater)
    if construct and crater.constructor then crater.constructor(self, ...) end
    return self
end
function crater.constructor(self)
end
function crater.GetAbilityTexture(self)
    local caster = self:GetCaster();
    if caster:GetModifierStackCount(self:GetIntrinsicModifierName(),caster)==0 then
        return "invoker_sun_strike"
    else
        return "techies_focused_detonate"
    end
end
function crater.GetManaCost(self,i)
    local caster = self:GetCaster();
    local cost = {70,80,90,100};
    if caster:GetModifierStackCount(self:GetIntrinsicModifierName(),caster)==0 then
        return cost[(i)+1]
    else
        return 0
    end
end
function crater.GetCooldown(self,i)
    local caster = self:GetCaster();
    if IsClient() then
        return 30
    end
    if caster:GetModifierStackCount(self:GetIntrinsicModifierName(),caster)==0 then
        return 0.5
    else
        return 30
    end
end
function crater.GetCastPoint(self)
    local caster = self:GetCaster();
    if caster:GetModifierStackCount(self:GetIntrinsicModifierName(),caster)==0 then
        return 0.3
    else
        return 0
    end
end
function crater.GetIntrinsicModifierName(self)
    return "modifier_crater_spell_manager"
end
function crater.OnSpellStart(self)
    local caster = self:GetCaster();
    local origin = caster:GetAbsOrigin();
    if caster:GetModifierStackCount(self:GetIntrinsicModifierName(),caster)==0 then
        local direction = (caster:GetCursorPosition()-origin):Normalized();
        direction.z = 0;
        local projectileTable = {Ability = self,EffectName = "",vSpawnOrigin = origin,fDistance = 10000,fStartRadius = self:GetSpecialValueFor("crater_radius"),fEndRadius = self:GetSpecialValueFor("crater_radius"),Source = caster,vVelocity = direction*(self:GetSpecialValueFor("marker_speed"))};
        self.projectileParticle = ParticleManager:CreateParticleForTeam("particles/crater_marker.vpcf",PATTACH_CUSTOMORIGIN,caster,caster:GetTeamNumber());
        ParticleManager:SetParticleControl(self.projectileParticle,0,caster:GetAbsOrigin()+direction);
        ParticleManager:SetParticleControl(self.projectileParticle,1,direction*self:GetSpecialValueFor("marker_speed"));
        caster:EmitSound("Hero_Ancient_Apparition.IceBlastRelease.Cast");
        caster:SetModifierStackCount(self:GetIntrinsicModifierName(),caster,1);
        self.time = GameRules:GetGameTime();
        self.launchDirection = direction;
        self.launchLocation = origin;
        self:EndCooldown();
        self:StartCooldown(0.25);
    else
        local time = GameRules:GetGameTime()-self.time;
        local origin = self.launchLocation+(self.launchDirection*(self:GetSpecialValueFor("marker_speed")*time));
        self.dummy = CreateUnitByName("npc_dota_thinker",origin,true,caster,caster:GetPlayerOwner(),caster:GetTeamNumber());
        self:OnDestroyProjectile(origin,self.dummy);
        caster:SetModifierStackCount(self:GetIntrinsicModifierName(),caster,0);
        Timers:CreateTimer(0.5,function()
            if self.dummy and IsValidEntity(self.dummy) then
                AddFOWViewer(caster:GetTeamNumber(),origin,self:GetSpecialValueFor("crater_radius"),0.5,true);
                return 0.5
            end
        end
);
    end
end
function crater.OnDestroyProjectile(self,origin,target)
    local caster = self:GetCaster();
    self:CreateVisibilityNode(origin,self:GetSpecialValueFor("crater_radius"),self:GetSpecialValueFor("crater_duration"));
    local pTable = {Target = self.dummy,Source = caster,Ability = self,EffectName = "particles/units/heroes/hero_ogre_magi/ogre_magi_ignite.vpcf",iMoveSpeed = self:GetSpecialValueFor("projectile_speed")};
    caster:EmitSound("Ability.Ghostship.bell");
    ParticleManager:DestroyParticle(self.projectileParticle,true);
    ParticleManager:ReleaseParticleIndex(self.projectileParticle);
    self.projectileParticle = ParticleManager:CreateParticleForTeam("particles/crater_marker.vpcf",PATTACH_CUSTOMORIGIN,caster,caster:GetTeamNumber());
    ParticleManager:SetParticleControl(self.projectileParticle,0,origin);
    ParticleManager:SetParticleControl(self.projectileParticle,1,Vector(0,0,0));
    self.partic = ParticleManager:CreateParticle("particles/units/heroes/hero_ogre_magi/ogre_magi_ignite.vpcf",PATTACH_CUSTOMORIGIN,caster);
    ParticleManager:SetParticleControl(self.partic,0,caster:GetAbsOrigin());
    ParticleManager:SetParticleControlEnt(self.partic,1,self.dummy,PATTACH_POINT_FOLLOW,"attach_hitloc",self.dummy:GetAbsOrigin(),true);
    ParticleManager:SetParticleControl(self.partic,2,Vector(self:GetSpecialValueFor("projectile_speed"),0));
    ProjectileManager:CreateTrackingProjectile(pTable);
    return false
end
function crater.OnProjectileHit(self,target,location)
    if (not target) then
        local caster = self:GetCaster();
        caster:SetModifierStackCount(self:GetIntrinsicModifierName(),caster,1);
        return false
    else
        self:CreateCrater(location);
        self.dummy:EmitSound("Hero_Invoker.SunStrike.Ignite");
        UTIL_Remove(self.dummy);
        self.dummy = nil;
        ParticleManager:DestroyParticle(self.partic,true);
        ParticleManager:ReleaseParticleIndex(self.partic);
        ParticleManager:DestroyParticle(self.projectileParticle,true);
        ParticleManager:ReleaseParticleIndex(self.projectileParticle);
    end
end
function crater.CreateCrater(self,origin)
    local caster = self:GetCaster();
    self:CreateVisibilityNode(origin,self:GetSpecialValueFor("crater_radius"),self:GetSpecialValueFor("crater_duration"));
    local dummy = CreateModifierThinker(self:GetCaster(),self,"modifier_crater_area_controller",{duration = self:GetSpecialValueFor("crater_duration")},origin+Vector(0,0,50),caster:GetTeamNumber(),false);
    GridNav:DestroyTreesAroundPoint(origin,self:GetSpecialValueFor("crater_radius"),false);
    local damageTable = {ability = self,victim = caster,attacker = caster,damage = self:GetSpecialValueFor("crater_damage"),damage_type = DAMAGE_TYPE_MAGICAL};
    local units = FindUnitsInRadius(caster:GetTeamNumber(),origin,nil,self:GetSpecialValueFor("crater_radius"),DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC,DOTA_UNIT_TARGET_FLAG_NONE,FIND_ANY_ORDER,false);
    __TS__ArrayForEach(units, function(unit)
        damageTable.victim = unit;
        ApplyDamage(damageTable);
        unit:AddNewModifier(caster,self,"modifier_stun",{duration = FrameTime()});
    end
);
    local talent = caster:FindAbilityByName("special_bonus_unique_crater_0");
    if talent and (talent:GetLevel()==1) then
        local units = FindUnitsInRadius(caster:GetTeamNumber(),origin,nil,talent:GetSpecialValueFor("value"),DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC,DOTA_UNIT_TARGET_FLAG_NONE,FIND_ANY_ORDER,false);
        __TS__ArrayForEach(units, function(unit)
            local dist = (unit:GetAbsOrigin()-origin):Length2D();
            if dist>(self:GetSpecialValueFor("crater_radius")-50) then
                local knockbackTable = {should_stun = false,knockback_duration = 0.33,duration = 0.33,knockback_distance = -dist,knockback_height = 0,center_x = origin.x,center_y = origin.y,center_z = GetGroundHeight(origin,nil)};
                unit:AddNewModifier(caster,self,"modifier_knockback",knockbackTable);
            end
        end
);
    end
end
modifier_crater_projectile = modifier_crater_projectile or {}
modifier_crater_projectile.__index = modifier_crater_projectile
function modifier_crater_projectile.new(construct, ...)
    local self = setmetatable({}, modifier_crater_projectile)
    if construct and modifier_crater_projectile.constructor then modifier_crater_projectile.constructor(self, ...) end
    return self
end
function modifier_crater_projectile.constructor(self)
end
function modifier_crater_projectile.OnCreated(self)
    if IsClient() then
        return
    end
    local projectile = self:GetParent();
    local ability = self:GetAbility();
    self.speed = (ability:GetSpecialValueFor("projectile_speed")*FrameTime());
    self.radius = ability:GetSpecialValueFor("crater_radius");
    self:StartIntervalThink(FrameTime());
    self.particle = ParticleManager:CreateParticle("particles/crater_marker.vpcf",PATTACH_ABSORIGIN,self:GetCaster());
    ParticleManager:SetParticleControl(self.particle,4,Vector(self.radius,0,0));
end
function modifier_crater_projectile.OnIntervalThink(self)
    local projectile = self:GetParent();
    projectile:SetAbsOrigin(projectile:GetAbsOrigin()+(self.direction*self.speed));
end
function modifier_crater_projectile.OnDestroy(self)
    if IsClient() then
        return
    end
    local projectile = self:GetParent();
    local ability = self:GetAbility();
    local origin = projectile:GetAbsOrigin();
    ability:CreateVisibilityNode(origin,self.radius,ability:GetSpecialValueFor("vision_duration"));
    local dummy = CreateModifierThinker(self:GetCaster(),ability,"modifier_crater_area_controller",{duration = ability:GetSpecialValueFor("crater_duration")},origin+Vector(0,0,50),self:GetCaster():GetTeamNumber(),false);
    self:GetParent():Destroy();
end
function modifier_crater_projectile.GetEffectName(self)
    return "particles/crater_marker.vpcf"
end
function modifier_crater_projectile.GetEffectAttachType(self)
    return PATTACH_ABSORIGIN_FOLLOW
end
modifier_crater_area_controller = modifier_crater_area_controller or {}
modifier_crater_area_controller.__index = modifier_crater_area_controller
function modifier_crater_area_controller.new(construct, ...)
    local self = setmetatable({}, modifier_crater_area_controller)
    if construct and modifier_crater_area_controller.constructor then modifier_crater_area_controller.constructor(self, ...) end
    return self
end
function modifier_crater_area_controller.constructor(self)
end
function modifier_crater_area_controller.OnCreated(self)
    if IsServer() then
        self.particle2 = ParticleManager:CreateParticle("particles/crater_strike.vpcf",PATTACH_ABSORIGIN_FOLLOW,self:GetParent());
        self.particle = ParticleManager:CreateParticle("particles/crater_area.vpcf",PATTACH_ABSORIGIN,self:GetCaster());
        ParticleManager:SetParticleControl(self.particle,0,self:GetParent():GetAbsOrigin());
        ParticleManager:SetParticleControl(self.particle,3,self:GetParent():GetAbsOrigin());
        self:StartIntervalThink(FrameTime());
    end
end
function modifier_crater_area_controller.OnIntervalThink(self)
    local units = FindUnitsInRadius(self:GetCaster():GetTeamNumber(),self:GetParent():GetAbsOrigin(),nil,self:GetAbility():GetSpecialValueFor("crater_radius"),DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_BASIC+DOTA_UNIT_TARGET_HERO,DOTA_UNIT_TARGET_FLAG_NONE,FIND_ANY_ORDER,false);
    __TS__ArrayForEach(units, function(unit)
        local origin = self:GetParent():GetAbsOrigin();
        unit:AddNewModifier(self:GetCaster(),self:GetAbility(),"modifier_crater_area_control",{duration = 0.1,x = origin.x,y = origin.y,z = origin.z});
    end
);
end
function modifier_crater_area_controller.OnDestroy(self)
    if IsServer() then
        ParticleManager:DestroyParticle(self.particle,true);
        ParticleManager:ReleaseParticleIndex(self.particle);
        ParticleManager:DestroyParticle(self.particle2,true);
        ParticleManager:ReleaseParticleIndex(self.particle2);
    end
end
modifier_crater_area_control = modifier_crater_area_control or {}
modifier_crater_area_control.__index = modifier_crater_area_control
function modifier_crater_area_control.new(construct, ...)
    local self = setmetatable({}, modifier_crater_area_control)
    if construct and modifier_crater_area_control.constructor then modifier_crater_area_control.constructor(self, ...) end
    return self
end
function modifier_crater_area_control.constructor(self)
end
function modifier_crater_area_control.OnCreated(self,kv)
    if IsClient() then
        return
    end
    self.position = Vector(kv.x,kv.y,kv.z);
    self:StartIntervalThink(FrameTime());
end
function modifier_crater_area_control.OnIntervalThink(self)
    local unit = self:GetParent();
    local break_range = self:GetAbility():GetSpecialValueFor("crater_radius")-150;
    if (unit:GetAbsOrigin()-self.position):Length2D()>break_range then
        local direction = unit:GetAbsOrigin()-self.position;
        direction = direction:Normalized();
        local dot = direction:Dot(unit:GetForwardVector());
        if dot>0 then
            self:SetStackCount(1);
            return
        end
    end
    self:SetStackCount(0);
    AddFOWViewer(unit:GetTeamNumber(),self.position,break_range,FrameTime()*2,false);
end
function modifier_crater_area_control.DeclareFunctions(self)
    return {MODIFIER_PROPERTY_MOVESPEED_LIMIT,MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE,MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,MODIFIER_PROPERTY_FIXED_NIGHT_VISION,MODIFIER_PROPERTY_FIXED_DAY_VISION}
end
function modifier_crater_area_control.GetFixedDayVision(self)
    return 50
end
function modifier_crater_area_control.GetFixedNightVision(self)
    return 50
end
function modifier_crater_area_control.GetModifierMoveSpeed_Limit(self)
    if self:GetStackCount()==1 then
        return 0.01
    end
end
function modifier_crater_area_control.GetModifierMoveSpeedBonus_Constant(self)
    if self:GetStackCount()==1 then
        return -1000
    end
end
function modifier_crater_area_control.GetModifierMoveSpeed_Absolute(self)
    if self:GetStackCount()==1 then
        return 0
    end
end
modifier_crater_spell_manager = modifier_crater_spell_manager or {}
modifier_crater_spell_manager.__index = modifier_crater_spell_manager
function modifier_crater_spell_manager.new(construct, ...)
    local self = setmetatable({}, modifier_crater_spell_manager)
    if construct and modifier_crater_spell_manager.constructor then modifier_crater_spell_manager.constructor(self, ...) end
    return self
end
function modifier_crater_spell_manager.constructor(self)
end
function modifier_crater_spell_manager.IsHidden(self)
    return true
end
