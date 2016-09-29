--------------------------------------------------------------------------------------------------------
--
--    Hero: Disruptor
--    Perk: When Disruptor casts Enemy Moving abilities, they will have 25% mana refunded and cooldowns reduced by 25%. Abilities that only move units upwards are not counted.
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_disruptor_perk", "abilities/hero_perks/npc_dota_hero_disruptor_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_disruptor_perk == nil then npc_dota_hero_disruptor_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--    Modifier: modifier_npc_dota_hero_disruptor_perk        
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_disruptor_perk == nil then modifier_npc_dota_hero_disruptor_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_disruptor_perk:IsPassive()
  return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_disruptor_perk:IsHidden()
  return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_disruptor_perk:RemoveOnDeath()
	return false
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_disruptor_perk:DeclareFunctions()
  local funcs = {
    MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
  }
  return funcs
end

function modifier_npc_dota_hero_disruptor_perk:OnAbilityFullyCast(keys)
  if IsServer() then

    local manaRefund = 25
    local cooldownReduction = 25

    manaRefund = manaRefund * 0.01
    cooldownReduction = 1 - (cooldownReduction * 0.01)

    if keys.ability:HasAbilityFlag("enemyMoving") and keys.unit == self:GetParent() then
      keys.ability:EndCooldown()
      keys.ability:StartCooldown(keys.ability:GetCooldown(keys.ability:GetLevel()-1)*cooldownReduction)
      self:GetParent():GiveMana(keys.ability:GetManaCost(keys.ability:GetLevel()-1)*manaRefund)
    end
  end
end

