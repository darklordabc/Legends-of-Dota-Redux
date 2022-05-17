--------------------------------------------------------------------------------------------------------
--
--		Hero: Chaos Knight
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_chaos_knight_perk", "abilities/hero_perks/npc_dota_hero_chaos_knight_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_chaos_knight_perk ~= "" then npc_dota_hero_chaos_knight_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_npc_dota_hero_chaos_knight_perk				
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_chaos_knight_perk ~= "" then modifier_npc_dota_hero_chaos_knight_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_chaos_knight_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_chaos_knight_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_chaos_knight_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_chaos_knight_perk:RemoveOnDeath()
	return false
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------

function modifier_npc_dota_hero_chaos_knight_perk:OnCreated()
	if IsServer() then
		local caster = self:GetCaster()
		local ab = caster:FindAbilityByName("lycan_summon_wolves_critical_strike")
		if ab then
			ab:SetLevel(1)
		else
			ab = caster:AddAbility("lycan_summon_wolves_critical_strike")
            ab:SetStolen(true)
			ab:SetLevel(1)
			-- ab:SetHidden(true)
		end
	end
end
