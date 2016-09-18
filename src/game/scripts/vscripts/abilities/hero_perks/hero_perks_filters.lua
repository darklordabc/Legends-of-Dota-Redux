function heroPerksDamageFilter(filterTable)
  local targetIndex = filterTable["entindex_target_const"]
  local target = EntIndexToHScript(targetIndex)
  local casterIndex = filterTable["entindex_source_const"]
  local caster = EntIndexToHScript(casterIndex)
  local abilityIndex = filterTable["entindex_ability_const"]
  local ability = EntIndexToHScript(abilityIndex)
  
  -- Perk for Puck
  local puckPerk = require('abilities/hero_perks/npc_dota_hero_puck_perk')
  PerkPuckReflectSpell(caster,target,ability)
  
  local targetPerk = target:FindAbilityByName(target:GetName() .. "_perk")
  if targetPerk and targetPerks_projectile[targetPerk:GetName()] then
    target.perkTarget = caster
    target.perkAbility = ability
  end
  -- Returning the filterTable
  return filterTable
end

function heroPerksModifierFilter(filterTable)
  local parent_index = filterTable["entindex_parent_const"]
  local caster_index = filterTable["entindex_caster_const"]
  local ability_index = filterTable["entindex_ability_const"]
  if not parent_index or not caster_index or not ability_index then
      return true
  end
  local parent = EntIndexToHScript( parent_index )
  local caster = EntIndexToHScript( caster_index )
  local ability = EntIndexToHScript( ability_index )
  -- Perk for Dragon Knight
  local perkForDragonKnight = require('abilities/hero_perks/npc_dota_hero_dragon_knight_perk')
  PerkDragonKnight(filterTable)
  -- Perk for Ancient Apparition
  local perkForAncientApparition = require('abilities/hero_perks/npc_dota_hero_ancient_apparition_perk')
  perkAncientApparition(filterTable)
  -- Returning the filterTable
  return filterTable
end
