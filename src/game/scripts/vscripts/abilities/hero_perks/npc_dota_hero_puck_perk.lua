--------------------------------------------------------------------------------------------------------
--
--		Hero: Puck
--		Perk: Puck gets Time Warp Aura as a free ability
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_puck_perk", "abilities/hero_perks/npc_dota_hero_puck_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_puck_perk ~= "" then npc_dota_hero_puck_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_npc_dota_hero_puck_perk			
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_puck_perk ~= "" then modifier_npc_dota_hero_puck_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_puck_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_puck_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_puck_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_puck_perk:RemoveOnDeath()
	return false
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_puck_perk:OnCreated(keys)
	
    if IsServer() then
        local caster = self:GetCaster()
        local puck = caster:FindAbilityByName("frostbitten_golem_time_warp_aura")

        if puck then
            puck:UpgradeAbility(false)
        else 
            puck = caster:AddAbility("frostbitten_golem_time_warp_aura")
            --nullField:SetLevel(1)	
        end
    end
end
