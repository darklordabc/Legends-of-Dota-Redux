item_monkey_king_bar_consumable = class({})

function item_monkey_king_bar_consumable:GetIntrinsicModifierName()
  return "modifier_item_monkey_king_bar_consumable"
end

function item_monkey_king_bar_consumable:OnSpellStart()
  self:ConsumeItem(self:GetCaster())
end

function item_monkey_king_bar_consumable:CastFilterResultTarget(target)
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

function item_monkey_king_bar_consumable:GetCustomCastErrorTarget(target)
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


function item_monkey_king_bar_consumable:ConsumeItem(hCaster)
  
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

LinkLuaModifier("modifier_item_monkey_king_bar_consumable","abilities/items/monkey_king_bar.lua",LUA_MODIFIER_MOTION_NONE)
modifier_item_monkey_king_bar_consumable = class({})

function modifier_item_monkey_king_bar_consumable:GetTexture()
  return "item_monkey_king_bar"
end
function modifier_item_monkey_king_bar_consumable:RemoveOnDeath()
  return false
end
function modifier_item_monkey_king_bar_consumable:IsPurgable()
  return false
end
function modifier_item_monkey_king_bar_consumable:IsPermanent()
  return true
end
function modifier_item_monkey_king_bar_consumable:GetAttributes()
  return MODIFIER_ATTRIBUTE_MULTIPLE
end
function modifier_item_monkey_king_bar_consumable:IsHidden()
  if not self:GetAbility() then
    self:Destroy()
  end
  return self:GetAbility().IsItem
end

function modifier_item_monkey_king_bar_consumable:CheckState()
  local funcs = {
    [MODIFIER_STATE_CANNOT_MISS] = true,
  }
  return funcs
end

function modifier_item_monkey_king_bar_consumable:DeclareFunctions()
  local funcs = {
    MODIFIER_EVENT_ON_ATTACK_LANDED,
    MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
    MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE_POST_CRIT,
  }
  return funcs
end

function modifier_item_monkey_king_bar_consumable:GetModifierPreAttack_BonusDamage()
  return self:GetAbility():GetSpecialValueFor("greater_crit_bonus_damage")
end

function modifier_item_monkey_king_bar_consumable:GetModifierPreAttack_BonusDamagePostCrit()
  if IsServer() then
    if not self.bash_damage then 
      self.bash_damage = 0 
    end
    return self.bash_damage
  end
end

function modifier_item_monkey_king_bar_consumable:OnAttackLanded(keys)
  if IsServer() and keys.attacker == self:GetParent() then
   


    self.bash_damage = nil
    local random = RandomInt(0,100)
    if random <= self:GetAbility():GetSpecialValueFor("monkey_king_bar_bash_chance") then
      self.bash_damage = self:GetAbility():GetSpecialValueFor("monkey_king_bar_bash_damage")
       -- Checks
      if not keys.target:IsBuilding() then
        keys.target:AddNewModifier(self:GetParent(),self,"modifier_stunned",{duration = self:GetAbility():GetSpecialValueFor("monkey_king_bar_bash_stun")})
      end
    end
  end
end





