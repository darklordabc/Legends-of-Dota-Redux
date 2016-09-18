--------------------------------------------------------------------------------------------------------
--
--		Hero: Lina
--		Perk: Increases Lina's intelligence by 3 for each level put in fire-type spells.
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_lina_perk", "abilities/hero_perks/npc_dota_hero_lina_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_lina_perk == nil then npc_dota_hero_lina_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_lina_perk				
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_lina_perk == nil then modifier_npc_dota_hero_lina_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_lina_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_lina_perk:IsHidden()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_lina_perk:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
	}
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_lina_perk:GetModifierBonusStats_Intellect(params)
	local caster = self:GetCaster()

	local intellect_value = 3
	local bonusIntellect = 0

	for i = 0, 15 do
		local ability = caster:GetAbilityByIndex(i)
		if ability and ability:HasAbilityFlag("fire") then
			local level = ability:GetLevel()
			bonusIntellect = bonusIntellect + (level * intellect_value)	
		end
	end
	return bonusIntellect
end
--------------------------------------------------------------------------------------------------------

