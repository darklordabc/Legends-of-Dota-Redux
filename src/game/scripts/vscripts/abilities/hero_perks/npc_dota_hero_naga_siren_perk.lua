--------------------------------------------------------------------------------------------------------
--
--		Hero: Naga Siren
--		Perk: Illusion creating abilities will have 50% of their mana refunded and cooldowns reduced by 20%.
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_naga_siren_perk", "abilities/hero_perks/npc_dota_hero_naga_siren_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_naga_siren_perk ~= "" then npc_dota_hero_naga_siren_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_npc_dota_hero_naga_siren_perk				
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_naga_siren_perk ~= "" then modifier_npc_dota_hero_naga_siren_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_naga_siren_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_naga_siren_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_naga_siren_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_naga_siren_perk:RemoveOnDeath()
	return false
end
--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_naga_siren_perk:DeclareFunctions()
  local funcs = {
    MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
  }
  return funcs
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_naga_siren_perk:GetModifierIncomingDamage_Percentage(keys)
  if self:GetParent():IsIllusion() then
    return -25
  end
end

--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_naga_siren_perk:OnCreated()
  if IsServer and not self:GetParent():IsIllusion() then
    ListenToGameEvent('npc_spawned', function(keys)
      local unit = EntIndexToHScript(keys.entindex)
      if unit:GetUnitName() == self:GetParent():GetUnitName() and unit:GetPlayerOwner() == self:GetParent():GetPlayerOwner() then
        unit:AddNewModifier(unit,self:GetAbility(),"modifier_npc_dota_hero_naga_siren_perk",{})
      end
    end,nil)
  end
end