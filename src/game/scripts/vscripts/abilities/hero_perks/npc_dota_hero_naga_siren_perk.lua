--------------------------------------------------------------------------------------------------------
--
--		Hero: Naga Siren
--		Perk: Illusion creating abilities will have 50% of their mana refunded and cooldowns reduced by 20%.
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_naga_siren_perk", "abilities/hero_perks/npc_dota_hero_naga_siren_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_naga_siren_perk ~= "" then npc_dota_hero_naga_siren_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_npc_dota_hero_naga_siren_perk				
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_naga_siren_perk ~= "" then modifier_npc_dota_hero_naga_siren_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_naga_siren_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_naga_siren_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_naga_siren_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_naga_siren_perk:RemoveOnDeath()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_naga_siren_perk:OnCreated(keys)
	self.cooldownPercentReduction = 20
    self.manaPercentReduction = 50

    self.cooldownReduction = 1-(self.cooldownPercentReduction / 100)
    self.manaReduction = 1-(self.manaPercentReduction / 100)
	return true
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_naga_siren_perk:DeclareFunctions()
  local funcs = {
    MODIFIER_EVENT_ON_ABILITY_FULLY_CAST
  }
  return funcs
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_naga_siren_perk:OnAbilityFullyCast(keys)
  if IsServer() then
    local hero = self:GetCaster()
    local target = keys.target
    local ability = keys.ability
    if hero == keys.unit and ability and ability:HasAbilityFlag("illusion") then
      hero:GiveMana(ability:GetManaCost(ability:GetLevel() - 1) * self.manaReduction)
      local cooldown = ability:GetCooldownTimeRemaining() * self.cooldownReduction
      ability:EndCooldown()
      ability:StartCooldown(cooldown)
    end
  end
end
