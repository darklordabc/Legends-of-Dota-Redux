--------------------------------------------------------------------------------------------------------
--
--		Hero: tidehunter
--		Perk: 
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_tidehunter_perk", "scripts/vscripts/../abilities/hero_perks/npc_dota_hero_tidehunter_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_tidehunter_perk == nil then npc_dota_hero_tidehunter_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_npc_dota_hero_tidehunter_perk				
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_tidehunter_perk == nil then modifier_npc_dota_hero_tidehunter_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_tidehunter_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_tidehunter_perk:IsHidden()
	return true
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

function modifier_npc_dota_hero_tidehunter_perk:OnDeath()
  if IsServer() then
    local caster = self:GetParent()
    if caster:HasAbility("tidehunter_ravage") then
      caster:FindAbilityByName("tidehunter_ravage"):EndCooldown()
    end
  end
end

