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
function modifier_npc_dota_hero_skeleton_king_perk:DeclareFunctions()
    return { MODIFIER_EVENT_ON_RESPAWN }
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
function modifier_npc_dota_hero_skeleton_king_perk:OnRespawn(keys)
    if IsServer() then
        local caster = self:GetCaster()
        local cooldownReductionPct = 50
        local goldReductionPct = 50

        local cooldownReduction = 1 - (cooldownReductionPct / 100)
        local goldReduction = goldReductionPct / 100

        if caster == keys.unit then
            local buybackCD = OptionManager:GetOption('buybackCooldownConstant') * cooldownReduction
            local buybackCost = caster:GetBuybackCost()
            Timers:CreateTimer(function( )
                if caster:HasModifier('modifier_buyback_gold_penalty') then
                    print("buyback") 
                    print(buybackCD)
                    print(buybackCost)
                    caster:SetBuybackGoldLimitTime(0)
                    caster:RemoveModifierByName('modifier_buyback_gold_penalty')
                    caster:SetBuybackCooldownTime(buybackCD)
                    caster:ModifyGold(buybackCost * goldReduction,false,0)
                end
            end, DoUniqueString('wraithking_buyback'), 0.1)
        end
    end
end
--------------------------------------------------------------------------------------------------------

