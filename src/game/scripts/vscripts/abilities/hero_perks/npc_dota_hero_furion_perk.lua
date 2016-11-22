--------------------------------------------------------------------------------------------------------
--
--		Hero: Nature's Prophet
--		Perk: Reduces the cooldown of all Teleportation abilities by 50%. 
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_furion_perk", "abilities/hero_perks/npc_dota_hero_furion_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_furion_perk ~= "" then npc_dota_hero_furion_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_npc_dota_hero_furion_perk				
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_furion_perk ~= "" then modifier_npc_dota_hero_furion_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_furion_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_furion_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_furion_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_furion_perk:RemoveOnDeath()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_furion_perk:OnCreated()
  if IsServer() then
    local cooldownReductionPercent = 50
    self.cooldownReduction = 1 - (cooldownReductionPercent / 100)
  end
  return true
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_furion_perk:DeclareFunctions()
  local funcs = {
    MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
  }
  return funcs
end

function modifier_npc_dota_hero_furion_perk:OnAbilityFullyCast(keys)
  if IsServer() then
    local hero = self:GetCaster()
    local target = keys.target
    local ability = keys.ability

    if hero == keys.unit and ability and ability:HasAbilityFlag("teleport") then
      local cooldown = ability:GetCooldownTimeRemaining() * self.cooldownReduction
      ability:EndCooldown()
      ability:StartCooldown(cooldown)
    end
  end
end
