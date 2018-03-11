--------------------------------------------------------------------------------------------------------
--
--		Hero: Sand King
--		Perk: Channeling abilities refund 30% of their manacost when cast by Sand King. 
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_sand_king_perk", "abilities/hero_perks/npc_dota_hero_sand_king_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_sand_king_perk ~= "" then npc_dota_hero_sand_king_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_npc_dota_hero_sand_king_perk				
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_sand_king_perk ~= "" then modifier_npc_dota_hero_sand_king_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_sand_king_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_sand_king_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_sand_king_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_sand_king_perk:RemoveOnDeath()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_sand_king_perk:OnCreated(keys)
	self.manaPercentReduction = 30
	self.manaReduction = self.manaPercentReduction / 100
	return true
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_sand_king_perk:DeclareFunctions()
  local funcs = {
	MODIFIER_EVENT_ON_ABILITY_FULLY_CAST
  }
  return funcs
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_sand_king_perk:OnAbilityFullyCast(keys)
  if IsServer() then
	local hero = self:GetCaster()
	local target = keys.target
	local ability = keys.ability
	if hero == keys.unit and ability and ability:HasAbilityFlag("channeled") then
	  hero:GiveMana(ability:GetManaCost(ability:GetLevel()-1) * self.manaReduction)
	end
  end
end
