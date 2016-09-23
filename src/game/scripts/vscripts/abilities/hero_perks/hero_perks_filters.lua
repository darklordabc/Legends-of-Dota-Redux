function heroPerksProjectileFilter(filterTable)
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
  
  targetPerks_modifier = {
    npc_dota_hero_dragon_knight_perk = true,
    npc_dota_hero_ancient_apparition_perk = true,
    npc_dota_hero_drow_ranger = true, 
    npc_dota_hero_death_prophet = true,
    npc_dota_hero_obsidian_destroyer = true
  }
  -- Perk for Dragon Knight
  local perkForDragonKnight = require('abilities/hero_perks/npc_dota_hero_dragon_knight_perk')
  PerkDragonKnight(filterTable)
  -- Perk for Ancient Apparition
  local perkForAncientApparition = require('abilities/hero_perks/npc_dota_hero_ancient_apparition_perk')
  perkAncientApparition(filterTable)
   -- Perk for Drow Ranger
  local perkForDrowRanger = require('abilities/hero_perks/npc_dota_hero_drow_ranger_perk')
  perkDrowRanger(filterTable)
  -- Perk for Death Prophet
  local perkForDeathProphet = require('abilities/hero_perks/npc_dota_hero_death_prophet_perk')
  perkDeathProphet(filterTable)
   -- Perk for Outworld Devourer
  local perkforOD = require('abilities/hero_perks/npc_dota_hero_obsidian_destroyer_perk')
  perkOD(filterTable)
  -- Returning the filterTable
  return filterTable
end

function heroPerksDamageFilter(filterTable)
	local victim_index = filterTable["entindex_victim_const"]
    local attacker_index = filterTable["entindex_attacker_const"]
    local ability_index = filterTable["entindex_inflictor_const"]
    if not victim_index or not attacker_index then
        return true
    end
    local parent = EntIndexToHScript( victim_index )
    local caster = EntIndexToHScript( attacker_index )
  
  targetPerks_damage = {
    npc_dota_hero_abaddon_perk = true,
  }
  -- Perk for Dragon Knight
  local perkForAbaddon = require('abilities/hero_perks/npc_dota_hero_abaddon_perk')
  PerkAbaddon(filterTable)
  return filterTable
end

function heroPerksGoldFilter(filterTable)
  
  local perkForAlchemist = require('abilities/hero_perks/npc_dota_hero_alchemist_perk')
  alchemistPerkGoldFilter(filterTable)
  
  return filterTable
end

