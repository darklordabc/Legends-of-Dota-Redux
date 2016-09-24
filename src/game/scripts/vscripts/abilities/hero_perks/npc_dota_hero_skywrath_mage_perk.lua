--------------------------------------------------------------------------------------------------------
--
--		Hero: skywrath_mage
--		Perk: 
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_skywrath_mage_perk", "abilities/hero_perks/npc_dota_hero_skywrath_mage_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_skywrath_mage_perk == nil then npc_dota_hero_skywrath_mage_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_npc_dota_hero_skywrath_mage_perk				
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_skywrath_mage_perk == nil then modifier_npc_dota_hero_skywrath_mage_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_skywrath_mage_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_skywrath_mage_perk:IsHidden()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_skywrath_mage_perk:OnCreated(keys)
	self.cooldownThreshold = 7
    self.manaPercentReduction = 15
    self.manaReduction = self.manaPercentReduction / 100
	return true
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_skywrath_mage_perk:DeclareFunctions()
  local funcs = {
    MODIFIER_EVENT_ON_ABILITY_FULLY_CAST
  }
  return funcs
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_skywrath_mage_perk:OnAbilityFullyCast(keys)
  if IsServer() then
    local hero = self:GetCaster()
    local target = keys.target
    local ability = keys.ability
    if hero == keys.unit and ability and ability:GetCooldownTimeRemaining() < self.cooldownThreshold then
      hero:GiveMana(ability:GetManaCost(ability:GetLevel() - 1) * self.manaReduction)
    end
  end
end
