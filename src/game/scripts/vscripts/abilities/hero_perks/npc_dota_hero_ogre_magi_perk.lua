--------------------------------------------------------------------------------------------------------
--
--      Hero: Ogre Magi
--      Perk: When Ogre Magi casts a spell, there is a 2% chance to refund the manacost of that spell and refresh its cooldown. 
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_ogre_magi_perk", "abilities/hero_perks/npc_dota_hero_ogre_magi_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_ogre_magi_perk ~= "" then npc_dota_hero_ogre_magi_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--      Modifier: modifier_npc_dota_hero_ogre_magi_perk             
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_ogre_magi_perk ~= "" then modifier_npc_dota_hero_ogre_magi_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_ogre_magi_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_ogre_magi_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_ogre_magi_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_ogre_magi_perk:RemoveOnDeath()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_ogre_magi_perk:OnCreated(keys)
	local caster = self:GetCaster()
	local bloodlust = caster:FindAbilityByName("ogre_magi_bloodlust")
	if not bloodlust then
		bloodlust = caster:AddAbility("ogre_magi_bloodlust")
		bloodlust:SetLevel(1)
		bloodlust:SetHidden(true)
	else
		bloodlust:SetLevel(1)
	end
	self.bloodlust = bloodlust
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_ogre_magi_perk:DeclareFunctions()
  local funcs = {
	MODIFIER_EVENT_ON_ABILITY_FULLY_CAST
  }
  return funcs
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_ogre_magi_perk:OnAbilityFullyCast(keys)
  if IsServer() then
	local hero = self:GetCaster()
	local target = keys.target
	local ability = keys.ability
	if hero == keys.unit and ability and ability:GetCooldown(-1) > 0 then
	  hero:SetCursorCastTarget(hero)
	  self.bloodlust:OnSpellStart()
	end
  end
end
