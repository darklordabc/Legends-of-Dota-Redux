--------------------------------------------------------------------------------------------------------
--
--		Hero: pugna
--		Perk: 
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_pugna_perk", "abilities/hero_perks/npc_dota_hero_pugna_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_pugna_perk == nil then npc_dota_hero_pugna_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_npc_dota_hero_pugna_perk				
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_pugna_perk == nil then modifier_npc_dota_hero_pugna_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_pugna_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_pugna_perk:IsHidden()
	return true
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------

function modifier_npc_dota_hero_pugna_perk:DeclareFunctions()
  local funcs = {
    MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
  }
  return funcs
end

function modifier_npc_dota_hero_pugna_perk:OnAbilityFullyCast(params)
	if IsServer() and params.unit == self:GetParent() then
		if params.ability:HasAbilityFlag("drain") then
			params.ability:RefundManaCost()
		end
	end
end