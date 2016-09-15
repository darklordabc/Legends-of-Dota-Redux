--------------------------------------------------------------------------------------------------------
--
--		Hero: Nature's Prophet
--		Perk: Reduces the cooldown of all Teleportation abilities by 50%. 
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_furion_perk", "scripts/vscripts/../abilities/hero_perks/npc_dota_hero_furion_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_furion_perk == nil then npc_dota_hero_furion_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_npc_dota_hero_furion_perk				
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_furion_perk == nil then modifier_npc_dota_hero_furion_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_furion_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_furion_perk:IsHidden()
	return true
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_furion_perk:DeclareFunctions()
  local funcs = {
    MODIFIER_EVENT_ON_ABILITY_START,
  }
  return funcs
end

function modifier_npc_dota_hero_furion_perk:OnAbilityStart(keys)
  if IsServer() then
    local hero = self:GetCaster()
    local target = keys.target
    local ability = keys.ability
    
    local teleportSpells = {
    	furion_teleportation = true,
    	wisp_relocate = true,
    	abyssal_underlord_dark_rift = true,
    	item_tpscroll = true,
    	item_travel_boots = true,
    	item_travel_boots_2 = true
    	}


    if teleportSpells[ability] then
      ability:EndCooldown()
      ability:StartCooldown(ability:GetCooldown(ability:GetLevel()-1)*0.5)
    end
  end
end
