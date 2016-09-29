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
  local intervalTime = 10
  self.goldAmount = 2
  self:StartIntervalThink(intervalTime)
end




function modifier_npc_dota_hero_alchemist_perk:OnIntervalThink()
  local caster = self:GetParent()
  SendOverheadEventMessage( caster, OVERHEAD_ALERT_GOLD  , caster, self.goldAmount, nil )
  caster:ModifyGold(self.goldAmount,true,DOTA_ModifyGold_GameTick)
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
