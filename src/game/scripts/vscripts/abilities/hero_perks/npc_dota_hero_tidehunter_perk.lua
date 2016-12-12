--------------------------------------------------------------------------------------------------------
--
--		Hero: Tidehunter
--		Perk: Refreshes Ravage when Tidehunter dies. 
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_tidehunter_perk", "abilities/hero_perks/npc_dota_hero_tidehunter_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_tidehunter_perk ~= "" then npc_dota_hero_tidehunter_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_npc_dota_hero_tidehunter_perk				
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_tidehunter_perk ~= "" then modifier_npc_dota_hero_tidehunter_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_tidehunter_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_tidehunter_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_tidehunter_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_tidehunter_perk:RemoveOnDeath()
	return false
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_tidehunter_perk:DeclareFunctions()
  local funcs = {
    MODIFIER_EVENT_ON_DEATH,
  }
  return funcs
end

function modifier_npc_dota_hero_tidehunter_perk:OnDeath(keys)
  if IsServer() then
    local caster = self:GetParent()
    if caster == keys.unit and caster:HasAbility("tidehunter_ravage") then
      caster:FindAbilityByName("tidehunter_ravage"):EndCooldown()
    end
  end
end

