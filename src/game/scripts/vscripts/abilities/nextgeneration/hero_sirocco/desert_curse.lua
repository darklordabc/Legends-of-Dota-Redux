function ScepterCheck( keys )
  local caster = keys.caster
  local target = keys.target
  local ability = keys.ability
  local plague = keys.plague
  local duration = ability:GetSpecialValueFor("duration")
  local scepter_duration = ability:GetSpecialValueFor("scepter_duration")

  if caster:HasScepter() then
    ability:ApplyDataDrivenModifier(caster, target, plague, {Duration = scepter_duration})
  else
    ability:ApplyDataDrivenModifier(caster, target, plague, {Duration = duration})
  end
end

function damage_cursed( keys )
  local caster = keys.caster
  local target = keys.target
  local ability = keys.ability
  local ability_level = ability:GetLevel() - 1
  local plague = keys.plague
  local plague_shared = keys.plague_shared
  local damage_multiplier = ability:GetLevelSpecialValueFor("damage_multiplier", ability_level)/100
  local radius = ability:GetSpecialValueFor("blast_radius")

  local findheroes = FindUnitsInRadius(caster:GetTeam(), target:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_DAMAGE_FLAG_NONE, FIND_ANY_ORDER, false)
  for _,unit in ipairs(findheroes) do

    local health = unit:GetHealth()
    local damage_table = {}

    damage_table.attacker = caster
    damage_table.damage_type = DAMAGE_TYPE_MAGICAL
    damage_table.ability = ability
    damage_table.victim = unit
    damage_table.damage = health * damage_multiplier

    ApplyDamage(damage_table)
    local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_obsidian_destroyer/obsidian_destroyer_sanity_eclipse_mana_loss.vpcf",PATTACH_ABSORIGIN,unit)

    if not unit:HasModifier(plague) then
      ability:ApplyDataDrivenModifier(caster, unit, plague_shared, {})
    end

  end
end

function stacks_attack( event )
  local caster = event.caster
  local attacker = event.attacker
  local target = event.target
  local ability = event.ability
  local manaBurn = ability:GetLevelSpecialValueFor("mana_damage_lost", (ability:GetLevel() - 1))
  local stacks_modifier = event.stacks_modifier
  local stack = attacker:GetModifierStackCount(stacks_modifier, ability) + 1

  attacker:ReduceMana(manaBurn)
  if not attacker:HasModifier(stacks_modifier) then
    ability:ApplyDataDrivenModifier(caster, attacker, stacks_modifier, {})
  end
  attacker:SetModifierStackCount(stacks_modifier, ability, stack)
end

function stacks_attacked( event )
  local caster = event.caster
  local target = event.target
  local attacker = event.attacker
  local ability = event.ability
  local manaBurn = ability:GetLevelSpecialValueFor("mana_damage_lost", (ability:GetLevel() - 1))
  local stack = 1
  local stacks_modifier = event.stacks_modifier

  if attacker:GetTeam() == DOTA_UNIT_TARGET_TEAM_ENEMY then
    target:ReduceMana(manaBurn)

    if not target:HasModifier(stacks_modifier) then
      ability:ApplyDataDrivenModifier(caster, target, stacks_modifier, {})
      stack = 1
    else
      stack = target:GetModifierStackCount(stacks_modifier, ability)+1
    end

    target:SetModifierStackCount(stacks_modifier, ability, stack)
  end
end