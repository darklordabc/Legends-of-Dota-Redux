--------------------------------------------------------------------------------------------------------
--
--		Hero: Beastmaster
--		Perk: Increases Beastmaster's Strength by 3 for every level put in Neutral abilities. 
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_beastmaster_perk", "abilities/hero_perks/npc_dota_hero_beastmaster_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_beastmaster_perk == nil then npc_dota_hero_beastmaster_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_npc_dota_hero_beastmaster_perk			
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_beastmaster_perk == nil then modifier_npc_dota_hero_beastmaster_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_beastmaster_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_beastmaster_perk:IsHidden()
	return true
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_beastmaster_perk:DeclareFunctions()
	return { 
	MODIFIER_PROPERTY_STATS_STRENGTH_BONUS  
	}
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_beastmaster_perk:OnCreated()
	if IsServer() then
		self.bonusPerLevel = 3
		self.bonusAmount = 0
	end
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_beastmaster_perk:GetModifierBonusStats_Strength(params)
	local caster = self:GetCaster()
	local bonusStrength = 0

	for i = 0, 15 do
		local ability = caster:GetAbilityByIndex(i)
		if ability and ability:GetName() ~= "npc_dota_hero_beastmaster_perk" and ability:HasAbilityFlag("neutral") then
			local level = ability:GetLevel()
			bonusStrength = bonusStrength + (level * self.bonusPerLevel)	
		end
	end
	self.bonusAmount = bonusStrength
	return self.bonusAmount
end
--------------------------------------------------------------------------------------------------------
