--------------------------------------------------------------------------------------------------------
--
--      Hero: Monkey King
--      Perk: Monkey King has Mischief​ as an innate ability
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_monkey_king_perk", "abilities/hero_perks/npc_dota_hero_monkey_king_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_monkey_king_perk ~= "" then npc_dota_hero_monkey_king_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--      Modifier: modifier_npc_dota_hero_monkey_king_perk             
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_monkey_king_perk ~= "" then modifier_npc_dota_hero_monkey_king_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_monkey_king_perk:IsPassive()
    return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_monkey_king_perk:IsHidden()
    return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_monkey_king_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_monkey_king_perk:RemoveOnDeath()
    return false
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_monkey_king_perk:OnCreated(keys)
    if IsServer() then
        local caster = self:GetCaster()
        local Mischief​ = caster:FindAbilityByName("monkey_king_mischief")

        if Mischief​ then
            Mischief​:UpgradeAbility(false)
        else 
            Mischief​ = caster:AddAbility("monkey_king_mischief")
            caster:AddAbility("monkey_king_untransform")
            Mischief​:SetHidden(false)
            Mischief​:SetLevel(1)
        end
    end
end
--------------------------------------------------------------------------------------------------------
