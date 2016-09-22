--------------------------------------------------------------------------------------------------------
--
--		Hero: Zeus
--		Perk: Reduces the manacost of all Lightning spells by 20%. 
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_zuus_perk", "abilities/hero_perks/npc_dota_hero_zuus_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_zuus_perk == nil then npc_dota_hero_zuus_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_npc_dota_hero_zuus_perk				
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_zuus_perk == nil then modifier_npc_dota_hero_zuus_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_zuus_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_zuus_perk:IsHidden()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_zuus_perk:OnCreated(keys)
	self.cooldownPercentReduction = 20
	self.cooldownReduction = 1-(self.cooldownPercentReduction / 100)
	return true
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_zuus_perk:DeclareFunctions()
  local funcs = {
	MODIFIER_EVENT_ON_ABILITY_FULLY_CAST
  }
  return funcs
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_zuus_perk:OnAbilityFullyCast(keys)
  if IsServer() then
	local hero = self:GetCaster()
	local target = keys.target
	local ability = keys.ability
	if hero == keys.unit and ability and ability:HasAbilityFlag("lightning") then
	  ability:EndCooldown()
	  ability:StartCooldown(ability:GetCooldown(ability:GetLevel() - 1) * self.cooldownReduction)
	end
  end
end
