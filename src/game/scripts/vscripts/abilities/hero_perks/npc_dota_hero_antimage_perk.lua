--------------------------------------------------------------------------------------------------------
--
--		Hero: Antimage
--		Perk: 
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_antimage_perk", "abilities/hero_perks/npc_dota_hero_antimage_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_antimage_perk == nil then npc_dota_hero_antimage_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_npc_dota_hero_antimage_perk				
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_antimage_perk == nil then modifier_npc_dota_hero_antimage_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_antimage_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_antimage_perk:IsHidden()
	return true
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------

