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

  return filterTable
end
