--------------------------------------------------------------------------------------------------------
--
--		Hero: Meepo
--		Perk: Increases all damage by 5% for every other Meepo on your team. Takes 25% max health as damage whenever a Meepo dies. 
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_meepo_perk", "abilities/hero_perks/npc_dota_hero_meepo_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_meepo_perk == nil then npc_dota_hero_meepo_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_npc_dota_hero_meepo_perk				
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_meepo_perk == nil then modifier_npc_dota_hero_meepo_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_meepo_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_meepo_perk:IsHidden()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_meepo_perk:RemoveOnDeath()
	return false
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_meepo_perk:OnCreated(keys)
	self.bonusPerMeepo = 5
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_meepo_perk:DeclareFunctions()
	return { 
	MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE, 
	MODIFIER_EVENT_ON_DEATH  
	}
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_meepo_perk:GetModifierTotalDamageOutgoing_Percentage(keys)
	local caster = self:GetCaster()
	local heroes = HeroList:GetAllHeroes()

	local otherMeepos = 0
	for _, hero in pairs(heroes) do
		if hero ~= caster and hero:HasModifier("modifier_npc_dota_hero_meepo_perk") and hero:GetTeamNumber() == caster:GetTeamNumber() then
			otherMeepos = otherMeepos + 1
		end
	end
	return otherMeepos * self.bonusPerMeepo
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_meepo_perk:OnDeath(keys)
	local caster = self:GetCaster()
	local heroes = HeroList:GetAllHeroes()
	if not keys.unit:HasModifier("modifier_npc_dota_hero_meepo_perk") then return false end

	if not caster:IsAlive() then
		for _, hero in pairs(heroes) do
			if hero ~= caster and hero:HasModifier("modifier_npc_dota_hero_meepo_perk") and hero:GetTeamNumber() == keys.unit:GetTeamNumber() then
				local healthDamage = hero:GetMaxHealth() * 0.25
				local damage = {
					victim = hero,
					attacker = keys.attacker,
					damage = healthDamage,
					damage_type = DAMAGE_TYPE_PURE,
					damage_flags = DOTA_DAMAGE_FLAG_REFLECTION,
					ability = self:GetAbility()
				}
				ApplyDamage( damage )
			end
		end
	end
	return true
end
--------------------------------------------------------------------------------------------------------
