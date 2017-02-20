--------------------------------------------------------------------------------------------------------
--
--		Hero: Slardar
--		Perk: Slardar gets 1 gold whenever he bashes a unit.
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_slardar_perk", "abilities/hero_perks/npc_dota_hero_slardar_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_slardar_perk ~= "" then npc_dota_hero_slardar_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_npc_dota_hero_slardar_perk				
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_slardar_perk ~= "" then modifier_npc_dota_hero_slardar_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_slardar_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_slardar_perk:IsHidden()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_slardar_perk:IsPurgable()
	return false
end

function modifier_npc_dota_hero_slardar_perk:RemoveOnDeath()
  return false
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_slardar_perk:OnCreated()
  if IsServer() then
    local caster = self:GetCaster()
    
    Timers:CreateTimer(function()
      caster:AddItemByName('item_sprint')
        return
    end, DoUniqueString('give_slard_sprint'), .5)
  end
end

function perkSlardar(filterTable)
end