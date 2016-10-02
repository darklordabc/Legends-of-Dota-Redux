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
    npc_dota_hero_drow_ranger_perk = true, 
    npc_dota_hero_death_prophet_perk = true,
    npc_dota_hero_obsidian_destroyer_perk = true,
    npc_dota_hero_venomancer_perk = true,
    npc_dota_hero_silencer_perk = true,
    npc_dota_hero_viper_perk = true,
    npc_dota_hero_slardar_perk = true,
    npc_dota_hero_spirit_breaker_perk = true,
    npc_dota_hero_troll_warlord_perk = true,
  }

  local targetPerk = caster:FindAbilityByName(caster:GetName() .. "_perk")
  if not targetPerk then return true end
  if not targetPerks_modifier[targetPerk:GetName()] then return true end
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
  -- Perk for Venomancer
  local perkforVenomancer = require('abilities/hero_perks/npc_dota_hero_venomancer_perk')
  perkVenomancer(filterTable)
  -- Perk for Silencer
  local perkforSilencer = require('abilities/hero_perks/npc_dota_hero_silencer_perk')
  perkSilencer(filterTable)
  -- Perk for Viper
  local perkforViper = require('abilities/hero_perks/npc_dota_hero_viper_perk')
  perkViper(filterTable)
  -- Perk for Slardar
  local perkForSlardar = require('abilities/hero_perks/npc_dota_hero_slardar_perk')
  perkSlardar(filterTable)
  -- Perk for Spirit Breaker
  local perkForSpaceCow = require('abilities/hero_perks/npc_dota_hero_spirit_breaker_perk')
  perkSpaceCow(filterTable)
  -- Perk for Troll Warlord
  local perkForTrollWarlord = require('abilities/hero_perks/npc_dota_hero_troll_warlord_perk')
  perkTrollWarlord(filterTable)
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
    npc_dota_hero_pudge_perk = true,
    npc_dota_hero_bane_perk = true
  }
  local targetPerk = caster:FindAbilityByName(caster:GetName() .. "_perk")
  if not targetPerk then return true end
  if not targetPerks_damage[targetPerk:GetName()] then return true end
  -- Perk for Abaddon
  local perkForAbaddon = require('abilities/hero_perks/npc_dota_hero_abaddon_perk')
  PerkAbaddon(filterTable)
   -- Perk for Pudge
  local perkForPudge = require('abilities/hero_perks/npc_dota_hero_pudge_perk')
  PerkPudge(filterTable)
   -- Perk for Bane
  local perkForBane = require('abilities/hero_perks/npc_dota_hero_bane_perk')
  PerkBane(filterTable)

  return filterTable
end

function heroPerksAbilityTuningValueFilter(filterTable)
  return filterTable
end

