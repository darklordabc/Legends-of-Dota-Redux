--------------------------------------------------------------------------------------------------------
--
--		Hero: Ursa
--		Perk: Increases all damage done to neutrals by 15%
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_ursa_perk", "abilities/hero_perks/npc_dota_hero_ursa_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_ursa_perk == nil then npc_dota_hero_ursa_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_npc_dota_hero_ursa_perk				
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_ursa_perk == nil then modifier_npc_dota_hero_ursa_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_ursa_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_ursa_perk:IsHidden()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_ursa_perk:RemoveOnDeath()
	return false
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_ursa_perk:DeclareFunctions()
	return { MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE }
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_ursa_perk:GetModifierTotalDamageOutgoing_Percentage(keys)
	local target = keys.target
	if target and target:GetTeam() == DOTA_TEAM_NEUTRALS then
		return 15
	else 
		return 0
	end
end
--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------
