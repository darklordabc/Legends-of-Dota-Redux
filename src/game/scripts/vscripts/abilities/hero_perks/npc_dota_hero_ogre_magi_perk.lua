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
	self.refundChance = 2
	return true
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
	  local random = math.random(100)
	  if random <= self.refundChance then
		hero:EmitSound("DOTA_Item.Refresher.Activate")
		local particle = ParticleManager:CreateParticle("particles/items2_fx/refresher.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero)
		ParticleManager:SetParticleControl(particle, 0, hero:GetAbsOrigin())
		ability:RefundManaCost()
		ability:EndCooldown()
	  end
	end
  end
end
