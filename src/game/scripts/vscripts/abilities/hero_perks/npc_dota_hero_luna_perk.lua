--------------------------------------------------------------------------------------------------------
--
--		Hero: luna
--		Perk: 
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_luna_perk", "abilities/hero_perks/npc_dota_hero_luna_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_luna_perk == nil then npc_dota_hero_luna_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_npc_dota_hero_luna_perk				
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_luna_perk == nil then modifier_npc_dota_hero_luna_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_luna_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_luna_perk:IsHidden()
	return true
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_luna_perk:DeclareFunctions()
  local funcs = {
    MODIFIER_PROPERTY_FIXED_NIGHT_VISION
  }
end

function modifier_npc_dota_hero_luna_perk:GetNightTimeVisionRange()
  local nightVision = 1800
  return nightVision
end
