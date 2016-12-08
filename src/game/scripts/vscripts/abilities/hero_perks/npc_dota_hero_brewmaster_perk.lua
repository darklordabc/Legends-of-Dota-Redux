--------------------------------------------------------------------------------------------------------
--
--		Hero: Brewmaster
--		Perk: Brewmaster gains +100% regen from Salve, Bottle and Clarity.
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_brewmaster_perk", "abilities/hero_perks/npc_dota_hero_brewmaster_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_brewmaster_perk ~= "" then npc_dota_hero_brewmaster_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_npc_dota_hero_brewmaster_perk				
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_brewmaster_perk ~= "" then modifier_npc_dota_hero_brewmaster_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_brewmaster_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_brewmaster_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_brewmaster_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_brewmaster_perk:RemoveOnDeath()
	return false
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------

function modifier_npc_dota_hero_brewmaster_perk:DeclareFunctions()
	return { 
	MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT, 
	MODIFIER_PROPERTY_MANA_REGEN_CONSTANT, 
	 }
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_brewmaster_perk:GetModifierConstantHealthRegen()
	local healthRegen = 0

	local bottleRegen = self:GetCaster():FindModifierByName("modifier_bottle_regeneration")
	local salveRegen = self:GetCaster():FindModifierByName("modifier_flask_healing")

	if bottleRegen then healthRegen = healthRegen + 36 end
	if salveRegen then healthRegen = healthRegen + 50 end

	return healthRegen
end

function modifier_npc_dota_hero_brewmaster_perk:GetModifierConstantManaRegen()
	local manaRegen = 0

	local bottleRegen = self:GetCaster():FindModifierByName("modifier_bottle_regeneration")
	local clarityRegen = self:GetCaster():FindModifierByName("modifier_clarity_potion")

	if bottleRegen then manaRegen = manaRegen + 24 end
	if clarityRegen then manaRegen = manaRegen + 3.8 end

	return manaRegen
end
