--------------------------------------------------------------------------------------------------------
--
--		Hero: Tinker
--		Perk: After refreshing spells tinker gets a damage boost
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_tinker_perk", "abilities/hero_perks/npc_dota_hero_tinker_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_tinker_perk ~= "" then npc_dota_hero_tinker_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_npc_dota_hero_tinker_perk				
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_tinker_perk ~= "" then modifier_npc_dota_hero_tinker_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_tinker_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_tinker_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_tinker_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_tinker_perk:RemoveOnDeath()
	return false
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_tinker_perk:OnCreated()
	self.refreshBoostTime = 30
	self.damageBoost = 10
end


function modifier_npc_dota_hero_tinker_perk:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
	}
	return funcs
end


function modifier_npc_dota_hero_tinker_perk:OnAbilityFullyCast(params)
	if params.unit == self:GetParent() then
		if params.ability:HasAbilityFlag("refresh") or params.ability:GetAbilityName() == "item_refresher" or params.ability:GetAbilityName() == "item_refresher_shard" then
			params.unit:GiveMana(params.ability:GetManaCost(-1) * 0.5)
		end
	end
end

