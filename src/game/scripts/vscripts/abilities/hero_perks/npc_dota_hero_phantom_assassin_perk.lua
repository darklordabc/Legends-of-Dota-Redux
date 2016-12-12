--------------------------------------------------------------------------------------------------------
--
--		Hero: Phantom Assassin
--		Perk: Dagger spells will have 50% of their manacost refunded, and their cooldown reduced by 1 second. 
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_phantom_assassin_perk", "abilities/hero_perks/npc_dota_hero_phantom_assassin_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_phantom_assassin_perk ~= "" then npc_dota_hero_phantom_assassin_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_npc_dota_hero_phantom_assassin_perk				
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_phantom_assassin_perk ~= "" then modifier_npc_dota_hero_phantom_assassin_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_phantom_assassin_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_phantom_assassin_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_phantom_assassin_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_phantom_assassin_perk:RemoveOnDeath()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_phantom_assassin_perk:OnCreated(keys)
	self.cooldownBaseReduction = 2
	self.manaPercentReduction = 50

	self.manaReduction = self.manaPercentReduction / 100
	return true
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_phantom_assassin_perk:DeclareFunctions()
  local funcs = {
	MODIFIER_EVENT_ON_ABILITY_FULLY_CAST
  }
  return funcs
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_phantom_assassin_perk:OnAbilityFullyCast(keys)
  if IsServer() then
	local hero = self:GetCaster()
	local target = keys.target
	local ability = keys.ability
	if hero == keys.unit and ability and ability:HasAbilityFlag("dagger") then
	  hero:GiveMana(ability:GetManaCost(-1) * self.manaReduction)
	  if ability:GetCooldownTimeRemaining() > self.cooldownBaseReduction + 1 then
	  	local cooldown = ability:GetCooldownTimeRemaining() - self.cooldownBaseReduction
		ability:EndCooldown()
		ability:StartCooldown(cooldown)
	  else 
	  	ability:EndCooldown()
		ability:StartCooldown(1)
	  end
	end
  end
end
