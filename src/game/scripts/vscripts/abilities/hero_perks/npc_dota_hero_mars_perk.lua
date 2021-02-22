--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_mars_perk", "abilities/hero_perks/npc_dota_hero_mars_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_mars_perk ~= "" then npc_dota_hero_mars_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_npc_dota_hero_mars_perk				
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_mars_perk ~= "" then modifier_npc_dota_hero_mars_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_mars_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_mars_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_mars_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_mars_perk:RemoveOnDeath()
	return false
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------

function modifier_npc_dota_hero_mars_perk:OnCreated()
	if IsServer() then
		local caster = self:GetCaster()
		local ab = caster:FindAbilityByName("faceless_void_backtrack")
		if ab then
			ab:SetLevel(1)
		else
			ab = caster:AddAbility("faceless_void_backtrack")
            ab:SetStolen(true)
			ab:SetLevel(1)
			ab:SetHidden(false)
		end
	end
end
