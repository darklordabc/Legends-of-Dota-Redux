--------------------------------------------------------------------------------------------------------
--
--		Hero: Treant
--		Perk: Treant gets healed for the mana cost of any Nature ability he uses.
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_treant_perk", "abilities/hero_perks/npc_dota_hero_treant_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_treant_perk ~= "" then npc_dota_hero_treant_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_npc_dota_hero_treant_perk				
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_treant_perk ~= "" then modifier_npc_dota_hero_treant_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_treant_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_treant_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_treant_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_treant_perk:RemoveOnDeath()
	return false
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_treant_perk:DeclareFunctions()
  local funcs = {
    MODIFIER_EVENT_ON_ABILITY_FULLY_CAST
  }
  return funcs
end

function modifier_npc_dota_hero_treant_perk:OnAbilityFullyCast(keys)

  if IsServer() then
	if self:GetParent():GetHealth() == self:GetParent():GetMaxHealth() then return end
    if keys.unit == self:GetParent() then
      if keys.ability:HasAbilityFlag("nature") then
        keys.unit:Heal(keys.ability:GetManaCost(keys.ability:GetLevel()-1) ,keys.ability)
	      SendOverheadEventMessage(keys.unit,OVERHEAD_ALERT_HEAL,keys.unit,keys.ability:GetManaCost(keys.ability:GetLevel()-1),nil)
        local healParticle = ParticleManager:CreateParticle("particles/units/heroes/hero_bloodseeker/bloodseeker_bloodbath_heal.vpcf", PATTACH_ABSORIGIN_FOLLOW, keys.unit)
        ParticleManager:SetParticleControl(healParticle, 1, Vector(radius, radius, radius))
      end
    end
  end
end
