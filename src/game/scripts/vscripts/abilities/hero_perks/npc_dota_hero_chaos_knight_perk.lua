--------------------------------------------------------------------------------------------------------
--
--		Hero: Chaos Knight
--		Perk: Chaos Knight gains 200 extra gold for each ability he randoms. 
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_chaos_knight_perk", "abilities/hero_perks/npc_dota_hero_chaos_knight_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_chaos_knight_perk ~= "" then npc_dota_hero_chaos_knight_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_npc_dota_hero_chaos_knight_perk				
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_chaos_knight_perk ~= "" then modifier_npc_dota_hero_chaos_knight_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_chaos_knight_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_chaos_knight_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_chaos_knight_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_chaos_knight_perk:RemoveOnDeath()
	return false
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_chaos_knight_perk:OnCreated()
	if IsServer() then
		local caster = self:GetCaster()
		local ply = caster:GetPlayerOwner()
		-- amount of gold per random ability
		local goldPerRandom = 200

		if caster:IsRealHero() and ply and ply.random and ply.random > 0 and PlayerResource:GetConnectionState(caster:GetPlayerOwnerID()) ~= 1 then
			caster:ModifyGold(ply.random * goldPerRandom, false, 0)
			SendOverheadEventMessage( ply, OVERHEAD_ALERT_GOLD , ply, ply.random * goldPerRandom, nil )
			ply.random = 0
		end
	end
	return true
end
--------------------------------------------------------------------------------------------------------
