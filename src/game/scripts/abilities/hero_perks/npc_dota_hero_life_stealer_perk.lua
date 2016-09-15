--------------------------------------------------------------------------------------------------------
--
--		Hero: Life Stealer
--		Perk: When this hero casts Infest, its cooldown will be reduced to 30 seconds.
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_life_stealer_perk", "scripts/vscripts/../abilities/hero_perks/npc_dota_hero_life_stealer_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_life_stealer_perk == nil then npc_dota_hero_life_stealer_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_npc_dota_hero_life_stealer_perk				
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_life_stealer_perk == nil then modifier_npc_dota_hero_life_stealer_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_life_stealer_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_life_stealer_perk:IsHidden()
	return true
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_life_stealer_perk:DeclareFunctions()
  local funcs = {
    MODIFIER_EVENT_ON_ABILITY_START,
  }
  return funcs
end

function modifier_npc_dota_hero_life_stealer_perk:OnAbilityStart(keys)
  if IsServer() then
    local hero = self:GetCaster()
    local target = keys.target
    local ability = keys.ability

    if ability:GetName() == "life_stealer_infest" then
      ability:EndCooldown()
      ability:StartCooldown(30)
    end
  end
end
