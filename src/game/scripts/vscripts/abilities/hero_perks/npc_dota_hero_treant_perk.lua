--------------------------------------------------------------------------------------------------------
--
--		Hero: Treant
--		Perk: Treant self-casts Living Armor and Nature's Guise when casting them on allies.
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_treant_perk", "abilities/hero_perks/npc_dota_hero_treant_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_treant_perk ~= "" then npc_dota_hero_treant_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_npc_dota_hero_treant_perk				
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_treant_perk ~= "" then modifier_npc_dota_hero_treant_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_treant_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_treant_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_treant_perk:RemoveOnDeath()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_treant_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------

function modifier_npc_dota_hero_treant_perk:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
	}
	return funcs
end

local Timers = require('easytimers')

function modifier_npc_dota_hero_treant_perk:OnAbilityFullyCast(params)
	if params.caster == self:GetParent() then
		if params.ability:GetName() == "treant_living_armor" then
			local armor = params.ability
			local duration = armor:GetSpecialValueFor("duration")
			self:GetParent():AddNewModifier(self:GetParent(), armor, "modifier_treant_living_armor", {duration = duration})
		end
		if params.ability:GetName() == "treant_natures_guise" then
			local guise = params.ability
			local duration = guise:GetSpecialValueFor("duration")
			self:GetParent():AddNewModifier(self:GetParent(), guise, "modifier_treant_natures_guise", {duration = duration})
		end
	end
end
