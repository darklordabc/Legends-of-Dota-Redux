local Timers = require('easytimers')
--------------------------------------------------------------------------------------------------------
--
--		Hero: Ember Spirit
--		Perk: If Ember Spirit has Fire Remnant and Activate Fire Remnant, he will gain a free level at the start of the game. Also, Activate Fire Remnant will have 50% Mana Refunded.
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_ember_spirit_perk", "abilities/hero_perks/npc_dota_hero_ember_spirit_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_ember_spirit_perk ~= "" then npc_dota_hero_ember_spirit_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_npc_dota_hero_ember_spirit_perk				
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_ember_spirit_perk ~= "" then modifier_npc_dota_hero_ember_spirit_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_ember_spirit_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_ember_spirit_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_ember_spirit_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_ember_spirit_perk:RemoveOnDeath()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_ember_spirit_perk:OnCreated()
	if IsServer() then		
			Timers:CreateTimer(function()
					if self:GetCaster():HasAbility("ember_spirit_activate_fire_remnant") and self:GetCaster():HasAbility("ember_spirit_fire_remnant") then
						self:GetCaster():HeroLevelUp(true)
					end
				return
			end, DoUniqueString('levelup_ES'), 2)		
	end
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_ember_spirit_perk:DeclareFunctions()
  local funcs = {
    MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
  }
  return funcs
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_ember_spirit_perk:OnAbilityFullyCast(keys)
  if IsServer() then

    local manaRefund = .5 --Give back 50% of mana

	if keys.ability:GetAbilityName() == "ember_spirit_activate_fire_remnant" and keys.unit == self:GetParent() then
      self:GetParent():GiveMana(keys.ability:GetManaCost(keys.ability:GetLevel()-1)*manaRefund)
    end
  end
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------

