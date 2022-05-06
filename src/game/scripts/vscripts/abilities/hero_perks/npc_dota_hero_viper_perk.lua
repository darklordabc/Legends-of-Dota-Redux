--------------------------------------------------------------------------------------------------------
--
--		Hero: Viper
--		Perk: Poison effects applied by Viper lower the target's armor and magic resistance by 10%
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_viper_perk", "abilities/hero_perks/npc_dota_hero_viper_perk.lua" , LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_npc_dota_hero_viper_armor_debuff", "abilities/hero_perks/npc_dota_hero_viper_perk.lua" , LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
npc_dota_hero_viper_perk = class({ GetIntrinsicModifierName = function() return "modifier_npc_dota_hero_viper_perk" end, })
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_npc_dota_hero_viper_perk				
--------------------------------------------------------------------------------------------------------
modifier_npc_dota_hero_viper_perk = class({
  IsHidden = function() return false end,
  IsPassive = function() return true end,
  IsPurgable = function() return false end,
  IsPermanent = function() return true end,
  RemoveOnDeath = function() return false end,
  GetAttributes = function() return MODIFIER_ATTRIBUTE_PERMANENT end,
  GetTexture = function() return "custom/npc_dota_hero_viper_perk" end,
})
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
        ViperPoisonTracker(caster, parent)
      end
    end
  end
  return true
end

function ViperPoisonTracker(self, ent)
  self.perkTargets = self.perkTargets or {}
  table.insert(self.perkTargets, ent)

  self.poisonTracker = self.poisonTracker or Timers:CreateTimer(1,function()
    for k,v in pairs(self.perkTargets) do
      if v and not v:IsNull() then
        local count = 0
        for l,m in pairs(v:FindAllModifiers()) do
          local source = m:GetAbility()
          if source and source:HasAbilityFlag("poison") then
            count = count+1
          end
        end
        if count > 0 then
          local mod = v:FindModifierByNameAndCaster("modifier_npc_dota_hero_viper_armor_debuff", self) or v:AddNewModifier(self, nil, "modifier_npc_dota_hero_viper_armor_debuff", {})
          if mod then
            mod:SetStackCount(count)
          end
        else
          table.remove(self.perkTargets, k)
          v:RemoveModifierByNameAndCaster("modifier_npc_dota_hero_viper_armor_debuff", self)
        end
      else
        table.remove(self.perkTargets, k)
      end
    end

    if #self.perkTargets == 0 then
      self.perkTargets = nil
      self.poisonTracker = nil
      return
    end
  end)
end

modifier_npc_dota_hero_viper_armor_debuff = class({
  IsHidden = function() return false end,
  IsPurgable = function() return true end,
  GetTexture = function() return "custom/npc_dota_hero_viper_perk" end,
  GetAttributes = function() return MODIFIER_ATTRIBUTE_MULTIPLE end,

  DeclareFunctions = function() return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS} end,
  GetModifierMagicalResistanceBonus = function(self) return self.debuff * self:GetStackCount() end,

  OnCreated = function(self)
    self.debuff = -10
    self.armorValue = self:GetParent():GetPhysicalArmorValue(false)

    --weird hack because GetPhysicalArmorValue would call below function when calcualting armor
    -- so we dont define it until after we calculate armor.
    self.GetModifierPhysicalArmorBonus = function(self) return self.armorValue * self.debuff * self:GetStackCount() * 0.01 end
  end,
})
