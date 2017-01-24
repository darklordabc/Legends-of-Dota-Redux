--------------------------------------------------------------------------------------------------------
--
--    Hero: Disruptor
--    Perk: Reduces the cooldown of Movement-Blocking abilities by 30% when cast by Disruptor.
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_disruptor_perk", "abilities/hero_perks/npc_dota_hero_disruptor_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_disruptor_perk ~= "" then npc_dota_hero_disruptor_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--    Modifier: modifier_npc_dota_hero_disruptor_perk        
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_disruptor_perk ~= "" then modifier_npc_dota_hero_disruptor_perk = class({}) end
--------------------------------------------------------------------------------------------------------
if IsServer() then
    function modifier_npc_dota_hero_disruptor_perk:OnCreated()
        self:StartIntervalThink(1.0)
        self:OnIntervalThink()
    end

    function modifier_npc_dota_hero_disruptor_perk:OnIntervalThink()
        local hero = self:GetParent()
        local maxMana = hero:GetMaxMana()
        local mana = hero:GetMana()

        local stacks = 10 - math.floor((mana / maxMana) * 10)

        self:SetStackCount(stacks)
    end
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_disruptor_perk:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MANA_REGEN_CONSTANT
    }

    return funcs
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_disruptor_perk:GetModifierConstantManaRegen()
    return 0.5 * self:GetStackCount()
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_disruptor_perk:IsPurgable()
  return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_disruptor_perk:GetAttributes()
  return MODIFIER_ATTRIBUTE_PERMANENT + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_disruptor_perk:IsPassive()
  return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_disruptor_perk:IsHidden()
  return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_disruptor_perk:RemoveOnDeath()
  return true
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------

