--------------------------------------------------------------------------------------------------------
--
--		Hero: phantom_assassin
--		Perk: 
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_phantom_assassin_perk", "abilities/hero_perks/npc_dota_hero_phantom_assassin_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_phantom_assassin_perk == nil then npc_dota_hero_phantom_assassin_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_npc_dota_hero_phantom_assassin_perk				
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_phantom_assassin_perk == nil then modifier_npc_dota_hero_phantom_assassin_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_phantom_assassin_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_phantom_assassin_perk:IsHidden()
	return true
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------

