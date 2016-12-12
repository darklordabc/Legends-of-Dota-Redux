--------------------------------------------------------------------------------------------------------
--
--		Hero: Magnus
--		Perk: When Magnus casts Enemy Moving abilities, they will have 25% mana refunded and cooldowns reduced by 25%.
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_magnataur_perk", "abilities/hero_perks/npc_dota_hero_magnataur_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_magnataur_perk ~= "" then npc_dota_hero_magnataur_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_npc_dota_hero_magnataur_perk				
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_magnataur_perk ~= "" then modifier_npc_dota_hero_magnataur_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_magnataur_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_magnataur_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_magnataur_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_magnataur_perk:RemoveOnDeath()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_magnataur_perk:OnCreated()
  local manaRefund = 25
  local cooldownReduction = 25

  self.manaRefund = manaRefund * 0.01
  self.cooldownReduction = 1 - (cooldownReduction * 0.01)
  return true
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_magnataur_perk:DeclareFunctions()
  local funcs = {
    MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
  }
  return funcs
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_magnataur_perk:OnAbilityFullyCast(keys)
  if IsServer() then
    if keys.ability:HasAbilityFlag("enemyMoving") and keys.unit == self:GetParent() then
      keys.ability:EndCooldown()
      keys.ability:StartCooldown(keys.ability:GetCooldown(keys.ability:GetLevel()-1)*self.cooldownReduction)
      self:GetParent():GiveMana(keys.ability:GetManaCost(keys.ability:GetLevel()-1)*self.manaRefund)
    end
  end
end

