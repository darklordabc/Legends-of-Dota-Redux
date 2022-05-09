--------------------------------------------------------------------------------------------------------
--
--		Hero: Pugna
--		Perk: Drain spells will have 50% mana refunded and have 25% reduced cooldowns when cast by Pugna.
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_pugna_perk", "abilities/hero_perks/npc_dota_hero_pugna_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_pugna_perk ~= "" then npc_dota_hero_pugna_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_npc_dota_hero_pugna_perk				
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_pugna_perk ~= "" then modifier_npc_dota_hero_pugna_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_pugna_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_pugna_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_pugna_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_pugna_perk:RemoveOnDeath()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_pugna_perk:OnCreated()
	self.cooldownPercentReduction = 25
	self.manaPercentReduction = 50

	self.cooldownReduction = 1-(self.cooldownPercentReduction / 100)
	self.manaReduction = 1-(self.manaPercentReduction / 100)
	return true
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------

function modifier_npc_dota_hero_pugna_perk:DeclareFunctions()
  local funcs = {
    MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
  }
  return funcs
end

function modifier_npc_dota_hero_pugna_perk:OnAbilityFullyCast(params)
	if IsServer() and params.unit == self:GetParent() then
		if params.ability:HasAbilityFlag("drain") then
			local cooldown = params.ability:GetCooldownTimeRemaining() * self.cooldownReduction
			self:GetCaster():GiveMana(params.ability:GetManaCost(-1) * self.manaReduction)
			params.ability:EndCooldown()
			params.ability:StartCooldown(cooldown)
		end
	end
end
