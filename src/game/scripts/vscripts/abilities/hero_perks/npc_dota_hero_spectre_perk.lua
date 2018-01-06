--------------------------------------------------------------------------------------------------------
--
--		Hero: Spectre
--		Perk: Spectre gains phased movement for 4 seconds every time she uses an ability.
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_spectre_perk", "abilities/hero_perks/npc_dota_hero_spectre_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_npc_dota_hero_spectre_phased", "abilities/hero_perks/npc_dota_hero_spectre_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_spectre_perk ~= "" then npc_dota_hero_spectre_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_npc_dota_hero_spectre_perk				
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_spectre_perk ~= "" then modifier_npc_dota_hero_spectre_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_spectre_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_spectre_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_spectre_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_spectre_perk:RemoveOnDeath()
	return false
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_spectre_perk:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ABILITY_EXECUTED,
	}
	return funcs
end

function modifier_npc_dota_hero_spectre_perk:OnAbilityExecuted(params)
	if params.unit == self:GetParent() then
		local phase = params.ability -- For modifier icon
		if params.ability:GetManaCost() > 0 then
			self:GetParent():AddNewModifier(self:GetParent(), nil, "modifier_npc_dota_hero_spectre_phased", {duration = 4})
		end
	end
end

--------------------------------------------------------------------------------------------------------
--		Phase Modifier: 	modifier_npc_dota_hero_spectre_phased		
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_spectre_phased ~= "" then modifier_npc_dota_hero_spectre_phased = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_spectre_phased:CheckState()
	local state = {
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
		[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true,
	}
	return state
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_spectre_phased:GetTexture()
	return "spectre_reality"
end
--------------------------------------------------------------------------------------------------------
