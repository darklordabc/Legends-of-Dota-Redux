--------------------------------------------------------------------------------------------------------
--
--		Hero: Weaver
--		Perk: Once level 6, Weaver will automatically cast Time Lapse upon taking fatal damage. Has a separate 120 second cooldown. 
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_weaver_perk", "abilities/hero_perks/npc_dota_hero_weaver_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_npc_dota_hero_weaver_perk_delay", "abilities/hero_perks/npc_dota_hero_weaver_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_weaver_perk ~= "" then npc_dota_hero_weaver_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_npc_dota_hero_weaver_perk
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_weaver_perk ~= "" then modifier_npc_dota_hero_weaver_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_weaver_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_weaver_perk:IsHidden()
	return self:GetCaster():HasModifier("modifier_npc_dota_hero_weaver_perk_delay")
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_weaver_perk:IsPurgable()
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
        self.lapseLevel = 0
        self.lapse = self:GetParent():AddAbility("weaver_time_lapse_perk")
        self.lapse:SetLevel(self.lapseLevel)
        self.lapse:SetHidden(true)
        self:StartIntervalThink(2.0)
    end

     function modifier_npc_dota_hero_weaver_perk:OnIntervalThink()
        local checkLevel = self:GetParent():GetLevel()
        local lapseLevel = 1

        if checkLevel >= 18 then 
            lapseLevel = 3
        elseif checkLevel >= 12 then
            lapseLevel = 2
        elseif checkLevel >= 6 then
            lapseLevel = 1
        else
            lapseLevel = 0
        end
        
        if lapseLevel ~= self.lapseLevel then 
            self.lapseLevel = lapseLevel
            self.lapse:SetLevel(lapseLevel)
        end
    end
    
    function modifier_npc_dota_hero_weaver_perk:OnTakeDamage(params)
        if params.unit == self:GetParent() then
            if params.damage > self:GetParent():GetHealth() and self.lapse and not self:GetParent():HasModifier("modifier_npc_dota_hero_weaver_perk_delay") and self.lapse:GetLevel() > 0  and self:GetParent():IsRealHero() then
                if self:GetParent():HasScepter() then
                    self:GetParent():SetCursorCastTarget(self:GetParent())
                    self.lapse:OnSpellStart()
                    self:GetParent():SpendMana(self.lapse:GetManaCost(-1),self.lapse)
                    self:GetParent():AddNewModifier(self:GetParent(),self:GetAbility(),"modifier_npc_dota_hero_weaver_perk_delay",{Duration = self.lapse:GetCooldown(-1)})
                else
                    self.lapse:OnSpellStart()
                    self:GetParent():SpendMana(self.lapse:GetManaCost(-1),self.lapse)
                    self:GetParent():AddNewModifier(self:GetParent(),self:GetAbility(),"modifier_npc_dota_hero_weaver_perk_delay",{Duration = self.lapse:GetCooldown(-1)})
                end
            end
        end
    end

    function modifier_npc_dota_hero_weaver_perk:GetMinHealth(params)
        if self.lapse and not self.lapse:IsNull() and self.lapse:GetLevel() > 0 and not self:GetParent():HasModifier("modifier_npc_dota_hero_weaver_perk_delay") and self:GetParent():IsRealHero() then
            return 1
        else
            return 0
        end
    end
end
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_weaver_perk_delay ~= "" then modifier_npc_dota_hero_weaver_perk_delay = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_weaver_perk_delay:RemoveOnDeath()
    return false
end
--------------------------------------------------------------------------------------------------------
