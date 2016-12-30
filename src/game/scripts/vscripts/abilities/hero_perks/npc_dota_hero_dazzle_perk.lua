--------------------------------------------------------------------------------------------------------
--
--		Hero: Dazzle
--		Perk: Shallow Grave has double cast range and 50% cooldown reduction when picked by Dazzle.
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_dazzle_perk", "abilities/hero_perks/npc_dota_hero_dazzle_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_dazzle_perk ~= "" then npc_dota_hero_dazzle_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_npc_dota_hero_dazzle_perk				
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_dazzle_perk ~= "" then modifier_npc_dota_hero_dazzle_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_dazzle_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_dazzle_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_dazzle_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_dazzle_perk:RemoveOnDeath()
	return false
end
-- Add additional functions
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_dazzle_perk:OnCreated(keys)
    if IsServer() then
        local caster = self:GetCaster()

        if caster:HasAbility("dazzle_shallow_grave") and PlayerResource:GetSteamAccountID(caster:GetPlayerOwnerID()) > 0 and not caster:FindAbilityByName("dazzle_shallow_grave"):IsHidden() then
	        self.grave = caster:AddAbility("dazzle_shallow_grave_perk")
	        self.grave:SetHidden(true)
	        caster:SwapAbilities("dazzle_shallow_grave","dazzle_shallow_grave_perk",false,true)
        end
    end
end