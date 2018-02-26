require('lib/physics')
require('lib/util_dusk')
require('lib/timers')

function hawkeye_double_tap(event)
  local caster = event.caster
  local caster_pos = caster:GetAbsOrigin()
  local distance = 6000
  local target = caster:GetCursorPosition()
  local direction = (target - caster_pos):Normalized()
  local speed = 3500
  -- if caster:HasScepter() then
  -- -- distance = 16000
  -- -- speed = 4500
  -- -- if event.ability:HasAttribute("AbilityCastRange") then
  -- --   print("FOUND ATTRIBUTE!!!!!!!!")
  -- --   local f = event.ability:Attribute_GetIntValue("AbilityCastRange",0)
  -- --   print("ATTRIBUTE IS "..f)
  -- -- end
  -- end
  local point = caster_pos+direction*distance
  
  caster:EmitSound("Ability.Assassinate")
  
  caster.hitlist = {}
  
  Physics:Unit(caster)
  caster:SetPhysicsFriction(0.1)
  caster:PreventDI(true)
  
  caster:SetPhysicsVelocity(direction * -1200)
  
  caster:SetPhysicsAcceleration(Vector(0,0,-3600))
  
  Timers:CreateTimer(0.8,function()
    FindClearSpaceForUnit(caster,caster:GetAbsOrigin(),true)
    caster:PreventDI(false)
    caster:SetPhysicsVelocity(0)
    end)
  
  
  local point = point + Vector(0,0,300)
  
  local target = FastDummy(point, caster:GetTeam(), 5, 0)
  
  local info = 
  {
  Target = target,
  Source = caster,
  Ability = caster:FindAbilityByName("hawkeye_double_tap_visuals"),  
  EffectName = "particles/units/heroes/hero_sniper/sniper_assassinate.vpcf",
  vSpawnOrigin = target:GetAbsOrigin(),
  fDistance = distance,
  fStartRadius = 64,
  fEndRadius = 64,
  bHasFrontalCone = false,
  bReplaceExisting = false,
  iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
  iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
  iUnitTargetType = DOTA_UNIT_TARGET_HERO,
  fExpireTime = GameRules:GetGameTime() + 10.0,
  bDeleteOnHit = true,
  iMoveSpeed = speed,
  bProvidesVision = false,
  iVisionRadius = 0,
  iVisionTeamNumber = caster:GetTeamNumber(),
  iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION
  }
  
  local projectile = ProjectileManager:CreateTrackingProjectile(info)
  
  local info = 
  {
  Ability = event.ability,
  EffectName = "",
  vSpawnOrigin = caster:GetAbsOrigin(),
  fDistance = distance,
  fStartRadius = 90,
  fEndRadius = 90,
  Source = caster,
  bHasFrontalCone = false,
  bReplaceExisting = false,
  iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
  iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
  iUnitTargetType = DOTA_UNIT_TARGET_HERO,
  fExpireTime = GameRules:GetGameTime() + 10.0,
  vVelocity = direction * speed,
  bProvidesVision = true,
  iVisionRadius = 600,
  iVisionTeamNumber = caster:GetTeamNumber()
  }
  local projectile = ProjectileManager:CreateLinearProjectile(info)
end

function hawkeye_double_tap_reset(event)
  local caster = event.caster
  local ab = caster:FindAbilityByName("hawkeye_double_tap_second_shot")
  local ab2 = caster:FindAbilityByName("hawkeye_double_tap")
  ab:SetHidden(true)
  ab2:SetHidden(false)
  caster.hitlist = {}
end

function hawkeye_double_tap_2_check(event)
  local caster = event.caster
  local mult = event.mult or 5
  local dmg = caster:GetAverageTrueAttackDamage(caster)*mult
  local n = 0
  PrintTable(caster.hitlist)
  for k,v in pairs(caster.hitlist) do
    print("======CHECKING ENTRY======")
    print("======"..k.."======")
    if IsValidEntity(v) then
      if v:IsAlive() then
        n = k
        print("======TARGET "..k.." IS VALID======")
        break
      end
    end
  end
  print("target is "..n)
  
  if n == 0 then caster:EmitSound("Hawkeye.Doh") caster:RemoveModifierByName("hawkeye_double_tap_second_shot_effect_mod") return end
  if caster.hitlist[n]:IsRealHero() and caster.hitlist[n]:GetHealth() <= dmg then caster:EmitSound("Hawkeye.Yes") end
  if not caster.hitlist[n]:IsRealHero() then caster:EmitSound("Hawkeye.Doh") end

  event.ability:ApplyDataDrivenModifier(caster, caster.hitlist[n], "modifier_show_target", {}) --[[Returns:void
  No Description Set
  ]]
  
  caster.double_tap_target = caster.hitlist[n]
  
--  caster:RemoveModifierByName("hawkeye_double_tap_second_shot_effect_mod")
end

function hawkeye_double_tap_2(event)
  local caster = event.caster
  local ab = event.ability
  local ab2 = caster:FindAbilityByName("hawkeye_double_tap")
  local speed = 3200
  local n = 1
  if caster.double_tap_target == nil then return end
--  PrintTable(caster.hitlist)
--  for k,v in pairs(caster.hitlist) do
--    print("======CHECKING ENTRY======")
--    print("======"..k.."======")
--    if IsValidEntity(v) then
--      if v:IsAlive() then
--        n = k
--        print("======TARGET "..k.." IS VALID======")
--        break
--      end
--    end
--  end
--  print("target is "..n)
--  
--  local target = caster.hitlist[n]
  local target = caster.double_tap_target

  caster:EmitSound("Ability.Assassinate")
  
  caster:RemoveModifierByName("hawkeye_double_tap_second_shot_effect_mod")
  
  local info = 
  {
  Target = target,
  Source = caster,
  Ability = event.ability,  
  EffectName = "particles/units/heroes/hero_sniper/sniper_assassinate.vpcf",
  vSpawnOrigin = target:GetAbsOrigin(),
  fDistance = 6000,
  fStartRadius = 64,
  fEndRadius = 64,
  bHasFrontalCone = false,
  bReplaceExisting = false,
  iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
  iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
  iUnitTargetType = DOTA_UNIT_TARGET_HERO,
  fExpireTime = GameRules:GetGameTime() + 10.0,
  bDeleteOnHit = true,
  iMoveSpeed = speed,
  bProvidesVision = true,
  iVisionRadius = 300,
  iVisionTeamNumber = caster:GetTeamNumber(),
  iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION
  }
  
  local projectile = ProjectileManager:CreateTrackingProjectile(info)
end

function hawkeye_double_tap_hit(event)
  local caster = event.caster
  local target = event.target
  local target_hp = target:GetMaxHealth()
  local mult = event.mult or 3
  -- if caster:HasScepter() then mult = event.mult_scepter or 1.25 end
  table.insert(caster.hitlist,target)
  local ab = event.ability
  local ab2 = caster:FindAbilityByName("hawkeye_double_tap_second_shot")
  local basedmg = event.ability:GetLevelSpecialValueFor("base_damage",event.ability:GetLevel()-1)

  ab:SetHidden(true)
  ab2:SetHidden(false)

  ab2:StartCooldown(1)
  
  event.ability:ApplyDataDrivenModifier(caster,caster,"hawkeye_double_tap_second_shot_effect_mod",{})
  
  local damage = caster:GetAverageTrueAttackDamage(caster)*mult+basedmg
  
  print("DAMAGE IS AT "..damage.." AND BASE DAMAGE IS AT "..caster:GetAverageTrueAttackDamage(caster))
--  local damage = target_hp*0.5
  local dmgTable = {
    attacker = caster,
    victim = target,
    damage = damage,
    damage_type = event.ability:GetAbilityDamageType(),
    ability = event.ability
    }
    ApplyDamage(dmgTable)
  --if not target:IsAlive() then table.remove(caster.hitlist,target) end  
end

function hawkeye_double_tap_hit_2(event)
  local caster = event.caster
  local target = event.target
  local target_hp = target:GetMaxHealth()
  local ab = caster:FindAbilityByName("hawkeye_double_tap_second_shot")
  local mult = ab:GetLevelSpecialValueFor("mult",ab:GetLevel()-1)
  local scep_mult = ab:GetLevelSpecialValueFor("mult_scepter",ab:GetLevel()-1)
  local basedmg = ab:GetLevelSpecialValueFor("base_damage",ab:GetLevel()-1)

  -- if caster:HasScepter() then mult = scep_mult end
  
  local damage = caster:GetAverageTrueAttackDamage(caster)*mult+basedmg
  
  print("DAMAGE IS AT "..damage.." AND BASE ATTACK DAMAGE IS AT "..caster:GetAverageTrueAttackDamage(caster).." AND MULTIPLIER IS AT "..mult.." AND BONUS DAMAGE IS "..basedmg)
--  local damage = target_hp*0.5
  local dmgTable = {
    attacker = caster,
    victim = target,
    damage = damage,
    damage_type = DAMAGE_TYPE_PURE,
    ability = event.ability
    }
    ApplyDamage(dmgTable)
  
end

function hawkeye_double_tap_end(event)
  local caster = event.caster
  local target = event.target
  
  print("END")
  
  target:ForceKill(true)
end

function hawkeye_ricochet_propagate(event)
  local caster = event.caster
  local target = event.target
  local radius = event.radius
  local damage = event.damage
  local enemy_found = FindUnitsInRadius( caster:GetTeamNumber(),
                              target:GetCenter(),
                              nil,
                                radius,
                                DOTA_UNIT_TARGET_TEAM_ENEMY,
                                DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_CREEP,
                                DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE,
                                FIND_CLOSEST,
                                false)
                                
  for k,v in pairs(enemy_found) do
    --[[local damage_table = {
    victim = v,
    attacker = caster,
    damage = damage,
    damage_type = DAMAGE_TYPE_PHYSICAL,
    ability = event.ability
    } ]]
    --ApplyDamage(damage_table)
    caster:PerformAttack(v,true,true,true,false,true, false, true)
  end
  
  Orders:IssueAttackOrder(caster,target)
end

function hawkeye_hit_n_run(event)
  local caster = event.caster
  local facing = caster:GetForwardVector()
  local distance = event.ability:GetLevelSpecialValueFor("jump_distance",event.ability:GetLevel()-1)
  
  
  ProjectileManager:ProjectileDodge(caster)
  
  local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_centaur/centaur_warstomp.vpcf", PATTACH_CUSTOMORIGIN, event.caster)
      ParticleManager:SetParticleControl(particle, 0, event.caster:GetAbsOrigin())
      ParticleManager:SetParticleControl(particle, 1, Vector(225,225,225))
  
  Physics:Unit(caster)
  caster:SetPhysicsFriction(0)
  caster:PreventDI(true)
  -- To allow going through walls / cliffs add the following:
  caster:FollowNavMesh(false)
  caster:SetAutoUnstuck(false)
  caster:SetNavCollisionType(PHYSICS_NAV_NOTHING)
  
  caster:SetPhysicsVelocity(facing * distance * 2)
  caster:AddPhysicsVelocity(Vector(0,0,distance*2))
  
  caster:SetPhysicsAcceleration(Vector(0,0,-(distance*10)))
  
  Timers:CreateTimer(0.5,function()
    caster:SetPhysicsVelocity(Vector(0,0,0))
--    FindClearSpaceForUnit(caster,caster:GetAbsOrigin(),true)
    caster:PreventDI(false)
  end
  )
  Timers:CreateTimer(0.6,function()
    FindClearSpaceForUnit(caster,caster:GetAbsOrigin(),true)
  end
  )
end

function hawkeye_rapid_fire(event)
  local caster = event.caster
  local target = event.target
  local hits = event.hits

  caster:Interrupt()
  caster:Stop()

  event.ability:ApplyDataDrivenModifier(caster, caster, "modifier_rapidfire_damage_reduction", { Duration=(0.15*(hits-1))+0.05 }) --[[Returns:void
  No Description Set
  ]]
  
  for i=0, hits-1 do
    Timers:CreateTimer(0.15*i,function()
      caster:PerformAttack(target,true,true,true,false,true, false, true)
    end)
  end
  
  Timers:CreateTimer(0.15*(hits-1)+0.08,function()
    Orders:IssueAttackOrder(caster,target)
  end)
end

function DetonateCountdown(keys)
  local caster = keys.caster
  local target = keys.target
  local ticks = keys.ticks

  local mod = target:FindModifierByName("modifier_detonator_dart")

  mod:SetStackCount(ticks)
end

function DetonateTick(keys)
  local caster = keys.caster
  local target = keys.target

  local damage = keys.damage
  local radius = keys.radius
  local forceExplode = keys.explode == 1

  local mod = target:FindModifierByName("modifier_detonator_dart")

  mod:SetStackCount(mod:GetStackCount()-1)

  if mod:GetStackCount() <= 0 or forceExplode then
    target:RemoveModifierByName("modifier_detonator_dart")
    local enemy_found = FindUnitsInRadius( caster:GetTeamNumber(),
                              target:GetCenter(),
                              nil,
                                radius,
                                DOTA_UNIT_TARGET_TEAM_ENEMY,
                                DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_CREEP,
                                DOTA_UNIT_TARGET_FLAG_NONE,
                                FIND_CLOSEST,
                                false)
    for k,v in pairs(enemy_found) do
      DealDamage(v,caster,damage,DAMAGE_TYPE_MAGICAL)
    end

    ParticleManager:CreateParticle("particles/units/heroes/hero_phoenix/phoenix_supernova_reborn.vpcf", PATTACH_ABSORIGIN_FOLLOW, target) --[[Returns:int
    Creates a new particle effect
    ]]
    target:EmitSound("Hero_Gyrocopter.CallDown.Damage")

    target:AddNewModifier(caster, nil, "modifier_stunned", {Duration=0.5}) --[[Returns:void
    No Description Set
    ]]
    return
  end

  target:EmitSound("Hawkeye.DetBeep")
end