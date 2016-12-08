--------------------------------------------------------------------------------------------------------
--
--		Hero: Slardar
--		Perk: Slardar gets 1 gold whenever he bashes a unit.
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_slardar_perk", "abilities/hero_perks/npc_dota_hero_slardar_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
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
  self:GetParent().bashGold = 1
end

function perkSlardar(filterTable)
  local parent_index = filterTable["entindex_parent_const"]
  local caster_index = filterTable["entindex_caster_const"]
  local ability_index = filterTable["entindex_ability_const"]
  if not parent_index or not caster_index or not ability_index then
    return true
  end
  local parent = EntIndexToHScript( parent_index )
  local caster = EntIndexToHScript( caster_index )
  local ability = EntIndexToHScript( ability_index )
  if ability then
    if caster:HasModifier("modifier_npc_dota_hero_slardar_perk") then
      if ability:HasAbilityFlag("bash") and parent ~= caster then
        --SendOverheadEventMessage( nil, OVERHEAD_ALERT_GOLD  , caster, caster.bashGold, nil )
        caster:PopupNumbers(caster, "gold", Vector(255, 215, 0), 2.0, caster.bashGold, 0, nil)
        caster:ModifyGold(caster.bashGold,true,DOTA_ModifyGold_Unspecified)
      end
    end  
  end
end
