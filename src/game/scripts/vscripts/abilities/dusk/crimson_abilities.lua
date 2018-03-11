function crimson_disintegrate(event)
  local caster = event.caster
  local target = event.target

  
  
  local selfdamage = event.selfdamage
  
  local damage = event.damage
  if caster:HasScepter() then damage = event.damage_scepter end

  local hp = target:GetHealth()
  local cp = caster:GetHealth()

  damage = hp * (damage/100)
  selfdamage = cp * (damage/100)

  event.ability:ApplyDataDrivenModifier(caster, target, "crimson_disintegrate_reduction_mod", {}) --[[Returns:void
  No Description Set
  ]]
  
  local dmgTable = {
    attacker = caster,
    victim = target,
    damage = damage,
    damage_type = DAMAGE_TYPE_PURE,
    ability = event.ability
    }
    ApplyDamage(dmgTable)
  if not caster:IsAlive() then
    local t = caster:GetRespawnTime()
    caster:SetTimeUntilRespawn(t/2)
  end
  if target:IsRealHero() then
    if caster:HasScepter() then
      -- Start searching for units in a 350 radius
      local enemy_found = FindUnitsInRadius( caster:GetTeamNumber(),
                              target:GetCenter(),
                              nil,
                                350,
                                DOTA_UNIT_TARGET_TEAM_ENEMY,
                                DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_CREEP,
                                DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE,
                                FIND_CLOSEST,
                                false)
    for k,v in pairs(enemy_found) do
      Timers:CreateTimer(k*0.15,function()
        if v:IsPositionInRange(target:GetAbsOrigin(),600) then
          if v ~= target then
            EmitSoundOn("Hero_Lion.FingerOfDeathImpact",v)
            local particle  = ParticleManager:CreateParticle("particles/units/heroes/hero_crimson/crimson_disintegrate.vpcf", PATTACH_CUSTOMORIGIN, target)
            ParticleManager:SetParticleControlEnt(particle,0,target,PATTACH_POINT_FOLLOW,"attach_hitloc",target:GetAbsOrigin(),true)
            ParticleManager:SetParticleControlEnt(particle,1,v,PATTACH_POINT_FOLLOW,"attach_hitloc",v:GetAbsOrigin(),true)
            event.ability:ApplyDataDrivenModifier(caster, v, "crimson_disintegrate_reduction_mod", {}) --[[Returns:void
            No Description Set
            ]]
            local dmgTable = {
            attacker = caster,
            victim = v,
            damage = damage,
            damage_type = DAMAGE_TYPE_MAGICAL,
            ability = event.ability
            }
            ApplyDamage(dmgTable)
          end
        end
      end)
    end
    end
  end
end

function crimson_drain(event)
  local caster = event.caster
  local target = event.target
  local particle = event.particle
  local speed = event.speed
  
  local info = 
  {
  Target = caster,
  Source = target,
  Ability = event.ability,  
  EffectName = particle,
  vSpawnOrigin = target:GetAbsOrigin(),
  fDistance = 2000,
  fStartRadius = 64,
  fEndRadius = 64,
  bHasFrontalCone = false,
  bReplaceExisting = false,
  iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_FRIENDLY,
  iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
  iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
  fExpireTime = GameRules:GetGameTime() + 10.0,
  bDeleteOnHit = true,
  iMoveSpeed = speed,
  bProvidesVision = false,
  iVisionRadius = 0,
  iVisionTeamNumber = caster:GetTeamNumber()
  }
  
  local projectile = ProjectileManager:CreateTrackingProjectile(info)
  
end

function crimson_red_rituals_dmg(event)
  local caster = event.caster
  local target = event.unit
  local damage = event.damage
  local threshold = event.threshold
  local stack = target:GetModifierStackCount("crimson_red_rituals_stun_check",event.ability)
  local stunduration = (stack/threshold)*0.75
  
  target:SetModifierStackCount("crimson_red_rituals_stun_check",event.ability,stack+damage)
  
  print("STACKS ARE "..stack)
  
  if stack >= threshold then print("PROC!!!") print("STUN DURATION IS "..stunduration) target:AddNewModifier(caster,nil,"modifier_stunned",{Duration=stunduration}) target:SetModifierStackCount("crimson_red_rituals_stun_check",event.ability,0) return end
  
end

function blood_sorcery(keys)
  local caster = keys.caster
  local hperc = 100-caster:GetHealthPercent()
  local str = caster:GetStrength()
  local int = caster:GetIntellect()

  caster:SetModifierStackCount("crimson_blood_sorcery_armor_mod",keys.ability,hperc)
  caster:SetModifierStackCount("crimson_blood_sorcery_mod",keys.ability,int)

  caster:CalculateStatBonus()

end

function Lifebreak(keys)
  local caster = keys.caster

  local cahp = caster:GetMaxHealth()

  local pct = keys.self_damage / 100

  local u = cahp * pct

  local s = caster:GetHealth() - u

  if s <= 0 then
    s = 1
  end

  caster:SetHealth(s)
end

function BloodSorceryGainMana(keys)
  local caster = keys.caster
  local target = keys.unit

  local tahp = target:GetMaxHealth()
  local pct = keys.amt / 100

  local r = math.ceil(tahp * pct)

  caster:GiveMana(r)
end

function BloodSorceryManaCheck(keys)
  local caster = keys.caster
  local pct = caster:GetManaPercent()

  if pct >= 75 then
    keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_blood_sorcery_regen", {}) --[[Returns:void
    No Description Set
    ]]
  else
    caster:RemoveModifierByName("modifier_blood_sorcery_regen") --[[Returns:void
    Removes a modifier
    ]]
  end
end

function StartRituals(keys)
  local caster = keys.caster
  local target = keys.target

  local hp = target:GetHealth()

  target.rr_hp = hp
end

function RedRituals(keys)
  local caster = keys.caster
  local target = keys.target

  local hp = target.rr_hp

  local c = target:GetHealth()

  local dmg = keys.damage

  local d = ((hp - c)*dmg) / 10

  local b = ((keys.bonus / 100) * c) / 10

  DealDamage(target,caster,d+b,DAMAGE_TYPE_MAGICAL)
end

function DestructionSphere(keys)
  local caster = keys.caster
  local target = caster:GetCursorPosition()

  local delay = keys.delay
  local radius = keys.aoe
  local damage = keys.base
  local percent = keys.percent

  local unit = FastDummy(target+Vector(0,0,240),caster:GetTeamNumber(),delay+0.03,radius)
  local p = ParticleManager:CreateParticle("particles/units/heroes/hero_crimson/crimson_destruction_sphere.vpcf", PATTACH_ABSORIGIN_FOLLOW, unit) --[[Returns:int
  Creates a new particle effect
  ]]
  ParticleManager:SetParticleControl(p, 0, Vector(0,0,0)) --[[Returns:void
  Set the control point data for a control on a particle effect
  ]]
  ParticleManager:SetParticleControl(p, 1, Vector(radius,0,0)) --[[Returns:void
  Set the control point data for a control on a particle effect
  ]]
  Timers:CreateTimer(delay,function()
    local enemy = FindUnitsInRadius( caster:GetTeamNumber(),
                          target,
                          nil,
                        radius,
                        DOTA_UNIT_TARGET_TEAM_ENEMY,
                        DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_CREEP,
                        DOTA_UNIT_TARGET_FLAG_NONE,
                        FIND_CLOSEST,
                        false)
    for k,v in pairs(enemy) do
      local hp = v:GetHealthDeficit()
      local dmg = (hp*percent)+damage
      DealDamage(v,caster,dmg,DAMAGE_TYPE_MAGICAL)
    end
  end)
end

function Sacrifice(keys)
  local caster = keys.caster
  local target = keys.target

  local unit = FastDummy(target:GetCenter(),caster:GetTeamNumber(),30,0)

  Physics:Unit(unit)
  unit:SetPhysicsFriction(0)
  unit:PreventDI(true)
    -- To allow going through walls / cliffs add the following:
  unit:FollowNavMesh(false)
  unit:SetAutoUnstuck(false)
  unit:SetNavCollisionType(PHYSICS_NAV_NOTHING)

  keys.ability:ApplyDataDrivenModifier(caster, unit, "modifier_sacrifice_move_aura", {}) --[[Returns:void
  No Description Set
  ]]

  unit.owner = caster

  unit:SetAbsOrigin(unit:GetAbsOrigin()+Vector(0,0,150))

  local p = ParticleManager:CreateParticle("particles/units/heroes/hero_crimson/crimson_sacrifice.vpcf", PATTACH_POINT_FOLLOW, unit) --[[Returns:int
  Creates a new particle effect
  ]]

  ParticleManager:SetParticleControl(p, 0, Vector(0,0,200)) --[[Returns:void
  Set the control point data for a control on a particle effect
  ]]
end

function MoveSacrifice(keys)
  local caster = keys.caster
  local target = keys.target
  local owner = target.owner
  local speed = 775

  local direction = ((caster:GetAbsOrigin()+Vector(0,0,150)) - target:GetAbsOrigin()):Normalized()

  if target:GetRangeToUnit(caster) < 20 then
    target:RemoveSelf()
  end
    
  target:SetPhysicsVelocity(direction * speed)
end

function AncientPact(keys)
  local caster = keys.caster
  local hp = caster:GetHealthDeficit()
  local mp = caster:GetMana()
  local max = 375
  local amt = mp
  local mult = keys.x
  if mp > hp then amt = hp end
  if amt > max then amt = max end
  if hp > max then hp = max end

  caster:SpendMana(amt*mult,caster)
  caster:Heal(amt,caster)

  local p = ParticleManager:CreateParticle("particles/units/heroes/hero_crimson/crimson_ancient_pact.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster) --[[Returns:int
  Creates a new particle effect
  ]]
end