--------------------------------------------------------------------------------------------------------
--
--		Hero: Undying
--		Perk: Undying gains +1 strength per creep death or +4 strength per hero death in a 900 radius for 30 seconds.
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_undying_perk", "abilities/hero_perks/npc_dota_hero_undying_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_npc_dota_hero_undying_perk_aura", "abilities/hero_perks/npc_dota_hero_undying_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_undying_perk ~= "" then npc_dota_hero_undying_perk = class({}) end

function npc_dota_hero_undying_perk:GetIntrinsicModifierName()
	return "modifier_npc_dota_hero_undying_perk"
end
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_npc_dota_hero_undying_perk				
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_undying_perk ~= "" then modifier_npc_dota_hero_undying_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_undying_perk:IsPassive()
	return true
end

function modifier_npc_dota_hero_undying_perk:OnCreated()
	self.radius = 900
	self:GetAbility().creepStr = 1
	self:GetAbility().heroStr = 4
	self.expireTime = 30
	self:GetParent().strTable = {}
	if IsServer() then
		self:StartIntervalThink(0.1)
	end
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_undying_perk:IsPurgable()
	return false
end

function modifier_npc_dota_hero_undying_perk:OnRefresh()
	self:GetParent().strTable = {}
end

function modifier_npc_dota_hero_undying_perk:OnIntervalThink()
	if #self:GetParent().strTable > 0 then
		for i = #self:GetParent().strTable, 1, -1 do
			if self:GetParent().strTable[i] + self.expireTime < GameRules:GetGameTime() then
				table.remove(self:GetParent().strTable, i)
				
			end
		end
		self:SetStackCount(#self:GetParent().strTable)
		if #self:GetParent().strTable == 0 then
			self:SetDuration(-1,true)
		end
		self:GetParent():CalculateStatBonus()
	else
		self:SetDuration(-1,true)
	end
end

--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_undying_perk:IsHidden()
	return false
end

function modifier_npc_dota_hero_undying_perk:IsAura()
	if self:GetCaster():IsRealHero() then
		return true
	else return false end
end

function modifier_npc_dota_hero_undying_perk:DeclareFunctions()
  local funcs = {
    MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
  }
  return funcs
end

function modifier_npc_dota_hero_undying_perk:DestroyOnExpire()
	return false
end

function modifier_npc_dota_hero_undying_perk:GetModifierAura()
	return "modifier_npc_dota_hero_undying_perk_aura"
end

function modifier_npc_dota_hero_undying_perk:GetAuraRadius()
	return self.radius
end

function modifier_npc_dota_hero_undying_perk:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS
end

function modifier_npc_dota_hero_undying_perk:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_npc_dota_hero_undying_perk:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_npc_dota_hero_undying_perk:GetModifierBonusStats_Strength()
	return self:GetStackCount()
end

--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------


--------------------------------------------------------------------------------------------------------
--		Aura Modifier: modifier_npc_dota_hero_undying_perk_aura		
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_undying_perk_aura ~= "" then modifier_npc_dota_hero_undying_perk_aura = class({}) end

function modifier_npc_dota_hero_undying_perk_aura:IsHidden()
	return true
end

function modifier_npc_dota_hero_undying_perk_aura:DeclareFunctions()
  local funcs = {
    MODIFIER_EVENT_ON_DEATH,
  }
  return funcs
end

function modifier_npc_dota_hero_undying_perk_aura:OnDeath(params)
	if IsServer() and params.unit:HasModifier("modifier_npc_dota_hero_undying_perk_aura") and params.unit == self:GetParent() then
		local trigger = 1
		if params.unit:IsRealHero() then
			trigger = 4
		end
		for i = 1, trigger do
			local modifier = self:GetCaster():FindModifierByName("modifier_npc_dota_hero_undying_perk")
			if not modifier then return end
			modifier:SetDuration(modifier.expireTime, true)
			table.insert(self:GetCaster().strTable, GameRules:GetGameTime())
		end
	end
end
