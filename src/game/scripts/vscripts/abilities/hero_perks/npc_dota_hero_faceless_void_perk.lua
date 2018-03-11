--------------------------------------------------------------------------------------------------------
--
--		Hero: faceless_void
--		Perk: 
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_faceless_void_perk", "abilities/hero_perks/npc_dota_hero_faceless_void_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_faceless_void_perk ~= "" then npc_dota_hero_faceless_void_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_npc_dota_hero_faceless_void_perk				
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_faceless_void_perk ~= "" then modifier_npc_dota_hero_faceless_void_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_faceless_void_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_faceless_void_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_faceless_void_perk:IsHidden()
	return true
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------

