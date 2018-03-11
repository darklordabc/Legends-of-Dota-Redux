--------------------------------------------------------------------------------------------------------
--
--    Hero: Oracle
--    Perk: Support items used by Oracle will have their cooldowns reduced by 20%.
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_oracle_perk", "abilities/hero_perks/npc_dota_hero_oracle_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_oracle_perk ~= "" then npc_dota_hero_oracle_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--    Modifier: modifier_npc_dota_hero_oracle_perk       
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_oracle_perk ~= "" then modifier_npc_dota_hero_oracle_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_oracle_perk:IsPassive()
  return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_oracle_perk:IsHidden()
  return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_oracle_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_oracle_perk:RemoveOnDeath()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_oracle_perk:OnCreated()
  if IsServer() then
    local cooldownPercentReduction = 20
    self.cooldownReduction = 1 - (cooldownPercentReduction / 100)
	-- Hard-coded due to being used in a listener for items purchased. 
    self.limitedItems = {
      item_buckler = true,
	  item_iron_talon = true,
      item_urn_of_shadows = true,
      item_medallion_of_courage = true,
      item_arcane_boots = true,
      item_ancient_janggo = true,
      item_mekansm = true,
      item_pipe = true,
      item_guardian_greaves = true
    }
  end
  return true
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------

function modifier_npc_dota_hero_oracle_perk:DeclareFunctions()
  local funcs = {
    MODIFIER_EVENT_ON_ABILITY_FULLY_CAST
  }
  return funcs
end

function modifier_npc_dota_hero_oracle_perk:OnAbilityFullyCast(keys)
  if IsServer() then
    local hero = self:GetCaster()
    local target = keys.target
    local ability = keys.ability
    if hero == keys.unit and ability and self.limitedItems[ability:GetName()] then
      local cooldown = ability:GetCooldownTimeRemaining() * self.cooldownReduction
      ability:EndCooldown()
      ability:StartCooldown(cooldown)
    end
  end
end
