--------------------------------------------------------------------------------------------------------
--
--		Hero: Morphling
--		Perk: Increases Morphling's movement speed by 50% in water.
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_morphling_perk", "abilities/hero_perks/npc_dota_hero_morphling_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_morphling_perk == nil then npc_dota_hero_morphling_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_npc_dota_hero_morphling_perk				
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_morphling_perk == nil then modifier_npc_dota_hero_morphling_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_morphling_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_morphling_perk:IsHidden()
	return true
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