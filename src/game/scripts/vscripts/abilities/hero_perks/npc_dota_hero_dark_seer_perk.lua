--------------------------------------------------------------------------------------------------------
--
--		Hero: Dark Seer
--		Perk: Dark Seer self-casts Surge and Ion Shell when casting them on allies.
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_dark_seer_perk", "abilities/hero_perks/npc_dota_hero_dark_seer_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_dark_seer_perk ~= "" then npc_dota_hero_dark_seer_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_npc_dota_hero_dark_seer_perk				
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_dark_seer_perk ~= "" then modifier_npc_dota_hero_dark_seer_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_dark_seer_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_dark_seer_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_dark_seer_perk:RemoveOnDeath()
    return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_dark_seer_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------

function modifier_npc_dota_hero_dark_seer_perk:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ABILITY_EXECUTED,
	}
	return funcs
end

--local timers = require('easytimers')

function modifier_npc_dota_hero_dark_seer_perk:OnAbilityExecuted(params)
	if params.unit == self:GetParent() then
		if params.ability:GetName() == "dark_seer_surge" then
			local surge = params.ability
			local duration = surge:GetSpecialValueFor("duration")
			self:GetParent():AddNewModifier(self:GetParent(), surge, "modifier_dark_seer_surge", {duration = duration})
		end
		if params.ability:GetName() == "dark_seer_ion_shell" then
			local shell = params.ability
			local duration = shell:GetSpecialValueFor("duration")
			self:GetParent():AddNewModifier(self:GetParent(), shell, "modifier_dark_seer_ion_shell", {duration = duration})
		end
	end
end