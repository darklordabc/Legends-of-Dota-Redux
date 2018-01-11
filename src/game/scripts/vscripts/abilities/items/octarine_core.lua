item_octarine_core_consumable = class({})

function item_octarine_core_consumable:GetIntrinsicModifierName()
  return "modifier_item_octarine_core_consumable"
end

function item_octarine_core_consumable:OnSpellStart()
  self:ConsumeItem(self:GetCaster())
end

function item_octarine_core_consumable:CastFilterResultTarget(target)
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

function item_octarine_core_consumable:GetCustomCastErrorTarget(target)
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



function item_octarine_core_consumable:ConsumeItem(hCaster)
  
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

LinkLuaModifier("modifier_item_octarine_core_consumable","abilities/items/octarine_core.lua",LUA_MODIFIER_MOTION_NONE)
modifier_item_octarine_core_consumable = class({})

function modifier_item_octarine_core_consumable:GetTexture()
  return "item_octarine_core"
end
function modifier_item_octarine_core_consumable:RemoveOnDeath()
  return false
end
function modifier_item_octarine_core_consumable:IsPurgable()
  return false
end
function modifier_item_octarine_core_consumable:IsPermanent()
  return true
end
function modifier_item_octarine_core_consumable:GetAttributes()
  return MODIFIER_ATTRIBUTE_MULTIPLE
end
function modifier_item_octarine_core_consumable:IsHidden()
  if not self:GetAbility() then
    self:Destroy()
    return
  end
  return self:GetAbility().IsItem
end


function modifier_item_octarine_core_consumable:DeclareFunctions()
  local funcs = {
    MODIFIER_EVENT_ON_TAKEDAMAGE,
    MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
    MODIFIER_PROPERTY_HEALTH_BONUS,
    MODIFIER_PROPERTY_MANA_BONUS,
    MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE,
  }
  return funcs
end

function modifier_item_octarine_core_consumable:GetModifierBonusStats_Intellect()
  if not self:GetAbility() then
    self:Destroy()
    return
  end
  return self:GetAbility():GetSpecialValueFor("octarine_core_bonus_intelligence")
end

function modifier_item_octarine_core_consumable:GetModifierHealthBonus()
  if not self:GetAbility() then
    self:Destroy()
    return
  end
  return self:GetAbility():GetSpecialValueFor("octarine_core_bonus_health")
end

function modifier_item_octarine_core_consumable:GetModifierManaBonus()
  if not self:GetAbility() then
    self:Destroy()
    return
  end
  return self:GetAbility():GetSpecialValueFor("octarine_core_bonus_mana")
end

function modifier_item_octarine_core_consumable:GetModifierPercentageCooldown()
  if not self:GetAbility() then
    self:Destroy()
    return
  end
  return self:GetAbility():GetSpecialValueFor("octarine_core_bonus_cooldown")
end

function modifier_item_octarine_core_consumable:OnTakeDamage(keys)
  if IsServer() and keys.attacker == self:GetCaster() and keys.inflictor then
  
    if self:GetParent():IsIllusion() or self:GetParent():IsClone() or self:GetParent():IsTempestDouble() then
      return
    end
    
    if not self:GetAbility() then
      self:Destroy()
      return
    end

    local damage_flags = keys.damage_flags
    
    if bit.band(damage_flags, DOTA_DAMAGE_FLAG_HPLOSS) == DOTA_DAMAGE_FLAG_HPLOSS then
      return nil
    end
    if bit.band(damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) == DOTA_DAMAGE_FLAG_REFLECTION then
      return nil
    end
    --counting the amout of octarine cores
    local count = 0
    for i=0,self:GetCaster():GetModifierCount() do
      if self:GetCaster():GetModifierNameByIndex(i) == "modifier_item_octarine_core_consumable" then
        count = count + 1
      end
    end
    -- This shouldnt happen, just in case. Divide it by the amount of modifiers to prevent them stacking
    if count == 0 then count = 1 end

    local healFactor = self:GetAbility():GetSpecialValueFor("octarine_core_hero_lifesteal") * 0.01 / count
    if not keys.unit:IsHero() then
      healFactor = self:GetAbility():GetSpecialValueFor("octarine_core_creep_lifesteal") * 0.01 / count
    end
    local heal = healFactor * keys.damage
    
    --make sure unit isnt dead before we heal them
    if self:GetCaster():GetHealth() > 0 then 
      self:GetCaster():Heal(heal,self:GetAbility())
      ParticleManager:CreateParticle("particles/items3_fx/octarine_core_lifesteal.vpcf", PATTACH_ABSORIGIN, self:GetCaster())
    end
  end
end

