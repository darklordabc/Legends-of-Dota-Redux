--------------------------------------------------------------------------------------------------------
--
--		Hero: Legion Commander
--		Perk: When Legion Commander casts Duel, she will gain spell immunity for the duration of the duel.
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_legion_commander_perk", "abilities/hero_perks/npc_dota_hero_legion_commander_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_legion_commander_perk ~= "" then npc_dota_hero_legion_commander_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_npc_dota_hero_legion_commander_perk				
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_legion_commander_perk ~= "" then modifier_npc_dota_hero_legion_commander_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_legion_commander_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_legion_commander_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_legion_commander_perk:RemoveOnDeath()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_legion_commander_perk:IsPurgable()
	return false
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
    if hero ~= keys.caster then return end
    local ability = keys.ability
    --local timers = require('easytimers')

    if ability:GetName() == "legion_commander_duel" then
      hero:AddNewModifier(hero,ability,"modifier_black_king_bar_immune",{duration = ability:GetLevelSpecialValueFor("duration",ability:GetLevel()-1)})
      Timers:CreateTimer(function ()
        if not hero:HasModifier("modifier_legion_commander_duel") and hero:HasModifier("modifier_black_king_bar_immune") then
      	  hero:RemoveModifierByName("modifier_black_king_bar_immune")
      	else
      	  return 0.5
      	end
      end, 'check_if_duel_is_going_on', 0.5)
    end
  end
end
