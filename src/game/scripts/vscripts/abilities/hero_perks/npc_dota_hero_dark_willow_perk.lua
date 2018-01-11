--------------------------------------------------------------------------------------------------------
--
--		Hero: Dark Willow
--		Perk: Dark Willow gains +2 to all stats for each level put in a support ability.
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_dark_willow_perk", "abilities/hero_perks/npc_dota_hero_dark_willow_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_dark_willow_perk ~= "" then npc_dota_hero_dark_willow_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_npc_dota_hero_dark_willow_perk		
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_dark_willow_perk ~= "" then modifier_npc_dota_hero_dark_willow_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_dark_willow_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_dark_willow_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_dark_willow_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_dark_willow_perk:RemoveOnDeath()
	return false
end
-- Add additional functions
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_dark_willow_perk:DeclareFunctions()
	return { 
	MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
	MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
	MODIFIER_PROPERTY_STATS_STRENGTH_BONUS  
	}
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_dark_willow_perk:OnCreated()
	self.bonusPerLevel = 2
	self.bonusAmount = 1
	if IsServer() then
		self:StartIntervalThink(0.1)
	end
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_dark_willow_perk:OnIntervalThink()
	if IsServer() then
		local caster = self:GetParent()
		for i=0, caster:GetAbilityCount() do
			local skill = caster:GetAbilityByIndex(i)
			if skill and skill:HasAbilityFlag("support") then
				if not skill.perkLevel then skill.perkLevel = skill:GetLevel() end
				if skill:GetLevel() > skill.perkLevel then
					local increase = (skill:GetLevel()  - skill.perkLevel)
					increase = increase * self.bonusPerLevel
					local stacks = self:GetStackCount()
					self:SetStackCount(stacks + increase)
					skill.perkLevel = skill:GetLevel()
				end
			end
		end
	end
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_dark_willow_perk:GetModifierBonusStats_Intellect(params)
	return self.bonusAmount * self:GetStackCount()
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_dark_willow_perk:GetModifierBonusStats_Agility(params)
	return self.bonusAmount * self:GetStackCount()
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_dark_willow_perk:GetModifierBonusStats_Strength(params)
	return self.bonusAmount * self:GetStackCount()
end
--------------------------------------------------------------------------------------------------------

