--------------------------------------------------------------------------------------------------------
--
--		Hero: ancient_apparition
--		Perk: Freezes health of targets when a freezing debuff is applied
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_ancient_apparition_perk", "abilities/hero_perks/npc_dota_hero_ancient_apparition_perk.lua", LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_ancient_apparition_perk == nil then npc_dota_hero_ancient_apparition_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_npc_dota_hero_ancient_apparition_perk				
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_ancient_apparition_perk == nil then modifier_npc_dota_hero_ancient_apparition_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_ancient_apparition_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_ancient_apparition_perk:IsHidden()
	return true
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_ancient_apparition_perk_heal_freeze", "abilities/hero_perks/npc_dota_hero_ancient_apparition_perk.lua", LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_ancient_apparition_perk_heal_freeze == nil then modifier_npc_dota_hero_ancient_apparition_perk_heal_freeze = class({}) end
--------------------------------------------------------------------------------------------------------
--    Modifier: modifier_npc_dota_hero_ancient_apparition_perk_heal_freeze        
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_ancient_apparition_perk_heal_freeze:DeclareFunctions()
  local funcs = {
    MODIFIER_PROPERTY_DISABLE_HEALING
  }
  return funcs
end

function modifier_npc_dota_hero_ancient_apparition_perk_heal_freeze:GetDisableHealing(keys)
  return 1
end

function perkAncientApparition(filterTable)
  local parent_index = filterTable["entindex_parent_const"]
  local caster_index = filterTable["entindex_caster_const"]
  local ability_index = filterTable["entindex_ability_const"]
  if not parent_index or not caster_index or not ability_index then
    return true
  end
  local parent = EntIndexToHScript( parent_index )
  local caster = EntIndexToHScript( caster_index )
  local ability = EntIndexToHScript( ability_index )
  if ability then
    local abilityname = ability:GetAbilityName()
    if caster:HasModifier("modifier_npc_dota_hero_ancient_apparition_perk") then
      local iceSpells = {
        tusk_snowball = true,
        drow_ranger_frost_arrows= true,
        crystal_maiden_crystal_nova= true,
        crystal_maiden_frostbite= true,
        crystal_maiden_freezing_field= true,
        jakiro_dual_breath= true,
        jakiro_ice_path= true,
        lich_frost_armor= true,
        lich_frost_nova= true,
        lich_chain_frost= true,
        ancient_apparition_ice_vortex= true,
        ancient_apparition_cold_feet= true,
        invoker_cold_snap= true,
        invoker_ice_wall = true,
        winter_wyvern_arctic_burn= true,
        winter_wyvern_winters_curse= true,
      }

      if iceSpells[abilityname] then
        local modifierDuration = filterTable["duration"]
        parent:AddNewModifier(caster,nil,"modifier_npc_dota_hero_ancient_apparition_perk_heal_freeze",{duration = modifierDuration})
      end
    end  
  end
end
