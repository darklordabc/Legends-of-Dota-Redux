--------------------------------------------------------------------------------------------------------
--
--		Hero: Phantom Lancer
--		Perk: Illusion creating abilities will have cooldowns reduced by 50%.
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_phantom_lancer_perk", "abilities/hero_perks/npc_dota_hero_phantom_lancer_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_phantom_lancer_perk ~= "" then npc_dota_hero_phantom_lancer_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_npc_dota_hero_phantom_lancer_perk				
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_phantom_lancer_perk ~= "" then modifier_npc_dota_hero_phantom_lancer_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_phantom_lancer_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_phantom_lancer_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_phantom_lancer_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_phantom_lancer_perk:RemoveOnDeath()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_phantom_lancer_perk:DeclareFunctions()
  local funcs = {
    MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
  }
  return funcs
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_phantom_lancer_perk:GetModifierMoveSpeedBonus_Percentage(keys)
  if self:GetParent():IsIllusion() then
    return 40
  end
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_phantom_lancer_perk:OnCreated()
  if IsServer and not self:GetParent():IsIllusion() then
    ListenToGameEvent('npc_spawned', function(keys)
      local unit = EntIndexToHScript(keys.entindex)
      if unit and unit:GetUnitName() == self:GetParent():GetUnitName() and unit:GetPlayerOwner() == self:GetParent():GetPlayerOwner() then
        unit:AddNewModifier(unit,self:GetAbility(),"modifier_npc_dota_hero_phantom_lancer_perk",{})
      end
    end,nil)
  end
end
