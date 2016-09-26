--------------------------------------------------------------------------------------------------------
--
--		Hero: Underlord
--		Perk: Underlord gains +1 to all stats for each level put in a custom ability.
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_abyssal_underlord_perk", "abilities/hero_perks/npc_dota_hero_abyssal_underlord_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_abyssal_underlord_perk == nil then npc_dota_hero_abyssal_underlord_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_npc_dota_hero_abyssal_underlord_perk			
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_abyssal_underlord_perk == nil then modifier_npc_dota_hero_abyssal_underlord_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_abyssal_underlord_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_abyssal_underlord_perk:IsHidden()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_abyssal_underlord_perk:IsHidden()
	return true
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_abyssal_underlord_perk:DeclareFunctions()
	return { 
	MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
	MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
	MODIFIER_PROPERTY_STATS_STRENGTH_BONUS  
	}
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_abyssal_underlord_perk:OnCreated()
	if IsServer() then
		self.bonusPerLevel = 1
		self.bonusAmount = 0
	end
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_abyssal_underlord_perk:GetModifierBonusStats_Intellect(params)
	local caster = self:GetCaster()
	local bonusIntellect = 0

	for i = 0, 15 do
		local ability = caster:GetAbilityByIndex(i)
		if ability and ability:GetName() ~= "npc_dota_hero_abyssal_underlord_perk" and ability:IsCustomAbility()  then
			local level = ability:GetLevel()
			bonusIntellect = bonusIntellect + (level * self.bonusPerLevel)	
		end
	end
	self.bonusAmount = bonusIntellect
	return self.bonusAmount
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_abyssal_underlord_perk:GetModifierBonusStats_Agility(params)
	return self.bonusAmount
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_abyssal_underlord_perk:GetModifierBonusStats_Strength(params)
	return self.bonusAmount
end
--------------------------------------------------------------------------------------------------------

