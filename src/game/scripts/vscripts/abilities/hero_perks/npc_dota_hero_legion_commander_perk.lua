--------------------------------------------------------------------------------------------------------
--
--		Hero: legion_commander
--		Perk: 
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_legion_commander_perk", "abilities/hero_perks/npc_dota_hero_legion_commander_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_legion_commander_perk == nil then npc_dota_hero_legion_commander_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_npc_dota_hero_legion_commander_perk				
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_legion_commander_perk == nil then modifier_npc_dota_hero_legion_commander_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_legion_commander_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_legion_commander_perk:IsHidden()
	return true
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------

