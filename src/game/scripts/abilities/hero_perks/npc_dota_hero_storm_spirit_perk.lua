--------------------------------------------------------------------------------------------------------
--
--    Hero: storm
--    Perk: Gives 1 mana everytime the OnUnitMoved event triggers
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_storm_spirit_perk", "scripts/vscripts/../abilities/hero_perks/npc_dota_hero_storm_spirit_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_storm_spirit_perk == nil then npc_dota_hero_storm_spirit_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--    Modifier: modifier_npc_dota_hero_storm_perk        
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_storm_spirit_perk == nil then modifier_npc_dota_hero_storm_spirit_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_storm_spirit_perk:IsPassive()
  return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_storm_spirit_perk:IsHidden()
  return false
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_storm_spirit_perk:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_UNIT_MOVED,
    }
    return funcs
end

function modifier_npc_dota_hero_storm_spirit_perk:OnUnitMoved(keys)
  if keys.unit == self:GetCaster() then
    self:GetParent():GiveMana(1/3)
  end
end
