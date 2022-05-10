--------------------------------------------------------------------------------------------------------
--
--		Hero: nyx_assassin
--		Perk: Nyx Assassin gains 10% Bonus movement speed when invisible.
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_nyx_assassin_perk", "abilities/hero_perks/npc_dota_hero_nyx_assassin_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_nyx_assassin_perk ~= "" then npc_dota_hero_nyx_assassin_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_npc_dota_hero_nyx_assassin_perk				
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_nyx_assassin_perk ~= "" then modifier_npc_dota_hero_nyx_assassin_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_nyx_assassin_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_nyx_assassin_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_nyx_assassin_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_nyx_assassin_perk:RemoveOnDeath()
	return false
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------

function modifier_npc_dota_hero_nyx_assassin_perk:DeclareFunctions()
  local funcs = {
    MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
  }
  return funcs
end

function modifier_npc_dota_hero_nyx_assassin_perk:GetModifierMoveSpeedBonus_Percentage()
    local caster = self:GetParent()
    if caster:IsInvisible() then
      return 17
    else
      return 0
    end
end
