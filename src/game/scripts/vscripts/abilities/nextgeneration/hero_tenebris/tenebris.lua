if tenebris == nil then tenebris = class ({}) end
LinkLuaModifier("tenebris_mortal_coil_modifier_buff", "abilities/nextgeneration/hero_tenebris/tenebris.lua", LUA_MODIFIER_MOTION_NONE)
 
function FadeStrike_OnOrbImpact(kv)
    local caster = kv.caster
    local target = kv.target
 
    --Target must be vulnerable
    if target:IsInvulnerable() then
        return
    end
 
    --Damage must be greater than zero
    local damage = kv.damage
    if damage == nil or damage <= 0 then
        return
    end
 
    --Apply bonus damage
    local ability   = kv.ability
    local bonus = caster:GetAttackSpeed() * 100 + 1
    bonus = bonus * ability:GetLevelSpecialValueFor("bonus_damage", ability:GetLevel() - 1) / 100

    local amount = math.floor(bonus)
    caster:PopupNumbers(target, "damage", Vector(153, 0, 204), 2.0, amount, nil, POPUP_SYMBOL_POST_EYE)
    ApplyDamage({victim=target,attacker=caster,damage=bonus,damage_type=ability:GetAbilityDamageType(),damage_flags=DOTA_DAMAGE_FLAG_IGNORES_PHYSICAL_ARMOR+DOTA_DAMAGE_FLAG_BYPASSES_BLOCK+DOTA_DAMAGE_FLAG_NO_DAMAGE_MULTIPLIERS})
    caster:AddNewModifier(caster, ability, "modifier_invisible", {Duration = ability:GetLevelSpecialValueFor("duration_buff", ability:GetLevel() - 1)})
 
--------APPLY MORTAL COIL TO TARGET
 
    kv.damage   = damage+bonus
    kv.unit     = target
    MortalCoil_OnTakeDamage(kv)
 
--------BEGIN EFFIGY
 
    --End if caster does not have Effigy
    if not caster:HasModifier("tenebris_effigy_modifier_buff") then
        return
    end
 
    --Find enemy heroes
    target_team = DOTA_UNIT_TARGET_TEAM_ENEMY
    target_type = DOTA_UNIT_TARGET_HERO
    target_flags    = DOTA_UNIT_TARGET_FLAG_NONE
    local enemies   = FindUnitsInRadius(caster:GetTeamNumber(),Vector(0,0,0),target,100000,target_team,target_type,target_flags,0,false)
 
    --End if no valid targets to check
    if #enemies == 0 then
        return
    end
 
    --Stun enemies with Effigy
    local inactive = false
    for _,enemy in pairs(enemies) do
        if enemy ~= target then
            inactive = false
            local modifiers = enemy:FindAllModifiers()
            for k, v in pairs(modifiers) do
                if v:GetName() == "tenebris_effigy_modifier_debuff" then
                    inactive = true
                end
            end
            if inactive then
                kv.unit = enemy
                MortalCoil_OnTakeDamage(kv)
            end
        end
    end
end
 
function BloodWard_OnCreated(kv)
    local caster    = kv.caster
    local target    = kv.target
    target:SetForwardVector(caster:GetForwardVector())
    target.life = 100.0
    kv.ability.bloodward = target
end
 
function BloodWard_OnTakeDamage(kv)
    local attacker = kv.attacker
    local target = kv.unit
    local ability = kv.ability
 
    if attacker == target then
        return
    end
 
    local damage = 100./ability:GetSpecialValueFor("attacks_to_destroy")
    if not kv.attacker:IsRealHero() then
        damage = damage/ability:GetSpecialValueFor("hero_value")
    end
    target.life = target.life - damage
    if target.life > 0 then
        target:SetHealth(target.life)
    else
        ApplyDamage({victim=target,attacker=attacker,damage=100,damage_type=DAMAGE_TYPE_PURE,damage_flags=DOTA_DAMAGE_FLAG_BYPASSES_INVULNERABILITY+DOTA_DAMAGE_FLAG_HPLOSS+DOTA_DAMAGE_FLAG_NO_DAMAGE_MULTIPLIERS})
    end
end
 
function BloodWard_OnThink(kv)
    local caster    = kv.caster
    local target    = kv.target
    local ability   = kv.ability
 
    --Deal Damage
    local damage = ability:GetSpecialValueFor("dps")/10.0
    ApplyDamage({victim=target,attacker=caster,damage=damage,damage_type=ability:GetAbilityDamageType(),damage_flags=DOTA_DAMAGE_FLAG_BYPASSES_BLOCK+DOTA_DAMAGE_FLAG_HPLOSS})
end
 
function BloodWard_OnAttackLanded(kv)
    local caster    = kv.caster
    local target    = kv.attacker
    local ability   = kv.ability
 
    --Damage is greater than zero
    local damage    = kv.damage
    if damage == nil or damage <= 0 then
        return
    end
 
    --Create SFX
    local bloodward = ability.bloodward
    if not bloodward:IsNull() then 
        local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_dazzle/dazzle_shadow_wave.vpcf",PATTACH_CUSTOMORIGIN_FOLLOW,target)
        ParticleManager:SetParticleControlEnt(particle,0,bloodward,PATTACH_POINT_FOLLOW,"attach_hitloc",bloodward:GetAbsOrigin(),true)
        ParticleManager:SetParticleControlEnt(particle,1,target,PATTACH_POINT_FOLLOW,"attach_hitloc",target:GetAbsOrigin(),true)
     
        bloodward:EmitSound("Visage_Familiar.Attack")
        target:EmitSound("Visage_Familiar.projectileImpact")
     
        --Deal damage
        damage = damage*ability:GetSpecialValueFor("reflect")/100.0
        ApplyDamage({victim=target,attacker=caster,damage=damage,damage_type=ability:GetAbilityDamageType(),damage_flags=DOTA_DAMAGE_FLAG_BYPASSES_BLOCK+DOTA_DAMAGE_FLAG_REFLECTION})
     
        --Lose life if self is not target
        if kv.target ~= ability.bloodward then
            damage = 100.0/ability:GetSpecialValueFor("maximum_reflections")
            if not kv.attacker:IsRealHero() then
                damage = damage/ability:GetSpecialValueFor("hero_value")
            end
            ability.bloodward.life = ability.bloodward.life - damage
            if ability.bloodward.life > 0 then
                ability.bloodward:SetHealth(ability.bloodward.life)
            else
                ApplyDamage({victim=ability.bloodward,attacker=target,damage=100,damage_type=DAMAGE_TYPE_PURE,damage_flags=DOTA_DAMAGE_FLAG_BYPASSES_INVULNERABILITY+DOTA_DAMAGE_FLAG_HPLOSS+DOTA_DAMAGE_FLAG_NO_DAMAGE_MULTIPLIERS})
            end
        end
    end
end
 
function MortalCoil_OnCreated(kv)
    kv.caster:AddNewModifier(kv.caster,kv.ability,"tenebris_mortal_coil_modifier_buff",{})
    MortalCoil_OnIntervalThink(kv)
end
 
function MortalCoil_OnIntervalThink(kv)
    kv.caster:SetModifierStackCount("tenebris_mortal_coil_modifier_buff",kv.caster,kv.caster:GetAgility()*(kv.ability:GetSpecialValueFor("ias")-1)+.5)
end
 
function MortalCoil_OnTakeDamage(kv)
    local caster = kv.caster
    local target = kv.unit
 
    --Target is not magic immune
    if target:IsMagicImmune() then
        return
    end
 
    --Caster has Mortal Coil leveled
    local ability = caster:FindAbilityByName("tenebris_mortal_coil")
    if ability == nil or ability:GetLevel() < 1 then
        return
    end
 
    --Damage is greater than zero
    local damage = kv.damage
    if damage == nil or damage <= 0 then
        return
    end
 
    --Damage is greater than the threshold
    local duration = ability:GetSpecialValueFor("duration_max")*damage/target:GetMaxHealth()
    ability:ApplyDataDrivenModifier(caster,target,"tenebris_mortal_coil_modifier_debuff",{duration=duration})
end
 
function Effigy_OnSpellStart(kv)
    local caster    = kv.caster
    local target    = kv.target
    local ability   = kv.ability

    local duration = ability:GetLevelSpecialValueFor("duration", ability:GetLevel() - 1)
    if caster:HasScepter() then
        duration = ability:GetLevelSpecialValueFor("scepter_duration", ability:GetLevel() - 1)
    end
 
    --Check target spell block and apply effects
    if (not target:TriggerSpellAbsorb(ability)) then
        ability:ApplyDataDrivenModifier(caster,caster,"tenebris_effigy_modifier_buff",{Duration = duration})
        ability:ApplyDataDrivenModifier(caster,target,"tenebris_effigy_modifier_debuff",{Duration = duration})
    end
end
 
function Effigy_OnDealDamage(kv)
    local caster    = kv.caster
    local target    = kv.unit
 
    --Ignore illusions
    if not target:IsRealHero() then
        return
    end
 
    --Damage greater than zero
    damage = kv.damage
    if damage == nil or damage <= 0 then
        return
    end
 
    --Find enemy heroes
    target_team = DOTA_UNIT_TARGET_TEAM_ENEMY
    target_type = DOTA_UNIT_TARGET_HERO
    target_flags    = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
    local enemies   = FindUnitsInRadius(caster:GetTeamNumber(),Vector(0,0,0),target,100000,target_team,target_type,target_flags,0,false)
 
    --End if no valid targets to check
    if #enemies == 0 then
        return
    end
 
    --Damage enemies with Effigy
    for _,enemy in pairs(enemies) do
        if enemy ~= target then
            inactive = false
            local modifiers = enemy:FindAllModifiers()
            for k, v in pairs(modifiers) do
                if v:GetName() == "tenebris_effigy_modifier_debuff" then
                    inactive = true
                end
            end
            if inactive then
                local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_dazzle/dazzle_shadow_wave.vpcf",PATTACH_CUSTOMORIGIN_FOLLOW,target)
                ParticleManager:SetParticleControlEnt(particle, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
                ParticleManager:SetParticleControlEnt(particle, 1, enemy, PATTACH_POINT_FOLLOW, "attach_hitloc", enemy:GetAbsOrigin(), true)
 
                target:EmitSound("Visage_Familiar.Attack")
                enemy:EmitSound("Visage_Familiar.projectileImpact")
 
                ApplyDamage({victim=enemy,attacker=caster,damage=damage,damage_type=DAMAGE_TYPE_PURE,damage_flags=DOTA_DAMAGE_FLAG_HPLOSS+DOTA_DAMAGE_FLAG_NO_DAMAGE_MULTIPLIERS})
                MortalCoil_OnTakeDamage(kv)
            end
        end
    end
end

function Effigy_OnDestroy(kv)
    local caster    = kv.caster
    local target    = kv.unit
    local ability   = kv.ability
 
 
    --Find ALL enemy heroes that coul have Effigy
    local enemies       = HeroList:GetAllHeroes()
 
    --Check if these heroes have Effigy
    local inactive = true
    for _,enemy in pairs(enemies) do
        if enemy:GetTeam() ~= caster:GetTeam() then
            if enemy:HasModifier("tenebris_effigy_modifier_debuff") then
                enemy:RemoveModifierByName("tenebris_effigy_modifier_debuff")
                enemy:RemoveModifierByName("tenebris_effigy_modifier_timer")
            end
        end
    end
end
 
function Effigy_OnDeath(kv)
    local caster    = kv.caster
    local target    = kv.unit
    local ability   = kv.ability
 
--------Remove Effigy from Caster
 
    --Find ALL enemy heroes that coul have Effigy
    local target_radius = ability:GetSpecialValueFor("radius")
    local target_team   = DOTA_UNIT_TARGET_TEAM_ENEMY
    local target_type   = DOTA_UNIT_TARGET_HERO
    local target_flags  = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES+DOTA_UNIT_TARGET_FLAG_INVULNERABLE+DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD


    local enemies       = HeroList:GetAllHeroes()
 
    --Check if these heroes have Effigy
    local inactive = true
    for _,enemy in pairs(enemies) do
        if enemy:GetTeam() ~= caster:GetTeam() then
            local modifiers = enemy:FindAllModifiers()
            for k, v in pairs(modifiers) do
                if v:GetName() == "tenebris_effigy_modifier_debuff" then
                    inactive = false
                end
            end
        end
    end
 
    --If no heroes have Effigy, remove it from caster
    if inactive then
        caster:RemoveModifierByName("tenebris_effigy_modifier_buff")
    end
 
    --------Apply Effigy to a new hero
 
    --Find new target for Effigy
    local target_flags  = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES+DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE
 
    --Find enemies near target
    local enemies = FindUnitsInRadius(caster:GetTeamNumber(),target:GetOrigin(),caster,target_radius,target_team,target_type,target_flags,FIND_CLOSEST,false)
 
    --Add enemies near caster
    for k,v in pairs(
        FindUnitsInRadius(caster:GetTeamNumber(),caster:GetOrigin(),caster,target_radius,target_team,target_type,target_flags,0,false)
    ) do enemies[k] = v end
 
    --Stop if no enemies
    if #enemies == 0 then
        return
    end
 
    --Find closest target
    local target_new    = nil
    local target_range  = 100000
    local enemy         = nil
    local enemy_range   = 1000000
 
    for _,enemy in pairs(enemies) do
        enemy_range=CalcDistanceBetweenEntityOBB(target,enemy)
        if enemy_range<target_range then
            target_new = enemy
            target_range = enemy_range
        end
    end
 
    --Casts Effigy on the new target or stop
    if target_new ~= nil and (not target:TriggerSpellAbsorb(ability)) then
        local duration = ability:GetLevelSpecialValueFor("duration", ability:GetLevel() - 1)
        if caster:HasScepter() then
            duration = ability:GetLevelSpecialValueFor("scepter_duration", ability:GetLevel() - 1)
        end

        local particle = ParticleManager:CreateParticle("particles/econ/items/abaddon/abaddon_alliance/abaddon_death_coil_alliance.vpcf",PATTACH_CUSTOMORIGIN_FOLLOW,target_new)
        ParticleManager:SetParticleControlEnt(particle,0,target,PATTACH_POINT_FOLLOW,"attach_hitloc",target:GetAbsOrigin(),true)
        ParticleManager:SetParticleControlEnt(particle,1,target_new,PATTACH_POINT_FOLLOW,"attach_hitloc",target_new:GetAbsOrigin(),true)
 
        target:EmitSound("Hero_Visage.GraveChill.Cast")
        target_new:EmitSound("Hero_Visage.GraveChill.Target")
 
        ability:ApplyDataDrivenModifier(caster,target_new,"tenebris_effigy_modifier_timer",{Duration = duration})
    end
end

--tenebris_mortal_coil_modifier_buff.lua
if tenebris_mortal_coil_modifier_buff == nil then tenebris_mortal_coil_modifier_buff = class ({}) end
 
function tenebris_mortal_coil_modifier_buff:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
    }
 
    return funcs
end
 
function tenebris_mortal_coil_modifier_buff:GetModifierAttackSpeedBonus_Constant()
    return self:GetStackCount()
end
 
function tenebris_mortal_coil_modifier_buff:IsHidden()
    return true
end
 
