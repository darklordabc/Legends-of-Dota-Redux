--------------------------------------------------------------------------------------------------------
--
--		Hero: leshrac
--		Perk: 
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_leshrac_perk", "abilities/hero_perks/npc_dota_hero_leshrac_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_leshrac_perk == nil then npc_dota_hero_leshrac_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_npc_dota_hero_leshrac_perk				
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_leshrac_perk == nil then modifier_npc_dota_hero_leshrac_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_leshrac_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_leshrac_perk:IsHidden()
	return false
end

function modifier_npc_dota_hero_leshrac_perk:GetTexture()
	return "octarine_vampirism_lod"
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------

function modifier_npc_dota_hero_leshrac_perk:OnCreated(keys)
	
    if IsServer() then
        local caster = self:GetCaster()
        local octarine = caster:FindAbilityByName("octarine_vampirism_lod")

        if octarine then
            octarine:UpgradeAbility(false)
        else 
            octarine = caster:AddAbility("octarine_vampirism_lod")
            octarine:SetHidden(true)
            octarine:SetLevel(1)
        end
    end
end