--------------------------------------------------------------------------------------------------------
--
--		Hero: Lich
--		Perk: Denying a creep gives 25% of that creeps max health to lich
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
		MODIFIER_EVENT_ON_DEATH,
	}
	return funcs
end

function modifier_npc_dota_hero_lich_perk:OnDeath(params)
	if IsServer() then
		if params.attacker == self:GetParent() and params.attacker:GetTeamNumber() == params.unit:GetTeamNumber() then
			params.attacker:GiveMana(params.unit:GetMaxHealth()*0.25)
		end
	end
end

