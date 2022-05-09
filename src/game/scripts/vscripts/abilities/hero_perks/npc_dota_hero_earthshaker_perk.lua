--------------------------------------------------------------------------------------------------------
--
--		Hero: Earthshaker
--		Perk: Earth abilities Earthshaker uses heal him for 2% of his health.
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_earthshaker_perk", "abilities/hero_perks/npc_dota_hero_earthshaker_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_earthshaker_perk ~= "" then npc_dota_hero_earthshaker_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_npc_dota_hero_earthshaker_perk				
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_earthshaker_perk ~= "" then modifier_npc_dota_hero_earthshaker_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_earthshaker_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_earthshaker_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_earthshaker_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_earthshaker_perk:RemoveOnDeath()
	return false
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_earthshaker_perk:DeclareFunctions()
  local funcs = {
    MODIFIER_EVENT_ON_ABILITY_FULLY_CAST
  }
  return funcs
end

function modifier_npc_dota_hero_earthshaker_perk:OnAbilityFullyCast(keys)
  local healPercent = 3
  healPercent = 0.01 * healPercent

  if IsServer() then
	if self:GetParent():GetHealth() == self:GetParent():GetMaxHealth() then return end
    if keys.unit == self:GetParent() then
      if keys.ability:HasAbilityFlag("earth") then
        keys.unit:Heal(self:GetParent():GetMaxHealth() * healPercent ,keys.ability)
	SendOverheadEventMessage(keys.unit,OVERHEAD_ALERT_HEAL,keys.unit,keys.unit:GetMaxHealth() * healPercent,nil)
        local healParticle = ParticleManager:CreateParticle("particles/units/heroes/hero_bloodseeker/bloodseeker_bloodbath_heal.vpcf", PATTACH_ABSORIGIN_FOLLOW, keys.unit)
        ParticleManager:SetParticleControl(healParticle, 1, Vector(radius, radius, radius))
      end
    end
  end
end
