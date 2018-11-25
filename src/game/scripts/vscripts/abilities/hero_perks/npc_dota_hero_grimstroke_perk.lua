--------------------------------------------------------------------------------------------------------
--
--		Hero: grimstroke
--		Perk: Spells with 800 range or more deal 15% extra damage.
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_grimstroke_perk", "abilities/hero_perks/npc_dota_hero_grimstroke_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_grimstroke_perk ~= "" then npc_dota_hero_grimstroke_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_npc_dota_hero_grimstroke_perk				
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_grimstroke_perk ~= "" then modifier_npc_dota_hero_grimstroke_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_grimstroke_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_grimstroke_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_grimstroke_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_grimstroke_perk:RemoveOnDeath()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_grimstroke_perk:OnCreated()
  if IsServer() then
    self.range = 800
    self.amp = 15
  end
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------

function modifier_npc_dota_hero_grimstroke_perk:DeclareFunctions()
  local funcs = {
    MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE ,
  }
  return funcs
end

function modifier_npc_dota_hero_grimstroke_perk:GetModifierSpellAmplify_Percentage(keys)
  if IsServer() then
    local hero = self:GetCaster()
    local unit = keys.attacker
    local ability = keys.ability

    if not hero == unit then return 0 end

    if ability and ability:GetCastRange(nil,nil) >= self.range then
      return self.amp
    end

  end
end
