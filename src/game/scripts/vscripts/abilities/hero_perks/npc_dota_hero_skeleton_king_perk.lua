local Timers = require('easytimers')
--------------------------------------------------------------------------------------------------------
--
--		Hero: Wraith King
--		Perk: Wraith King starts the game with an Aegis of the Immortal.
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_skeleton_king_perk", "abilities/hero_perks/npc_dota_hero_skeleton_king_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_skeleton_king_perk == nil then npc_dota_hero_skeleton_king_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_npc_dota_hero_skeleton_king_perk				
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_skeleton_king_perk == nil then modifier_npc_dota_hero_skeleton_king_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_skeleton_king_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_skeleton_king_perk:IsHidden()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_skeleton_king_perk:RemoveOnDeath()
	return false
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
function modifier_npc_dota_hero_skeleton_king_perk:OnCreated(keys)
	if IsServer() then
		local caster = self:GetCaster()
		
		Timers:CreateTimer(function()
			caster:AddItemByName('item_aegis')
        return
    end, DoUniqueString('give_wk_aegis'), 1)
	end
end
--------------------------------------------------------------------------------------------------------

