--------------------------------------------------------------------------------------------------------
--
--		Hero: huskar
--		Perk: Regenerates 1hp/s for every 10% of health he is missing
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_huskar_perk", "abilities/hero_perks/npc_dota_hero_huskar_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_huskar_perk == nil then npc_dota_hero_huskar_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_npc_dota_hero_huskar_perk				
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_huskar_perk == nil then modifier_npc_dota_hero_huskar_perk = class({}) end
--------------------------------------------------------------------------------------------------------
if IsServer() then
    function modifier_npc_dota_hero_huskar_perk:OnCreated()
        self:StartIntervalThink(1.0)
        self:OnIntervalThink()
    end

    function modifier_npc_dota_hero_huskar_perk:OnIntervalThink()
        local hero = self:GetParent()
        local maxHealth = hero:GetMaxHealth()
        local health = hero:GetHealth()

        local stacks = 10 - math.floor((health / maxHealth) * 10)

        self:SetStackCount(stacks)
    end
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_huskar_perk:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT
    }

    return funcs
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_huskar_perk:GetModifierConstantHealthRegen()
    return 1 * self:GetStackCount()
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_huskar_perk:GetAttributes()
  return MODIFIER_ATTRIBUTE_PERMANENT + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_huskar_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_huskar_perk:IsHidden()
	return true
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------

