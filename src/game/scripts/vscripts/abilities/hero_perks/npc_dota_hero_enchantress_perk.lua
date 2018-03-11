--------------------------------------------------------------------------------------------------------
--
--		Hero: Enchantress
--		Perk: Enchantress can creates plants without the health penalty. 
--		Note: Perk code is located in the Cherub's abilities, like Flower Garden, code. 
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_enchantress_perk", "abilities/hero_perks/npc_dota_hero_enchantress_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_enchantress_perk ~= "" then npc_dota_hero_enchantress_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_npc_dota_hero_enchantress_perk				
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_enchantress_perk ~= "" then modifier_npc_dota_hero_enchantress_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_enchantress_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_enchantress_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_enchantress_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_enchantress_perk:RemoveOnDeath()
    return false
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------

