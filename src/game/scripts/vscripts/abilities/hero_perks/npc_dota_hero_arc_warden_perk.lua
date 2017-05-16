--------------------------------------------------------------------------------------------------------
--
--		Hero: Arc Warden
--		Perk: Arc Warden may use a consumable item on himself every 90 seconds without consuming the item. 
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_arc_warden_perk", "abilities/hero_perks/npc_dota_hero_arc_warden_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_npc_dota_hero_arc_warden_perk_downtime", "abilities/hero_perks/npc_dota_hero_arc_warden_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_arc_warden_perk ~= "" then npc_dota_hero_arc_warden_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_npc_dota_hero_arc_warden_perk				
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_arc_warden_perk ~= "" then modifier_npc_dota_hero_arc_warden_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_arc_warden_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_arc_warden_perk:IsHidden()
	return self:GetCaster():HasModifier("modifier_npc_dota_hero_arc_warden_perk_downtime")
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_arc_warden_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_arc_warden_perk:OnCreated(keys)
	self.downtime = 90
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_arc_warden_perk:RemoveOnDeath()
	return false
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_arc_warden_perk:DeclareFunctions()
  local funcs = {
	MODIFIER_EVENT_ON_ABILITY_FULLY_CAST
  }
  return funcs
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_arc_warden_perk:OnAbilityFullyCast(keys)
  if IsServer() then
	local hero = self:GetCaster()
	local target = keys.target
	local ability = keys.ability

	if hero == keys.unit and ability and ability:HasAbilityFlag("self_consumable") and not hero:HasModifier("modifier_npc_dota_hero_arc_warden_perk_downtime") then
	  if target and not target:HasModifier("modifier_npc_dota_hero_arc_warden_perk") then return end

	  -- Adds item
	  local item = CreateItem(ability:GetAbilityName(), hero, hero)
	  hero:AddItem(item)

	  -- Effects
	  hero:EmitSound("Hero_Zuus.ArcLightning.Cast")
	  local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_stormspirit/stormspirit_ball_lightning_end.vpcf", PATTACH_OVERHEAD_FOLLOW, hero)
	  ParticleManager:SetParticleControl(particle, 0, hero:GetAbsOrigin())

	  -- If Tome of Knowledge used, this perk has double cooldown length
	  local cooldown = self.downtime
	  if ability:GetAbilityName() == "item_tome_of_knowledge" then
	  	cooldown = cooldown * 2
	  end
	  
	  -- Adds modifier
	  hero:AddNewModifier(hero, nil, "modifier_npc_dota_hero_arc_warden_perk_downtime", {Duration = cooldown})
  	end
  end
end
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_npc_dota_hero_arc_warden_perk_downtime				
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_arc_warden_perk_downtime ~= "" then modifier_npc_dota_hero_arc_warden_perk_downtime = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_arc_warden_perk_downtime:GetTexture()
	return "arc_warden_flux"
end

function modifier_npc_dota_hero_arc_warden_perk_downtime:RemoveOnDeath()
	return false
end
--------------------------------------------------------------------------------------------------------
