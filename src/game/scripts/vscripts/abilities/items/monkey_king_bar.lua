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

function modifier_item_monkey_king_bar_consumable:DeclareFunctions()
  local funcs = {
    MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
    MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
    MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_MAGICAL,
    MODIFIER_EVENT_ON_ATTACK_RECORD
  }
  
  -- Tracking when to give the true strike + bonus magical damage
  self.pierce_proc      = true
  self.pierce_records     = {}

  return funcs`
end

function modifier_item_monkey_king_bar_consumable:GetModifierAttackSpeedBonus_Constant()
  if not self:GetAbility() then
    self:Destroy()
  end
  return self:GetAbility():GetSpecialValueFor("monkey_king_bar_bonus_attack_speed")
end

function modifier_item_monkey_king_bar_consumable:GetModifierPreAttack_BonusDamage()
  if not self:GetAbility() then
    self:Destroy()
  end
  return self:GetAbility():GetSpecialValueFor("monkey_king_bar_bonus_damage")
end

-- MKB Pierces do not stack
function modifier_item_monkey_king_bar_consumable:GetModifierProcAttack_BonusDamage_Magical(keys)
  if not IsServer() then return end

  for _, record in pairs(self.pierce_records) do  
    if record == keys.record then
      table.remove(self.pierce_records, _)

      if not self.parent:IsIllusion() and self:GetAbility():GetSecondaryCharges() == 1 and not keys.target:IsBuilding() then
        -- self.parent:EmitSound("DOTA_Item.MKB.proc")
        SendOverheadEventMessage(nil, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE, keys.target, self.bonus_chance_damage, nil)
        
        return self.bonus_chance_damage
      end
    end
  end
end

function modifier_item_monkey_king_bar_consumable:OnAttackRecord(keys)
  if keys.attacker == self.parent then
    if self.pierce_proc then
      table.insert(self.pierce_records, keys.record)
      self.pierce_proc = false
    end
  
    if RollPseudoRandom(self.bonus_chance, self) then
      self.pierce_proc = true
    end
  end
end