--------------------------------------------------------------------------------------------------------
--
--    Hero: Alchemist
--    Perk: At the start of the game, Alchemist gains a free level of Greevils Greed, whether he has it or not. 
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
function modifier_npc_dota_hero_alchemist_perk:GetTexture()
  return "alchemist_goblins_greed"
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_alchemist_perk:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_ABILITY_FULLY_CAST
    }
end

function modifier_npc_dota_hero_alchemist_perk:OnAbilityFullyCast(params)
    if params.unit == self:GetParent() then
        local item = params.ability
        if item:GetAbilityName() == "item_ultimate_scepter" or item:GetAbilityName() == "item_moon_shard" or string.find(item:GetAbilityName(),"consumable") then
            self:GetParent():ModifyGold( item:GetGoldCost(-1) * 0.25, true, 0 ) 
        end
    end
end