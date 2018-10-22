--------------------------------------------------------------------------------------------------------
--
--      Hero: Clockwork
--      Perk: Fires a random flare to any part of the map every 15 seconds. Scales with Rocket Flare.
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_rattletrap_perk", "abilities/hero_perks/npc_dota_hero_rattletrap_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_npc_dota_hero_rattletrap_flare_delay", "abilities/hero_perks/npc_dota_hero_rattletrap_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_rattletrap_perk ~= "" then npc_dota_hero_rattletrap_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--      Modifier: modifier_npc_dota_hero_rattletrap_perk                
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_rattletrap_perk ~= "" then modifier_npc_dota_hero_rattletrap_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_rattletrap_perk:IsPassive()
    return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_rattletrap_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_rattletrap_perk:RemoveOnDeath()
    return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_rattletrap_perk:OnIntervalThink(keys)
    if IsServer() then
        local caster = self:GetCaster()
        if caster:HasModifier("modifier_rattletrap_battery_assault") then
            self:SetStackCount(0)
        else 
            self:SetStackCount(1)
        end
    end
end

function modifier_npc_dota_hero_rattletrap_perk:IsHidden()
    return self:GetStackCount() == 1
end
--------------------------------------------------------------------------------------------------------

function modifier_npc_dota_hero_rattletrap_perk:CheckState()
    return {
        [MODIFIER_STATE_NO_UNIT_COLLISION ] = true,
    }
end