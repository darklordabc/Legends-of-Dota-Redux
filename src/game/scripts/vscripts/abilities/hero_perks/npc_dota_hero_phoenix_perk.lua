--------------------------------------------------------------------------------------------------------
--
--        Hero: Phoenix
--        Perk: Once level 6, Phoenix will automatically cast Supernova upon taking fatal damage. Has a separate 180 second cooldown. 
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_phoenix_perk", "abilities/hero_perks/npc_dota_hero_phoenix_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_npc_dota_hero_phoenix_perk_delay", "abilities/hero_perks/npc_dota_hero_phoenix_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_phoenix_perk ~= "" then npc_dota_hero_phoenix_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--        Modifier: modifier_npc_dota_hero_phoenix_perk
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_phoenix_perk ~= "" then modifier_npc_dota_hero_phoenix_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_phoenix_perk:IsPassive()
    return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_phoenix_perk:IsHidden()
    return self:GetCaster():HasModifier("modifier_npc_dota_hero_phoenix_perk_delay")
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_phoenix_perk:IsPurgable()
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
        self.eggLevel = 0
        self.egg = self:GetParent():AddAbility("phoenix_supernova_perk")
        self.egg:SetLevel(self.eggLevel)
        self.egg:SetHidden(true)
        self:StartIntervalThink(2.0)
    end

    function modifier_npc_dota_hero_phoenix_perk:OnIntervalThink()
        local checkLevel = self:GetParent():GetLevel()
        local eggLevel = 1

        if checkLevel >= 18 then 
            eggLevel = 3
        elseif checkLevel >= 12 then
            eggLevel = 2
        elseif checkLevel >= 6 then
            eggLevel = 1
        else
            eggLevel = 0
        end

        if eggLevel ~= self.eggLevel then 
            self.eggLevel = eggLevel
            self.egg:SetLevel(eggLevel)
        end
    end
    
    function modifier_npc_dota_hero_phoenix_perk:OnTakeDamage(params)
        if params.unit == self:GetParent() then
            if params.damage > self:GetParent():GetHealth() and self.egg and not self:GetParent():HasModifier("modifier_npc_dota_hero_phoenix_perk_delay") and self.egg:GetLevel() > 0 and self:GetParent():IsRealHero() then
                if self:GetParent():HasScepter() then
                    self:GetParent():SetCursorCastTarget(self:GetParent())
                    self.egg:OnSpellStart()
                    self:GetParent():AddNewModifier(self:GetParent(),self:GetAbility(),"modifier_npc_dota_hero_phoenix_perk_delay",{Duration = self.egg:GetCooldown(-1)})
                else
                    self.egg:OnSpellStart()
                    self:GetParent():AddNewModifier(self:GetParent(),self:GetAbility(),"modifier_npc_dota_hero_phoenix_perk_delay",{Duration = self.egg:GetCooldown(-1)})
                end
            end
        end
    end

    function modifier_npc_dota_hero_phoenix_perk:GetMinHealth(params)
        if self.egg and self.egg:GetLevel() > 0 and not self:GetParent():HasModifier("modifier_npc_dota_hero_phoenix_perk_delay") and self:GetParent():IsRealHero() then
            return 1
        else
            return 0
        end
    end
end
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_phoenix_perk_delay ~= "" then modifier_npc_dota_hero_phoenix_perk_delay = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_phoenix_perk_delay:RemoveOnDeath()
    return false
end
--------------------------------------------------------------------------------------------------------
