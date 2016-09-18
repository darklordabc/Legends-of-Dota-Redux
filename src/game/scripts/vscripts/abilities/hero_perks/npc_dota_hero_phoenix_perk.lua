--------------------------------------------------------------------------------------------------------
--
--		Hero: centaur
--		Perk: 
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_phoenix_perk", "abilities/hero_perks/npc_dota_hero_phoenix_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_phoenix_perk == nil then npc_dota_hero_phoenix_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_npc_dota_hero_phoenix_perk				
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_phoenix_perk == nil then modifier_npc_dota_hero_phoenix_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_phoenix_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_phoenix_perk:IsHidden()
	return true
end

function modifier_npc_dota_hero_phoenix_perk:RemoveOnDeath()
	return false
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_phoenix_perk:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_TAKEDAMAGE,
	}
	return funcs
end

function modifier_npc_dota_hero_phoenix_perk:OnTakeDamage(params)
	if params.unit == self:GetParent() then
		local egg = self:GetParent():FindAbilityByName("phoenix_supernova")
		if params.damage > self:GetParent():GetHealth() and egg and egg:IsCooldownReady() then
			self:GetParent():CastAbilityNoTarget(egg, self:GetParent():GetPlayerID())
		end
	end
end