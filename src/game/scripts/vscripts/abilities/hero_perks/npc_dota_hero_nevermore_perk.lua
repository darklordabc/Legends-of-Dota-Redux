--------------------------------------------------------------------------------------------------------
--
--      Hero: Shadow Fiend
--      Perk: At the start of the game, Shadow Fiend gains a free level of Necromastery, whether he has it or not.
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_nevermore_perk", "abilities/hero_perks/npc_dota_hero_nevermore_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_nevermore_perk ~= "" then npc_dota_hero_nevermore_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--      Modifier: modifier_npc_dota_hero_nevermore_perk             
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_nevermore_perk ~= "" then modifier_npc_dota_hero_nevermore_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_nevermore_perk:IsPassive()
    return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_nevermore_perk:IsHidden()
    return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_nevermore_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_nevermore_perk:RemoveOnDeath()
    return false
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_nevermore_perk:OnCreated(keys)
    if IsServer() then
        local caster = self:GetCaster()
        local necromastery = caster:FindAbilityByName("nevermore_necromastery")
        local necromasteryOP = caster:FindAbilityByName("nevermore_necromastery_op")

        if necromastery then
            necromastery:UpgradeAbility(false)
        end

        if necromasteryOP then
            necromasteryOP:UpgradeAbility(false)
        end

        if necromastery == nil and necromasteryOP == nil then
            necromastery = caster:AddAbility("nevermore_necromastery")
            necromastery:SetHidden(true)
            necromastery:SetLevel(1)
        end
    end
end
--------------------------------------------------------------------------------------------------------
