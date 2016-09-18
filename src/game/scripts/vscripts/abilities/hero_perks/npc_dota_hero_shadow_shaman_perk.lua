--------------------------------------------------------------------------------------------------------
--
--    Hero: Shadow Shaman
--    Perk: All hexes get an instant refund in their manacosts and cooldowns get reduced by 20%
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_shadow_shaman_perk", "abilities/hero_perks/npc_dota_hero_shadow_shaman_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_shadow_shaman_perk == nil then npc_dota_hero_shadow_shaman_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--    Modifier: modifier_npc_dota_hero_shadow_shaman_perk       
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_shadow_shaman_perk == nil then modifier_npc_dota_hero_shadow_shaman_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_shadow_shaman_perk:IsPassive()
  return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_shadow_shaman_perk:IsHidden()
  return true
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------

function modifier_npc_dota_hero_shadow_shaman_perk:DeclareFunctions()
  local funcs = {
    MODIFIER_EVENT_ON_ABILITY_EXECUTED

  }
  return funcs
end

function modifier_npc_dota_hero_shadow_shaman_perk:OnAbilityExecuted(keys)
  local cooldownPercentReduction = 20
  local cooldownPercentReduction = 1-(cooldownPercentReduction / 100)

  if IsServer() then
    local hero = self:GetCaster()
    local target = keys.target
    local ability = keys.ability
    print(ability:GetAbilityName())
    if ability:GetName() == "shadow_shaman_voodoo" or ability:GetName() == "lion_voodoo" or ability:GetName() == "item_sheepstick" then
      ability:RefundManaCost()
      ability:EndCooldown()
      ability:StartCooldown(ability:GetCooldown(ability:GetLevel()-1)*cooldownPercentReduction)
    end
  end
end
