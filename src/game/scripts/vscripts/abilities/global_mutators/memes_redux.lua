local Timers = require('easytimers')

function memesProjectileFilter(filterTable)
  local targetIndex = filterTable["entindex_target_const"]
  local target = EntIndexToHScript(targetIndex)
  local casterIndex = filterTable["entindex_source_const"]
  local caster = EntIndexToHScript(casterIndex)
  local abilityIndex = filterTable["entindex_ability_const"]
  local ability = EntIndexToHScript(abilityIndex)

  -- Returning the filterTable
  return filterTable
end

function memesOrderFilter(filterTable)
  local units = filterTable["units"]
  local order_type = filterTable["order_type"]
  local issuer = filterTable["issuer_player_id_const"]
  local abilityIndex = filterTable["entindex_ability"]
  local targetIndex = filterTable["entindex_target"]


  return filterTable
end

function memesModifierFilter(filterTable)
  local parent_index = filterTable["entindex_parent_const"]
  local caster_index = filterTable["entindex_caster_const"]
  local ability_index = filterTable["entindex_ability_const"]
  if not parent_index or not caster_index or not ability_index then
      return true
  end
  local parent = EntIndexToHScript( parent_index )
  local caster = EntIndexToHScript( caster_index )
  local ability = EntIndexToHScript( ability_index )
  local modifierName = filterTable["name_const"]

  -- Add the memes
  -- Darude - Sandstorm
  if modifierName == "modifier_sandking_sand_storm" then
    caster:EmitSound("Memes.Darude_Sandstorm")
    print("dududu")
    Timers:CreateTimer(function()
      if caster and caster:HasModifier("modifier_sandking_sand_storm") then
        return 0.5
      else
        caster:StopSound("Memes.Darude_Sandstorm")
        return nil
      end
    end, DoUniqueString("darude"), 0.5)
  -- THERE'S A HOOK!
  elseif modifierName == "modifier_pudge_meat_hook" then
    Timers:CreateTimer(function()
      EmitSoundOn("Memes.Hook",caster)
    end, DoUniqueString("hook"), 0.3)
  end

 
  return filterTable
end

function memesDamageFilter(filterTable)
    local victim_index = filterTable["entindex_victim_const"]
    local attacker_index = filterTable["entindex_attacker_const"]
    local ability_index = filterTable["entindex_inflictor_const"]
    if not victim_index or not attacker_index then
        return true
    end
    local parent = EntIndexToHScript( victim_index )
    local caster = EntIndexToHScript( attacker_index )
    
    if ability_index then
      local ability = EntIndexToHScript( ability_index ) 
      -- THERE'S A HOOK
      if ability:GetName() == "rattletrap_hookshot" then
        EmitSoundOn("Memes.Hook",caster)
      end
    end

  return filterTable
end