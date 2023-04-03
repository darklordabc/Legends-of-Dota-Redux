--------------------------------------------------------------------------------------------------------
--
--		Hero: Zeus
--		Perk: Zeus refunds 20% of the manacost of any Lightning spells he casts.
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_zuus_perk", "abilities/hero_perks/npc_dota_hero_zuus_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_zuus_perk ~= "" then npc_dota_hero_zuus_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_npc_dota_hero_zuus_perk				
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_zuus_perk ~= "" then modifier_npc_dota_hero_zuus_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_zuus_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_zuus_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_zuus_perk:RemoveOnDeath()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_zuus_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_zuus_perk:OnCreated()
  local manaRefund = 25
  local cooldownReduction = 25

  self.manaRefund = manaRefund * 0.01
  self.cooldownReduction = 1 - (cooldownReduction * 0.01)
  return true
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_zuus_perk:DeclareFunctions()
  local funcs = {
    MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
  }
  return funcs
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_zuus_perk:OnAbilityFullyCast(keys)
  if IsServer() then
    if keys.ability:HasAbilityFlag("lightning") and keys.unit == self:GetParent() then
      local cooldown = keys.ability:GetCooldownTimeRemaining()
      keys.ability:EndCooldown()
      keys.ability:StartCooldown(cooldown*self.cooldownReduction)
      self:GetParent():GiveMana(keys.ability:GetManaCost(keys.ability:GetLevel()-1)*self.manaRefund)
    end
  end
end
