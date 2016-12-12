--------------------------------------------------------------------------------------------------------
--
--      Hero: Templar Assassin
--      Perk: Templar Assassin turns invisible for 10 seconds when not moving for 5 seconds. Breaks upon moving or attacking.
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_templar_assassin_perk", "abilities/hero_perks/npc_dota_hero_templar_assassin_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_npc_dota_hero_templar_assassin_invis_break", "abilities/hero_perks/npc_dota_hero_templar_assassin_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_npc_dota_hero_templar_assassin_invis", "abilities/hero_perks/npc_dota_hero_templar_assassin_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_templar_assassin_perk ~= "" then npc_dota_hero_templar_assassin_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--      Modifier: modifier_npc_dota_hero_templar_assassin_perk              
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_templar_assassin_perk ~= "" then modifier_npc_dota_hero_templar_assassin_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_templar_assassin_perk:IsPassive()
    return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_templar_assassin_perk:IsHidden()
    return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_templar_assassin_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_templar_assassin_perk:OnCreated(keys)
    if IsServer() then
        self.check = false
        self.invisDelay = 5
        self:GetCaster().invisDuration = 10
        self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_npc_dota_hero_templar_assassin_invis_break", {Duration = self.invisDelay})
    end
    return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_templar_assassin_perk:DeclareFunctions()
    return { 
        MODIFIER_EVENT_ON_UNIT_MOVED, 
        MODIFIER_EVENT_ON_ATTACK 
    }
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_templar_assassin_perk:OnUnitMoved(keys)
    if IsServer() then
        if keys.unit and self:GetCaster() == keys.unit then
            self:GetCaster():RemoveModifierByName("modifier_npc_dota_hero_templar_assassin_invis")
            self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_npc_dota_hero_templar_assassin_invis_break", {Duration = self.invisDelay})
            self:GetCaster().hasMoved = true
        end
    end
    return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_templar_assassin_perk:OnAttack(keys)
    if IsServer() then
        if keys.attacker and self:GetCaster() == keys.attacker then
            self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_npc_dota_hero_templar_assassin_invis_break", {Duration = self.invisDelay})
        end
    end
    return true
end
--------------------------------------------------------------------------------------------------------
--      Modifier: modifier_npc_dota_hero_templar_assassin_invis_break               
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_templar_assassin_invis_break ~= "" then modifier_npc_dota_hero_templar_assassin_invis_break = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_templar_assassin_invis_break:IsHidden()
    return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_templar_assassin_invis_break:OnDestroy()
    if IsServer() then 
        local caster = self:GetCaster()
        self:GetAbility().particle = ParticleManager:CreateParticle("particles/generic_hero_status/status_invisibility_start.vpcf",PATTACH_ABSORIGIN_FOLLOW, caster)
        self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_npc_dota_hero_templar_assassin_invis", {Duration = self:GetCaster().invisDuration})
    end
    return true
end
--------------------------------------------------------------------------------------------------------
--      Modifier: modifier_npc_dota_hero_templar_assassin_invis          
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_templar_assassin_invis ~= "" then modifier_npc_dota_hero_templar_assassin_invis = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_templar_assassin_invis:DeclareFunctions()
    return { 
        MODIFIER_PROPERTY_INVISIBILITY_LEVEL   
    }
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_templar_assassin_invis:IsHidden()
    return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_templar_assassin_invis:GetModifierInvisibilityLevel()
    return 1
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_templar_assassin_invis:CheckState()
    local states = { 
        [MODIFIER_STATE_INVISIBLE] = true
    }
    return states
end
--------------------------------------------------------------------------------------------------------
