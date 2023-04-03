--local timers = require('easytimers')
--------------------------------------------------------------------------------------------------------
--
--      Hero: Wraith King
--      Perk: Wraith King can buyback with a 50% reduced cooldown, refunding 50% of the buyback cost and removing the gold penalty.
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_skeleton_king_perk", "abilities/hero_perks/npc_dota_hero_skeleton_king_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_skeleton_king_perk ~= "" then npc_dota_hero_skeleton_king_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--      Modifier: modifier_npc_dota_hero_skeleton_king_perk             
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_skeleton_king_perk ~= "" then modifier_npc_dota_hero_skeleton_king_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_skeleton_king_perk:IsPassive()
    return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_skeleton_king_perk:IsHidden()
    return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_skeleton_king_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_skeleton_king_perk:RemoveOnDeath()
    return false
end
--------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------
-- Add additional functions
function modifier_npc_dota_hero_skeleton_king_perk:OnCreated(keys)
    if IsServer() then
        local caster = self:GetCaster()
        local pudge = caster:FindAbilityByName("skeleton_king_vampiric_aura")

        if pudge then
            pudge:UpgradeAbility(false)
        else 
            pudge = caster:AddAbility("skeleton_king_vampiric_aura")
            pudge:SetStolen(true)
            pudge:SetActivated(true)
            pudge:SetLevel(1)
        end
    end
end
--------------------------------------------------------------------------------------------------------

