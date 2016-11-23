--------------------------------------------------------------------------------------------------------
--
--		Hero: Earth Spirit
--		Perk: Earth Spirit gains 3+ damage for each point in Earth Abilities.
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_earth_spirit_perk", "abilities/hero_perks/npc_dota_hero_earth_spirit_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_earth_spirit_perk ~= "" then npc_dota_hero_earth_spirit_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_npc_dota_hero_earth_spirit_perk				
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_earth_spirit_perk ~= "" then modifier_npc_dota_hero_earth_spirit_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_earth_spirit_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_earth_spirit_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_earth_spirit_perk:IsHidden()
	return false
end

function modifier_npc_dota_hero_earth_spirit_perk:GetTexture()
	return "earth_spirit_stone_caller"
end

function modifier_npc_dota_hero_earth_spirit_perk:RemoveOnDeath()
	return false
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------


function modifier_npc_dota_hero_earth_spirit_perk:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
	}
	return funcs
end

function modifier_npc_dota_hero_earth_spirit_perk:OnCreated()
	self.baseDamage = 3
	if IsServer() then
		self:StartIntervalThink(0.1)
	end
end

function modifier_npc_dota_hero_earth_spirit_perk:OnIntervalThink()
	if IsServer() then
		local spirit = self:GetParent()
		for i=0, spirit:GetAbilityCount() do
			local skill = spirit:GetAbilityByIndex(i)
			if skill and skill:HasAbilityFlag("earth") then
				skill.spiritPerkLvl = skill.spiritPerkLvl or skill:GetLevel()
				if skill:GetLevel() > skill.spiritPerkLvl then
					local increase = (skill:GetLevel() - skill.spiritPerkLvl)
					local stacks = self:GetStackCount()
					self:SetStackCount(stacks + increase*self.baseDamage)
					skill.spiritPerkLvl = skill:GetLevel()
				end
			end
		end
	end
end

function modifier_npc_dota_hero_earth_spirit_perk:GetModifierPreAttack_BonusDamage()
	return self:GetStackCount()
end
