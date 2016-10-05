--------------------------------------------------------------------------------------------------------
--
--		Hero: sniper
--		Perk: swaps shrapnel with better one
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_sniper_perk", "abilities/hero_perks/npc_dota_hero_sniper_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_sniper_perk == nil then npc_dota_hero_sniper_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_npc_dota_hero_sniper_perk				
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_sniper_perk == nil then modifier_npc_dota_hero_sniper_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_sniper_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_sniper_perk:IsHidden()
	return true
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
