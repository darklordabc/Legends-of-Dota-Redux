--------------------------------------------------------------------------------------------------------
--
--    Hero: Storm Spirit
--    Perk: Restores mana when Storm Spirit travels at high speeds. 
--    Function: Compares position every 0.1 second between the previous position, after the initial 50 units the unit will get its unit moved/10 mana
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
        local overload = caster:FindAbilityByName("storm_spirit_overload")
        local arcaneOrb = caster:FindAbilityByName("obsidian_destroyer_arcane_orb")

        if arcaneOrb then
          if self:GetCaster().GetPlayerID then
            util:DisplayError(self:GetCaster():GetPlayerID(), "#perk_denied")
            self:Destroy()
          end
        end
        if not arcaneOrb then
          if overload then
              overload:UpgradeAbility(false)
          else 
              overload = caster:AddAbility("storm_spirit_overload")
              overload:SetHidden(true)
              overload:SetLevel(1)
          end
        end
    end
end
