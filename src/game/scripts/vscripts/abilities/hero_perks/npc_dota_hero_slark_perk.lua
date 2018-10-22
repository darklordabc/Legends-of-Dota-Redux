--------------------------------------------------------------------------------------------------------
--
--		Hero: Slark
--		Perk: Slark gets a free level of dark pact, and casts it every 10 seconds. Also is immune to its self damage. 
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
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
	}
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_slark_perk:GetModifierIncomingDamage_Percentage(params)
	if IsClient() then return end
	if params.inflictor and params.inflictor:GetAbilityName() == "slark_dark_pact" and params.attacker == self:GetParent() then
		return -1000
	end
end
--------------------------------------------------------------------------------------------------------

function modifier_npc_dota_hero_slark_perk:OnCreated()
	if IsClient() then return end
	local hero = self:GetParent()
	local ability = hero:FindAbilityByName("slark_dark_pact")

	if not ability then
		ability = hero:AddAbility("slark_dark_pact")
		ability:SetStolen(true)
	end
	ability:SetLevel(1)
	self:StartIntervalThink(10)
end

function modifier_npc_dota_hero_slark_perk:OnIntervalThink()
	local hero = self:GetParent()
	local ability = hero:FindAbilityByName("slark_dark_pact")
	ability:OnSpellStart()
end