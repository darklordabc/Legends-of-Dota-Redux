--------------------------------------------------------------------------------------------------------
--
--		Hero: Ancient Apparition
--		Perk: Ancient Apparition disables the health regeneration of targets when a Ice ability debuff is applied.
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_ancient_apparition_perk", "abilities/hero_perks/npc_dota_hero_ancient_apparition_perk.lua", LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_ancient_apparition_perk ~= "" then npc_dota_hero_ancient_apparition_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_npc_dota_hero_ancient_apparition_perk				
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_ancient_apparition_perk ~= "" then modifier_npc_dota_hero_ancient_apparition_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_ancient_apparition_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_ancient_apparition_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_ancient_apparition_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_ancient_apparition_perk:RemoveOnDeath()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_ancient_apparition_perk:IsBuff()
	return true
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_ancient_apparition_perk_heal_freeze", "abilities/hero_perks/npc_dota_hero_ancient_apparition_perk.lua", LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_ancient_apparition_perk_heal_freeze ~= "" then modifier_npc_dota_hero_ancient_apparition_perk_heal_freeze = class({}) end
--------------------------------------------------------------------------------------------------------
--    Modifier: modifier_npc_dota_hero_ancient_apparition_perk_heal_freeze        
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_ancient_apparition_perk_heal_freeze:DeclareFunctions()
  local funcs = {
    MODIFIER_PROPERTY_DISABLE_HEALING
  }
  return funcs
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_ancient_apparition_perk_heal_freeze:GetTexture()
  return "ancient_apparition_ice_blast"
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_ancient_apparition_perk_heal_freeze:GetDisableHealing(keys)
  return 1
end
--------------------------------------------------------------------------------------------------------
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
    if caster:HasModifier("modifier_npc_dota_hero_ancient_apparition_perk") then
      if ability:HasAbilityFlag("ice") then
        local modifierDuration = filterTable["duration"]
	if target:GetTeamNumber() ~= caster:GetTeamNumber() then
          parent:AddNewModifier(caster,nil,"modifier_npc_dota_hero_ancient_apparition_perk_heal_freeze",{duration = modifierDuration})
	end
      end
    end  
  end
end
