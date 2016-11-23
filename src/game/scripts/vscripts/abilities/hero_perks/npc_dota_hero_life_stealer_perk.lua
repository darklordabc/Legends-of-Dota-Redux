--------------------------------------------------------------------------------------------------------
--
--		Hero: Life Stealer
--		Perk: When Life Stealer casts Infest, its cooldown will be reduced to 30 seconds.
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_life_stealer_perk", "abilities/hero_perks/npc_dota_hero_life_stealer_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_life_stealer_perk ~= "" then npc_dota_hero_life_stealer_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_npc_dota_hero_life_stealer_perk				
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_life_stealer_perk ~= "" then modifier_npc_dota_hero_life_stealer_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_life_stealer_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_life_stealer_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_life_stealer_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_life_stealer_perk:RemoveOnDeath()
	return false
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_life_stealer_perk:DeclareFunctions()
  local funcs = {
    MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
  }
  return funcs
end

function modifier_npc_dota_hero_life_stealer_perk:OnAbilityFullyCast(keys)
  if IsServer() then
    local hero = self:GetCaster()
    local target = keys.target
    local ability = keys.ability

    if ability:GetName() == "life_stealer_infest" then
      ability:EndCooldown()
      ability:StartCooldown(30)
    end
  end
end
