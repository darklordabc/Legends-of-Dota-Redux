--------------------------------------------------------------------------------------------------------
--
--    Hero: Storm Spirit
--    Perk: Storm Spirit gets a free point into Mana Aura, wheter he has it or not
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_storm_spirit_perk", "abilities/hero_perks/npc_dota_hero_storm_spirit_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_storm_spirit_perk ~= "" then npc_dota_hero_storm_spirit_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--    Modifier: modifier_npc_dota_hero_storm_spirit_perk    
      
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_storm_spirit_perk ~= "" then modifier_npc_dota_hero_storm_spirit_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_storm_spirit_perk:IsPassive()
  return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_storm_spirit_perk:IsHidden()
  return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_storm_spirit_perk:RemoveOnDeath()
  return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_storm_spirit_perk:IsPurgable()
  return false
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------

function modifier_npc_dota_hero_storm_spirit_perk:OnCreated(keys)
    if IsServer() then
        local caster = self:GetCaster()
        local mana_aura = caster:FindAbilityByName("forest_troll_high_priest_mana_aura")
        if overload then
            mana_aura:UpgradeAbility(false)
        else 
            mana_aura = caster:AddAbility("forest_troll_high_priest_mana_aura")
            mana_aura:SetStolen(true)
            mana_aura:SetActivated(true)
            mana_aura:SetLevel(1)
        end

    end
end
