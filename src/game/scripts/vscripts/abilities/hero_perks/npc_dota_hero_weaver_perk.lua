--------------------------------------------------------------------------------------------------------
--
--		Hero: Weaver
--		Perk: 
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_weaver_perk", "abilities/hero_perks/npc_dota_hero_weaver_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_weaver_perk == nil then npc_dota_hero_weaver_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_npc_dota_hero_weaver_perk				
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_weaver_perk == nil then modifier_npc_dota_hero_weaver_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_weaver_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_weaver_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_weaver_perk:RemoveOnDeath()
	return false
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_weaver_perk:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_TAKEDAMAGE,
        MODIFIER_PROPERTY_MIN_HEALTH,
    }
    return funcs
end
if IsServer() then
    function modifier_npc_dota_hero_weaver_perk:OnCreated()
        self.lapse = self:GetParent():FindAbilityByName("weaver_time_lapse")
    end
    
    function modifier_npc_dota_hero_weaver_perk:OnTakeDamage(params)
        if params.unit == self:GetParent() then
            if params.damage > self:GetParent():GetHealth() and self.lapse and self.lapse:IsCooldownReady() and self.lapse:GetLevel() > 0 then
                self:GetParent():CastAbilityNoTarget(self.lapse, self:GetParent():GetPlayerID())
            end
        end
    end

    function modifier_npc_dota_hero_weaver_perk:GetMinHealth(params)
        if self.lapse and self.lapse:GetLevel() > 0 and self.lapse:IsCooldownReady() then
            return 1
        else
            return 0
        end
    end
end
