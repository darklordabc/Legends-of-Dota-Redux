--------------------------------------------------------------------------------------------------------
--
--		Hero: Shadow Demon
--		Perk: Demonic abilities cast by Shadow Demon will have 20% mana cost refunded and 20% cooldown reduction
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_shadow_demon_perk", "abilities/hero_perks/npc_dota_hero_shadow_demon_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_shadow_demon_perk ~= "" then npc_dota_hero_shadow_demon_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_npc_dota_hero_shadow_demon_perk				
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_shadow_demon_perk ~= "" then modifier_npc_dota_hero_shadow_demon_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_shadow_demon_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_shadow_demon_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_shadow_demon_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_shadow_demon_perk:RemoveOnDeath()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_shadow_demon_perk:OnCreated()
  if IsServer() then
    local cooldownReductionPercent = 20
    self.cooldownReduction = 1 - (cooldownReductionPercent / 100)
  end
  return true
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_shadow_demon_perk:DeclareFunctions()
  local funcs = {
    MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
  }
  return funcs
end

function modifier_npc_dota_hero_shadow_demon_perk:OnAbilityFullyCast(keys)
  if IsServer() then
    local hero = self:GetCaster()
    local unit = keys.unit
    local ability = keys.ability

    if hero == unit and ability:HasAbilityFlag("demon") then
      local cooldown = ability:GetCooldownTimeRemaining() * self.cooldownReduction
      hero:GiveMana(ability:GetManaCost(ability:GetLevel()-1) * 0.2)
      ability:EndCooldown()
      ability:StartCooldown(cooldown)
    end
  end
end

