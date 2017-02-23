--------------------------------------------------------------------------------------------------------
--
--    Hero: Alchemist
--    Perk: Alchemist will receives 2 bonus gold every 10 seconds. Alchemist can also gift Aghanim's Scepters. 
--    
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_alchemist_perk", "abilities/hero_perks/npc_dota_hero_alchemist_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_alchemist_perk ~= "" then npc_dota_hero_alchemist_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--    Modifier: modifier_npc_dota_hero_alchemist_perk        
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_alchemist_perk ~= "" then modifier_npc_dota_hero_alchemist_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_alchemist_perk:IsPassive()
  return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_alchemist_perk:IsHidden()
  return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_alchemist_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_alchemist_perk:RemoveOnDeath()
	return true
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_alchemist_perk:OnCreated()
  local intervalTime = 10
  self.goldAmount = 3
  self:StartIntervalThink(intervalTime)
end


function modifier_npc_dota_hero_alchemist_perk:OnIntervalThink()
  if IsServer() then
    local caster = self:GetParent()
    --SendOverheadEventMessage( nil, OVERHEAD_ALERT_GOLD  , caster, self.goldAmount, nil )
    caster:PopupNumbers(caster, "gold", Vector(255, 215, 0), 2.0, self.goldAmount, 0, nil)
    caster:ModifyGold(self.goldAmount,true,DOTA_ModifyGold_GameTick)
  end
end

