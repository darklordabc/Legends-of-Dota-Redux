--------------------------------------------------------------------------------------------------------
--
--		Hero: Pangolier
--		Perk: At the start of the game, Pangolier gains a free level of Heartpiercer, whether he has it or not.
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_pangolier_perk", "abilities/hero_perks/npc_dota_hero_pangolier_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_pangolier_perk ~= "" then npc_dota_hero_pangolier_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_npc_dota_hero_pangolier_perk				
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_pangolier_perk ~= "" then modifier_npc_dota_hero_pangolier_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_pangolier_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_pangolier_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_pangolier_perk:RemoveOnDeath()
	return false
end
--------------------------------------------------------------------------------------------------------
--function modifier_npc_dota_hero_pangolier_perk:GetTexture()
--	return "custom/side_gunner_redux"
--end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_pangolier_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------

function modifier_npc_dota_hero_pangolier_perk:OnCreated(keys)
    if IsServer() then
        local caster = self:GetCaster()
        local gunner = caster:FindAbilityByName("pangolier_heartpiercer")

        if gunner then
            gunner:UpgradeAbility(false)
        else 
            gunner = caster:AddAbility("pangolier_heartpiercer")
            gunner:SetStolen(true)
            gunner:SetActivated(true)
            gunner:SetLevel(1)
        end
    end
end
