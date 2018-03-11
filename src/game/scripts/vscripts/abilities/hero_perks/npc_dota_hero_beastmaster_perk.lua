--------------------------------------------------------------------------------------------------------
--
--		Hero: Beastmaster
--      Perk: Increases Beastmaster's Strength by 3 for every level put in Neutral abilities. 
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_beastmaster_perk", "abilities/hero_perks/npc_dota_hero_beastmaster_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_beastmaster_perk ~= "" then npc_dota_hero_beastmaster_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_npc_dota_hero_beastmaster_perk				
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_beastmaster_perk ~= "" then modifier_npc_dota_hero_beastmaster_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_beastmaster_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_beastmaster_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_beastmaster_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_beastmaster_perk:RemoveOnDeath()
	return false
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------

function modifier_npc_dota_hero_beastmaster_perk:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
	}
	return funcs
end

function modifier_npc_dota_hero_beastmaster_perk:OnCreated()
	self.bonusPerLevel = 3
	self.bonusStrength = 1
	if IsServer() then
		self:StartIntervalThink(0.1)
	end
end

function modifier_npc_dota_hero_beastmaster_perk:OnIntervalThink()
	if IsServer() then
		local maiden = self:GetParent()
		for i=0, maiden:GetAbilityCount() do
			local skill = maiden:GetAbilityByIndex(i)
			if skill and skill:HasAbilityFlag("neutral") then
				if not skill.beastMasterPerkLvl then skill.beastMasterPerkLvl = skill:GetLevel() end
				if skill:GetLevel() > skill.beastMasterPerkLvl then
					local increase = (skill:GetLevel()  - skill.beastMasterPerkLvl)
					increase = increase * self.bonusPerLevel
					if skill:GetMaxLevel() == 1 then
						increase = increase * 4
					end
					local stacks = self:GetStackCount()
					self:SetStackCount(stacks + increase)
					skill.beastMasterPerkLvl = skill:GetLevel()
				end
			end
		end
	end
end

function modifier_npc_dota_hero_beastmaster_perk:GetModifierBonusStats_Strength()
	return self.bonusStrength * self:GetStackCount()
end