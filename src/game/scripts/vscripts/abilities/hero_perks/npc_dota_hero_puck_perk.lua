--------------------------------------------------------------------------------------------------------
--
--    Hero: puck
--    Perk: 
--
--------------------------------------------------------------------------------------------------------
--LinkLuaModifier( "modifier_npc_dota_hero_puck_perk", "scripts/vscripts/../abilities/hero_perks/npc_dota_hero_puck_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_puck_perk == nil then npc_dota_hero_puck_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--    Modifier: modifier_npc_dota_hero_puck_perk        
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_puck_perk == nil then modifier_npc_dota_hero_puck_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_puck_perk:IsPassive()
  return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_puck_perk:IsHidden()
  return false
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_puck_perk:DeclareFunctions()
    local funcs = {
        --MODIFIER_PROPERTY_ABSORB_SPELL,
        MODIFIER_EVENT_ON_PROJECTILE_DODGE,
    }
    return funcs
end

function modifier_npc_dota_hero_puck_perk:OnProjectileDodge(keys)
  if IsServer() then
    if keys.ranged_attack == false then
      local random = RandomInt(1,4) 
      if random == 1 then
        local hCaster = self:GetParent()
        if hCaster:HasAbility(hCaster.perkAbility:GetAbilityName()) then
          hCaster:RemoveAbility(hCaster.perkAbility:GetAbilityName())
        end
        local hAbility = hCaster:AddAbility(hCaster.perkAbility:GetAbilityName())
        if hAbility then
          hAbility:SetStolen(true) 
          hAbility:SetHidden(true) 
          hAbility:SetLevel(hCaster.perkAbility:GetLevel())
          hCaster:SetCursorCastTarget(hCaster.perkTarget)
          hAbility:OnSpellStart()
        end
      end
    end
  end
end 
--------------------------------------------------------------------------------------------------------
-- This function gets called in the TrackingProjectileFilter, to be found in the ingame.lua file
--------------------------------------------------------------------------------------------------------

function PerkPuckReflectSpell(hCaster,hTarget,hAbility) -- hCaster = the caster of the spell, not the dodging unit that is hTarget
  if hTarget:HasModifier("modifier_npc_dota_hero_puck_perk") then
    hTarget.perkTarget = hCaster
    hTarget.perkAbility = hAbility
  end
end

