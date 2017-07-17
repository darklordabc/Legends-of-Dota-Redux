--------------------------------------------------------------------------------------------------------
--
--		Hero: Leshrac
--		Perk: At the start of the game, Leshrac gains a free level of Octarine Vampirism, whether he has it or not.
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_leshrac_perk", "abilities/hero_perks/npc_dota_hero_leshrac_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_leshrac_perk ~= "" then npc_dota_hero_leshrac_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_npc_dota_hero_leshrac_perk				
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_leshrac_perk ~= "" then modifier_npc_dota_hero_leshrac_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_leshrac_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_leshrac_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_leshrac_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_leshrac_perk:RemoveOnDeath()
	return false
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------

function modifier_npc_dota_hero_leshrac_perk:OnCreated(keys)
	self.created = GameRules:GetGameTime()
    if IsServer() then
        local caster = self:GetCaster()
        local octarine = caster:FindAbilityByName("octarine_vampirism_lod")

        if octarine then
            octarine:UpgradeAbility(false)
        else 
            octarine = caster:AddAbility("octarine_vampirism_lod")
            octarine:SetStolen(true)
            octarine:SetActivated(true)
            octarine:SetLevel(1)
        end
    end
end
