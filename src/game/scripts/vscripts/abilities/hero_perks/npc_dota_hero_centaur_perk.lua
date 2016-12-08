--------------------------------------------------------------------------------------------------------
--
--		Hero: Centaur
--		Perk: Centaur Warrunner takes 75% damage from Self-Damaging spells.
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_centaur_perk", "abilities/hero_perks/npc_dota_hero_centaur_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_centaur_perk ~= "" then npc_dota_hero_centaur_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_npc_dota_hero_centaur_perk				
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_centaur_perk ~= "" then modifier_npc_dota_hero_centaur_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_centaur_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_centaur_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_centaur_perk:IsPurgable()
	return false
end

function modifier_npc_dota_hero_centaur_perk:RemoveOnDeath()
	return false
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------

function modifier_npc_dota_hero_centaur_perk:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_TAKEDAMAGE,
	}
	return funcs
end

function modifier_npc_dota_hero_centaur_perk:OnTakeDamage(params)
	if params.attacker == self:GetParent() then
		if params.inflictor and params.inflictor:HasAbilityFlag("self_damage") then
			local hp = self:GetParent():GetHealth()
			self:GetParent():SetHealth(hp + params.damage*0.25)
		end
	end
end
