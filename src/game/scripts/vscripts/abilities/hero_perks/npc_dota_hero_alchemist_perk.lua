--------------------------------------------------------------------------------------------------------
--
--    Hero:  Alchemist
--    Perk: Gives 1 gold per second
--    
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_alchemist_perk", "abilities/hero_perks/npc_dota_hero_alchemist_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_alchemist_perk == nil then npc_dota_hero_alchemist_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--    Modifier: modifier_npc_dota_hero_alchemist_perk        
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_alchemist_perk == nil then modifier_npc_dota_hero_alchemist_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_alchemist_perk:IsPassive()
  return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_alchemist_perk:IsHidden()
  return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_alchemist_perk:RemoveOnDeath()
	return false
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_alchemist_perk:OnCreated()
  local passiveGoldGainPercent = 20 -- In this case 20% means once every 5 goldtick intervals this triggers
  local amountOfTicksPerInterval = 100/passiveGoldGainPercent
  local goldTickTime = GetGoldTickTime or 0.6 -- Standard, the first option isn't used for now.
  self:StartIntervalThink(amountOfTicksPerInterval*goldTickTime)
end

function modifier_npc_dota_hero_alchemist_perk:DeclareFunctions()
  local funcs = {
    MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
    MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
    MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
  }
  return funcs
end

function modifier_npc_dota_hero_alchemist_perk:GetModifierBonusStats_Strength()
  local caster = self:GetParent()
  local stats = caster:FindAbilityByName("attribute_bonus")
  if stats then
    local statsLevel = stats:GetLevel()
    return statsLevel
  else 
    return 0
  end
end

function modifier_npc_dota_hero_alchemist_perk:GetModifierBonusStats_Agility()
  local caster = self:GetParent()
  local stats = caster:FindAbilityByName("attribute_bonus")
  if stats then
    local statsLevel = stats:GetLevel()
    return statsLevel
  else 
    return 0
  end
end

function modifier_npc_dota_hero_alchemist_perk:GetModifierBonusStats_Intellect()
  local caster = self:GetParent()
  local stats = caster:FindAbilityByName("attribute_bonus")
  if stats then
    local statsLevel = stats:GetLevel()
    return statsLevel
  else 
    return 0
  end
end



function modifier_npc_dota_hero_alchemist_perk:OnIntervalThink()
  local OptionManager = require('optionmanager')
  local caster = self:GetParent()
  local goldGain = caster.goldPerTick 
  print("GetGoldPerTick "..goldGain)
  caster:ModifyGold(goldGain,true,DOTA_ModifyGold_GameTick)
end


function alchemistPerkGoldFilter(filterTable)
  local playerID = filterTable["player_id_const"]
  local player =  PlayerResource:GetPlayer(playerID)
  local hero =  player:GetAssignedHero()

  if hero:HasModifier("modifier_npc_dota_hero_alchemist_perk") then
    if not hero.goldPerTick and filterTable.reason_const == DOTA_ModifyGold_GameTick then
      hero.goldPerTick = filterTable.gold
    end
  end
end
