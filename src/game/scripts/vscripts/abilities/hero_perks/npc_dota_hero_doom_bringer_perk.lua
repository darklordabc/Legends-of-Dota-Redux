--------------------------------------------------------------------------------------------------------
--
--		Hero: Doom Bringer
--		Perk: Doom applies Break when casting Doom.
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_doom_bringer_perk", "abilities/hero_perks/npc_dota_hero_doom_bringer_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_npc_dota_hero_doom_bringer_doom_break", "abilities/hero_perks/npc_dota_hero_doom_bringer_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_doom_bringer_perk ~= "" then npc_dota_hero_doom_bringer_perk = class({}) end
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

function modifier_npc_dota_hero_doom_bringer_perk:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ABILITY_EXECUTED,
	}
	return funcs
end

function modifier_npc_dota_hero_doom_bringer_perk:OnAbilityExecuted(params)
	if params.unit == self:GetParent() then
		if params.ability:GetName() == "doom_bringer_doom" and not self:GetParent():HasScepter() then
			local doom = params.ability
			params.target:AddNewModifier(self:GetParent(), doom, "modifier_npc_dota_hero_doom_bringer_doom_break", {duration = doom:GetSpecialValueFor("duration")})
		end
	end
end

--------------------------------------------------------------------------------------------------------
--		Break Modifier: modifier_npc_dota_hero_doom_bringer_doom_break				
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_doom_bringer_doom_break ~= "" then modifier_npc_dota_hero_doom_bringer_doom_break = class({}) end

function modifier_npc_dota_hero_doom_bringer_doom_break:CheckState()
	local state = {
	[MODIFIER_STATE_PASSIVES_DISABLED] = true,
	}
	return state
end

function modifier_npc_dota_hero_doom_bringer_doom_break:GetEffectName()
	return "particles/items3_fx/silver_edge_slow.vpcf"
end

function modifier_npc_dota_hero_doom_bringer_doom_break:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end