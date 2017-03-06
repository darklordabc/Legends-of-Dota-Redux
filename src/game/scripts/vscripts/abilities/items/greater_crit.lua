item_greater_crit_consumable = class({})

function item_greater_crit_consumable:GetIntrinsicModifierName()
  return "modifier_item_greater_crit_consumable"
end

function item_greater_crit_consumable:OnSpellStart()

  if self:GetCursorTarget() == self:GetCaster() then
    self:ConsumeItem(self:GetCaster())
  end
end


function item_greater_crit_consumable:ConsumeItem(hCaster)
  
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

LinkLuaModifier("modifier_item_greater_crit_consumable","abilities/items/greater_crit.lua",LUA_MODIFIER_MOTION_NONE)
modifier_item_greater_crit_consumable = class({})

function modifier_item_greater_crit_consumable:GetTexture()
  return "item_greater_crit"
end
function modifier_item_greater_crit_consumable:RemoveOnDeath()
  return false
end
function modifier_item_greater_crit_consumable:IsPurgable()
  return false
end
function modifier_item_greater_crit_consumable:IsPermanent()
  return true
end
function modifier_item_greater_crit_consumable:GetAttributes()
  return MODIFIER_ATTRIBUTE_MULTIPLE
end
function modifier_item_desolator_consumable:IsHidden()
  return self:GetAbility().IsItem
end

function modifier_item_greater_crit_consumable:DeclareFunctions()
  local funcs = {
    MODIFIER_EVENT_ON_ATTACK_START,
    MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
  }
  return funcs
end

function modifier_item_greater_crit_consumable:GetModifierPreAttack_BonusDamage()
  return self:GetAbility():GetSpecialValueFor("greater_crit_bonus_damage")
end

function modifier_item_greater_crit_consumable:OnAttackStart()
  if IsServer() then
    self:GetParent():RemoveModifierByName("modifier_item_greater_crit_consumable_crit")
    local random = RandomInt(0,100)
    if random <= self:GetAbility():GetSpecialValueFor("greater_crit_crit_chance") then
      self:GetParent():AddNewModifier(self:GetParent(),self:GetAbility(),"modifier_item_greater_crit_consumable_crit",{duration = 1})
    end
  end
end

LinkLuaModifier("modifier_item_greater_crit_consumable_crit","abilities/items/greater_crit.lua",LUA_MODIFIER_MOTION_NONE)
modifier_item_greater_crit_consumable_crit = class({})

function modifier_item_greater_crit_consumable_crit:DeclareFunctions()
  local funcs = {
    MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
    MODIFIER_EVENT_ON_ATTACK_LANDED,
  }
  return funcs
end

function modifier_item_greater_crit_consumable_crit:IsHidden()
  return true
end

function modifier_item_greater_crit_consumable_crit:GetTexture()
  return "item_greater_crit"
end

function modifier_item_greater_crit_consumable_crit:GetModifierPreAttack_CriticalStrike()
  if not self:GetAbility() or not self:GetAbility():GetSpecialValueFor("greater_crit_crit_multiplier") then
    self:Destroy()
    return 0
  end
  return self:GetAbility():GetSpecialValueFor("greater_crit_crit_multiplier")
end

function modifier_item_greater_crit_consumable_crit:OnAttackLanded(keys)
  if IsServer() and keys.attacker == self:GetParent() then
    -- particle
    local particle = ParticleManager:CreateParticle("string_1",PATTACH_ABSORIGIN, keys.target)
    ParticleManager:SetParticleControlEnt(particle,0,keys.target,PATTACH_ABSORIGIN_FOLLOW,"follow_origin",keys.target:GetAbsOrigin(),true)
    ParticleManager:DestroyParticle(particle,false)
    ParticleManager:ReleaseParticleIndex(particle)
  end
end





