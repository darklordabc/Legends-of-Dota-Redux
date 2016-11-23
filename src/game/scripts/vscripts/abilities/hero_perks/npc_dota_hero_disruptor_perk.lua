--------------------------------------------------------------------------------------------------------
--
--    Hero: Disruptor
--    Perk: Reduces the cooldown of Movement-Blocking abilities by 30% when cast by Disruptor.
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_disruptor_perk", "abilities/hero_perks/npc_dota_hero_disruptor_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_disruptor_perk ~= "" then npc_dota_hero_disruptor_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--    Modifier: modifier_npc_dota_hero_disruptor_perk        
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_disruptor_perk ~= "" then modifier_npc_dota_hero_disruptor_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_disruptor_perk:IsPassive()
  return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_disruptor_perk:IsHidden()
  return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_disruptor_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_disruptor_perk:RemoveOnDeath()
	return false
end
function modifier_npc_dota_hero_disruptor_perk:OnCreated()
  local cooldownReduction = 30

  self.cooldownReduction = 1 - (cooldownReduction * 0.01)
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
    if keys.ability:HasAbilityFlag("blocking") and keys.unit == self:GetParent() then
      keys.ability:EndCooldown()
      keys.ability:StartCooldown(keys.ability:GetCooldown(keys.ability:GetLevel()-1)*self.cooldownReduction)
    end
  end
end

