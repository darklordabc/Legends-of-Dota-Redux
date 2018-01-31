-- Look for line 35 for the special values
-- Search for self.parentName if you are making an aura, give it the name of the parent modifier
-- Also change texture, and obviously properties

item_skadi_consumable = class({})

function item_skadi_consumable:GetIntrinsicModifierName()
  return "modifier_item_skadi_consumable"
end

function item_skadi_consumable:OnSpellStart()
  self:ConsumeItem(self:GetCaster())
end

function item_skadi_consumable:CastFilterResultTarget(target)
  -- Check if its the caster thats targetted
  if self:GetCaster() ~= target then
    return UF_FAIL_CUSTOM
  end
  -- Check if the ability exists/can be given
  if IsServer() then
    local name = self:GetIntrinsicModifierName()
    if not self:GetCaster():HasAbility("ability_consumable_item_container") then
      local ab = self:GetCaster():AddAbility("ability_consumable_item_container")
      ab:SetLevel(1)
      ab:SetHidden(true)
    end
    local ab = self:GetCaster():FindAbilityByName("ability_consumable_item_container")
    if not ab or ab[name] then
      return UF_FAIL_CUSTOM
    end
    return UF_SUCCESS
  end
  return UF_SUCCESS
end

function item_skadi_consumable:GetCustomCastErrorTarget(target)
  if self:GetCaster() ~= target then
    return "#consumable_items_only_self"
  end
  local ab  = self:GetCaster():FindAbilityByName("ability_consumable_item_container")
  if not ab then
    return "#consumable_items_no_available_slot"
  end
  local name = self:GetIntrinsicModifierName()
  if ab[name] then
    return "#consumable_items_already_consumed"
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
  if ab and not ab[name] then
    hCaster:RemoveItem(self)
    hCaster:RemoveModifierByName(name)
    local modifier = hCaster:AddNewModifier(hCaster,ab,name,{})
    ab[name] = true
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
function modifier_item_skadi_consumable:IsHidden()
  if not self:GetAbility() then
    self:Destroy()
    return
  end
  return self:GetAbility().IsItem
end
function modifier_item_skadi_consumable:GetAttributes()
  return MODIFIER_ATTRIBUTE_MULTIPLE
end



function modifier_item_skadi_consumable:DeclareFunctions()
  local funcs = {
    MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
    MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
    MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
    MODIFIER_PROPERTY_HEALTH_BONUS,
    MODIFIER_PROPERTY_MANA_BONUS,
    MODIFIER_EVENT_ON_ATTACK_LANDED,
    MODIFIER_PROPERTY_PROJECTILE_NAME,
  }
  return funcs
end

function modifier_item_skadi_consumable:GetModifierProjectileName()
  return "particles/items2_fx/skadi_projectile.vpcf"
end

function modifier_item_skadi_consumable:GetModifierBonusStats_Strength()
  if not self:GetAbility() then
    self:Destroy()
    return
  end
  return self:GetAbility():GetSpecialValueFor("skadi_bonus_all_stats")
end

function modifier_item_skadi_consumable:GetModifierBonusStats_Agility()
  if not self:GetAbility() then
    self:Destroy()
    return
  end
  return self:GetAbility():GetSpecialValueFor("skadi_bonus_all_stats")
end

function modifier_item_skadi_consumable:GetModifierBonusStats_Intellect()
  if not self:GetAbility() then
    self:Destroy()
    return
  end
  return self:GetAbility():GetSpecialValueFor("skadi_bonus_all_stats")
end

function modifier_item_skadi_consumable:GetModifierHealthBonus()
  if not self:GetAbility() then
    self:Destroy()
    return
  end
  return self:GetAbility():GetSpecialValueFor("skadi_bonus_health")
end

function modifier_item_skadi_consumable:GetModifierManaBonus()
  if not self:GetAbility() then
    self:Destroy()
    return
  end
  return self:GetAbility():GetSpecialValueFor("skadi_bonus_mana")
end

function modifier_item_skadi_consumable:OnAttackLanded(keys)
  if IsServer() and keys.attacker == self:GetCaster() and not keys.target:IsBuilding() then
    if not self:GetAbility() then
      self:Destroy()
      return
    end
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
  if not self:GetAbility() or not self:GetAbility():GetSpecialValueFor("skadi_cold_attack_speed") then
    self:Destroy()
    return 0
  end
  return self:GetAbility():GetSpecialValueFor("skadi_cold_attack_speed")
end

function modifier_item_skadi_consumable_slow:GetModifierMoveSpeedBonus_Percentage()
  if not self:GetAbility() then
    self:Destroy()
    return
  end
  return self:GetAbility():GetSpecialValueFor("skadi_cold_movement_speed")
end

function modifier_item_skadi_consumable_slow:GetStatusEffectName()
  return "particles/status_fx/status_effect_frost.vpcf"
end
