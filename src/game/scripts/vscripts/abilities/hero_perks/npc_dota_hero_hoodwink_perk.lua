--------------------------------------------------------------------------------------------------------
--
--		Hero: Hoodwink
--		Perk: Hoodwink gets Scurry as a free ability
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_hoodwink_perk", "abilities/hero_perks/npc_dota_hero_hoodwink_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_hoodwink_perk ~= "" then npc_dota_hero_hoodwink_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_npc_dota_hero_puck_perk			
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_hoodwink_perk ~= "" then modifier_npc_dota_hero_hoodwink_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_hoodwink_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_hoodwink_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_hoodwink_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_hoodwink_perk:RemoveOnDeath()
	return false
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_hoodwink_perk:OnCreated(keys)
	
    if IsServer() then
        local caster = self:GetCaster()
        local hood = caster:FindAbilityByName("hoodwink_scurry")

        if hood then
            hood:UpgradeAbility(false)
        else 
            hood = caster:AddAbility("hoodwink_scurry")
            --nullField:SetLevel(1)	
        end
    end
end
