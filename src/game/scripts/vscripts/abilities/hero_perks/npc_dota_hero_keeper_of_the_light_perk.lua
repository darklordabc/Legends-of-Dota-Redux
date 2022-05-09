--------------------------------------------------------------------------------------------------------
--
--		Hero: keeper_of_the_light
--		Perk: 
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_keeper_of_the_light_perk", "abilities/hero_perks/npc_dota_hero_keeper_of_the_light_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_keeper_of_the_light_perk ~= "" then npc_dota_hero_keeper_of_the_light_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_npc_dota_hero_keeper_of_the_light_perk				
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_keeper_of_the_light_perk ~= "" then modifier_npc_dota_hero_keeper_of_the_light_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_keeper_of_the_light_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_keeper_of_the_light_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_keeper_of_the_light_perk:IsHidden()
	return true
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------

function modifier_npc_dota_hero_keeper_of_the_light_perk:OnCreated(keys)
    if IsServer() then
        local caster = self:GetCaster()
        local kotl = caster:FindAbilityByName("aether_range_lod")

        if kotl then
            kotl:UpgradeAbility(false)
        else 
            kotl = caster:AddAbility("aether_range_lod")
            kotl:SetStolen(true)
            kotl:SetActivated(true)
            kotl:SetLevel(1)
        end
    end
end
