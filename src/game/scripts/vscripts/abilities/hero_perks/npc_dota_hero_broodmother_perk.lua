--------------------------------------------------------------------------------------------------------
--
--		Hero: Broodmother
--		Perk: Non-ultimate Summon abilities will have 20% mana cost refunded and 20% cooldown reduction
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_broodmother_perk", "abilities/hero_perks/npc_dota_hero_broodmother_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_broodmother_perk ~= "" then npc_dota_hero_broodmother_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_npc_dota_hero_broodmother_perk				
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_broodmother_perk ~= "" then modifier_npc_dota_hero_broodmother_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_broodmother_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_broodmother_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_broodmother_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_broodmother_perk:RemoveOnDeath()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_broodmother_perk:OnCreated()
  if IsServer() then
    local cooldownReductionPercent = 25
    self.cooldownReduction = 1 - (cooldownReductionPercent / 100)
  end
  return true
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_broodmother_perk:DeclareFunctions()
  local funcs = {
    MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
  }
  return funcs
end

function modifier_npc_dota_hero_broodmother_perk:OnAbilityFullyCast(keys)
  if IsServer() then
    local hero = self:GetCaster()
    local unit = keys.unit
    local ability = keys.ability

    if hero == unit and ability:HasAbilityFlag("summon_non_ult") then
      local cooldown = ability:GetCooldownTimeRemaining() * self.cooldownReduction
      hero:GiveMana(ability:GetManaCost(ability:GetLevel()-1) * 0.25)
      ability:EndCooldown()
      ability:StartCooldown(cooldown)
    end
  end
end

