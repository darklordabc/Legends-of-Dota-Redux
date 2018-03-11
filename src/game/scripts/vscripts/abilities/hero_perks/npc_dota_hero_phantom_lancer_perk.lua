--------------------------------------------------------------------------------------------------------
--
--		Hero: Phantom Lancer
--		Perk: Illusion creating abilities will have cooldowns reduced by 50%.
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_phantom_lancer_perk", "abilities/hero_perks/npc_dota_hero_phantom_lancer_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_phantom_lancer_perk ~= "" then npc_dota_hero_phantom_lancer_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_npc_dota_hero_phantom_lancer_perk				
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_phantom_lancer_perk ~= "" then modifier_npc_dota_hero_phantom_lancer_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_phantom_lancer_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_phantom_lancer_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_phantom_lancer_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_phantom_lancer_perk:RemoveOnDeath()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_phantom_lancer_perk:OnCreated(keys)
	self.cooldownPercentReduction = 50
    --self.manaPercentReduction = 0

    self.cooldownReduction = 1-(self.cooldownPercentReduction / 100)
    --self.manaReduction = 1-(self.manaPercentReduction / 100)
	return true
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_phantom_lancer_perk:DeclareFunctions()
  local funcs = {
    MODIFIER_EVENT_ON_ABILITY_FULLY_CAST
  }
  return funcs
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_phantom_lancer_perk:OnAbilityFullyCast(keys)
  if IsServer() then
    local hero = self:GetCaster()
    local target = keys.target
    local ability = keys.ability
    if hero == keys.unit and ability and ability:HasAbilityFlag("illusion") then
      --hero:GiveMana(ability:GetManaCost(ability:GetLevel() - 1) * self.manaReduction)
      local cooldown = ability:GetCooldownTimeRemaining() * self.cooldownReduction
      ability:EndCooldown()
      ability:StartCooldown(cooldown)
    end
  end
end
