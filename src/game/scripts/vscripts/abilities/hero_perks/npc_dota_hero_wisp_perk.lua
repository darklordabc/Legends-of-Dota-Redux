--------------------------------------------------------------------------------------------------------
--
--		Hero: Wisp
--		Perk: Wisp provides 3 mana per second regeneration to nearby allies.
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_wisp_perk", "abilities/hero_perks/npc_dota_hero_wisp_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_wisp_perk ~= "" then npc_dota_hero_wisp_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_npc_dota_hero_wisp_perk				
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_wisp_perk ~= "" then modifier_npc_dota_hero_wisp_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_wisp_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_wisp_perk:IsHidden()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_wisp_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_wisp_perk:RemoveOnDeath()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_wisp_perk:GetTexture()
	return "necrolyte_heartstopper_aura"
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------

function modifier_npc_dota_hero_wisp_perk:OnCreated(keys)
    if IsServer() then
        local caster = self:GetCaster()
        local essense = caster:FindAbilityByName("obsidian_destroyer_essence_aura")

        if essense then
            essense:UpgradeAbility(false)
        else 
            essense = caster:AddAbility("obsidian_destroyer_essence_aura")
            essense:SetStolen(true)
            essense:SetActivated(true)
            essense:SetLevel(1)
        end
    end
end
