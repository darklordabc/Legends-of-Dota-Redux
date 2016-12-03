function gemini_voidal_flare_purge(event)
  local caster = event.caster
  local target = event.target
  
  target:Purge(true,true,false,true,false)
end

function FastDummy(target, team, duration, vision)
  duration = duration or 0
  vision = vision or  250
  local dummy = CreateUnitByName("npc_dummy_unit", target, false, nil, nil, team)
  if dummy ~= nil then
    dummy:SetAbsOrigin(target) -- CreateUnitByName uses only the x and y coordinates so we have to move it with SetAbsOrigin()
    dummy:SetDayTimeVisionRange(vision)
    dummy:SetNightTimeVisionRange(vision)
    dummy:AddNewModifier(dummy, nil, "modifier_phased", { duration = 9999})
    dummy:AddNewModifier(dummy, nil, "modifier_invulnerable", { duration = 9999})
    dummy:AddNewModifier(dummy, nil, "modifier_kill", {duration = duration })
    
  end
  return dummy
end

function RealmBlister( keys )
  -- Variables
  local caster = keys.caster
  local ability = keys.ability
  local target_point = keys.target_points[1]

  -- Special Variables
  local duration = ability:GetLevelSpecialValueFor("duration", (ability:GetLevel() - 1))
  local vision_radius = ability:GetLevelSpecialValueFor("vision_radius", (ability:GetLevel() - 1))

  -- Dummy
  local dummy_modifier = keys.dummy_aura
  local dummy = CreateUnitByName("npc_dummy_blank", target_point, false, caster, caster, caster:GetTeam())
  dummy:AddNewModifier(caster, nil, "modifier_phased", {})
  ability:ApplyDataDrivenModifier(caster, dummy, dummy_modifier, {})

  -- Vision
  ability:CreateVisibilityNode(target_point, vision_radius, duration)

  -- Timer to remove the dummy
  Timers:CreateTimer(duration, function() dummy:RemoveSelf() end)
end

function ChronosphereAura( keys )
print("==AURA IS ACTIVE==")
  local caster = keys.caster
  local target = keys.target
  local ability = keys.ability
  local aura_modifier = keys.aura_modifier
  local caster_modifier = keys.caster_modifier

  if (caster:GetPlayerOwner() == target:GetPlayerOwner()) then
    ability:ApplyDataDrivenModifier(caster, target, caster_modifier, {})
  else
    ability:ApplyDataDrivenModifier(caster, target, aura_modifier, {}) 
  end
end

--DEPRECATED
-- function gemini_shemi_dmg_block(event)
--   print("==DAMAGE BLOCK==")
--   local caster = event.caster
--   local target = event.unit
--   local attacker = event.attacker
--   local dmg = event.dmg
  
--   if attacker:HasModifier("modifier_chronosphere_datadriven") or attacker:HasModifier("modifier_chronosphere_caster_datadriven") then return end
  
--   NegateDamage(target)
-- end

function abyssal_vortex_aura(event)
  local caster = event.caster
  local target = event.target
  local target_pos = target:GetAbsOrigin()
  local radius = event.radius
  local pull_speed = event.pull_speed
  
  local damage = event.damage or 150
  local dtype = DAMAGE_TYPE_MAGICAL
  local flags = nil
  if caster:HasScepter() then dtype = DAMAGE_TYPE_PURE flags = DOTA_DAMAGE_FLAG_BYPASSES_MAGIC_IMMUNITY end
  
  local enemy_found = FindUnitsInRadius( caster:GetTeamNumber(),
                              target:GetCenter(),
                              nil,
                                radius,
                                DOTA_UNIT_TARGET_TEAM_BOTH,
                                DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_CREEP,
                                DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
                                FIND_CLOSEST,
                                false)
  if not caster:HasScepter() then -- Ignore magic immune units if we don't have Aghanim's Scepter
    for k,v in pairs(enemy_found) do
     if v:IsMagicImmune() then table.remove(enemy_found,k) end
    end
  end
  for k,v in pairs(enemy_found) do
    local direction = (target_pos - v:GetAbsOrigin()):Normalized()
    local distance = 1-((target_pos - v:GetAbsOrigin()):Length2D()/radius)
    local truedistance = distance
    local mindistance = 0.3
    local maxdistance = 0.4
    if distance < mindistance then distance = mindistance end
    if distance > maxdistance then distance = maxdistance end
    if truedistance < 0.98 then
      Physics:Unit(v)
      v:SetPhysicsFriction(0.1)
      v:PreventDI(false)
      
      v:SetPhysicsVelocity(direction * pull_speed * 1.25 * (distance))
    end
    if v:GetTeam() ~= caster:GetTeam() then
      local damage_table = {
        victim = v,
        attacker = caster,
        damage = damage*0.06*truedistance,
        damage_type = dtype,
        damage_flags = flags,
        ability = event.ability
        } 
        ApplyDamage(damage_table)
    else
      DealNonLethalDamage(v,caster,damage*0.06*truedistance,dtype)
    end
  end                              
end

function unstable_rift(event)
  local caster = event.caster
  local caster_pos = caster:GetAbsOrigin()
  local caster_pos_offset = caster:GetForwardVector()*125
  local caster_pnt = caster:GetCursorPosition()
  local duration = event.duration or 14
  
  print("UNSTABLE RIFT IS RUNNING")
  
  local open = FastDummy(caster_pos, caster:GetTeam(), duration+1, 500)
  local close = FastDummy(caster_pnt, caster:GetTeam(), duration+1, 500)
  
  caster.open = open
  caster.close = close
  
  caster.open:SetAbsOrigin(open:GetAbsOrigin()+Vector(0,0,30))
  caster.close:SetAbsOrigin(close:GetAbsOrigin()+Vector(0,0,30))
  
  EmitSoundOn("Hero_Juggernaut.HealingWard.Cast",caster.open)
  EmitSoundOn("Hero_Juggernaut.HealingWard.Cast",caster.close)
  
--  EmitSoundOn("Hero_Juggernaut.HealingWard.Loop",caster.open)
--  EmitSoundOn("Hero_Juggernaut.HealingWard.Loop",caster.close)
  
  caster.openparticle  = ParticleManager:CreateParticle("particles/units/heroes/hero_gemini/gemini_dark_rift.vpcf", PATTACH_ABSORIGIN_FOLLOW, open)
  ParticleManager:SetParticleControl(caster.openparticle,0,caster.open:GetAbsOrigin())
  ParticleManager:SetParticleControl(caster.openparticle,1,caster.open:GetAbsOrigin())
  caster.closeparticle  = ParticleManager:CreateParticle("particles/units/heroes/hero_gemini/gemini_dark_rift.vpcf", PATTACH_ABSORIGIN_FOLLOW, close)
  ParticleManager:SetParticleControl(caster.closeparticle,0,caster.close:GetAbsOrigin())
  ParticleManager:SetParticleControl(caster.closeparticle,1,caster.close:GetAbsOrigin())
  
  
  event.ability:ApplyDataDrivenModifier(caster,open,"gemini_unstable_rift_mod",{})
  event.ability:ApplyDataDrivenModifier(caster,close,"gemini_unstable_rift_mod",{})
  
  if open:HasModifier("gemini_unstable_rift_mod") then print("HAS THE CORRECT MODIFIER!") end
  if close:HasModifier("gemini_unstable_rift_mod") then print("HAS THE CORRECT MODIFIER!") end
end

function gemini_unstable_rift_transport(event)
  local caster = event.caster
  local target = event.target
  local summon_time = event.summon_time
  local enemy_found = FindUnitsInRadius( caster:GetTeamNumber(),
                              target:GetCenter(),
                              nil,
                                100,
                                DOTA_UNIT_TARGET_TEAM_BOTH,
                                DOTA_UNIT_TARGET_HERO,
                                DOTA_UNIT_TARGET_FLAG_NONE,
                                FIND_CLOSEST,
                                false)
  for k,v in pairs(enemy_found) do
    event.ability:ApplyDataDrivenModifier(caster,v,"gemini_unstable_rift_count_mod",{})
    event.ability:ApplyDataDrivenModifier(caster,v,"gemini_unstable_rift_show_mod",{})
    local stacks = v:GetModifierStackCount("gemini_unstable_rift_count_mod",event.ability)
    v:SetModifierStackCount("gemini_unstable_rift_count_mod",event.ability,stacks+1)
    if stacks > summon_time*10 then -- transport the hero across
      if not v:IsSilenced() then 
        if target == caster.open then -- transport to the close
          FindClearSpaceForUnit(v,caster.close:GetAbsOrigin(),true)
          v:RemoveModifierByName("gemini_unstable_rift_count_mod")
          for k,v in pairs(enemy_found) do
            v:RemoveModifierByName("gemini_unstable_rift_count_mod")
          end
          caster.open:EmitSound("Hero_Chen.TeleportOut")
          caster.close:EmitSound("Hero_Chen.TeleportIn")
        end
        if target == caster.close then -- transport to the open
          FindClearSpaceForUnit(v,caster.open:GetAbsOrigin(),true)
          v:RemoveModifierByName("gemini_unstable_rift_count_mod")
          for k,v in pairs(enemy_found) do
            v:RemoveModifierByName("gemini_unstable_rift_count_mod")
          end
          caster.close:EmitSound("Hero_Chen.TeleportOut")
          caster.open:EmitSound("Hero_Chen.TeleportIn")
        end
        local damage_table = {
        victim = v,
        attacker = caster,
        damage = v:GetMaxHealth()*0.15,
        damage_type = DAMAGE_TYPE_MAGICAL,
        ability = event.ability
        } 
        ApplyDamage(damage_table)
        break
      end
    end
  end
end

function gemini_unstable_rift_end(event)
  local caster = event.caster
  
  caster.open:StopSound("Hero_Juggernaut.HealingWard.Loop")
  caster.close:StopSound("Hero_Juggernaut.HealingWard.Loop")
  
  caster.open:EmitSound("Hero_Juggernaut.HealingWard.Stop")
  caster.close:EmitSound("Hero_Juggernaut.HealingWard.Stop")
  
  ParticleManager:DestroyParticle(caster.openparticle,false)
  ParticleManager:DestroyParticle(caster.closeparticle,false)
end

function abyssal_vortex_begin_sound(event)
  local caster = event.caster
  local d = FastDummy(caster:GetAbsOrigin(), caster:GetTeam(), 5, 600)
  caster.dsnd = d
  d:EmitSound("Hero_Enigma.Black_Hole")
end

function abyssal_vortex_stop_sound(event)
  local caster = event.caster
  if caster.dsnd then
    caster.dsnd:StopSound("Hero_Enigma.Black_Hole")
    caster.dsnd:EmitSound("Hero_Enigma.Black_Hole.Stop")
  end
end