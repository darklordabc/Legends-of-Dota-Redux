--------------------------------------------------------------------------------------------------------
--
--		Hero: Enigma
--		Perk: When Enigma dies, Black Hole's cooldown will be refreshed.
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_enigma_perk", "abilities/hero_perks/npc_dota_hero_enigma_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_enigma_perk ~= "" then npc_dota_hero_enigma_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_npc_dota_hero_enigma_perk				
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_enigma_perk ~= "" then modifier_npc_dota_hero_enigma_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_enigma_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_enigma_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_enigma_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_enigma_perk:RemoveOnDeath()
	return false
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_enigma_perk:DeclareFunctions()
  local funcs = {
    MODIFIER_EVENT_ON_DEATH,
  }
  return funcs
end

function modifier_npc_dota_hero_enigma_perk:OnDeath(keys)
  if IsServer() then
    local caster = self:GetParent()
    if caster == keys.unit and caster:HasAbility("enigma_black_hole") then
      caster:FindAbilityByName("enigma_black_hole"):EndCooldown() 
    end
  end
end

