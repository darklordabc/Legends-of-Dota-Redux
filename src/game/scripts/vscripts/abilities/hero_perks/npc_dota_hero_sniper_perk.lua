--------------------------------------------------------------------------------------------------------
--
--		Hero: Sniper
--		Perk: When Sniper uses Shrapnel it will have a global cast range.
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_sniper_perk", "abilities/hero_perks/npc_dota_hero_sniper_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_sniper_perk ~= "" then npc_dota_hero_sniper_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_npc_dota_hero_sniper_perk				
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_sniper_perk ~= "" then modifier_npc_dota_hero_sniper_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_sniper_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_sniper_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_sniper_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_sniper_perk:RemoveOnDeath()
	return false
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_sniper_perk:OnCreated(keys)
    if IsServer() then
        local caster = self:GetCaster()

        if caster:HasAbility("sniper_shrapnel") and PlayerResource:GetSteamAccountID(caster:GetPlayerOwnerID()) > 0 then
	        self.grave = caster:AddAbility("sniper_shrapnel_perk")
	        caster:SwapAbilities("sniper_shrapnel","sniper_shrapnel_perk",false,true)
        end
    end
end
