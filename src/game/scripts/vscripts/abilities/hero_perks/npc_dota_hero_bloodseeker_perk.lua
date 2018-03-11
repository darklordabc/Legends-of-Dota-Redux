--------------------------------------------------------------------------------------------------------
--
--		Hero: Bloodseeker
--		Perk: When Bloodseeker casts Rupture, 100% of the mana cost will be refunded and cooldown reduced by 20%.
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_bloodseeker_perk", "abilities/hero_perks/npc_dota_hero_bloodseeker_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_bloodseeker_perk ~= "" then npc_dota_hero_bloodseeker_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_npc_dota_hero_bloodseeker_perk				
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_bloodseeker_perk ~= "" then modifier_npc_dota_hero_bloodseeker_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_bloodseeker_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_bloodseeker_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_bloodseeker_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_bloodseeker_perk:RemoveOnDeath()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_bloodseeker_perk:OnCreated()
  if IsServer() then
    local cooldownReductionPercent = 20
    self.cooldownReduction = 1 - (cooldownReductionPercent / 100)
  end
  return true
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------

function modifier_npc_dota_hero_bloodseeker_perk:DeclareFunctions()
  local funcs = {
    MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
  }
  return funcs
end

function modifier_npc_dota_hero_bloodseeker_perk:OnAbilityFullyCast(keys)
  if IsServer() then
    local hero = self:GetCaster()
    local unit = keys.unit
    local ability = keys.ability


    if hero == unit and ability:GetName() == "bloodseeker_rupture" then
      local cooldown = ability:GetCooldownTimeRemaining() * self.cooldownReduction
      ability:RefundManaCost()
      ability:EndCooldown()
      ability:StartCooldown(cooldown)
    end
  end
end
