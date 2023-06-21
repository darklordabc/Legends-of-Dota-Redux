--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_snapfire_perk", "abilities/hero_perks/npc_dota_hero_snapfire_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_snapfire_perk ~= "" then npc_dota_hero_snapfire_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_npc_dota_hero_snapfire_perk				
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_snapfire_perk ~= "" then modifier_npc_dota_hero_snapfire_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_snapfire_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_snapfire_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_snapfire_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_snapfire_perk:RemoveOnDeath()
	return false
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------

function modifier_npc_dota_hero_snapfire_perk:OnCreated()
	if IsServer() then
		local caster = self:GetCaster()
		local ab = caster:FindAbilityByName("pangolier_lucky_shot")
		if ab then
			ab:SetLevel(1)
		else
			ab = caster:AddAbility("pangolier_lucky_shot")
            ab:SetStolen(true)
			ab:SetLevel(1)
			ab:SetHidden(false)
		end
	end
end
