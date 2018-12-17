item_desolator_consumable = class({})

function item_desolator_consumable:GetIntrinsicModifierName()
  return "modifier_item_desolator_consumable"
end

function item_desolator_consumable:OnSpellStart()
    self:ConsumeItem(self:GetCaster())
end

function item_desolator_consumable:CastFilterResultTarget(target)
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

function item_desolator_consumable:GetCustomCastErrorTarget(target)
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



function item_desolator_consumable:ConsumeItem(hCaster)
  
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

LinkLuaModifier("modifier_item_desolator_consumable","abilities/items/desolator.lua",LUA_MODIFIER_MOTION_NONE)
modifier_item_desolator_consumable = class({})

function modifier_item_desolator_consumable:GetTexture()
  return "item_desolator"
end
function modifier_item_desolator_consumable:RemoveOnDeath()
  return false
end
function modifier_item_desolator_consumable:IsPurgable()
  return false
end
function modifier_item_desolator_consumable:IsPermanent()
  return true
end
function modifier_item_desolator_consumable:IsHidden()
  if not self:GetAbility() then
    self:Destroy()
    return
  end
  return self:GetAbility().IsItem
end
function modifier_item_desolator_consumable:GetAttributes()
  return MODIFIER_ATTRIBUTE_MULTIPLE
end


function modifier_item_desolator_consumable:DeclareFunctions()
  local funcs = {
    MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
    MODIFIER_EVENT_ON_ATTACK_LANDED,
  }
  return funcs
end

function modifier_item_desolator_consumable:GetModifierPreAttack_BonusDamage()
  if not self:GetAbility() then
    self:Destroy()
    return
  end
  return self:GetAbility():GetSpecialValueFor("desolator_bonus_damage")
end


function modifier_item_desolator_consumable:OnAttackLanded(keys)
  if IsServer() and keys.attacker == self:GetCaster() and keys.target:GetTeamNumber() ~= self:GetParent():GetTeamNumber() then
    if not self:GetAbility() then
      self:Destroy()
      return
    end
    local duration = self:GetAbility():GetSpecialValueFor("desolator_corruption_duration")
    keys.target:AddNewModifier(self:GetCaster(),self:GetAbility(),"modifier_item_desolator_consumable_corruption",{duration = duration})
  end
end


LinkLuaModifier("modifier_item_desolator_consumable_corruption","abilities/items/desolator.lua",LUA_MODIFIER_MOTION_NONE)
modifier_item_desolator_consumable_corruption = class({})

function modifier_item_desolator_consumable_corruption:DeclareFunctions()
  local funcs = {
    MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
    MODIFIER_PROPERTY_PROJECTILE_NAME, 
  }
  return funcs
end

function modifier_item_desolator_consumable:GetModifierProjectileName()
  return "particles/items_fx/desolator_projectile.vpcf"
end

function modifier_item_desolator_consumable_corruption:IsDebuff()
  return true
end

function modifier_item_desolator_consumable_corruption:GetTexture()
  return "item_desolator"
end

function modifier_item_desolator_consumable_corruption:GetModifierPhysicalArmorBonus()
  if not self:GetAbility() or not self:GetAbility():GetSpecialValueFor("desolator_corruption_armor") then
    self:Destroy()
    return 0
  end
  return self:GetAbility():GetSpecialValueFor("desolator_corruption_armor")
end

