function paragon_cleanse(event)
  local caster = event.caster
  local target = event.target
  local cteam = caster:GetTeam()
  local tteam = target:GetTeam()
  local dmg = event.ability:GetLevelSpecialValueFor("heal",event.ability:GetLevel()-1)

  
  
  print("[Ability: Paragon Cleanse]")
  if cteam == tteam then
  print("Heal.")
    target:Heal(dmg,caster)
    return
  end
  
  local dmgTable = {
    attacker = caster,
    victim = target,
    damage = dmg,
    damage_type = DAMAGE_TYPE_PURE,
    ability = event.ability
  }
  print("Harm.")
  ApplyDamage(dmgTable)
end

function paragon_smite2(keys)
  local caster = keys.caster
  local target = keys.target

  local dmg = keys.damage
  local scepter_dmg = keys.scepter_damage

  local scepter_dmg_bonus = keys.scepter_damage_bonus

  if caster:HasScepter() then
    dmg = scepter_dmg
    if caster:GetTeam() == DOTA_TEAM_GOODGUYS then
      if target == duskDota.lastDireKill.attacker then dmg = dmg + scepter_dmg_bonus end
    else
      if target == duskDota.lastRadiantKill.attacker then dmg = dmg + scepter_dmg_bonus end
    end
  end

  if not target:IsAlive() then keys.ability:RefundManaCost() keys.ability:EndCooldown() return end

  local targetmod = target:GetAbsOrigin()+Vector(0,0,800)
  local unit = FastDummy(target:GetAbsOrigin(),caster:GetTeam(),2,750)
  local boltparticle  = ParticleManager:CreateParticle("particles/units/heroes/hero_paragon/smite.vpcf", PATTACH_ABSORIGIN, unit)
  ParticleManager:SetParticleControl(boltparticle,0,target:GetCenter())
  ParticleManager:SetParticleControl(boltparticle,1,targetmod)
  EmitGlobalSound("Hero_Zuus.GodsWrath")

  ScreenShake(target:GetCenter(), 500, 2, 0.3, 70000, 0, true)

  target:Interrupt()

  DealDamage(target,caster,dmg,DAMAGE_TYPE_PURE)

  if not target:IsAlive() then
    target:AddNoDraw()
    ParticleManager:CreateParticle("particles/units/heroes/hero_nyx_assassin/nyx_assassin_mana_burn.vpcf", PATTACH_ABSORIGIN, unit)
    ParticleManager:CreateParticle("particles/units/heroes/hero_bounty_hunter/bounty_hunter_windwalk.vpcf", PATTACH_ABSORIGIN, unit)
    ParticleManager:CreateParticle("particles/units/heroes/hero_phoenix/phoenix_supernova_reborn.vpcf", PATTACH_ABSORIGIN, unit)
    EmitGlobalSound("Hero_Phoenix.SuperNova.Explode")
  end
end

function paragon_smite(event)
  local caster = event.caster
  local cteam = caster:GetTeam()
  local target = nil
  local dmg = event.ability:GetLevelSpecialValueFor("damage",event.ability:GetLevel()-1) or 800
  if cteam == DOTA_TEAM_GOODGUYS then
    target = duskDota.lastDireKill.attacker
  end
  if cteam == DOTA_TEAM_BADGUYS then
    target = duskDota.lastRadiantKill.attacker
  end
  
  if target == nil or not IsValidEntity(target) then print("Invalid target.") event.ability:EndCooldown() event.ability:RefundManaCost() return end
  local targetmod = target:GetAbsOrigin()+Vector(0,0,800)
  local unit = FastDummy(target:GetAbsOrigin(),caster:GetTeam(),2,750)
  local boltparticle  = ParticleManager:CreateParticle("particles/units/heroes/hero_zuus/zuus_lightning_bolt.vpcf", PATTACH_ABSORIGIN, unit)
  ParticleManager:SetParticleControl(boltparticle,0,target:GetCenter())
  ParticleManager:SetParticleControl(boltparticle,1,targetmod)
  EmitGlobalSound("Hero_Zuus.GodsWrath")
  if not target:IsAlive() then print("Target is dead already") return end

  ScreenShake(target:GetCenter(), 500, 2, 0.3, 70000, 0, true)
  
  if caster:HasScepter() then
    dmg=dmg+100
    
    local k = target:GetStreak()
    local x = event.ability:GetLevelSpecialValueFor("scepter_damage_per_kill",event.ability:GetLevel()-1)
    
    dmg=dmg+(k*x)
  end
  
  local dmgTable = {
    attacker = caster,
    victim = target,
    damage = dmg,
    damage_type = DAMAGE_TYPE_PURE,
    ability = event.ability
  }
  
  ApplyDamage(dmgTable)
  
  local info = 
  {
    Ability = event.ability,
    EffectName = "",
    vSpawnOrigin = target:GetAbsOrigin(),
    fDistance = 0,
    fStartRadius = 64,
    fEndRadius = 64,
    Source = target,
    bHasFrontalCone = false,
    bReplaceExisting = false,
    iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
    iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
    iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
    fExpireTime = GameRules:GetGameTime() + 3.0,
    bDeleteOnHit = false,
    vVelocity = caster:GetForwardVector() * 0,
    bProvidesVision = true,
    iVisionRadius = 700,
    iVisionTeamNumber = caster:GetTeamNumber()
  }
  projectile = ProjectileManager:CreateLinearProjectile(info)
  
  if not target:IsAlive() then
    target:AddNoDraw()
    ParticleManager:CreateParticle("particles/units/heroes/hero_nyx_assassin/nyx_assassin_mana_burn.vpcf", PATTACH_ABSORIGIN, unit)
    ParticleManager:CreateParticle("particles/units/heroes/hero_bounty_hunter/bounty_hunter_windwalk.vpcf", PATTACH_ABSORIGIN, unit)
    ParticleManager:CreateParticle("particles/units/heroes/hero_phoenix/phoenix_supernova_reborn.vpcf", PATTACH_ABSORIGIN, unit)
    EmitGlobalSound("Hero_Phoenix.SuperNova.Explode")
  end

end

--DEPRECATED
-- function paragon_tranquil_reverse_damage(event)
--   local caster = event.attacker
--   local target = event.unit
--   local thp = target:GetHealth()
--   local damage = event.dmg
--   local heal = damage
  
--   NegateDamage(target)
  
-- end

-- --DEPRECATED
-- function paragon_guardian(event)
--   local caster = event.caster
--   local target = event.unit
--   local attacker = event.attacker
  
--   local hp = target:GetHealth()
  
--   local reduc = 1-(event.reduc/100)
  
--   local damage = event.dmg
  
--   print("====[PARAGON GUARDIAN] Running now.")
  
--   if caster == target then print("Units are the same!") return end
--   if caster:HasModifier("paragon_tranquil_seal_mod") or attacker:HasModifier("paragon_tranquil_seal_mod") then return end
  
--   if damage >= hp then
--     --Effects
--     event.ability:ApplyDataDrivenModifier(target,caster,"paragon_guardian_effect_mod",{})
--     event.ability:ApplyDataDrivenModifier(caster,caster,"paragon_guardian_effect_mod",{})
--     EmitSoundOn("Hero_Omniknight.GuardianAngel.Cast",caster)
--     local total = damage*reduc
--     if caster:GetHealth() < total then total = caster:GetHealth()-1 end
--     local dmgTable = {
--     attacker = attacker,
--     victim = caster,
--     damage = total,
--     damage_type = DAMAGE_TYPE_PURE,
--     ability = event.ability
--     }
--     ApplyDamage(dmgTable)
--   end
  
-- end

function guardian(keys)
  local caster = keys.caster
  local target = keys.target

  if target.guardian == nil then

    target.guardian = caster

  else

    target.guardian = nil

  end
end

function TranquilSeal(keys)
  local caster = keys.caster
  local target = keys.target

  local cteam = caster:GetTeam()
  local tteam = target:GetTeam()

  if cteam == tteam then
    keys.ability:ApplyDataDrivenModifier(caster, target, "paragon_tranquil_seal_mod_ally", {}) --[[Returns:void
    No Description Set
    ]]
  else
    keys.ability:ApplyDataDrivenModifier(caster, target, "paragon_tranquil_seal_mod_enemy", {}) --[[Returns:void
    No Description Set
    ]]
  end
end

function conversion(keys)
  local caster = keys.caster
  local p = caster:GetPlayerOwnerID()
  local pl = PlayerResource:GetPlayer(p) --[[Returns:handle
  No Description Set
  ]]
  local target = keys.target
  local damage = keys.damage
  local health_bonus = keys.health_bonus
  local mana_bonus = keys.mana_bon
  local duration = keys.duration or 45

  if target:IsAncient() then return end

  if target:IsRealHero() then DealDamage(target,caster,damage,DAMAGE_TYPE_MAGICAL) return end
  if target:IsIllusion() then target:ForceKill(false) end

  if caster.conversion_creep == nil then
    caster.conversion_creep = target
  else
    if not caster.conversion_creep:IsNull() then
      caster.conversion_creep:ForceKill(false)
    end
    caster.conversion_creep = target
  end

  target:Stop()
  target:SetOwner(PlayerResource:GetSelectedHeroEntity(p))
  target:SetControllableByPlayer(p, true) --[[Returns:void
  Set this unit controllable by the player with the passed ID.
  ]]
  target:SetTeam(caster:GetTeamNumber()) --[[Returns:void
  No Description Set
  ]]
  target:RespawnUnit()
  target:SetMustReachEachGoalEntity(false) --[[Returns:void
  Set whether this NPC is required to reach each goal entity, rather than being allowed to 'unkink' their path
  ]]
  target:SetInitialGoalEntity(nil) --[[Returns:void
  Sets the initial waypoint goal for this NPC
  ]]

  keys.ability:ApplyDataDrivenModifier(caster, target, "modifier_conversion", {}) --[[Returns:void
  No Description Set
  ]]

  target:AddNewModifier(caster, nil, "modifier_kill", {Duration=duration}) --[[Returns:void
  No Description Set
  ]]
end