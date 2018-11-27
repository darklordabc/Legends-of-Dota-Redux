LinkLuaModifier("modifier_item_echo_sabre_consumable", "abilities/items/echo_sabre.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_echo_sabre_consumable_buff", "abilities/items/echo_sabre.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_echo_sabre_consumable_debuff", "abilities/items/echo_sabre.lua", LUA_MODIFIER_MOTION_NONE)

item_echo_sabre_consumable = class({})

function item_echo_sabre_consumable:GetIntrinsicModifierName()
  return "modifier_item_echo_sabre_consumable"
end

function item_echo_sabre_consumable:OnSpellStart()
    self:ConsumeItem(self:GetCaster())
end

function item_echo_sabre_consumable:CastFilterResultTarget(target)
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

function item_echo_sabre_consumable:GetCustomCastErrorTarget(target)
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

function item_echo_sabre_consumable:ConsumeItem(hCaster)
  local name = self:GetIntrinsicModifierName()
  -- Learn the ability container if needed
  if not self:GetCaster():HasAbility("ability_consumable_item_container") then
    local ab = self:GetCaster():AddAbility("ability_consumable_item_container")
    ab:SetLevel(1)
    ab:SetHidden(true)
  end
  -- Double check everything works, then remove the item and add the modifier from the container ability
  local ab = self:GetCaster():FindAbilityByName("ability_consumable_item_container")
  if ab and not ab[name] then
    hCaster:RemoveItem(self)
    hCaster:RemoveModifierByName(name)
    local modifier = hCaster:AddNewModifier(hCaster,ab,name,{})
    ab[name] = true
  end
end


modifier_item_echo_sabre_consumable = class({
  IsHidden = function(self)
    if not self:GetAbility() then
      self:Destroy()
      return
    end
    return self:GetAbility().IsItem
  end,

  IsPassive = function() return true end,
  IsPurgable = function() return false end,
  IsPermanent = function() return true end,
  RemoveOnDeath = function() return false end,
  DestroyOnExpire = function() return false end,
  GetAttributes = function() return MODIFIER_ATTRIBUTE_MULTIPLE end,
  GetTexture = function() return "item_echo_sabre" end,

  DeclareFunctions = function()
    return {
      MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
      MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
      MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
      MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
      MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
      MODIFIER_EVENT_ON_ATTACK_LANDED,
    }
  end,

  GetModifierAttackSpeedBonus_Constant = function(self)
    if not self:GetAbility() then
      self:Destroy()
      return
    end
    return self:GetAbility():GetSpecialValueFor("echo_sabre_bonus_attack_speed")
  end,
  GetModifierPreAttack_BonusDamage = function(self)
    if not self:GetAbility() then
      self:Destroy()
      return
    end
    return self:GetAbility():GetSpecialValueFor("echo_sabre_bonus_damage")
  end,
  GetModifierBonusStats_Intellect = function(self)
    if not self:GetAbility() then
      self:Destroy()
      return
    end
    return self:GetAbility():GetSpecialValueFor("echo_sabre_bonus_intellect")
  end,
  GetModifierBonusStats_Strength = function(self)
    if not self:GetAbility() then
      self:Destroy()
      return
    end
    return self:GetAbility():GetSpecialValueFor("echo_sabre_bonus_strength")
  end,
  GetModifierConstantManaRegen = function(self)
    if not self:GetAbility() then
      self:Destroy()
      return
    end
    return self:GetAbility():GetSpecialValueFor("echo_sabre_bonus_mana_regen")
  end,

  OnAttackLanded = function(self, keys)
    if not IsServer() then return end
    if self:GetParent() ~= keys.attacker then return end
    if self:GetParent():IsRangedAttacker() then return end
    if self:GetAbility():IsItem() and not self:GetAbility():IsCooldownReady() or not self:GetAbility():IsItem() and self:GetRemainingTime() >= 0 then return end

    self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_item_echo_sabre_consumable_buff", {})
    if not keys.target:IsOther() and not keys.target:IsBuilding() and not keys.target:IsMagicImmune() then
      keys.target:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_item_echo_sabre_consumable_debuff", {duration = self:GetAbility():GetSpecialValueFor("slow_duration")})
    end
    if self:GetAbility():IsItem() then
      self:GetAbility():UseResources(false, false, true)
    else
      self:SetDuration(5 * (1-self:GetParent():GetCooldownReduction()), true)
    end
  end,
})

modifier_item_echo_sabre_consumable_buff = class({
  IsHidden = function() return true end,
  IsPurgable = function() return false end,
  DeclareFunctions = function() return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_EVENT_ON_ATTACK_LANDED,} end,
  GetTexture = function() return "item_echo_sabre" end,

  GetModifierAttackSpeedBonus_Constant = function(self)
    if IsServer() and not self:GetParent():IsRangedAttacker() then
      return 490 --self:GetAbility():GetSpecialValueFor("echo_attack_speed")
    end
  end,

  OnAttackLanded = function(self, keys)
    if self:GetParent() ~= keys.attacker then return end
    --incase they gained buff and then became ranged
    if self:GetParent():IsRangedAttacker() then
      self:Destroy()
      return
    end

    if not keys.target:IsOther() and not keys.target:IsBuilding() and not keys.target:IsMagicImmune() then
      keys.target:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_item_echo_sabre_consumable_debuff", {duration = self:GetAbility():GetSpecialValueFor("slow_duration")})
    end
    self:Destroy()
  end,
})

modifier_item_echo_sabre_consumable_debuff = class({
  IsHidden = function() return false end,
  IsPurgable = function() return true end,
  IsDebuff = function() return true end,
  GetTexture = function() return "item_echo_sabre" end,
  DeclareFunctions = function() return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,} end,
  GetModifierMoveSpeedBonus_Percentage = function(self) return -self:GetAbility():GetSpecialValueFor("movement_slow") end,
})