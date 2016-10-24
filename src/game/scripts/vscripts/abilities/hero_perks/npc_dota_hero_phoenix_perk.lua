--------------------------------------------------------------------------------------------------------
--
--        Hero: Phoenix
--        Perk: Phoenix auto-casts Supernova when taking lethal damage.
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_phoenix_perk", "abilities/hero_perks/npc_dota_hero_phoenix_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_phoenix_perk == nil then npc_dota_hero_phoenix_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--        Modifier: modifier_npc_dota_hero_phoenix_perk                
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_phoenix_perk == nil then modifier_npc_dota_hero_phoenix_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_phoenix_perk:IsPassive()
    return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_phoenix_perk:IsHidden()
    return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_phoenix_perk:RemoveOnDeath()
    return false
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_phoenix_perk:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_TAKEDAMAGE,
        MODIFIER_PROPERTY_MIN_HEALTH,
    }
    return funcs
end
if IsServer() then
    function modifier_npc_dota_hero_phoenix_perk:OnCreated()
        self.egg = self:GetParent():FindAbilityByName("phoenix_supernova")
    end
    
    function modifier_npc_dota_hero_phoenix_perk:OnTakeDamage(params)
        if params.unit == self:GetParent() then
            if params.damage > self:GetParent():GetHealth() and self.egg and self.egg:IsCooldownReady() and self.egg:GetLevel() > 0 and self:GetParent():IsRealHero() then
                if self:GetParent():HasScepter() then
                    self:GetParent():SetCursorCastTarget(self:GetParent())
                    self.egg:OnSpellStart()
                    self.egg:StartCooldown(self.egg:GetTrueCooldown())
                else
                    self.egg:OnSpellStart()
                    self.egg:StartCooldown(self.egg:GetTrueCooldown())
                end
            end
        end
    end

    function modifier_npc_dota_hero_phoenix_perk:GetMinHealth(params)
        if self.egg and self.egg:GetLevel() > 0 and self.egg:IsCooldownReady() and self:GetParent():IsRealHero() then
            return 1
        else
            return 0
        end
    end
end
