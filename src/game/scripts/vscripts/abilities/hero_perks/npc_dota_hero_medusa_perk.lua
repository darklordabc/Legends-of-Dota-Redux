--------------------------------------------------------------------------------------------------------
--
--      Hero: Medusa
--      Perk: Medusa gains +0.5 mana regeneration per active Toggle effect. 
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_medusa_perk", "abilities/hero_perks/npc_dota_hero_medusa_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_medusa_perk ~= "" then npc_dota_hero_medusa_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--      Modifier: modifier_npc_dota_hero_medusa_perk                
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_medusa_perk ~= "" then modifier_npc_dota_hero_medusa_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_medusa_perk:IsPassive()
    return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_medusa_perk:IsHidden()
    return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_medusa_perk:IsPurgable()
    return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_medusa_perk:RemoveOnDeath()
    return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_medusa_perk:DeclareFunctions()
    return { MODIFIER_EVENT_ON_ATTACK_LANDED  }
end
--------------------------------------------------------------------------------------------------------

function modifier_npc_dota_hero_medusa_perk:OnAttackLanded(params)
    if self:GetParent() == params.attacker then
        self:GetParent():GiveMana(params.damage * 0.03)
    end
end