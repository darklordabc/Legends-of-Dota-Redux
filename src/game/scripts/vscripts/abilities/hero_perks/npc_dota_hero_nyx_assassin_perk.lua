--------------------------------------------------------------------------------------------------------
--
--		Hero: nyx_assassin
--		Perk: Bonus movement speed when invisible
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_nyx_assassin_perk", "abilities/hero_perks/npc_dota_hero_nyx_assassin_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_nyx_assassin_perk == nil then npc_dota_hero_nyx_assassin_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_npc_dota_hero_nyx_assassin_perk				
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_nyx_assassin_perk == nil then modifier_npc_dota_hero_nyx_assassin_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_nyx_assassin_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_nyx_assassin_perk:IsHidden()
	return true
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------

function modifier_npc_dota_hero_nyx_assassin_perk:DeclareFunctions()
  local funcs = {
    MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
  }
end

function modifier_npc_dota_hero_nyx_assassin_perk:GetModifierMoveSpeedBonus_Percentage()
  if IsServer() then
    local caster = self:GetParent()
    local bonusMovementSpeed = 10

    if caster:IsInvisible() then
      return bonusMovementSpeed
    else
      return 0
    end
  end
end
