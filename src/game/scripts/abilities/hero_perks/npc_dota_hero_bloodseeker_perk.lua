--------------------------------------------------------------------------------------------------------
--
--		Hero: Bloodseeker
--		Perk: When this hero casts Rupture, 100% of the mana cost will be refunded and cooldown reduced by 20%.
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_bloodseeker_perk", "abilities/hero_perks/npc_dota_hero_bloodseeker_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_bloodseeker_perk == nil then npc_dota_hero_bloodseeker_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_npc_dota_hero_bloodseeker_perk				
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_bloodseeker_perk == nil then modifier_npc_dota_hero_bloodseeker_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_bloodseeker_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_bloodseeker_perk:IsHidden()
	return true
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_bloodseeker_perk:DeclareFunctions()
  local funcs = {
    MODIFIER_EVENT_ON_ABILITY_START,
  }
  return funcs
end

function modifier_npc_dota_hero_bloodseeker_perk:OnAbilityStart(keys)
  if IsServer() then
    local hero = self:GetCaster()
    local target = keys.target
    local ability = keys.ability


    if ability:GetName() == "bloodseeker_rupture" then
      ability:RefundManaCost()
      ability:EndCooldown()
      ability:StartCooldown(ability:GetCooldown(ability:GetLevel()-1)*0.8)
    end
  end
end
