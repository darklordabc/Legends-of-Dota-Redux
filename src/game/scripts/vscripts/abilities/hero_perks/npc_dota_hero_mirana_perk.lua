--------------------------------------------------------------------------------------------------------
--
--    Hero: Mirana
--    Perk: When Mirana casts Skillshots, they will have 50% mana refunded and cooldowns reduced by 20%.
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_mirana_perk", "abilities/hero_perks/npc_dota_hero_mirana_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_mirana_perk ~= "" then npc_dota_hero_mirana_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--    Modifier: modifier_npc_dota_hero_mirana_perk        
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_mirana_perk ~= "" then modifier_npc_dota_hero_mirana_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_mirana_perk:IsPassive()
  return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_mirana_perk:IsHidden()
  return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_mirana_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_mirana_perk:RemoveOnDeath()
	return false
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_mirana_perk:DeclareFunctions()
  local funcs = {
    MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
  }
  return funcs
end

function modifier_npc_dota_hero_mirana_perk:OnAbilityFullyCast(keys)
  if IsServer() then

    local manaRefund = 50
    local cooldownReduction = 20

    manaRefund = 1 -(manaRefund * 0.01)
    cooldownReduction = 1 - (cooldownReduction * 0.01)

    if keys.ability:HasAbilityFlag("skillshot") and keys.unit == self:GetParent() then
      local cooldown = keys.ability:GetCooldownTimeRemaining()
      keys.ability:EndCooldown()
      keys.ability:StartCooldown(cooldown*cooldownReduction)
      self:GetParent():GiveMana(keys.ability:GetManaCost(keys.ability:GetLevel()-1)*manaRefund)
    end
  end
end
