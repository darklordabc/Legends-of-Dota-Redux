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
  return true
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
function modifier_npc_dota_hero_alchemist_perk:OnCreated()
    if IsServer() then
        local caster = self:GetCaster()
        local greed = caster:FindAbilityByName("alchemist_goblins_greed")

        if greed then
            greed:UpgradeAbility(false)
        else 
            greed = caster:AddAbility("alchemist_goblins_greed")
            greed:SetHidden(true)
            greed:SetLevel(1)
        end
    end
end