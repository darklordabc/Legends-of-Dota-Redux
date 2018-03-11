--------------------------------------------------------------------------------------------------------
--
--		Hero: Troll Warlord
--		Perk: Increases the duration of all Rage effects on Troll Warlord by 20%. 
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_troll_warlord_perk", "abilities/hero_perks/npc_dota_hero_troll_warlord_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_troll_warlord_perk ~= "" then npc_dota_hero_troll_warlord_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_npc_dota_hero_troll_warlord_perk				
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_troll_warlord_perk ~= "" then modifier_npc_dota_hero_troll_warlord_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_troll_warlord_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_troll_warlord_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_troll_warlord_perk:RemoveOnDeath()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_troll_warlord_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_troll_warlord_perk:OnCreated()
	if IsServer() then
		local rageDurationBonusPct = 20
		self:GetCaster().rageDurationBonus = (rageDurationBonusPct / 100)
	end
	return true
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------
function perkTrollWarlord(filterTable)
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
    if caster:HasModifier("modifier_npc_dota_hero_troll_warlord_perk") then
      if ability:HasAbilityFlag("rage") and filterTable["duration"] ~= -1 then
        local modifierDuration = filterTable["duration"]
        local bonusDuration = modifierDuration + (modifierDuration * caster.rageDurationBonus)
        filterTable["duration"] = bonusDuration
      end
    end  
  end
end
