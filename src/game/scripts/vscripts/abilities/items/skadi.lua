-- Look for line 35 for the special values
-- Search for self.parentName if you are making an aura, give it the name of the parent modifier
-- Also change texture, and obviously properties

item_skadi_consumable = class({})

function item_skadi_consumable:GetIntrinsicModifierName()
  return "modifier_item_skadi_consumable"
end

function item_skadi_consumable:OnSpellStart()

  if self:GetCursorTarget() == self:GetCaster() then
    self:ConsumeItem(self:GetCaster())
  end
end


function item_skadi_consumable:ConsumeItem(hCaster)
  
  local name = self:GetIntrinsicModifierName()
  if not self:GetCaster():HasAbility("ability_consumable_item_container") then
    local ab = self:GetCaster():AddAbility("ability_consumable_item_container")
    ab:SetLevel(1)
    ab:SetHidden(true)
  end
  local ab = self:GetCaster():FindAbilityByName("ability_consumable_item_container")
  if ab then
    hCaster:RemoveItem(self)
    hCaster:RemoveModifierByName(name)
    local modifier = hCaster:AddNewModifier(hCaster,ab,name,{})
  else
    print("The item container could not be added!")
  end
end

LinkLuaModifier("modifier_item_skadi_consumable","abilities/items/skadi.lua",LUA_MODIFIER_MOTION_NONE)
modifier_item_skadi_consumable = class({})

function modifier_item_skadi_consumable:GetTexture()
  return "item_skadi"
end
function modifier_item_skadi_consumable:IsPassive()
  return true
end
function modifier_item_skadi_consumable:RemoveOnDeath()
  return false
end
function modifier_item_skadi_consumable:IsPurgable()
  return false
end
function modifier_item_skadi_consumable:IsPermanent()
  return true
end


function modifier_item_skadi_consumable:DeclareFunctions()
  local funcs = {
    MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
    MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
    MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
    MODIFIER_PROPERTY_HEALTH_BONUS,
    MODIFIER_PROPERTY_MANA_BONUS,
    MODIFIER_EVENT_ON_ATTACK_LANDED,
  }
  return funcs
end

function modifier_item_skadi_consumable:GetModifierBonusStats_Strength()
  return self:GetAbility():GetSpecialValueFor("skadi_bonus_all_stats")
end

function modifier_item_skadi_consumable:GetModifierBonusStats_Agility()
  return self:GetAbility():GetSpecialValueFor("skadi_bonus_all_stats")
end

function modifier_item_skadi_consumable:GetModifierBonusStats_Intellect()
  return self:GetAbility():GetSpecialValueFor("skadi_bonus_all_stats")
end

function modifier_item_skadi_consumable:GetModifierHealthBonus()
  return self:GetAbility():GetSpecialValueFor("skadi_bonus_health")
end

function modifier_item_skadi_consumable:GetModifierManaBonus()
  return self:GetAbility():GetSpecialValueFor("skadi_bonus_mana")
end

function modifier_item_skadi_consumable:OnAttackLanded(keys)
  if IsServer() and keys.attacker == self:GetCaster() and not keys.target:IsBuilding() then
    local duration = self:GetAbility():GetSpecialValueFor("skadi_cold_duration_melee")
    if keys.attacker:IsRangedAttacker() then
      duration = self:GetAbility():GetSpecialValueFor("skadi_cold_duration_ranged")
    end
    keys.target:AddNewModifier(self:GetCaster(),self:GetAbility(),"modifier_item_skadi_consumable_slow",{duration = duration})
  end
end


LinkLuaModifier("modifier_item_skadi_consumable_slow","abilities/items/skadi.lua",LUA_MODIFIER_MOTION_NONE)
modifier_item_skadi_consumable_slow = class({})

function modifier_item_skadi_consumable_slow:DeclareFunctions()
  local funcs = {
    MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
    MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, 
  }
  return funcs
end

function modifier_item_skadi_consumable_slow:GetTexture()
  return "item_skadi"
end
function modifier_item_skadi_consumable_slow:GetModifierAttackSpeedBonus_Constant()
  return self:GetAbility():GetSpecialValueFor("skadi_cold_attack_speed")
end

function modifier_item_skadi_consumable_slow:GetModifierMoveSpeedBonus_Percentage()
  return self:GetAbility():GetSpecialValueFor("skadi_cold_movement_speed")
end

function modifier_item_skadi_consumable_slow:GetStatusEffectName()
  return "particles/status_fx/status_effect_frost.vpcf"
end
