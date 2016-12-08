--------------------------------------------------------------------------------------------------------
--
--		Hero: crystal_maiden
--		Perk: Crystal Maiden gains +2 MS for every Support skill she has. 
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_crystal_maiden_perk", "abilities/hero_perks/npc_dota_hero_crystal_maiden_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_crystal_maiden_perk ~= "" then npc_dota_hero_crystal_maiden_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_npc_dota_hero_crystal_maiden_perk				
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_crystal_maiden_perk ~= "" then modifier_npc_dota_hero_crystal_maiden_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_crystal_maiden_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_crystal_maiden_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_crystal_maiden_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_crystal_maiden_perk:RemoveOnDeath()
	return false
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------

function modifier_npc_dota_hero_crystal_maiden_perk:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
	}
	return funcs
end

function modifier_npc_dota_hero_crystal_maiden_perk:OnCreated()
	if not self.movementSpeed then self.movementSpeed = 0 end
	self.baseMovement = 2
	if IsServer() then
		self:StartIntervalThink(0.1)
	end
end

function modifier_npc_dota_hero_crystal_maiden_perk:OnIntervalThink()
	if IsServer() then
		local maiden = self:GetParent()
		for i=0, maiden:GetAbilityCount() do
			local skill = maiden:GetAbilityByIndex(i)
			if skill and skill:HasAbilityFlag("support") then
				if not skill.maidenPerkLvl then skill.maidenPerkLvl = skill:GetLevel() end
				if skill:GetLevel() > skill.maidenPerkLvl then
					local increase = (skill:GetLevel() - skill.maidenPerkLvl)
					local stacks = self:GetStackCount()
					self:SetStackCount(stacks + increase)
					skill.maidenPerkLvl = skill:GetLevel()
				end
			end
		end
	end
end

function modifier_npc_dota_hero_crystal_maiden_perk:GetModifierMoveSpeedBonus_Constant()
	return self.baseMovement * self:GetStackCount()
end