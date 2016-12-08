--------------------------------------------------------------------------------------------------------
--
--		Hero: Riki
--		Perk: Increases Riki's health regeneration by 4 while invisible. 
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_riki_perk", "abilities/hero_perks/npc_dota_hero_riki_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_riki_perk ~= "" then npc_dota_hero_riki_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_npc_dota_hero_riki_perk				
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_riki_perk ~= "" then modifier_npc_dota_hero_riki_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_riki_perk:IsPassive()
	return true
end

--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_riki_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_riki_perk:RemoveOnDeath()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_riki_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------

function modifier_npc_dota_hero_riki_perk:DeclareFunctions()
	return { MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT }
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_riki_perk:GetModifierConstantHealthRegen()
	if self:GetCaster():IsInvisible() then
 		return 4
	else 
		return 0
	end
end
