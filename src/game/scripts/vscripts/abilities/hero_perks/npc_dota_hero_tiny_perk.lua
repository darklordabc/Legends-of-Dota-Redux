--------------------------------------------------------------------------------------------------------
--
--		Hero: Tiny
--		Perk: Increases damage done to buildings by 10%. 
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_tiny_perk", "abilities/hero_perks/npc_dota_hero_tiny_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_tiny_perk ~= "" then npc_dota_hero_tiny_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_npc_dota_hero_tiny_perk				
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_tiny_perk ~= "" then modifier_npc_dota_hero_tiny_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_tiny_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_tiny_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_tiny_perk:RemoveOnDeath()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_tiny_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_tiny_perk:DeclareFunctions()
	return { MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE }
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_tiny_perk:GetModifierTotalDamageOutgoing_Percentage(keys)
	local target = keys.target
	if target:IsBuilding() then
		return 10
	else 
		return 0
	end
end
--------------------------------------------------------------------------------------------------------
