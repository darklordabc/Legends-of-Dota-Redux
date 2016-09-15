--------------------------------------------------------------------------------------------------------
--
--		Hero: witch_doctor
--		Perk: 
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_witch_doctor_perk", "scripts/vscripts/../abilities/hero_perks/npc_dota_hero_witch_doctor_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_witch_doctor_perk == nil then npc_dota_hero_witch_doctor_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_npc_dota_hero_witch_doctor_perk				
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_witch_doctor_perk == nil then modifier_npc_dota_hero_witch_doctor_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_witch_doctor_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_witch_doctor_perk:IsHidden()
	return true
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------

