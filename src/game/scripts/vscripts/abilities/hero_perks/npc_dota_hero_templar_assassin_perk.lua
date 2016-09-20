--------------------------------------------------------------------------------------------------------
--
--      Hero: Templar Assassin
--      Perk: Templar Assassin turns invisible when not moving for 2 seconds. 
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_templar_assassin_perk", "abilities/hero_perks/npc_dota_hero_templar_assassin_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_npc_dota_hero_templar_assassin_invis_break", "abilities/hero_perks/npc_dota_hero_templar_assassin_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_templar_assassin_perk == nil then npc_dota_hero_templar_assassin_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--      Modifier: modifier_npc_dota_hero_templar_assassin_perk              
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_templar_assassin_perk == nil then modifier_npc_dota_hero_templar_assassin_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_templar_assassin_perk:IsPassive()
    return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_templar_assassin_perk:IsHidden()
    return not self.check
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_templar_assassin_perk:OnCreated(keys)
    if IsServer() then
        self.check = false
        self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_npc_dota_hero_templar_assassin_invis_break", {Duration = 2})
    end
    return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_templar_assassin_perk:DeclareFunctions()
    return { 
        MODIFIER_EVENT_ON_UNIT_MOVED, 
        MODIFIER_EVENT_ON_ATTACK, 
        MODIFIER_PROPERTY_INVISIBILITY_LEVEL   
    }
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_templar_assassin_perk:GetModifierInvisibilityLevel()
    self.check = not self:GetCaster():HasModifier("modifier_npc_dota_hero_templar_assassin_invis_break")
    if self.check then 
        return 1
    else 
        return 0
    end
end
function modifier_npc_dota_hero_templar_assassin_perk:CheckState()
    local states = { 
        [MODIFIER_STATE_INVISIBLE] = self.check
    }
    return states
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_templar_assassin_perk:OnUnitMoved(keys)
    if IsServer() then
        if keys.unit and self:GetCaster() == keys.unit then
            self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_npc_dota_hero_templar_assassin_invis_break", {Duration = 2})
        end
    end
    return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_templar_assassin_perk:OnAttack(keys)
    if IsServer() then
        if keys.attacker and self:GetCaster() == keys.attacker then
            self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_npc_dota_hero_templar_assassin_invis_break", {Duration = 2})
        end
    end
    return true
end
--------------------------------------------------------------------------------------------------------
--      Modifier: modifier_npc_dota_hero_templar_assassin_invis_break               
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_templar_assassin_invis_break == nil then modifier_npc_dota_hero_templar_assassin_invis_break = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_templar_assassin_invis_break:IsHidden()
    return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_templar_assassin_invis_break:OnDestroy()
    if IsServer() then 
        local caster = self:GetCaster()
        self:GetAbility().particle = ParticleManager:CreateParticle("particles/generic_hero_status/status_invisibility_start.vpcf",PATTACH_ABSORIGIN_FOLLOW, caster)
    end
    return true
end
--------------------------------------------------------------------------------------------------------
