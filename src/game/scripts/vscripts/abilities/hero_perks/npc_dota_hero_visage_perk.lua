--------------------------------------------------------------------------------------------------------
--
--      Hero: Visage
--      Perk: Summon Familiars will refund 100% of manacost and have its cooldown reduced by 50%.
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_visage_perk", "abilities/hero_perks/npc_dota_hero_visage_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_visage_perk == nil then npc_dota_hero_visage_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--      Modifier: modifier_npc_dota_hero_visage_perk                
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_visage_perk == nil then modifier_npc_dota_hero_visage_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_visage_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_visage_perk:IsHidden()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_visage_perk:OnCreated(keys)
	self.cooldownPercentReduction = 50
	self.cooldownReduction = 1-(self.cooldownPercentReduction / 100)
	return true
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_visage_perk:DeclareFunctions()
  local funcs = {
	MODIFIER_EVENT_ON_ABILITY_FULLY_CAST
  }
  return funcs
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_visage_perk:OnAbilityFullyCast(keys)
  if IsServer() then
	local hero = self:GetCaster()
	local target = keys.target
	local ability = keys.ability
	if hero == keys.unit and ability:GetName() == "visage_summon_familiars" then
	  ability:RefundManaCost()
	  ability:EndCooldown()
	  ability:StartCooldown(ability:GetCooldown(ability:GetLevel() - 1) * self.cooldownReduction)
	end
  end
end
