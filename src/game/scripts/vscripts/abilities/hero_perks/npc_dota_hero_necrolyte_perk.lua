--------------------------------------------------------------------------------------------------------
--
--		Hero: Necrolyte
--		Perk: At the start of the game, Necrophos gains a free level of Sadist, whether he has it or not.
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_necrolyte_perk", "abilities/hero_perks/npc_dota_hero_necrolyte_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_necrolyte_perk ~= "" then npc_dota_hero_necrolyte_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_npc_dota_hero_necrolyte_perk				
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_necrolyte_perk ~= "" then modifier_npc_dota_hero_necrolyte_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_necrolyte_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_necrolyte_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_necrolyte_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_necrolyte_perk:RemoveOnDeath()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_necrolyte_perk:GetTexture()
	return "necrolyte_sadist"
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------

function modifier_npc_dota_hero_necrolyte_perk:OnCreated(keys)
    if IsServer() then
        local caster = self:GetCaster()
        local sadist = caster:FindAbilityByName("necrolyte_sadist")

        if sadist then
            sadist:UpgradeAbility(false)
        else 
            sadist = caster:AddAbility("necrolyte_sadist")
            sadist:SetHidden(true)
            sadist:SetLevel(1)
        end
    end
end
