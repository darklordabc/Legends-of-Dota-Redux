--------------------------------------------------------------------------------------------------------
--
--		Hero: Dawnbreaker
--		Perk: Dawnbreaker gains 1.5% self healing and regen amplification for every level of Light spells she has.
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_dawnbreaker_perk", "abilities/hero_perks/npc_dota_hero_dawnbreaker_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_dawnbreaker_perk ~= "" then npc_dota_hero_dawnbreaker_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_dawnbreaker_perk				
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_dawnbreaker_perk ~= "" then modifier_npc_dota_hero_dawnbreaker_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_dawnbreaker_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_dawnbreaker_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_dawnbreaker_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_dawnbreaker_perk:RemoveOnDeath()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_dawnbreaker_perk:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_HP_REGEN_AMPLIFY_PERCENTAGE,
	}
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_dawnbreaker_perk:OnCreated()
	self.bonusPerLevel = 2.0
	self.bonusAmount = 1
	if IsServer() then
		self:StartIntervalThink(0.1)
	end
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_dawnbreaker_perk:OnIntervalThink()
	if IsServer() then
		local caster = self:GetParent()
		for i=0, caster:GetAbilityCount() do
			local skill = caster:GetAbilityByIndex(i)
			if skill and skill:HasAbilityFlag("light") then
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
function modifier_npc_dota_hero_dawnbreaker_perk:GetModifierHPRegenAmplify_Percentage(params)
	return self.bonusAmount * self:GetStackCount()
end
--------------------------------------------------------------------------------------------------------
