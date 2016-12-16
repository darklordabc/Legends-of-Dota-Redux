--------------------------------------------------------------------------------------------------------
--
--		Hero: Sven
--		Perk: At the start of the game, Sven gains a free level of Great Cleave, whether he has it or not.
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_sven_perk", "abilities/hero_perks/npc_dota_hero_sven_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_sven_perk ~= "" then npc_dota_hero_sven_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_npc_dota_hero_sven_perk				
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_sven_perk ~= "" then modifier_npc_dota_hero_sven_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_sven_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_sven_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_sven_perk:RemoveOnDeath()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_sven_perk:GetTexture()
	return "sven_great_cleave"
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_sven_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------

function modifier_npc_dota_hero_sven_perk:OnCreated(keys)
    if IsServer() then
        local caster = self:GetCaster()
        local cleave = caster:FindAbilityByName("sven_great_cleave")

        if cleave then
            cleave:UpgradeAbility(false)
        else 
            cleave = caster:AddAbility("sven_great_cleave")
	    for i=0,24 do
            	local abil = caster:GetAbilityByIndex(i)
                if not abil then
		    cleave:SetAbilityIndex(i)
		end
     	    end
            cleave:SetHidden(true)
            cleave:SetLevel(1)
        end
    end
end
