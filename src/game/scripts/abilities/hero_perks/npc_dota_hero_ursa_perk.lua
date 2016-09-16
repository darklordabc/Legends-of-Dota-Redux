--------------------------------------------------------------------------------------------------------
--
--    Hero: ursa
--    Perk: Adds 10% to Ursa's damage output when attacking a neutral creep.
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_ursa_perk", "scripts/vscripts/../abilities/hero_perks/npc_dota_hero_ursa_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_ursa_perk == nil then npc_dota_hero_ursa_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--    Modifier: modifier_npc_dota_hero_ursa_perk        
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_ursa_perk == nil then modifier_npc_dota_hero_ursa_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_ursa_perk:IsPassive()
  return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_ursa_perk:IsHidden()
  return true
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_ursa_perk:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_ATTACK_START,
    }
    return funcs
end

function modifier_npc_dota_hero_ursa_perk:OnAttackStart(keys)
  local caster = keys.attacker
  local target = keys.target
  if target:IsNeutralUnitType() then
    caster:AddNewModifier(caster,nil,"modifier_npc_dota_hero_ursa_perk_extra_damage",{})
  else
    caster:RemoveModifierByName("modifier_npc_dota_hero_ursa_perk_extra_damage")
  end
end
--------------------------------------------------------------------------------------------------------
--    Modifier: modifier_npc_dota_hero_ursa_perk_extra_damage        
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_ursa_perk", "scripts/vscripts/../abilities/hero_perks/npc_dota_hero_ursa_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
if modifier_npc_dota_hero_ursa_perk_extra_damage == nil then modifier_npc_dota_hero_ursa_perk_extra_damage = class({}) end

function modifier_npc_dota_hero_ursa_perk_extra_damage:IsHidden()
  return true
end

--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_ursa_perk_extra_damage:DeclareFunctions()
    local funcs = {
      MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE,
      MODIFIER_PROPERTY_MAGICDAMAGEOUTGOING_PERCENTAGE,
    }
    return funcs
end

function modifier_npc_dota_hero_ursa_perk_extra_damage:GetModifierTotalDamageOutgoing_Percentage()
  return 10
end
function modifier_npc_dota_hero_ursa_perk_extra_damage:GetModifierMagicDamageOutgoing_Percentage()
  return -10
end
