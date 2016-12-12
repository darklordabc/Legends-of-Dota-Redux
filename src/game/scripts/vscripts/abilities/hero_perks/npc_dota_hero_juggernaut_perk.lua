--------------------------------------------------------------------------------------------------------
--
--		Hero: Juggernaut
--		Perk: Healing/Mana Ward will have 100 percent of their mana cost refunded.
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_juggernaut_perk", "abilities/hero_perks/npc_dota_hero_juggernaut_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_juggernaut_perk ~= "" then npc_dota_hero_juggernaut_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_npc_dota_hero_juggernaut_perk				
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_juggernaut_perk ~= "" then modifier_npc_dota_hero_juggernaut_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_juggernaut_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_juggernaut_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_juggernaut_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_juggernaut_perk:RemoveOnDeath()
	return false
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------

function modifier_npc_dota_hero_juggernaut_perk:DeclareFunctions()
  local funcs = {
    MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
  }
  return funcs
end

function modifier_npc_dota_hero_juggernaut_perk:OnAbilityFullyCast(params)
	if IsServer() and params.unit == self:GetParent() then
		if params.ability:GetName() == "juggernaut_healing_ward_mana" or params.ability:GetName() == "juggernaut_healing_ward" then
			params.ability:RefundManaCost()
		end
	end
end