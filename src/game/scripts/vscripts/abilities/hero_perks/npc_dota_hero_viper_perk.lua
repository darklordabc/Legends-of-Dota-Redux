--------------------------------------------------------------------------------------------------------
--
--		Hero: Viper
--		Perk: Poison effects applied by Viper also lower the target's armor by 2. 
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_viper_perk", "abilities/hero_perks/npc_dota_hero_viper_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_npc_dota_hero_viper_armor_debuff", "abilities/hero_perks/npc_dota_hero_viper_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_viper_perk ~= "" then npc_dota_hero_viper_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_npc_dota_hero_viper_perk				
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_viper_perk ~= "" then modifier_npc_dota_hero_viper_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_viper_perk:IsPassive()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_viper_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_viper_perk:RemoveOnDeath()
	return false
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------

function perkViper(filterTable)
  local parent_index = filterTable["entindex_parent_const"]
  local caster_index = filterTable["entindex_caster_const"]
  local ability_index = filterTable["entindex_ability_const"]
  if not parent_index or not caster_index or not ability_index then
    return true
  end
  local parent = EntIndexToHScript( parent_index )
  local caster = EntIndexToHScript( caster_index )
  if parent:GetTeamNumber() == caster:GetTeamNumber() then return end
  local ability = EntIndexToHScript( ability_index )
  if ability then
    if caster:HasModifier("modifier_npc_dota_hero_viper_perk") then
      if ability:HasAbilityFlag("poison") then
        parent:AddNewModifier(caster, nil, "modifier_npc_dota_hero_viper_armor_debuff", {duration = filterTable["duration"]})
      end
    end  
  end
end

if modifier_npc_dota_hero_viper_armor_debuff ~= "" then modifier_npc_dota_hero_viper_armor_debuff = class({}) end

function modifier_npc_dota_hero_viper_armor_debuff:OnCreated()
	self.armordebuff = -2
end

function modifier_npc_dota_hero_viper_armor_debuff:IsHidden()
	return false
end

function modifier_npc_dota_hero_viper_armor_debuff:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
	}
	return funcs
end

function modifier_npc_dota_hero_viper_armor_debuff:IsPurgable()
	return true
end

function modifier_npc_dota_hero_viper_armor_debuff:GetModifierPhysicalArmorBonus()
	return self.armordebuff
end

function modifier_npc_dota_hero_viper_armor_debuff:GetTexture()
	return "viper_nethertoxin"
end
