--local timers = require('easytimers')
--------------------------------------------------------------------------------------------------------
--
--		Hero: Lycan
--		Perk: Shapeshift lasts 20 seconds longer during the night when cast by Lycan. 
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_lycan_perk", "abilities/hero_perks/npc_dota_hero_lycan_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_lycan_perk ~= "" then npc_dota_hero_lycan_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_npc_dota_hero_lycan_perk				
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_lycan_perk ~= "" then modifier_npc_dota_hero_lycan_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_lycan_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_lycan_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_lycan_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_lycan_perk:RemoveOnDeath()
	return false
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
    		if hero:HasModifier("modifier_lycan_shapeshift") and GameRules:IsDaytime() == false then
    			local shapeshift = hero:FindModifierByName("modifier_lycan_shapeshift")
				local shapeshift2 = hero:FindModifierByName("modifier_lycan_shapeshift_aura")
				local shapeshift3 = hero:FindModifierByName("modifier_lycan_shapeshift_speed")
    			shapeshift:SetDuration(shapeshift:GetDuration() + 20.0, true)
				shapeshift2:SetDuration(shapeshift2:GetDuration() + 20.0, true)
				shapeshift3:SetDuration(shapeshift3:GetDuration() + 20.0, true)
    		end

	        return
	    end, DoUniqueString('modify_lycan_ult'), 1.55)
    end
  end
end