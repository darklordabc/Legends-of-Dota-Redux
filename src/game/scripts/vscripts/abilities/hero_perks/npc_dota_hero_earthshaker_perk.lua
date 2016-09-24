--------------------------------------------------------------------------------------------------------
--
--		Hero: earthshaker
--		Perk: Heals for (2)% of earthshakers max hp when using an earth spell
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_earthshaker_perk", "abilities/hero_perks/npc_dota_hero_earthshaker_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_earthshaker_perk == nil then npc_dota_hero_earthshaker_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_npc_dota_hero_earthshaker_perk				
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_earthshaker_perk == nil then modifier_npc_dota_hero_earthshaker_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_earthshaker_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_earthshaker_perk:IsHidden()
	return true
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_earthshaker_perk:DeclareFunctions()
  local funcs = {
    MODIFIER_EVENT_ON_ABILITY_FULLY_CAST
  }
  return funcs
end

function modifier_npc_dota_hero_earthshaker_perk:OnAbilityFullyCast(keys)
  local healPercent = 2
  healPercent = 0.01 * healPercent

  if IsServer() then
    if keys.unit == self:GetParent() then
      if keys.ability:HasAbilityFlag("earth") then
        keys.unit:Heal(self:GetParent():GetMaxHealth() * healPercent ,keys.ability)
      end
    end
  end
end
