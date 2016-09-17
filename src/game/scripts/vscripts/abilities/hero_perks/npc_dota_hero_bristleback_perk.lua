--------------------------------------------------------------------------------------------------------
--
--		Hero: bristleback
--		Perk: 
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_bristleback_perk", "abilities/hero_perks/npc_dota_hero_bristleback_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_bristleback_perk == nil then npc_dota_hero_bristleback_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_npc_dota_hero_bristleback_perk				
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_bristleback_perk == nil then modifier_npc_dota_hero_bristleback_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_bristleback_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_bristleback_perk:IsHidden()
	return true
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------

