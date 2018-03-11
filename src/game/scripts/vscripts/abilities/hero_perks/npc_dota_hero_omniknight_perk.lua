--------------------------------------------------------------------------------------------------------
--
--		Hero: Omniknight
--		Perk: Light spells refund 40% of their mana cost when cast by Omniknight. 
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_omniknight_perk", "abilities/hero_perks/npc_dota_hero_omniknight_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_omniknight_perk ~= "" then npc_dota_hero_omniknight_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_npc_dota_hero_omniknight_perk				
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_omniknight_perk ~= "" then modifier_npc_dota_hero_omniknight_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_omniknight_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_omniknight_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_omniknight_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_omniknight_perk:RemoveOnDeath()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_omniknight_perk:OnCreated(keys)
    self.manaPercentReduction = 40
    self.manaReduction = self.manaPercentReduction / 100
	return true
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_omniknight_perk:DeclareFunctions()
  local funcs = {
    MODIFIER_EVENT_ON_ABILITY_FULLY_CAST
  }
  return funcs
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_omniknight_perk:OnAbilityFullyCast(keys)
  if IsServer() then
    local hero = self:GetCaster()
    local target = keys.target
    local ability = keys.ability
    if hero == keys.unit and ability and ability:HasAbilityFlag("light") then
      hero:GiveMana(ability:GetManaCost(ability:GetLevel() - 1) * self.manaReduction)
    end
  end
end
