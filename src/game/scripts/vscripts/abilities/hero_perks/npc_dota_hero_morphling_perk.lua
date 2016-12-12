--------------------------------------------------------------------------------------------------------
--
--		Hero: Morphling
--		Perk: Morphling gains 50% bonus movement speed in water.
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_morphling_perk", "abilities/hero_perks/npc_dota_hero_morphling_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_morphling_perk ~= "" then npc_dota_hero_morphling_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_npc_dota_hero_morphling_perk				
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_morphling_perk ~= "" then modifier_npc_dota_hero_morphling_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_morphling_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_morphling_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_morphling_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_morphling_perk:RemoveOnDeath()
	return false
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_morphling_perk:DeclareFunctions()
	return { MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE }
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_morphling_perk:GetModifierMoveSpeedBonus_Percentage()
	local caster = self:GetCaster() 
	local height = caster:GetAbsOrigin().z
	-- 128 is the height of the river, 140 is around the edges
	if height <= 140 then 
		return 50
	else 
		return 0 
	end
end
--------------------------------------------------------------------------------------------------------
