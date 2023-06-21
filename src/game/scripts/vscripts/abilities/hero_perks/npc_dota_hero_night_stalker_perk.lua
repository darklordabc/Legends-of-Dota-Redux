--------------------------------------------------------------------------------------------------------
--
--		Hero: night_stalker
--		Perk: 
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_night_stalker_perk", "abilities/hero_perks/npc_dota_hero_night_stalker_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_night_stalker_perk ~= "" then npc_dota_hero_night_stalker_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_npc_dota_hero_night_stalker_perk				
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_night_stalker_perk ~= "" then modifier_npc_dota_hero_night_stalker_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_night_stalker_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_night_stalker_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_night_stalker_perk:IsHidden()
	return true
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------

function modifier_npc_dota_hero_night_stalker_perk:OnCreated(keys)
    if IsServer() then
        local caster = self:GetCaster()
        local night = caster:FindAbilityByName("night_stalker_hunter_in_the_night")

        if night then
            night:UpgradeAbility(false)
        else 
            night = caster:AddAbility("night_stalker_hunter_in_the_night")
            night:SetStolen(true)
            night:SetActivated(true)
            night:SetLevel(1)
        end
    end
end
