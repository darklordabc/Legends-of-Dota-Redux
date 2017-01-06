--------------------------------------------------------------------------------------------------------
--
--		Hero: Rubick
--		Perk: Rubick gains 1 free level of Null Field, whether he has it or not. 
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_rubick_perk", "abilities/hero_perks/npc_dota_hero_rubick_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_rubick_perk ~= "" then npc_dota_hero_rubick_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_npc_dota_hero_rubick_perk				
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_rubick_perk ~= "" then modifier_npc_dota_hero_rubick_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_rubick_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_rubick_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_rubick_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_rubick_perk:RemoveOnDeath()
	return false
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_rubick_perk:OnCreated(keys)
	
    if IsServer() then
        local caster = self:GetCaster()
        local nullField = caster:FindAbilityByName("rubick_null_field")

        if nullField then
            nullField:UpgradeAbility(false)
        else 
            nullField = caster:AddAbility("rubick_null_field")
            nullField:SetHidden(true)
            nullField:SetLevel(1)	
        end
    end
end
--------------------------------------------------------------------------------------------------------
