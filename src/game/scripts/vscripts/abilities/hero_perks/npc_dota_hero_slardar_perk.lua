--------------------------------------------------------------------------------------------------------
--
--		Hero: Slardar
--		Perk: Physical damage dealt by Slarder is increased by 50%
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_slardar_perk", "abilities/hero_perks/npc_dota_hero_slardar_perk.lua", LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_slardar_perk ~= "" then npc_dota_hero_slardar_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_npc_dota_hero_slardar_perk				
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_slardar_perk ~= "" then modifier_npc_dota_hero_slardar_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_slardar_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_slardar_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_slardar_perk:IsPurgable()
	return false
end

function modifier_npc_dota_hero_slardar_perk:RemoveOnDeath()
  return false
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_slardar_perk:OnCreated()
  if IsServer() then
  end
end

function perkSlardar(filterTable)
  local victim_index = filterTable["entindex_victim_const"]
  local attacker_index = filterTable["entindex_attacker_const"]
  local ability_index = filterTable["entindex_inflictor_const"]
  if not victim_index or not attacker_index or not ability_index then
    return filterTable
  end
  local victim = EntIndexToHScript( victim_index )
  local attacker = EntIndexToHScript( attacker_index )
  local ability = EntIndexToHScript( ability_index )
  local damageType = filterTable.damagetype_const

  if ability and attacker:HasModifier("modifier_npc_dota_hero_slardar_perk") then
    if damageType == DAMAGE_TYPE_PHYSICAL then
      filterTable.damage = filterTable.damage * 1.25
    end
  end
  return filterTable
end
