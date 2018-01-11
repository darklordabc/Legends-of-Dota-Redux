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
        local Mischief​ = caster:FindAbilityByName("monkey_king_jingu_mastery_lod")
        local Mischief​B = caster:FindAbilityByName("monkey_king_jingu_mastery_lod_melee")

        if Mischief​B and not Mischief​ then
            Mischief​B:UpgradeAbility(false)
            Mischief​B:SetHidden(false)
        elseif Mischief​ and not Mischief​B then
            Mischief​:UpgradeAbility(false)
            Mischief​:SetHidden(false)
        else 
            Mischief​ = caster:AddAbility("monkey_king_jingu_mastery_lod")
            Mischief​:SetStolen(true)
            Mischief​:SetActivated(true)
            Mischief​:SetLevel(1)
        end

    end
end
--------------------------------------------------------------------------------------------------------
