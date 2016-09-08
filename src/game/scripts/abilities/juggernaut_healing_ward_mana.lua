function spawnHealingWard (keys)
  local caster = keys.caster
  local ability = keys.ability
  local duration = ability:GetDuration()
  local point = keys.target_points[1]
  local ward = CreateUnitByName('npc_dota_healing_ward', point, false, caster, caster, caster:GetTeamNumber())
  ward:SetControllableByPlayer(caster:GetPlayerID(), false)
  ability:ApplyDataDrivenModifier(caster,ward,"modifier_healing_ward_mana_aura",{duration = duration})

  local radius = ability:GetSpecialValueFor("healing_ward_aura_radius")
  local particle = ParticleManager:CreateParticle("particles/juggernaut_healing_wardmana.vpcf", PATTACH_ABSORIGIN_FOLLOW, ward)
  ParticleManager:SetParticleControl(particle, 1, Vector(radius, radius, radius))
  ParticleManager:SetParticleControlEnt(particle, 2, ward, PATTACH_POINT_FOLLOW, "flame_attachment", ward:GetAbsOrigin(), true)
  ward:FindModifierByName("modifier_healing_ward_mana_aura"):AddParticle(particle, false, false, 1, false, false)
end

function destroyHealingWard(keys)
  keys.target:RemoveSelf()
end

function healingWardMana(keys)
  local ability = keys.ability
  local target = keys.target
  local healing_ward_mana_restore_pct = 0.01 * ability:GetLevelSpecialValueFor("healing_ward_mana_restore_pct",ability:GetLevel()-1) * 0.04
  
  target:GiveMana(target:GetMaxMana()*healing_ward_mana_restore_pct)
end
