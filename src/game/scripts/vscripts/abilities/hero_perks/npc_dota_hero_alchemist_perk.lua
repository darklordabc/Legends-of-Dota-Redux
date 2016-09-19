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
  return true
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_alchemist_perk:OnCreated()
  self:StartIntervalThink(1)
end

function modifier_npc_dota_hero_alchemist_perk:OnIntervalThink()
  local caster = self:GetParent()
  --if caster:IsAlive() then
    local stats = caster:FindAbilityByName("attribute_bonus")
    local statsLevel = stats:GetLevel()
    local basicGoldGain = 1
    local goldGain = 1 + statsLevel
    caster:ModifyGold(goldGain,true,DOTA_ModifyGold_GameTick)
  --end
end


