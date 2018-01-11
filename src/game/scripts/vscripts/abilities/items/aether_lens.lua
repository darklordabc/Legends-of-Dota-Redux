item_aether_lens_consumable = class({})

function item_aether_lens_consumable:GetIntrinsicModifierName()
  return "modifier_item_aether_lens_consumable"
end

function item_aether_lens_consumable:OnSpellStart()
    self:ConsumeItem(self:GetCaster())
end

function item_aether_lens_consumable:CastFilterResultTarget(target)
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

function item_aether_lens_consumable:GetCustomCastErrorTarget(target)
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



function item_aether_lens_consumable:ConsumeItem(hCaster)
  
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

LinkLuaModifier("modifier_item_aether_lens_consumable","abilities/items/aether_lens.lua",LUA_MODIFIER_MOTION_NONE)
modifier_item_aether_lens_consumable = class({})

function modifier_item_aether_lens_consumable:GetTexture()
  return "item_aether_lens"
end
function modifier_item_aether_lens_consumable:RemoveOnDeath()
  return false
end
function modifier_item_aether_lens_consumable:IsPurgable()
  return false
end
function modifier_item_aether_lens_consumable:IsPermanent()
  return true
end
function modifier_item_aether_lens_consumable:IsHidden()
  -- The modifier from the item might error
  if not self:GetAbility() then
    self:Destroy()
    return
  end
  -- Only show when the item is not a modifier
  return self:GetAbility().IsItem
end

function modifier_item_aether_lens_consumable:GetAttributes()
  return MODIFIER_ATTRIBUTE_MULTIPLE
end


function modifier_item_aether_lens_consumable:DeclareFunctions()
  local funcs = {
    MODIFIER_PROPERTY_MANA_BONUS,
    MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
    MODIFIER_PROPERTY_CAST_RANGE_BONUS,
    --MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
  }
  return funcs
end

function modifier_item_aether_lens_consumable:GetModifierManaBonus()
  if not self:GetAbility() then
    self:Destroy()
    return
  end
  return self:GetAbility():GetSpecialValueFor("aether_lens_bonus_mana")
end

function modifier_item_aether_lens_consumable:GetModifierConstantManaRegen()
  if not self:GetAbility() then
    self:Destroy()
    return
  end
  return self:GetAbility():GetSpecialValueFor("aether_lens_bonus_mana_regen")
end

function modifier_item_aether_lens_consumable:GetModifierCastRangeBonus()
  if not self:GetAbility() then
    self:Destroy()
    return
  end
  return self:GetAbility():GetSpecialValueFor("aether_lens_cast_range_bonus")
end
-- No longer part of the item in 7.07
--[[function modifier_item_aether_lens_consumable:GetModifierSpellAmplify_Percentage()
  if not self:GetAbility() then
    self:Destroy()
    return
  end
  return self:GetAbility():GetSpecialValueFor("aether_lens_spell_amp")
end]]
