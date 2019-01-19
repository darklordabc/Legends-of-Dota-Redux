item_heart_consumable = class({})

function item_heart_consumable:GetIntrinsicModifierName()
  return "modifier_item_heart_consumable"
end

function item_heart_consumable:OnSpellStart()
  self:ConsumeItem(self:GetCaster())
end

function item_heart_consumable:CastFilterResultTarget(target)
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

function item_heart_consumable:GetCustomCastErrorTarget(target)
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


function item_heart_consumable:ConsumeItem(hCaster)
  
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

LinkLuaModifier("modifier_item_heart_consumable","abilities/items/heart.lua",LUA_MODIFIER_MOTION_NONE)
modifier_item_heart_consumable = class({})

function modifier_item_heart_consumable:GetTexture()
  if self:GetRemainingTime() <= 0 or self:GetRemainingTime() >= 20 then
    return "item_heart"
  else
    return "custom/item_heart_disabled"
  end
end


function modifier_item_heart_consumable:RemoveOnDeath()
  return false
end
function modifier_item_heart_consumable:IsPurgable()
  return false
end
function modifier_item_heart_consumable:IsPermanent()
  return true
end
function modifier_item_heart_consumable:IsHidden()
  if not self:GetAbility() then
    self:Destroy()
    return
  end
  return self:GetAbility().IsItem
end
function modifier_item_heart_consumable:GetAttributes()
  return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_item_heart_consumable:DeclareFunctions()
  local funcs = {
    MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
    MODIFIER_PROPERTY_HEALTH_BONUS,
    MODIFIER_EVENT_ON_TAKEDAMAGE,
    MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE,
    MODIFIER_PROPERTY_HP_REGEN_AMPLIFY_PERCENTAGE_SOURCE, 
  }
  return funcs
end

function modifier_item_heart_consumable:GetModifierHPRegenAmplify_PercentageSource()
  if not self:GetAbility() then
    self:Destroy()
    return
  end
  return self:GetAbility():GetSpecialValueFor("heart_hp_regen_amp")
end

function modifier_item_heart_consumable:GetModifierBonusStats_Strength()
  if not self:GetAbility() then
    self:Destroy()
    return
  end
  return self:GetAbility():GetSpecialValueFor("heart_bonus_strength")
end
function modifier_item_heart_consumable:GetModifierHealthBonus()
  if not self:GetAbility() then
    self:Destroy()
    return
  end
  return self:GetAbility():GetSpecialValueFor("heart_bonus_health")
end

function modifier_item_heart_consumable:GetModifierHealthRegenPercentage()
  --if IsServer() then
    if not self:GetAbility() then
      self:Destroy()
      return
    end
    if self:GetParent():IsIllusion() then
      return 0
    end
    
    if self:GetRemainingTime() <= 0 or self:GetRemainingTime() >= 20 then
      return self:GetAbility():GetSpecialValueFor("heart_health_regen_rate")
    end
    return 0
  --end
end


function modifier_item_heart_consumable:DestroyOnExpire()
  return false
end

function modifier_item_heart_consumable:OnTakeDamage(keys)
  if keys.attacker and keys.unit == self:GetCaster() and (keys.attacker:IsHero() or keys.attacker:GetUnitName() == "npc_dota_roshan" )and self:GetCaster():IsRealHero() then
    if not self:GetAbility() then
      self:Destroy()
      return
    end
    local cooldown = self:GetAbility():GetSpecialValueFor("heart_cooldown_melee")
    if self:GetCaster():IsRangedAttacker() then
      local cooldown = self:GetAbility():GetSpecialValueFor("heart_cooldown_ranged_tooltip")
    end
    if IsServer() then
      local cdr = 1 - self:GetParent():GetCooldownReduction()
      if self:GetAbility():IsItem() then
        self:GetAbility():StartCooldown(cooldown * cdr)
      end
      self:SetDuration(cooldown * cdr, true)
    end
  end
end


