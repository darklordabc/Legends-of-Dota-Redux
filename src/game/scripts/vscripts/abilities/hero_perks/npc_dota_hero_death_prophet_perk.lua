--------------------------------------------------------------------------------------------------------
--
--		Hero: Death Prophet
--		Perk: Any silence from Death Prophet is also a mute.
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_death_prophet_perk", "abilities/hero_perks/npc_dota_hero_death_prophet_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_death_prophet_perk ~= "" then npc_dota_hero_death_prophet_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_npc_dota_hero_death_prophet_perk				
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_death_prophet_perk ~= "" then modifier_npc_dota_hero_death_prophet_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_death_prophet_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_death_prophet_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_death_prophet_perk:RemoveOnDeath()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_death_prophet_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_death_prophet_perk_mute", "abilities/hero_perks/npc_dota_hero_death_prophet_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
--    Modifier: modifier_npc_dota_hero_death_prophet_perk_mute       
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_death_prophet_perk_mute ~= "" then modifier_npc_dota_hero_death_prophet_perk_mute = class({}) end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_death_prophet_perk_mute:CheckState()
  local state = {
    [MODIFIER_STATE_MUTED] = self:GetParent():IsSilenced(),
  }
  return state
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_death_prophet_perk_mute:IsHidden()
  return not self:GetParent():IsSilenced()
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_death_prophet_perk_mute:GetTexture()
  return "death_prophet_witchcraft"
end
--------------------------------------------------------------------------------------------------------
function perkDeathProphet(filterTable)  --ModifierGainedFilter
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
    if caster:HasModifier("modifier_npc_dota_hero_death_prophet_perk") then
      if ability:HasAbilityFlag("silence") then
        local modifierDuration = filterTable["duration"]
        parent:AddNewModifier(caster,ability,"modifier_npc_dota_hero_death_prophet_perk_mute",{duration = modifierDuration})
      end
    end  
  end  
end
