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
function modifier_npc_dota_hero_meepo_perk:AllowIllusionDuplicate()
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
	MODIFIER_EVENT_ON_HERO_KILLED  
	}
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_meepo_perk:GetModifierTotalDamageOutgoing_Percentage(keys)
	local caster = self:GetCaster()
	local heroes = HeroList:GetAllHeroes()

	local otherMeepos = 0
	for _, hero in pairs(heroes) do
		if hero ~= caster and hero:HasModifier("modifier_npc_dota_hero_meepo_perk") and hero:IsRealHero() and hero:IsAlive() and hero:GetTeamNumber() == caster:GetTeamNumber() then
			otherMeepos = otherMeepos + 1
		end
	end
	return otherMeepos * self.bonusPerMeepo
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_meepo_perk:OnHeroKilled(keys)
	local caster = self:GetCaster()
	local heroes = HeroList:GetAllHeroes()

	-- returns if killed hero doesnt have meepo perk or is illusion
	if not IsServer() or not keys.target:HasModifier("modifier_npc_dota_hero_meepo_perk") or keys.target:IsIllusion() then return false end
	
	-- if Meepo is alive and on the same team as killed Meepo, take 25% max health as damage
	if caster:IsAlive() and caster:IsRealHero() and caster:GetTeam() == keys.target:GetTeam() then
		local damage = {
			victim = caster,
			attacker = keys.attacker,
			damage = caster:GetMaxHealth() * 0.25,
			damage_type = DAMAGE_TYPE_PURE,
			damage_flags = DOTA_DAMAGE_FLAG_REFLECTION,
			ability = self:GetAbility()
		}
		ApplyDamage( damage )
	end
	return true
end
--------------------------------------------------------------------------------------------------------
