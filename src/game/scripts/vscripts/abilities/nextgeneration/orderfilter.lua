-- Uther (added it here because I dont want it in the ingame files)
require('abilities/nextgeneration/hero_uther/Argent_Smite')
-- Proteus
require('abilities/nextgeneration/hero_proteus/proteus_jet')

function nextGenOrderFilter(filterTable)
  local units = filterTable["units"]
  local order_type = filterTable["order_type"]
  local issuer = filterTable["issuer_player_id_const"]
  local abilityIndex = filterTable["entindex_ability"]
  local targetIndex = filterTable["entindex_target"]
  
  local unit = EntIndexToHScript(units["0"])
  local target = EntIndexToHScript(targetIndex)
  local ability = EntIndexToHScript(abilityIndex)


  -- Uther controls
  AllowAlliedAttacks(unit,target,order_type)
  if CancelOtherAlliedAttacks(unit,target,order_type) == false then
    --return false -- I think this can be skipped
  end
  
  -- Tried this as fix for the ranged heroes
  --StopAllowingAlliedAttacks(unit,target,order_type)
  
  -- Proteus order filters
  jetOrder(filterTable)
  
  return filterTable
end

function nextGenModifierFilter(filterTable)
  local parent_index = filterTable["entindex_parent_const"]
  local caster_index = filterTable["entindex_caster_const"]
  local ability_index = filterTable["entindex_ability_const"]
  if not parent_index or not caster_index or not ability_index then
      return filterTable
  end
  local parent = EntIndexToHScript( parent_index )
  local caster = EntIndexToHScript( caster_index )
  local ability = EntIndexToHScript( ability_index )

  -- Uther argent smite
  argentSmiteDoNotDebuffAllies(filterTable)
  
  
  -- Returning the filterTable
  return filterTable
end

function nextGenDamageFilter(filterTable)
    local victim_index = filterTable["entindex_victim_const"]
    local attacker_index = filterTable["entindex_attacker_const"]
    local ability_index = filterTable["entindex_inflictor_const"]
    if not victim_index or not attacker_index then
        return filterTable
    end
    local parent = EntIndexToHScript( victim_index )
    local caster = EntIndexToHScript( attacker_index )

    -- Argent smite not hurting allies
    filterTable = damageFilterArgentSmite(filterTable)

  
  return filterTable
end
