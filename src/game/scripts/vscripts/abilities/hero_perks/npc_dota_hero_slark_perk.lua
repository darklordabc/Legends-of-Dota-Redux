--------------------------------------------------------------------------------------------------------
--
--		Hero: Slark
--		Perk: Slark gains +3 agility for each level put in an mobility/escape skill. 
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_slark_perk", "abilities/hero_perks/npc_dota_hero_slark_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_slark_perk ~= "" then npc_dota_hero_slark_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_npc_dota_hero_slark_perk				
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_slark_perk ~= "" then modifier_npc_dota_hero_slark_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_slark_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_slark_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_slark_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_slark_perk:RemoveOnDeath()
	return false
end
--------------------------------------------------------------------------------------------------------

function modifier_npc_dota_hero_slark_perk:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
	}
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_slark_perk:GetModifierBonusStats_Agility(params)
	local caster = self:GetCaster()

	local agility_value = 3
	local bonusAgility = 0

	for i = 0, 15 do
		local ability = caster:GetAbilityByIndex(i)
		if ability and ability:HasAbilityFlag("mobility") then
			local level = ability:GetLevel()
			bonusAgility = bonusAgility + (level * agility_value)	
		end
	end
	return bonusAgility
end
--------------------------------------------------------------------------------------------------------

