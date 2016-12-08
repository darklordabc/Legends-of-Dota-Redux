--------------------------------------------------------------------------------------------------------
--
--		Hero: Clinkz
--		Perk: Clinkz will receive a free level in his first non-ultimate Autocast ability at the start of the game. 
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_clinkz_perk", "abilities/hero_perks/npc_dota_hero_clinkz_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_clinkz_perk ~= "" then npc_dota_hero_clinkz_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_npc_dota_hero_clinkz_perk				
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_clinkz_perk ~= "" then modifier_npc_dota_hero_clinkz_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_clinkz_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_clinkz_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_clinkz_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_clinkz_perk:RemoveOnDeath()
    return false
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_clinkz_perk:OnCreated(keys)
	if IsServer() then
		local caster = self:GetCaster()
		
		for i = 0, 15 do 
			local ability = caster:GetAbilityByIndex(i)
			if ability and ability:HasAbilityFlag("autocast_basic") then
				ability:UpgradeAbility(true)
				break
			end
		end
	end
end
--------------------------------------------------------------------------------------------------------
