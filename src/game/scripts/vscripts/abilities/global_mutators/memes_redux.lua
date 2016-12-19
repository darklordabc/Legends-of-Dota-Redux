local Timers = require('easytimers')

--------------------------------------------------------------------------------------------------------
--    Modifier: modifier_memes_redux        
--------------------------------------------------------------------------------------------------------
if modifier_memes_redux ~= "" then modifier_memes_redux = class({}) end
----------------------------------------------------------------------------------------------------------
if IsServer() then
----------------------------------------------------------------------------------------------------------
function modifier_memes_redux:OnCreated()
  InitiateMemes()
end
----------------------------------------------------------------------------------------------------------
function modifier_memes_redux:DeclareFunctions()
  return { 
    MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
    MODIFIER_EVENT_ON_DEATH 
  }
end
----------------------------------------------------------------------------------------------------------
function modifier_memes_redux:OnAbilityFullyCast(event)
  local caster = event.unit
  local ability = event.ability

  if ability:GetName() == "satyr_hellcaller_shockwave" then
    caster:EmitSound("Memes.Hadouken")
  end
end
----------------------------------------------------------------------------------------------------------
function modifier_memes_redux:OnDeath(event)
  local target = event.unit

  if target:IsOwnedByAnyPlayer() then
    EmitSoundOnClient("Memes.Death",target:GetPlayerOwner())
  end
end
----------------------------------------------------------------------------------------------------------
end
----------------------------------------------------------------------------------------------------------
function InitiateMemes()
  print("memes initiated")

  ListenToGameEvent('entity_killed', function(event)
    local inflictor_index = event.entindex_inflictor
    local attacker_index = event.entindex_attacker
    local target_index = event.entindex_killed

    if target_index ~= nil and attacker_index ~= nil then
      local attacker = EntIndexToHScript( attacker_index )
      local target = EntIndexToHScript( target_index )

      if inflictor_index ~= nil then
        -- More stuff
      end

      if target:IsRealHero() then
        EmitGlobalSound("Memes.Kill")
      end
    end
  end, nil)

  ListenToGameEvent('entity_hurt',function(event)
    local inflictor_index = event.entindex_inflictor
    local attacker_index = event.entindex_attacker
    local target_index = event.entindex_killed

    if inflictor_index ~= nil and target_index ~= nil and attacker_index ~= nil then
      local ability = EntIndexToHScript( inflictor_index )
      local attacker = EntIndexToHScript( attacker_index )
      local target = EntIndexToHScript( target_index )
      --THERES A HOOK!
      if ability:GetName() == "pudge_meat_hook" and target:IsHero() then
        EmitGlobalSound("Memes.Hook")
      end
    end
  end,nil)
end
----------------------------------------------------------------------------------------------------------
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

  -- Returning the filterTable
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
  end

  -- Returning the filterTable
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

  -- Returning the filterTable
  return filterTable
end