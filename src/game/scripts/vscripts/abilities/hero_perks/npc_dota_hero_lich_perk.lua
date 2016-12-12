--------------------------------------------------------------------------------------------------------
--
--		Hero: Lich
--		Perk: Sacrifice also restores Lich's health. 
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_lich_perk", "abilities/hero_perks/npc_dota_hero_lich_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_lich_perk ~= "" then npc_dota_hero_lich_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_npc_dota_hero_lich_perk				
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_lich_perk ~= "" then modifier_npc_dota_hero_lich_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_lich_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_lich_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_lich_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_lich_perk:RemoveOnDeath()
	return false
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_lich_perk:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ABILITY_EXECUTED,
	}
	return funcs
end

function modifier_npc_dota_hero_lich_perk:OnAbilityExecuted(params)
	if params.unit == self:GetParent() and params.ability:GetName() == "lich_dark_ritual" then
		local sacrifice = params.ability
		local hTarget = params.target
		local hp = hTarget:GetHealth() * sacrifice:GetSpecialValueFor("health_conversion") / 100
		self:GetParent():Heal(hp, self:GetAbility())
		SendOverheadEventMessage(self:GetParent(), OVERHEAD_ALERT_HEAL, self:GetParent(), hp, self:GetParent())
	end
end

