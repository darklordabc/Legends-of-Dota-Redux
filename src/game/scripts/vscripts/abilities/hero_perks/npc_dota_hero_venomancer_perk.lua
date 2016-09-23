--------------------------------------------------------------------------------------------------------
--
--		Hero: Venomancer
--		Perk: Increases the duration of all Poison effects Venomancer applies by 25%. 
--
--------------------------------------------------------------------------------------------------------
local Timers = require('easytimers')
LinkLuaModifier( "modifier_npc_dota_hero_venomancer_perk", "abilities/hero_perks/npc_dota_hero_venomancer_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_venomancer_perk == nil then npc_dota_hero_venomancer_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_npc_dota_hero_venomancer_perk				
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_venomancer_perk == nil then modifier_npc_dota_hero_venomancer_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_venomancer_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_venomancer_perk:IsHidden()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_venomancer_perk:OnCreated()
	if IsServer() then
		local poisonDurationBonusPct = 25
		self:GetCaster().poisonDurationBonus = (poisonDurationBonusPct / 100)
		self:GetCaster().lastPoisonAbility = nil
	end
	return true
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------
function perkVenomancer(filterTable)
  local parent_index = filterTable["entindex_parent_const"]
  local caster_index = filterTable["entindex_caster_const"]
  local ability_index = filterTable["entindex_ability_const"]
  if not parent_index or not caster_index or not ability_index then
    return true
  end
  local parent = EntIndexToHScript( parent_index )
  local caster = EntIndexToHScript( caster_index )
  local ability = EntIndexToHScript( ability_index )
  if ability then
    if caster:HasModifier("modifier_npc_dota_hero_venomancer_perk") then
      if ability:HasAbilityFlag("poison") and ability ~= caster.lastPoisonAbility then
        local modifierDuration = filterTable["duration"]
        local bonusDuration = modifierDuration + (modifierDuration * caster.poisonDurationBonus)
        local modifierName = filterTable["name_const"]
        print(modifierName)
        print(bonusDuration)
        -- stops recursion
        caster.lastPoisonAbility = ability
        parent:RemoveModifierByName(modifierName)
        parent:AddNewModifier(caster,ability,modifierName,{duration = bonusDuration})
        Timers:CreateTimer(function() 
        	caster.lastPoisonAbility = nil
        end, DoUniqueString("poisonLast"), 0.1)
      end
    end  
  end
end
