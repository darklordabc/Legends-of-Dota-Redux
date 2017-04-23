--------------------------------------------------------------------------------------------------------
--
--		Hero: Doom Bringer
--		Perk: Doom's passives cannot be disabled.
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_doom_bringer_perk", "abilities/hero_perks/npc_dota_hero_doom_bringer_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_doom_bringer_perk ~= "" then npc_dota_hero_doom_bringer_perk = class({}) end

function npc_dota_hero_doom_bringer_perk:GetIntrinsicModifierName()
	return "modifier_npc_dota_hero_doom_bringer_perk"
end
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_npc_dota_hero_doom_bringer_perk				
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_doom_bringer_perk ~= "" then modifier_npc_dota_hero_doom_bringer_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_doom_bringer_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_doom_bringer_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_doom_bringer_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_doom_bringer_perk:RemoveOnDeath()
	return false
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_doom_bringer_perk:CheckState()
	local state = {
		[MODIFIER_STATE_PASSIVES_DISABLED] = false,
	}
	return state
end

function modifier_npc_dota_hero_doom_bringer_perk:GetPriority()
	return MODIFIER_PRIORITY_ULTRA
end