--------------------------------------------------------------------------------------------------------
--
--		Hero: Spirit Breaker
--		Perk: When Spirit Breaker bashes, he also applies Break.
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_spirit_breaker_perk", "abilities/hero_perks/npc_dota_hero_spirit_breaker_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_npc_dota_hero_spirit_breaker_perk_break", "abilities/hero_perks/npc_dota_hero_spirit_breaker_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_spirit_breaker_perk ~= "" then npc_dota_hero_spirit_breaker_perk = class({}) end

function npc_dota_hero_spirit_breaker_perk:GetIntrinsicModifierName()
    return "modifier_npc_dota_hero_spirit_breaker_perk"
end
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_npc_dota_hero_spirit_breaker_perk				
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_spirit_breaker_perk ~= "" then modifier_npc_dota_hero_spirit_breaker_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_spirit_breaker_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_spirit_breaker_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_spirit_breaker_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_spirit_breaker_perk:RemoveOnDeath()
	return false
end
--------------------------------------------------------------------------------------------------------
--    Modifier: modifier_npc_dota_hero_spirit_breaker_perk_break
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_spirit_breaker_perk_break ~= "" then modifier_npc_dota_hero_spirit_breaker_perk_break = class({}) end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_spirit_breaker_perk_break:CheckState()
  local state = {
    [MODIFIER_STATE_PASSIVES_DISABLED] = true,
  }
  return state
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_spirit_breaker_perk_break:IsPurgable(  )
  return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_spirit_breaker_perk_break:IsHidden()
  return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_spirit_breaker_perk_break:GetTexture()
  return "npc_dota_hero_spirit_breaker_perk"
end
--------------------------------------------------------------------------------------------------------
function perkSpaceCow(filterTable)  --ModifierGainedFilter
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
    if caster:HasModifier("modifier_npc_dota_hero_spirit_breaker_perk") then
      if ability:HasAbilityFlag("bash") and parent:GetTeamNumber() ~= caster:GetTeamNumber() then
        local modifierDuration = filterTable["duration"]
        local modifier = parent:AddNewModifier(caster, nil,"modifier_npc_dota_hero_spirit_breaker_perk_break",{duration = modifierDuration})
        local breakParticle = ParticleManager:CreateParticle("particles/items3_fx/silver_edge.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent)
        modifier:AddParticle(breakParticle, false, false, 1, false, false)
      end
    end  
  end  
end
