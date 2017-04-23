function lich_winters_requiem(event)
  local caster = event.caster
  local caster_vec = caster:GetAbsOrigin()
  local damage = event.damage
  local explosionradius = 200
  local radius = event.radius
  local point = RandomVector(RandomInt(125,radius))
  local final_vec = caster_vec+point
  print("EXPLOSION!!")
  local particle  = ParticleManager:CreateParticle("particles/units/heroes/hero_lich/lich_frost_nova.vpcf", PATTACH_ABSORIGIN, caster)
  ParticleManager:SetParticleControl(particle,0,final_vec)
  ParticleManager:SetParticleControl(particle,1,final_vec)
--  local particle = ParticleManager:CreateParticle("particles/econ/events/ti4/teleport_end_ground_flash_ti4.vpcf", PATTACH_ABSORIGIN, caster)
  EmitSoundOn("Ability.FrostNova",caster)
  
  local enemy_found = FindUnitsInRadius( caster:GetTeamNumber(),
                              final_vec,
                              nil,
                                explosionradius,
                                DOTA_UNIT_TARGET_TEAM_ENEMY,
                                DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_CREEP,
                                DOTA_UNIT_TARGET_FLAG_NONE,
                                FIND_ANY_ORDER,
                                false)
  for k,v in pairs(enemy_found) do
    local damage_table = {
    victim = v,
    attacker = caster,
    damage = damage,
    damage_type = DAMAGE_TYPE_MAGICAL,
    ability = event.ability
    } 
    ApplyDamage(damage_table)
    event.ability:ApplyDataDrivenModifier(caster,v,"lich_winters_requiem_slow_mod",{})
  end
end

function lich_absolute_zero_start(event)
  local caster = event.caster
  local modifier = "lich_absolute_zero_slow_mod"
  
  if caster:HasScepter() then modifier = "lich_absolute_zero_scepter_mod" end
  
  local enemy_found = FindUnitsInRadius( caster:GetTeamNumber(),
                              caster:GetAbsOrigin(),
                              nil,
                                FIND_UNITS_EVERYWHERE,
                                DOTA_UNIT_TARGET_TEAM_ENEMY,
                                DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_CREEP,
                                DOTA_UNIT_TARGET_FLAG_NONE,
                                FIND_ANY_ORDER,
                                false)
  for k,v in pairs(enemy_found) do
    if v:IsMagicImmune() then break end
    event.ability:ApplyDataDrivenModifier(caster,v,modifier,{})
  end
end