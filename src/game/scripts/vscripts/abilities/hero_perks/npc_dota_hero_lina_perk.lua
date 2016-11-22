--------------------------------------------------------------------------------------------------------
--
--		Hero: Lina
--		Perk: Increases Lina's intelligence by 3 for each level put in fire-type spells.
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_lina_perk", "abilities/hero_perks/npc_dota_hero_lina_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_lina_perk ~= "" then npc_dota_hero_lina_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_lina_perk				
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_lina_perk ~= "" then modifier_npc_dota_hero_lina_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_lina_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_lina_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_lina_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_lina_perk:RemoveOnDeath()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_lina_perk:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
	}
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_lina_perk:OnCreated()
	self.bonusPerLevel = 3
	self.bonusAmount = 1
	if IsServer() then
		self:StartIntervalThink(0.1)
	end
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_lina_perk:OnIntervalThink()
	if IsServer() then
		local caster = self:GetParent()
		for i=0, caster:GetAbilityCount() do
			local skill = caster:GetAbilityByIndex(i)
			if skill and skill:HasAbilityFlag("fire") then
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
function modifier_npc_dota_hero_lina_perk:GetModifierBonusStats_Intellect(params)
	return self.bonusAmount * self:GetStackCount()
end
--------------------------------------------------------------------------------------------------------

