--------------------------------------------------------------------------------------------------------
--
--		Hero: legion_commander
--		Perk: 
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_legion_commander_perk", "scripts/vscripts/../abilities/hero_perks/npc_dota_hero_legion_commander_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_legion_commander_perk == nil then npc_dota_hero_legion_commander_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_npc_dota_hero_legion_commander_perk				
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_legion_commander_perk == nil then modifier_npc_dota_hero_legion_commander_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_legion_commander_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_legion_commander_perk:IsHidden()
	return true
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_legion_commander_perk:DeclareFunctions()
  local funcs = {
    MODIFIER_EVENT_ON_ABILITY_START,
  }
  return funcs
end

function modifier_npc_dota_hero_legion_commander_perk:OnAbilityStart(keys)
  if IsServer() then
    local hero = self:GetCaster()
    local target = keys.target
    local ability = keys.ability


    if ability:GetName() == "legion_commander_duel" then
      ability:EndCooldown()
      ability:StartCooldown(ability:GetCooldown(ability:GetLevel()-1)*0.5)
    end
  end
end
