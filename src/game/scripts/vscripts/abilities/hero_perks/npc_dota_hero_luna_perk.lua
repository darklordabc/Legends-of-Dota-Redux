--------------------------------------------------------------------------------------------------------
--
--		Hero: Luna
--		Perk: Luna gains 1 free level of Lunar Blessing, whether she has it or not. 
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_luna_perk", "abilities/hero_perks/npc_dota_hero_luna_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_luna_perk ~= "" then npc_dota_hero_luna_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_npc_dota_hero_luna_perk				
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_luna_perk ~= "" then modifier_npc_dota_hero_luna_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_luna_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_luna_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_luna_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_luna_perk:RemoveOnDeath()
    return false
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_luna_perk:OnCreated(keys)
	
    if IsServer() then
        local caster = self:GetCaster()
        local blessing = caster:FindAbilityByName("luna_lunar_blessing")

        if blessing then
            blessing:UpgradeAbility(false)
        else 
            blessing = caster:AddAbility("luna_lunar_blessing")
            blessing:SetHidden(true)
            blessing:SetLevel(1)
        end
    end
end
--------------------------------------------------------------------------------------------------------
