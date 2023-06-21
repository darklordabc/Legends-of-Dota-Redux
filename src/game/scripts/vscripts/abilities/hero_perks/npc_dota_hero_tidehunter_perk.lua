--------------------------------------------------------------------------------------------------------
--
--		Hero: Tidehunter
--		Perk: Refreshes Ravage when Tidehunter dies. 
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_tidehunter_perk", "abilities/hero_perks/npc_dota_hero_tidehunter_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_tidehunter_perk ~= "" then npc_dota_hero_tidehunter_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_npc_dota_hero_tidehunter_perk				
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_tidehunter_perk ~= "" then modifier_npc_dota_hero_tidehunter_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_tidehunter_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_tidehunter_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_tidehunter_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_tidehunter_perk:RemoveOnDeath()
	return false
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_tidehunter_perk:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PHYSICAL_CONSTANT_BLOCK,
	}
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_tidehunter_perk:OnCreated()
	self.bonusPerLevel = 5
	self.bonusAmount = 1
	if IsServer() then
		self:StartIntervalThink(0.1)
	end
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_tidehunter_perk:OnIntervalThink()
	if IsServer() then
		local caster = self:GetParent()
		for i=0, caster:GetAbilityCount() do
			local skill = caster:GetAbilityByIndex(i)
			if skill and skill:HasAbilityFlag("water") then
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
function modifier_npc_dota_hero_tidehunter_perk:GetModifierPhysical_ConstantBlock(params)
	return self.bonusAmount * self:GetStackCount()
end

