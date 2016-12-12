--------------------------------------------------------------------------------------------------------
--
--      Hero: Queen of Pain
--      Perk: Queen of Pain deals 10% more damage to male heroes, but receives 10% more damage from female heroes.
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_queenofpain_perk", "abilities/hero_perks/npc_dota_hero_queenofpain_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_queenofpain_perk ~= "" then npc_dota_hero_queenofpain_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--      Modifier: modifier_npc_dota_hero_queenofpain_perk               
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_queenofpain_perk ~= "" then modifier_npc_dota_hero_queenofpain_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_queenofpain_perk:IsPassive()
    return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_queenofpain_perk:IsHidden()
    return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_queenofpain_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_queenofpain_perk:RemoveOnDeath()
	return false
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_queenofpain_perk:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE, 
        MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE
    }
    -- body
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_queenofpain_perk:GetModifierTotalDamageOutgoing_Percentage(keys)
    if keys.target and keys.target:IsHero() and keys.target:HasUnitFlag("male") then
        return 10
    else 
        return 0
    end
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_queenofpain_perk:GetModifierIncomingDamage_Percentage(keys)
    if keys.attacker and keys.attacker:IsHero() and keys.attacker:HasUnitFlag("female") then
        return 10
    else 
        return 0
    end
end
--------------------------------------------------------------------------------------------------------
