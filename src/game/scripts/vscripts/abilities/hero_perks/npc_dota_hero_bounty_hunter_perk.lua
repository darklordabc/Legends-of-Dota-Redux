--------------------------------------------------------------------------------------------------------
--
--		Hero: Bounty Hunter
--		Perk: Bounty Hunter deals 10% more damage to Tracked enemies. 
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_bounty_hunter_perk", "abilities/hero_perks/npc_dota_hero_bounty_hunter_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_bounty_hunter_perk ~= "" then npc_dota_hero_bounty_hunter_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_npc_dota_hero_bounty_hunter_perk				
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_bounty_hunter_perk ~= "" then modifier_npc_dota_hero_bounty_hunter_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_bounty_hunter_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_bounty_hunter_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_bounty_hunter_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_bounty_hunter_perk:RemoveOnDeath()
	return false
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_bounty_hunter_perk:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE
    }
    -- body
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_bounty_hunter_perk:GetModifierTotalDamageOutgoing_Percentage(keys)
    if keys.target and keys.target:HasModifier("modifier_bounty_hunter_track") then
        return 17
    else 
        return 0
    end
end
--------------------------------------------------------------------------------------------------------
