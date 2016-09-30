local Timers = require('easytimers')
--------------------------------------------------------------------------------------------------------
--
--		Hero: lycan
--		Perk: 
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_lycan_perk", "abilities/hero_perks/npc_dota_hero_lycan_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_lycan_perk == nil then npc_dota_hero_lycan_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_npc_dota_hero_lycan_perk				
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_lycan_perk == nil then modifier_npc_dota_hero_lycan_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_lycan_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_lycan_perk:IsHidden()
	return true
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_lycan_perk:DeclareFunctions()
  local funcs = {
    MODIFIER_EVENT_ON_ABILITY_FULLY_CAST
  }
  return funcs
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_lycan_perk:OnAbilityFullyCast(keys)
  if IsServer() then
    local hero = self:GetCaster()
    local target = keys.target
    local ability = keys.ability
    if hero == keys.unit and ability and ability:GetName() == "lycan_shapeshift" then
    	Timers:CreateTimer(function()
    		if hero:HasModifier("modifier_lycan_shapeshift") and GameRules:IsDaytime() == true then
    			local shapeshift = hero:FindModifierByName("modifier_lycan_shapeshift")
    			shapeshift:SetDuration(shapeshift:GetDuration() + 20.0, true)
    		end

	        return
	    end, DoUniqueString('modify_lycan_ult'), 1.55)
    end
  end
end