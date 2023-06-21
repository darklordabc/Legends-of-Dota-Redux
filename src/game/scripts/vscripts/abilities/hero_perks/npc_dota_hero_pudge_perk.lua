--------------------------------------------------------------------------------------------------------
--
--		Hero: Pudge
--		Perk: At the start of the game, Pudge gains a free level of Flesh Heap, whether he has it or not.
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_pudge_perk", "abilities/hero_perks/npc_dota_hero_pudge_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_pudge_perk ~= "" then npc_dota_hero_pudge_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_npc_dota_hero_pangolier_perk				
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_pudge_perk ~= "" then modifier_npc_dota_hero_pudge_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_pudge_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_pudge_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_pudge_perk:RemoveOnDeath()
	return false
end
--------------------------------------------------------------------------------------------------------
--function modifier_npc_dota_hero_pudge_perk:GetTexture()
--	return "custom/side_gunner_redux"
--end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_pudge_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------

function modifier_npc_dota_hero_pudge_perk:OnCreated(keys)
    if IsServer() then
        local caster = self:GetCaster()
        local pudge = caster:FindAbilityByName("pudge_flesh_heap")

        if pudge then
            pudge:UpgradeAbility(false)
        else 
            pudge = caster:AddAbility("pudge_flesh_heap")
            pudge:SetStolen(true)
            pudge:SetActivated(true)
            pudge:SetLevel(1)
        end
    end
end
