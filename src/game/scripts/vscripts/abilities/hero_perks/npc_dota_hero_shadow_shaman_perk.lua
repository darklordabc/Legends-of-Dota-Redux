--------------------------------------------------------------------------------------------------------
--
--    Hero: Shadow Shaman
--    Perk: All hexes get an instant refund in their manacosts and cooldowns get reduced by 20%
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_shadow_shaman_perk", "abilities/hero_perks/npc_dota_hero_shadow_shaman_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_shadow_shaman_perk ~= "" then npc_dota_hero_shadow_shaman_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--    Modifier: modifier_npc_dota_hero_shadow_shaman_perk       
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_shadow_shaman_perk ~= "" then modifier_npc_dota_hero_shadow_shaman_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_shadow_shaman_perk:IsPassive()
  return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_shadow_shaman_perk:IsHidden()
  return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_shadow_shaman_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_shadow_shaman_perk:RemoveOnDeath()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_shadow_shaman_perk:OnCreated()
  if IsServer() then
    local cooldownPercentReduction = 20
    self.cooldownReduction = 1 - (cooldownPercentReduction / 100)
  end
  return true
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------

function modifier_npc_dota_hero_shadow_shaman_perk:DeclareFunctions()
  local funcs = {
    MODIFIER_EVENT_ON_ABILITY_FULLY_CAST
  }
  return funcs
end

function modifier_npc_dota_hero_shadow_shaman_perk:OnAbilityFullyCast(keys)
  if IsServer() then
    local hero = self:GetCaster()
    local target = keys.target
    local ability = keys.ability
    if hero == keys.unit and ability and ability:HasAbilityFlag("hex") then
      local cooldown = ability:GetCooldownTimeRemaining() * self.cooldownReduction
      ability:RefundManaCost()
      ability:EndCooldown()
      ability:StartCooldown(cooldown)
    end
  end
end
